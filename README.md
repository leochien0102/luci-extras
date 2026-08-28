# luci-extras

Unified OpenWrt feed for leochien0102's self-maintained LuCI packages.
Each package lives in its own top-level subdirectory so that OpenWrt's
`scripts/feeds` scanner (`scan.mk -mindepth 1`) can pick it up.

## Packages

| Package | Upstream | Notes |
|---|---|---|
| `luci-app-argon-config` | coolsnowwolf/luci (argon theme) | argon theme config app |
| `luci-app-accesscontrol-plus` | leochien0102 (original) | access control + miaplus |
| `luci-theme-proton2025` | ChesterGoodiny/luci-theme-proton2025 | Proton2025 dark theme |

All three are firewall-generation-neutral; a single `main` branch serves
both fw3 and fw4 builds.

## Usage

In `feeds.conf`:

    src-git luciextras https://github.com/leochien0102/luci-extras.git;main

Then `./scripts/feeds update -a && ./scripts/feeds install -a`.
