local _, ns = ...
-- Spec guides for World of Warcraft: Forever (client 1.60.1).
-- Sources (fetched 2026-11-15):
--   Warcraft Tavern spec guides  https://www.warcrafttavern.com/forever/guides/<spec>-<class>/
--   Icy Veins rotation + stats   https://www.icy-veins.com/wow-forever/<spec>-<class>-<role>-pve-rotation-cooldowns-abilities
--                                https://www.icy-veins.com/wow-forever/<spec>-<class>-<role>-pve-stat-priority
--   wowhandbook class/leveling   https://wowhandbook.com/classes/<class>/ (+ leveling/, talents/, stat-priority/, spellbook/)
--   TopBuilds tier lists         https://topbuilds.gg/wow-forever/{dps,healer,tank,leveling}-tier-list/
-- "best" flags: leveling = wowhandbook's recommended leveling build; dungeons/raid = TopBuilds tier lists
-- plus WT/IV strengths. Stats use the Icy Veins level-60 priorities (caps: melee 8% hit / 6.5% expertise,
-- spells 17% hit vs level 63 bosses).
-- Tab names follow wowhandbook's client-data talent calculator ("Shadow Magic", "Elemental Combat",
-- "Feral Combat"); lookups by "Shadow", "Elemental" and "Feral" are aliased at the bottom of this file.

ns.SPECGUIDES = ns.SPECGUIDES or {}

---------------------------------------------------------------------------
-- WARRIOR
---------------------------------------------------------------------------
ns.SPECGUIDES.WARRIOR = ns.SPECGUIDES.WARRIOR or {}

ns.SPECGUIDES.WARRIOR["Arms"] = {
  role = "Melee DPS",
  best = { leveling = false, dungeons = false, raid = false, pvp = true },
  summary = "Slow two-hander, bleeds and Overpower procs (Bloodthrill). Best 2-3 target cleave and Mortal Strike; WT calls it the premier PvP spec. Levels as Prot to 30, then Arms.",
  stats = "Weapon DPS > Hit (8% with a 2H) > Expertise (6.5%) > Crit > Strength > Agility > Attack Power",
  rotation = {
    "Battle Shout up; Sunder, Demoralizing Shout, Thunder Clap only if you own them",
    "Overpower whenever a dodge or Bloodthrill enables it",
    "Mortal Strike on cooldown (pool 30 Rage for it)",
    "Keep Rend up: it feeds Bloodthrill Overpower procs",
    "Execute under 20%, but keep Overpower and Mortal Strike ahead of it",
    "Slam as filler when you can finish it (Improved Slam makes it instant)",
    "Spearing Strike first vs Giants, Dragonkin and mounted enemies",
    "Heroic Strike or Hamstring only with spare Rage",
  },
  aoe = {
    "Sweeping Strikes (Battle Stance) when 2+ enemies will live",
    "Whirlwind in Berserker Stance on 3+ enemies (hits up to 4)",
    "On 2 targets: Rend both and Cleave for extra Bloodthrill procs",
    "Cleave instead of Heroic Strike with a second enemy in range",
  },
  tips = {
    "Stay in Battle Stance; Tactical Mastery keeps 10 Rage on swap (25 with Improved)",
    "Reckless Swings when you need Rage and have health to spare",
    "Recklessness, Retaliation and Shield Wall no longer share a cooldown",
    "Swing Rage is normalized to weapon speed; crit auto attacks give double Rage",
    "Victory Rush (level 20) after kills heals 10% max health",
  },
  source = "https://www.icy-veins.com/wow-forever/arms-warrior-melee-dps-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/arms-warrior/ , https://wowhandbook.com/classes/warrior/leveling/
}

ns.SPECGUIDES.WARRIOR["Fury"] = {
  role = "Melee DPS",
  best = { leveling = false, dungeons = true, raid = true, pvp = false },
  summary = "Dual-wield berserker built on Bloodthirst, Whirlwind and Flurry; the PvE Warrior DPS (A-tier). Dual-wield or 2H Fury leveling builds also work without a respec.",
  stats = "Weapon DPS > Hit (8% specials, 27% dual-wield autos) > Expertise (6.5%) > Crit > Strength > Agility",
  rotation = {
    "Battle Shout up; 5 Sunder Armor on the pull if you own the debuff",
    "Whirlwind whenever it is ready, even in the execute phase",
    "Bloodthirst on cooldown (pool 30 Rage without delaying Whirlwind)",
    "Execute under 20%; with 2000+ Attack Power keep Bloodthirst ahead of it",
    "Under 25 Rage, hop to Battle Stance for an Overpower proc (Rend while there)",
    "Hamstring with spare Rage to fish crits for Flurry and Windfury procs",
    "Heroic Strike only with excess Rage",
  },
  aoe = {
    "Whirlwind on cooldown (hits up to 4)",
    "Bloodthirst the main target between Whirlwinds",
    "Cleave instead of Heroic Strike with 2+ enemies",
  },
  tips = {
    "Death Wish + Recklessness is your burst; both make you take more damage",
    "Berserker Rage ignores Fear/Incapacitate; Bloodrage freely for Rage",
    "Keep crits coming: Flurry drops off quickly and takes damage with it",
    "Leveling DW: two fast 1H by DPS; 2H Fury: slowest weapon, Overpower on every proc",
    "Leveling: Victory Rush after every kill, Bloodrage at the start of pulls",
  },
  source = "https://www.icy-veins.com/wow-forever/fury-warrior-melee-dps-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/fury-warrior/ , https://topbuilds.gg/wow-forever/dps-tier-list/
}

ns.SPECGUIDES.WARRIOR["Protection"] = {
  role = "Tank",
  best = { leveling = true, dungeons = true, raid = true, pvp = false },
  summary = "Shield tank: blocks, dodges and parries pay your Rage. wowhandbook's recommended leveling build (5/6/40, no respec) and TopBuilds' S-tier main tank.",
  stats = "Defense: Stamina > Armor > Agility > Avoidance > Defense; Threat: Expertise > Hit (8%) > Agility > Strength",
  rotation = {
    "Defensive Stance; Shield Block on cooldown vs melee (off the GCD)",
    "Shield Slam on cooldown (pool Rage for it)",
    "Revenge whenever a block, dodge or parry enables it",
    "Thunder Clap when ready (works in Defensive Stance, scales with AP)",
    "Keep Rend on the target (scales with AP, extra threat)",
    "Sunder Armor between attacks; Battle Shout and Demoralizing Shout up",
    "Heroic Strike only with excess Rage",
  },
  aoe = {
    "Thunder Clap as mobs arrive: it only hits 4 targets",
    "Tab Revenge, Shield Slam and Sunder onto mobs Thunder Clap missed",
    "Cleave instead of Heroic Strike with 2+ enemies",
    "Challenging Shout for emergencies (works through taunt immunity)",
  },
  tips = {
    "Rage from damage taken ignores your armor and absorb shields in Forever",
    "Last Stand and Shield Wall (15 min) for big hits; Vanguard lets you Charge in Def Stance",
    "Leveling: Charge, Rend, Revenge every proc, Shield Block between swings",
    "Leveling: carry Rage into the next pull; Victory Rush heals 10% per kill",
    "From 40 Block Value adds Shield Slam damage: upgrade your shield",
  },
  source = "https://www.icy-veins.com/wow-forever/protection-warrior-tank-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/protection-warrior/ , https://wowhandbook.com/classes/warrior/leveling/
}

