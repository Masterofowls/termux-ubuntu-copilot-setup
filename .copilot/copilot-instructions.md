# Global Copilot CLI Rules

These instructions apply globally across all projects, sessions, and models that load user-level Copilot instructions.

- Use configured MCP servers whenever they are helpful for the task. Prefer the existing MCPs for fetch/web access, Playwright/browser work, filesystem access, GitHub, git, Markdown, CSV, SQLite, `uvx`, and `npx` workflows.
- Remember the operating environment: Ubuntu running inside Termux on an Android phone. Account for mobile/Termux constraints, Android storage paths, package availability, and ARM/Linux compatibility.
- Copy or export files from `/root` to the shared Android storage folder when needed so the user can access them from Android. Prefer common shared paths such as `/storage/emulated/0`, `/sdcard`, or Termux shared storage if available, and verify the target path before writing.
- Check project documentation, package docs, command help, READMEs, API docs, and existing code conventions as needed before making changes or choosing tools.
- After installing a tool, make it available on `PATH` for future sessions. Prefer durable locations such as `/usr/local/bin`, `~/.local/bin`, or shell profile updates when appropriate.
- Use global memory or global configuration for reusable preferences and environment knowledge. Keep project-specific facts in the project when appropriate.
- Split large or risky tasks into smaller stages, validate each stage, and continue iterating until the requested outcome is complete.
- Minimize unnecessary permission prompts. When the user has approved permissive operation, prefer `/allow-all` or launching Copilot with `--allow-all`; still respect security, privacy, and safety boundaries.
- Apply these preferences consistently unless a repository-specific instruction, explicit user request, or safety requirement takes precedence.

## Working Defaults

- **NEVER use background agents.** Do not use the `task` tool with `mode: "background"` under any circumstances. This environment runs on Android (Termux proot Ubuntu) where background sub-agent processes are killed by the OS (SIGKILL/signal 9) due to memory limits. Always do work directly in the main conversation using inline tool calls.
- Start by understanding the current directory, repository state, existing scripts, and available package manager before making changes.
- Prefer existing project tools and conventions over introducing new frameworks, dependencies, or file layouts.
- Make precise, complete changes that solve the root request. Avoid unrelated refactors, broad rewrites, or cosmetic churn.
- Preserve user work. Do not overwrite, reset, delete, or revert files unless the user explicitly asks or approves.
- Use parallel tool calls for independent reads, searches, checks, and validations whenever possible.
- Prefer `rg`, `glob`, `view`, and project-native commands for exploration. Use MCPs when they provide better context or capabilities.
- For long-running work, provide short progress updates and keep going until the task is complete or genuinely blocked.
- Ask questions only when required for scope, behavior, secrets, credentials, destructive operations, or mutually exclusive implementation choices.

## Validation and Quality

- After code changes, run the smallest relevant existing tests, lint, type-check, build, or smoke test that proves the change works.
- If a validation command fails, inspect the failure and fix issues caused by the current task. Report unrelated pre-existing failures clearly.
- For web or UI tasks, use Playwright MCP or browser-based checks when useful.
- For data tasks, use CSV and SQLite MCPs/tools to inspect structure, sample rows, schemas, and transformations.
- For GitHub tasks, prefer GitHub MCP or `gh` for issues, PRs, Actions, releases, and repository metadata.
- For Git tasks, inspect status before editing or committing. Use clear commit messages if asked to commit.

## Termux and Android Environment

- Assume limited mobile resources: avoid unnecessary heavy downloads, large builds, background daemons, and duplicate package installs.
- Prefer ARM64-compatible packages and binaries. Verify architecture when downloading releases.
- Use durable user paths such as `/root/.local/bin` and `/usr/local/bin` for tools; update shell profiles only when needed.
- When the user needs an artifact on Android, copy it to shared storage and provide the final Android-accessible path.
- Do not assume shared storage is mounted. Check `/sdcard`, `/storage/emulated/0`, and Termux storage setup first.

## Documentation and Memory

- Check official docs, README files, command help, or package metadata before configuring unfamiliar tools.
- Record reusable environment preferences in global instructions or durable config, not in project files.
- Keep project-specific notes in repository-supported instruction files only when they benefit that project.
- Do not create planning or note files in repositories unless the user explicitly requests them.

