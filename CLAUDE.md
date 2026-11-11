# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Skill Documentation

`Skills/NnGoogleAdsKit/` holds the published API-reference skill. It lives here — not in a
separate skills repo — so the API and its documentation change in the same PR. It previously lived
in the `nelix-swift-tools` marketplace, where nothing tied it to this package's releases.

- **Any PR changing the public API must update `Skills/`.** Nothing enforces this in CI, so check
  it by hand whenever a PR touches `public`/`open` declarations in `Sources/` — including the
  `NnGoogleAdsUITestHelpers` product, not just `NnGoogleAdsKit`.
- **Don't hand-edit `version` in `Skills/NnGoogleAdsKit/.claude-plugin/plugin.json`.** `nnex`
  writes it on every release, so it always equals the tag that shipped it.
- **SwiftPM ignores `Skills/`** — it is not a target and must not become one.
- **The skill is public.** Never put local machine paths or private details in it.

### Releasing

Releases go through `nnex ship package <version>` (no `v` prefix — matches the `0.9.0`
convention). `.nnex/nnex.json` lists `Skills/NnGoogleAdsKit` as this target's skill, so a release:

1. writes the release version into the skill's `plugin.json`, then tags and publishes the package;
2. adds or updates the `NnGoogleAdsKit` entry in the `nn-swift-skills` marketplace
   (`skillMarketplace` in `~/.nnex/nnex.json`) as a `git-subdir` source pinned to that tag.

There is no tag-push workflow — `nnex` owns the marketplace bump. **Doc changes therefore reach
consumers on release, not on merge**: a correction merged to `main` is invisible until the next
`nnex ship`. Tagging by hand skips step 2, and the marketplace keeps serving the previous
release's docs with nothing erroring and nothing warning.
