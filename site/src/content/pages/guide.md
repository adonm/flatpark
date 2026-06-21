---
title: User guide
description: Installing, updating, uninstalling, and understanding FlatPark apps.
group: Docs
order: 2
---

## Installing an app

First add the FlatPark remote (once), then install any app:

```sh
flatpak --user remote-add --if-not-exists flatpark https://dl.flatpark.org/flatpark.flatpakrepo
flatpak --user install flatpark <app-id>
```

The [setup page](/setup/) has the full first-time walkthrough, including the
runtime remote.

## User vs system install

`--user` installs into your home directory and needs no admin rights. Drop
`--user` from both commands for a system-wide install (requires root). You can
use either; `--user` is the simplest if you are not sure.

## Updates and the single runtime

FlatPark continuously rebuilds each app against the newest runtime, so a normal
`flatpak update` keeps every app current and you only ever need one, latest copy
of the runtime installed:

```sh
flatpak --user update
```

## Reading an app's permissions

Every app page lists the exact sandbox permissions it requests, with a
plain-language risk label. Check these before installing — see
[Trust & safety](/trust/) for what the model guarantees.

## Uninstalling

```sh
flatpak --user uninstall <app-id>
```

To also remove unused runtimes afterwards:

```sh
flatpak --user uninstall --unused
```

## Troubleshooting

- **App not found:** make sure the remote was added (`flatpak remotes`) and the
  app id is spelled exactly as shown on its page.
- **Signature/GPG errors:** re-add the remote with the command above; it pins the
  signing key.
- **Won't launch:** run it from a terminal (`flatpak run <app-id>`) to see the
  error output.