## Known Installed Tools and Paths

Use these known tools directly when appropriate instead of rediscovering their paths every session. If a command fails, then re-check the path with `command -v`.

| Tool | Path | Notes |
| --- | --- | --- |
| `copilot` | `/usr/local/bin/copilot` | GitHub Copilot CLI 1.0.39 |
| `gh` | `/usr/bin/gh` | GitHub CLI, authenticated for the user |
| `git` | `/usr/bin/git` | Git 2.51.0 |
| `curl` | `/usr/bin/curl` | HTTP downloads/API calls |
| `wget` | `/usr/bin/wget` | Alternate downloader |
| `rclone` | `/usr/bin/rclone` | Provides the local SFTP bridge for Android file managers |
| `node` | `/root/.nvm/versions/node/v24.15.0/bin/node` | nvm default Node.js v24.15.0 in login shells |
| system `node` | `/usr/bin/node` | System Node.js v20.19.4 |
| `npm` | `/root/.nvm/versions/node/v24.15.0/bin/npm` | nvm default npm 11.12.1 in login shells |
| system `npm` | `/usr/bin/npm` | System npm 9.2.0 |
| `npx` | `/root/.nvm/versions/node/v24.15.0/bin/npx` | nvm default npx in login shells |
| system `npx` | `/usr/bin/npx` | System npx 9.2.0 |
| `nvm` | `/root/.nvm/nvm.sh` | nvm 0.40.4 shell function loaded by `/etc/profile.d/nvm.sh`; default alias is `lts/*` -> v24.15.0 |
| `pyenv` | `/usr/bin/pyenv` | pyenv 2.5.4 with root `/usr/share/pyenv`; loaded by `/etc/profile.d/pyenv.sh` |
| `tauri` | `/usr/local/bin/tauri` | npm `@tauri-apps/cli` 2.11.0 |
| `cargo-tauri` | `/root/.cargo/bin/cargo-tauri` | Cargo Tauri CLI 2.10.1 |
| `cargo` | `/root/.cargo/bin/cargo` | Rust Cargo 1.95.0 |
| `rustc` | `/root/.cargo/bin/rustc` | Rust 1.95.0 |
| `rustup` | `/root/.cargo/bin/rustup` | Rustup 1.29.0 |
| `python` | `/root/.local/bin/python` | uv-managed CPython 3.13.13 |
| `python3` | `/root/.local/bin/python3` | uv-managed CPython 3.13.13 |
| `python3.13` | `/root/.local/bin/python3.13` | uv-managed CPython 3.13.13 |
| system `python` | `/usr/bin/python` | System Python launcher |
| system `python3` | `/usr/bin/python3` | System Python 3.13.7 |
| `pip` | `/root/.local/bin/pip` | Wrapper: `uv pip` for package operations, managed pip for help/version |
| `pip3` | `/root/.local/bin/pip3` | Wrapper: `uv pip` for package operations, managed pip for help/version |
| system `pip` | `/usr/bin/pip` | System-managed Python pip; avoid unless explicitly needed |
| system `pip3` | `/usr/bin/pip3` | System-managed Python pip 25.1.1; avoid unless explicitly needed |
| `uv` | `/root/.local/bin/uv` | uv 0.11.8, ARM64; symlinked from `/usr/local/bin/uv` too |
| `uvx` | `/root/.local/bin/uvx` | uvx 0.11.8, ARM64; symlinked from `/usr/local/bin/uvx` too |
| `venv` | `/root/.local/bin/venv` | Wrapper for `uv venv` |
| `mkvenv` | `/root/.local/bin/mkvenv` | Wrapper for `uv venv` |
| `github-mcp-server` | `/usr/local/bin/github-mcp-server` | Official GitHub MCP server 1.0.3 |
| `mcp-github-with-gh-token` | `/usr/local/bin/mcp-github-with-gh-token` | Wrapper that gets token from `GH_TOKEN` or `gh auth token` |
| `code` | `/data/data/com.termux/files/usr/bin/code` | Code - OSS; when run as root may require `--no-sandbox --user-data-dir <dir>` |
| `rg` | `/data/data/com.termux/files/usr/bin/rg` | ripgrep 15.1.0 |
| `sqlite3` | `/usr/lib/android-sdk/platform-tools/sqlite3` | SQLite CLI 3.46.1 |
| `bash` | `/usr/bin/bash` | Default shell |
| `sh` | `/usr/bin/sh` | POSIX shell |
| `apt` | `/usr/bin/apt` | Ubuntu package manager |
| `apt-get` | `/usr/bin/apt-get` | Ubuntu package manager |
| `termux-setup-storage` | `/data/data/com.termux/files/usr/bin/termux-setup-storage` | Android shared storage setup |
| `termux-open` | `/data/data/com.termux/files/usr/bin/termux-open` | Open files/URLs with Android |
| `termux-share` | `/data/data/com.termux/files/usr/bin/termux-share` | Share files through Android |
| `axs` | `/data/data/com.termux/files/usr/bin/axs` | AcodeX server 0.2.14 installed in native Termux |
| `acodeX-server` | `/data/data/com.termux/files/usr/bin/acodeX-server` | Symlink to `axs` |
| `acodex-ubuntu` | `/data/data/com.termux/files/usr/bin/acodex-ubuntu` | Starts AcodeX server with Termux proot Ubuntu |
| `proot-login` | `/data/data/com.termux/files/usr/bin/proot-login` | Wrapper for `proot-distro login` in native Termux |
| `ubuntu` | `/data/data/com.termux/files/usr/bin/ubuntu` | Native Termux launcher for `proot-distro login ubuntu --user froggy` |
| `termux-ubuntu` | `/data/data/com.termux/files/usr/bin/termux-ubuntu` | Native Termux launcher for Ubuntu proot |
| `native-termux` | `/data/data/com.termux/files/usr/bin/native-termux` | Opens native Termux shell without auto-entering Ubuntu |
| `termux-ubuntu-command` | `/data/data/com.termux/files/usr/bin/termux-ubuntu-command` | Run a command inside Termux Ubuntu |
| `start-ubuntu-filemanager` | `/data/data/com.termux/files/usr/bin/start-ubuntu-filemanager` | Native Termux launcher that starts Ubuntu localhost SFTP for Android file managers |
| `start-ubuntu-filemanager-sftp` | `/usr/local/bin/start-ubuntu-filemanager-sftp` | Ubuntu-side localhost SFTP server launcher on `127.0.0.1:8022` |
| `stop-ubuntu-filemanager-sftp` | `/usr/local/bin/stop-ubuntu-filemanager-sftp` | Stops the Ubuntu localhost SFTP server |

