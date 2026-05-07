# Ubuntu-Only Setup (No Termux)

Run GitHub Copilot CLI on **standard Ubuntu** — a VPS, WSL, cloud VM, or bare-metal Linux machine.
No Android, no Termux, no proot.

**When to use this:** You are setting up on a regular Linux machine, cloud server, WSL2,
or any Ubuntu/Debian system that is not Termux.

---

## Key Differences from Termux Setup

| | Standard Ubuntu | Termux Ubuntu Proot |
|---|---|---|
| Package manager | `apt` | `apt` (inside proot) |
| Background agents | OK to use | NEVER (Android SIGKILL) |
| Wake lock | Not needed | Required |
| Termux:API | Not available | Via PATH from native Termux |
| systemd | Available | Not available |
| Architecture | Usually x86_64 | ARM64 |
| File paths | Standard `/root`, `/home/user` | Same (inside proot) |
| Android storage | Not applicable | `/storage/emulated/0` |

> **Important:** On standard Ubuntu, background agents are safe to use.
> Remove the "NEVER use background agents" rule from `copilot-instructions.md`
> if you are not on Android.

---

## Step 1 — System Packages

```bash
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
  git curl wget \
  build-essential cmake ninja-build pkg-config \
  libssl-dev libffi-dev \
  python3 python3-pip python3-venv \
  unzip zip xz-utils \
  ca-certificates gnupg \
  tmux htop jq
```

---

## Step 2 — GitHub CLI (gh)

```bash
# Official apt repo
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list

sudo apt update && sudo apt install -y gh

# Authenticate
gh auth login
```

---

## Step 3 — Node.js (nvm)

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc

