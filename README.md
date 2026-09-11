# AbP Map Pack

Custom AoE2:DE random map scripts.

## Install / update

One-time setup: open [`update.ps1`](update.ps1) in this repo, click **Raw**,
and save the file somewhere handy (e.g. your Desktop).

Then, whenever you want to install the pack or grab the latest map changes:
**right-click `update.ps1` → Run with PowerShell**, and restart AoE2 DE.
The maps appear under Custom maps. The script finds your game profile
automatically and syncs this repo's newest version into
`Games\Age of Empires 2 DE\<profile-id>\mods\local\AbP Map Pack\`.

Manual alternative: download this repo as ZIP (green **Code** button →
Download ZIP) and drop its contents into that same folder.

## Maps

| Map | Description |
| --- | --- |
| **AbP Trio Stone Lanes** | MBA Trio Stone Lanes with ordered spawns: lobby order = spawn order, teams mirrored across the lanes. |
| **AbP Trio Lanes** | The water-middle Trio variant, same ordered spawns. |
| **AbP Trio Ford** | Mangrove ford middle with two solid stone gate-walls and a relic alley between them — mid can't be crossed without mining through. Great Marlins and oysters live in the walkable water. |
| **AbP Michi Relic Pond** | Classic seasons michi: 10 relics per player, dockable fish ponds (1–2 per player), standard 8 herdables, lighter woodlines, no-collision trade carts. |
| **AbP Michi Official Relic Pond** | Same treatment on the official 2023 Michi base (per-team-size layouts, neutral 1v1 markets), plus grouped teams on fallback placement and ordered spawns. |
| **AbP Black Boarest v2** | MBA Black Boarest v2 with no-collision trade carts added. |
| **AbP Arena** | Official Arena + no-collision trade carts, plus experimental small in-base ponds (carved into spawn terrain, ~1 per base, stocked with fish). All official berries kept. |
| **AbP Amazon Tunnel** | Official Amazon Tunnel + no-collision trade carts + decorative fish beneath every TC. |
| **AbP Burrito Brawl 4v4** | 4v4 rework of Dragonmilk's Burrito Brawl: the two-homes-per-player gimmick becomes diagonal team pockets (team 1 left-top + right-bottom, team 2 the opposite), burrito wall and corner lakes intact, 8 relics. Play on Large or bigger. |

## Lobby notes

- The Trio maps assign spawns by team (`AT_TEAM`): the lobby needs **two real teams
  of 2+ players** — AoE2 does not count a 1-player team as a team, so these maps
  cannot generate a plain 1v1. Use the Michi maps for 1v1s.
- Burrito Brawl 4v4 assigns by lobby slot: **team 1 = slots 1-4, team 2 = slots 5-8.**

## Notable techniques used

- `assign_to AT_TEAM <n> -1 0` — ordered (lobby-order) team member placement
- `effect_amount SET_ATTRIBUTE TRADE_CART ATTR_RADIUS_1 0` + `ATTR_LINE_OF_SIGHT 4` —
  no-collision trade (RADIUS_2 deliberately left default, per Dragonmilk's Tres Leches 2)
- `ignore_terrain_restrictions` — fish/oysters on mangrove (only Great Marlins survive there)
- Black-Forest-recipe ponds: plain `WATER`, 32 tiles, `clumping_factor 15`, `height_limits 0 0`,
  count scaled to players via a `N_PLAYER_GAME` define ladder
