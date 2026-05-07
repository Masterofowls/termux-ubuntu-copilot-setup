# termux-ubuntu-copilot-setup

> **GitHub Copilot CLI — complete configuration for Ubuntu proot on Termux (Android ARM64)**

Full setup for running GitHub Copilot CLI on an Android phone via Termux + proot Ubuntu, including:
- Global Copilot instructions (no background agents, Android-aware defaults)
- All 8 MCP server configurations (fetch, playwright, filesystem, github, git, markdown, csv, sqlite)
- Termux-specific setup (wake locks, Termux:API, permissions, boot scripts, properties)
- Complete tool install guide (Node, Python/uv, Rust, Android SDK, Tauri, gh CLI)
- Plugin/skills catalog with install commands

---

## Quick Restore (Fresh Device)

```bash
# 1. Native Termux — run fresh-install script
pkg install -y git curl
git clone https://github.com/Masterofowls/termux-ubuntu-copilot-setup
cd termux-ubuntu-copilot-setup
bash scripts/fresh-install.sh

# 2. Grant all Android permissions
bash scripts/grant-all-permissions.sh

# 3. Enter Ubuntu proot
proot-distro login ubuntu --user root

# 4. Install all Ubuntu tools
# Follow UBUNTU-TOOLS-INSTALL.md

# 5. Restore Copilot config
mkdir -p ~/.copilot
cp .copilot/copilot-instructions.md ~/.copilot/
cp .copilot/mcp-config.json ~/.copilot/
cp .copilot/permissions-config.json ~/.copilot/

# 6. Authenticate GitHub CLI
gh auth login

# 7. Start Copilot
copilot --allow-all
```

---

## Choose Your Setup

| Scenario | Guide |
|----------|-------|
| Android phone, native Termux only (no Ubuntu proot) | [NATIVE-TERMUX-SETUP.md](./NATIVE-TERMUX-SETUP.md) |
| Android phone, Termux + Ubuntu proot (this environment) | [TERMUX-SETUP.md](./TERMUX-SETUP.md) + [UBUNTU-TOOLS-INSTALL.md](./UBUNTU-TOOLS-INSTALL.md) |
| Standard Ubuntu / VPS / WSL / cloud (no Termux) | [UBUNTU-ONLY-SETUP.md](./UBUNTU-ONLY-SETUP.md) |

---

## Repository Contents

| File / Directory | Purpose |
|------------------|---------|
| `.copilot/copilot-instructions.md` | Global Copilot CLI rules (333 lines) |
| `.copilot/mcp-config.json` | All 8 MCP server definitions |
| `.copilot/permissions-config.json` | Copilot permissions config |
| `NATIVE-TERMUX-SETUP.md` | **Native Termux only** (no Ubuntu proot) |
| `TERMUX-SETUP.md` | Termux + Ubuntu proot: wake locks, Termux:API, boot scripts |
| `UBUNTU-ONLY-SETUP.md` | **Standard Ubuntu / VPS / WSL** (no Termux) |
| `UBUNTU-TOOLS-INSTALL.md` | All tools: Node, Python, Rust, Android SDK, etc. |
| `SKILLS.md` | Full plugin/skills catalog with install commands |
| `scripts/fresh-install.sh` | One-shot Termux native setup script |
| `scripts/grant-all-permissions.sh` | Grant all Android permissions to Termux |
| `scripts/hacktools.sh` | Mobile HackLab tool launcher |
| `scripts/start-hacklab.sh` | Start X11/XFCE desktop session |
| `scripts/stop-hacklab.sh` | Stop desktop session |
| `package.json` | Node.js dependencies (playwright) |

---

## MCP Servers

| Server | Command |
|--------|---------|
| `fetch` | `uvx --from mcp-server-fetch mcp-server-fetch` |
| `playwright` | `npx -y @playwright/mcp@latest` |
| `filesystem` | `npx -y @modelcontextprotocol/server-filesystem@latest /root` |
| `github` | `/usr/local/bin/mcp-github-with-gh-token` |
| `git` | `uvx --from mcp-server-git mcp-server-git` |
| `markdown` | `npx -y @xjtlumedia/markdown-mcp-server@latest` |
| `csv` | `npx -y excel-csv-mcp-server@latest` |
| `sqlite` | `uvx --from mcp-server-sqlite mcp-server-sqlite --db-path /root/.copilot/mcp.sqlite` |

Config file: `~/.copilot/mcp-config.json`

---

## Key Environment Paths

| Component | Path |
|-----------|------|
| Copilot instructions | `~/.copilot/copilot-instructions.md` |
| MCP config | `~/.copilot/mcp-config.json` |
| Node.js (nvm) | `~/.nvm/versions/node/v24.15.0/bin/node` |
| Python (uv) | `~/.local/bin/python` (CPython 3.13.13) |
| Rust/Cargo | `~/.cargo/bin/` |
| Android SDK | `/usr/lib/android-sdk` |
| Android NDK | `/usr/lib/android-sdk/ndk/29.0.14206865` |
| Java 17 | `/usr/lib/jvm/java-17-openjdk-arm64` |
| GitHub CLI | `/usr/bin/gh` |
| Ubuntu SFTP bridge | `127.0.0.1:8022` (rclone, key in Android storage) |

---

## Android Constraints

> **CRITICAL:** Always run `termux-wake-lock` before long tasks.
> Android will SIGKILL (signal 9) background processes when screen turns off or memory is low.
> Copilot is configured to **never use background agents** for this reason.

See [TERMUX-SETUP.md](./TERMUX-SETUP.md) for full details on:
- Wake locks and battery optimization
- Termux:API setup and permissions
- Boot scripts and widget shortcuts
- tmux for session persistence
- Android SFTP file access

---

## Excluded Files (Secrets)

`~/.copilot/settings.json` and `~/.copilot/config.json` contain a live OAuth token and are **never committed**. Restore them by running `copilot` once and authenticating.

---

## Links

- [NATIVE-TERMUX-SETUP.md](./NATIVE-TERMUX-SETUP.md) — Native Termux (no proot)
- [TERMUX-SETUP.md](./TERMUX-SETUP.md) — Termux + Ubuntu proot (Android)
- [UBUNTU-ONLY-SETUP.md](./UBUNTU-ONLY-SETUP.md) — Standard Ubuntu / VPS / WSL
- [UBUNTU-TOOLS-INSTALL.md](./UBUNTU-TOOLS-INSTALL.md) — Full tool install guide
- [SKILLS.md](./SKILLS.md) — Plugin/skills catalog
- [GitHub Copilot CLI docs](https://docs.github.com/en/copilot/using-github-copilot/using-github-copilot-in-the-command-line)
