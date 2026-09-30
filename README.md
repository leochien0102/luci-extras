# luci-extras

Unified OpenWrt feed for leochien0102's self-maintained LuCI packages.
Each package lives in its own top-level subdirectory so that OpenWrt's
`scripts/feeds` scanner (`scan.mk -mindepth 1`) can pick it up.

## Packages

| Package | Upstream | Notes |
|---|---|---|
| `luci-app-accesscontrol-plus` | leochien0102 (original) | access control + miaplus |
| `luci-app-ssrp-watch` | leochien0102 (original) | watchdog for the ssr-plus tunnel; see its own README |
| `luci-theme-argon-plus` | luci feed (jerrykuku) | Argon theme + argon-config merged; see below |
| `luci-theme-proton2025` | ChesterGoodiny/luci-theme-proton2025 | Proton2025 dark theme |

All are firewall-generation-neutral; a single `main` branch serves
both fw3 and fw4 builds.

`luci-app-ssrp-watch` is the one package here with a hard dependency on
another feed: it needs `luci-app-ssr-plus` from the `helloworld` feed,
because its page hangs off that app's menu node and every path it reads is
an ssr-plus internal. It registers its own tab from its own controller, so
luci-app-ssr-plus needs no modification -- which is the point, that package
being a fork whose every local line has to be carried through each upstream
merge.

`luci-app-argon-config` used to live here but was dropped: the `luci` feed
(coolsnowwolf) ships a package of the same name and sits ahead of this one
in `feeds.conf`, so `feeds install -a` always picked that one and the copy
here was never built. Keeping two of them bought nothing.

`luci-theme-argon-plus` is the answer to that dead end: the feed's
`luci-theme-argon` and `luci-app-argon-config` merged into one package
under a name that does not collide. Everything ships together -- theme,
config UCI, rpcd backend and ACL -- and the settings UI is mounted inline
below the theme selector on System Properties -> Language and Style,
in the manner of `luci-theme-proton2025`, whenever the Argon Plus design
is selected. There is no `System -> Argon Config` menu entry. Theme
assets live under `/luci-static/argon-plus/` and the rpcd object is
`luci.argon_plus`.

The package does not declare package-manager-level conflicts (the feed's
luci.mk has no channel for that), so keep the upstream pair out of the
image config when this one is selected -- the openwrt-actions target
configs already do. Its uci-defaults migrate away from the pair: a stale
`luci.themes.Argon` entry carried over by sysupgrade is removed, and if
Argon was the active theme, Argon Plus takes the slot.

## Syncing `luci-theme-proton2025`

The package is vendored from `ChesterGoodiny/luci-theme-proton2025` with
`git subtree`. Sync to a release tag, not to `main` -- the tag is what
`PROTON_VERSION` is pinned to:

    git subtree pull --prefix=luci-theme-proton2025 \
        https://github.com/ChesterGoodiny/luci-theme-proton2025 vX.Y.Z --squash
    git commit --amend -m "⬆️ chore(proton2025): sync upstream vX.Y.Z"

Upstream's tree does not satisfy this repo's `.gitattributes` (nor its own),
so these four items have to be carried by hand **every time**:

1. bump `PROTON_VERSION?=` in the package `Makefile`. Upstream's CI overrides
   it from the release tag, so the value it commits always lags behind;
2. re-normalise the CRLF files upstream keeps committing despite its own
   `eol=lf` rules:

       git add --renormalize -- luci-theme-proton2025
       git ls-files --eol | awk '$1=="i/crlf" && /eol=lf/'

   The second command must print nothing. A file left in that state shows a
   permanent "modified" that `git checkout` cannot clear, and it makes
   `scripts/feeds update` fail with "local changes would be overwritten".
   `root/usr/share/rpcd/ucode/luci.proton-temp` is a ucode script: CRLF there
   breaks it at runtime, which is how the `postrm` bug got in;
3. keep the `postrm` hardening (drop `luci.themes.Proton2025`, restore
   `mediaurlbase`). It is not upstream, so a merge may drop it;
4. confirm nothing else drifted -- only `Makefile` may differ:

       git --git-dir=<upstream-clone> archive vX.Y.Z | tar -x -C /tmp/up
       diff -rq /tmp/up luci-theme-proton2025

## Usage

In `feeds.conf`:

    src-git luciextras https://github.com/leochien0102/luci-extras.git;main

Then `./scripts/feeds update -a && ./scripts/feeds install -a`.
