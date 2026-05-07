# Ubuntu Tools Installation Guide (Termux proot / ARM64)

Complete setup for all tools used by GitHub Copilot CLI on Termux Ubuntu (Android ARM64).

---

## 1. System Prerequisites

```bash
apt update && apt upgrade -y
apt install -y \
  build-essential git git-lfs curl wget unzip zip \
  python3 python3-pip python3-dev python3-venv \
  libssl-dev libffi-dev zlib1g-dev \
  libreadline-dev libbz2-dev libsqlite3-dev \
  libncurses-dev liblzma-dev libxml2-dev \
  clang cmake ninja-build \
  openjdk-17-jdk \
  ripgrep bat htop tmux tree jq \
  lazygit glab rclone
```

---

## 2. Node.js via nvm

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh"
nvm install --lts && nvm alias default lts/*

# Persist for all shells
cat > /etc/profile.d/nvm.sh << 'EOF'
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
EOF

node --version && npm --version
```

---

## 3. Python via uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh

cat > /etc/profile.d/uv.sh << 'EOF'
export UV_PYTHON_PREFERENCE=managed
export UV_PYTHON_DOWNLOADS=automatic
export UV_LINK_MODE=copy
export PATH="/root/.local/bin:$PATH"
EOF
source /etc/profile.d/uv.sh

uv python install 3.13
python --version && uv --version
```

---

## 4. Rust via rustup

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
echo 'source "$HOME/.cargo/env"' > /etc/profile.d/rust.sh

# Android cross-compile targets
rustup target add aarch64-linux-android armv7-linux-androideabi \
  i686-linux-android x86_64-linux-android

rustc --version && cargo --version

# Android linker config (Termux clang)
cat >> ~/.cargo/config.toml << 'EOF'

[target.aarch64-linux-android]
linker = "/data/data/com.termux/files/usr/bin/aarch64-linux-android-clang"
EOF
```

---

## 5. GitHub CLI (gh)

```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt update && apt install -y gh
gh auth login && gh auth status
```

---

## 6. GitHub Copilot CLI

```bash
# Download ARM64 binary
curl -L "https://github.com/github/copilot-cli/releases/latest/download/copilot-linux-arm64" \
  -o /usr/local/bin/copilot
chmod +x /usr/local/bin/copilot
copilot auth login
copilot version
```

---

## 7. MCP Servers

```bash
# GitHub MCP server binary
GHMS_VERSION=$(gh release list -R github/github-mcp-server --limit 1 --json tagName -q '.[0].tagName')
curl -L "https://github.com/github/github-mcp-server/releases/download/${GHMS_VERSION}/github-mcp-server_linux_arm64.tar.gz" \
  | tar -xz -C /usr/local/bin github-mcp-server
chmod +x /usr/local/bin/github-mcp-server

# GitHub MCP wrapper (reads token from gh auth)
cat > /usr/local/bin/mcp-github-with-gh-token << 'EOF'
#!/bin/bash
export GITHUB_TOKEN="$(gh auth token)"
exec /usr/local/bin/github-mcp-server stdio "$@"
EOF
chmod +x /usr/local/bin/mcp-github-with-gh-token

# Pre-warm uv MCP tools (optional — uvx downloads on first use anyway)
uvx --from mcp-server-fetch mcp-server-fetch --version 2>/dev/null || true
uvx --from mcp-server-git mcp-server-git --version 2>/dev/null || true
uvx --from mcp-server-sqlite mcp-server-sqlite --version 2>/dev/null || true

# Playwright browsers
npx playwright install chromium

# Install MCP config
mkdir -p ~/.copilot
cp .copilot/mcp-config.json ~/.copilot/
```

---

## 8. Tauri CLI

```bash
npm install -g @tauri-apps/cli        # → /usr/local/bin/tauri
cargo install tauri-cli --locked      # → ~/.cargo/bin/cargo-tauri
tauri --version
```

---

## 9. Android SDK & NDK

```bash
apt install -y android-sdk
cat > /etc/profile.d/android.sh << 'EOF'
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export ANDROID_HOME=/usr/lib/android-sdk
export ANDROID_SDK_ROOT=/usr/lib/android-sdk
export ANDROID_NDK_HOME=/usr/lib/android-sdk/ndk/29.0.14206865
export NDK_HOME=$ANDROID_NDK_HOME
export GRADLE_USER_HOME=/root/.gradle
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/debian:$PATH"
EOF
source /etc/profile.d/android.sh

sdkmanager --install "platforms;android-35" "build-tools;35.0.1" \
  "platform-tools" "ndk;29.0.14206865"
```

---

## 10. Shell Environment (all tools on PATH)

```bash
cat > /etc/profile.d/copilot-env.sh << 'EOF'
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export ANDROID_HOME=/usr/lib/android-sdk
export ANDROID_SDK_ROOT=/usr/lib/android-sdk
export ANDROID_NDK_HOME=/usr/lib/android-sdk/ndk/29.0.14206865
export NDK_HOME=$ANDROID_NDK_HOME
export GRADLE_USER_HOME=/root/.gradle
export UV_PYTHON_PREFERENCE=managed
export UV_PYTHON_DOWNLOADS=automatic
export UV_LINK_MODE=copy
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
export PATH="\
/root/.local/bin:\
/usr/local/bin:\
/root/.cargo/bin:\
$JAVA_HOME/bin:\
$ANDROID_HOME/cmdline-tools/latest/bin:\
$ANDROID_HOME/platform-tools:\
$ANDROID_HOME/build-tools/debian:\
/usr/bin:/bin:\
$PATH"
EOF
source /etc/profile.d/copilot-env.sh
```

---

## 11. Full Restore from This Repo

```bash
git clone https://github.com/Masterofowls/copilot-config.git
cd copilot-config
mkdir -p ~/.copilot
cp .copilot/copilot-instructions.md ~/.copilot/
cp .copilot/mcp-config.json ~/.copilot/
cp .copilot/permissions-config.json ~/.copilot/
npm install
chmod +x scripts/*.sh && cp scripts/*.sh ~/
gh auth login
copilot auth login
# Install skills — see SKILLS.md
```

---

## 12. Verify Everything

```bash
node --version          # v24.x
python --version        # 3.13.x
cargo --version         # 1.95.x
gh auth status          # Logged in
copilot version         # 1.0.x
java -version           # openjdk 17
adb version             # 34.x
tauri --version         # 2.x
copilot plugin list     # installed plugins
```
