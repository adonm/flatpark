#!/bin/sh
set -eu

# Runs offline at install time inside org.gnome.Platform. Upstream ships
# Longbridge Pro as a .deb with the application binary at /usr/local/bin.
# Flatpak-exported metadata and fonts are installed by the manifest at build
# time; extra-data only stages the proprietary app binary into /app/extra.

extra_root="${EXTRA_ROOT:-/app/extra}"
cd "$extra_root"

[ -f longbridgepro.deb ] || { echo "missing extra-data: longbridgepro.deb" >&2; exit 1; }

rm -rf stage longbridge
mkdir stage
bsdtar -xOf longbridgepro.deb 'data.tar*' | bsdtar -xf - -C stage
[ -x stage/usr/local/bin/longbridge ] || { echo "Longbridge binary not found in .deb" >&2; exit 1; }
mv stage/usr/local/bin/longbridge longbridge
rm -rf stage longbridgepro.deb
[ -x longbridge ] || { echo "Longbridge binary missing after stage" >&2; exit 1; }
