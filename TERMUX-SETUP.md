# Termux Android Setup Guide

Complete guide for setting up GitHub Copilot CLI on **Android via Termux** — including proot Ubuntu, wake locks, Termux API, permissions, boot scripts, and all Android-specific constraints.

---

## Critical Android Constraints

### Android SIGKILL / Background Process Kills

Android aggressively kills background processes with **signal 9 (SIGKILL)** — especially when:
- The screen turns off
- Another app goes foreground
- Android memory manager runs
- Battery optimization is active

**This means:**
- NEVER run `copilot` with background agents (`mode: "background"`)
- NEVER rely on `nohup`, `&`, `screen` without a wake lock
- Long builds (`cargo build`, `gradle assembleRelease`) can be killed mid-run
- Always acquire a **wake lock** before long-running work
- Set **`mode: "sync"`** for all Copilot sub-agents
- Use `tmux` to keep sessions alive across screen locks

### Copilot CLI — No Background Agents Rule

The global instructions file `~/.copilot/copilot-instructions.md` enforces this:

```
NEVER use background agents.
Do not use the task tool with mode: "background" under any circumstances.
This environment runs on Android (Termux proot Ubuntu) where background
sub-agent processes are killed by the OS (SIGKILL/signal 9) due to
Android memory limits. Always do work directly in the main conversation
using inline tool calls.
```

---

## Phase 1 — Native Termux Setup

Run all steps below **in the native Termux app** (not inside Ubuntu proot).

### 1.1 Initial Package Setup

```bash
pkg update -y && pkg upgrade -y

pkg install -y \
  proot-distro git curl wget openssh python nodejs \
  termux-api termux-tools \
  starship fzf zoxide bat eza fd ripgrep \
  jq htop btop ncdu glow tmate tmux

# Approve Android storage dialog
termux-setup-storage
```

### 1.2 Wake Lock — CRITICAL (prevents SIGKILL)

```bash
termux-wake-lock
```

Add to Termux:Boot so it runs every reboot:

```bash
mkdir -p ~/.termux/boot
printf '#!/data/data/com.termux/files/usr/bin/sh\ntermux-wake-lock\n' \
  > ~/.termux/boot/00-wake-lock
chmod +x ~/.termux/boot/00-wake-lock
```

### 1.3 Install proot Ubuntu

```bash
proot-distro install ubuntu
# Verify
proot-distro login ubuntu -- lsb_release -a
```

### 1.4 Auto-Login to Ubuntu

Add to `~/.bashrc`:

```bash
if [ -n "${PS1:-}" ] \
  && [ -z "${TERMUX_SKIP_AUTO_UBUNTU:-}" ] \
  && [ -z "${TERMUX_AUTO_UBUNTU_ENTERED:-}" ] \
  && command -v proot-distro >/dev/null 2>&1; then
  export TERMUX_AUTO_UBUNTU_ENTERED=1
  exec proot-distro login ubuntu --user root
fi

alias ubuntu='proot-distro login ubuntu --user root'
alias native-termux='TERMUX_SKIP_AUTO_UBUNTU=1 bash -l'
alias start-acodex-ubuntu='acodex-ubuntu 8767'
```

Bypass auto-login:
```bash
TERMUX_SKIP_AUTO_UBUNTU=1 bash -l
# or just run:
native-termux
```

### 1.5 Termux:Widget Shortcuts

```bash
mkdir -p ~/.shortcuts

# Ubuntu login
printf '#!/data/data/com.termux/files/usr/bin/bash\nexec proot-distro login ubuntu --user root\n' \
  > ~/.shortcuts/ubuntu

# Stay in native Termux
printf '#!/data/data/com.termux/files/usr/bin/bash\nexec bash -l\n' \
  > ~/.shortcuts/native-termux

# AcodeX editor backend
printf '#!/data/data/com.termux/files/usr/bin/bash\nexec acodex-ubuntu 8767\n' \
  > ~/.shortcuts/start-acodex-ubuntu

chmod +x ~/.shortcuts/*
```

### 1.6 Termux:Boot Scripts

```bash
mkdir -p ~/.termux/boot

# Wake lock (runs first on boot)
printf '#!/data/data/com.termux/files/usr/bin/sh\ntermux-wake-lock\n' \
  > ~/.termux/boot/00-wake-lock

# SFTP file-manager bridge
printf '#!/data/data/com.termux/files/usr/bin/sh\nstart-ubuntu-filemanager >/dev/null 2>&1\n' \
  > ~/.termux/boot/start-ubuntu-filemanager

# AcodeX (optional)
printf '#!/data/data/com.termux/files/usr/bin/sh\nexec acodex-ubuntu 8767\n' \
  > ~/.termux/boot/start-acodex-ubuntu

chmod +x ~/.termux/boot/*
```

---

## Phase 2 — Termux:API Setup

Termux:API gives terminal access to Android hardware: camera, GPS, battery, SMS, contacts, notifications, clipboard, TTS, sensors.

### 2.1 Install

