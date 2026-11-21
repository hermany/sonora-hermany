#!/bin/sh
# Arma /Applications/"Sonora Hermany.app" con el binario release, el icono propio y firma ad-hoc.
# Uso: cargo build --release -p sonora && hermany/make-app.sh
set -e
here=$(cd "$(dirname "$0")/.." && pwd)
APP="/Applications/Sonora Hermany.app"
ORIG=${ORIG:-/Applications/Sonora.app/Contents}
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$here/target/release/sonora" "$APP/Contents/MacOS/sonora-hermany-bin"
cat > "$APP/Contents/MacOS/sonora-hermany" <<'LAUNCHER'
#!/bin/sh
# Lanza Navidrome al abrir si el puerto 4533 esta libre; lo apaga al salir.
dir=$(dirname "$0")
NAV=/opt/homebrew/bin/navidrome
if ! nc -z 127.0.0.1 4533 2>/dev/null && [ -x "$NAV" ]; then
    "$NAV" --configfile "$HOME/.config/navidrome/navidrome.toml" >>"$HOME/Library/Logs/navidrome.log" 2>&1 &
    nav=$!
    trap 'kill $nav 2>/dev/null' EXIT
    for _ in 1 2 3 4 5 6 7 8 9 10; do nc -z 127.0.0.1 4533 2>/dev/null && break; sleep 1; done
fi
"$dir/sonora-hermany-bin" "$@"
LAUNCHER
chmod +x "$APP/Contents/MacOS/sonora-hermany"
cp -R "$ORIG/Resources/icons" "$ORIG"/Resources/LICENSE* "$ORIG/Resources/THIRD-PARTY.md" "$APP/Contents/Resources/"
cp "$here/hermany/sonora-hermany.icns" "$APP/Contents/Resources/"
cp "$ORIG/Info.plist" "$APP/Contents/Info.plist"
PB=/usr/libexec/PlistBuddy
$PB -c "Set :CFBundleExecutable sonora-hermany" -c "Set :CFBundleIconFile sonora-hermany" \
    -c "Set :CFBundleIdentifier dev.hermany.sonora-hermany" -c "Set :CFBundleName Sonora-Hermany" \
    -c "Set :CFBundleDisplayName Sonora\ Hermany" "$APP/Contents/Info.plist"
$PB -c "Delete :CFBundleURLTypes" "$APP/Contents/Info.plist" 2>/dev/null || true
codesign --force --deep -s - "$APP"
echo "listo: $APP"
