# AbP Map Pack

Custom AoE2:DE random map scripts. Install by dropping this folder into
`Games\Age of Empires 2 DE\<profile-id>\mods\local\` and restarting the game —
the maps appear under Custom maps.

## Maps

| Map | Description |
| --- | --- |
| **AbP Trio Stone Lanes** | MBA Trio Stone Lanes with ordered spawns: lobby order = spawn order, teams mirrored across the lanes. |
| **AbP Trio Lanes** | The water-middle Trio variant, same ordered spawns. |
| **AbP Trio Ford** | Mangrove ford middle with two solid stone gate-walls and a relic alley between them — mid can't be crossed without mining through. Great Marlins and oysters live in the walkable water. |
| **AbP Michi Relic Pond** | Classic seasons michi: 10 relics per player, dockable fish ponds (1–2 per player), standard 8 herdables, lighter woodlines, no-collision trade carts. |
| **AbP Michi Official Relic Pond** | Same treatment on the official 2023 Michi base (per-team-size layouts, neutral 1v1 markets), plus grouped teams on fallback placement and ordered spawns. |

## Notable techniques used

- `assign_to AT_TEAM <n> -1 0` — ordered (lobby-order) team member placement
- `effect_amount SET_ATTRIBUTE TRADE_CART ATTR_RADIUS_1 0` + `ATTR_LINE_OF_SIGHT 4` —
  no-collision trade (RADIUS_2 deliberately left default, per Dragonmilk's Tres Leches 2)
- `ignore_terrain_restrictions` — fish/oysters on mangrove (only Great Marlins survive there)
- Black-Forest-recipe ponds: plain `WATER`, 32 tiles, `clumping_factor 15`, `height_limits 0 0`,
  count scaled to players via a `N_PLAYER_GAME` define ladder
