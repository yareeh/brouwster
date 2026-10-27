#!/bin/zsh
# Builds build/Brouwster.app (settings) with the embedded background router that handles links.
# With --install, copies it to ~/Applications and registers it with Launch Services.
set -euo pipefail
cd "${0:A:h}/.."

lsregister=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
app=build/Brouwster.app
router="$app/Contents/Helpers/Brouwster Router.app"

swift build -c release
bin="$(swift build -c release --show-bin-path)"
[[ -d "$app" ]] && $lsregister -u "$app" 2>/dev/null || true
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$router/Contents/MacOS"
cp "$bin/Brouwster" "$app/Contents/MacOS/"
cp Resources/Brouwster-Info.plist "$app/Contents/Info.plist"
cp "$bin/BrouwsterRouter" "$router/Contents/MacOS/"
cp Resources/Router-Info.plist "$router/Contents/Info.plist"
codesign --force --sign - "$router"
codesign --force --sign - "$app"
echo "Built $app"

if [[ "${1:-}" == "--install" ]]; then
  dest=~/Applications/Brouwster.app
  mkdir -p ~/Applications
  for id in yareeh.brouwster yareeh.brouwster.router; do
    osascript -e "quit app id \"$id\"" 2>/dev/null || true
  done
  rm -rf "$dest"
  cp -R "$app" "$dest"
  # Keep the build copy from claiming links, and drop stale scheme claims before re-registering.
  $lsregister -u "$app" 2>/dev/null || true
  $lsregister -u "$dest" 2>/dev/null || true
  $lsregister -f -R "$dest"
  echo "Installed $dest"
fi
