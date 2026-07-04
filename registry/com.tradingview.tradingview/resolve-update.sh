#!/usr/bin/env bash
# Update resolver for TradingView.
#
# Prints the current version + Linux x86_64 .deb as JSON on stdout:
#   { "version": "3.3.0-1", "releaseDate": "YYYY-MM-DD",
#     "sources": [ { "filename": "tradingview.deb", "url": "..." } ] }
#
# TradingView publishes a small Debian repository. The plain Packages.gz path
# may be unavailable on its CDN, but InRelease advertises Acquire-By-Hash, so we
# read Packages.gz via the SHA256 object declared by the signed Release data.
set -euo pipefail

ROOT_URL="https://tvd-packages.tradingview.com/ubuntu/stable"
DIST="jammy"
COMPONENT="multiverse"
ARCH="amd64"

need() { command -v "$1" >/dev/null 2>&1 || { echo "missing command: $1" >&2; exit 1; }; }
need curl; need gzip; need python3

inrelease="$(curl -fsSL "$ROOT_URL/dists/$DIST/InRelease")"

release_date="$(python3 - "$inrelease" <<'PY'
import email.utils
import sys

text = sys.argv[1]
for line in text.splitlines():
    if line.startswith("Date:"):
        dt = email.utils.parsedate_to_datetime(line.split(":", 1)[1].strip())
        print(dt.date().isoformat())
        break
else:
    raise SystemExit("missing Date in InRelease")
PY
)"

packages_hash="$(python3 - "$inrelease" "$COMPONENT/binary-$ARCH/Packages.gz" <<'PY'
import sys

text, wanted = sys.argv[1:3]
in_sha256 = False
for line in text.splitlines():
    if line == "SHA256:":
        in_sha256 = True
        continue
    if in_sha256 and line and not line.startswith(" "):
        break
    if in_sha256:
        parts = line.split()
        if len(parts) == 3 and parts[2] == wanted:
            print(parts[0])
            break
else:
    raise SystemExit(f"missing SHA256 entry for {wanted}")
PY
)"

packages="$(curl -fsSL "$ROOT_URL/dists/$DIST/$COMPONENT/binary-$ARCH/by-hash/SHA256/$packages_hash" | gzip -dc)"

python3 - "$ROOT_URL" "$release_date" "$packages" <<'PY'
import json
import re
import sys

root_url, release_date, packages = sys.argv[1:4]

def split_records(text):
    for raw in text.strip().split("\n\n"):
        record = {}
        last = None
        for line in raw.splitlines():
            if not line:
                continue
            if line[0].isspace():
                continue
            key, _, value = line.partition(":")
            if _:
                record[key] = value.strip()
                last = key
        if record:
            yield record

def version_key(v):
    # TradingView versions are simple Debian versions such as 3.3.0-1.
    return [int(x) if x.isdigit() else x for x in re.split(r"([0-9]+)", v)]

records = [
    r for r in split_records(packages)
    if r.get("Package") == "tradingview" and r.get("Architecture") == "amd64"
]
if not records:
    raise SystemExit("failed to find tradingview amd64 package")

latest = max(records, key=lambda r: version_key(r.get("Version", "")))
version = latest.get("Version")
filename = latest.get("Filename")
if not version or not filename:
    raise SystemExit("latest package missing Version or Filename")

url = f"{root_url}/{filename}"
print(json.dumps({
    "version": version,
    "releaseDate": release_date,
    "sources": [{"filename": "tradingview.deb", "url": url}],
}, indent=2))
PY
