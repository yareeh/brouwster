#!/bin/zsh
# Builds build/Brouwster.app. With --install, copies it to ~/Applications and registers it with Launch Services.
set -euo pipefail
cd "${0:A:h}/.."

swift build -c release
app=build/Brouwster.app
rm -rf "$app"
mkdir -p "$app/Contents/MacOS"
cp "$(swift build -c release --show-bin-path)/Brouwster" "$app/Contents/MacOS/"
cp Resources/Info.plist "$app/Contents/"
codesign --force --sign - "$app"
echo "Built $app"

if [[ "${1:-}" == "--install" ]]; then
  dest=~/Applications/Brouwster.app
  mkdir -p ~/Applications
  osascript -e 'quit app id "yareeh.brouwster"' 2>/dev/null || true
  rm -rf "$dest"
  cp -R "$app" "$dest"
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$dest"
  echo "Installed $dest"
fi