`jq` was not installed when these instructions were written; do not assume it exists unless `command -v jq` succeeds.

## Version Managers

- `uv` is the default Python version manager, package manager, and virtualenv manager. Prefer `uv python`, `uv venv`, `uv add`, `uv sync`, `uv run`, `uv pip`, and `uvx` for Python work.
- uv-managed CPython `3.13.13` is installed at `/root/.local/share/uv/python/cpython-3.13.13-linux-aarch64-gnu/bin/python3.13`.
- `/root/.local/bin/python`, `/root/.local/bin/python3`, and `/root/.local/bin/python3.13` point to the uv-managed Python 3.13.13 and are first on `PATH` in configured shells.
- `/root/.local/bin/pip` and `/root/.local/bin/pip3` are wrappers around `uv pip`; use `uv pip install ...` or `uv add ...` rather than system pip.
- `/root/.local/bin/venv` and `/root/.local/bin/mkvenv` are wrappers for `uv venv`.
- uv defaults are configured in `/etc/profile.d/uv.sh`: `UV_PYTHON_PREFERENCE=managed`, `UV_PYTHON_DOWNLOADS=automatic`, `UV_LINK_MODE=copy`, and `/root/.local/bin` first on `PATH`.
- Use `uv python install <version>` for Python versions and `uv python list --only-installed` to inspect installed interpreters. Avoid installing Python versions with `pyenv` unless uv cannot support the requested version.
- `pyenv` is installed at `/usr/bin/pyenv`, with `PYENV_ROOT=/usr/share/pyenv`. It is initialized globally by `/etc/profile.d/pyenv.sh`.
- Common Python build dependencies for `pyenv install` are installed (`build-essential`, SSL, zlib, bz2, readline, sqlite, ncurses, xz, tk, XML, ffi, lzma, LLVM-related packages).
- `pyenv` remains available as a fallback at `/usr/bin/pyenv`, but uv is preferred by default.
- `nvm` is installed at `/root/.nvm`, initialized globally by `/etc/profile.d/nvm.sh`, and loaded for root's non-login interactive Bash shells via `/root/.bashrc`.
- nvm default alias is `lts/*`, currently resolving to Node.js `v24.15.0` with npm `11.12.1`.
- The previous system Node remains available at `/usr/bin/node` (`v20.19.4`) with system npm/npx `9.2.0`.
- If a shell does not have `nvm`, source it with `. /root/.nvm/nvm.sh` before using `nvm`, `node`, `npm`, or `npx` from nvm.

