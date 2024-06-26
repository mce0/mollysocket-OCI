# mce0/mollysocket

![Build, scan & push](https://github.com/mce0/mollysocket-OCI/actions/workflows/build.yml/badge.svg)

[Mollysocket](https://github.com/mollyim/mollysocket) allows [Molly](https://github.com/mollyim/mollyim-android), a Signal fork, getting notifications via [UnifiedPush](https://unifiedpush.org/).

### Notes
- Prebuilt images are available at `ghcr.io/mce0/mollysocket`.
- Don't trust random images: build yourself if you can.
- Always keep your software up-to-date: manage versions with [build-time variables](https://github.com/mce0/mollysocket-OCI/blob/main/Dockerfile#L1-L3).

### Features & usage
- Drop-in replacement for the [official image](https://github.com/mollyim/mollysocket/pkgs/container/mollysocket).
- Based on the latest [Alpine](https://alpinelinux.org/) containers which provide more recent packages while having less attack surface.
- Daily rebuilds keeping the image up-to-date.
- Comes with the [hardened memory allocator](https://github.com/GrapheneOS/hardened_malloc) built from the latest tag, protecting against some heap-based buffer overflows.