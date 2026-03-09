#!/usr/bin/env bash
# ClawManager Installer — macOS & Linux
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ClawManager/releases/main/install.sh | bash
#   VERSION=v0.1.26 bash install.sh   # pin a specific version
set -euo pipefail

REPO="ClawManager/releases"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
RELEASES_URL="https://github.com/${REPO}/releases/download"

# ── Colours ──────────────────────────────────────────────────────────────────
if [ -t 1 ]; then
  BOLD="\033[1m"; GREEN="\033[0;32m"; YELLOW="\033[0;33m"
  RED="\033[0;31m"; RESET="\033[0m"
else
  BOLD=""; GREEN=""; YELLOW=""; RED=""; RESET=""
fi

info()    { echo -e "${GREEN}[✓]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
die()     { echo -e "${RED}[✗]${RESET} $*" >&2; exit 1; }
heading() { echo -e "\n${BOLD}$*${RESET}"; }

# ── Resolve version ──────────────────────────────────────────────────────────
resolve_version() {
  if [ -n "${VERSION:-}" ]; then
    echo "$VERSION"
    return
  fi
  if command -v curl &>/dev/null; then
    curl -fsSL "$API_URL" 2>/dev/null \
      | grep '"tag_name"' \
      | head -1 \
      | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/'
  elif command -v wget &>/dev/null; then
    wget -qO- "$API_URL" 2>/dev/null \
      | grep '"tag_name"' \
      | head -1 \
      | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/'
  else
    die "Neither curl nor wget found. Please install one and retry."
  fi
}

# ── Download helper ──────────────────────────────────────────────────────────
download() {
  local url="$1" dest="$2"
  info "Downloading $(basename "$dest") …"
  if command -v curl &>/dev/null; then
    curl -fsSL --progress-bar -o "$dest" "$url"
  else
    wget -q --show-progress -O "$dest" "$url"
  fi
}

# ── macOS installer ──────────────────────────────────────────────────────────
install_macos() {
  local version="$1"
  local version_num="$2"
  local arch
  arch="$(uname -m)"

  case "$arch" in
    arm64)           ASSET="ClawManager-arm64.dmg" ;;
    x86_64 | i386)  ASSET="ClawManager-x64.dmg" ;;
    *)               die "Unsupported macOS architecture: $arch" ;;
  esac

  local url="${RELEASES_URL}/${version}/${ASSET}"
  local tmpdir
  tmpdir="$(mktemp -d)"
  local dmg_path="${tmpdir}/${ASSET}"

  download "$url" "$dmg_path"

  info "Mounting ${ASSET} …"
  local mount_output
  mount_output="$(hdiutil attach -nobrowse -noautoopen "$dmg_path" 2>&1)"
  local mount_point
  mount_point="$(echo "$mount_output" | grep '/Volumes/' | tail -1 | awk '{for(i=NF;i>=1;i--){if($i ~ /^\/Volumes\//){print substr($0, index($0,$i)); break}}}')"

  if [ -z "$mount_point" ]; then
    die "Could not determine mount point from hdiutil output:\n${mount_output}"
  fi
  info "Mounted at: ${mount_point}"

  # Find the .app inside the DMG
  local app_bundle
  app_bundle="$(find "$mount_point" -maxdepth 2 -name "*.app" | head -1)"
  if [ -z "$app_bundle" ]; then
    hdiutil detach "$mount_point" &>/dev/null || true
    die "No .app bundle found in DMG."
  fi
  local app_name
  app_name="$(basename "$app_bundle")"

  info "Installing ${app_name} to /Applications …"
  if [ -d "/Applications/${app_name}" ]; then
    warn "Replacing existing /Applications/${app_name}"
    rm -rf "/Applications/${app_name}"
  fi
  cp -R "$app_bundle" /Applications/

  info "Detaching disk image …"
  hdiutil detach "$mount_point" &>/dev/null || warn "Could not detach — you may need to eject manually."

  info "Clearing quarantine flag (best effort) …"
  xattr -dr com.apple.quarantine "/Applications/${app_name}" &>/dev/null \
    || warn "Could not clear quarantine — Gatekeeper may prompt on first launch."

  rm -rf "$tmpdir"

  heading "✅  ClawManager ${version} installed!"
  echo "   Launch from /Applications/${app_name}"
}

# ── Linux installer ──────────────────────────────────────────────────────────
install_linux() {
  local version="$1"
  local version_num="$2"
  local arch
  arch="$(uname -m)"

  local tmpdir
  tmpdir="$(mktemp -d)"

  case "$arch" in
    aarch64 | arm64)
      # .deb package for ARM64
      local asset="ClawManager-arm64.deb"
      local url="${RELEASES_URL}/${version}/${asset}"
      local dest="${tmpdir}/${asset}"
      download "$url" "$dest"

      info "Installing .deb package (requires sudo) …"
      if command -v sudo &>/dev/null; then
        sudo dpkg -i "$dest" || {
          warn "dpkg reported errors — attempting: sudo apt-get install -f"
          sudo apt-get install -f -y || die "Dependency fix failed. Run 'sudo apt-get install -f' manually."
        }
      else
        dpkg -i "$dest" || {
          warn "dpkg reported errors — attempting: apt-get install -f"
          apt-get install -f -y || die "Dependency fix failed. Run 'apt-get install -f' manually."
        }
      fi
      rm -f "$dest"
      heading "✅  ClawManager ${version} installed!"
      echo "   Run: clawmanager  (or find it in your application launcher)"
      ;;

    x86_64 | amd64)
      # .deb package for x64
      local asset="ClawManager-amd64.deb"
      local url="${RELEASES_URL}/${version}/${asset}"
      local dest="${tmpdir}/${asset}"
      download "$url" "$dest"

      info "Installing .deb package (requires sudo) …"
      if command -v sudo &>/dev/null; then
        sudo dpkg -i "$dest" || {
          warn "dpkg reported errors — attempting: sudo apt-get install -f"
          sudo apt-get install -f -y || die "Dependency fix failed. Run 'sudo apt-get install -f' manually."
        }
      else
        dpkg -i "$dest" || {
          warn "dpkg reported errors — attempting: apt-get install -f"
          apt-get install -f -y || die "Dependency fix failed. Run 'apt-get install -f' manually."
        }
      fi
      rm -f "$dest"
      heading "✅  ClawManager ${version} installed!"
      echo "   Run: clawmanager  (or find it in your application launcher)"
      ;;

    *)
      die "Unsupported Linux architecture: ${arch}. Supported: aarch64, x86_64."
      ;;
  esac

  rm -rf "$tmpdir"
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
  heading "ClawManager Installer"

  local os
  os="$(uname -s)"

  local version
  info "Fetching latest release version …"
  version="$(resolve_version)"
  [ -n "$version" ] || die "Could not determine release version. Set VERSION=vX.Y.Z to override."
  info "Version: ${version}"
  # Strip leading 'v' for use in filenames (e.g. v0.2.0 → 0.2.0)
  local version_num="${version#v}"

  case "$os" in
    Darwin)  install_macos "$version" "$version_num" ;;
    Linux)   install_linux "$version" "$version_num" ;;
    *)       die "Unsupported OS: ${os}. This script supports macOS and Linux." ;;
  esac
}

main "$@"