---------------------------------------------------------------------------
-- PALADIN
---------------------------------------------------------------------------
ns.SPECGUIDES.PALADIN = ns.SPECGUIDES.PALADIN or {}

ns.SPECGUIDES.PALADIN["Holy"] = {
  role = "Healer",
  best = { leveling = false, dungeons = true, raid = true, pvp = false },
  summary = "Reactive single-target plate healer: efficient Flash of Light, Holy Light on Infusion of Light, Light's Vigil for AoE, Oath of Light. Holy/Ret hybrid can heal dungeons while leveling.",
  stats = "Healing Power > Intellect > Spirit > Mp5 > Crit",
  rotation = {
    "Keep Oath of Light on the tank (single-target heals also heal a second target)",
    "Seal of Light if no other Paladin has it, else Seal of Wisdom; keep the Judgement up",
    "Flash of Light as your main heal (best healing per mana)",
    "Holy Light on Infusion of Light procs or ahead of known big hits",
    "Light's Vigil before AoE damage, then Holy Shock the same target",
    "Holy Shock when someone may die before a cast lands, or while moving",
    "Lay on Hands only as a last resort (costs all your mana)",
  },
  aoe = {
    "Light's Vigil + Holy Shock is your only AoE heal: expensive, pre-cast it",
  },
  tips = {
    "Divine Favor for a guaranteed crit heal (Illumination refunds mana)",
    "5-second rule: stop-cast unneeded heals; Reverence lets Spirit regen in combat",
    "Coordinate Auras and Blessings (Kings, Might, Wisdom) with other Paladins",
    "Idle: Seal of Righteousness, Judgement, Holy Strike, Consecration, Exorcism",
    "Undead: Cannibalize restores mana in Forever, not only health",
  },
  source = "https://www.icy-veins.com/wow-forever/holy-paladin-healer-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/holy-paladin/ , https://topbuilds.gg/wow-forever/healer-tier-list/
}

ns.SPECGUIDES.PALADIN["Protection"] = {
  role = "Tank",
  best = { leveling = false, dungeons = true, raid = false, pvp = false },
  summary = "Spellblade tank: Seal of Fury (absorbs on hit, Judgement taunts), Consecration, Holy Shield, Holy Strike. Excellent AoE threat for dungeons; the 0/35/16 build also levels.",
  stats = "Stamina > Defense (to 440) > Spell Power > Intellect > Strength; 8% melee hit",
  rotation = {
    "Righteous Fury on at all times",
    "Pre-pull Seal of the Crusader + Judgement if no Ret has it, then Seal of Fury",
    "Keep Consecration down as mana allows",
    "Judgement on cooldown (off the GCD, taunts with Seal of Fury); Swift Judgement too",
    "Holy Shield on cooldown",
    "Holy Strike on cooldown (Shieldsworn makes it trigger Holy Shield)",
    "Exorcism on Undead and Demons",
  },
  aoe = {
    "Consecration: the first 4 enemies take full damage, pull mobs into it",
    "Hammer of the Righteous (lvl 40, 6s cd) hits the target + 3 nearby", -- inferred from wowhandbook spellbook; no guide places it
    "Holy Wrath vs Undead/Demons when you are not taking hits",
  },
  tips = {
    "Off-tanking: swap to Seal of Wisdom/Light so Judgement does not taunt",
    "Templar's Bulwark is your big defensive (Forbearance); bubbles drop threat",
    "Reckoning: let a weak mob stack 4 extra attacks, release them on the boss pull",
    "Solo leveling: use Seal of Righteousness so Judgement does not pull extra mobs",
    "No interrupt; Voice of Truth (lvl 20) makes you immune to silence/interrupts",
  },
  source = "https://www.icy-veins.com/wow-forever/protection-paladin-tank-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/protection-paladin/ , https://wowhandbook.com/classes/paladin/leveling/
}

ns.SPECGUIDES.PALADIN["Retribution"] = {
  role = "Melee DPS",
  best = { leveling = true, dungeons = false, raid = false, pvp = false },
  summary = "Slow 2H with Seal of Command, Holy Strike and Judgement (no longer eats the Seal). Fastest, safest Paladin leveling (12/8/31, no respec); raid DPS trails other specs.",
  stats = "Weapon DPS > Hit (8%) > Expertise (6.5%) > Strength > Spell Power (Shockadin: Spell Power > Crit)",
  rotation = {
    "Judge Seal of the Crusader if the debuff is missing, then Seal of Command",
    "Slow 2H: Seal of Righteousness at 3 Echo of Command, back at 1+ Echo of Righteousness",
    "Hammer of Wrath on targets under 20% (Champion of the Light powers it)",
    "Consecration on cooldown",
    "Judgement on cooldown",
    "Holy Strike on cooldown",
    "Exorcism on Undead and Demons",
  },
  aoe = {
    "Same priority; Crusader Judgement only on the main target",
    "Holy Wrath on cooldown vs several Undead/Demons",
    "Hammer of the Righteous (lvl 40) hits 4 targets", -- inferred from wowhandbook spellbook; no guide places it
  },
  tips = {
    "Leveling 1-21: Seal of Righteousness, Judgement + Holy Strike on cd; Seal of Command from 22",
    "Keep Retribution Aura and Blessing of Might up while leveling",
    "Slowest 2H you can (3.3+); after 40 Intellect adds spell power (Champion of the Light)",
    "Fast weapon (2.9 or faster) reverses the Unsealed Wrath seal swap",
    "Divine Shield now halves your damage; Undead Cannibalize also restores mana",
  },
  source = "https://www.icy-veins.com/wow-forever/retribution-paladin-melee-dps-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/retribution-paladin/ , https://wowhandbook.com/classes/paladin/leveling/
}