1. Install **Termux:API** from **F-Droid** (same F-Droid repo as Termux — NOT Google Play)
   - URL: https://f-droid.org/packages/com.termux.api/
2. Install the pkg:

```bash
pkg install -y termux-api
```

### 2.2 Grant All Android Permissions

Save this as `~/grant-all-permissions.sh` and run from **native Termux**. Each command triggers an Android permission dialog — approve each one:

```bash
#!/data/data/com.termux/files/usr/bin/bash
echo "=== Granting All Termux Permissions ==="

echo "[1] Wake lock..."
termux-wake-lock && echo "  OK Wake lock"

echo "[2] Storage (approve Android dialog)..."
termux-setup-storage

echo "[3] Battery (Termux:API dialog)..."
termux-battery-status && echo "  OK Battery"

echo "[4] Camera..."
termux-camera-info && echo "  OK Camera"

echo "[5] Location..."
termux-location --provider network --request once && echo "  OK Location"

echo "[6] Microphone..."
termux-microphone-record -d 2>/dev/null; echo "  OK Microphone"

echo "[7] Contacts..."
termux-contacts-list -l 1 2>/dev/null; echo "  OK Contacts"

echo "[8] SMS..."
termux-sms-list -l 1 2>/dev/null; echo "  OK SMS"

echo "[9] Call log..."
termux-call-log -l 1 2>/dev/null; echo "  OK Call log"

echo "[10] Notifications..."
termux-notification --title "Termux Setup" --content "All permissions granted!" \
  && echo "  OK Notifications"

echo ""
echo "=== Done! Approve any Android dialogs that appeared ==="
```

```bash
chmod +x ~/grant-all-permissions.sh
# Also add as a widget shortcut:
cp ~/grant-all-permissions.sh ~/.shortcuts/grant-all-permissions
chmod +x ~/.shortcuts/grant-all-permissions
```

### 2.3 Disable Battery Optimization

Battery optimization kills Termux even with a wake lock. Disable for all Termux apps:

```
Settings -> Apps -> Termux -> Battery -> Unrestricted
Settings -> Apps -> Termux:API -> Battery -> Unrestricted
Settings -> Apps -> Termux:Boot -> Battery -> Unrestricted (if installed)
```

Samsung one UI: Settings -> Device Care -> Battery -> Background usage limits -> Never sleeping apps -> Add Termux

### 2.4 Termux:API from Ubuntu proot

Termux:API binaries live in Termux native — expose them inside Ubuntu proot:

```bash
# In Ubuntu proot — add to /etc/profile.d/termux-api.sh:
cat > /etc/profile.d/termux-api.sh << 'EOF'
TERMUX_BIN="/data/data/com.termux/files/usr/bin"
if [ -d "$TERMUX_BIN" ]; then
  export PATH="$TERMUX_BIN:$PATH"
fi
EOF

source /etc/profile.d/termux-api.sh

# Test from Ubuntu
termux-battery-status
termux-notification --title "Hello from Ubuntu proot" --content "Termux API works!"
```

### 2.5 Key Termux:API Commands Reference

```bash
# Device info
termux-battery-status           # level, charging state, health
termux-camera-info              # list cameras and capabilities
termux-sensor -l                # list all available sensors

# Location
termux-location                                    # GPS or network
termux-location --provider gps                     # force GPS

# Notifications
termux-notification --title "Title" --content "Body"
termux-notification-remove <id>

# Clipboard
termux-clipboard-get
termux-clipboard-set "text"

# Text-to-speech
termux-tts-speak "Hello world"
termux-tts-engines

# Hardware
termux-torch on                 # flashlight on
termux-torch off
termux-vibrate -d 500           # vibrate 500ms

# Network
termux-wifi-connectioninfo
termux-wifi-scaninfo

# Contacts
termux-contacts-list
termux-sms-list
termux-sms-send -n "+1234567890" "Message text"
termux-call-log

# Files / Share
termux-share -a send file.txt   # Android share sheet
termux-open file.pdf            # open with Android app
termux-open-url "https://..."   # open URL in default browser
termux-storage-get ~/file.txt   # pick file from Android storage picker
```

---

## Phase 3 — Termux Properties

Edit `~/.termux/termux.properties`:

```properties
# Allow other Android apps to run Termux commands
allow-external-apps = true

# Long scrollback
terminal-transcript-rows = 10000

# Start in fullscreen
fullscreen = true

# Extra keys rows for developer workflow
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]

# Volume buttons control phone volume
volume-keys = volume

# Bell vibrates instead of audio beep
bell-character = vibrate
```

Apply: `termux-reload-settings`

---

## Phase 4 — Android File Access

### Shared Storage

```bash
termux-setup-storage
# Symlinks created under ~/storage/:
#   ~/storage/shared     -> /storage/emulated/0
#   ~/storage/downloads  -> Downloads
#   ~/storage/dcim       -> Camera photos
#   ~/storage/movies     -> Movies
#   ~/storage/music      -> Music

# From Ubuntu proot:
ls /storage/emulated/0/Download/
ls /root/AndroidFiles/      # -> /storage/emulated/0/TermuxUbuntu/Home
```

