#!/usr/bin/env bash
# Update resolver for BrowserOS desktop releases.
#
# BrowserOS publishes several release lines in one GitHub repo. GitHub's
# "latest" release can point to BrowserClaw/CLI/server assets, so this resolver
# scans releases for the newest desktop release that has an amd64 Debian package.
set -euo pipefail

repo="browseros-ai/BrowserOS"

need() { command -v "$1" >/dev/null 2>&1 || { echo "missing command: $1" >&2; exit 1; }; }
need curl; need jq

rels="$(curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
        "https://api.github.com/repos/$repo/releases?per_page=100")"

match="$(jq -c '
  map(select(.draft == false and .prerelease == false))
  | map(. as $r
      | ($r.assets[]? | select(.name | test("^BrowserOS_v[0-9][^/]*_amd64\\.deb$")))
        as $a
      | {version: ($r.tag_name | ltrimstr("v")),
         releaseDate: ($r.published_at[0:10]),
         url: $a.browser_download_url})
  | first
' <<<"$rels")"

version="$(jq -r '.version // empty' <<<"$match")"
date="$(jq -r '.releaseDate // empty' <<<"$match")"
url="$(jq -r '.url // empty' <<<"$match")"

[ -n "$version" ] && [ -n "$url" ] || { echo "failed to resolve BrowserOS desktop release" >&2; exit 1; }
echo "resolved BrowserOS $version ($date): $url" >&2

jq -n --arg v "$version" --arg d "$date" --arg u "$url" \
  '{version:$v, releaseDate:$d, sources:[{filename:"browseros.deb", url:$u}]}'

