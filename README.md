# AbP Map Pack

Custom AoE2:DE random map scripts.

## Install / update

This repo is **private** — you need to be added as a collaborator (accept the
GitHub invite email first).

One-time setup: open [`update.ps1`](update.ps1) in this repo, click **Raw**,
and save the file somewhere handy (e.g. your Desktop). That's it — no other
installs needed.

Then, whenever you want to install the pack or grab the latest map changes:
**right-click `update.ps1` → Run with PowerShell**, and restart AoE2 DE.
On the very first run the script sets itself up: if you have neither Git nor
the GitHub CLI, it installs the GitHub CLI automatically (via winget) and
opens a one-time GitHub browser sign-in. Every run after that is silent. It
finds your game profile automatically and keeps
`Games\Age of Empires 2 DE\<profile-id>\mods\local\AbP Map Pack\` up to date.

Already have Git or `gh`? The script just uses what you have.

Manual alternative: `git clone` this repo into that same folder yourself,
then `git pull` whenever there are updates.

## Maps

| Map | Description |
| --- | --- |
| **AbP Trio Stone Lanes** | MBA Trio Stone Lanes with ordered spawns: lobby order = spawn order, teams mirrored across the lanes. |
| **AbP Trio Lanes** | The water-middle Trio variant, same ordered spawns. |
| **AbP Trio Ford** | Mangrove ford middle with two solid stone gate-walls and a relic alley between them — mid can't be crossed without mining through. Great Marlins and oysters live in the walkable water. |
| **AbP Michi Relic Pond** | Classic seasons michi: 10 relics per player, dockable fish ponds (1–2 per player), standard 8 herdables, lighter woodlines, no-collision trade carts. |
| **AbP Michi Official Relic Pond** | Same treatment on the official 2023 Michi base (per-team-size layouts, neutral 1v1 markets), plus grouped teams on fallback placement and ordered spawns. |
| **AbP Black Boarest v2** | MBA Black Boarest v2 with no-collision trade carts added. |
| **AbP Onion** | Original map: a sealed concentric onion at the center — tree ring, solid stone wall, tree ring, solid gold wall, then a relic sanctum (12 relics, treasure, jaguars) around a marlin pool. Peel it layer by layer; every layer pays. Full AbP kit: guaranteed home mangrove pond, TC fish, ghost trade. |
| **AbP Arena** | Official Arena + no-collision trade carts, plus experimental small in-base ponds (carved into spawn terrain, ~1 per base, stocked with fish). All official berries kept. |
| **AbP Amazon Tunnel** | Official Amazon Tunnel + no-collision trade carts + decorative fish beneath every TC. |
| **AbP Burrito Brawl 4v4** | 4v4 rework of Dragonmilk's Burrito Brawl: full team sides assigned by team (`AT_TEAM`, team 1 left, team 2 right), every player keeps the two-homes gimmick (2 TCs each), burrito wall, corner fish lakes and mangrove islands intact, 8 relics, TC fish, no-collision trade carts. Play on Large or bigger. |

## Lobby notes

- The Trio maps and Burrito Brawl 4v4 assign spawns by team (`AT_TEAM`): the lobby
  needs **two real teams of 2+ players** — AoE2 does not count a 1-player team as a
  team, so these maps cannot generate a plain 1v1 or an FFA. Use the Michi maps for 1v1s.
- Burrito Brawl 4v4 no longer cares about lobby slot order: each team fills its own side
  of the burrito top-to-bottom in lobby order, so "Team Together" works as expected.

## Notable techniques used

- `assign_to AT_TEAM <n> -1 0` — ordered (lobby-order) team member placement
- `assign_to AT_TEAM <n> -1 2` immediately followed by `... -1 0` — gives the *same*
  team member two lands (flags 2 = "do not remember this assignment"), as used for
  Burrito Brawl's two-homes spawns
- `effect_amount SET_ATTRIBUTE TRADE_CART ATTR_RADIUS_1 0` + `ATTR_LINE_OF_SIGHT 4` —
  no-collision trade (RADIUS_2 deliberately left default, per Dragonmilk's Tres Leches 2)
- `ignore_terrain_restrictions` — fish/oysters on mangrove (only Great Marlins survive there)
- Black-Forest-recipe ponds: plain `WATER`, 32 tiles, `clumping_factor 15`, `height_limits 0 0`,
  count scaled to players via a `N_PLAYER_GAME` define ladder