---------------------------------------------------------------------------
-- HUNTER
---------------------------------------------------------------------------
ns.SPECGUIDES.HUNTER = ns.SPECGUIDES.HUNTER or {}

ns.SPECGUIDES.HUNTER["Beast Mastery"] = {
  role = "Ranged DPS",
  best = { leveling = true, dungeons = true, raid = true, pvp = false },
  summary = "Pet-centric ranged DPS with Summon Hawk (lvl 25) and Bestial Wrath. Recommended leveling build (35/16/0, pet tanks) and TopBuilds' S-tier group DPS.",
  stats = "Weapon damage > Hit (8%) > Crit > Agility > Intellect (Careful Aim) > Attack Power",
  rotation = {
    "Hunter's Mark, send the pet first; keep Serpent Sting up",
    "Summon Hawk on cooldown, keep 2 hawks out",
    "Aimed Shot on cooldown (pre-cast on the pull; shares cd with Multi-Shot)",
    "Arcane Shot only while 2 hawks will stay up 6+ seconds",
    "Immolation Trap in melee range (traps work in combat, 30s cd)",
    "Rapid Fire and Bestial Wrath on cooldown",
  },
  aoe = {
    "Explosive Trap on cooldown under the pack",
    "Multi-Shot on cooldown; Serpent Sting several targets",
    "Volley for big packs; Multi-Shot while moving",
  },
  tips = {
    "Bestial Discipline keeps 50% of Spirit regen while casting",
    "Leveling: pet in, Mark, Auto Shot; from 16 a Raptor Strike + Immolation Trap melee trip",
    "Don't spend hawk, trap and Sting on a mob about to die: wasted mana",
    "Scorpid Sting is now -2% hit for 20s (does not stack with Insect Swarm)",
    "Tranquilizing Shot removes Enrage/Frenzy; Feign Death drops aggro",
  },
  source = "https://www.warcrafttavern.com/forever/guides/beast-mastery-hunter/",
  -- also: https://www.icy-veins.com/wow-forever/beast-mastery-hunter-ranged-dps-pve-rotation-cooldowns-abilities , https://wowhandbook.com/classes/hunter/leveling/
}

ns.SPECGUIDES.HUNTER["Marksmanship"] = {
  role = "Ranged DPS",
  best = { leveling = false, dungeons = false, raid = false, pvp = false },
  summary = "Petless (Lone Wolf) ranged DPS built on the new Sniper Shot (4s cast, 15s cd), Aimed Shot and Trueshot Aura. Higher ceiling than BM but gear, positioning and mana hungry.",
  stats = "Weapon damage > Hit (8%) > Crit > Agility > Intellect (Careful Aim) > Attack Power",
  rotation = {
    "Hunter's Mark before the pull; pre-cast Sniper Shot",
    "Sniper Shot on cooldown",
    "Aimed Shot on cooldown",
    "Keep Serpent Sting up (also enables Rapid Recuperation regen)",
    "Arcane Shot on cooldown",
    "Immolation Trap in melee range; Rapid Fire on cooldown",
  },
  aoe = {
    "Explosive Trap and Multi-Shot on cooldown",
    "Sniper Shot; Arcane Shot only on 3 or fewer targets",
    "Volley for big packs; Multi-Shot while moving",
  },
  tips = {
    "Lone Wolf: dismiss the pet for damage in endgame PvE; bring one when solo",
    "Rapid Recuperation (50% regen while casting) needs Serpent Sting active",
    "Sniper Shot and Aimed Shot are expensive: watch your mana",
    "Trueshot Aura buffs ranged Attack Power for the raid",
  },
  source = "https://www.warcrafttavern.com/forever/guides/marksmanship-hunter/",
  -- also: https://www.icy-veins.com/wow-forever/marksmanship-hunter-ranged-dps-pve-rotation-cooldowns-abilities
}

ns.SPECGUIDES.HUNTER["Survival"] = {
  role = "Melee DPS",
  best = { leveling = false, dungeons = false, raid = false, pvp = false },
  summary = "Melee-weaving Hunter: shots at range, then Raptor Strike, Mongoose Bite and traps in melee, Strider Kick to reposition. Usually petless via Lone Wolf. High skill cap.",
  stats = "Weapon damage > Hit (8%) > Crit > Agility > Attack Power",
  rotation = {
    "Hunter's Mark; pre-cast Aimed Shot, Serpent Sting while closing in",
    "Immolation Trap in melee range, keep it on cooldown",
    "Summon Hawk on cooldown, keep 2 out",
    "Raptor Strike on cooldown",
    "Mongoose Bite on cooldown",
    "Strider Kick back to range, then Aimed/Arcane Shot again",
    "Rapid Fire on cooldown",
  },
  aoe = {
    "At range: Explosive Trap, Multi-Shot, Volley",
    "In melee: Explosive Trap down, Raptor Strike and Mongoose Bite",
  },
  tips = {
    "Resourcefulness: 50% regen while casting after a crit (pairs with Lethal Attacks)",
    "Movement interrupts Auto Shot: time your melee trips",
    "Improved Tracking: keep the matching tracking up for bonus damage",
  },
  source = "https://www.icy-veins.com/wow-forever/survival-hunter-melee-dps-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/survival-hunter/
}

---------------------------------------------------------------------------
-- ROGUE
---------------------------------------------------------------------------
ns.SPECGUIDES.ROGUE = ns.SPECGUIDES.ROGUE or {}

ns.SPECGUIDES.ROGUE["Assassination"] = {
  role = "Melee DPS",
  best = { leveling = false, dungeons = false, raid = false, pvp = false },
  summary = "Reworked poison spec: poisons can crit, Venom finisher (+30% poison damage), Mutilate with two daggers, Improved Expose Armor refunds Combo Points. Complex and gear-dependent.",
  stats = "Expertise (6.5%) > Hit (8%) > Agility > Weapon damage > Crit",
  rotation = {
    "Open from Stealth (Ambush per WT, Garrote per Icy Veins)",
    "Mutilate to build (Sinister Strike for the 5th point to save Energy)",
    "Shank on cooldown for Venom uptime, without capping Energy",
    "5 CP: Expose Armor if no stronger armor debuff (Improved refunds 2 CP)",
    "5 CP: Slice and Dice, then Venom; refresh whichever is about to drop",
    "Spare 5 CP: Eviscerate (Kidney Shot on stunnable bosses)",
    "Vanish + Ambush or Cold Blood + Mutilate for burst",
  },
  aoe = {
    "No AoE: kill one mob at a time and never switch targets holding Combo Points",
  },
  tips = {
    "Instant + Deadly Poison by default; Improved Poisons saves charges",
    "Energy regen is smooth (1 per 0.1s); never build at 5 Combo Points",
    "Thistle Tea for a burst of Energy; Feint now drops twice the threat",
    "Sources differ on Rupture: Icy Veins keeps it up on long fights, WT skips it",
  },
  source = "https://www.warcrafttavern.com/forever/guides/assassination-rogue/",
  -- also: https://www.icy-veins.com/wow-forever/assassination-rogue-melee-dps-pve-rotation-cooldowns-abilities
}

