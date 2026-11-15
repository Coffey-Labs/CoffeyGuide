local _, ns = ...

-- Stat weights for the gear advisor, WoW Forever (client 1.60.1).
-- endgame: numeric weights from wowhandbook.com/classes/<class>/stat-priority/ (the same weights its /bis/<class>/
--   sheets rank items by; data from client 1.60.1.70938), converted to schema keys and normalised so the primary
--   stat = 1.0. Primary stat: STR (Warrior/Ret/Enh DPS), AGI (Hunter/Rogue/Feral), STA (tanks), SP (caster DPS),
--   HEAL (healers). Source Hit/Crit for casters and healers map to SPELLHIT/SPELLCRIT; source 'Attack Power' -> AP
--   (and RAP for Hunters); source 'Weapon DPS' -> DPS. Single-school damage (e.g. +Shadow Damage) and Spell
--   Penetration have no schema key; their source weights are noted in comments. Expertise (Forever stat) has no key.
--   Keys marked '-- added' are not in the wowhandbook table and come from the cited page text / icy-veins.
-- leveling: wowhandbook only publishes "same weights + a little extra Stamina" for leveling, so these tables are
--   derived from the class leveling pages' stat priorities (wowhandbook + icy-veins.com/wow-forever) -- derived from priority.
--   Per 1 point; HIT/CRIT/SPELLHIT/SPELLCRIT/DODGE/PARRY/BLOCK per 1%.

ns.WEIGHTS = ns.WEIGHTS or {}

-- WARRIOR ---------------------------------------------------------------
ns.WEIGHTS.WARRIOR = ns.WEIGHTS.WARRIOR or {}
ns.WEIGHTS.WARRIOR["Arms"] = {
  -- derived from priority: weapon (slow, high top end) > Str/AP > Stamina > crit > Agi; little hit needed vs same-level mobs
  leveling = { STR = 1.0, AGI = 0.45, STA = 0.7, SPI = 0.1, AP = 0.5, HIT = 6.0, CRIT = 12.0, DPS = 7.0, ARMOR = 0.01 },
  -- wowhandbook Arms weights (AP = 1 in source); Forever: Agility gives crit/armor but no melee AP for Warriors; normalised STR = 1.0 (source STR = 2.2)
  endgame  = { STR = 1.0, AGI = 0.83, STA = 0.18, AP = 0.45, HIT = 20.86, CRIT = 15.02, DPS = 6.36 },
  source = "https://wowhandbook.com/classes/warrior/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/warrior/leveling/, https://www.icy-veins.com/wow-forever/arms-warrior-leveling
}
ns.WEIGHTS.WARRIOR["Fury"] = {
  -- derived from priority: weapons > Str/AP > Stamina > crit > Agi; dual wield makes hit a bit better than for Arms
  leveling = { STR = 1.0, AGI = 0.5, STA = 0.7, SPI = 0.1, AP = 0.5, HIT = 7.0, CRIT = 13.0, DPS = 7.0, ARMOR = 0.01 },
  -- wowhandbook Fury weights (AP = 1 in source); normalised STR = 1.0 (source STR = 2.2)
  endgame  = { STR = 1.0, AGI = 1.02, STA = 0.18, AP = 0.45, HIT = 10.41, CRIT = 18.58, DPS = 6.36 },
  source = "https://wowhandbook.com/classes/warrior/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/warrior/leveling/, https://www.icy-veins.com/wow-forever/fury-warrior-leveling
}
ns.WEIGHTS.WARRIOR["Protection"] = {
  -- derived from priority: weapon DPS (speed irrelevant) > Str/AP > Stamina > Agi (dodge = rage); Block Value from 40
  leveling = { STR = 1.0, AGI = 0.5, STA = 0.9, SPI = 0.1, AP = 0.5, HIT = 7.0, CRIT = 9.0, DPS = 6.0, ARMOR = 0.02, DEF = 0.6, DODGE = 4.0, PARRY = 3.0, BLOCK = 1.5, BLOCKVALUE = 0.3 },
  -- wowhandbook Prot weights; DEF 15/pt is the source's push to 440 defense (crit immunity) and dominates scores; normalised STA = 1.0 (source STA = 1)
  -- DODGE added: not in wowhandbook Warrior table; scaled like its Prot Paladin Dodge/Parry (per 1%)
  -- PARRY added: as DODGE
  -- BLOCK added: icy-veins defensive priority (Avoidance), per 1%
  -- BLOCKVALUE added: Block Value = Shield Slam damage from 40 (wowhandbook leveling page)
  -- ARMOR added: icy-veins defensive priority puts Armor 2nd
  endgame  = { STR = 0.54, AGI = 0.57, STA = 1.0, HIT = 9.83, CRIT = 7.06, ARMOR = 0.02, DEF = 15.0, DODGE = 4.5, PARRY = 4.5, BLOCK = 2.0, BLOCKVALUE = 0.3 },
  source = "https://wowhandbook.com/classes/warrior/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/warrior/leveling/, https://www.icy-veins.com/wow-forever/protection-warrior-leveling
}

