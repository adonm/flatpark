#!/bin/sh
# Stub sandbox for BrowserOS Flatpak. cobalt requires a sandbox binary to exist
# at a known path before it will launch the browser. BrowserOS does not ship
# chrome-sandbox, so this stub exits non-zero and lets Chromium fall back to the
# zypak/no-setuid path provided by the Chromium base app.
echo "Stub sandbox ignoring command: $*" >&2
exit 1

