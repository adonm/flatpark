#!/bin/sh
set -eu

# Runs offline at install time inside org.gnome.Platform. The upstream Debian
# package is a plain FHS tree whose payload is a single Tauri binary at
# usr/bin/tine (the SolidJS frontend is embedded in the executable); the rest is
# the .desktop file and three icon sizes. We stage the binary at a stable path
# the wrapper expects: /app/extra/tine/bin/tine. The desktop file, icon and
# AppStream metainfo are shipped by the manifest at *build* time — extra-data is
# fetched later on the user's machine, so anything Flatpak must export cannot
# come from here.

extra_root="${EXTRA_ROOT:-/app/extra}"
cd "$extra_root"

[ -f tine.deb ] || { echo "missing extra-data: tine.deb" >&2; exit 1; }

# The Platform runtime has no ar/dpkg, but bsdtar (libarchive) reads the .deb
# ar container directly; pipe its data member into a second bsdtar to unpack the
# FHS tree (the inner data.tar compression is auto-detected).
rm -rf stage tine
mkdir stage
# --no-same-owner: on a system-wide install Flatpak runs apply_extra as root with
# every capability dropped, so restoring the archive's recorded uid/gid fails and
# aborts the unpack even though every member extracted fine.
bsdtar -xOf tine.deb 'data.tar*' | bsdtar --no-same-owner -xf - -C stage
[ -f stage/usr/bin/tine ] || { echo "tine not found in .deb" >&2; exit 1; }

mkdir -p tine/bin
mv stage/usr/bin/tine tine/bin/tine
rm -rf stage tine.deb
chmod +x tine/bin/tine
