local _, ns = ...

-- Horde leveling route 1-60 for World of Warcraft: Forever (client 1.60.1).
-- Main spine: wowhandbook.com/leveling/horde/ (25 steps, levels per step).
-- Riverglades / Mount Hyjal / flight points: warcraftmaps.com (client data).
-- Dungeon level ranges + entrances + Horde quest IDs: local ForeverDungeonJournal
-- data (Dungeons.lua, DungeonEntrances.lua, QuestUpdates.lua). Class quests: not here.

local WH    = "https://wowhandbook.com/leveling/horde/"
local WH_DU = "https://wowhandbook.com/zones/kalimdor/durotar/"
local WH_MU = "https://wowhandbook.com/zones/kalimdor/mulgore/"
local WH_TI = "https://wowhandbook.com/zones/eastern-kingdoms/tirisfal-glades/"
local WH_ZE = "https://wowhandbook.com/zones/zephras-isle/"
local WM    = "https://warcraftmaps.com/guides/leveling-horde-1-60"
local WM_RG = "https://warcraftmaps.com/zone/2548/riverglades"
local WM_HY = "https://warcraftmaps.com/zone/2482/mount-hyjal"
local WM_SH = "https://warcraftmaps.com/zone/2652/shendralas"
local FDJ   = "ForeverDungeonJournal Data/Dungeons.lua + DungeonEntrances.lua (local)"

