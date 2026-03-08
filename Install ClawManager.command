#!/usr/bin/env bash
# Install ClawManager.command
# Double-click this file in Finder to install ClawManager on macOS.
# ---------------------------------------------------------------
# NOTE: This script is unsigned. macOS Gatekeeper may warn that the
# file is from an unidentified developer. If you see that prompt,
# right-click (or Control-click) the file in Finder and choose
# "Open", then confirm when asked.
# ---------------------------------------------------------------

set -euo pipefail

# ── Terminal colour helpers ─────────────────────────────────────
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

print_banner() {
  echo ""
  echo "${CYAN}${BOLD}╔═══════════════════════════════════════╗${RESET}"
  echo "${CYAN}${BOLD}║      ClawManager macOS Installer      ║${RESET}"
  echo "${CYAN}${BOLD}╚═══════════════════════════════════════╝${RESET}"
  echo ""
}

print_step()    { echo "${CYAN}▶ $*${RESET}"; }
print_ok()      { echo "${GREEN}✔ $*${RESET}"; }
print_warn()    { echo "${YELLOW}⚠ $*${RESET}"; }
print_error()   { echo "${RED}✘ $*${RESET}"; }

# ── macOS check ────────────────────────────────────────────────
if [[ "$(uname -s)" != "Darwin" ]]; then
  print_error "This installer is for macOS only."
  echo ""
  echo "For Linux or Windows, visit:"
  echo "  https://github.com/ClawManager/releases"
  echo ""
  read -r -p "Press Enter to close..."
  exit 1
fi

print_banner

# ── Dependency: curl ───────────────────────────────────────────
if ! command -v curl &>/dev/null; then
  print_error "curl is required but was not found."
  echo "Install Xcode Command Line Tools with:  xcode-select --install"
  echo ""
  read -r -p "Press Enter to close..."
  exit 1
fi

# ── Run the canonical installer ────────────────────────────────
INSTALL_URL="https://raw.githubusercontent.com/ClawManager/releases/main/install.sh"

print_step "Downloading and running the ClawManager installer…"
echo ""

if curl -fsSL "$INSTALL_URL" | bash; then
  echo ""
  print_ok "ClawManager installed successfully!"
  echo ""
  echo "${BOLD}Next steps:${RESET}"
  echo "  • Open ClawManager from your Applications folder"
  echo "  • If macOS warns about an unidentified developer, right-click"
  echo "    the app icon → Open → confirm when prompted."
  echo "  • Or clear the quarantine flag manually:"
  echo "      xattr -dr com.apple.quarantine /Applications/ClawManager.app"
  echo ""
else
  EXIT_CODE=$?
  echo ""
  print_error "Installation failed (exit code ${EXIT_CODE})."
  echo ""
  print_warn "Troubleshooting tips:"
  echo "  • Check your internet connection and try again."
  echo "  • For manual downloads, visit:"
  echo "      https://github.com/ClawManager/releases/releases"
  echo "  • To report a bug, open an issue at:"
  echo "      https://github.com/ClawManager/releases/issues"
  echo ""
fi

read -r -p "Press Enter to close..."
