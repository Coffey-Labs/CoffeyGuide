local _, ns = ...

-- Gold (g_), mounts (m_), professions (p_) and extras (x_) for WoW: Forever 1.60.1.
-- Researched 2026-11-15. Sources: wowhandbook.com, warcrafttavern.com/forever, warcraftmaps.com,
-- method.gg/wow-forever, Blizzard blue posts as quoted by those sites, and the local
-- ForeverDungeonJournal data (quest IDs / NPC coords).

local WH   = "https://wowhandbook.com"
local WT   = "https://www.warcrafttavern.com/forever"
local WM   = "https://warcraftmaps.com"
local SEVEN = { "WARRIOR", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "DRUID" } -- buy riding (Paladin/Warlock get class mounts)

ns.AddSteps{

  ---------------------------------------------------------------------------
  -- PROFESSIONS
  ---------------------------------------------------------------------------
  { id = "p_gathering_start", min = 1, max = 10, kind = "profession", optional = true,
    title = "Pick up a gathering skill",
    text = "Start-zone quest offers a gathering skill (+2 skill): Mining for Dummies, Pelt Collecting for Beginners or Wild Harvest. Gathering is learnable at 1, crafting at 5. Journeyman needs lvl 10, Expert 20, Artisan 35.",
    source = WT .. "/guides/professions/" },

  { id = "p_secondary", min = 5, max = 60, kind = "profession", optional = true,
    title = "First Aid + Cooking (+ Fishing)",
    text = "Every class: First Aid (bandages; Forever also adds Minor Healing Potion at skill 55) and Cooking. Cooking places a Basic Campfire from skill 1 and Well Fed food gives +5% kill XP. Fishing feeds Cooking/Alchemy.",
    source = WH .. "/professions/" },

  { id = "p_pair_plate", min = 5, max = 60, kind = "profession", optional = true,
    classes = { "WARRIOR", "PALADIN" },
    title = "Mining + Blacksmithing",
    text = "Plate classes: Mining + Blacksmithing for your own weapons/plate and pre-raid crafts. Sharpening Wheel camp object (skill 20) gives Strength. Mine while leveling; Blacksmithing can wait until you have gold.",
    source = WH .. "/professions/" },

  { id = "p_pair_leather", min = 5, max = 60, kind = "profession", optional = true,
    classes = { "ROGUE", "HUNTER", "DRUID", "SHAMAN" },
    title = "Skinning + Leatherworking",
    text = "Leather/mail users: Skinning + Leatherworking. LW 20 unlocks the Camp Tent (tops up rested XP). LW needs Pristine Leather/Hide/Scale (Scarce skins) for many recipes, so keep yours.",
    source = WH .. "/professions/" },

  { id = "p_pair_caster", min = 5, max = 60, kind = "profession", optional = true,
    classes = { "PRIEST", "MAGE", "WARLOCK", "DRUID", "SHAMAN" },
    title = "Herb + Alchemy / Tailor + Ench",
    text = "Casters: Herbalism + Alchemy is the safest gold pair (dyes and acids feed every crafter). Tailoring + Enchanting needs no gatherer but costs gold before it pays; best if you run many dungeons.",
    source = WM .. "/guides/best-professions-for-gold" },

  { id = "p_engineering_pvp", min = 5, max = 60, kind = "profession", optional = true,
    title = "Engineering for PvP",
    text = "Mining + Engineering: PvP and utility for any class, not income. Nov 10: Iron Grenade vendor price cut to 1s25c. Gnomes have Engineering Specialization (fewer gadget backfires).",
    source = WT .. "/news/class-economy-changes-wow-forever-hotfixes-for-november-10/" },

  { id = "p_tauren_herbs", min = 1, max = 60, kind = "profession", optional = true,
    races = { "Tauren" },
    title = "Tauren: Cultivation herbs",
    text = "Cultivation lets Tauren pick herbs without Herbalism and doubles yield if you have it. Free herb income while leveling; Barrens herb loop (10-30) is a listed farm.",
    source = WT .. "/guides/professions/" },

  { id = "p_swap_at_60", min = 55, max = 60, kind = "profession", optional = true,
    title = "Gather to 60, then craft",
    text = "Plan: two gathering skills (or gather + secondary) to 60, then drop one gatherer for a crafter once the mount gold is saved. Two crafters burn gold before 40. Note: crafting 150/225/300 also gives Legacy points.",
    source = WM .. "/guides/best-professions-for-gold" },

  ---------------------------------------------------------------------------
  -- GOLD
  ---------------------------------------------------------------------------
  { id = "g_basics", min = 1, max = 60, kind = "gold", optional = true,
    title = "Gold basics",
    text = "Loot everything, vendor greys, sell unused quest rewards. Skip spell ranks you never use and level-20 greens. Class training 1-60 costs about 206g. Make your own food/bandages. Buying gold gets accounts closed.",
    source = WH .. "/gold/" },

  { id = "g_gathering", min = 5, max = 60, kind = "gold", optional = true,
    title = "Two gatherers while leveling",
    text = "Herbalism sells from day one; Mining feeds 3 crafters; Skinning suits classes that kill a lot. Sell raw mats to players a few levels behind you. Legacy Bountiful Harvest raises Scarce material finds.",
    source = WM .. "/guides/best-professions-for-gold" },

  { id = "g_scarce", min = 10, max = 60, kind = "gold", optional = true,
    title = "Scarce materials",
    text = "Forever bonus drops from normal nodes/skins: Frilled Lichen/Rosecap/Stranglevine, Pyrite/Bauxite/Pitchblende, Pristine Leather/Hide/Scale. Lichen > Cerulean Dye (128 recipes). Don't dump them all in week one.",
    source = WM .. "/guides/scarce-materials" },

  { id = "g_ah_rules", min = 10, max = 60, kind = "gold", optional = true,
    title = "AH and vendor changes",
    text = "Nov 10: AH minimum deposit now 1 copper (was 1s), so cheap mats are worth listing. Vendor price of crafted LW/Tailoring/BS armor cut: never craft to vendor. Racial vendor mounts are now BoP. Sell bags, dyes, crate mats.",
    source = WT .. "/news/class-economy-changes-wow-forever-hotfixes-for-november-10/" },

  { id = "g_crates_a", min = 10, max = 60, kind = "gold", optional = true, faction = "Alliance",
    zone = "Redridge Mountains", map = 1433,
    title = "Waylaid Crates (Alliance)",
    text = "Mobs drop empty Waylaid Crates (Expert from 20, Artisan from 35). Fill with cloth/ore/herbs/leather or crafts, turn in to Marcy Baker for 50 Merchant's Favor + rep (recipes). Or sell empty crates and the mats they need.",
    wp = { { 1433, 9.8, 71.0, "Marcy Baker" } },
    source = WH .. "/professions/merchants-favor/" },

  { id = "g_crates_h", min = 10, max = 60, kind = "gold", optional = true, faction = "Horde",
    zone = "The Barrens", map = 1413,
    title = "Waylaid Crates (Horde)",
    text = "Mobs drop empty Waylaid Crates (Expert from 20, Artisan from 35). Fill with cloth/ore/herbs/leather or crafts, turn in to Dokimi for 50 Merchant's Favor + rep (recipes). Or sell empty crates and the mats they need.",
    wp = { { 1413, 50.2, 29.4, "Dokimi" } },
    source = WH .. "/professions/merchants-favor/" },

  { id = "g_band_10_20", min = 10, max = 25, kind = "gold", optional = true,
    zone = "The Barrens", map = 1413,
    title = "Gold 10-25: Barrens",
    text = "Skinners: Barrens beast loop south of the Crossroads (zhevras, plainstriders, Sunscale raptors) for Pristine/Light/Medium Leather and crates, ~80 Skinning. Fishers: Deviate Fish at Lushwater/Stagnant Oasis and Forgotten Pools.",
    source = WM .. "/gold/farms/barrens-pristine-leather-loop" },

  { id = "g_band_20_30", min = 22, max = 32, kind = "gold", optional = true,
    title = "Gold 22-32: cloth & leather",
    text = "Durnholde Keep, Hillsbrad (22-30, both factions): Syndicate drop Wool/Silk, kill Shadow Mages first. Wetlands raptors (22-30) at Black Channel Marsh for Medium/Heavy Leather. Angerfang Encampment (26-32) for Silk.",
    source = WM .. "/gold/farms/hillsbrad-durnholde-wool" },

  { id = "g_paladin_rfc", min = 20, max = 26, kind = "gold", optional = true, classes = { "PALADIN" },
    title = "Paladin: solo Ragefire Chasm",
    text = "Listed Forever farm: Paladins can solo Ragefire Chasm from level 20 for vendor loot and cloth. Beta-tested route; check it still works.",
    source = WM .. "/gold/farms/paladin-ragefire-chasm-low-level" },

  { id = "g_mage_nightbane", min = 26, max = 30, kind = "gold", optional = true, classes = { "MAGE" },
    zone = "Duskwood", map = 1431,
    title = "Mage: Nightbane worgen",
    text = "Listed Forever farm for Frost Mages: Nightbane worgen in Duskwood at 26-30 (cloth, vendor loot). Beta-tested route.",
    source = WM .. "/gold/farms/duskwood-nightbane-mage-farm" },

  { id = "g_band_30_40", min = 30, max = 45, kind = "gold", optional = true,
    title = "Gold 30-45: ore and herbs",
    text = "Arathi iron loop (Mining 125, Gold 155) from Boulderfist Hall past Witherbark Village; sell at Hammerfall (H) or Refuge Pointe (A). Northern STV herb loop (Kurzen, Balia'mah...): Khadgar's Whisker 185, Purple Lotus 210.",
    source = WM .. "/gold/farms/arathi-highlands-iron-mining" },

  { id = "g_sm_solo", min = 30, max = 40, kind = "gold", optional = true, classes = { "HUNTER", "ROGUE" },
    title = "Hunter/Rogue: SM Graveyard",
    text = "Listed solo farms: Hunters clear Scarlet Monastery Graveyard to Thalnos (32-40); Rogues loot Graveyard chests with stealth (30-38).",
    source = WM .. "/gold/farms" },

  { id = "g_save_mount", min = 30, max = 40, kind = "gold",
    title = "Save 100g for level 40",
    text = "Riding at 40 costs 100g and includes your first mount. Most money arrives in the 30s from quests, so spend little before 30. Dual spec is also offered at 40 (reported 50g). Paladins/Warlocks skip the riding cost.",
    source = WT .. "/guides/riding/" },

  { id = "g_riverglades", min = 35, max = 45, kind = "gold", optional = true,
    zone = "Riverglades", map = 2548,
    title = "Riverglades (35-45)",
    text = "New 35-45 zone, 150+ quests = good quest gold. Beta reports: a Riverglades vendor sells all nine Scarce materials at a fixed price (unconfirmed live) - check before paying AH prices. Nov 11 hotfix nerfed several Twilight mobs here.",
    source = WM .. "/guides/scarce-materials" },

  { id = "g_band_40_50", min = 40, max = 50, kind = "gold", optional = true,
    title = "Gold 40-50: Badlands/Tanaris",
    text = "Badlands Mithril/Truesilver circuit Camp Cagg > Dustbelch Grotto (Mining 175/230; Kargath FP for Horde, skip Dustbelch below 44). Tanaris 44-50: Lost Rigger Cove pirates + Wastewander for Mageweave.",
    source = WM .. "/gold/farms/badlands-mithril-circuit" },

  { id = "g_quest_gold_48", min = 48, max = 60, kind = "gold",
    title = "Quest gold from level 48",
    text = "Nov 10 hotfix: most quests level 48+ now reward extra gold. XP-to-gold at 60 is removed, so do NOT hoard completed quests for 60 - turn them in as you go. Repeatables, trivial quests and item-reward quests unchanged.",
    source = WT .. "/news/more-gold-from-quests-above-level-48-in-wow-forever/" },

  { id = "g_band_50_60", min = 48, max = 60, kind = "gold", optional = true,
    title = "Gold 48-60: endgame mats",
    text = "Un'Goro Thorium rim loop (Mining 245/275, Marshal's Refuge FP both sides). Felwood herbs: Gromsblood, Dreamfoil. 54+: Devilsaur skinning (Un'Goro), Felcloth satyrs (Felwood). Rugged Leather is the most-used material.",
    source = WM .. "/gold" },

  { id = "g_save_epic", min = 55, max = 60, kind = "gold", optional = true, classes = SEVEN,
    title = "Save for epic riding",
    text = "Journeyman Riding at 60 is 1000g; extra swift mounts 200g. Honored with your home city = 10% off training and mounts; Legacy Bartering up to 10% more off mounts only. Quests give no bonus gold at 60 - farm your class route.",
    source = "https://www.method.gg/wow-forever/how-to-get-a-mount-in-wow-forever-cost-requirement-and-mount-options" },

  ---------------------------------------------------------------------------
  -- MOUNTS (level 40 riding, by race)
  ---------------------------------------------------------------------------
  { id = "m_riding_human", min = 40, max = 60, kind = "mount", races = { "Human" }, classes = SEVEN,
    zone = "Elwynn Forest", map = 1429,
    title = "Riding 40: Eastvale (Human)",
    text = "Train Apprentice Riding (100g, includes a horse) from Randal Hunter, Eastvale Logging Camp. Extra colors 20g from Katie Hunter; Unger Statforth in Menethil sells the Black Stallion. Mounts are BoP.",
    wp = { { 1429, 84.3, 64.9, "Randal Hunter" }, { 1429, 84.1, 65.4, "Katie Hunter" } },
    source = WT .. "/guides/riding/" },

  { id = "m_riding_dwarf", min = 40, max = 60, kind = "mount", races = { "Dwarf" }, classes = SEVEN,
    zone = "Dun Morogh", map = 1426,
    title = "Riding 40: Amberstill (Dwarf)",
    text = "Train Apprentice Riding (100g, includes a ram) from Ultham Ironhorn at Amberstill Ranch. Extra rams 20g from Veron Amberstill.",
    wp = { { 1426, 63.7, 50.1, "Ultham Ironhorn" }, { 1426, 63.5, 50.6, "Veron Amberstill" } },
    source = WT .. "/guides/riding/" },

  { id = "m_riding_gnome", min = 40, max = 60, kind = "mount", races = { "Gnome" }, classes = SEVEN,
    zone = "Dun Morogh", map = 1426,
    title = "Riding 40: Steelgrill's (Gnome)",
    text = "Train Apprentice Riding (100g, includes a mechanostrider) from Binjy Featherwhistle at Steelgrill's Depot. Extra colors 20g from Milli Featherwhistle.",
    wp = { { 1426, 49.2, 48.1, "Binjy Featherwhistle" }, { 1426, 49.1, 48.0, "Milli Featherwhistle" } },
    source = WT .. "/guides/riding/" },

  { id = "m_riding_nightelf", min = 40, max = 60, kind = "mount", races = { "NightElf" }, classes = SEVEN,
    zone = "Darnassus", map = 1457,
    title = "Riding 40: Darnassus (NE)",
    text = "Train Apprentice Riding (100g, includes a saber) from Jartsam, Cenarion Enclave. Extra sabers 20g from Lelanai.",
    wp = { { 1457, 38.1, 16.1, "Jartsam" }, { 1457, 37.6, 15.3, "Lelanai" } },
    source = WT .. "/guides/riding/" },

  { id = "m_riding_skyborne", min = 40, max = 60, kind = "mount", races = { "Skyborne" }, classes = SEVEN,
    zone = "Zephras Isle", map = 2521,
    title = "Riding 40: Zephras (Skyborne)",
    text = "Genn Fairweather at Fairweather Stables trains riding and sells Galestriders (both factions). 100g incl. mount. Reported Nov 13: Skyborne riding gets no Honored discount.",
    wp = { { 2521, 53.8, 81.3, "Genn Fairweather" } },
    source = WT .. "/guides/riding/" },

  { id = "m_riding_orc", min = 40, max = 60, kind = "mount", races = { "Orc" }, classes = SEVEN,
    zone = "Orgrimmar", map = 1454,
    title = "Riding 40: Valley of Honor (Orc)",
    text = "Train Apprentice Riding (100g, includes a wolf) from Kildar, Valley of Honor. Extra wolves 20g from Ogunaro Wolfrunner.",
    wp = { { 1454, 69.4, 13.1, "Kildar" }, { 1454, 69.4, 12.2, "Ogunaro Wolfrunner" } },
    source = WT .. "/guides/riding/" },

  { id = "m_riding_troll", min = 40, max = 60, kind = "mount", races = { "Troll" }, classes = SEVEN,
    zone = "Durotar", map = 1411,
    title = "Riding 40: Sen'jin (Troll)",
    text = "Train Apprentice Riding (100g, includes a raptor) from Xar'Ti in Sen'jin Village. Extra raptors 20g from Zjolnir.",
    wp = { { 1411, 55.3, 75.5, "Xar'Ti" }, { 1411, 55.2, 75.7, "Zjolnir" } },
    source = WT .. "/guides/riding/" },

  { id = "m_riding_tauren", min = 40, max = 60, kind = "mount", races = { "Tauren" }, classes = SEVEN,
    zone = "Mulgore", map = 1412,
    title = "Riding 40: Bloodhoof (Tauren)",
    text = "Train Apprentice Riding (100g, includes a kodo) from Kar Stormsinger. Extra kodos 20g from Harb Clawhoof in Bloodhoof Village.",
    wp = { { 1412, 46.8, 61.9, "Kar Stormsinger" }, { 1412, 47.5, 58.6, "Harb Clawhoof" } },
    source = WT .. "/guides/riding/" },

  { id = "m_riding_undead", min = 40, max = 60, kind = "mount", races = { "Scourge" }, classes = SEVEN,
    zone = "Tirisfal Glades", map = 1420,
    title = "Riding 40: Brill (Undead)",
    text = "Train Apprentice Riding (100g, includes a skeletal horse) from Velma Warnam in Brill. Extra horses 20g from Zachariah Post.",
    wp = { { 1420, 60.2, 52.4, "Velma Warnam" }, { 1420, 59.9, 52.6, "Zachariah Post" } },
    source = WT .. "/guides/riding/" },

  { id = "m_epic_60", min = 60, max = 60, kind = "mount", optional = true, classes = SEVEN,
    title = "Journeyman Riding (epic)",
    text = "At 60 your race's riding trainer sells Journeyman Riding (1000g, +100% speed); swift mounts are 200g each at the same vendor. Other races' mounts need Exalted with that race. Honored home rep = 10% off.",
    source = WT .. "/guides/riding/" },

  -- Class mounts (detailed chains live in the class quest file)
  { id = "m_paladin_warhorse_a", min = 40, max = 60, kind = "mount", optional = true, faction = "Alliance", classes = { "PALADIN" },
    zone = "Stormwind City", map = 1453,
    title = "Warhorse: Tome of Nobility",
    text = "Free level-40 mount, no riding fee: The Tome of Nobility from Duthorian Rall (Cathedral of Light). Dwarves can also start it with Tiza Battleforge in Ironforge's Mystic Ward.",
    quests = { { "The Tome of Nobility" } },
    wp = { { 1453, 50.5, 47.5, "Duthorian Rall" }, { 1455, 27.6, 12.2, "Tiza Battleforge" } },
    source = WH .. "/classes/paladin/quests/" },

  { id = "m_paladin_warhorse_h", min = 40, max = 60, kind = "mount", optional = true, faction = "Horde", classes = { "PALADIN" },
    title = "Forsaken Warhorse",
    text = "Forsaken Paladins have their own free mount quests (no riding fee). Sources have not confirmed the level-40 giver yet: ask your Paladin trainer at 40.",
    source = WH .. "/gold/" },

  { id = "m_warlock_felsteed", min = 40, max = 60, kind = "mount", optional = true, classes = { "WARLOCK" },
    zone = "The Barrens", map = 1413,
    title = "Felsteed: Strahad Farsan",
    text = "Free level-40 mount: your Warlock trainer sends you to Strahad Farsan in Ratchet for Summon Felsteed. If riding skill is missing after the quest, summon the Felsteed once (Nov 9 fix).",
    quests = { { "Summon Felsteed" } },
    wp = { { 1413, 62.6, 35.5, "Strahad Farsan" } },
    source = WH .. "/classes/warlock/quests/" },

  { id = "m_paladin_charger_a", min = 60, max = 60, kind = "mount", optional = true, faction = "Alliance", classes = { "PALADIN" },
    zone = "Stormwind City", map = 1453,
    title = "Charger chain (60)",
    text = "Epic class mount instead of 1000g riding: Duthorian Rall sends you to Lord Grayson Shadowbreaker. Long chain with dungeon runs and costly reagents.",
    wp = { { 1453, 50.5, 47.5, "Duthorian Rall" }, { 1453, 49.4, 47.6, "Lord Grayson Shadowbreaker" } },
    source = WH .. "/classes/paladin/quests/" },

  { id = "m_paladin_charger_h", min = 60, max = 60, kind = "mount", optional = true, faction = "Horde", classes = { "PALADIN" },
    title = "Forsaken Charger (60)",
    text = "Forsaken Paladins earn Summon Forsaken Charger via their own level-60 chain (dungeons + materials). Steps not confirmed by guides yet.",
    source = WH .. "/gold/" },

  { id = "m_warlock_dreadsteed", min = 60, max = 60, kind = "mount", optional = true, classes = { "WARLOCK" },
    zone = "Burning Steppes", map = 1428,
    title = "Dreadsteed chain (60)",
    text = "Epic class mount instead of 1000g riding: start with Mor'zul Bloodbringer in Burning Steppes. Long chain with dungeon runs and reagents, ending in Dire Maul.",
    quests = { { "Dreadsteed of Xoroth", 7631 } },
    wp = { { 1428, 12.6, 31.4, "Mor'zul Bloodbringer" } },
    source = WH .. "/classes/warlock/quests/" },

  { id = "m_pack_kodo", min = 60, max = 60, kind = "mount", optional = true,
    title = "Reins of the Pack Kodo",
    text = "Long-term goal: 6000 Merchant's Favor, Exalted with your crate faction, level 60 + Journeyman Riding. Stable master Huey Sunnydale (Alliance) or Okamache in The Barrens (Horde).",
    source = WH .. "/professions/merchants-favor/" },

  ---------------------------------------------------------------------------
  -- EXTRAS
  ---------------------------------------------------------------------------
  { id = "x_rested", min = 1, max = 60, kind = "extra", optional = true,
    title = "Rested XP",
    text = "Log out in inns/capitals: 5% of a level per 8h, cap 150%. Rested doubles kill XP only (not quests). LW Camp Tent tops rested up to 5% of a level once per hour. Legacy Well Rested: +4%/rank rate and cap.",
    source = WT .. "/guides/experience/" },

  { id = "x_bags_a", min = 1, max = 20, kind = "extra", optional = true, faction = "Alliance",
    title = "Free bags (Alliance)",
    text = "Quest bags: Old Blanchy's Feed Pouch, 8 slots (Verna Furlbrow, Westfall, lvl 9); Wizbang's Gunnysack, 8 (Auberdine, lvl 7); Hunting Satchel, 10 (Vyrin Swiftwind, Loch Modan, lvl 15); Deviate Hide Pack, 10 (Wailing Caverns, 13).",
    wp = { { 1436, 59.9, 19.4, "Verna Furlbrow" }, { 1432, 81.7, 64.1, "Vyrin Swiftwind" } },
    source = WH .. "/leveling/bags/" },

  { id = "x_bags_h", min = 1, max = 25, kind = "extra", optional = true, faction = "Horde",
    title = "Free bags (Horde)",
    text = "Quest bags: Scuffed Shipping Crate, 8 slots (Wrenix, Ratchet, lvl 9, new); Deviate Hide Pack, 10 (Nalpak above Wailing Caverns, lvl 13); Spidersilk Pouch 12 or reagent Sack 10 (Yorn Grimtotem, Mulgore, lvl 23).",
    wp = { { 1413, 63.1, 36.3, "Wrenix the Wretched" }, { 1413, 46.0, 35.7, "Nalpak" }, { 1412, 32.5, 20.1, "Yorn Grimtotem" } },
    source = WH .. "/leveling/bags/" },

  { id = "x_camping", min = 5, max = 60, kind = "extra", optional = true,
    title = "Camping buffs",
    text = "Sit or craft at a campfire for 1 min to get every camp buff (1 hour). Each player adds one object from their profession (unlocked at skill 20). Buffs don't stack with matching class buffs. Not allowed in capitals.",
    source = WH .. "/professions/camping/" },

  { id = "x_sleepingbag_h", min = 14, max = 32, kind = "extra", optional = true, faction = "Horde",
    title = "Cozy Sleeping Bag 1/2",
    text = "Up to +3% kill XP for 2h. Start at the Burned-Out Remains south of Camp Taurajo, follow the note to Westfall's Alexston Farmstead, then the Nailed Plank to Stonetalon's abandoned camp (Old Toolbox, 12 slots).",
    quests = { { "... and that note you found", 79007 }, { "Stepping Stones", 79192 }, { "Scramble", 79980 } },
    wp = { { 1413, 46.3, 73.9, "Burned-Out Remains" }, { 1436, 37.3, 50.6, "Burned-Out Remains" }, { 1442, 40.8, 52.6, "Pocket Litter" }, { 1442, 39.6, 49.9, "Mound of Dirt" } },
    source = WH .. "/news/cozy-sleeping-bag-in-wow-forever/" },

  { id = "x_sleepingbag_a", min = 14, max = 32, kind = "extra", optional = true, faction = "Alliance",
    title = "Cozy Sleeping Bag 1/2",
    text = "Up to +3% kill XP for 2h. Start at the Burned-Out Remains, Alexston Farmstead (Westfall), follow the note to the burnt tower south of Camp Taurajo, then to Stonetalon's abandoned camp (Old Toolbox, 12 slots).",
    quests = { { "... and that note you found", 79008 }, { "Stepping Stones", 79192 }, { "Scramble", 79980 } },
    wp = { { 1436, 37.3, 50.6, "Burned-Out Remains" }, { 1413, 46.3, 73.9, "Burned-Out Remains" }, { 1442, 40.8, 52.6, "Pocket Litter" }, { 1442, 39.6, 49.9, "Mound of Dirt" } },
    source = WH .. "/news/cozy-sleeping-bag-in-wow-forever/" },

  { id = "x_sleepingbag_2", min = 32, max = 60, kind = "extra", optional = true,
    title = "Cozy Sleeping Bag 2/2",
    text = "Finish the chain: Carved Figurine on the Stonewrought Dam heads (Wetlands side), then the Messenger Bag at Thoradin's Wall - climb the fallen cart (Hillsbrad side). Satchel underneath gives the Cozy Sleeping Bag. Since Nov 17 its area also counts as Resting.",
    quests = { { "Wet Job", 79974 }, { "Eagle's Fist", 79975 }, { "This Must Be The Place", 79976 } },
    wp = { { 1432, 49.4, 12.9, "Carved Figurine" }, { 1424, 88.0, 47.1, "Fallen cart" }, { 1424, 85.7, 52.2, "Messenger Bag" } },
    source = WH .. "/news/cozy-sleeping-bag-in-wow-forever/" },

  { id = "x_dungeon_xp", min = 13, max = 60, kind = "extra", optional = true,
    title = "Dungeons vs questing",
    text = "Oct 1: dungeon quests give 50% less bonus XP. Nov 9: dungeon kill XP +50%. Run dungeons with their quests in hand and compare the trip with nearby questing. Nov 13: a mob gray to any party member gives the whole party 0 XP, so don't run with a much higher-level friend.",
    -- Nov 9 / Nov 13 dates: https://us.forums.blizzard.com/en/wow/t/2403040
    source = WT .. "/news/experience-from-dungeon-kills-increased-in-wow-forever/" },

  { id = "x_group_finder", min = 13, max = 60, kind = "extra", optional = true,
    title = "Finding groups",
    text = "No automatic Dungeon Finder: use the Looking For Group listing (or the Meeting Stone's listing) to post/find groups by dungeon and role. Meeting Stones don't summon; walk in or use a Warlock summon.",
    source = WT .. "/news/no-group-finder-or-summoning-stones-in-wow-forever/" },

  { id = "x_world_buffs", min = 1, max = 60, kind = "extra", optional = true,
    title = "World buffs while leveling",
    text = "Rend's head (UBRS) gives Warchief's Blessing / Might of Stormwind. Since Nov 12 heralds also reach the Crossroads and Razor Hill (Horde) and Goldshire, Lakeshire and Sentinel Hill (Alliance). Buffs no longer work in raids and, since Nov 17, always drop on death.",
    source = WT .. "/news/forever-world-buffs-now-provided-in-razor-hill-goldshire-lakeshire-sentinel-hill/" },

  { id = "x_travel", min = 1, max = 60, kind = "extra", optional = true,
    title = "Flights and hearthstone",
    text = "No flying mounts in Forever. Legacy Frequent Flier: 50% off flight paths and 20% faster flights. Set your hearth at your next hub before leaving town; hearth cooldown 30 min.", -- unverified: classic (hearth cooldown)
    source = WT .. "/guides/legacy/" },

  { id = "x_legacy", min = 25, max = 60, kind = "extra", optional = true,
    title = "Legacy points",
    text = "Account-wide points: each class at 25/45/60, crafting 150/225/300, Novice Spelunker (6 low dungeons). Open with Y. Leveling perks: Well Rested, Talented, Thrill of Adventure, Frequent Flier. Gold: Bartering, Bountiful Harvest.",
    source = WH .. "/legacy/fast-10-points/" },

  { id = "x_crate_rep", min = 10, max = 60, kind = "extra", optional = true,
    title = "Crate reputation",
    text = "Waylaid Crates give 2000 rep with Azeroth Commerce Authority (A) / Durotar Supply and Logistics (H): profession titles, tabard at Exalted, Pack Kodo. Legacy Diplomat: +2% rep per rank.",
    source = WH .. "/factions/" },

  { id = "x_dalaran_a", min = 30, max = 40, kind = "extra", optional = true, faction = "Alliance",
    zone = "Hillsbrad Foothills", map = 1424,
    title = "City of Dalaran access",
    text = "New dungeon. Emissary Jacques in Southshore: An Alarming Request > Image of Archmage Modera at Lordamere Lake. Heart of Disruption gives the Dalaran Sewer Key (Kirin Tor rep).",
    quests = { { "An Alarming Request", 92432 }, { "Heart of Disruption", 92458 } },
    wp = { { 1424, 48.4, 60.2, "Emissary Jacques" }, { 1416, 7.7, 58.8, "Image of Archmage Modera" } },
    source = WH .. "/zones/dungeons/city-of-dalaran/" },

  { id = "x_dalaran_h", min = 30, max = 40, kind = "extra", optional = true, faction = "Horde",
    zone = "Hillsbrad Foothills", map = 1424,
    title = "City of Dalaran access",
    text = "New dungeon. Magus Wordeen Voidglare, Tarren Mill: Prison Break In + Key to the City, then Dalaran Patrols and Blood in the Streets. Heart of Disruption gives the Dalaran Sewer Key.",
    quests = { { "Prison Break In", 544 }, { "Key to the City", 93680 }, { "Dalaran Patrols", 545 }, { "Blood in the Streets", 92434 } },
    wp = { { 1424, 61.5, 20.7, "Magus Wordeen Voidglare" } },
    source = WH .. "/zones/dungeons/city-of-dalaran/" },

  { id = "x_ony_a", min = 48, max = 60, kind = "extra", optional = true, faction = "Alliance",
    zone = "Burning Steppes", map = 1428,
    title = "Onyxia attunement (A)",
    text = "Per character, still required. Start at 48 with Dragonkin Menace from Helendis Riverhorn, Burning Steppes; 16 quests ending with Drakefire Amulet (General Drakkisath, UBRS). Keep the amulet in your bags.",
    quests = { { "Dragonkin Menace", 4182 } },
    wp = { { 1428, 85.4, 68.8, "Helendis Riverhorn" } },
    source = WT .. "/news/onyxias-lair-raid-will-still-require-attunement-in-wow-forever/" },

  { id = "x_ony_h", min = 55, max = 60, kind = "extra", optional = true, faction = "Horde",
    zone = "Badlands", map = 1418,
    title = "Onyxia attunement (H)",
    text = "Per character, still required. From 55: Blood and Thunder (new) from Warlord Goretooth in Kargath, then Warlord's Command; 15 quests ending with Blood of the Black Dragon Champion (UBRS).",
    quests = { { "Blood and Thunder", 98325 } },
    wp = { { 1418, 5.8, 47.4, "Warlord Goretooth" } },
    source = WT .. "/news/onyxias-lair-raid-will-still-require-attunement-in-wow-forever/" },

  { id = "x_ubrs_seal", min = 57, max = 60, kind = "extra", optional = true,
    title = "UBRS key: Seal of Ascension",
    text = "Inside LBRS, Vaelan wants the three gemstones (Omokk, Voone, Wyrmthalak) + Unadorned Seal (trash drop). Forge it at Emberstrife in Dustwallow's Wyrmbog. One holder opens UBRS for the group. Since Nov 17 UBRS is back to full strength: bring a full group.",
    quests = { { "Seal of Ascension", 4742 }, { "Seal of Ascension", 4743 } },
    source = WM .. "/guides/dungeon-keys-and-attunements" },

  { id = "x_scholo_key", min = 58, max = 60, kind = "extra", optional = true,
    zone = "Western Plaguelands", map = 1422,
    title = "Scholomance Skeleton Key",
    text = "Skeleton Key exists in the client. In Classic it came from a long Western Plaguelands chain at Chillwind Camp / The Bulwark. Forever steps not checked yet.", -- unverified: classic
    source = WM .. "/guides/dungeon-keys-and-attunements" },

  { id = "x_raids_dec9", min = 55, max = 60, kind = "extra", optional = true,
    title = "Raids open December 9",
    text = "Barrow Deeps (10) and Hyjal Summit (20) on Mount Hyjal need no attunement; Onyxia's Lair (40) needs the Drakefire Amulet. Attunement to the Core (Molten Core) is not in Forever for now. World buffs don't work in raids.",
    source = WT .. "/guides/raids/" },
}