ns.SPECGUIDES.ROGUE["Combat"] = {
  role = "Melee DPS",
  best = { leveling = true, dungeons = true, raid = true, pvp = false },
  summary = "Sinister Strike, Riposte, Blade Flurry and the new Adrenaline Rush capstone; Hack and Slash merges the weapon specs. Recommended leveling (16/35/0) and A-tier DPS.",
  stats = "Expertise (6.5%) > Hit (8%) > Agility > Weapon damage > Crit",
  rotation = {
    "Open from Stealth: Garrote or Cheap Shot (Ambush with daggers)",
    "Slice and Dice at 5 CP, refresh when it expires",
    "Expose Armor on long fights if you own the armor debuff",
    "Shank on cooldown unless it would cap Energy",
    "Sinister Strike to build (Backstab in the dagger variant); Riposte when lit",
    "Spare 5 CP: Eviscerate",
    "Blade Flurry and Adrenaline Rush on cooldown, together",
  },
  aoe = {
    "Blade Flurry is your only AoE: every attack hits one extra target",
    "Never switch targets while holding Combo Points",
  },
  tips = {
    "Leveling: Sinister Strike on cd, Eviscerate to finish; Slice and Dice if the next pull is close",
    "Replace the starter dagger with a sword, mace, axe or fist weapon ASAP",
    "Sap no longer breaks Stealth; Distract also lowers enemy stealth detection",
    "Shank (24) and Flash of Steel (37) are your extra Energy sources",
  },
  source = "https://www.warcrafttavern.com/forever/guides/combat-rogue/",
  -- also: https://www.icy-veins.com/wow-forever/combat-rogue-melee-dps-pve-rotation-cooldowns-abilities , https://wowhandbook.com/classes/rogue/leveling/
}

ns.SPECGUIDES.ROGUE["Subtlety"] = {
  role = "Melee DPS",
  -- pvp flag: TopBuilds names Rogue the best PvP class without picking a spec; Subtlety chosen from Classic convention
  best = { leveling = false, dungeons = false, raid = false, pvp = true }, -- unverified: classic
  summary = "Stealth and burst: Ghostly Strike, Hemorrhage, Premeditation, Preparation and the new Death Mark finisher (stores damage, explodes after 6s). Ambush or Bleed builds.",
  stats = "Weapon damage > Expertise (6.5%) > Hit (8%) > Weapon Skill > Agility",
  rotation = {
    "Poisons: Instant on main hand, Deadly on off hand",
    "Open from Stealth: Premeditation, then Ambush or Garrote",
    "Keep Rupture, Death Mark and Slice and Dice up (5 CP each)",
    "Shank on cooldown at 0-3 CP (Boot Knife can add 2)",
    "Ghostly Strike on cooldown, then Garrote/Ambush (Initiative adds CP)",
    "Hemorrhage as your main builder",
    "Spare 5 CP: Eviscerate; Vanish or Preparation for extra burst",
  },
  aoe = {
    "No AoE: single-target one mob at a time, never switch with Combo Points",
  },
  tips = {
    "Pool Energy for Death Mark windows; never overcap Energy or Combo Points",
    "Stand behind the boss: frontal dodge/parry penalties are high",
    "Master of Deception helps sneak past dangerous mobs",
    "Keep Rupture and Garrote near 100% uptime (bleeds ignore armor)",
  },
  source = "https://www.icy-veins.com/wow-forever/subtlety-rogue-melee-dps-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/subtlety-rogue/
}

---------------------------------------------------------------------------
-- PRIEST
---------------------------------------------------------------------------
ns.SPECGUIDES.PRIEST = ns.SPECGUIDES.PRIEST or {}

ns.SPECGUIDES.PRIEST["Discipline"] = {
  role = "Healer",
  best = { leveling = false, dungeons = true, raid = true, pvp = false },
  summary = "Shield and tank healer: Soul Warding, Penance, Renewed Hope, Divine Aegis and Power Infusion (+20% spell power/healing). Strong, safe dungeon and tank healer.",
  stats = "Healing Power > Mp5 > Spirit > Intellect > Crit",
  rotation = {
    "Power Word: Shield the tank (and casters) to stop pushback and buy time",
    "Renew on targets taking steady damage",
    "Penance for burst single-target healing",
    "Flash Heal for quick heals; Lesser Heal/Heal for efficient filler",
    "Greater Heal + Inner Focus before known big hits",
    "Prayer of Healing when a party is hurt (heals the targeted party)",
    "Holy Nova when Searing Light procs and nobody is in danger",
  },
  aoe = {
    "Prayer of Healing heals whichever party you target, pets included",
  },
  tips = {
    "Power Infusion on your best caster, or yourself in emergencies",
    "Meditation keeps 50% mana regen while casting",
    "Fade sheds twice the threat; Renew from several Priests now stacks",
    "Mouseover healing is built in: Options > Combat",
  },
  source = "https://www.warcrafttavern.com/forever/guides/discipline-priest/",
  -- also: https://www.icy-veins.com/wow-forever/discipline-priest-healer-pve-rotation-cooldowns-abilities
}