-- PALADIN ---------------------------------------------------------------
ns.WEIGHTS.PALADIN = ns.WEIGHTS.PALADIN or {}
ns.WEIGHTS.PALADIN["Holy"] = {
  -- derived from priority: Holy/Ret hybrid levels with a two-hander; spell damage > 8% melee hit > crit/Int > Str
  leveling = { STR = 0.5, AGI = 0.3, STA = 0.6, INT = 0.6, SPI = 0.5, AP = 0.2, SP = 1.0, HEAL = 0.5, HIT = 8.0, CRIT = 7.0, SPELLCRIT = 5.0, MP5 = 1.0, DPS = 4.0, ARMOR = 0.01 },
  -- wowhandbook Holy weights (Critical Strike = spell crit); normalised HEAL = 1.0 (source HEAL = 1)
  endgame  = { STA = 0.1, INT = 0.45, SPI = 0.15, HEAL = 1.0, SPELLCRIT = 7.0, MP5 = 0.7 },
  source = "https://wowhandbook.com/classes/paladin/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/paladin/leveling/, https://www.icy-veins.com/wow-forever/holy-paladin-leveling
}
ns.WEIGHTS.PALADIN["Protection"] = {
  -- derived from priority: Stamina and Spell Power first (once Consecration/Ret Aura), weapon/hit/crit early
  leveling = { STR = 0.5, AGI = 0.3, STA = 1.0, INT = 0.4, SPI = 0.3, SP = 1.0, HIT = 7.0, CRIT = 6.0, SPELLCRIT = 4.0, MP5 = 0.8, DPS = 4.0, ARMOR = 0.02, DEF = 0.8, DODGE = 3.0, PARRY = 3.0, BLOCK = 1.5 },
  -- wowhandbook Prot weights (Dodge/Parry per 1%); DEF 15/pt = push to 440 defense; normalised STA = 1.0 (source STA = 1)
  -- HIT added: wowhandbook text 'then Stamina, 8% melee hit, and spell damage' (not in its table)
  -- SP added: Consecration/Judgement/Holy Strike scale with spell damage (wowhandbook text, icy-veins #3)
  -- INT added: icy-veins priority (Stamina > Defense > Spell Power > Intellect > Strength)
  -- ARMOR added
  endgame  = { STR = 0.2, AGI = 0.33, STA = 1.0, INT = 0.2, SP = 0.6, HIT = 8.0, ARMOR = 0.02, DEF = 15.0, DODGE = 4.35, PARRY = 4.67 },
  source = "https://wowhandbook.com/classes/paladin/stat-priority/",
  -- leveling sources: https://www.icy-veins.com/wow-forever/protection-paladin-leveling, https://wowhandbook.com/classes/paladin/leveling/
}
ns.WEIGHTS.PALADIN["Retribution"] = {
  -- derived from priority: weapon damage > Stamina/Spirit (downtime) > Str; after 40 Int -> spell damage (CotL)
  leveling = { STR = 1.0, AGI = 0.5, STA = 1.0, INT = 0.5, SPI = 0.8, AP = 0.45, SP = 0.8, HIT = 8.0, CRIT = 10.0, MP5 = 1.0, DPS = 7.0, ARMOR = 0.01 },
  -- wowhandbook Ret weights (Spell Power = Holy Damage 2.64, AP = 1 in source); normalised STR = 1.0 (source STR = 2.43)
  -- INT added: Forever Champion of the Light 5/5 = +60% of Intellect as spell damage (0.6 x SP) + mana
  endgame  = { STR = 1.0, AGI = 0.85, STA = 0.16, INT = 0.7, AP = 0.41, SP = 1.09, HIT = 23.81, CRIT = 16.46, DPS = 5.76 },
  source = "https://wowhandbook.com/classes/paladin/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/paladin/leveling/, https://www.icy-veins.com/wow-forever/retribution-paladin-leveling
}

-- HUNTER ----------------------------------------------------------------
ns.WEIGHTS.HUNTER = ns.WEIGHTS.HUNTER or {}
ns.WEIGHTS.HUNTER["Beast Mastery"] = {
  -- derived from priority: weapon damage > Agility > Stamina > Intellect (Careful Aim)
  leveling = { AGI = 1.0, STA = 0.6, INT = 0.35, SPI = 0.15, AP = 0.3, RAP = 0.4, HIT = 7.0, CRIT = 9.0, DPS = 5.5, ARMOR = 0.01 },
  -- wowhandbook Beast Mastery weights; Intellect -> Attack Power via Careful Aim; source 'Attack Power' applied to both AP and RAP (Auto Shot is the main damage source); normalised AGI = 1.0 (source AGI = 2.77)
  endgame  = { AGI = 1.0, STA = 0.14, INT = 0.4, AP = 0.36, RAP = 0.36, HIT = 8.28, CRIT = 9.51, DPS = 5.05 },
  source = "https://wowhandbook.com/classes/hunter/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/hunter/leveling/, https://www.icy-veins.com/wow-forever/beast-mastery-hunter-leveling
}
ns.WEIGHTS.HUNTER["Marksmanship"] = {
  -- derived from priority: weapon damage > Agility > Stamina > Intellect (Careful Aim)
  leveling = { AGI = 1.0, STA = 0.6, INT = 0.35, SPI = 0.15, AP = 0.3, RAP = 0.4, HIT = 7.5, CRIT = 10.0, DPS = 5.5, ARMOR = 0.01 },
  -- wowhandbook Marksmanship weights; Intellect -> Attack Power via Careful Aim; source 'Attack Power' applied to both AP and RAP (Auto Shot is the main damage source); normalised AGI = 1.0 (source AGI = 2.83)
  endgame  = { AGI = 1.0, STA = 0.14, INT = 0.38, AP = 0.35, RAP = 0.35, HIT = 8.39, CRIT = 11.13, DPS = 4.95 },
  source = "https://wowhandbook.com/classes/hunter/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/hunter/leveling/, https://www.icy-veins.com/wow-forever/marksmanship-hunter-leveling
}
ns.WEIGHTS.HUNTER["Survival"] = {
  -- derived from priority: weapon damage > Agility > Stamina > Intellect (Careful Aim); Str for melee weaving
  leveling = { STR = 0.3, AGI = 1.0, STA = 0.6, INT = 0.35, SPI = 0.15, AP = 0.4, RAP = 0.35, HIT = 7.0, CRIT = 9.0, DPS = 5.5, ARMOR = 0.01 },
  -- wowhandbook Survival weights; Intellect -> Attack Power via Careful Aim; source 'Attack Power' applied to both AP and RAP (Auto Shot is the main damage source); normalised AGI = 1.0 (source AGI = 3.1)
  endgame  = { AGI = 1.0, STA = 0.13, INT = 0.35, AP = 0.32, RAP = 0.32, HIT = 7.07, CRIT = 10.11, DPS = 4.52 },
  source = "https://wowhandbook.com/classes/hunter/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/hunter/leveling/, https://www.icy-veins.com/wow-forever/survival-hunter-leveling
}

-- ROGUE -----------------------------------------------------------------
ns.WEIGHTS.ROGUE = ns.WEIGHTS.ROGUE or {}
ns.WEIGHTS.ROGUE["Assassination"] = {
  -- derived from priority: weapon damage > Agility > Strength > Stamina; hit rare but strong (Combat has Precision)
  leveling = { STR = 0.55, AGI = 1.0, STA = 0.5, AP = 0.5, HIT = 10.0, CRIT = 12.0, DPS = 7.5, ARMOR = 0.01 },
  -- wowhandbook Assassination weights (AP = 1 in source); normalised AGI = 1.0 (source AGI = 2.06)
  endgame  = { STR = 0.53, AGI = 1.0, STA = 0.19, AP = 0.49, HIT = 13.59, CRIT = 13.73, DPS = 6.8 },
  source = "https://wowhandbook.com/classes/rogue/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/rogue/leveling/, https://www.icy-veins.com/wow-forever/assassination-rogue-leveling
}
ns.WEIGHTS.ROGUE["Combat"] = {
  -- derived from priority: weapon damage > Agility > Strength > Stamina; hit rare but strong (Combat has Precision)
  leveling = { STR = 0.55, AGI = 1.0, STA = 0.5, AP = 0.5, HIT = 9.0, CRIT = 11.0, DPS = 7.5, ARMOR = 0.01 },
  -- wowhandbook Combat weights (AP = 1 in source); normalised AGI = 1.0 (source AGI = 1.96)
  endgame  = { STR = 0.56, AGI = 1.0, STA = 0.2, AP = 0.51, HIT = 12.35, CRIT = 12.14, DPS = 7.14 },
  source = "https://wowhandbook.com/classes/rogue/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/rogue/leveling/, https://www.icy-veins.com/wow-forever/combat-rogue-leveling
}
ns.WEIGHTS.ROGUE["Subtlety"] = {
  -- derived from priority: weapon damage > Agility > Strength > Stamina; hit rare but strong (Combat has Precision)
  leveling = { STR = 0.55, AGI = 1.0, STA = 0.5, AP = 0.5, HIT = 10.0, CRIT = 11.0, DPS = 7.5, ARMOR = 0.01 },
  -- wowhandbook Subtlety weights (AP = 1 in source); normalised AGI = 1.0 (source AGI = 1.93)
  endgame  = { STR = 0.57, AGI = 1.0, STA = 0.21, AP = 0.52, HIT = 10.98, CRIT = 11.82, DPS = 7.25 },
  source = "https://wowhandbook.com/classes/rogue/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/rogue/leveling/, https://www.icy-veins.com/wow-forever/subtlety-rogue-leveling
}

-- PRIEST ----------------------------------------------------------------
ns.WEIGHTS.PRIEST = ns.WEIGHTS.PRIEST or {}
ns.WEIGHTS.PRIEST["Discipline"] = {
  -- derived from priority: Spirit/Int (Spirit Tap, Meditation) then spell damage/Stamina; healing power for dungeons; wand
  leveling = { STA = 0.6, INT = 0.7, SPI = 0.8, SP = 1.0, HEAL = 0.8, SPELLHIT = 5.0, SPELLCRIT = 6.0, MP5 = 1.1, DPS = 1.0 },
  -- wowhandbook Discipline weights (Critical Strike = spell crit); normalised HEAL = 1.0 (source HEAL = 1)
  endgame  = { STA = 0.1, INT = 0.2, SPI = 0.15, HEAL = 1.0, SPELLCRIT = 9.8, MP5 = 0.4 },
  source = "https://wowhandbook.com/classes/priest/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/priest/leveling/, https://www.icy-veins.com/wow-forever/discipline-priest-leveling
}
ns.WEIGHTS.PRIEST["Holy"] = {
  -- derived from priority: Spirit/Int then spell damage/Stamina; healing power (icy-veins Holy leveling) for groups; wand
  leveling = { STA = 0.6, INT = 0.7, SPI = 0.8, SP = 1.0, HEAL = 0.8, SPELLHIT = 5.0, SPELLCRIT = 5.0, MP5 = 1.1, DPS = 1.0 },
  -- wowhandbook Holy weights (Critical Strike = spell crit); normalised HEAL = 1.0 (source HEAL = 1)
  endgame  = { STA = 0.1, INT = 0.35, SPI = 0.3, HEAL = 1.0, SPELLCRIT = 4.2, MP5 = 0.6 },
  source = "https://wowhandbook.com/classes/priest/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/priest/leveling/, https://www.icy-veins.com/wow-forever/holy-priest-leveling
}
ns.WEIGHTS.PRIEST["Shadow Magic"] = {
  -- derived from priority: Spell Power > crit > hit (icy-veins); Spirit/Int for Spirit Tap downtime (wowhandbook); wand
  leveling = { STA = 0.6, INT = 0.6, SPI = 0.8, SP = 1.0, HEAL = 0.1, SPELLHIT = 6.0, SPELLCRIT = 7.0, MP5 = 1.0, DPS = 1.0 },
  -- wowhandbook Shadow weights (Spell Power = Shadow Damage = 1); normalised SP = 1.0 (source SP = 1)
  endgame  = { STA = 0.15, INT = 0.24, SPI = 0.1, SP = 1.0, SPELLHIT = 11.4, SPELLCRIT = 11.76, MP5 = 0.3 },
  source = "https://wowhandbook.com/classes/priest/stat-priority/",
  -- leveling sources: https://www.icy-veins.com/wow-forever/shadow-priest-leveling, https://wowhandbook.com/classes/priest/leveling/
}

-- SHAMAN ----------------------------------------------------------------
ns.WEIGHTS.SHAMAN = ns.WEIGHTS.SHAMAN or {}
ns.WEIGHTS.SHAMAN["Elemental Combat"] = {
  -- derived from priority: Spell Damage > crit > hit > Intellect (mana) (icy-veins Elemental leveling)
  leveling = { STA = 0.6, INT = 0.6, SPI = 0.4, SP = 1.0, HEAL = 0.2, SPELLHIT = 6.0, SPELLCRIT = 7.0, MP5 = 1.0 },
  -- wowhandbook Elemental weights; school damage not in schema: Nature 0.8, Fire 0.2, Spell Penetration 0.5; normalised SP = 1.0 (source SP = 1)
  endgame  = { STA = 0.15, INT = 0.19, SP = 1.0, SPELLHIT = 11.8, SPELLCRIT = 8.54 },
  source = "https://wowhandbook.com/classes/shaman/stat-priority/",
  -- leveling sources: https://www.icy-veins.com/wow-forever/elemental-shaman-leveling, https://wowhandbook.com/classes/shaman/leveling/
}
ns.WEIGHTS.SHAMAN["Enhancement"] = {
  -- derived from priority: slow 2H weapon > Str (2 AP) > Int (1 AP + mana + spell crit) > Agi; SP worth half
  leveling = { STR = 1.0, AGI = 0.55, STA = 0.6, INT = 0.85, SPI = 0.2, AP = 0.5, SP = 0.5, HIT = 9.0, CRIT = 11.0, MP5 = 0.6, DPS = 7.5, ARMOR = 0.01 },
  -- wowhandbook Enhancement weights (AP = 1 in source); Forever: Mental Dexterity turns Intellect into Attack Power; normalised STR = 1.0 (source STR = 2.2)
  -- SP added: 'spell power is worth half as much' (wowhandbook leveling) / icy-veins #5 after Int
  endgame  = { STR = 1.0, AGI = 0.6, STA = 0.18, INT = 0.9, AP = 0.45, SP = 0.5, HIT = 23.64, CRIT = 15.4, DPS = 6.36 },
  source = "https://wowhandbook.com/classes/shaman/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/shaman/leveling/, https://www.icy-veins.com/wow-forever/enhancement-shaman-leveling
}
ns.WEIGHTS.SHAMAN["Restoration"] = {
  -- derived from priority: Spell Healing > crit (Water Shield mana) > Intellect (icy-veins Resto leveling)
  leveling = { STR = 0.3, STA = 0.6, INT = 0.7, SPI = 0.5, SP = 0.7, HEAL = 1.0, SPELLCRIT = 6.0, MP5 = 1.1, DPS = 1.0 },
  -- wowhandbook Restoration weights (Critical Strike = spell crit); normalised HEAL = 1.0 (source HEAL = 1)
  endgame  = { STA = 0.1, INT = 0.4, SPI = 0.35, HEAL = 1.0, SPELLCRIT = 6.0, MP5 = 0.6 },
  source = "https://wowhandbook.com/classes/shaman/stat-priority/",
  -- leveling sources: https://www.icy-veins.com/wow-forever/restoration-shaman-leveling
}

-- MAGE ------------------------------------------------------------------
ns.WEIGHTS.MAGE = ns.WEIGHTS.MAGE or {}
ns.WEIGHTS.MAGE["Arcane"] = {
  -- derived from priority: Spell Power (more abundant in Forever) > Int > Spirit (Arcane mana hunger) > crit
  leveling = { STA = 0.5, INT = 0.8, SPI = 0.7, SP = 1.0, SPELLHIT = 7.0, SPELLCRIT = 5.0, MP5 = 1.1, DPS = 0.6 },
  -- wowhandbook Arcane weights (Spell Power = Arcane Damage = 1; Spell Penetration 0.5); spell hit cap 16% vs raid boss; normalised SP = 1.0 (source SP = 1)
  endgame  = { STA = 0.15, INT = 0.83, SP = 1.0, SPELLHIT = 14.7, SPELLCRIT = 10.36 },
  source = "https://wowhandbook.com/classes/mage/stat-priority/",
  -- leveling sources: https://www.icy-veins.com/wow-forever/arcane-mage-leveling, https://wowhandbook.com/classes/mage/leveling/
}
ns.WEIGHTS.MAGE["Fire"] = {
  -- derived from priority: Spell Power > crit (rare, prioritise) > Int > Spirit (icy-veins Fire leveling)
  leveling = { STA = 0.5, INT = 0.6, SPI = 0.6, SP = 1.0, SPELLHIT = 7.0, SPELLCRIT = 8.0, MP5 = 0.9, DPS = 0.6 },
  -- wowhandbook Fire weights (Spell Power = Fire Damage = 1; Spell Penetration 0.5); normalised SP = 1.0 (source SP = 1)
  endgame  = { STA = 0.15, INT = 0.34, SP = 1.0, SPELLHIT = 17.9, SPELLCRIT = 11.34 },
  source = "https://wowhandbook.com/classes/mage/stat-priority/",
  -- leveling sources: https://www.icy-veins.com/wow-forever/fire-mage-leveling, https://wowhandbook.com/classes/mage/leveling/
}
ns.WEIGHTS.MAGE["Frost"] = {
  -- derived from priority: hit > spell damage > mana (Int/Spirit); Stamina vs pushback (icy-veins + wowhandbook)
  leveling = { STA = 0.5, INT = 0.7, SPI = 0.6, SP = 1.0, SPELLHIT = 7.0, SPELLCRIT = 5.0, MP5 = 0.9, DPS = 0.6 },
  -- wowhandbook Frost weights (Spell Power = Frost Damage = 1; Spell Penetration 0.5); normalised SP = 1.0 (source SP = 1)
  endgame  = { STA = 0.15, INT = 0.37, SP = 1.0, SPELLHIT = 14.0, SPELLCRIT = 7.98 },
  source = "https://wowhandbook.com/classes/mage/stat-priority/",
  -- leveling sources: https://www.icy-veins.com/wow-forever/frost-mage-leveling, https://wowhandbook.com/classes/mage/leveling/
}

-- WARLOCK ---------------------------------------------------------------
ns.WEIGHTS.WARLOCK = ns.WEIGHTS.WARLOCK or {}
ns.WEIGHTS.WARLOCK["Affliction"] = {
  -- derived from priority: Spell Power/Shadow > crit (Pandemic); Stamina > Int for Life Tap; Spirit helps
  leveling = { STA = 0.8, INT = 0.5, SPI = 0.6, SP = 1.0, SPELLHIT = 6.0, SPELLCRIT = 6.0, MP5 = 0.6, DPS = 0.6 },
  -- wowhandbook Affliction weights (Spell Power = Shadow Damage = 1; Spell Penetration 0.5); normalised SP = 1.0 (source SP = 1)
  endgame  = { STA = 0.15, INT = 0.4, SPI = 0.19, SP = 1.0, SPELLHIT = 8.7, SPELLCRIT = 9.24 },
  source = "https://wowhandbook.com/classes/warlock/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/warlock/leveling/, https://www.icy-veins.com/wow-forever/affliction-warlock-leveling
}
ns.WEIGHTS.WARLOCK["Demonology"] = {
  -- derived from priority: general Spell Power > hit; Spirit/Int/Stamina also buff your demon
  leveling = { STA = 0.8, INT = 0.5, SPI = 0.6, SP = 1.0, SPELLHIT = 6.0, SPELLCRIT = 4.0, MP5 = 0.6, DPS = 0.6 },
  -- wowhandbook Demonology weights (Shadow/Fire Damage 0.5, Spell Penetration 0.5); normalised SP = 1.0 (source SP = 1)
  endgame  = { STA = 0.15, INT = 0.32, SP = 1.0, SPELLHIT = 14.0, SPELLCRIT = 7.84, MP5 = 0.28 },
  source = "https://wowhandbook.com/classes/warlock/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/warlock/leveling/, https://www.icy-veins.com/wow-forever/demonology-warlock-leveling
}
ns.WEIGHTS.WARLOCK["Destruction"] = {
  -- derived from priority: Spell Power/Fire > hit (no Suppression before 41) > crit; Stamina for Life Tap
  leveling = { STA = 0.8, INT = 0.5, SPI = 0.5, SP = 1.0, SPELLHIT = 7.0, SPELLCRIT = 6.0, MP5 = 0.6, DPS = 0.6 },
  -- wowhandbook Destruction weights (Shadow/Fire Damage 0.5, Spell Penetration 0.5); normalised SP = 1.0 (source SP = 1)
  endgame  = { STA = 0.15, INT = 0.36, SP = 1.0, SPELLHIT = 11.5, SPELLCRIT = 9.1 },
  source = "https://wowhandbook.com/classes/warlock/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/warlock/leveling/, https://www.icy-veins.com/wow-forever/destruction-warlock-leveling
}

-- DRUID -----------------------------------------------------------------
ns.WEIGHTS.DRUID = ns.WEIGHTS.DRUID or {}
ns.WEIGHTS.DRUID["Balance"] = {
  -- derived from priority: Spell Power (priority stat) > Int > crit > Spirit (icy-veins Balance leveling)
  leveling = { STA = 0.5, INT = 0.6, SPI = 0.5, SP = 1.0, HEAL = 0.2, SPELLHIT = 6.0, SPELLCRIT = 6.0, MP5 = 1.0 },
  -- wowhandbook Balance weights; school damage not in schema: Arcane 0.6, Nature 0.4; normalised SP = 1.0 (source SP = 1)
  endgame  = { STA = 0.15, INT = 0.2, SP = 1.0, SPELLHIT = 14.5, SPELLCRIT = 10.64 },
  source = "https://wowhandbook.com/classes/druid/stat-priority/",
  -- leveling sources: https://www.icy-veins.com/wow-forever/balance-druid-leveling
}
ns.WEIGHTS.DRUID["Feral Combat"] = {
  -- derived from priority: Str = Agi; Stamina/Spirit cut downtime; weapon DPS (forms scale), Int only for shifting
  leveling = { STR = 1.0, AGI = 1.0, STA = 0.6, INT = 0.2, SPI = 0.3, AP = 0.4, HIT = 7.0, CRIT = 9.0, DPS = 3.0, ARMOR = 0.02, DEF = 0.3, DODGE = 3.0 },
  -- wowhandbook Feral (cat) weights (AP = 1 in source); bear tanking would want Armor/Defense/Stamina instead; normalised AGI = 1.0 (source AGI = 2.47)
  -- DPS added: Forever forms scale with weapon DPS (icy-veins Feral: Weapon DPS first); not in wowhandbook table
  endgame  = { STR = 0.98, AGI = 1.0, STA = 0.16, AP = 0.4, HIT = 8.32, CRIT = 10.17, DPS = 4.0 },
  source = "https://wowhandbook.com/classes/druid/stat-priority/",
  -- leveling sources: https://wowhandbook.com/classes/druid/leveling/, https://www.icy-veins.com/wow-forever/feral-druid-leveling
}
ns.WEIGHTS.DRUID["Restoration"] = {
  -- derived from priority: Spell Power while leveling (faster kills), Healing Power, then Int/Spirit
  leveling = { STA = 0.5, INT = 0.6, SPI = 0.6, SP = 1.0, HEAL = 0.7, SPELLCRIT = 5.0, MP5 = 1.0 },
  -- wowhandbook Restoration weights (Critical Strike = spell crit); normalised HEAL = 1.0 (source HEAL = 1)
  endgame  = { STA = 0.1, INT = 0.35, SPI = 0.45, HEAL = 1.0, SPELLCRIT = 3.0, MP5 = 0.6 },
  source = "https://wowhandbook.com/classes/druid/stat-priority/",
  -- leveling sources: https://www.icy-veins.com/wow-forever/restoration-druid-leveling, https://wowhandbook.com/classes/druid/leveling/
}
