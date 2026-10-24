# ZapFast Linux builds (Ubuntu 22.04+)

Prebuilt **ZapFast** binaries for Ubuntu 22.04 and anything newer, built from
the upstream source by GitHub Actions.

- Upstream project: [crmne/zapfast](https://github.com/crmne/zapfast) (MIT)
- This repository only adds a build workflow, an installer and the resulting
  release artifacts. It does not change the app's behaviour or its code,
  except for the audio host described below.

## Why this exists

The upstream AppImage does not run on Ubuntu 22.04:

- Upstream releases are built on Ubuntu 24.04, so the binary needs
  **glibc 2.39**. 22.04 ships glibc 2.35.
- The AppImage also needs a working FUSE mount, which fails on some setups.

These builds are compiled on an `ubuntu-22.04` runner (glibc 2.35) and shipped
as a plain tarball, so no FUSE is involved.

One deliberate change: upstream compiles cpal's **PipeWire** audio host, which
needs libpipewire **0.3.53+**; Ubuntu 22.04 has 0.3.48. The workflow builds
`fastframe-audio` with its PulseAudio host instead (PulseAudio is the sound
server on 22.04), so sound, notification sounds and voice notes work normally.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/favourthemaster/zapfast-linux-builds/main/install.sh | bash
```

The script installs `~/.local/bin/zapfast` and a desktop entry. It never
touches:

- `~/.config/zapfast` — settings and themes
- `~/.local/share/zapfast` — window state
- `~/.local/state/zapfast` — the linked WhatsApp session and message archive

so an update keeps you logged in.

## Build it yourself

Actions → **Build ZapFast for Ubuntu 22.04** → *Run workflow*. Leave the `ref`
input empty to build the latest upstream release, or pass a tag such as
`v0.20.1`.

Each successful run attaches a workflow artifact and publishes a release tagged
`v<version>` containing:

```
zapfast-<version>-ubuntu22.04-x86_64.tar.gz
SHA256SUMS
```

## Notes

- x86_64 only. The workflow runs on GitHub's hosted 22.04 image, so expect
  roughly 20–40 minutes per build.
- Voice/video calls need a working microphone and PulseAudio; PipeWire-only
  desktops are not supported by these builds.
- ZapFast is MIT licensed. All credit for the application goes to
  [Carmine Paolino and contributors](https://github.com/crmne/zapfast).