ns.SPECGUIDES.PRIEST["Holy"] = {
  role = "Healer",
  best = { leveling = false, dungeons = true, raid = true, pvp = false },
  summary = "Raid healer with Holy Binding (Flash Heal heals you too), Spiritual Guidance, Litany of Light and the Prayer of Mending capstone. TopBuilds' S-tier healer.",
  stats = "Healing Power > Mp5 > Spirit > Intellect > Crit",
  rotation = {
    "Renew everyone taking steady damage (stacks across Priests)",
    "Power Word: Shield to buy time and stop pushback",
    "Flash Heal for quick heals (Holy Binding heals you as well)",
    "Lesser Heal/Heal as efficient filler",
    "Greater Heal + Inner Focus before big hits",
    "Prayer of Mending, Prayer of Healing or Holy Nova for group damage",
    "Mix spells: Litany of Light rewards not spamming one heal",
  },
  aoe = {
    "Prayer of Mending bounces to injured allies; Prayer of Healing for a party",
    "Holy Nova on Searing Light procs",
  },
  tips = {
    "Meditation keeps 50% regen while casting; Spiritual Guidance turns Spirit into healing",
    "Abolish Disease and Dispel Magic when it matters; Fear Ward is baseline now",
    "Fade early if threat climbs",
    "Mouseover healing is built in: Options > Combat",
  },
  source = "https://www.warcrafttavern.com/forever/guides/holy-priest/",
  -- also: https://www.icy-veins.com/wow-forever/holy-priest-healer-pve-rotation-cooldowns-abilities
}

ns.SPECGUIDES.PRIEST["Shadow Magic"] = {
  role = "Caster DPS",
  best = { leveling = true, dungeons = false, raid = false, pvp = false },
  summary = "DoT caster: Shadowform, Mind Flay, Devouring Plague (baseline at 20), Shadow Word: Death (32) and Vampiric Embrace self-healing. Recommended leveling spec (17/3/31).",
  stats = "Hit (17%) > Spell Power > Crit > Spell Penetration > Spirit",
  rotation = {
    "Pre-cast Fade, then Mind Blast into the pull",
    "Keep Shadow Word: Pain up",
    "Keep Devouring Plague up",
    "Mind Blast on cooldown",
    "Shadow Word: Death on cooldown (backlash if the target survives)",
    "Keep Vampiric Embrace up (party heals for 10% of your Shadow damage, you for double)",
    "Mind Flay filler; don't clip it (Improved Mind Flay favors the 3rd tick)",
  },
  aoe = {
    "Shadow Word: Pain on every target: most of your AoE",
    "Devouring Plague on the lowest-health target",
    "Mind Blast and Shadow Word: Death only below 4 targets",
  },
  tips = {
    "Leveling 1-24: Shield + Renew pre-pull, Shadow Word: Pain, then wand (never Smite)",
    "From 25: Pain on 2-3 mobs; Spirit Tap refills mana on each kill",
    "Avoid long heals: they stop regen and drop Shadowform (42)",
    "Devouring Contagion can spread Devouring Plague",
    "Undead: Dark Sacrifice turns health into mana",
  },
  source = "https://www.warcrafttavern.com/forever/guides/shadow-priest/",
  -- also: https://www.icy-veins.com/wow-forever/shadow-priest-ranged-dps-pve-rotation-cooldowns-abilities , https://wowhandbook.com/classes/priest/leveling/
  -- Vampiric Embrace 10% (was 20%), caster gets 100% more (Nov 16 notes, live with weekly maintenance): https://us.forums.blizzard.com/en/wow/t/2403040
}

---------------------------------------------------------------------------
-- SHAMAN
---------------------------------------------------------------------------
ns.SPECGUIDES.SHAMAN = ns.SPECGUIDES.SHAMAN or {}

ns.SPECGUIDES.SHAMAN["Elemental Combat"] = {
  role = "Caster DPS",
  best = { leveling = false, dungeons = false, raid = false, pvp = false },
  summary = "Lightning caster: Lightning Bolt and Chain Lightning with Lightning Overload duplicates, Call of Thunder crit and Lightning Mastery bursts, plus Flame Shock. Good AoE and group buffs, but mana can run short.",
  stats = "Spell Power > Hit (17%) > Crit > Intellect > Mp5",
  rotation = {
    "Pre-place totems with Call of the Elements (Searing Totem last)",
    "Flame Shock the target; refresh it when it falls off",
    "Lightning Mastery with trinkets, racials and potions",
    "Chain Lightning when mana allows (no cooldown during Lightning Mastery)",
    "Lightning Bolt as filler",
  },
  aoe = {
    "Magma Totem in range; Fire Nova on cooldown (bursts at your Fire totem)",
    "Chain Lightning on cooldown as mana allows",
    "Flame Shock targets that lack it",
    "Totemic Call (lvl 22) teleports your totems to you (30s cooldown)",
  },
  tips = {
    "Lava Burst was removed in beta; Call of Thunder (+5% Lightning crit) took its place",
    "Lightning Overload: 10/20/30% chance to trigger a duplicate spell",
    "Elemental Focus procs make your next spell free",
    "Water Shield returns mana from crits; Mana Tide Totem for long fights",
    "Windfury Totem is a party buff now and gets you invites",
    "Buff totems last 5 min, weapon imbues 60 min",
  },
  source = "https://www.icy-veins.com/wow-forever/elemental-shaman-ranged-dps-pve-rotation-cooldowns-abilities",
  -- Lava Burst -> Call of Thunder, Lightning Mastery, Totemic Call: https://us.forums.blizzard.com/en/wow/t/2360696 (Nov 3 notes)
}

ns.SPECGUIDES.SHAMAN["Enhancement"] = {
  role = "Melee DPS",
  best = { leveling = true, dungeons = false, raid = false, pvp = false },
  summary = "Slow 2H melee built around Windfury, with Stormstrike (damage and mana), Maelstrom Weapon instant Lightning Bolts and Rage of the Farseer. Recommended leveling spec (6/34/11); brings Windfury Totem.",
  stats = "Weapon DPS > Hit (8%) > Expertise > Strength > Intellect > Spell Power",
  rotation = {
    "Windfury Weapon + Lightning Shield; Call of the Elements for totems",
    "Totems: Strength of Earth, Magma (Searing if low mana), Mana Spring, Windfury",
    "Keep Flame Shock on the target",
    "Rage of the Farseer with trinkets and racials",
    "Stormstrike on cooldown",
    "Lightning Bolt at 5 Maelstrom Weapon stacks",
    "Earth Shock filler; Fire Nova with a Fire totem down",
  },
  aoe = {
    "Magma Totem and Fire Nova on cooldown",
    "Cycle Flame Shock across targets",
    "Keep Stormstrike and 5-stack Lightning Bolt going; mana heavy",
  },
  tips = {
    "Leveling 10-24: Lightning Shield, Flame Shock + Searing Totem, Earth Shock",
    "Before 30 use Flametongue or Rockbiter; Windfury Weapon from 30",
    "Since Nov 10 weapon imbues and weapon totems stack: Windfury Weapon and Windfury Totem both proc",
    "Stormstrike: 100% weapon damage, 8s cooldown (Nov 10)",
    "Maelstrom Weapon: 20% per stack, procs 6-10 times a minute by rank; melee does most of your damage",
    "Mental Dexterity turns 33/66/100% of Intellect into Attack Power (was 50/100/150%); Strength first",
  },
  source = "https://www.icy-veins.com/wow-forever/enhancement-shaman-melee-dps-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/enhancement-shaman/ , https://wowhandbook.com/classes/shaman/leveling/
  -- Nov 10 Enhancement changes: https://us.forums.blizzard.com/en/wow/t/2403040
}