## Acode and AcodeX

- Acode APK is downloaded at `/storage/emulated/0/Download/Acode-v1.11.8.apk`; Android install may require user confirmation in the package installer UI.
- AcodeX server `axs` 0.2.14 is installed in native Termux at `/data/data/com.termux/files/usr/bin/axs`; `acodeX-server` is a symlink to it.
- AcodeX should use the user's native Termux proot Ubuntu, not Acode's built-in terminal distro. Start it from native Termux, not from inside Ubuntu/proot:

```sh
start-acodex-ubuntu
# equivalent:
acodex-ubuntu 8767
```

- `acodex-ubuntu` runs `axs --port 8767 --command "proot-distro login ubuntu --user froggy"`.
- The native Termux `.bashrc` contains `alias ubuntu='proot-distro login ubuntu --user froggy'`, `alias start-acodex-ubuntu='acodex-ubuntu 8767'`, and `alias proot-login='proot-distro login'`.
- A Termux:Widget-compatible shortcut exists at `/data/data/com.termux/files/home/.shortcuts/start-acodex-ubuntu`.
- User-facing setup guide exists at `/storage/emulated/0/Download/Acode-AcodeX-Ubuntu-setup.txt`.
- In Acode, install plugin `bajrangcoder.acodex`, open AcodeX terminal, and connect to port `8767`.
- Do not run `proot-distro` commands from inside another proot; it intentionally refuses. Start AcodeX from native Termux so new terminal sessions enter Ubuntu correctly.

## Termux Ubuntu Auto-Start and Android Editors

- Native Termux is configured to auto-enter the existing Ubuntu proot for interactive shells using `/data/data/com.termux/files/home/.bashrc`.
- Default Ubuntu command: `proot-distro login ubuntu --user froggy`.
- To bypass auto-login and stay in native Termux, use either:

```sh
TERMUX_SKIP_AUTO_UBUNTU=1 bash -l
native-termux
```

- Native Termux helper scripts:
  - `/data/data/com.termux/files/usr/bin/ubuntu`
  - `/data/data/com.termux/files/usr/bin/termux-ubuntu`
  - `/data/data/com.termux/files/usr/bin/termux-ubuntu-command`
  - `/data/data/com.termux/files/usr/bin/native-termux`
- Termux:Widget shortcuts, if the app/plugin is installed:
  - `/data/data/com.termux/files/home/.shortcuts/ubuntu`
  - `/data/data/com.termux/files/home/.shortcuts/native-termux`
  - `/data/data/com.termux/files/home/.shortcuts/start-acodex-ubuntu`
- Termux:Tasker scripts, if installed:
  - `/data/data/com.termux/files/home/.termux/tasker/ubuntu`
  - `/data/data/com.termux/files/home/.termux/tasker/start-acodex-ubuntu`
- Termux:Boot script, if installed:
  - `/data/data/com.termux/files/home/.termux/boot/start-acodex-ubuntu`
- SmartIDE package `org.smartide.code` is installed. Its private settings are not accessible from this shell, so use a shared workspace instead of trying to point it directly at Termux private storage.
- Shared Android editor workspace:
  - Android path: `/storage/emulated/0/SmartIDE/UbuntuProjects`
  - Ubuntu path: `/home/froggy/SmartIDE` (`~/SmartIDE`)
  - Guide file: `/storage/emulated/0/SmartIDE/UbuntuProjects/README-Termux-Ubuntu.txt`
