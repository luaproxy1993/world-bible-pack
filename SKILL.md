---
name: world-bible-pack
description: >
  Build a World Bible content pack: character portraits, a playable-window
  map, location plates, and props. Use when the user runs /world-bible-pack,
  says 内容集, 素材包, 立绘, 地图, 道具, or wants pictures from a locked World
  Bible. Not for writing the bible — that is /world-bible.
argument-hint: "[world_path]"
user-invocable: true
metadata:
  short-description: Generate portraits, map, places, props from a World Bible
  version: "1.0.0"
  requires: "world-bible"
---

# World Bible Pack

Reads a **text** World Bible and writes pictures under `{WORLD}/pack/`.
Does not author lock, world, stage, or timeline.

```
WB_SKILL=~/.grok/skills/world-bible
PACK_SKILL=~/.grok/skills/world-bible-pack
WORLD=<world-root>
```

Load:

- `{WORLD}/lock.json`, `{WORLD}/art/art.json`, `{WORLD}/stage/stage.json`, `{WORLD}/world/world.json`
- `{WB_SKILL}/references/ART.md` (schools, tell, Must, Forbidden)
- `imagine` skill before any `image_gen` / `image_edit`

Abort if look school, medium, or style_sentence is empty. Abort if
`lock.look.source` is `inferred` — send them to `/world-bible art` for
`look-dev: pick`.

## Commands

```
/world-bible-pack
/world-bible-pack <world_path>
```

Resolve world: path named → `./<slug>` → ask once.

## Run

Do only this pack. Do not edit bible JSON. Do not start `/world-bible`.
Do not ask more than one path question.

Every prompt starts with the school **tell** + `art.medium` + two pigments
from `art.palette` + `art.light`. Then the subject. End with the school's
Must. Recurring places: `image_edit` from the style-anchor when ratio
matches.

## What to generate

Derive the list from `art.subjects[]` if that array is non-empty. Else:

| Kind | Source | File | Recipe |
|------|--------|------|--------|
| `anchor` | one empty place that teaches light | `pack/anchor.png` | location, no hero, 16:9 |
| `map` | playable window geography | `pack/map.png` | painted/photographed map of this window only, **no letters** |
| `portrait` | every `stage.people[]` | `pack/people/<id>.png` | standing three-quarter, flat black, 3:4 |
| `place` | every `stage.places[]` | `pack/places/<id>.png` | location, no hero, mixed ratios |
| `signature` | `world.signature` in use | `pack/signature/<id>.png` | object in this world's light, not a catalog shot |
| `prop` | three ordinary objects named in place/people briefs | `pack/props/<slug>.png` | in use or where it lives |

Entry face is generated first among portraits and frozen. Later portraits
of the same face are `image_edit`.

Write `pack/pack.json` listing every asset (`id`, `kind`, `subject_id`, `path`).

## Order

```
anchor          image_gen 16:9
  → map         image_gen 16:9 or 1:1
  → portraits   entry face first; then others (parallel within)
  → places      image_edit from anchor when 16:9; else image_gen
  → signature   in use
  → props       in use
  → pack.json
```

Parallelize only within one row. Copy files onto disk before the next row.

## Verify

Fail if:

- thumbnail could pass for another school
- a portrait has an environment
- the map has readable type
- a place could be another world's city
- the entry face drifted
- a prop is a white-background catalog shot

One retry, then keep and flag.

**STOP** — `pack: accept`