ns.SPECGUIDES.SHAMAN["Restoration"] = {
  role = "Healer",
  best = { leveling = false, dungeons = true, raid = true, pvp = false },
  summary = "Riptide + Chain Heal healer with Mana Tide, Nature's Swiftness and party totems. Simple and efficient; TopBuilds ranks it B but totems make it a raid staple.",
  stats = "Healing Power > Crit > Intellect > Spirit > Mp5",
  rotation = {
    "Pre-place totems with Call of the Elements",
    "Riptide the most injured target on cooldown",
    "Chain Heal a Riptided target when others nearby are hurt",
    "Healing Wave (downranked) for steady damage",
    "Lesser Healing Wave when a heal can't wait",
    "Healing Stream Totem if your Water slot is free",
    "Lightning Bolt when healing is quiet and mana allows",
  },
  aoe = {
    "Chain Heal off a Riptide target",
    "Fire Nova and Chain Lightning for damage when no one needs healing",
  },
  tips = {
    "Mindfulness keeps 50% regen while casting",
    "Water Shield procs mana from healing crits",
    "Place Mana Tide Totem where other healers benefit",
    "Nature's Swiftness + Healing Wave for emergencies; Tremor Totem vs fear",
  },
  source = "https://www.warcrafttavern.com/forever/guides/restoration-shaman/",
  -- also: https://www.icy-veins.com/wow-forever/restoration-shaman-healer-pve-rotation-cooldowns-abilities
}

---------------------------------------------------------------------------
-- MAGE
---------------------------------------------------------------------------
ns.SPECGUIDES.MAGE = ns.SPECGUIDES.MAGE or {}

ns.SPECGUIDES.MAGE["Arcane"] = {
  role = "Caster DPS",
  best = { leveling = false, dungeons = false, raid = false, pvp = false },
  summary = "Arcane Blast stacking (18s cycle), Missile Barrage, the new Arcane Wrath (scales with max mana) and Fire Blast/Pyroblast weaving. Big scaler, hardest mana management.",
  stats = "Hit (17%) > Spell Power > Crit > Intellect > Spirit > Mp5",
  rotation = {
    "Arcane Blast to build stacks (18s cycle); spend Arcane Concentration on it",
    "Arcane Missiles on Missile Barrage (ideally at 2+ Blast stacks)",
    "Arcane Wrath at 3-4 Blast stacks depending on mana",
    "Fire Blast at 1-2 and at 4 stacks to build Heating Up and Ignite",
    "Pyroblast at 3 Heating Up while 3-4 Blast stacks are up",
    "Arcane Power at 4 stacks; Presence of Mind on Arcane Wrath or Pyroblast",
    "Let stacks drop, restart with Arcane Blast",
  },
  aoe = {
    "Arcane Explosion spam",
    "Flamestrike on the pack, Presence of Mind Flamestrike when it ends",
  },
  tips = {
    "Arcane Meditation is mandatory (50% regen while casting)",
    "Arcane Power raises mana cost by 30%: use it with care",
    "Polymorph extra mobs, Remove Lesser Curse dangerous curses",
    "Leveling: Arcane to 39 (wand + free Missiles), then respec Frost at 40",
  },
  source = "https://www.warcrafttavern.com/forever/guides/arcane-mage/",
  -- also: https://www.icy-veins.com/wow-forever/arcane-mage-ranged-dps-pve-rotation-cooldowns-abilities
}

ns.SPECGUIDES.MAGE["Fire"] = {
  role = "Caster DPS",
  best = { leveling = false, dungeons = false, raid = true, pvp = false },
  summary = "Crit-driven: Heating Up (3 stacks = fast Pyroblast), per-Mage Ignite, Improved Scorch, Combustion. Top burst and scaling, bad leveling. Frostfire Bolt variant uses Shatter.",
  stats = "Hit (17%) > Spell Power > Crit > Intellect > Spirit > Mp5",
  rotation = {
    "Pre-cast Pyroblast on bosses",
    "Scorch to 5 Improved Scorch stacks, refresh before it falls",
    "Fire Blast on cooldown (a crit gives 2 Heating Up stacks)",
    "Pyroblast at 3 Heating Up stacks",
    "Combustion for burst",
    "Arcane Missiles on Missile Barrage",
    "Filler: Fireball (Frostfire Bolt build: Frostfire Bolt, Ice Lance on Fingers of Frost)",
  },
  aoe = {
    "Flamestrike no longer stacks: recast as the 8s area ends",
    "Blast Wave on cooldown, then Cone of Cold",
    "Arcane Explosion between",
  },
  tips = {
    "Improved Scorch and Ignite only boost the Mage who applied them",
    "Burning Soul cuts threat by 30% and reduces pushback",
    "No Ice Block: rely on positioning, Frost Nova and Blink",
    "Master of Elements refunds mana on Fire/Frost crits",
  },
  source = "https://www.warcrafttavern.com/forever/guides/fire-mage/",
  -- also: https://www.icy-veins.com/wow-forever/fire-mage-ranged-dps-pve-rotation-cooldowns-abilities , https://topbuilds.gg/wow-forever/dps-tier-list/
}

