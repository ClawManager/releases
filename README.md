# ClawManager Releases

Windows, macOS and Linux builds for [ClawManager](https://clawmanager.ai).

Downloads are available in the [Releases](https://github.com/ClawManager/releases/releases) tab.

---

## One-Line Install

### macOS & Linux

```bash
curl -fsSL https://raw.githubusercontent.com/ClawManager/releases/main/install.sh | bash
```

To install a specific version:

```bash
VERSION=v0.1.26 bash <(curl -fsSL https://raw.githubusercontent.com/ClawManager/releases/main/install.sh)
```

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/ClawManager/releases/main/install.ps1 | iex
```

To install a specific version:

```powershell
$env:VERSION="v0.1.26"; iwr -useb https://raw.githubusercontent.com/ClawManager/releases/main/install.ps1 | iex
```

---

## What the installer does

### macOS
- Detects your architecture (Apple Silicon or Intel)
- Downloads the matching `.dmg` from the latest GitHub Release
- Mounts the image, copies **ClawManager.app** to `/Applications`, then ejects
- Clears the macOS quarantine flag (best effort — avoids "unidentified developer" prompts)

### Linux
| Architecture | Package | Install method |
|---|---|---|
| ARM64 (`aarch64`) | `.deb` | `sudo dpkg -i` (auto-fixes deps with `apt-get -f`) |
| x86\_64 | `.AppImage` | Saved to `~/.local/bin/ClawManager.AppImage` |

### Windows
- Downloads the `ClawManager-Setup.exe` installer
- Launches the Setup wizard — follow the on-screen steps

---

## Manual Downloads

See the [Releases page](https://github.com/ClawManager/releases/releases) to download a specific build directly.

| Platform | File | Notes |
|---|---|---|
| macOS (Apple Silicon) | `ClawManager-arm64.dmg` | M1 / M2 / M3 |
| macOS (Intel) | `ClawManager.dmg` | x86\_64; also runs on Apple Silicon via Rosetta |
| Linux ARM64 | `ClawManager-arm64.deb` | Debian / Ubuntu / derivatives |
| Linux x86\_64 | `ClawManager.AppImage` | Universal; runs on most modern distros |
| Windows | `ClawManager-Setup.exe` | x64 installer |

---

## Requirements

- **macOS**: 12 Monterey or later
- **Linux**: glibc 2.28+ (Debian 10 / Ubuntu 20.04 equivalent or newer)
- **Windows**: Windows 10 (1903) or later, x64

---

## Troubleshooting

**macOS — "app is damaged and can't be opened"**
Run the quarantine-clear command manually:
```bash
xattr -dr com.apple.quarantine /Applications/ClawManager.app
```

**Linux AppImage — permission denied**
```bash
chmod +x ~/.local/bin/ClawManager.AppImage
```

**Linux AppImage — not in PATH**
Add to your shell profile:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

**Windows — SmartScreen warning**
Click *More info* → *Run anyway*. The binary is unsigned; closed-source distribution is intentional.