### SFTP File Manager Bridge (rclone)

Serves the full Ubuntu filesystem to Android file managers over local SFTP:

```bash
# Start (from Ubuntu or native Termux)
start-ubuntu-filemanager-sftp

# Stop
stop-ubuntu-filemanager-sftp

# Android file manager connection:
# Protocol: SFTP
# Host:     127.0.0.1
# Port:     8022
# User:     root
# Auth:     private key at /storage/emulated/0/Download/TermuxUbuntuSFTP/material_files_ed25519
```

---

## Phase 5 — tmux (Survive Screen Locks)

```bash
pkg install -y tmux

tmux new -s main        # new session
# Ctrl+B then D         # detach (session stays alive)
tmux attach -t main     # reattach
tmux ls                 # list active sessions
```

Recommended `~/.tmux.conf` for phone use:

```
set -g mouse on
set -g history-limit 50000
set -g default-terminal "xterm-256color"
unbind C-b
set -g prefix C-a
bind C-a send-prefix
bind | split-window -h
bind - split-window -v
```

---

## Phase 6 — Copilot CLI on Android

### Always Run with --allow-all

```bash
copilot --allow-all
```

Add permanent alias in Ubuntu `/etc/profile.d/copilot-env.sh`:

```bash
echo 'alias copilot="copilot --allow-all"' > /etc/profile.d/copilot-env.sh
```

### Run Copilot Inside tmux

```bash
tmux new -s copilot
copilot --allow-all
# Ctrl+B D to detach and let it work while screen is off
# tmux attach -t copilot to check progress
```

### Restore Config on Fresh Install

```bash
cd ~
git clone https://github.com/Masterofowls/termux-ubuntu-copilot-setup
mkdir -p ~/.copilot
cp termux-ubuntu-copilot-setup/.copilot/copilot-instructions.md ~/.copilot/
cp termux-ubuntu-copilot-setup/.copilot/mcp-config.json ~/.copilot/
cp termux-ubuntu-copilot-setup/.copilot/permissions-config.json ~/.copilot/
```

---

## Full Fresh Install Script (Native Termux)

```bash
#!/data/data/com.termux/files/usr/bin/bash
set -e
echo "=== Termux Ubuntu Copilot Fresh Install ==="

termux-wake-lock

pkg update -y && pkg upgrade -y
pkg install -y proot-distro git curl wget openssh \
  python nodejs termux-api termux-tools \
  starship fzf zoxide bat eza fd ripgrep jq htop tmux

termux-setup-storage

proot-distro install ubuntu 2>/dev/null || echo "Ubuntu already installed"

mkdir -p ~/.termux/boot ~/.shortcuts

printf '#!/data/data/com.termux/files/usr/bin/sh\ntermux-wake-lock\n' > ~/.termux/boot/00-wake-lock
printf '#!/data/data/com.termux/files/usr/bin/sh\nstart-ubuntu-filemanager >/dev/null 2>&1\n' > ~/.termux/boot/start-ubuntu-filemanager
chmod +x ~/.termux/boot/*

printf '#!/data/data/com.termux/files/usr/bin/bash\nexec proot-distro login ubuntu --user root\n' > ~/.shortcuts/ubuntu
printf '#!/data/data/com.termux/files/usr/bin/bash\nexec bash -l\n' > ~/.shortcuts/native-termux
chmod +x ~/.shortcuts/*

cat > ~/.termux/termux.properties << 'TPROP'
allow-external-apps = true
terminal-transcript-rows = 10000
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
volume-keys = volume
TPROP
termux-reload-settings 2>/dev/null || true

termux-battery-status >/dev/null 2>&1 \
  && echo "Termux:API OK" \
  || echo "Install Termux:API from F-Droid then run: termux-battery-status"

echo ""
echo "=== Done. Next steps: ==="
echo "  1. proot-distro login ubuntu --user root"
echo "  2. Follow UBUNTU-TOOLS-INSTALL.md"
echo "  3. cp .copilot/copilot-instructions.md ~/.copilot/"
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Process killed mid-run | `termux-wake-lock` + disable battery optimization for Termux |
| `copilot` hangs, no output | Use `mode: "sync"`, never `mode: "background"` |
| `proot-distro` refuses inside Ubuntu | Already in proot — run from native Termux |
| Android file manager no Ubuntu files | Start SFTP bridge: `start-ubuntu-filemanager-sftp` |
| Termux:API commands not found in Ubuntu | Add Termux bin to PATH (see Phase 2.4) |
| SSH permission denied | `chmod 600 ~/.ssh/id_ed25519 && chmod 700 ~/.ssh` |
| `npm`/`node` not found in Ubuntu | `. /root/.nvm/nvm.sh` |
| Screen locks and build stops | Use tmux + wake lock; keep Termux in foreground |
| SIGKILL on long cargo/gradle build | tmux + wake lock; split builds into smaller targets |
| Termux:API not responding | Ensure Termux:API app is installed from F-Droid (not Play Store) |
| `termux-setup-storage` no effect | Revoke and re-grant storage permission in Android Settings |
