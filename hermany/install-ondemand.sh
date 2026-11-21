#!/bin/sh
# Instala el proxy bajo demanda de Navidrome como LaunchAgent (arranca al iniciar sesion).
# Uso: hermany/install-ondemand.sh   |   desinstalar: hermany/install-ondemand.sh remove
set -e
here=$(cd "$(dirname "$0")" && pwd)
P="$HOME/Library/LaunchAgents/dev.hermany.navidrome-ondemand.plist"
launchctl bootout "gui/$(id -u)" "$P" 2>/dev/null || true
[ "$1" = remove ] && { rm -f "$P"; echo "quitado"; exit 0; }
cat > "$P" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>dev.hermany.navidrome-ondemand</string>
<key>ProgramArguments</key><array><string>/usr/bin/env</string><string>python3</string><string>$here/navidrome-ondemand.py</string></array>
<key>EnvironmentVariables</key><dict><key>PATH</key><string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string></dict>
<key>RunAtLoad</key><true/><key>KeepAlive</key><true/>
<key>StandardOutPath</key><string>$HOME/Library/Logs/navidrome-ondemand.log</string>
<key>StandardErrorPath</key><string>$HOME/Library/Logs/navidrome-ondemand.log</string>
</dict></plist>
PLIST
launchctl bootstrap "gui/$(id -u)" "$P"
echo "instalado: $P"
