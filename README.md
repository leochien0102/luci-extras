# luci-extras

Unified OpenWrt feed for leochien0102's self-maintained LuCI packages.
Each package lives in its own top-level subdirectory so that OpenWrt's
`scripts/feeds` scanner (`scan.mk -mindepth 1`) can pick it up.

## Packages

| Package | Upstream | Notes |
|---|---|---|
| `luci-app-accesscontrol-plus` | leochien0102 (original) | access control + miaplus |
| `luci-theme-proton2025` | ChesterGoodiny/luci-theme-proton2025 | Proton2025 dark theme |

Both are firewall-generation-neutral; a single `main` branch serves
both fw3 and fw4 builds.

`luci-app-argon-config` used to live here but was dropped: the `luci` feed
(coolsnowwolf) ships a package of the same name and sits ahead of this one
in `feeds.conf`, so `feeds install -a` always picked that one and the copy
here was never built. Keeping two of them bought nothing.

## Usage

In `feeds.conf`:

    src-git luciextras https://github.com/leochien0102/luci-extras.git;main

Then `./scripts/feeds update -a && ./scripts/feeds install -a`.