ns.SPECGUIDES.MAGE["Frost"] = {
  role = "Caster DPS",
  -- pvp: TopBuilds lists Mage among the best PvP classes; Frost picked for its control and survivability
  best = { leveling = true, dungeons = true, raid = false, pvp = true },
  summary = "Control and burst: Frostbolt, Winter's Chill + Cone of Cold, Ice Lance on Fingers of Frost/Frostbite, Ice Barrier (+Frost damage). Best leveling and farming spec.",
  stats = "Hit (17%) > Spell Power > Crit > Intellect > Mp5 > Spirit",
  rotation = {
    "Arcane Intellect; Mage Armor in groups, Ice/Frost Armor solo",
    "Ice Barrier before the pull; recast when Frigid Power has under 3s",
    "Pre-cast Frostbolt; Frostbolt is your main spell",
    "At 5 Winter's Chill stacks batch Cone of Cold with your next Frostbolt",
    "Ice Lance on Fingers of Frost or Frostbite freezes (Frost Nova if no procs)",
    "Arcane Missiles on Missile Barrage",
    "Counterspell dangerous casts; Polymorph extra mobs",
  },
  aoe = {
    "Cone of Cold on cooldown, Cold Snap to reset it",
    "Blizzard as filler (Improved Blizzard slow is capped at 40%)",
    "Solo: Ice Barrier, gather, Cone of Cold, Frost Nova, Blink, Blizzard, repeat",
  },
  tips = {
    "Leveling plan: Arcane to 39, respec Frost at 40 (18/0/33)",
    "Cone of Cold slows less in Forever: kite big packs carefully",
    "Ice Block clears DoTs, diseases and bleeds",
    "Drink while waiting for respawns, not between every pull",
  },
  source = "https://www.icy-veins.com/wow-forever/frost-mage-ranged-dps-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/frost-mage/ , https://wowhandbook.com/classes/mage/leveling/
}

---------------------------------------------------------------------------
-- WARLOCK
---------------------------------------------------------------------------
ns.SPECGUIDES.WARLOCK = ns.SPECGUIDES.WARLOCK or {}

ns.SPECGUIDES.WARLOCK["Affliction"] = {
  role = "Caster DPS",
  best = { leveling = true, dungeons = false, raid = false, pvp = false },
  summary = "DoT spec with the new Wrack channel (your DoTs tick 100% faster while you channel it), Banes in their own slot and Nightfall procs. The drain-tank build (41/10/0) is the recommended way to level.",
  stats = "Hit (17%) > Spell Power > Crit > Haste > Intellect",
  rotation = {
    "Pre-pull: sacrifice the Imp (Demonic Sacrifice), open with Shadow Bolt",
    "Bane of Agony (Amplify Curse when ready); Bane of Doom only in SM Ruin",
    "Your assigned Curse (Elements for casters, Recklessness for melee)",
    "Corruption, then Siphon Life",
    "Shadow Bolt only on Shadow Trance (Nightfall) procs",
    "Life Tap under ~40% mana, at the end of a Wrack channel",
    "Wrack (6s channel) between DoT refreshes; break it when something above is due",
  },
  aoe = {
    "2 targets: Corruption (+Agony, Siphon Life if 30s+) on the second via focus macro",
    "3+: Hellfire once the tank has them; Rain of Fire if standing in is unsafe",
    "Corruption on quick-dying mobs, Agony on long-lived ones",
  },
  tips = {
    "Life Tap scales with Spirit (424 + Spirit health into mana)",
    "Refresh DoTs as they expire, never early",
    "Soul Siphon: Drain Life, Drain Soul and Wrack gain 4/8/12% per DoT on the target (max 36%)",
    "Leveling: Corruption everything, wand before 30, then Drain Life tank; Fear the 2nd mob",
    "Pets: Voidwalker 10-19, Succubus/Incubus from 20, Felhunter vs casters",
    "Keep a Limited Invulnerability Potion for Hellfire pulls",
  },
  source = "https://www.warcrafttavern.com/forever/guides/affliction-warlock/",
  -- also: https://www.icy-veins.com/wow-forever/affliction-warlock-ranged-dps-pve-rotation-cooldowns-abilities , https://wowhandbook.com/classes/warlock/leveling/
  -- Nov 10 Wrack / Soul Siphon changes: https://us.forums.blizzard.com/en/wow/t/2403040 , https://wowhandbook.com/classes/warlock/talents/
}

ns.SPECGUIDES.WARLOCK["Demonology"] = {
  role = "Caster DPS",
  best = { leveling = false, dungeons = false, raid = false, pvp = false },
  summary = "Demon spec: Demonic Knowledge, Demonic Brand (Searing Pain marks for the pet), Demonic Pact keeps your Sacrifice buff, Decimation Soul Fire. Fire (Imp) or Shadow (Sayaad) build.",
  stats = "Hit (17%) > Spell Power > Crit > Haste > Intellect",
  rotation = {
    "Open with Soul Fire landing as the tank arrives; send the demon with it",
    "Searing Pain when Demonic Brand is missing from the pet's target",
    "Bane (Doom if 60s+ of fight left, else Agony) and your assigned Curse",
    "Immolate",
    "Soul Fire during Decimation (Fire build only)",
    "Corruption",
    "Life Tap in gaps, or when the Imp is low on mana",
    "Filler: Searing Pain (Fire build) or Shadow Bolt (Shadow build)",
  },
  aoe = {
    "Bane of Agony every mob as they run in (skip Corruption, it has a cast)",
    "3+ mobs: Hellfire once the tank has them; Rain of Fire from range",
    "Shadow build: for long AoE runs sacrifice the Sayaad and summon the Imp",
  },
  tips = {
    "Demonic Energies passes Life Tap mana to your demon",
    "Demons scale with your stats in Forever",
    "Leveling (15/31/5): pet + Corruption, wand, Drain Soul before kills for Soul Harvest",
    "Leveling stats: Spirit, then Stamina over Intellect (health is mana via Life Tap)",
  },
  source = "https://www.warcrafttavern.com/forever/guides/demonology-warlock/",
  -- also: https://www.icy-veins.com/wow-forever/demonology-warlock-ranged-dps-pve-rotation-cooldowns-abilities
}

ns.SPECGUIDES.WARLOCK["Destruction"] = {
  role = "Caster DPS",
  best = { leveling = false, dungeons = true, raid = true, pvp = false },
  summary = "Fire burst with the new Incinerate filler (+25% on Immolated targets), Conflagrate, Shadowburn and Bane of Havoc cleave. Strong burst and AoE, little mobility.",
  stats = "Hit (17%) > Spell Power > Haste > Crit > Intellect",
  rotation = {
    "Pre-cast Soul Fire as the tank pulls (keep 2+ Soul Shards)",
    "Bane (Doom if 60s+ left, else Amplify Curse + Agony) and your Curse",
    "Immolate",
    "Corruption",
    "Conflagrate (needs Immolate on the target)",
    "Shadowburn (needs a Soul Shard)",
    "Life Tap in short gaps or while moving",
    "Incinerate as filler",
  },
  aoe = {
    "2 targets: Bane of Havoc on the second (takes 15% of main-target damage)",
    "Packs: Havoc on one, Agony on the rest, then Hellfire on 3+",
    "Rain of Fire when standing in the pack is unsafe",
  },
  tips = {
    "Conflagrate (10s) and Shadowburn (15s) keep Shadow and Flame buffs up",
    "Firestone is now a weapon imbue that stacks with Wizard Oil",
    "Curse of Recklessness only lowers armor now; Elements covers all magic",
    "Hellfire burns you too and can pull mobs off the tank",
  },
  source = "https://www.warcrafttavern.com/forever/guides/destruction-warlock/",
  -- also: https://www.icy-veins.com/wow-forever/destruction-warlock-ranged-dps-pve-rotation-cooldowns-abilities , https://topbuilds.gg/wow-forever/dps-tier-list/
}