- For SmartIDE and similar editors, open `/storage/emulated/0/SmartIDE/UbuntuProjects` as the project folder, edit there, and run/build from Termux Ubuntu at `~/SmartIDE`.
- Android file-manager access for the Termux Ubuntu proot is configured:
  - Direct shared folder visible in Android file managers: `/storage/emulated/0/TermuxUbuntu/Home`.
  - Ubuntu links to that folder: `/home/froggy/AndroidFiles` and `/root/AndroidFiles`.
  - Full Ubuntu filesystem is available to file managers through local-only rclone SFTP on `127.0.0.1:8022`, username `root`, key `/storage/emulated/0/Download/TermuxUbuntuSFTP/material_files_ed25519`, initial path `/`.
  - Start the server from native Termux with `start-ubuntu-filemanager` or from Ubuntu root with `start-ubuntu-filemanager-sftp`; stop it with `stop-ubuntu-filemanager-sftp`; pid file is `/run/rclone-termux-filemanager-sftp.pid`.
  - Native Termux auto-start attempts to start this SFTP bridge before entering Ubuntu, and a Termux:Boot script exists at `/data/data/com.termux/files/home/.termux/boot/start-ubuntu-filemanager`.
  - Guide file: `/storage/emulated/0/TermuxUbuntu/README-Material-Files.txt`.
  - Android apps still cannot directly browse `/data/data/com.termux/...` without root/Shizuku/SAF support; use the shared folder or SFTP bridge instead.

## Android, Gradle, Java, and Native Build Paths

Use these known Android development paths directly when working on Android, Gradle, Kotlin, Java, native, APK, or AAB projects. Prefer a project's `./gradlew` wrapper when present; use system `gradle` only when there is no wrapper or when explicitly requested.

| Component | Path / Value | Notes |
| --- | --- | --- |
| `JAVA_HOME` | `/usr/lib/jvm/java-17-openjdk-arm64` | OpenJDK 17.0.18 ARM64 |
| Java binaries | `/usr/lib/jvm/java-17-openjdk-arm64/bin` | Contains `java`, `javac`, and related tools |
| `java` | `/usr/lib/jvm/java-17-openjdk-arm64/bin/java` | Runtime |
| `javac` | `/usr/lib/jvm/java-17-openjdk-arm64/bin/javac` | Compiler |
| System `gradle` | `/usr/bin/gradle` | Gradle 4.4.1; often too old for modern Android projects |
| Gradle user home | `/root/.gradle` | Caches, wrappers, daemons, downloaded Gradle distributions |
| Tauri npm CLI | `/usr/local/bin/tauri` | `@tauri-apps/cli` 2.11.0; supports `tauri android ...` |
| Tauri Cargo CLI | `/root/.cargo/bin/cargo-tauri` | `cargo tauri` 2.10.1; supports `cargo tauri android ...` |
| Cargo config | `/root/.cargo/config.toml` | Persists Android linker/env settings |
| Android SDK root | `/usr/lib/android-sdk` | Use as `ANDROID_HOME` and `ANDROID_SDK_ROOT` |
| SDK command-line tools | `/usr/lib/android-sdk/cmdline-tools/latest/bin` | Contains `sdkmanager`, `avdmanager` |
| `sdkmanager` | `/usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager` | Android package manager |
| `avdmanager` | `/usr/lib/android-sdk/cmdline-tools/latest/bin/avdmanager` | AVD management |
| SDK platform tools | `/usr/lib/android-sdk/platform-tools` | Contains `adb` |
| `adb` | `/usr/lib/android-sdk/platform-tools/adb` | Android Debug Bridge 34.0.5-debian |
| SDK build-tools root | `/usr/lib/android-sdk/build-tools` | Installed versions include `34.0.0`, `35.0.1`, and `debian` |
| Debian build-tools | `/usr/lib/android-sdk/build-tools/debian` | On `PATH`; contains `aapt`, `aapt2`, `apksigner`, `zipalign` |
| `aapt` | `/usr/lib/android-sdk/build-tools/debian/aapt` | Android asset packaging |
| `aapt2` | `/usr/lib/android-sdk/build-tools/debian/aapt2` | Android asset packaging v2 |
| `apksigner` | `/usr/lib/android-sdk/build-tools/debian/apksigner` | APK signing |
| `zipalign` | `/usr/lib/android-sdk/build-tools/debian/zipalign` | APK alignment |
| Android platforms | `/usr/lib/android-sdk/platforms` | Installed: `android-34`, `android-35` |
| Android NDK root | `/usr/lib/android-sdk/ndk/29.0.14206865` | Use as `ANDROID_NDK_HOME` and `NDK_HOME` |
| NDK bundle alias | `/usr/lib/android-sdk/ndk-bundle` | Exists; sdkmanager warns it is an inconsistent alias for NDK 29 |
| `ndk-build` | `/usr/lib/android-sdk/ndk/29.0.14206865/ndk-build` | NDK build command |
| Android CMake root | `/usr/lib/android-sdk/cmake/3.31.6` | Android SDK CMake package |
| Android CMake bin | `/usr/lib/android-sdk/cmake/3.31.6/bin` | Prefer for Android CMake if project expects SDK CMake |
| System `cmake` | `/usr/bin/cmake` | CMake 3.31.6 |
| `ninja` | `/usr/bin/ninja` | Ninja 1.12.1 |
| `clang` | `/usr/bin/clang` | System Clang |
| `clang++` | `/usr/bin/clang++` | System Clang++ |
| Termux Android clang | `/data/data/com.termux/files/usr/bin/aarch64-linux-android-clang` | Working linker for Rust `aarch64-linux-android` target on this phone |

