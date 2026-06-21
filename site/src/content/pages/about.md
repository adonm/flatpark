---
title: About FlatPark
description: What FlatPark is, why it exists, and how it relates to Flatpak and Flathub.
group: Project
order: 1
---

FlatPark is a community Flatpak hub for apps that ship as a definitive download —
an official installer or prebuilt archive at a stable, public release URL.
FlatPark fetches that release at build time, repackages it as a Flatpak
([extra-data](/trust/)), pins it, and signs the result. It never builds apps from
source.

## Why it exists

- **One runtime, always latest.** Every hosted app is continuously upgraded and
  tested against the newest runtime, so you only need a single, latest copy of
  the runtime installed.
- **Sandboxed and out of your home directory.** Flatpak keeps each app
  sandboxed; FlatPark keeps the permissions tight and surfaces them on every
  app page.
- **One place to install and update.** Apps that otherwise ship only a raw
  `.deb`, AppImage, or tarball become installable and auto-updating through one
  remote.

## How it relates to Flatpak and Flathub

FlatPark is built on [Flatpak](https://flatpak.org/) and is **not affiliated
with [Flathub](https://flathub.org/)**. Flathub builds most apps from source;
FlatPark deliberately only repackages official downloads (extra-data). The two
are complementary — if an app is on Flathub, install it there.

## Who runs it

FlatPark is an independent, community-run project. Its own code is MIT-licensed;
the packaged applications remain their vendors' property and are fetched from
official sources at install time.
