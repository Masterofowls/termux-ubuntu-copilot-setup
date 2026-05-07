#!/data/data/com.termux/files/usr/bin/bash
# Complete fresh install for Termux Ubuntu Copilot environment
# Run from NATIVE Termux (not Ubuntu proot) on a fresh Android install

set -e
echo "=== Termux Ubuntu Copilot — Fresh Install ==="

# Step 1: Wake lock (prevents SIGKILL during install)
termux-wake-lock

# Step 2: Core packages
pkg update -y && pkg upgrade -y
pkg install -y \
  proot-distro git curl wget openssh \
  python nodejs termux-api termux-tools \
  starship fzf zoxide bat eza fd ripgrep \
  jq htop btop ncdu glow tmux

# Step 3: Storage
termux-setup-storage

# Step 4: Ubuntu proot
proot-distro install ubuntu 2>/dev/null || echo "Ubuntu already installed"

# Step 5: Boot scripts
mkdir -p ~/.termux/boot
printf '#!/data/data/com.termux/files/usr/bin/sh\ntermux-wake-lock\n' \
  > ~/.termux/boot/00-wake-lock
printf '#!/data/data/com.termux/files/usr/bin/sh\nstart-ubuntu-filemanager >/dev/null 2>&1\n' \
  > ~/.termux/boot/start-ubuntu-filemanager
printf '#!/data/data/com.termux/files/usr/bin/sh\nexec acodex-ubuntu 8767\n' \
  > ~/.termux/boot/start-acodex-ubuntu
chmod +x ~/.termux/boot/*

# Step 6: Widget shortcuts
mkdir -p ~/.shortcuts
printf '#!/data/data/com.termux/files/usr/bin/bash\nexec proot-distro login ubuntu --user root\n' \
  > ~/.shortcuts/ubuntu
printf '#!/data/data/com.termux/files/usr/bin/bash\nexec bash -l\n' \
  > ~/.shortcuts/native-termux
printf '#!/data/data/com.termux/files/usr/bin/bash\nexec acodex-ubuntu 8767\n' \
  > ~/.shortcuts/start-acodex-ubuntu
cp "$(dirname "$0")/grant-all-permissions.sh" ~/.shortcuts/grant-all-permissions 2>/dev/null || true
chmod +x ~/.shortcuts/*

# Step 7: Auto-login to Ubuntu
grep -q "TERMUX_AUTO_UBUNTU_ENTERED" ~/.bashrc 2>/dev/null || cat >> ~/.bashrc << 'BASHEOF'

if [ -n "${PS1:-}" ] \
  && [ -z "${TERMUX_SKIP_AUTO_UBUNTU:-}" ] \
  && [ -z "${TERMUX_AUTO_UBUNTU_ENTERED:-}" ] \
  && command -v proot-distro >/dev/null 2>&1; then
  export TERMUX_AUTO_UBUNTU_ENTERED=1
  exec proot-distro login ubuntu --user root
fi
alias ubuntu='proot-distro login ubuntu --user root'
alias native-termux='TERMUX_SKIP_AUTO_UBUNTU=1 bash -l'
BASHEOF

# Step 8: Termux properties
cat > ~/.termux/termux.properties << 'TPROP'
allow-external-apps = true
terminal-transcript-rows = 10000
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
volume-keys = volume
bell-character = vibrate
TPROP
termux-reload-settings 2>/dev/null || true

# Step 9: Test Termux:API
termux-battery-status >/dev/null 2>&1 \
  && echo "  OK Termux:API is working" \
  || echo "  WARN: Install Termux:API from F-Droid, then run: termux-battery-status"

echo ""
echo "=== Install complete ==="
echo ""
echo "Recommended next steps:"
echo "  1. Disable battery optimization: Settings -> Apps -> Termux -> Battery -> Unrestricted"
echo "  2. Run: ./grant-all-permissions.sh"
echo "  3. Enter Ubuntu: proot-distro login ubuntu --user root"
echo "  4. Follow UBUNTU-TOOLS-INSTALL.md for full tool setup"
echo "  5. Restore Copilot config: cp .copilot/* ~/.copilot/"