Known Android-related `PATH` entries already present in this environment:

```text
/usr/lib/jvm/java-17-openjdk-arm64/bin
/usr/lib/android-sdk/cmdline-tools/latest/bin
/usr/lib/android-sdk/tools
/usr/lib/android-sdk/tools/bin
/usr/lib/android-sdk/platform-tools
/usr/lib/android-sdk/build-tools/debian
/root/.cargo/bin
```

When Android tools require environment variables, use:

```sh
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export ANDROID_HOME=/usr/lib/android-sdk
export ANDROID_SDK_ROOT=/usr/lib/android-sdk
export ANDROID_NDK_HOME=/usr/lib/android-sdk/ndk/29.0.14206865
export NDK_HOME=/usr/lib/android-sdk/ndk/29.0.14206865
export GRADLE_USER_HOME=/root/.gradle
```

Rust Android targets installed:

```text
aarch64-linux-android
armv7-linux-androideabi
i686-linux-android
x86_64-linux-android
```

On this Ubuntu-on-Termux ARM64 phone, the reliable Tauri/Rust Android build target is `aarch64`. The installed Android NDK is present at `/usr/lib/android-sdk/ndk/29.0.14206865`, but its bundled host toolchain is under `linux-x86_64`; direct `ndk-build` can report `Unknown host CPU architecture: aarch64`. Use the persisted Cargo linker in `/root/.cargo/config.toml`, which points `aarch64-linux-android` to `/data/data/com.termux/files/usr/bin/aarch64-linux-android-clang`. For Tauri Android APK builds on this phone, prefer:

```sh
tauri android build --target aarch64 --apk
# or
cargo tauri android build --target aarch64 --apk
```

If Android builds fail, check for wrapper compatibility first (`./gradlew --version`), then Java version, then SDK/NDK/platform/build-tools availability. Be aware that `sdkmanager` currently warns about Debian package layout aliases for build-tools and NDK; do not treat those warnings as fatal unless the command exits non-zero.

## Android App Project Defaults

For Gradle/Android, Expo, React Native, and Tauri Android projects, default to producing a complete installable Android APK artifact, not just a partial compile or web build.

