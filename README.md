# GitHub Copilot CLI Config — Termux Ubuntu (Android)

Full configuration backup for GitHub Copilot CLI running inside **Ubuntu proot on Termux (Android/ARM64)**.

## Contents

| Path | Description |
|------|-------------|
| `.copilot/copilot-instructions.md` | Global Copilot CLI instructions — tools, paths, env, Android/Termux rules |
| `.copilot/mcp-config.json` | MCP server configuration (fetch, playwright, filesystem, github, git, markdown, csv, sqlite) |
| `.copilot/permissions-config.json` | Tool approval permissions for the `/root` workspace |
| `package.json` | Node.js dependencies (playwright) |
| `scripts/hacktools.sh` | Mobile HackLab interactive tool launcher |
| `scripts/start-hacklab.sh` | Start HackLab desktop (X11 + XFCE + audio) |
| `scripts/stop-hacklab.sh` | Stop HackLab desktop |

## Environment

- **Device:** Android phone (ARM64)
- **Shell:** Ubuntu proot via Termux (`proot-distro`)
- **Node:** nvm → v24.15.0
- **Python:** uv-managed CPython 3.13.13
- **Rust:** 1.95.0 via rustup
- **Java:** OpenJDK 17 ARM64
- **Android SDK:** `/usr/lib/android-sdk` (API 34/35, NDK 29)

## MCP Servers

| Server | Transport |
|--------|-----------|
| `fetch` | `uvx mcp-server-fetch` |
| `playwright` | `npx @playwright/mcp` |
| `filesystem` | `npx @modelcontextprotocol/server-filesystem` |
| `github` | `mcp-github-with-gh-token` (wraps `gh auth token`) |
| `git` | `uvx mcp-server-git` |
| `markdown` | `npx @xjtlumedia/markdown-mcp-server` |
| `csv` | `npx excel-csv-mcp-server` |
| `sqlite` | `uvx mcp-server-sqlite` |

## Key Tool Paths

```
/root/.local/bin/uv          uv 0.11.8 (Python manager)
/root/.nvm/...               nvm Node.js v24.15.0
/root/.cargo/bin/cargo       Rust 1.95.0
/usr/local/bin/copilot       GitHub Copilot CLI 1.0.41
/usr/bin/gh                  GitHub CLI
/usr/lib/android-sdk         Android SDK root
/usr/lib/jvm/java-17-openjdk-arm64  Java 17
```

## Restore Instructions

1. Copy `.copilot/` to `~/.copilot/`
2. Copy `.copilot/mcp-config.json` to `~/.copilot/mcp-config.json`
3. Install dependencies: `npm install` (for Playwright)
4. Authenticate: `gh auth login`
5. Scripts: `chmod +x scripts/*.sh && cp scripts/*.sh ~/`

> **Note:** `settings.json` and `config.json` (contain auth tokens) are intentionally excluded. Re-authenticate with `copilot auth login` after restore.
