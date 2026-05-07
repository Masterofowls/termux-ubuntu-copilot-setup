# Native Termux Setup (No Ubuntu Proot)

Run GitHub Copilot CLI **directly in Termux** on Android — no proot, no Ubuntu.
All tools install into the Termux prefix (`$PREFIX` = `/data/data/com.termux/files/usr`).

**When to use this:** You want a lightweight setup without maintaining a full Ubuntu proot,
or you want Copilot directly in the native Termux shell.

---

## Key Differences from Ubuntu Proot

| | Native Termux | Ubuntu Proot |
|---|---|---|
| Package manager | `pkg` | `apt` |
| Home dir | `/data/data/com.termux/files/home` | `/root` |
| Prefix | `/data/data/com.termux/files/usr` | `/usr` |
| Termux:API | Native, direct access | Via PATH export |
| systemd | Not available | Not available (proot) |
| glibc | Musl/Bionic | glibc |
| Background agents | NEVER (Android SIGKILL) | NEVER (Android SIGKILL) |
| Wake lock required | Yes | Yes (handled in native Termux) |

---

## Step 1 — Base Packages

```bash
pkg update -y && pkg upgrade -y

pkg install -y \
  git curl wget \
  openssh \
  nodejs-lts \
  python \
  termux-api \
  termux-tools \
  binutils \
  cmake ninja \
  clang \
  pkg-config \
  openssl \
  fzf zoxide bat eza fd ripgrep \
  jq htop tmux starship
```

---

## Step 2 — Node.js and npm

`nodejs-lts` from pkg is the recommended way in native Termux.
nvm also works but requires extra setup:

```bash
# Option A: pkg (simpler)
pkg install -y nodejs-lts
node -v && npm -v

# Option B: nvm (more version control)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts
```

---

## Step 3 — Python (uv)

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc

# uv manages Python versions automatically
uv python install 3.13
uv python list --only-installed

# Verify
python --version  # or: uv run python --version
```

---

## Step 4 — Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

rustc --version
cargo --version
```

Note: In native Termux, Rust compiles for the host Android target directly.
No cross-compilation needed for Termux packages.

---

## Step 5 — GitHub CLI (gh)

```bash
pkg install -y gh

# Authenticate
gh auth login
# Choose: GitHub.com -> HTTPS -> paste token
```

---

## Step 6 — GitHub Copilot CLI

```bash
npm install -g @github/copilot-cli 2>/dev/null \
  || npm install -g github-copilot-cli 2>/dev/null \
  || npm install -g copilot 2>/dev/null

# Or install as a gh extension (recommended):
gh extension install github/gh-copilot
```

For the full Copilot CLI agent (this repo uses):
```bash
# Check the current install method used in this environment:
which copilot
copilot --version
```

---

## Step 7 — Copilot Config Files

```bash
mkdir -p ~/.copilot

# Clone this repo and copy configs
git clone https://github.com/Masterofowls/termux-ubuntu-copilot-setup
cd termux-ubuntu-copilot-setup

cp .copilot/copilot-instructions.md ~/.copilot/
cp .copilot/permissions-config.json ~/.copilot/

# MCP config — needs Termux path adjustments (see Step 8)
```

---

## Step 8 — MCP Servers (Termux-Adjusted Config)

MCP servers run via `uvx` and `npx` — both work in native Termux.
The `filesystem` server path and `github` wrapper need adjustment:

```bash
# Create the GitHub MCP wrapper for native Termux
cat > "$PREFIX/bin/mcp-github-with-gh-token" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec env GITHUB_TOKEN="$(gh auth token)" github-mcp-server "$@"
EOF
chmod +x "$PREFIX/bin/mcp-github-with-gh-token"

# Install github-mcp-server
npm install -g github-mcp-server 2>/dev/null || true
```

Save this as `~/.copilot/mcp-config.json` (adjust paths for Termux):

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
        "/data/data/com.termux/files/home"
      ],
      "tools": ["*"]
    },
    "github": {
      "type": "local",
      "command": "/data/data/com.termux/files/usr/bin/mcp-github-with-gh-token",
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
        "--db-path", "/data/data/com.termux/files/home/.copilot/mcp.sqlite"
      ],
      "tools": ["*"]
    }
  }
}
```

---

## Step 9 — Shell Profile

Add to `~/.bashrc`:

```bash
# uv / Python
export UV_PYTHON_PREFERENCE=managed
export UV_PYTHON_DOWNLOADS=automatic
export PATH="$HOME/.local/bin:$PATH"

# Cargo / Rust
export PATH="$HOME/.cargo/bin:$PATH"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# nvm (if using nvm instead of pkg nodejs)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Starship prompt
command -v starship >/dev/null && eval "$(starship init bash)"

# zoxide
command -v zoxide >/dev/null && eval "$(zoxide init bash)"

# fzf
[ -f "$PREFIX/share/fzf/key-bindings.bash" ] && source "$PREFIX/share/fzf/key-bindings.bash"
[ -f "$PREFIX/share/fzf/completion.bash" ] && source "$PREFIX/share/fzf/completion.bash"
```

---

## Step 10 — Wake Lock (CRITICAL)

```bash
# Always acquire before long work
termux-wake-lock

# Boot script — runs on every Termux start (requires Termux:Boot app)
mkdir -p ~/.termux/boot
printf '#!/data/data/com.termux/files/usr/bin/sh\ntermux-wake-lock\n' \
  > ~/.termux/boot/00-wake-lock
chmod +x ~/.termux/boot/00-wake-lock
```

Also disable battery optimization:
```
Settings -> Apps -> Termux -> Battery -> Unrestricted
```

---

## Step 11 — Copilot Skills (Plugins)

```bash
# Install plugins directly in native Termux
copilot plugin install bash-linux
copilot plugin install gh-cli
copilot plugin install native-data-fetching
copilot plugin install csv

# List installed
copilot plugin list
```

See [SKILLS.md](./SKILLS.md) for the full catalog.

---

## Step 12 — Verification

```bash
node -v && npm -v
python --version
cargo --version
gh auth status
copilot --version
uvx --version
tmux -V
termux-battery-status
```

---

## Termux-Native Copilot Instructions Override

When running Copilot in **native Termux** (not Ubuntu proot), add this note to
`~/.copilot/copilot-instructions.md`:

```markdown
## Environment: Native Termux (Android)
- Home directory: /data/data/com.termux/files/home
- Prefix: /data/data/com.termux/files/usr
- Package manager: pkg (not apt)
- No proot/Ubuntu — all commands run in native Termux
- Termux:API available natively (no PATH export needed)
- NEVER use background agents (Android SIGKILL applies here too)
- Always run: termux-wake-lock before long tasks
```

---

## Termux-Specific Paths Reference

| Variable | Value |
|----------|-------|
| `$HOME` | `/data/data/com.termux/files/home` |
| `$PREFIX` | `/data/data/com.termux/files/usr` |
| Termux bin | `/data/data/com.termux/files/usr/bin` |
| npm globals | `/data/data/com.termux/files/usr/lib/node_modules` |
| pip packages | `~/.local/lib/python3.x/site-packages` |
| Cargo bins | `~/.cargo/bin` |
| uv bins | `~/.local/bin` |
| Copilot config | `~/.copilot/` |