- Always build a full APK when the task involves app creation, packaging, release preparation, or Android project changes. Prefer project-native commands such as `./gradlew assembleRelease`, `./gradlew assembleDebug`, `npx expo run:android --variant release`, `npx react-native build-android`, or `cargo tauri android build` as appropriate for the project.
- Always ensure the produced APK is signed. Prefer an existing release signing config or existing keystore when present. If no release signing setup exists, do not commit secrets; create or use an uncommitted local keystore only when appropriate, or produce a signed debug APK and clearly label it as debug-signed.
- Never store keystore passwords, signing passwords, private keys, or credentials in source code, committed Gradle files, logs, or global instructions. Use environment variables, local `*.properties` files ignored by git, or existing secure project conventions.
- Always add or preserve a project license. If a repository already has a license, keep it consistent. If no license is present and the user has not specified one, ask before choosing a legal license; do not invent legal terms silently.
- Always include a high-quality app icon for Android apps. Prefer adaptive icons with foreground/background layers, include required density assets or vector drawables, and wire them through the Android manifest/config for Gradle, Expo, React Native, or Tauri as appropriate.
- For Expo and React Native apps, ensure Android app metadata and icons are configured in the correct source of truth (`app.json`, `app.config.*`, `android/app/src/main`, or framework-specific config) before building.
- For Tauri Android apps, ensure Android icon, identifier/package, signing, and build config are wired through the Tauri/Android project structure before building.
- After building, verify the APK exists and is non-empty. When useful, inspect it with `aapt`, `aapt2`, `apksigner verify`, or `zipalign -c`.
- Always copy the final APK build artifact to Android shared storage so the user can install or share it from the phone. Prefer `/sdcard/Download` or `/storage/emulated/0/Download` when available; create a clear filename including app name, variant, and version when possible.
- After copying, report the exact APK path in shared storage and whether it is release-signed, debug-signed, or signed with an existing project configuration.

## Git and GitHub Authentication

Use these safe credential references for Git and GitHub work. Never paste, print, store, or commit actual tokens, private keys, or secret credential values in instructions, logs, code, or repository files.

| Item | Value / Path | Notes |
| --- | --- | --- |
| GitHub account | `Masterofowls` on `github.com` | Active account in GitHub CLI |
| GitHub auth file | `/root/.config/gh/hosts.yml` | Contains the GitHub CLI token; do not read or print token values |
| GitHub CLI config | `/root/.config/gh/config.yml` | General `gh` configuration |
| GitHub token retrieval | `gh auth token` | Use only at runtime for commands that require a token; do not save output |
| GitHub token scopes | `admin:public_key`, `gist`, `read:org`, `repo` | Reported by `gh auth status` |
| Git operation protocol | Prefer SSH for GitHub repository operations | `gh auth status` reports Git operations protocol as SSH |
| `gh` config protocol | `gh config get git_protocol` returned `https` when recorded | If protocol behavior matters, check current `gh auth status` |
| SSH public key | `/root/.ssh/id_ed25519.pub` | Public key only; private key material must not be read or exposed |
| Global git user config | Not recorded when checked | Before committing, check `git config user.name` and `git config user.email`; do not invent identity |

Credential usage defaults:

- Prefer `gh` or GitHub MCP for GitHub API operations because authentication is already configured.
- Prefer SSH remotes for GitHub Git operations when cloning, fetching, pushing, or adding remotes.
- If an HTTPS token is required for a subprocess, pass `GITHUB_TOKEN="$(gh auth token)"` or `GH_TOKEN="$(gh auth token)"` only in that process environment and avoid echoing it.
- Do not open `/root/.config/gh/hosts.yml` unless strictly necessary; it contains secret token material.
- Do not inspect private SSH keys. It is acceptable to reference public key files, fingerprints, and `ssh -T git@github.com` style connectivity checks when needed.
- Check `git --no-pager status` before commits, and inspect `git remote -v` before any push.
- If asked to commit, use the repository's existing git identity or ask the user if `user.name`/`user.email` are missing.

## Configured MCP Servers

The user-level MCP config is `/root/.copilot/mcp-config.json`. These servers have already been configured and smoke-tested:

| MCP server | Command |
| --- | --- |
| `fetch` | `uvx --from mcp-server-fetch mcp-server-fetch` |
| `playwright` | `npx -y @playwright/mcp@latest` |
| `filesystem` | `npx -y @modelcontextprotocol/server-filesystem@latest /root` |
| `github` | `/usr/local/bin/mcp-github-with-gh-token` |
| `git` | `uvx --from mcp-server-git mcp-server-git` |
| `markdown` | `npx -y @xjtlumedia/markdown-mcp-server@latest` |
| `csv` | `npx -y excel-csv-mcp-server@latest` |
| `sqlite` | `uvx --from mcp-server-sqlite mcp-server-sqlite --db-path /root/.copilot/mcp.sqlite` |

## Communication Style

- Lead with the outcome, then the most important details.
- Be concise, direct, and practical. Avoid unnecessary recap, filler, or offers to continue.
- Mention exact files changed, commands configured, and any required restart or reload step.
- If something is uncertain or incomplete, say so plainly and include the blocker or next required action.
