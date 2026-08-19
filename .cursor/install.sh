#!/usr/bin/env bash
#
# Cloud Agent install script for purchases-hybrid-common.
#
# Idempotent bootstrap of the Linux-buildable development experience:
#   - mise-managed toolchain (Java 17, Ruby 3.3.0, Node 24.x) from mise.toml/mise.lock
#   - Android SDK (command-line tools, platform 34, build-tools 34.0.0)
#   - Ruby gems (fastlane, cocoapods, danger, lefthook, ...) via bundler
#   - Node dependencies for the typescript and purchases-js-hybrid-mappings packages
#
# iOS work (PurchasesHybridCommon / PurchasesHybridCommonUI) requires macOS + Xcode
# and cannot be built on this Linux VM; it is intentionally not set up here.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

ANDROID_HOME="${ANDROID_HOME:-$HOME/android-sdk}"
ANDROID_CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

log() { printf '\n=== %s ===\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. mise (tool version manager)
# ---------------------------------------------------------------------------
log "Installing mise (if needed)"
export PATH="$HOME/.local/bin:$PATH"
if ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.run | sh
fi

log "Installing pinned toolchain via mise"
mise trust --quiet "$REPO_ROOT/mise.toml"
mise install

# `mise install` may re-normalize the committed lockfile (e.g. reorder platform
# entries) without changing the resolved tool versions. Restore the committed
# copy so a fresh checkout keeps a clean working tree; the tools stay installed.
if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$REPO_ROOT" checkout -- mise.lock 2>/dev/null || true
fi

# Make the mise-managed tools available to the rest of this script.
eval "$(mise env -s bash)"

# ---------------------------------------------------------------------------
# 2. Android SDK
# ---------------------------------------------------------------------------
export ANDROID_HOME
export ANDROID_SDK_ROOT="$ANDROID_HOME"
SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"

if [ ! -x "$SDKMANAGER" ]; then
  log "Installing Android command-line tools"
  tmpzip="$(mktemp)"
  curl -fsSL -o "$tmpzip" "$ANDROID_CMDLINE_TOOLS_URL"
  mkdir -p "$ANDROID_HOME/cmdline-tools"
  rm -rf "$ANDROID_HOME/cmdline-tools/latest"
  unzip -q -o "$tmpzip" -d "$ANDROID_HOME/cmdline-tools"
  mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
  rm -f "$tmpzip"
fi

log "Accepting Android SDK licenses and installing packages"
yes | "$SDKMANAGER" --licenses >/dev/null 2>&1 || true
"$SDKMANAGER" "platform-tools" "platforms;android-34" "build-tools;34.0.0" >/dev/null

# ---------------------------------------------------------------------------
# 3. Ruby gems (fastlane and friends)
# ---------------------------------------------------------------------------
log "Installing Ruby gems (bundle install)"
gem install bundler --conservative --no-document
bundle install

# ---------------------------------------------------------------------------
# 4. Node dependencies
# ---------------------------------------------------------------------------
log "Installing Node dependencies (typescript)"
corepack enable >/dev/null 2>&1 || true
( cd typescript && yarn install --frozen-lockfile )

log "Installing Node dependencies (purchases-js-hybrid-mappings)"
( cd purchases-js-hybrid-mappings && yarn install --frozen-lockfile )

# ---------------------------------------------------------------------------
# 5. Persist environment for future interactive/agent shells
# ---------------------------------------------------------------------------
log "Persisting environment to ~/.bashrc"
MARKER="# >>> purchases-hybrid-common cloud-agent env >>>"
if ! grep -qF "$MARKER" "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" <<EOF

$MARKER
export PATH="\$HOME/.local/bin:\$PATH"
eval "\$(mise activate bash)"
export ANDROID_HOME="$ANDROID_HOME"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/cmdline-tools/latest/bin:\$PATH"
# <<< purchases-hybrid-common cloud-agent env <<<
EOF
fi

log "Install complete"
