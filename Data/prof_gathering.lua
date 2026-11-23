local _, ns = ...

-- Gathering + secondary profession guides for World of Warcraft: Forever (1.60.1).
-- Sources (all Forever-specific):
--   icy-veins.com/wow-forever/{herbalism,mining,skinning,fishing}-leveling-guide + overview pages (Nov 2026)
--   warcrafttavern.com/forever/guides/{herbalism,mining,skinning,profession-trainers,cooking-leveling}/
--   wowhandbook.com/professions/{cooking,first-aid,fishing,camping}/ (+ /recipes/, client data)
--   forever.warcraftdb.com (Forever client DB: skill lines, smelting trivial ranges, item IDs)
--   gfinityesports.com Forever herbalism guide (only source naming herbs in Riverglades / Mount Hyjal / Shen'dralas)
-- No new gathering/secondary skill line exists in Forever: warcraftdb lists only the classic lines
-- (Herbalism 182, Mining 186, Skinning 393, Fishing 356, Cooking 185, First Aid 129). "Camping" is not a
-- skill line: every profession gets 3 camp objects (skill 20 / 140 blueprint / 300 blueprint) and Cooking
-- builds the campfires. "Tanning", "Gardening", "Bait and Tackle" are camp-crafting sub-menus, not professions.
-- Rank rules (Forever): Journeyman at skill 50, Expert 125, Artisan 200 for gathering professions, all from
-- full town/city trainers (starting-camp "junior" trainers teach Apprentice only). Secondary professions:
-- trainers teach Apprentice + Journeyman, Expert = book, Artisan = quest (level 35).

ns.PROFESSIONS = ns.PROFESSIONS or {}

---------------------------------------------------------------------------------------------------
-- HERBALISM
---------------------------------------------------------------------------------------------------
ns.PROFESSIONS["Herbalism"] = {
  kind = "gathering",
  summary = "Herbs for Alchemy and (new in Forever) First Aid healing potions. No tool needed. Camp: Incense Candle (Int). Scarce dye herbs + new endgame herbs (Marefoil, Demonsage, Death Lotus).",
  trainers = {
    Horde = "All ranks (Journeyman 50, Expert 125, Artisan 200): Jandi (Orgrimmar, The Drag 55.6,40.0), Komin Winterhoof (Thunder Bluff, Middle Rise), Martha Alliestar (Undercity, Apothecarium), Mishiki (Sen'jin Village), Faruza (Brill), Aranae Venomblood (Tarren Mill), Angrun (Grom'gol), Ruw (Camp Mojache). Apprentice only: Zor'la (Valley of Trials), Garan Sunstrider (Red Cloud Mesa), Florence Nightshade (Deathknell). Neutral: Halassa Fernbreeze (Shen'dar Village) + Syriel Nightrain (Valanaar) on Zephras Isle, Flora Silverwind (Booty Bay), Malvor (Nighthaven, Moonglade).",
    Alliance = "All ranks (Journeyman 50, Expert 125, Artisan 200): Reyna Stonebranch (Ironforge, Great Forge 55.6,58.0), Shylamiir (Stormwind, The Park), Tannysa (Stormwind, Mage Quarter), Firodren Mooncaller (Darnassus, Temple Gardens), Herbalist Pomeroy (Elwynn, outside Stormwind), Malorne Bladeleaf (Dolanaar), Kali Healtouch (Thelsamar), Alma Jainrose (Lakeshire), Cylania Rootstalker (Silverwind Refuge), Telurinon Moonshadow (Menethil), Brant Jasperbloom (Theramore), Edward Egan (Dalaran). Apprentice only: Nancy Songflower (Northshire), Emrys Flintbeard (Coldridge Valley), Eleyna Duskbreeze (Shadowglen). Neutral: Halassa Fernbreeze + Syriel Nightrain (Zephras Isle), Flora Silverwind (Booty Bay), Malvor (Nighthaven).",
  },
  gather = {
    "1-70 Peacebloom + Silverleaf (1), Earthroot (15) - Horde: Durotar, Mulgore, Tirisfal Glades, Zephras Isle | Alliance: Elwynn Forest, Dun Morogh, Teldrassil, Zephras Isle. Train Journeyman at 50.",
    "70-115 Mageroyal (50), Briarthorn (70), Stranglekelp (85, coasts), Bruiseweed (100) - Horde: The Barrens (west of Crossroads), Silverpine Forest | Alliance: Darkshore (Auberdine coast), Loch Modan (east bank).",
    "115-170 Wild Steelbloom (115), Kingsblood (125), Liferoot (150, riverbanks) - Horde: Hillsbrad Foothills (Durnholde), Stonetalon Mountains | Alliance: Wetlands, Hillsbrad Foothills, Stonetalon. New zone Riverglades (lvl 35-45) also has Kingsblood + Liferoot. Train Expert at 125.",
    "170-205 Fadeleaf (160), Goldthorn (170), Khadgar's Whisker (185) - Horde + Alliance: Arathi Highlands (Stromgarde ponds, Northfold), Stranglethorn Vale (Lake Nazferiti). Shen'dralas also lists Khadgar's Whisker. Train Artisan at 200.",
    "205-230 Wintersbite (195), Firebloom (205), Purple Lotus (210) - Horde + Alliance: Tanaris (Dunemaul to Southmoon/Eastmoon Ruins), Searing Gorge (Cauldron rim), Alterac Mountains (Wintersbite).",
    "230-270 Sungrass (230), Ghost Mushroom (245, Skulk Rock cave), Golden Sansam (260) - Horde: Feralas (High Wilderness, Ruins of Isildien), The Hinterlands | Alliance: The Hinterlands (Skulk Rock), Feralas.",
    "270-300 Dreamfoil (270), Mountain Silversage (280), Plaguebloom (285), Icecap (290, Winterspring), Black Lotus (300) - Horde: Felwood (Irontree Woods), Eastern Plaguelands | Alliance: Eastern Plaguelands (Darrowshire, Corin's Crossing), Felwood. New zone Mount Hyjal (lvl 60) lists Mountain Silversage + Black Lotus.",
    "Forever extras: scarce Frilled Lichen / Rosecap / Stranglevine drop from normal herbs (dyes). Marefoil, Demonsage, Death Lotus (new endgame flask herbs) - node locations not yet documented.",
  },
  recipes = {
    "Camp: Incense Candle (skill 20, trainer) - Intellect buff, no stack with Arcane Intellect",
    "Camp: Greenhouse (skill 140, Blueprint) - grows herbs from seeds + candle buff",
    "Camp: Seed Hybridizer (skill 300, Blueprint) - multiplies/combines herb seeds; combining can fail (Nov 19), Scarce Herb Seeds not accepted",
    "Goldthorn Tea (Cooking) +15 Herbalism for 15 min; Herbalist's Gloves +5 (LW 135); Enchant Gloves - Herbalism +2 / Advanced +5",
    "Apothecary Gloves +2 (Horde Serpentbloom quest, Wailing Caverns)",
    "Graverobber's Shovel (Dextren Ward, The Stockade): 10 charges, gathers Grave Moss without Herbalism",
    "Starter quest reward option: 'Wild Harvest' manual teaches Herbalism",
  },
  source = "https://www.icy-veins.com/wow-forever/herbalism-leveling-guide",
}

---------------------------------------------------------------------------------------------------
-- MINING (incl. Smelting)
---------------------------------------------------------------------------------------------------
ns.PROFESSIONS["Mining"] = {
  kind = "gathering",
  summary = "Ore, stone, gems for Blacksmithing/Engineering. Keep a Mining Pick in bags. Smelt cheap AH ore to ~105 first. New: Poor Copper Veins, Pyrite/Bauxite/Pitchblende, Azerothium + Heavy Thorium bars.",
  trainers = {
    Horde = "All ranks + Smelting (Journeyman 50, Expert 125, Artisan 200): Makaru (Orgrimmar, Valley of Honor 73.0,27.0), Brek Stonehoof (Thunder Bluff, Middle Rise), Brom Killian (Undercity, War Quarter), Krunn (Razor Hill), Johan Focht (The Sepulcher). Apprentice only, no smelting: Norzsh (Valley of Trials), Vartha Rockmane (Red Cloud Mesa), Walter Mason (Deathknell). Neutral: Messana Crestwind (Shen'dar Village) + Halavuul Cragwind (Valanaar) on Zephras Isle, Pikkle (Gadgetzan), Grungle (Powderfuse Port, Riverglades).",
    Alliance = "All ranks + Smelting (Journeyman 50, Expert 125, Artisan 200): Geofram Bouldertoe (Ironforge, Great Forge 50.3,28.0), Gelman Stonehand (Stormwind, Dwarven District), Yarr Hammerstone (Kharanos), Dank Drizzlecut (Gol'Bolar Quarry), Brock Stoneseeker (Thelsamar), Kurdram Stonehammer (Auberdine), Matt Johnson (Darkshire). Apprentice only, no smelting: Kelsey Fargo (Northshire), Sally Swiftwrench (Coldridge Valley), Fanorran Stilloak (Shadowglen). Neutral: Messana Crestwind + Halavuul Cragwind (Zephras Isle), Pikkle (Gadgetzan), Grungle (Powderfuse Port, Riverglades).",
  },
  steps = {
    { from = 1, to = 65, craft = "Smelt Copper -> Copper Bar", id = 2840, count = 65,
      mats = "1 Copper Ore each; buy ~120-140 Copper Ore total (keep 70 bars for Bronze)",
      note = "Learn Mining at a FULL trainer + forge. Smelt Copper yellow 25, grey 70. Or mine Copper/Poor Copper Veins in starting zones (see gather)." },
    { from = 65, to = 75, craft = "Smelt Tin -> Tin Bar", id = 3576, count = 70,
      mats = "70 Tin Ore",
      note = "Train Journeyman (skill 50) and learn Smelt Tin + Smelt Bronze (req 65). Tin greys at 75, keep all 70 bars." },
    { from = 75, to = 105, craft = "Smelt Bronze -> Bronze Bar", id = 2841, count = 70,
      mats = "1 Copper Bar + 1 Tin Bar each (70 + 70)",
      note = "Bronze yellow 65, green 90, grey 115; gains slow after 90. Buy a Mining Pick, enable Find Minerals, go mine." },
    { from = 105, to = 125, craft = "Mine Tin Veins (+ Silver Veins)",
      mats = "Mining Pick in bags",
      note = "Tin Vein 65 (grey 165), Silver Vein 75. Copper Veins grey at 100. Smelt Silver (req 75, yellow 100, grey 125) for extra points." },
    { from = 125, to = 175, craft = "Mine Iron Deposits (+ Gold Veins from 155)",
      mats = "Mining Pick",
      note = "Train Expert at 125. Smelt Iron (125; yellow 130, grey 140) and Smelt Gold (155; yellow 170, grey 185) add a few points. Smelt Steel (165) is grey at once." },
    { from = 175, to = 245, craft = "Mine Mithril Deposits (+ Truesilver from 230)",
      mats = "Mining Pick",
      note = "Mithril 175 (green 225, grey 275); Smelt Mithril/Truesilver are grey on learn. Train Artisan at 200 (needed past 225). Alt 230-245: Dark Iron Deposits (Searing Gorge, Burning Steppes)." },
    { from = 245, to = 275, craft = "Mine Small Thorium Veins",
      mats = "Mining Pick",
      note = "Small Thorium 245 (grey 345). Keep mining Mithril/Truesilver you pass. Smelt Thorium (250) is grey on learn." },
    { from = 275, to = 300, craft = "Mine Rich Thorium Veins + Small Thorium",
      mats = "Mining Pick",
      note = "Rich Thorium 275. Smelt Azerothium (275, trainer): 2 Pitchblende + 1 Coal -> Azerothium Bar (id 249726); Warcraft Tavern says it gives skill-ups from 275 but client DB lists it 275/275 (likely grey)." },
  },
  gather = {
    "1-65 Copper Veins + Poor Copper Veins (new, all starting zones) - Horde: Durotar (Razor Hill hills), Mulgore (Bael'dun cave), Tirisfal Glades (Agamand Mills hills), Zephras Isle (Shen'dar to Falaath Village) | Alliance: Elwynn Forest (Fargodeep Mine), Dun Morogh (Iceflow Lake), Teldrassil (Chunk of Amber nodes, Fel Rock), Zephras Isle.",
    "65-125 Tin (65) + Silver (75) - Horde: Silverpine Forest (Beren's Peril), Hillsbrad Foothills (Durnholde), The Barrens (Razorfen hills), Ashenvale, Stonetalon | Alliance: Wetlands (Thelgen Rock), Westfall (Gold Coast Quarry), Ashenvale, Stonetalon. Tin + Silver also spawn in Riverglades.",
    "125-175 Iron (125) + Gold (155) - Horde: Thousand Needles (canyon below Freewind Post), Arathi Highlands, Desolace (Kodo Graveyard) | Alliance: Arathi Highlands (Refuge Pointe loop), Desolace (from Nijel's Point), Thousand Needles. Riverglades (lvl 35-45) also has Iron.",
    "175-245 Mithril (175) + Truesilver (230) - Horde: The Hinterlands (from Revantusk), Tanaris (Gadgetzan loop) | Alliance: Tanaris, The Hinterlands (from Aerie Peak). Also Badlands, Searing Gorge, Feralas. 230-245 alt: Dark Iron in Searing Gorge / Burning Steppes.",
    "245-275 Small Thorium - Horde + Alliance: Un'Goro Crater (crater walls, Fungal Rock), Felwood (Irontree Woods / Shatter Scar Vale).",
    "275-300 Rich Thorium (275) + Small Thorium - Horde + Alliance: Winterspring (Lake Kel'Theril loop), Eastern Plaguelands (Light's Hope loop).",
    "Rockslicer (Rhahk'Zor, Deadmines) gathers Copper/Tin/Silver/Iron veins without Mining (30 charges). Scarce: Pyrite, Bauxite, Pitchblende.",
  },
  recipes = {
    "Smelt Copper 1 / Tin 65 / Bronze 65 / Silver 75 / Iron 125 / Gold 155 / Steel 165 / Mithril 175 / Truesilver 230 / Thorium 250 (trainer)",
    "Smelt Dark Iron 230 (8 Dark Iron Ore, not trainer-taught; Black Forge, Blackrock Depths)", -- unverified: classic (location/source of the recipe)
    "NEW Smelt Azerothium 275 (trainer): 2 Pitchblende + 1 Coal",
    "Summit of Eternity (Mount Hyjal): Toron Rockhoof's forge and anvil work again (Nov 20) for smelting and Blacksmithing",
    "NEW Smelt Heavy Thorium 300 (trainer): Heavy Thorium Ore -> Heavy Thorium Bar (id 251291), needs a Molten Foundry",
    "Camp: Lodestone (skill 20, trainer) - melee AP, no stack with Blessing of Might",
    "Camp: Rock Garden (140, Blueprint) - grows a common ore node; Molten Foundry (300, Blueprint) - high-end smelting station",
    "Skill: Miner's Cape +2 (Miner Johnson, Deadmines), Goblin Mining Helmet +5, Enchant Gloves - Mining +2 / Advanced +5",
    "Smelting Pants (Gilnid, Deadmines): -25% smelt time for Copper/Tin/Bronze/Silver",
  },
  source = "https://www.icy-veins.com/wow-forever/mining-leveling-guide",
}

---------------------------------------------------------------------------------------------------
-- SKINNING
---------------------------------------------------------------------------------------------------
ns.PROFESSIONS["Skinning"] = {
  kind = "gathering",
  summary = "Leather, hides and scales for Leatherworking (also some Tailoring/BS/Eng recipes). Knife in bags only. New Fel Leather/Hide and scarce Pristine Leather/Hide/Scale. Camp: Camp Chair (crit).",
  trainers = {
    Horde = "All ranks (Journeyman 50, Expert 125, Artisan 200): Thuwd (Orgrimmar, The Drag 63.1,45.3), Mooranta (Thunder Bluff, Middle Rise), Killian Hagey (Undercity, Rogues' Quarter), Rand Rhobart (Tirisfal, camp near Undercity), Yonn Deepcut (Bloodhoof Village), Dranh (Camp Taurajo), Malux (Shadowprey Village), Kulleg Stonehorn (Camp Mojache). Apprentice only: Kagil (Valley of Trials), Nawka Wildsong (Red Cloud Mesa), Margaret Weaver (Deathknell). Neutral: Ishlee Breezewhisper (Valanaar) + Mendalass Tattermend (Shen'dar Village) on Zephras Isle.",
    Alliance = "All ranks (Journeyman 50, Expert 125, Artisan 200): Balthus Stoneflayer (Ironforge, Great Forge 39.6,32.8), Maris Granger (Stormwind, Old Town), Eladriel (Darnassus, Craftsmen's Terrace), Helene Peltskinner (Goldshire), Radnaal Maneweaver (Teldrassil, outside Darnassus), Jayla (Silverwind Refuge), Wilma Ranthal (Redridge, Shalewind Canyon). Apprentice only: Riley Peltskinner (Northshire), Brighid Stormflayer (Coldridge Valley), Terunne Bearshaper (Shadowglen). Neutral: Ishlee Breezewhisper + Mendalass Tattermend (Zephras Isle).",
  },
  gather = {
    "Skill needed: beasts up to lvl 10 = 1; lvl 11-20 = 10 per level above 10; lvl 20+ = level x 5 (lvl 40 = 200). In Forever even lvl 1 beasts give points to 75.",
    "1-75 starting-zone beasts - Horde: Durotar (boars, scorpids), Mulgore (plainstriders, prairie wolves), Tirisfal Glades (duskbats, darkhounds), Zephras Isle (Vuldren, Ursera, Galestriders) | Alliance: Elwynn Forest (wolves, boars, Eastvale bears), Dun Morogh (boars, bears), Teldrassil (boars, nightsabers), Zephras Isle. Train Journeyman at 50.",
    "75-125 lvl 16-25 beasts - Horde: The Barrens (plainstriders/zhevras/raptors west of Northwatch Hold), Silverpine | Alliance: Loch Modan (boars, bears, crocolisks), Darkshore, Westfall, Redridge.",
    "125-150 - Horde: Hillsbrad Foothills (lions + bears near Tarren Mill) | Alliance: Wetlands (raptors, Whelgar's Excavation Site), Hillsbrad Foothills. Train Expert at 125.",
    "150-185 - Horde: Thousand Needles (Shimmering Flats basilisks/tortoises), Arathi Highlands | Alliance: Arathi Highlands (striders, thrashers, fleshstalkers), Thousand Needles.",
    "185-225 - Horde: Dustwallow Marsh (crocolisks, raptors), Badlands (coyotes), Stranglethorn Vale | Alliance: Stranglethorn Vale (raptors, panthers, stalkers), Badlands, Dustwallow Marsh. New zone Riverglades (lvl 35-45) is listed for 150-205. Train Artisan at 200.",
    "225-250 - Horde: Tanaris (Blisterpaw hyenas, Abyssal Sands), Feralas (Feral Scar Vale yetis) | Alliance: Feralas, Tanaris.",
    "250-275 - Horde + Alliance: Un'Goro Crater (ravasaurs), Felwood (Angerclaw bears, Felpaw wolves).",
    "275-300 - Horde: Western Plaguelands (Diseased Wolves/Grizzlies), Winterspring | Alliance: Winterspring (Frostsaber Rock), Western Plaguelands.",
  },
  recipes = {
    "Camp: Camp Chair (skill 20, trainer) - crit chance buff",
    "Camp: Field Guide (140, Blueprint) - crit + Track Beasts; Trapper's Workbench (300, Blueprint) - crit + a trap",
    "Keen Skinning Knife +3 (quest Unwelcome Guests); Enchant Gloves - Skinning +5 / Advanced Skinning +10",
    "Starter quest reward option: 'Pelt Collecting for Beginners' teaches Skinning",
    "New mats: Fel Leather, Fel Hide (sources undocumented); scarce Pristine Leather / Pristine Hide / Pristine Scale",
  },
  source = "https://www.icy-veins.com/wow-forever/skinning-leveling-guide",
}

---------------------------------------------------------------------------------------------------
-- COOKING
---------------------------------------------------------------------------------------------------
ns.PROFESSIONS["Cooking"] = {
  kind = "secondary",
  summary = "Food buffs (+5% kill XP while Well Fed) and the camp profession: builds Basic/Journeyman/Expert campfires and the Iron Oven. Fish route pairs with Fishing; 44 new recipes (teas, smoothies).",
  trainers = {
    Horde = "Apprentice + Journeyman: Zamja (Orgrimmar, The Drag 57.4,53.8), Aska Mistrunner (Thunder Bluff), Eunice Burch (Undercity, Trade Quarter), Cook Torka (Razor Hill), Pyall Silentstride (Bloodhoof), William Pickman (Brill), Duhng (Crossroads), Mudduk (Grom'gol), Gorg (Rog'mar, Riverglades), Ortak Lomgok (Elderwild, Mount Hyjal). Neutral: Nyalah Brightfire (Valanaar) + Zerril Softbreeze (Shen'dar Village), Zephras Isle. Expert (skill 125): Expert Cookbook from Wulan, Shadowprey Village, Desolace 26.2,69.8. Artisan (225, lvl 35): quest Clamlette Surprise, Dirge Quikcleave, Gadgetzan inn 52.6,28.0.",
    Alliance = "Apprentice + Journeyman: Stephen Ryback (Stormwind, Old Town 78.2,53.1), Daryl Riknussun (Ironforge, Great Forge), Alegorn (Darnassus), Tomas (Goldshire), Gremlock Pilsnor (Kharanos), Cook Ghilm (Gol'Bolar Quarry), Zarrin (Dolanaar), Crystal Boughman (Lakeshire), Katherine Lee (Dalaran), Hnaz Blunderflame (Elderwild, Mount Hyjal). Neutral: Nyalah Brightfire + Zerril Softbreeze (Zephras Isle). Expert (skill 125): Expert Cookbook from Shandrina, Silverwind Refuge, Ashenvale 49.6,67.0. Artisan (225, lvl 35): quest Clamlette Surprise, Dirge Quikcleave, Gadgetzan inn 52.6,28.0.",
  },
  steps = {
    { from = 1, to = 50, craft = "Brilliant Smallfish", id = 6290, count = 50,
      mats = "1 Raw Brilliant Smallfish (6291) each",
      note = "Craft a Basic Campfire Kit (1 Simple Wood) first - it is your cooking fire. Recipe ~40c: Tharynn Bouden (Goldshire), Catherine Leland (SW), Sewa Mistrunner (TB), Lizbeth Cromwell (UC), Nyalah Brightfire (Zephras). Alt: Roasted Boar Meat / Charred Wolf Meat (known)." },
    { from = 50, to = 75, craft = "Longjaw Mud Snapper", id = 4592, count = 25,
      mats = "1 Raw Longjaw Mud Snapper (6289) each",
      note = "Train Journeyman at 50 (no level req). Recipe ~4s: Tharynn Bouden, Tansy Puddlefizz (IF), Naal Mistrunner (TB), Lizbeth Cromwell, Killian Sanatha (Silverpine). Alt: Coyote Steak (trainer)." },
    { from = 75, to = 100, craft = "Longjaw Mud Snapper", id = 4592, count = 27,
      mats = "1 Raw Longjaw Mud Snapper each",
      note = "Snapper greys at 130. Alt (Icy Veins meat route): Coyote Steak to 90, then Dry Pork Ribs (trainer, 1 Boar Ribs + 1 Mild Spices)." },
    { from = 100, to = 150, craft = "Bristle Whisker Catfish", id = 4593, count = 52,
      mats = "1 Raw Bristle Whisker Catfish (6308) each",
      note = "Read Expert Cookbook (1g) at 125. Recipe ~12s: Catherine Leland (SW), Lindea Rabonne (Southshore), Kilxx (Ratchet), Sewa/Naal Mistrunner (TB), Ronald Burch (UC), Derak Nightfall (Tarren Mill). Catfish = +8 Fishing food." },
    { from = 150, to = 175, craft = "Bristle Whisker Catfish", id = 4593, count = 69,
      mats = "1 Raw Bristle Whisker Catfish each",
      note = "Catfish yellow 140, grey 180 - expect misses. Alt: Curiously Tasty Omelet (130; Raptor Egg + Hot Spices; Kendor Kabonka SW / Keena Hammerfall)." },
    { from = 175, to = 225, craft = "Mithril Head Trout", id = 8364, count = 52,
      mats = "1 Raw Mithril Head Trout (8365) each",
      note = "Recipe ~22s: Kelsey Yance (Booty Bay), Stuart Fleming (Menethil), Heldan Galesong (Auberdine), Tansy Puddlefizz (IF), Shankys (Orgrimmar), Wulan (Desolace), Wik'Tar (Ashenvale). Pre-buy Clamlette mats: 12 Giant Egg, 10 Zesty Clam Meat, 20 Alterac Swiss." },
    { from = 225, to = 300, craft = "Spotted Yellowtail", id = 6887, count = 120,
      mats = "1 Raw Spotted Yellowtail (4603) each",
      note = "First do Clamlette Surprise (Dirge Quikcleave, Gadgetzan, lvl 35). Recipe ~1g60s: Gikkix, Steamwheedle Port, Tanaris 66.6,22.1. Yellow 265, grey 305. Alt: Tender Wolf Steak (Dirge) or Monster Omelet (Himmik, Everlook), same breakpoints." },
  },
  recipes = {
    "Camp: Basic Campfire Kit (skill 1, Simple Wood) - 3 camp slots; Journeyman Campfire Kit (use 90 since Nov 10, was 140; blueprint from Lord Serpentis, Wailing Caverns) - 5 slots; Expert Campfire Kit (use 220) - 10 slots",
    "Camp: Iron Oven (skill 300; 10 Simple Flour, 5 Refreshing Spring Water, 4 Soothing Spices) - required for Mightfish Steak, Lobster Stew, Cleansing Stew",
    "Cookie's Feast (skill 140, blueprint from Cookie, Deadmines) - Stamina feast",
    "NEW teas (healing power): Peace Tea 25, Royal Tea 100, Root Tea 125, Triage Tea 180, Sunny Tea 200, Sage's Tea 250",
    "NEW smoothies (spirit): Venomous 25, Slimy 100, Calcified 180, Spicy 200, Wicked 250",
    "Spinefin Halibut (+18 Fishing, yellow 210, grey 220); Goldthorn Tea (+15 Herbalism)",
    "Expert Cookbook item 16072 (1g); Artisan quest items: Giant Egg 12207, Zesty Clam Meat 7974, Alterac Swiss 8932",
  },
  source = "https://wowhandbook.com/professions/cooking/",
}

---------------------------------------------------------------------------------------------------
-- FIRST AID
---------------------------------------------------------------------------------------------------
ns.PROFESSIONS["First Aid"] = {
  kind = "secondary",
  summary = "Bandages, plus in Forever all six Healing Potions (moved from Alchemy), anti-venoms, poultices (disease) and tourniquets (bleed). Camp: First Aid Kit (Stamina). Great for every class.",
  trainers = {
    Horde = "Apprentice + Journeyman: Arnok (Orgrimmar, Valley of Spirits 34.2,84.6), Pand Stonebinder (Thunder Bluff, Spirit Rise), Mary Edras (Undercity, Rogues' Quarter), Rawrk (Razor Hill), Vira Younghoof (Bloodhoof), Nurse Neela (Brill). Neutral: Melasa Fairmend (Valanaar) + Naleeia Tattermend (Shen'dar Village), Zephras Isle. Expert (125): book Expert First Aid - Under Wraps (1g) from Balai Lok'Wein, Brackenwall Village, Dustwallow Marsh 36.5,30.4. Artisan (225, lvl 35): quest Triage, Doctor Gregory Victor, Hammerfall, Arathi 73.4,36.9 (lead-in 'Horde Trauma' from Arnok, optional).",
    Alliance = "Apprentice + Journeyman: Shaina Fuller (Stormwind, Cathedral Square 52.9,44.8), Nissa Firestone (Ironforge, Great Forge), Dannelor (Darnassus), Michelle Belle (Goldshire), Thamner Pol (Kharanos), Byancie (Dolanaar), Fremal Doohickey (Menethil), Angelique Butler (Dalaran). Neutral: Melasa Fairmend + Naleeia Tattermend (Zephras Isle). Expert (125): book Expert First Aid - Under Wraps (1g) from Deneb Walker, Stromgarde Keep, Arathi 27.0,58.8. Artisan (225, lvl 35): quest Triage, Doctor Gustaf VanHowzen, Theramore 67.8,49.0 (lead-in 'Alliance Trauma' from Nissa Firestone, optional).",
  },
  steps = {
    { from = 1, to = 40, craft = "Linen Bandage", id = 1251, count = 41,
      mats = "1 Linen Cloth each (41)",
      note = "Starter recipe. Alt potion route (Icy Veins): Minor Healing Potion 1-75 (x85; 1 Peacebloom + 1 Empty Vial + 1 Mild Spices each)." },
    { from = 40, to = 75, craft = "Heavy Linen Bandage", id = 2581, count = 45,
      mats = "2 Linen Cloth each (90)",
      note = "Trainer recipe (req 40). Train Journeyman at 50 (no level req). Build the First Aid Kit camp object at 20 (3 Linen Bandage + 1 Refreshing Spring Water)." },
    { from = 75, to = 80, craft = "Heavy Linen Bandage", id = 2581, count = 11,
      mats = "2 Linen Cloth each (22)",
      note = "Alt: Lesser Healing Potion 75-110 (1 Briarthorn + 1 Empty Vial + 2 Mild Spices)." },
    { from = 80, to = 115, craft = "Wool Bandage", id = 3530, count = 49,
      mats = "1 Wool Cloth each (49)",
      note = "Trainer recipe (req 80)." },
    { from = 115, to = 150, craft = "Heavy Wool Bandage", id = 3531, count = 49,
      mats = "2 Wool Cloth each (98)",
      note = "Read Expert First Aid - Under Wraps at 125 (Deneb Walker / Balai Lok'Wein); buy both Manuals there too. Alt: Healing Potion 110-150 (Bruiseweed + Leaded Vial + Hot Spices)." },
    { from = 150, to = 180, craft = "Silk Bandage", id = 6450, count = 42,
      mats = "1 Silk Cloth each (42)",
      note = "Learn Silk Bandage from a First Aid trainer at 150." },
    { from = 180, to = 210, craft = "Heavy Silk Bandage", id = 6451, count = 42,
      mats = "2 Silk Cloth each (84)",
      note = "Manual: Heavy Silk Bandage (~22s) from Deneb Walker (A) / Balai Lok'Wein (H)." },
    { from = 210, to = 225, craft = "Mageweave Bandage", id = 8544, count = 18,
      mats = "1 Mageweave Cloth each (18)",
      note = "Manual: Mageweave Bandage (~50s), same vendors. At 225 + lvl 35 do Triage: save 15 patients before 6 die (Triage Bandages supplied)." },
    { from = 225, to = 240, craft = "Mageweave Bandage", id = 8544, count = 24,
      mats = "1 Mageweave Cloth each (24)",
      note = "Needs Artisan (Triage) to pass 225." },
    { from = 240, to = 260, craft = "Heavy Mageweave Bandage", id = 8545, count = 25,
      mats = "2 Mageweave Cloth each (50)",
      note = "Taught by the Triage doctor (wowhandbook); Icy Veins calls this source unconfirmed in Forever." },
    { from = 260, to = 290, craft = "Runecloth Bandage", id = 14529, count = 42,
      mats = "1 Runecloth each (42)",
      note = "Taught by the Triage doctor (wowhandbook)." },
    { from = 290, to = 300, craft = "Heavy Runecloth Bandage", id = 14530, count = 11,
      mats = "2 Runecloth each (22)",
      note = "Taught by the Triage doctor (wowhandbook). Usable from 225 skill, heals 2000." },
  },
  recipes = {
    "NEW potions: Minor (trainer, 1), Lesser (55), Healing (110) from trainer; Greater (155, Manual drops from Syndicate Mercenary, Arathi), Superior (215, Manual), Major (275, quest)",
    "NEW Poultices (cure disease, out of combat): Simple 90 (trainer), Clever 140, Superior 210, Powerful 280",
    "NEW Tourniquets (cure bleed, out of combat): Woolen 120 (trainer), Leather 200, Surgical 265",
    "Anti-Venom 80 (trainer), Strong 130, NEW Potent 215, Powerful 300",
    "Camp: First Aid Kit (skill 20, trainer) - Stamina buff to seated allies",
    "Camp: Toxin Study (140; blueprint from Commander Springvale, Shadowfang Keep); Plague Doctor's Laboratory (300)",
    "Expert First Aid - Under Wraps item 16084; Legacy talent Field Medicine shortens Recently Bandaged (open world)",
  },
  source = "https://wowhandbook.com/professions/first-aid/",
}

---------------------------------------------------------------------------------------------------
-- FISHING
---------------------------------------------------------------------------------------------------
ns.PROFESSIONS["Fishing"] = {
  kind = "secondary",
  summary = "Fish for Cooking (incl. +Fishing foods), alchemy oils and camp items. Any water where you stop losing catches gives skill. New: starter fishing quests, camp Fish Bowl (+8% stats), uncommon/rare fish.",
  trainers = {
    Horde = "Apprentice + Journeyman: Lumak (Orgrimmar, Valley of Honor 69.7,29.3), Kah Mistrunner (Thunder Bluff), Armand Cromwell (Undercity, Magic Quarter), Lau'Tiki (south of Sen'jin), Uthan Stillwater (Bloodhoof), Clyde Kellen (Brightwater Lake), Kil'Hiwana (Zoram Strand), Lui'Mala (Shadowprey), Katoom the Angler (Revantusk). Neutral: Myizz Luckycatch (Booty Bay), Krix (Powderfuse Port, Riverglades), Baelann Swiftcurrent (Valanaar) + Fenn Fairweather (Shen'dar Village). Expert (125, lvl 20): book Expert Fishing - The Bass and You (~1g5s) from Old Man Heming, Booty Bay 27.4,77.0. Artisan (225, lvl 35): quest Nat Pagle, Angler Extreme, Dustwallow Marsh 58.6,60.0 (lead-in 'You Too Good.' from Lumak).",
    Alliance = "Apprentice + Journeyman: Arnold Leland (Stormwind, Trade District canal 55.1,69.6), Grimnur Stonebrand (Ironforge, Forlorn Cavern), Astaia (Darnassus), Androl Oakhand (Rut'theran), Lee Brown (Goldshire), Paxton Ganter (Iceflow Lake), Warg Deepwater (Thelsamar), Matthew Hooper (Lakeshire), Harold Riggs (Menethil), Donald Rabonne (Southshore), Hunter Moore (Hillsbrad), Brannock (Feathermoon). Neutral: Myizz Luckycatch (Booty Bay), Krix (Riverglades), Baelann Swiftcurrent + Fenn Fairweather (Zephras Isle). Expert (125, lvl 20): book from Old Man Heming, Booty Bay 27.4,77.0. Artisan (225, lvl 35): quest Nat Pagle, Angler Extreme, Dustwallow 58.6,60.0 (lead-in 'I Got Nothin' Left!' from Grimnur Stonebrand).",
  },
  steps = {
    { from = 1, to = 50, craft = "Fish starting-zone water",
      mats = "Fishing Pole (6256, ~23c) + Shiny Bauble (6529, +25)",
      note = "Horde: Durotar coast by Lau'Tiki, Stonebull Lake (Mulgore), Brightwater Lake (Tirisfal). Alliance: Crystal Lake by Lee Brown (Elwynn), Iceflow Lake (Dun Morogh), Lake Al'Ameth (Teldrassil). Both: Shen'dar Village / Valanaar (Zephras Isle). Quest: Camping 101: Fishing (lvl 6)." },
    { from = 50, to = 75, craft = "Fish starting-zone water",
      mats = "Fishing Pole",
      note = "Train Journeyman at 50 (wowhandbook: also level 10). Starter waters give no lost catches from 25. Catches: Brilliant Smallfish, Longjaw Mud Snapper, Slitherskin Mackerel." },
    { from = 75, to = 125, craft = "Fish a capital city or 10-20 zone",
      mats = "Fishing Pole",
      note = "Any capital works to 150. Horde: Lushwater Oasis, Barrens (Deviate Fish), Silverpine coast (Rainbow Fin Albacore). Alliance: Loch Modan by Warg Deepwater (Loch Frenzy), Auberdine coast (Darkshore)." },
    { from = 125, to = 150, craft = "Fish a capital city or 10-20 zone",
      mats = "Fishing Pole",
      note = "At 125 + lvl 20 read Expert Fishing - The Bass and You (item 16083, Old Man Heming, Booty Bay lower docks) - required past 150." },
    { from = 150, to = 225, craft = "Fish Stranglethorn coast or Dustwallow Marsh",
      mats = "Fishing Pole + Bright Baubles (6532, +75)",
      note = "Waters open at 130, no lost catches at 225 (Bright Baubles cover the gap). Booty Bay docks or Nat Pagle's island (Tidefury Cove, SW of Theramore). Catches: Mithril Head Trout, Rockscale Cod, Oily Blackmouth, Firefin Snapper." },
    { from = 225, to = 300, craft = "Fish Dustwallow Marsh / Tanaris / Feralas / Hinterlands",
      mats = "Fishing Pole + Bright Baubles while effective skill < 300",
      note = "Lvl 35: quest Nat Pagle, Angler Extreme - catch Feralas Ahi (Verdantis River), Sar'theris Striker (Sar'theris Strand, Desolace), Savage Coast Blue Sailfin (STV), Misty Reed Mahi Mahi (Swamp of Sorrows). Then stay at Nat's island, or Steamwheedle Port (Tanaris), Revantusk pier, Verdantis River." },
  },
  recipes = {
    "Poles: Blump Family (+3, Alliance quest, Darkshore), Strong Fishing Pole (+5, vendor), Ravaged (+15, world drop), Big Iron (+20, Shellfish Traps Desolace), Nat Pagle's Extreme Angler FC-5000 (+25, Horde quest Snapjaws, Mon!), Arcanite (+35, Extravaganza)",
    "Lures: Shiny Bauble +25, NEW \"Secret\" Bait +25, Nightcrawlers +50, Bright Baubles +75, Aquadynamic Fish Attractor +100",
    "NEW Fishing food: Loch Frenzy Delight +3, Fillet of Frenzy +5, Bristle Whisker Catfish +8, Rockscale Cod +12, Filet of Redgill +18, Spinefin Halibut +18",
    "Camp: Fish Bowl (skill 20, trainer) - all attributes +8%",
    "Camp: Fishing Rack (140; blueprint from Gelihast, Blackfathom Deeps) - uncommon fish + lures; Fishing Hut (300) - rare fish",
    "Starter quests: Camping 101: Fishing (lvl 6), Bottles and Baubles (Lee Brown, Goldshire, lvl 7), Fishin' Time (Gilbert Gray, Stormwind Harbor, lvl 12)",
    "Stranglethorn Fishing Extravaganza (Sun 2-4pm): Riggle Bassbait, 40 Speckled Tastyfish; NEW Extravagant Extravaganza Coin rewards (Jang)",
  },
  source = "https://wowhandbook.com/professions/fishing/",
}
