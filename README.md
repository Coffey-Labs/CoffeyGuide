# Coffey's Leveling Guide

A free, standalone leveling and gear guide for **World of Warcraft: Forever**, by
[Coffey Labs LLC](https://coffeylabs.org).

It works out your race, class, spec and professions on its own, then shows the next
thing to do: the zone route from 1 to 60 for both factions and every race, including
Skyborne, with quest-by-quest steps for every zone.

Formerly named ForeverGuide. It was renamed in 3.0.0 because another WoW Forever addon already
uses that name and the `/fg` command.

## Features

- **Route 1-60** for Horde and Alliance, every starting zone including the Skyborne
  start on Zephras Isle, with dungeon steps, class quests and class mounts.
- **Quest-by-quest plans** for every zone on the route: accept, kill, collect and
  turn-in steps with map waypoints, checked against your quest log and
  completed-quest history.
- Riverglades, Shen'dralas and Mount Hyjal have no published routes yet, so their
  steps follow the quest chains and quest-giver locations, and some objectives there
  have no waypoint. If a step looks wrong, skip it and open an issue.
- **Tracker** panel with the current step, zone progress, live objectives and the next
  talent point.
- **Talents**: two or three leveling builds per class, detected from the points you
  have spent, with the next talent highlighted in the talent window.
- **Spec guides** for all 27 specs.
- **Gear**: an upgrade score in item tooltips, a bag-upgrade popup, quest-reward
  advice, and level 20/30/40/50 and pre-raid best-in-slot lists.
- **Professions**: a leveling guide for each profession you have learned.
- **Gold and extras**: gold-making tips, mounts, attunements and dungeon notes.
- Optional quality-of-life settings (auto accept, auto turn-in, sell gray items,
  auto repair). All are off by default; hold Shift to bypass them.

Coffey's Leveling Guide needs no other addons. When TomTom, Questie or ForeverDungeonJournal are
installed it uses them for waypoints and NPC locations, and never changes their
settings or frames.

## Install

Download `CoffeyGuide-<version>.zip` from
[Releases](https://git.coffeylabs.org/coffey-labs/CoffeyGuide/releases) and unzip it into
`World of Warcraft/_forever_/Interface/AddOns/`, so the addon ends up in
`AddOns/CoffeyGuide`. Then restart the game or type `/reload`.

Cloning this repository straight into `AddOns/` works too.

## Commands

| Command | Does |
|---|---|
| `/cguide` | Show or hide the tracker |
| `/cguide guide` | Open the full guide window |
| `/cguide quests` | Open the quest log tab |
| `/cguide talents`, `/cguide spec`, `/cguide gear`, `/cguide prof` | Open those tabs |
| `/cguide gold`, `/cguide dungeons`, `/cguide settings` | Open those tabs |
| `/cguide next`, `/cguide prev` | Move between route steps |
| `/cguide wp` | Set a waypoint for the current step |
| `/cguide sync` | Re-read completed quests |
| `/cguide reset` | Clear this character's guide progress |
| `/cguide resetpos` | Reset window positions |
| `/cguide talentdebug` | Print what the game's talent API returns, for bug reports |
| `/cguide support` | Show the link to our funding options |

`/coffeyguide` works as a longer alias for `/cguide`.

The minimap button and the addon compartment open the guide (left-click) or toggle
the tracker (right-click).

## Development

`tools/harness.lua` loads the addon against a mock game API and runs the main flows:

    lua5.1 tools/harness.lua . Data Undead Scourge PALADIN Horde 12

Set `HISTORY=1` to start with class quests already completed. By default the mock
exposes the classic global talent functions; `TALENT_API` swaps them for `id`, `new`,
`tier` (how WoW Forever does it) or `traits`. `TALENT_LATE=1` keeps talent data empty until after login, as on a slow
client.

`tools/validate_plans.lua` checks a quest-plan data file:

    lua5.1 tools/validate_plans.lua Data/plans_horde_10_26.lua h_tirisfal_late,h_silverpine

`media/` holds the project logo. It is not part of the release zip.

## Credits

Bundled libraries: LibStub, CallbackHandler-1.0, HereBeDragons-2.0, LibDataBroker-1.1
and LibDBIcon-1.0, each under its own license. Route, quest and gear data were compiled
from public WoW Forever guides and databases.

## Support the project

Coffey's Leveling Guide is free and will stay free. If it saves you time, you can help keep
Coffey Labs going through GitHub Sponsors or Liberapay. Our
[funding options](https://coffeylabs.org/support/) page lists both, along with what
the money pays for. In game, `/cguide support` shows the link.

## License

MIT. See [LICENSE](LICENSE). Copyright (c) 2026 Coffey Labs LLC.