ns.AddSteps{
  ---------------------------------------------------------------------------
  -- Starting zones: Orc + Troll (Durotar)
  ---------------------------------------------------------------------------
  { id = "h_valley_of_trials", min = 1, max = 5,
    title = "Valley of Trials", zone = "Durotar", map = 1411, kind = "zone",
    text = "Kaltunk sends you to Gornek in the Den. Do Cutting Teeth, Wayward Weapons (new), Sting of the Scorpid, Galgar's Cactus Apple Surprise, Sarkoth and Lazy Peons. Thazz'ril's Pick is in the north cave. Then head east to Sen'jin / Razor Hill.",
    faction = "Horde", races = { "Orc", "Troll" }, reach = 5,
    wp = { { 1411, 43.3, 68.5, "Kaltunk" }, { 1411, 42.1, 68.3, "Gornek (the Den)" }, { 1411, 44.6, 68.7, "Foreman Thazz'ril" } },
    source = WH_DU },

  { id = "h_razor_hill", min = 5, max = 10,
    title = "Sen'jin & Razor Hill", zone = "Durotar", map = 1411, kind = "zone",
    text = "Sen'jin: Vornal/Gadrin (Echo Isles, Zalazane), Kolkar Crag plans. Razor Hill is the hub: hearth here. Gar'Thok & Orgnil (Tiragarde Keep, Benedict). Brakk's campfire: The Great Outdoors. New: Legging It, A Pain in the Neck, the naga beach chain.",
    faction = "Horde", races = { "Orc", "Troll" }, reach = 10,
    wp = { { 1411, 55.9, 74.4, "Master Vornal (Sen'jin)" }, { 1411, 52.0, 43.5, "Gar'Thok (Razor Hill)" },
           { 1411, 52.2, 43.1, "Orgnil Soulscar" }, { 1411, 52.0, 47.3, "Brakk (campfire)" } },
    source = WH_DU },

  { id = "h_durotar_north", min = 10, max = 12,
    title = "North Durotar & Orgrimmar", zone = "Durotar", map = 1411, kind = "zone",
    text = "Rezlak's road quests and Drygulch Ravine, Fizzle Darkstorm, Skull Rock collars for Margoz (Gazz'uz lvl 14 drops Eye of Burning Shadow). Turn in to Neeru Fireblade in Orgrimmar, get the Orgrimmar FP, then cross the Southfury bridge to Far Watch Post.",
    faction = "Horde", races = { "Orc", "Troll" }, reach = 12,
    wp = { { 1411, 46.4, 22.9, "Rezlak" }, { 1411, 56.4, 20.0, "Margoz" }, { 1411, 52.6, 8.8, "Gazz'uz (Skull Rock)" } },
    source = WH_DU },

  ---------------------------------------------------------------------------
  -- Starting zones: Tauren (Mulgore)
  ---------------------------------------------------------------------------
  { id = "h_camp_narache", min = 1, max = 5,
    title = "Camp Narache", zone = "Mulgore", map = 1412, kind = "zone",
    text = "Red Cloud Mesa. Grull Hawkwind (The Hunt Begins/Continues, Battleboars), Chief Hawkwind (A Humble Task), Seer Graytongue (Rite of Strength, new Grace of An'she and Mu'sha: run straight to the Ritual Fire). Sharptusk in Brambleblade Ravine. Then north to Bloodhoof.",
    faction = "Horde", races = { "Tauren" }, reach = 5,
    wp = { { 1412, 44.5, 77.5, "Grull Hawkwind" }, { 1412, 43.9, 76.7, "Chief Hawkwind" }, { 1412, 42.5, 90.1, "Seer Graytongue" } },
    source = WH_MU },

  { id = "h_bloodhoof", min = 5, max = 10,
    title = "Bloodhoof Village", zone = "Mulgore", map = 1412, kind = "zone",
    text = "Hearth at Bloodhoof. Kaga Wildhoof's campfire: The Great Outdoors. Mull Thunderhorn's well cleansings, Baine Bloodhoof's plains jobs, Morin Cloudstalker's Venture Co. mine. New: Longwalker Malah (Brave Wildrunner), Drive Them Out, The High Chieftain.",
    faction = "Horde", races = { "Tauren" }, reach = 10,
    wp = { { 1412, 46.7, 63.4, "Baine Bloodhoof" }, { 1412, 47.5, 63.6, "Mull Thunderhorn" },
           { 1412, 54.8, 64.3, "Morin Cloudstalker" }, { 1412, 46.2, 67.2, "Kaga Wildhoof (campfire)" } },
    source = WH_MU },

  { id = "h_mulgore_north", min = 9, max = 12,
    title = "North Mulgore & Thunder Bluff", zone = "Mulgore", map = 1412, kind = "zone",
    text = "Wildmane well, Windfury harpies, Seer Wiserunner (Rite of Wisdom), lead Perith Stormhoof out of Palemane Rock, Red Rocks (A Sacred Burial, Journey into Thunder Bluff). Take the Thunder Bluff FP, then leave by the southeast pass into the Barrens.",
    faction = "Horde", races = { "Tauren" }, reach = 12,
    wp = { { 1412, 34.3, 43.3, "Seer Wiserunner" }, { 1412, 57.0, 34.5, "Lorekeeper Raintotem" }, { 1412, 58.3, 30.7, "Ancestral Spirit" } },
    source = WH_MU },

  ---------------------------------------------------------------------------
  -- Starting zones: Undead (Tirisfal Glades)
  ---------------------------------------------------------------------------
  { id = "h_deathknell", min = 1, max = 5,
    title = "Deathknell", zone = "Tirisfal Glades", map = 1420, kind = "zone",
    text = "Undertaker Mordo > Shadow Priest Sarvis. Mindless Ones, Rattlecages, The Damned, Scavenging Deathknell, Night Web's Hollow, Scarlet farm armbands, Marla's Last Wish. New: A Light in the Darkness (Aramis Hammerhand). Take Vital Intelligence to Brill.",
    faction = "Horde", races = { "Scourge" }, reach = 5,
    wp = { { 1420, 30.2, 71.7, "Undertaker Mordo" }, { 1420, 30.8, 66.2, "Shadow Priest Sarvis" }, { 1420, 32.1, 66.0, "Executor Arren" } },
    source = WH_TI },

  { id = "h_brill", min = 5, max = 10,
    title = "Brill", zone = "Tirisfal Glades", map = 1420, kind = "zone",
    text = "On the way: Calvin Montague (duel), Gordo's Task. Hearth at Gallows' End. Zygand (Scarlet war, new Discipline), Holland (Doom Weed), Dillinger, Johaan, Coleman (Agamand Mills), Eleanor Shackleton's campfire (Great Outdoors). Maggot Eye in the north.",
    faction = "Horde", races = { "Scourge" }, reach = 10,
    wp = { { 1420, 60.6, 51.8, "Executor Zygand" }, { 1420, 57.4, 48.9, "Junior Apothecary Holland" },
           { 1420, 61.7, 52.3, "Coleman Farthing" }, { 1420, 57.2, 55.5, "Eleanor Shackleton (campfire)" } },
    source = WH_TI },

  { id = "h_tirisfal_late", min = 10, max = 13,
    title = "Tirisfal: Shadowvale & East", zone = "Tirisfal Glades", map = 1420, kind = "zone",
    text = "Forever raised quest/mob levels around Shadowvale and Bandarion Keep: stay longer than in Classic. Solliden pumpkins, Bareth Dawnstone (new), Hilda/Ephram in Shadowvale, Linnea & Hadric Harlson's new cult quests, Captain Melrache. Undercity FP; zeppelin towers east of Brill.",
    faction = "Horde", races = { "Scourge" }, reach = 13,
    wp = { { 1420, 21.9, 46.9, "Hilda the Breaker" }, { 1420, 65.5, 60.3, "Deathguard Linnea" }, { 1420, 65.9, 61.1, "Hadric Harlson" } },
    source = WH_TI },

  ---------------------------------------------------------------------------
  -- Starting zone: Windshaper Skyborne (Zephras Isle)
  ---------------------------------------------------------------------------
  { id = "h_thendal", min = 1, max = 5,
    title = "Thendal Village", zone = "Zephras Isle", map = 2521, kind = "zone",
    text = "Ailee Farheart > Rorian. Harmony in Balance, Cirrusflies (+Queen), Anchors of Zephras (use Halaan's Gift), Falling With Style (Walk on Air off the tower), Harvesting Windstones, Yala's Agitators, Urs'anah, Al'Aketh Thugs. The Next Step goes to Shen'dar.",
    faction = "Horde", races = { "Skyborne" }, reach = 5,
    wp = { { 2521, 42.8, 23.4, "Ailee Farheart" }, { 2521, 42.1, 23.5, "Rorian the Dayseeker" },
           { 2521, 43.8, 24.1, "Halaan Hawk-Eye" }, { 2521, 47.3, 21.9, "Yala Windwatcher" } },
    source = WH_ZE },

  { id = "h_shendar", min = 5, max = 10,
    title = "Shen'dar & Falaath Village", zone = "Zephras Isle", map = 2521, kind = "zone",
    text = "Hub: Constable Aonda. Illaya Amberwind (The Windshapers, Meddlesome Mages), Raan's campfire, prideclaws, bandits, hippogryph cliffs, Vulgara (elite). Cult chain: Sania Silverstream > Missionary Jasaan (wardrobe) > Falaath. Tip: buy 3 Small Egg + 8 Strider Meat on the AH.",
    faction = "Horde", races = { "Skyborne" }, reach = 10,
    wp = { { 2521, 45.6, 45.5, "Constable Aonda" }, { 2521, 43.5, 44.8, "Illaya Amberwind" },
           { 2521, 46.9, 56.2, "Missionary Jasaan" }, { 2521, 42.4, 62.0, "West Pylon Watchtower" } },
    source = WH_ZE },

  { id = "h_valanaar", min = 9, max = 13,
    title = "Valanaar & Shrine of Akir", zone = "Zephras Isle", map = 2521, kind = "zone",
    text = "Valennia Stormfist, Ayessa Dawnsinger, Talaanis Shadowsong. Windfield Orchard (Aamelia), East Pylon tower, The Turncoat, assault the Shrine of Akir, Confront Lorthuna. Then Shadowgale Forest: Elegael Thornpaw, the Strange Hermit, Windsong Lake refugees.",
    faction = "Horde", races = { "Skyborne" }, reach = 13,
    wp = { { 2521, 66.2, 76.6, "Valennia Stormfist" }, { 2521, 59.1, 79.7, "Ayessa Dawnsinger" },
           { 2521, 46.7, 82.0, "Aamelia Windfield" }, { 2521, 61.8, 39.1, "Elegael Thornpaw" } },
    source = WH_ZE },

  { id = "h_skyborne_join_horde", min = 12, max = 14,
    title = "Skyborne: Join the Horde", zone = "Mulgore", map = 1412, kind = "travel",
    text = "The Fate of Zephras > What Comes Next > The Earthen Ring (Ayessa). Horde airship at the SW dock of Valanaar lands in north Mulgore by Thunder Bluff. Hand in to Alaana Stormwalker, take Welcome to Azeroth to Thrall in Orgrimmar. Get the Thunder Bluff FP.",
    faction = "Horde", races = { "Skyborne" },
    quests = { { "The Earthen Ring" }, { "Welcome to Azeroth" } },
    wp = { { 2521, 57.9, 80.8, "Horde airship (Valanaar)" }, { 1412, 33.4, 22.5, "Alaana Stormwalker" } },
    source = WH_ZE },

  ---------------------------------------------------------------------------
  -- 12-21: race branches, then the Barrens
  ---------------------------------------------------------------------------
  { id = "h_silverpine", min = 12, max = 15,
    title = "Silverpine Forest", zone = "Silverpine Forest", map = 1421, kind = "zone",
    text = "Walk south from Tirisfal. The Sepulcher is the hub: take the FP. Quest Malden's Orchard, the Decrepit Ferry, Ambermill, Pyrewood (worgen respawn faster in Forever). At 15 take the zeppelin from the Tirisfal towers to Orgrimmar for the Barrens.",
    faction = "Horde", races = { "Scourge" }, reach = 15,
    wp = { { 1421, 43.4, 41.7, "The Sepulcher (FP)" }, { 1421, 58.4, 34.9, "The Decrepit Ferry" } },
    source = WH },

  { id = "h_barrens_crossroads", min = 12, max = 16,
    title = "Barrens: The Crossroads", zone = "The Barrens", map = 1413, kind = "zone",
    text = "Far Watch Post (Conscript of the Horde), then the Crossroads: take the FP and set your hearth. Work the northern Barrens from here and grab the Ratchet FP on the coast. If quests go green and turn-ins are 5 min apart, move on.",
    faction = "Horde", races = { "Orc", "Troll", "Tauren", "Skyborne" }, reach = 16,
    wp = { { 1413, 62.3, 19.4, "Far Watch Post" }, { 1413, 52.6, 29.8, "The Crossroads (FP)" }, { 1413, 62.7, 36.2, "Ratchet (FP)" } },
    source = WH },

  { id = "h_barrens", min = 15, max = 21,
    title = "The Barrens & Stonetalon", zone = "The Barrens", map = 1413, kind = "zone",
    text = "Crossroads > Ratchet > Camp Taurajo (FP; hearth here for the south). Bramblescar, Agama'gor, Field of Giants. Short trip into Stonetalon via Malaka'jin. Undead arrive here by zeppelin from Tirisfal at ~15. Leave at 21.",
    faction = "Horde", reach = 21,
    wp = { { 1413, 52.6, 29.8, "The Crossroads" }, { 1413, 44.5, 59.3, "Camp Taurajo (FP)" }, { 1442, 71.3, 95.0, "Malaka'jin" } },
    source = WH },

  ---------------------------------------------------------------------------
  -- Early dungeons
  ---------------------------------------------------------------------------
  { id = "h_dungeon_rfc", min = 13, max = 18,
    title = "Ragefire Chasm", zone = "Orgrimmar", map = 1454, kind = "dungeon",
    text = "Horde-only dungeon (13-18) in the Cleft of Shadow, Orgrimmar. Quests: Neeru Fireblade (Cleft of Shadow), Thrall (Valley of Wisdom), Rahauro (Thunder Bluff), Varimathras (Undercity).",
    faction = "Horde", optional = true, any = true,
    quests = { { "Slaying the Beast", 5761 }, { "Hidden Enemies", 5728 }, { "Testing an Enemy's Strength", 5723 }, { "The Power to Destroy...", 5725 } },
    wp = { { 1454, 52.6, 49.0, "Ragefire Chasm entrance" } },
    source = FDJ },

  { id = "h_dungeon_hall_of_thanes", min = 13, max = 20,
    title = "Hall of Thanes", zone = "Ironforge", map = 1455, kind = "dungeon",
    text = "New Forever dungeon (13-20) beneath Ironforge, the Alliance's counterpart to RFC. Both-faction quests An Ancient Grudge (inside) and Important Heirlooms (Thom Filch by the entrance). Hard to reach as Horde: needs a group.",
    faction = "Horde", optional = true, any = true,
    quests = { { "An Ancient Grudge", 96395 }, { "Important Heirlooms", 96403 } },
    wp = { { 1455, 43.5, 52.0, "Hall of Thanes entrance" } },
    source = FDJ },

  { id = "h_dungeon_rol", min = 15, max = 22,
    title = "Ruins of Lordaeron", zone = "Tirisfal Glades", map = 1420, kind = "dungeon",
    text = "New Forever dungeon (15-22) in the ruined city outside Undercity: through the front gate, stairs on the left. Quests: Tabitha Heartweaver (Sepulcher), Morbin Lightbane & Theodore Griffs (Undercity), Deathguard Kristof (Brill).",
    faction = "Horde", optional = true, any = true,
    quests = { { "A Frightened Request", 92401 }, { "Light's Justice", 92421 }, { "The New Plague", 95216 }, { "The Wrath of Rath'mael", 92422 } },
    wp = { { 1420, 63.4, 67.4, "Ruins of Lordaeron entrance" } },
    source = FDJ },

  { id = "h_dungeon_wc", min = 15, max = 24,
    title = "Wailing Caverns", zone = "The Barrens", map = 1413, kind = "dungeon",
    text = "Cave at Lushwater Oasis (15-24). Nalpak and Ebru stand above the entrance; Mebok Mizzyrix in Ratchet; Nara Wildmane (Leaders of the Fang) and Apothecary Zamah in Thunder Bluff.",
    faction = "Horde", optional = true, any = true,
    quests = { { "Deviate Hides", 1486 }, { "Deviate Eradication", 1487 }, { "Smart Drinks", 1491 }, { "Leaders of the Fang", 914 }, { "Serpentbloom", 962 } },
    wp = { { 1413, 46.0, 36.4, "Wailing Caverns entrance" } },
    source = FDJ },

  ---------------------------------------------------------------------------
  -- 21-30
  ---------------------------------------------------------------------------
  { id = "h_ashenvale_1", min = 21, max = 23,
    title = "Ashenvale", zone = "Ashenvale", map = 1440, kind = "zone",
    text = "North from the Barrens to Splintertree Post (FP), then west to Zoram'gar Outpost (FP) on the coast; touch both. Thistlefur Village. Then fly to Orgrimmar and zeppelin to Tirisfal for Silverpine (Beren's Peril) and Hillsbrad.",
    faction = "Horde", reach = 23,
    wp = { { 1440, 73.2, 61.6, "Splintertree Post (FP)" }, { 1440, 11.7, 34.9, "Zoram'gar Outpost (FP)" } },
    source = WH },

  { id = "h_dungeon_sfk", min = 20, max = 30,
    title = "Shadowfang Keep", zone = "Silverpine Forest", map = 1421, kind = "dungeon",
    text = "Entrance north of Pyrewood Village (20-30). Quests at the Sepulcher: High Executor Hadrec, Dalar Dawnweaver, Lumina Windsinger (Old Fire-Eye); Keeper Bel'dugur in the Apothecarium; Doan Karhan in the Barrens.",
    faction = "Horde", optional = true, any = true,
    quests = { { "Deathstalkers in Shadowfang", 1098 }, { "Arugal Must Die", 1014 }, { "The Book of Ur", 1013 }, { "Old Fire-Eye", 95140 }, { "The Orb of Soran'ruk", 1740 } },
    wp = { { 1421, 44.8, 67.8, "Shadowfang Keep entrance" } },
    source = FDJ },

  { id = "h_hillsbrad_1", min = 22, max = 25,
    title = "Hillsbrad Foothills", zone = "Hillsbrad Foothills", map = 1424, kind = "zone",
    text = "Tarren Mill: take the FP and set your hearth. Quest Hillsbrad Fields and a short loop into Alterac Mountains, then back to Tarren Mill. Respawns were raised in Forever. Fly to the Sepulcher / Undercity for turn-ins, then back to Kalimdor.",
    faction = "Horde", reach = 25,
    wp = { { 1424, 61.4, 19.1, "Tarren Mill (FP)" } },
    source = WH },

  { id = "h_stonetalon", min = 24, max = 26,
    title = "Stonetalon & South Barrens", zone = "Stonetalon Mountains", map = 1442, kind = "zone",
    text = "Through Malaka'jin to Sun Rock Retreat: FP and hearth. Then south Barrens from Camp Taurajo: Bael Modan, Blackthorn Ridge. Finish via the Great Lift toward Thousand Needles.",
    faction = "Horde", reach = 26,
    wp = { { 1442, 47.4, 64.3, "Sun Rock Retreat (FP)" }, { 1413, 45.1, 57.7, "Camp Taurajo" }, { 1413, 65.8, 43.9, "The Tidus Stair" } },
    source = WH },

  { id = "h_dungeon_bfd", min = 24, max = 32,
    title = "Blackfathom Deeps", zone = "Ashenvale", map = 1440, kind = "dungeon",
    text = "Entrance on the Zoram Strand, NW Ashenvale (24-32), close to Zoram'gar. Je'neu Sancrea at Zoram'gar gives most quests; Tsunaman in Stonetalon gives Trouble in the Deeps.",
    faction = "Horde", optional = true, any = true,
    quests = { { "The Essence of Aku'Mai", 6563 }, { "Allegiance to the Old Gods", 6565 }, { "Amongst the Ruins", 6921 }, { "Trouble in the Deeps", 6562 } },
    wp = { { 1440, 14.5, 14.2, "Blackfathom Deeps entrance" }, { 1440, 12.0, 34.0, "Je'neu Sancrea" } },
    source = FDJ },

  { id = "h_ashenvale_needles", min = 26, max = 30,
    title = "Ashenvale & Thousand Needles", zone = "Thousand Needles", map = 1441, kind = "zone",
    text = "Fly to Zoram'gar, then Splintertree (Mystral Lake). Thunder Bluff/Mulgore turn-ins. Then Freewind Post: FP and hearth; Splithoof, Darkcloud Pinnacle, Highperch, Whitereach Post. The Shimmering Flats are stored at 35: skip them until quests send you.",
    faction = "Horde", reach = 30,
    wp = { { 1440, 11.6, 34.3, "Zoram'gar Outpost" }, { 1440, 73.1, 61.5, "Splintertree Post" },
           { 1441, 44.9, 48.9, "Freewind Post (FP)" }, { 1441, 21.5, 32.4, "Whitereach Post" } },
    source = WH },

  { id = "h_dungeon_excavation", min = 26, max = 33,
    title = "Excavation Site: Wetlands", zone = "Wetlands", map = 1437, kind = "dungeon",
    text = "New dungeon (26-33): blue mist portal under a big tree in the hills SE of Whelgar's Excavation, reached from Thelgen Rock. Horde quests: Borstan (The Drag, Orgrimmar), Bashana Runetotem (Thunder Bluff), Deathstalker Agent outside.",
    faction = "Horde", optional = true, any = true,
    quests = { { "Changing Tastes", 95697 }, { "Earthen Echo", 98823 }, { "Open the Maw", 95682 } },
    wp = { { 1437, 47.7, 56.2, "Excavation Site entrance" } },
    source = FDJ },

  { id = "h_dungeon_rfk", min = 29, max = 38,
    title = "Razorfen Kraul", zone = "The Barrens", map = 1413, kind = "dungeon",
    text = "Southern Barrens at the end of the thorny corridor (29-38). Quests: Mebok Mizzyrix (Ratchet), Auld Stonespire (Thunder Bluff), Master Apothecary Faranell (Undercity), Willix inside.",
    faction = "Horde", optional = true, any = true,
    quests = { { "Blueleaf Tubers", 1221 }, { "A Vengeful Fate", 1102 }, { "Going, Going, Guano!", 1109 }, { "Willix the Importer", 1144 } },
    wp = { { 1413, 42.9, 90.2, "Razorfen Kraul entrance" } },
    source = FDJ },

  ---------------------------------------------------------------------------
  -- 29-38
  ---------------------------------------------------------------------------
  { id = "h_hillsbrad_arathi", min = 29, max = 33,
    title = "Hillsbrad & Arathi", zone = "Arathi Highlands", map = 1417, kind = "zone",
    text = "Fly to Tarren Mill (hearth): Hillsbrad Fields, Durnholde Keep, Azurelode Mine, Dun Garok, Alterac loops. Then east into Arathi: Hammerfall FP, Witherbark Village. Fly to Undercity to finish.",
    faction = "Horde", reach = 33,
    wp = { { 1424, 62.3, 20.4, "Tarren Mill" }, { 1417, 72.6, 33.9, "Hammerfall (FP)" } },
    source = WH },

  { id = "h_dungeon_dalaran", min = 28, max = 33,
    title = "City of Dalaran", zone = "Alterac Mountains", map = 1416, kind = "dungeon",
    text = "New dungeon (28-33): drop through a street grate in Dalaran and follow the Underbelly pipe to the portal. Horde quests: Melisara (Tarren Mill), Doctor Martin Felben (Undercity), Archmage Modera's image at Lordamere Lake.",
    faction = "Horde", optional = true, any = true,
    quests = { { "The Grave Knight", 96986 }, { "Source of Power", 96988 }, { "Heart of Disruption", 96984 } },
    wp = { { 1416, 8.5, 59.3, "City of Dalaran entrance" } },
    source = FDJ },

  { id = "h_dungeon_sm", min = 30, max = 45,
    title = "Scarlet Monastery", zone = "Tirisfal Glades", map = 1420, kind = "dungeon",
    text = "NE Tirisfal. Wings: Graveyard 30-38, Library 33-41, Armory 34-42, Cathedral 36-45 (Armory/Cathedral need the Scarlet Key from Library). Quests: Varimathras & Faranell (Undercity), Sage Truthseeker (Thunder Bluff), Vorrel inside GY.",
    faction = "Horde", optional = true, any = true,
    quests = { { "Into The Scarlet Monastery", 1048 }, { "Hearts of Zeal", 1113 }, { "Compendium of the Fallen", 1049 }, { "Vorrel's Revenge", 1051 } },
    wp = { { 1420, 82.6, 33.8, "Scarlet Monastery entrance" } },
    source = FDJ },

  { id = "h_needles_desolace", min = 32, max = 34,
    title = "Needles Raceway & Desolace", zone = "Desolace", map = 1443, kind = "zone",
    text = "Mirage Raceway quests in Thousand Needles, then fly to Sun Rock and enter Desolace: Ghost Walker Post, Kodo Graveyard, Shadowprey Village (FP, hearth), Ethel Rethor, Thunder Axe Fortress. Gelkis/Magram 'Valley of Bones' quests need 35 now.",
    faction = "Horde", reach = 34,
    wp = { { 1441, 77.8, 77.3, "Mirage Raceway" }, { 1443, 56.2, 59.6, "Ghost Walker Post" }, { 1443, 25.4, 67.2, "Shadowprey Village (FP)" } },
    source = WH },

  { id = "h_stv_1", min = 34, max = 36,
    title = "Stranglethorn Vale", zone = "Stranglethorn Vale", map = 1434, kind = "zone",
    text = "Fly to Ratchet and take the boat to Booty Bay: take the FP. Quest out of Booty Bay (Vile Reef etc.). Grom'gol has zeppelins to Orgrimmar and Undercity.",
    faction = "Horde", reach = 36,
    wp = { { 1434, 26.4, 73.6, "Booty Bay (FP)" }, { 1434, 32.3, 27.7, "Grom'gol Base Camp" } },
    source = WH },

  { id = "h_dungeon_drowned_city", min = 35, max = 40,
    title = "The Drowned City", zone = "Stranglethorn Vale", map = 1434, kind = "dungeon",
    text = "New dungeon (35-40). Underwater west of the Vile Reef: swim to Sunken Hollow by the water-elemental island; cave with a large tablet. Quests: Kin'weelay & Commander Aggro'gosh (Grom'gol), Krazek (Booty Bay), Mazu'kon (Mulgore).",
    faction = "Horde", optional = true, any = true,
    quests = { { "The Drowned City", 95775 }, { "The Only Good Brinescale...", 95776 }, { "Shady Saltseers", 95789 }, { "Ancient Gurubashi Idol", 96774 } },
    wp = { { 1434, 21.4, 27.9, "Drowned City entrance" } },
    source = FDJ },

  { id = "h_dustwallow_desolace", min = 36, max = 38,
    title = "Dustwallow & Desolace", zone = "Dustwallow Marsh", map = 1445, kind = "zone",
    text = "Fly to Camp Taurajo and walk in: Shady Rest Inn, then Brackenwall Village (FP). Then fly to Shadowprey for Desolace: Ghost Walker Post, Valley of Spears, and the Gelkis/Magram Valley of Bones quests (min level 35 in Forever).",
    faction = "Horde", reach = 38,
    wp = { { 1445, 35.1, 38.3, "Brackenwall Village (FP)" }, { 1445, 29.7, 47.6, "Shady Rest Inn" }, { 1443, 25.8, 68.2, "Shadowprey Village" } },
    source = WH },

  { id = "h_shendralas", min = 37, max = 43,
    title = "Shen'dralas (side trip)", zone = "Shen'dralas", map = 2652, kind = "zone",
    text = "New area between Mulgore and Desolace, opened by the Valley of Bones chains (35+). No FP. Pylon chain: Shen'dralar Pylon > Mordent Evenshade > pylon shards from the Magram/Gelkis camps > Magister Kirandis > Mithera. Leads to Maraudon quests.",
    faction = "Horde", optional = true,
    quests = { { "Strange Pylons", 92914 }, { "Fragments of the Pylons", 96010 }, { "Powering the Pylons", 96018 }, { "A Brief History Lesson", 93016 },
               { "Meeting the Magister", 93394 }, { "Forlorn Gardens", 93341 }, { "Word of the Woods", 93594 } },
    wp = { { 2652, 43.6, 34.2, "Shen'dralar Pylon" }, { 2652, 35.0, 46.4, "Mordent Evenshade" },
           { 2652, 47.2, 75.8, "Magister Kirandis" }, { 2652, 52.8, 76.0, "Mithera" } },
    source = WM_SH },

  { id = "h_dungeon_rfd", min = 37, max = 46,
    title = "Razorfen Downs", zone = "The Barrens", map = 1413, kind = "dungeon",
    text = "Far south of the Barrens at the Thousand Needles border, through the thorny tunnel (37-46). Quests: Andrew Brownell & Varimathras (Undercity), Myriam Moonsinger (thorn maze), Belnistrasz inside.",
    faction = "Horde", optional = true, any = true,
    quests = { { "Bring the End", 3341 }, { "An Unholy Alliance", 6521 }, { "A Host of Evil", 6626 }, { "Extinguishing the Idol", 3525 } },
    wp = { { 1413, 50.0, 92.0, "Razorfen Downs entrance" } },
    source = FDJ },

  ---------------------------------------------------------------------------
  -- 37-45: Riverglades (new) and the classic alternatives
  ---------------------------------------------------------------------------
  { id = "h_riverglades_pickups", min = 37, max = 38,
    title = "Riverglades pickups", zone = "Stranglethorn Vale", map = 1434, kind = "quest",
    text = "Breadcrumbs before Riverglades: Report to Rog'mar (Commander Aggro'gosh, Grom'gol), Finding Tan'jani (Tor'gan, Hammerfall), Armory of Sunnyglade (Mirelle Tremayne, Undercity), Overseas Delivery (Innkeeper Fizzgrimble, Gadgetzan).",
    faction = "Horde", optional = true,
    wp = { { 1434, 32.2, 28.8, "Commander Aggro'gosh" }, { 1417, 74.4, 36.2, "Tor'gan" },
           { 1458, 61.4, 28.4, "Mirelle Tremayne" }, { 1446, 52.4, 27.8, "Innkeeper Fizzgrimble" } },
    source = WM_RG },

  { id = "h_riverglades", min = 38, max = 44,
    title = "Riverglades: Rog'mar", zone = "Riverglades", map = 2548, kind = "zone",
    text = "New 150+ quest zone (SE Khaz Modan). Boat Steamwheedle Port (Tanaris) > Powderfuse Port, road to Rog'mar (Horde FP, hub). Tran'gul: Encroaching Twilight; Clugfist's Decree; Krom'rosh > Da'grosh (Twilight's Shroud). Rog'mar-Stonard flight.",
    faction = "Horde", reach = 44,
    wp = { { 2548, 80.6, 54.6, "Powderfuse Port (boat)" }, { 2548, 59.6, 45.1, "Rog'mar (FP)" },
           { 2548, 59.4, 44.0, "Tran'gul" }, { 2548, 59.4, 45.5, "Krom'rosh" },
           { 2548, 64.4, 14.8, "Clugfist" }, { 2548, 33.4, 38.0, "Da'grosh" } },
    source = WM_RG },

  { id = "h_alterac_arathi", min = 38, max = 39,
    title = "Alterac, Hillsbrad & Arathi", zone = "Arathi Highlands", map = 1417, kind = "zone",
    text = "Alternative to Riverglades. Fly to Tarren Mill, short Alterac/Hillsbrad loop, then Arathi: Northfold Manor, Hammerfall, Drywhisker Gorge, Boulderfist Hall, Circle of West Binding and Faldir's Cove in the SW.",
    faction = "Horde", reach = 39,
    wp = { { 1417, 74.2, 33.9, "Hammerfall" }, { 1417, 31.8, 82.7, "Faldir's Cove" } },
    source = WH },

  { id = "h_badlands", min = 39, max = 40,
    title = "Badlands", zone = "Badlands", map = 1418, kind = "zone",
    text = "Kargath: FP and hearth. Valley of Fangs, the Dustbowl, Agmond's End. Uldaman is in the north of the zone.",
    faction = "Horde", reach = 40,
    wp = { { 1418, 6.5, 47.2, "Kargath (FP)" }, { 1418, 42.2, 52.7, "Valley of Fangs" }, { 1418, 51.4, 76.9, "Agmond's End" } },
    source = WH },

  { id = "h_dungeon_uldaman", min = 38, max = 48,
    title = "Uldaman", zone = "Badlands", map = 1418, kind = "dungeon",
    text = "Northern Badlands, through the excavation cave north of Angor Fortress (38-48). Quests: Jarkal Mossmeld (Kargath), Theldurin the Lost, Rigglefuzz, Patrick Garrett (Undercity), Dran Droffers (Orgrimmar).",
    faction = "Horde", optional = true, any = true,
    quests = { { "Uldaman Reagent Run", 2202 }, { "Find the Gems and Power Source", 2339 }, { "Solution to Doom", 709 }, { "Power Stones", 2418 }, { "Reclaimed Treasures", 2342 } },
    wp = { { 1418, 44.3, 12.0, "Uldaman entrance" } },
    source = FDJ },

  { id = "h_stv_swamp", min = 39, max = 43,
    title = "Stranglethorn & Swamp", zone = "Stranglethorn Vale", map = 1434, kind = "zone",
    text = "Fly to Grom'gol (hearth). Big STV pass: Grom'gol, Booty Bay, Nesingwary's Expedition. Then through Duskwood to Swamp of Sorrows: Stonard FP and hearth.",
    faction = "Horde", reach = 43,
    wp = { { 1434, 32.3, 27.7, "Grom'gol Base Camp" }, { 1434, 28.3, 77.6, "Booty Bay" },
           { 1434, 35.7, 10.8, "Nesingwary's Expedition" }, { 1435, 44.7, 57.2, "Stonard (FP)" } },
    source = WH },

  { id = "h_dungeon_kroldok", min = 40, max = 45,
    title = "Krol'dok Stronghold", zone = "Riverglades", map = 2548, kind = "dungeon",
    text = "New dungeon (40-45). North Riverglades on the hill above Sunnyglade: the small cave just west of the big fortress gates. Quests open after the Riverglades Twilight chain: Krom'rosh, Tran'gul, Kreza Darkthorn (Rog'mar), Da'grosh.",
    faction = "Horde", optional = true, any = true,
    quests = { { "Eye of Mugg", 94968 }, { "Tome of Twilight", 94972 }, { "A Token of Vengeance", 94975 }, { "Key Ingredients", 94974 } },
    wp = { { 2548, 37.5, 37.3, "Krol'dok Stronghold entrance" }, { 2548, 59.8, 46.0, "Kreza Darkthorn" } },
    source = FDJ },

  ---------------------------------------------------------------------------
  -- 43-50
  ---------------------------------------------------------------------------
  { id = "h_tanaris_feralas", min = 43, max = 45,
    title = "Needles, Tanaris & Feralas", zone = "Tanaris", map = 1446, kind = "zone",
    text = "Mirage Raceway turn-ins, then Tanaris: Gadgetzan FP, Steamwheedle Port. Fly to Freewind and go to Feralas: Camp Mojache (FP, hearth), Gordunni Outpost, the Writhing Deep. Fly to Orgrimmar for turn-ins.",
    faction = "Horde", reach = 45,
    wp = { { 1441, 80.2, 75.9, "Mirage Raceway" }, { 1446, 50.2, 27.5, "Gadgetzan (FP)" },
           { 1446, 66.6, 22.3, "Steamwheedle Port" }, { 1444, 75.7, 44.3, "Camp Mojache (FP)" } },
    source = WH },

  { id = "h_dungeon_zf", min = 43, max = 50,
    title = "Zul'Farrak", zone = "Tanaris", map = 1446, kind = "dungeon",
    text = "NW Tanaris at the gate of the troll city (43-50). Quests: Chief Engineer Bilgewhizzle & Trenton Lighthammer (Gadgetzan), Yeh'kinya (Steamwheedle Port), Master Gadrin (Sen'jin), Wizzle Brassbolts (Shimmering Flats).",
    faction = "Horde", optional = true, any = true,
    quests = { { "Divino-matic Rod", 2768 }, { "Troll Temper", 3042 }, { "The Prophecy of Mosh'aru", 3527 }, { "The Spider God", 2936 }, { "Gahz'rilla", 2770 } },
    wp = { { 1446, 38.7, 20.0, "Zul'Farrak entrance" } },
    source = FDJ },

  { id = "h_dungeon_maraudon", min = 45, max = 52,
    title = "Maraudon", zone = "Desolace", map = 1443, kind = "dungeon",
    text = "Western Desolace: through the Valley of Spears into the cave below the Maraudon cliffs (45-52). In Forever its quest Rot and Regret is unlocked through the Shen'dralas pylon chain (Mithera > Woodwyrd).",
    faction = "Horde", optional = true,
    wp = { { 1443, 29.1, 62.5, "Maraudon entrance" } },
    source = FDJ },

  { id = "h_swamp_dustwallow", min = 45, max = 47,
    title = "Swamp, Dustwallow, Feralas", zone = "Swamp of Sorrows", map = 1435, kind = "zone",
    text = "Fly to Stonard: Pool of Tears, Misty Reed Post. Then Dustwallow from Brackenwall Village and Feralas turn-ins at Camp Mojache (hearth). Fel'Zerul in Stonard starts the Sunken Temple quest.",
    faction = "Horde", reach = 47,
    wp = { { 1435, 44.7, 57.2, "Stonard" }, { 1435, 81.3, 81.0, "Misty Reed Post" },
           { 1445, 36.3, 31.4, "Brackenwall Village" }, { 1444, 74.4, 43.4, "Camp Mojache" } },
    source = WH },

  { id = "h_tanaris_searing", min = 46, max = 48,
    title = "Tanaris & Searing Gorge", zone = "Searing Gorge", map = 1427, kind = "zone",
    text = "Gadgetzan (hearth) for the big Tanaris pass, Sandsorrow Watch, Steamwheedle Port. Then Searing Gorge: Thorium Point FP, the Slag Pit. Blackrock Mountain is at the south end.",
    faction = "Horde", reach = 48,
    wp = { { 1446, 51.6, 26.8, "Gadgetzan" }, { 1427, 37.6, 26.5, "Thorium Point (FP)" } },
    source = WH },

  { id = "h_dungeon_alcaz", min = 48, max = 53,
    title = "Alcaz Prison", zone = "Dustwallow Marsh", map = 1445, kind = "dungeon",
    text = "New dungeon (48-53) on Alcaz Island off NE Dustwallow: from the dock take the path up the hill to the prison building at the north end; the portal is in its cellar.",
    faction = "Horde", optional = true,
    wp = { { 1445, 75.3, 14.1, "Alcaz Prison entrance" } },
    source = FDJ },

  { id = "h_dungeon_st", min = 49, max = 56,
    title = "Sunken Temple", zone = "Swamp of Sorrows", map = 1435, kind = "dungeon",
    text = "Dive into the Pool of Tears and follow the stairs down (49-56). Quests: Fel'Zerul (Stonard), Marvon Rivetseeker & Yeh'kinya (Tanaris), Atal'ai Exile (Hinterlands), Liv Rizzlefix (Ratchet).",
    faction = "Horde", optional = true, any = true,
    quests = { { "The Temple of Atal'Hakkar", 1445 }, { "Into the Depths", 3446 }, { "The God Hakkar", 3528 }, { "Jammal'an the Prophet", 1446 }, { "Zapper Fuel", 4146 } },
    wp = { { 1435, 69.5, 53.5, "Sunken Temple entrance" } },
    source = FDJ },

  { id = "h_hinterlands", min = 48, max = 50,
    title = "Hinterlands & Blasted Lands", zone = "The Hinterlands", map = 1425, kind = "zone",
    text = "Fly to Tarren Mill and ride to Revantusk Village: FP and hearth. Skulk Rock, Jintha'Alor. Then fly to Stonard for Swamp turn-ins and a Blasted Lands pass (no Horde FP there).",
    faction = "Horde", reach = 50,
    wp = { { 1425, 77.2, 80.1, "Revantusk Village (FP)" }, { 1425, 59.7, 77.8, "Jintha'Alor" } },
    source = WH },

  ---------------------------------------------------------------------------
  -- 50-60
  ---------------------------------------------------------------------------
  { id = "h_azshara_feralas", min = 50, max = 51,
    title = "STV, Azshara, Feralas", zone = "Azshara", map = 1447, kind = "zone",
    text = "STV finish (Grom'gol, Booty Bay), then from Orgrimmar ride into Azshara: Valormok FP, Thalassian Base Camp. Camp Mojache and Gadgetzan turn-ins.",
    faction = "Horde", reach = 51,
    wp = { { 1447, 28.1, 50.1, "Valormok (FP)" }, { 1434, 27.2, 77.0, "Booty Bay" } },
    source = WH },

  { id = "h_ungoro_steppes", min = 51, max = 53,
    title = "Un'Goro & Burning Steppes", zone = "Un'Goro Crater", map = 1449, kind = "zone",
    text = "Un'Goro: Marshal's Refuge FP, Slithering Scar, Lakkari Tar Pits. Gadgetzan turn-ins, then Badlands into Burning Steppes: Flame Crest FP. Fly to Undercity and start the Bulwark quests in east Tirisfal.",
    faction = "Horde", reach = 53,
    wp = { { 1449, 45.5, 8.7, "Marshal's Refuge (FP)" }, { 1428, 65.2, 23.9, "Flame Crest (FP)" }, { 1420, 83.3, 72.3, "The Bulwark" } },
    source = WH },

  { id = "h_plaguelands_felwood", min = 53, max = 55,
    title = "Plaguelands & Felwood", zone = "Felwood", map = 1448, kind = "zone",
    text = "The Bulwark (High Executor Derrington, Argent Officer Garush) for WPL/EPL: no Horde FP in Western Plaguelands, walk in from Tirisfal. Then fly to Splintertree for Felwood: Bloodvenom Post FP, Emerald Sanctuary, Irontree Woods, Felpaw Village.",
    faction = "Horde", reach = 55,
    wp = { { 1420, 83.1, 68.9, "High Executor Derrington" }, { 1448, 50.9, 81.6, "Emerald Sanctuary" }, { 1448, 65.7, 2.8, "Felpaw Village" } },
    source = WH },

  { id = "h_winterspring", min = 55, max = 56,
    title = "Winterspring", zone = "Winterspring", map = 1452, kind = "zone",
    text = "Through Timbermaw Hold to Everlook: FP and hearth. Winterfall Village. Then fly to Camp Mojache, Thunder Bluff and Orgrimmar for turn-ins.",
    faction = "Horde", reach = 56,
    wp = { { 1452, 60.9, 37.6, "Everlook (FP)" } },
    source = WH },

  { id = "h_mount_hyjal", min = 55, max = 60,
    title = "Mount Hyjal", zone = "Mount Hyjal", map = 2482, kind = "zone",
    text = "New 55-60 zone (138 quests) beside Winterspring/Felwood. Pick up The Source of the Corruption from Greta Mosshoof (Emerald Sanctuary). Hub and FP: Tainted Foothills; Summit of Eternity FP. Tainted Foothills flies to Everlook.",
    faction = "Horde", optional = true,
    wp = { { 1448, 51.2, 82.2, "Greta Mosshoof" }, { 2482, 55.1, 82.5, "Tainted Foothills (FP)" }, { 2482, 68.6, 44.1, "Summit of Eternity (FP)" } },
    source = WM_HY },

  { id = "h_dungeon_endgame", min = 52, max = 60,
    title = "BRD, Spire, Dire Maul, Blackmaw", zone = "Burning Steppes", map = 1428, kind = "dungeon",
    text = "Blackrock Mountain: BRD 52-60 (chain down from the Spire ledge), LBRS/UBRS 55-60. Dire Maul (central Feralas) East 55-60, West/North 57-60. New Blackmaw Hold 55-60, N Azshara: Nara Wildmane (TB), Muln Earthfury (Mulgore), Ogtinc.",
    faction = "Horde", optional = true, any = true,
    quests = { { "Get to the Roots of It", 92343 }, { "Blackmaw Magic", 97198 }, { "Claws That Rend, Tusks that Gore", 92069 } },
    wp = { { 1427, 34.8, 84.0, "Blackrock Mountain" }, { 1444, 59.0, 45.0, "Dire Maul" }, { 1447, 38.6, 33.2, "Blackmaw Hold" } },
    source = FDJ },

  { id = "h_azshara_wpl", min = 56, max = 57,
    title = "Azshara & West Plaguelands", zone = "Western Plaguelands", map = 1422, kind = "zone",
    text = "Barrens turn-ins (fly to Ratchet), Azshara from Valormok (Ruins of Eldarath). Then Undercity > Tirisfal > walk into Western Plaguelands (no Horde FP): Felstone Field. Get the Light's Hope Chapel FP in EPL.",
    faction = "Horde", reach = 57,
    wp = { { 1447, 22.3, 51.5, "Valormok" }, { 1422, 37.3, 56.8, "Felstone Field" }, { 1423, 69.9, 53.7, "Light's Hope Chapel (FP)" } },
    source = WH },

  { id = "h_silithus", min = 57, max = 59,
    title = "Silithus & Plaguelands", zone = "Silithus", map = 1451, kind = "zone",
    text = "Cenarion Hold: FP and hearth; Twilight camps. Un'Goro turn-ins at Marshal's Refuge. Then fly to Orgrimmar and finish WPL (Northridge, Dalson's Tears), the Bulwark and EPL (Light's Hope).",
    faction = "Horde", reach = 59,
    wp = { { 1451, 51.6, 38.6, "Cenarion Hold (FP)" }, { 1422, 48.3, 32.0, "Northridge Lumber Camp" }, { 1420, 83.0, 71.9, "The Bulwark" } },
    source = WH },

  { id = "h_dungeon_strat_scholo", min = 58, max = 60,
    title = "Stratholme, Scholo, Shaper's", zone = "Eastern Plaguelands", map = 1423, kind = "dungeon",
    text = "Stratholme 58-60: main gate NW EPL, service entrance N. Scholomance 58-60: Caer Darrow, WPL. New: Shaper's Terrace 58-60 above Marshal's Refuge (Mayena Earthseeker in Mulgore: Crystalline Elements).",
    faction = "Horde", optional = true, any = true,
    quests = { { "Crystalline Elements", 95928 } },
    wp = { { 1423, 30.0, 15.0, "Stratholme main gate" }, { 1422, 69.7, 73.2, "Scholomance" }, { 1449, 48.1, 6.1, "Shaper's Terrace" } },
    source = FDJ },

  { id = "h_felwood_winterspring_60", min = 59, max = 60,
    title = "Felwood, Moonglade, 60", zone = "Winterspring", map = 1452, kind = "zone",
    text = "Fly to Splintertree for Felwood, through Moonglade to Winterspring, Darkwhisper Gorge and Everlook. Level 60: the route ends here.",
    faction = "Horde", reach = 60,
    wp = { { 1452, 60.9, 37.6, "Everlook" } },
    source = WH },
}