---------------------------------------------------------------------------
-- DRUID
---------------------------------------------------------------------------
ns.SPECGUIDES.DRUID = ns.SPECGUIDES.DRUID or {}

ns.SPECGUIDES.DRUID["Balance"] = {
  role = "Caster DPS",
  best = { leveling = false, dungeons = false, raid = false, pvp = false },
  summary = "Moonkin caster: Moonfire + Insect Swarm DoTs and Eclipse (Wrath charges speed up Starfire). Brings raid spell crit, Rebirth and Innervate; damage still taking shape (C tier).",
  stats = "Hit (17%) > Crit > Spell Power > Intellect",
  rotation = {
    "Pre-cast Wrath to land as the boss is pulled",
    "Insect Swarm, then Moonfire; keep both up, don't refresh early",
    "Wrath, then 2 Starfire (each Wrath gives 2 Eclipse charges)",
    "Repeat, re-applying DoTs only as they fall off",
  },
  aoe = {
    "2-4 targets: DoT every enemy, Wrath + 2 Starfire on the priority target",
    "5+ targets: channel Hurricane",
  },
  tips = {
    "Improved Wrath and Moonglow keep you out of mana trouble",
    "Moonkin Form doubles Omen of Clarity procs and buffs raid spell crit",
    "Innervate a high-Spirit target; Rebirth is the only battle res",
    "Tranquility for heavy party-wide damage",
  },
  source = "https://www.icy-veins.com/wow-forever/balance-druid-ranged-dps-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/balance-druid/
}

ns.SPECGUIDES.DRUID["Feral Combat"] = {
  role = "Melee DPS", -- also the Druid tank spec (bear)
  best = { leveling = true, dungeons = true, raid = false, pvp = false },
  summary = "Cat DPS and bear tank in one tree: Shifting Power (mana as Energy), Primal Bite, Lacerate, Leader of the Pack. Recommended leveling (9/31/11); 0/46/5 bear, 0/41/10 cat.",
  stats = "Cat: Weapon DPS > Expertise (6.5%) > Hit (8%) > Agility > Strength; Bear: Armor > Defense (440) > Stamina",
  rotation = {
    "Cat: Mark of the Wild, Thorns and Faerie Fire (free in form) up",
    "Cat: Rip at 5 CP if missing; Rake if missing",
    "Cat: Ferocious Bite at 5 CP with 70+ Energy and 4s+ left on Rip",
    "Cat: Shifting Power at ~50 Energy or less; spend Omen of Clarity on Shred",
    "Cat: build with Shred from behind (Claw if you can't)",
    "Bear: Faerie Fire + Demoralizing Roar up, Primal Bite on cooldown",
    "Bear: Lacerate to 5 stacks and refresh; Maul at 35+ Rage",
  },
  aoe = {
    "Bear: Primal Bite, Swipe, Maul with spare Rage; Faerie Fire many targets",
    "Bear: Challenging Roar to grab a loose pack",
    "Cat: no real AoE; spend Combo Points before switching targets",
  },
  tips = {
    "Forms now use your weapon DPS: weapon and enchant upgrades matter",
    "Potions, racials and most doors work in form; Tiger's Fury is gone",
    "Leveling: Shred (Ravage from 32) from Stealth, Rake + Faerie Fire, Bite at 5 CP",
    "Leveling: Bear Form for bad pulls; save shapeshifts, not mana",
  },
  source = "https://www.icy-veins.com/wow-forever/feral-druid-melee-dps-and-tank-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/feral-druid/ , https://wowhandbook.com/classes/druid/leveling/
}

ns.SPECGUIDES.DRUID["Restoration"] = {
  role = "Healer",
  best = { leveling = false, dungeons = true, raid = true, pvp = false },
  summary = "HoT healer: Rejuvenation, Regrowth, Swiftmend, Bloom and the Wild Growth capstone; Reflection keeps regen while casting. A-tier healer with Innervate and Rebirth.",
  stats = "Healing Power > Intellect > Spirit > Mp5 > Crit",
  rotation = {
    "Keep Rejuvenation and Regrowth on active tanks",
    "Swiftmend a target with Rejuvenation/Regrowth that needs fast healing",
    "Regrowth on anyone who took real damage",
    "Wild Growth when a party is hurt (only the targeted group; use on Omen of Clarity)",
    "Healing Touch at the right rank for damage your HoTs don't cover",
    "Insect Swarm on the boss (lowers its hit); Wrath during downtime",
  },
  aoe = {
    "Wild Growth on the hurt party",
    "Tranquility (Improved Tranquility makes it usable every fight)",
  },
  tips = {
    "Nature's Swiftness + Healing Touch for emergencies",
    "Wild Growth: 3s cast, can't be cast while moving; healing coefficient doubled to 6.6% (Nov 13)",
    "5-second rule: pause casting to regen when healing isn't needed",
    "Nature's Splendor (Balance) extends your HoTs",
    "Innervate yourself or a high-Spirit healer",
  },
  source = "https://www.icy-veins.com/wow-forever/restoration-druid-healer-pve-rotation-cooldowns-abilities",
  -- also: https://www.warcrafttavern.com/forever/guides/restoration-druid/
  -- Wild Growth coefficient / no casting while moving (Nov 13): https://us.forums.blizzard.com/en/wow/t/2403040
}

---------------------------------------------------------------------------
-- Aliases: lookups by the shorter tab names resolve to the same guide without
-- adding extra keys (pairs() still sees exactly 3 specs per class).
---------------------------------------------------------------------------
do
  local aliases = {
    PRIEST = { ["Shadow"] = "Shadow Magic" },
    SHAMAN = { ["Elemental"] = "Elemental Combat" },
    DRUID  = { ["Feral"] = "Feral Combat" },
  }
  for class, map in pairs(aliases) do
    local t = ns.SPECGUIDES[class]
    if t and not getmetatable(t) then
      setmetatable(t, { __index = function(_, k)
        local real = map[k]
        return real and rawget(t, real) or nil
      end })
    end
  end
end
