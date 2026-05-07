# GitHub Copilot CLI Config — Termux Ubuntu (Android)

Full configuration backup and setup guide for GitHub Copilot CLI running inside **Ubuntu proot on Termux (Android/ARM64)**.

## Docs

| File | Description |
|------|-------------|
| [SKILLS.md](SKILLS.md) | All Copilot CLI plugins/skills — install commands + full catalog |
| [UBUNTU-TOOLS-INSTALL.md](UBUNTU-TOOLS-INSTALL.md) | Step-by-step tool installation guide for fresh Ubuntu setup |

## Config Files

| Path | Description |
|------|-------------|
| `.copilot/copilot-instructions.md` | Global Copilot instructions (tools, paths, Android/Termux rules) |
| `.copilot/mcp-config.json` | MCP server config (fetch, playwright, filesystem, github, git, markdown, csv, sqlite) |
| `.copilot/permissions-config.json` | Tool approval permissions for `/root` workspace |
| `package.json` | Node.js deps (playwright) |
| `scripts/hacktools.sh` | Mobile HackLab tool launcher |
| `scripts/start-hacklab.sh` | Start X11/XFCE desktop + audio |
| `scripts/stop-hacklab.sh` | Stop desktop |

## Quick Restore

```bash
git clone https://github.com/Masterofowls/copilot-config.git
cd copilot-config
mkdir -p ~/.copilot
cp .copilot/copilot-instructions.md ~/.copilot/
cp .copilot/mcp-config.json ~/.copilot/
cp .copilot/permissions-config.json ~/.copilot/
npm install
chmod +x scripts/*.sh && cp scripts/*.sh ~/
gh auth login && copilot auth login
```

See [UBUNTU-TOOLS-INSTALL.md](UBUNTU-TOOLS-INSTALL.md) for a fresh Ubuntu setup and [SKILLS.md](SKILLS.md) to install all skills.

## Environment

| Component | Version / Path |
|-----------|---------------|
| OS | Ubuntu proot in Termux (Android ARM64) |
| Node.js | nvm → v24.15.0 (`/root/.nvm`) |
| Python | uv → CPython 3.13.13 (`/root/.local/bin`) |
| Rust | rustup → 1.95.0 (`/root/.cargo/bin`) |
| Java | OpenJDK 17 ARM64 (`/usr/lib/jvm/java-17-openjdk-arm64`) |
| Android SDK | API 34/35, NDK 29 (`/usr/lib/android-sdk`) |
| Copilot CLI | 1.0.41 (`/usr/local/bin/copilot`) |
| gh | GitHub CLI (`/usr/bin/gh`) |

## MCP Servers

| Server | Runtime |
|--------|---------|
| `fetch` | `uvx mcp-server-fetch` |
| `playwright` | `npx @playwright/mcp` |
| `filesystem` | `npx @modelcontextprotocol/server-filesystem /root` |
| `github` | `/usr/local/bin/mcp-github-with-gh-token` |
| `git` | `uvx mcp-server-git` |
| `markdown` | `npx @xjtlumedia/markdown-mcp-server` |
| `csv` | `npx excel-csv-mcp-server` |
| `sqlite` | `uvx mcp-server-sqlite --db-path ~/.copilot/mcp.sqlite` |

> **Note:** `settings.json` / `config.json` (contain auth tokens) are excluded. Re-auth with `copilot auth login` after restore.