# Install LTS Node
nvm install --lts
nvm use --lts
nvm alias default lts/*

node -v && npm -v
```

---

## Step 4 — Python (uv)

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc

# Configure defaults
cat > /etc/profile.d/uv.sh << 'EOF'
export UV_PYTHON_PREFERENCE=managed
export UV_PYTHON_DOWNLOADS=automatic
export UV_LINK_MODE=copy
export PATH="/root/.local/bin:$PATH"
EOF
source /etc/profile.d/uv.sh

# Install Python
uv python install 3.13
uv python list --only-installed
```

---

## Step 5 — Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# Add targets if needed
rustup target add x86_64-unknown-linux-gnu   # standard x86_64
# rustup target add aarch64-unknown-linux-gnu # if on ARM

rustc --version && cargo --version
```

---

## Step 6 — Copilot CLI

```bash
# Install via npm
npm install -g github-copilot-cli 2>/dev/null \
  || npm install -g @github/copilot-cli 2>/dev/null

# Or as a gh extension (recommended)
gh extension install github/gh-copilot

# Verify
copilot --version
# or: gh copilot --version
```

---

## Step 7 — Copilot Config

```bash
mkdir -p ~/.copilot

# Clone this repo
git clone https://github.com/Masterofowls/termux-ubuntu-copilot-setup
cd termux-ubuntu-copilot-setup

# Copy configs
cp .copilot/copilot-instructions.md ~/.copilot/
cp .copilot/mcp-config.json ~/.copilot/
cp .copilot/permissions-config.json ~/.copilot/
```

### Remove Android-Specific Rules

Edit `~/.copilot/copilot-instructions.md` and remove or replace the Android-only rules:

```bash
# Lines to remove or change for standard Ubuntu:
# - "NEVER use background agents" (remove — background agents work fine on Linux)
# - wake lock references
# - Termux:API references
# - Android storage path references
# - ARM64 linker / cargo config references
```

Add Ubuntu-specific context at the top:

```markdown
## Environment: Standard Ubuntu Linux
- OS: Ubuntu (non-Android)
- Background agents: Available and safe to use
- No Termux constraints
- Standard /root home directory
- x86_64 architecture (or specify ARM64 if applicable)
```

---

## Step 8 — MCP Servers

### GitHub MCP Wrapper

```bash
cat > /usr/local/bin/mcp-github-with-gh-token << 'EOF'
#!/bin/bash
exec env GITHUB_TOKEN="$(gh auth token)" github-mcp-server "$@"
EOF
chmod +x /usr/local/bin/mcp-github-with-gh-token

# Install the server
npm install -g github-mcp-server
```

### MCP Config for Standard Ubuntu

The default `mcp-config.json` from this repo works as-is, but verify paths.
The `filesystem` server `args` should point to your home/workspace dir:

```json
{
  "mcpServers": {
    "fetch": {
      "type": "local",
      "command": "uvx",
      "args": ["--from", "mcp-server-fetch", "mcp-server-fetch"],
      "tools": ["*"]
    },
    "playwright": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"],
      "tools": ["*"]
    },
    "filesystem": {
      "type": "local",
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem@latest",
        "/root"
      ],
      "tools": ["*"]
    },
    "github": {
      "type": "local",
      "command": "/usr/local/bin/mcp-github-with-gh-token",
      "args": [],
      "tools": ["*"]
    },
    "git": {
      "type": "local",
      "command": "uvx",
      "args": ["--from", "mcp-server-git", "mcp-server-git"],
      "tools": ["*"]
    },
    "markdown": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@xjtlumedia/markdown-mcp-server@latest"],
      "tools": ["*"]
    },
    "csv": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "excel-csv-mcp-server@latest"],
      "tools": ["*"]
    },
    "sqlite": {
      "type": "local",
      "command": "uvx",
      "args": [
        "--from", "mcp-server-sqlite",
        "mcp-server-sqlite",
        "--db-path", "/root/.copilot/mcp.sqlite"
      ],
      "tools": ["*"]
    }
  }
}
```

---

## Step 9 — Shell Profile

Add to `/etc/profile.d/dev-env.sh` (system-wide) or `~/.bashrc` (user):

```bash
# uv / Python
export UV_PYTHON_PREFERENCE=managed
export UV_PYTHON_DOWNLOADS=automatic
export UV_LINK_MODE=copy
export PATH="$HOME/.local/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Cargo / Rust
export PATH="$HOME/.cargo/bin:$PATH"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Android (if needed)
# export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
# export ANDROID_HOME=/usr/lib/android-sdk
```

---

## Step 10 — Optional: Android SDK (for Android app builds on non-Android host)

```bash
sudo apt install -y openjdk-17-jdk

# Install Android command-line tools
mkdir -p /usr/local/android-sdk/cmdline-tools
cd /usr/local/android-sdk/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-11076708_latest.zip
mv cmdline-tools latest

export ANDROID_HOME=/usr/local/android-sdk
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Accept licenses and install SDK components
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.1" "ndk;29.0.14206865"
```

---

## Step 11 — Copilot Skills (Plugins)

```bash
# Dev essentials
copilot plugin install bash-linux
copilot plugin install gh-cli
copilot plugin install native-data-fetching
copilot plugin install csv

# If working with web/mobile
copilot plugin install building-native-ui
copilot plugin install expo-deployment

# Data
copilot plugin install csv
copilot plugin install find-skills

# List installed
copilot plugin list
```

See [SKILLS.md](./SKILLS.md) for the full catalog.

---

## Step 12 — systemd Service (Optional — keep Copilot sessions alive)

On standard Ubuntu you can use systemd to keep a tmux session running:

```bash
cat > /etc/systemd/system/copilot-session.service << 'EOF'
[Unit]
Description=Persistent Copilot tmux session
After=network.target

[Service]
Type=forking
User=root
ExecStart=/usr/bin/tmux new-session -d -s copilot
ExecStop=/usr/bin/tmux kill-session -t copilot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now copilot-session
# Attach: tmux attach -t copilot
```

---

## Step 13 — Verification

```bash
node -v && npm -v
python3 --version
cargo --version
gh auth status
copilot --version
uvx --version
tmux -V

# Test MCP servers
uvx --from mcp-server-fetch mcp-server-fetch --help 2>/dev/null && echo "fetch MCP OK"
npx -y @modelcontextprotocol/server-filesystem@latest --help 2>/dev/null && echo "filesystem MCP OK"
```

---

## Comparison: All Setup Modes

| Feature | Native Termux | Ubuntu in proot | Standard Ubuntu |
|---------|--------------|-----------------|-----------------|
| Package manager | `pkg` | `apt` | `apt` |
| Background agents | NEVER | NEVER | Safe to use |
| Wake lock | Required | Required (from native) | Not needed |
| Termux:API | Native | Via PATH | Not available |
| systemd | No | No | Yes |
| Persistent services | tmux + boot script | tmux + boot script | systemd |
| Android files | `~/storage/` | `/storage/emulated/0` | N/A |
| Copilot config path | `~/.copilot/` | `~/.copilot/` | `~/.copilot/` |
| MCP config path | `~/.copilot/mcp-config.json` | `~/.copilot/mcp-config.json` | `~/.copilot/mcp-config.json` |
| Instructions file | `~/.copilot/copilot-instructions.md` | `~/.copilot/copilot-instructions.md` | `~/.copilot/copilot-instructions.md` |
