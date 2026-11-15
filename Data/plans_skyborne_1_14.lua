local _, ns = ...
-- Zephras Isle (uiMapID 2521), Skyborne levels 1-14, both factions.
-- Order: wowhandbook.com/zones/zephras-isle/ (Alliance + Horde routes); quest IDs, givers and spawn
-- coords: QuestieDB Forever (baked TOC data). Class quests (Call of Earth, Taming the Beast, ...) left out.

local Z = 2521
local function W(x, y, label) return { Z, x, y, label } end

---------------------------------------------------------------------------
-- Thendal Grove / Thendal Village (1-5)
---------------------------------------------------------------------------
local function thendal(horde)
  local racialAccept = horde
    and { act = "accept", quest = { "The Gift of Skysight", 92598 }, npc = "Ventaari Brightwish", wp = W(42.6, 24.4, "Ventaari Brightwish") }
    or  { act = "accept", quest = { "Reading the Leylines", 92597 }, npc = "Falorne Fallwind", wp = W(43.3, 24.9, "Falorne Fallwind") }
  local racialUse = horde
    and { act = "use", quest = { "The Gift of Skysight", 92598 }, text = "Cast Skysight at the Elemental Convergence NE of Yala", wp = W(48.3, 20.6, "Elemental Convergence") }
    or  { act = "use", quest = { "Reading the Leylines", 92597 }, text = "Cast Read Leyline at the ley line north of Yala", wp = W(46.3, 17.9, "Ley Line") }
  local racialTurnin = horde
    and { act = "turnin", quest = { "The Gift of Skysight", 92598 }, npc = "Ventaari Brightwish", wp = W(42.6, 24.4, "Ventaari Brightwish") }
    or  { act = "turnin", quest = { "Reading the Leylines", 92597 }, npc = "Falorne Fallwind", wp = W(43.3, 24.9, "Falorne Fallwind") }
  return {
    { act = "note",   text = "Tip: brush past a small tornado for Blessing of Zephras (+40% run speed, 5 min) before long runs" },
    { act = "accept", quest = { "Coming of Age", 92460 }, npc = "Ailee Farheart", wp = W(42.8, 23.4, "Ailee Farheart") },
    { act = "turnin", quest = { "Coming of Age", 92460 }, npc = "Rorian the Dayseeker", wp = W(42.1, 23.5, "Rorian the Dayseeker") },
    { act = "accept", quest = { "Harmony in Balance", 92461 }, npc = "Rorian the Dayseeker", wp = W(42.1, 23.5, "Rorian the Dayseeker") },
    { act = "note",   text = "Rorian also hands out your class quest (train at the class trainer in the grove)" },
    { act = "accept", quest = { "Infestation Investigation", 92462 }, npc = "Elatrell Featherlight", wp = W(43.4, 24.8, "Elatrell Featherlight") },
    { act = "accept", quest = { "The Anchors of Zephras", 94414 }, npc = "Halaan Hawk-Eye", wp = W(43.8, 24.1, "Halaan Hawk-Eye") },
    { act = "use",    quest = { "The Anchors of Zephras", 94414 }, text = "Talk to Halaan and borrow Halaan's Gift to look at the distant anchor pylon", wp = W(43.8, 24.1, "Halaan Hawk-Eye") },
    { act = "turnin", quest = { "The Anchors of Zephras", 94414 }, npc = "Halaan Hawk-Eye", wp = W(43.8, 24.1, "Halaan Hawk-Eye") },
    { act = "accept", quest = { "Falling With Style", 92474 }, npc = "Myriaal Mistwake", wp = W(43.7, 24.1, "Myriaal Mistwake") },
    { act = "use",    quest = { "Falling With Style", 92474 }, text = "Climb the watchtower, jump off the top and cast Walk on Air to glide down", wp = W(43.7, 24.1, "Watchtower") },
    { act = "accept", quest = { "Harvesting Windstones", 93552 }, npc = "Dalia the Collector", wp = W(43.3, 24.0, "Dalia the Collector") },
    racialAccept,
    { act = "kill",   quest = { "Harmony in Balance", 92461 }, text = "Kill 8 Juvenile Vuldren in the meadow SE of the grove", wp = W(43.8, 25.3, "Juvenile Vuldren") },
    { act = "kill",   quest = { "Infestation Investigation", 92462 }, text = "Kill 8 Pesky Cirrusflies", wp = W(44.4, 25.9, "Pesky Cirrusflies") },
    { act = "collect",quest = { "Harvesting Windstones", 93552 }, text = "Mine 15 Windstone Clusters from the Raw Windstones around the grove", wp = W(41.9, 23.7, "Raw Windstones") },
    { act = "turnin", quest = { "Harmony in Balance", 92461 }, npc = "Rorian the Dayseeker", wp = W(42.1, 23.5, "Rorian the Dayseeker") },
    { act = "turnin", quest = { "Falling With Style", 92474 }, npc = "Rorian the Dayseeker", wp = W(42.1, 23.5, "Rorian the Dayseeker") },
    { act = "accept", quest = { "Elemental Unrest", 92464 }, npc = "Rorian the Dayseeker", wp = W(42.1, 23.5, "Rorian the Dayseeker") },
    { act = "turnin", quest = { "Harvesting Windstones", 93552 }, npc = "Dalia the Collector", wp = W(43.3, 24.0, "Dalia the Collector") },
    { act = "turnin", quest = { "Infestation Investigation", 92462 }, npc = "Elatrell Featherlight", wp = W(43.4, 24.8, "Elatrell Featherlight") },
    { act = "accept", quest = { "The Cirrusfly Queen", 92463 }, npc = "Elatrell Featherlight", wp = W(43.4, 24.8, "Elatrell Featherlight") },
    { act = "kill",   quest = { "The Cirrusfly Queen", 92463 }, text = "Kill the Cirrusfly Queen at the SE end of the grove", wp = W(48.4, 28.5, "Cirrusfly Queen") },
    { act = "turnin", quest = { "Elemental Unrest", 92464 }, npc = "Yala Windwatcher", wp = W(47.3, 21.9, "Yala Windwatcher") },
    { act = "accept", quest = { "Agitators", 92465 }, npc = "Yala Windwatcher", wp = W(47.3, 21.9, "Yala Windwatcher") },
    racialUse,
    { act = "kill",   quest = { "Agitators", 92465 }, text = "Kill 6 Roiling Winds and 7 Al'Aketh Converts just north of Yala", wp = W(47.7, 21.6, "Roiling Winds / Converts") },
    { act = "turnin", quest = { "Agitators", 92465 }, npc = "Yala Windwatcher", wp = W(47.3, 21.9, "Yala Windwatcher") },
    { act = "accept", quest = { "Return to Rorian", 92469 }, npc = "Yala Windwatcher", wp = W(47.3, 21.9, "Yala Windwatcher") },
    { act = "turnin", quest = { "The Cirrusfly Queen", 92463 }, npc = "Elatrell Featherlight", wp = W(43.4, 24.8, "Elatrell Featherlight") },
    racialTurnin,
    { act = "turnin", quest = { "Return to Rorian", 92469 }, npc = "Rorian the Dayseeker", wp = W(42.1, 23.5, "Rorian the Dayseeker") },
    { act = "accept", quest = { "Aetheen of the Gales", 92471 }, npc = "Rorian the Dayseeker", wp = W(42.1, 23.5, "Rorian the Dayseeker") },
    { act = "turnin", quest = { "Aetheen of the Gales", 92471 }, npc = "Aetheen of the Gales", wp = W(42.7, 23.7, "Aetheen of the Gales") },
    { act = "accept", quest = { "Foul Matriarch", 92470 }, npc = "Aetheen of the Gales", wp = W(42.7, 23.7, "Aetheen of the Gales") },
    { act = "accept", quest = { "Aggressive Encroachment", 92473 }, npc = "Valreaa Valewind", wp = W(42.4, 25.1, "Valreaa Valewind") },
    { act = "collect",quest = { "Aggressive Encroachment", 92473 }, text = "Collect 6 Scrawny Ursera Claws from the ursera west of the grove", wp = W(42.6, 26.0, "Scrawny Ursera") },
    { act = "kill",   quest = { "Foul Matriarch", 92470 }, text = "Kill 8 Ursera Scavengers in the den to the west", wp = W(39.4, 26.9, "Ursera Scavengers") },
    { act = "collect",quest = { "Foul Matriarch", 92470 }, text = "Kill Urs'anah at the back of the den and take her head", wp = W(35.6, 26.1, "Urs'anah") },
    { act = "accept", quest = { "Al'Aketh Thugs", 92544 }, npc = "Hanaa Nightwind", wp = W(38.3, 30.2, "Hanaa Nightwind") },
    { act = "kill",   quest = { "Al'Aketh Thugs", 92544 }, text = "Kill 6 Al'Aketh Brutes and 4 Neophytes in the camp SW of Hanaa", wp = W(38.1, 30.8, "Al'Aketh camp") },
    { act = "kill",   quest = { "Al'Aketh Thugs", 92544 }, text = "Kill Malduko Cloudcrush in the middle of the camp", wp = W(36.0, 33.5, "Malduko Cloudcrush") },
    { act = "turnin", quest = { "Al'Aketh Thugs", 92544 }, npc = "Hanaa Nightwind", wp = W(38.3, 30.2, "Hanaa Nightwind") },
    { act = "turnin", quest = { "Aggressive Encroachment", 92473 }, npc = "Valreaa Valewind", wp = W(42.4, 25.1, "Valreaa Valewind") },
    { act = "turnin", quest = { "Foul Matriarch", 92470 }, npc = "Aetheen of the Gales", wp = W(42.7, 23.7, "Aetheen of the Gales") },
    { act = "accept", quest = { "The Next Step", 92472 }, npc = "Aetheen of the Gales", wp = W(42.7, 23.7, "Aetheen of the Gales") },
    { act = "go",     text = "Follow the road south to Shen'dar Village", wp = W(45.6, 45.5, "Shen'dar Village") },
  }
end

ns.AddQuestPlan("a_thendal", thendal(false))
ns.AddQuestPlan("h_thendal", thendal(true))

---------------------------------------------------------------------------
-- Shen'dar Village, the highlands and Falaath Village (5-9/10)
---------------------------------------------------------------------------
local function shendar(horde)
  local welcome = horde and { "Welcome to Shen'dar Village", 92514 } or { "Welcome to Shen'dar Village", 93461 }
  local fq1 = horde and { "The Windshapers", 92595 } or { "The High Order", 92596 }
  local fq2 = horde and { "Meddlesome Mages", 94411 } or { "A Magical Affront", 94413 }
  local fnpc = horde and "Illaya Amberwind" or "Rathiril Sunlance"
  local fwp = horde and W(43.5, 44.8, "Illaya Amberwind") or W(45.0, 46.4, "Rathiril Sunlance")
  local toVal = horde and { "To Valanaar", 92579 } or { "To Valanaar", 92701 }
  local s = {
    { act = "turnin", quest = { "The Next Step", 92472 }, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "accept", quest = welcome, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "accept", quest = fq1, npc = fnpc, wp = fwp },
    { act = "use",    quest = fq1, text = horde and "Listen to what Illaya Amberwind has to say" or "Have a seat and speak with Rathiril Sunlance", wp = fwp },
    { act = "turnin", quest = fq1, npc = fnpc, wp = fwp },
    { act = "accept", quest = fq2, npc = fnpc, wp = fwp },
    { act = "use",    quest = welcome, text = "Speak with " .. fnpc .. " and Coriella Calmbreeze in the village", wp = W(43.0, 43.2, "Coriella Calmbreeze") },
    { act = "turnin", quest = welcome, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "accept", quest = { "The Criminal Element", 92517 }, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "accept", quest = { "The Great Outdoors", 96101 }, npc = "Raan Wildwind", wp = W(41.7, 44.8, "Raan Wildwind") },
    { act = "use",    quest = { "The Great Outdoors", 96101 }, text = "Sit by Raan's Basic Campfire until you get the Boosted Rest buff", wp = W(41.7, 44.8, "Raan's campfire") },
    { act = "turnin", quest = { "The Great Outdoors", 96101 }, npc = "Raan Wildwind", wp = W(41.7, 44.8, "Raan Wildwind") },
    { act = "accept", quest = { "Camping 101: Cooking", 96646 }, npc = "Raan Wildwind", wp = W(41.7, 44.8, "Raan Wildwind") },
    { act = "note",   text = "Raan also offers Camping 101 for your crafting/gathering profession - take the one that matches yours" },
    { act = "turnin", quest = { "Camping 101: Cooking", 96646 }, npc = "Zerril Softbreeze", wp = W(43.9, 43.9, "Zerril Softbreeze") },
    { act = "accept", quest = { "Restocking the Larders", 92553 }, npc = "Zerril Softbreeze", wp = W(43.9, 43.9, "Zerril Softbreeze") },
    { act = "accept", quest = { "Hippogryph Harassment", 92516 }, npc = "Teeri Wellwind", wp = W(44.4, 45.0, "Teeri Wellwind") },
    { act = "accept", quest = { "Pilfered Windstones", 93319 }, npc = "Teeri Wellwind", wp = W(44.4, 45.0, "Teeri Wellwind") },
    { act = "accept", quest = { "The Problem With Prideclaws", 92515 }, npc = "Indari Sunseam", wp = W(44.7, 44.5, "Indari Sunseam") },
    { act = "accept", quest = { "A Little Beauty", 93951 }, npc = "Taleen Shimmerthread", wp = W(44.8, 44.2, "Taleen Shimmerthread") },
    { act = "accept", quest = { "WANTED: Vulgara the Insatiable", 93318 }, text = "Optional: level 8 elite, take it only if grouped or ~7+", wp = W(43.4, 45.8, "Bounty board") },
  }
  if horde then
    s[#s + 1] = { act = "kill", quest = fq2, text = "Kill 6 High Order Apprentices NE of the village", wp = W(45.2, 41.4, "High Order Apprentices") }
  end
  local rest = {
    { act = "kill",   quest = { "The Criminal Element", 92517 }, text = "Kill 10 Highlands Bandits (lvl 7) in the camps NE of the village", wp = W(47.0, 39.6, "Bandit camps") },
    { act = "collect",quest = { "Pilfered Windstones", 93319 }, text = "Loot 10 Pilfered Windstones from the bandits", wp = W(47.0, 39.6, "Bandit camps") },
    { act = "kill",   quest = { "The Criminal Element", 92517 }, text = "Kill \"Badwind\" Bennic at the top camp", wp = W(50.6, 34.3, "\"Badwind\" Bennic") },
    { act = "turnin", quest = { "Pilfered Windstones", 93319 }, npc = "Teeri Wellwind", wp = W(44.4, 45.0, "Teeri Wellwind") },
    { act = "turnin", quest = { "The Criminal Element", 92517 }, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "accept", quest = { "Infiltrating the Cult", 93036 }, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "turnin", quest = { "Infiltrating the Cult", 93036 }, npc = "Sania Silverstream", wp = W(44.9, 45.5, "Sania Silverstream") },
    { act = "accept", quest = { "Falaath Village", 92529 }, npc = "Sania Silverstream", wp = W(44.9, 45.5, "Sania Silverstream") },
  }
  for _, v in ipairs(rest) do s[#s + 1] = v end
  if horde then
    s[#s + 1] = { act = "turnin", quest = fq2, npc = fnpc, wp = fwp }
  else
    s[#s + 1] = { act = "kill", quest = fq2, text = "Kill 6 Windshaper Novice Seers in the clearing west of the village", wp = W(39.3, 48.3, "Windshaper Novice Seers") }
  end
  local rest2 = {
    { act = "collect",quest = { "The Problem With Prideclaws", 92515 }, text = "Collect 10 Prideclaw Pelts from Prideclaws south of the village", wp = W(45.3, 53.2, "Prideclaws") },
    { act = "collect",quest = { "Restocking the Larders", 92553 }, text = "Get 8 Strider Meat (galestriders) and 3 Small Eggs (or buy them on the AH)", wp = W(42.5, 45.9, "Galestriders") },
    { act = "turnin", quest = { "Falaath Village", 92529 }, npc = "Missionary Jasaan", wp = W(46.9, 56.2, "Missionary Jasaan") },
    { act = "accept", quest = { "Among the Faithful", 92528 }, npc = "Missionary Jasaan", wp = W(46.9, 56.2, "Missionary Jasaan") },
    { act = "use",    quest = { "Among the Faithful", 92528 }, text = "Search the wardrobe in the house behind Jasaan and look around Falaath", wp = W(48.8, 53.9, "Wardrobe") },
    { act = "turnin", quest = { "Among the Faithful", 92528 }, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "turnin", quest = { "The Problem With Prideclaws", 92515 }, npc = "Indari Sunseam", wp = W(44.7, 44.5, "Indari Sunseam") },
    { act = "turnin", quest = { "Restocking the Larders", 92553 }, npc = "Zerril Softbreeze", wp = W(43.9, 43.9, "Zerril Softbreeze") },
  }
  for _, v in ipairs(rest2) do s[#s + 1] = v end
  if not horde then
    s[#s + 1] = { act = "turnin", quest = fq2, npc = fnpc, wp = fwp }
  end
  local rest3 = {
    { act = "accept", quest = { "Havoc in the Highlands", 92550 }, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "accept", quest = { "The Western Watch", 93926 }, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "accept", quest = { "Stolen Supplies", 92551 }, npc = "Danarii Bellowveil", wp = W(45.2, 45.2, "Danarii Bellowveil") },
    { act = "kill",   quest = { "Havoc in the Highlands", 92550 }, text = "Kill 6 Al'Aketh Stormcallers and 4 Living Lightning in Falaath Village", wp = W(47.4, 51.4, "Falaath Village") },
    { act = "collect",quest = { "Stolen Supplies", 92551 }, text = "Loot 10 Stolen Shen'dar Supplies among the Falaath houses", wp = W(50.7, 57.4, "Stolen Supplies") },
    { act = "collect",quest = { "Havoc in the Highlands", 92550 }, text = "Kill Commander Cyclas at the south end of Falaath and take his head", wp = W(50.4, 57.0, "Commander Cyclas") },
    { act = "turnin", quest = { "The Western Watch", 93926 }, npc = "Peacekeeper Vaaniel", wp = W(42.4, 62.0, "West Pylon Watchtower") },
    { act = "accept", quest = { "A Last Request", 93927 }, npc = "Peacekeeper Vaaniel", wp = W(42.4, 62.0, "Peacekeeper Vaaniel") },
    { act = "use",    quest = { "A Last Request", 93927 }, text = "Pick up the Bloody Note beside Vaaniel and read it", wp = W(42.4, 62.1, "Bloody Note") },
    { act = "kill",   quest = { "Hippogryph Harassment", 92516 }, text = "Kill 8 Hippogryph Youths and 6 Protectors on the western cliffs", wp = W(40.0, 58.6, "Hippogryph cliffs") },
    { act = "collect",quest = { "A Little Beauty", 93951 }, text = "Pick up 8 Hippogryph Down around the nests", wp = W(35.1, 54.1, "Hippogryph Down") },
    { act = "kill",   quest = { "Hippogryph Harassment", 92516 }, text = "Kill the Hippogryph Matriarch at the western end", wp = W(35.2, 54.1, "Hippogryph Matriarch") },
    { act = "collect",quest = { "WANTED: Vulgara the Insatiable", 93318 }, text = "Optional (elite): kill Vulgara the Insatiable among the Prideclaws, take her head", wp = W(42.7, 52.8, "Vulgara") },
    { act = "turnin", quest = { "Havoc in the Highlands", 92550 }, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "turnin", quest = { "A Last Request", 93927 }, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "turnin", quest = { "Stolen Supplies", 92551 }, npc = "Danarii Bellowveil", wp = W(45.2, 45.2, "Danarii Bellowveil") },
    { act = "turnin", quest = { "WANTED: Vulgara the Insatiable", 93318 }, npc = "Danarii Bellowveil", wp = W(45.2, 45.2, "Danarii Bellowveil") },
    { act = "turnin", quest = { "Hippogryph Harassment", 92516 }, npc = "Teeri Wellwind", wp = W(44.4, 45.0, "Teeri Wellwind") },
    { act = "turnin", quest = { "A Little Beauty", 93951 }, npc = "Taleen Shimmerthread", wp = W(44.8, 44.2, "Taleen Shimmerthread") },
    { act = "accept", quest = toVal, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "accept", quest = { "Deliver the Signet", 93948 }, npc = "Constable Aonda", wp = W(45.6, 45.5, "Constable Aonda") },
    { act = "go",     text = "Take the road SE to Valanaar on the south coast", wp = W(66.2, 76.6, "Valanaar") },
  }
  for _, v in ipairs(rest3) do s[#s + 1] = v end
  return s
end

ns.AddQuestPlan("a_shendar", shendar(false))
ns.AddQuestPlan("h_shendar", shendar(true))

---------------------------------------------------------------------------
-- Valanaar, Windfield Orchard, Shrine of Akir, Shadowgale Forest (9-13)
-- Shared blocks are reused; the Valanaar arrival, scholar/construct chains and
-- the Lorthuna hand-in differ per faction.
---------------------------------------------------------------------------
local arrival = {
  { act = "accept", quest = { "Crab Season", 93317 }, npc = "Nyalah Brightfire", wp = W(60.7, 72.7, "Nyalah Brightfire") },
  { act = "accept", quest = { "Blood Tithe", 92679 }, npc = "Alvarion Windfield", wp = W(62.1, 73.3, "Alvarion Windfield") },
  { act = "turnin", quest = { "Deliver the Signet", 93948 }, npc = "Talaanis Shadowsong", wp = W(66.2, 76.5, "Talaanis Shadowsong") },
}

local windfield = {
  { act = "collect",quest = { "Crab Season", 93317 }, text = "Collect 6 Windsong Crawler Meat from crawlers on the shore", wp = W(58.6, 70.7, "Windsong Crawlers") },
  { act = "turnin", quest = { "Crab Season", 93317 }, npc = "Nyalah Brightfire", wp = W(60.7, 72.7, "Nyalah Brightfire") },
  { act = "turnin", quest = { "Blood Tithe", 92679 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
  { act = "accept", quest = { "Make Yourself Useful", 92682 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
  { act = "accept", quest = { "Flutterfly Dust", 92683 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
  { act = "accept", quest = { "Ornery Ornery Galestriders", 92684 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
  { act = "collect",quest = { "Make Yourself Useful", 92682 }, text = "Pick 10 Ripe Stormapples and kill 5 Hungry Bandits in the orchard", wp = W(46.6, 80.7, "Windfield Orchard") },
  { act = "collect",quest = { "Flutterfly Dust", 92683 }, text = "Collect 5 Flutterfly Dust from Flutterflies in the fields", wp = W(48.2, 78.4, "Flutterflies") },
  { act = "collect",quest = { "Ornery Ornery Galestriders", 92684 }, text = "Collect 7 Lowlands Galestrider Tenderloins from Ornery Galestriders", wp = W(48.0, 78.0, "Ornery Galestriders") },
  { act = "accept", quest = { "What Is My Purpose?", 92698 }, npc = "Malfunctioning Cyclone Construct", wp = W(48.9, 78.3, "Malfunctioning Cyclone Construct") },
  { act = "turnin", quest = { "What Is My Purpose?", 92698 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
  { act = "turnin", quest = { "Make Yourself Useful", 92682 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
  { act = "turnin", quest = { "Flutterfly Dust", 92683 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
  { act = "turnin", quest = { "Ornery Ornery Galestriders", 92684 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
  { act = "accept", quest = { "The Hills Have Eyes", 92685 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
  { act = "collect",quest = { "The Hills Have Eyes", 92685 }, text = "Loot 7 Blood-Stained Bandit Masks from Highwayman Bandits in the hills", wp = W(45.8, 79.7, "Highwayman Bandits") },
  { act = "turnin", quest = { "The Hills Have Eyes", 92685 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
  { act = "accept", quest = { "Standing Our Ground", 92693 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
  { act = "use",    quest = { "Standing Our Ground", 92693 }, text = "Talk to Aamelia and stand with her against Ferauu the Bludgeon", wp = W(47.5, 78.4, "Ferauu the Bludgeon") },
  { act = "turnin", quest = { "Standing Our Ground", 92693 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
  { act = "accept", quest = { "Deliver the News", 92703 }, npc = "Aamelia Windfield", wp = W(46.7, 82.0, "Aamelia Windfield") },
}

local tower = {
  { act = "turnin", quest = { "Tower Defense", 93320 }, npc = "Yorana Windyreed", wp = W(69.5, 67.3, "Yorana Windyreed") },
  { act = "accept", quest = { "Disrupting Logistics", 92642 }, npc = "Yorana Windyreed", wp = W(69.5, 67.3, "Yorana Windyreed") },
  { act = "accept", quest = { "Breaking the Breaker", 92645 }, npc = "Yorana Windyreed", wp = W(69.5, 67.3, "Yorana Windyreed") },
  { act = "kill",   quest = { "Disrupting Logistics", 92642 }, text = "Kill 4 Al'Aketh Healers and 8 Al'Aketh Brawlers at the camp by the tower", wp = W(69.0, 67.7, "Al'Aketh camp") },
  { act = "kill",   quest = { "Breaking the Breaker", 92645 }, text = "Kill Commander Belguilos at the north end of the camp", wp = W(65.6, 65.6, "Commander Belguilos") },
}

local turncoat = {
  { act = "turnin", quest = { "Disrupting Logistics", 92642 }, npc = "Yorana Windyreed", wp = W(69.5, 67.3, "Yorana Windyreed") },
  { act = "turnin", quest = { "Breaking the Breaker", 92645 }, npc = "Yorana Windyreed", wp = W(69.5, 67.3, "Yorana Windyreed") },
  { act = "accept", quest = { "Return to Valanaar", 92880 }, npc = "Yorana Windyreed", wp = W(69.5, 67.3, "Yorana Windyreed") },
  { act = "turnin", quest = { "Return to Valanaar", 92880 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  { act = "accept", quest = { "The High Elder's Request", 92881 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  { act = "turnin", quest = { "The High Elder's Request", 92881 }, npc = "Talaanis Shadowsong", wp = W(66.2, 76.5, "Talaanis Shadowsong") },
  { act = "accept", quest = { "The Turncoat", 92643 }, npc = "Talaanis Shadowsong", wp = W(66.2, 76.5, "Talaanis Shadowsong") },
}

local shrine = {
  { act = "turnin", quest = { "The Turncoat", 92643 }, npc = "Dead Cultist", wp = W(56.0, 58.8, "Dead Cultist") },
  { act = "accept", quest = { "Unfortunate News", 92644 }, npc = "Dead Cultist", wp = W(56.0, 58.8, "Dead Cultist") },
  { act = "accept", quest = { "Al'Aketh Assassins", 98512 }, npc = "Fendaal Windstone", wp = W(56.8, 61.2, "Fendaal Windstone") },
  { act = "kill",   quest = { "Al'Aketh Assassins", 98512 }, text = "Kill 10 Al'Aketh Assassins around the turncoat's house", wp = W(57.1, 60.9, "Al'Aketh Assassins") },
  { act = "turnin", quest = { "Al'Aketh Assassins", 98512 }, npc = "Fendaal Windstone", wp = W(56.8, 61.2, "Fendaal Windstone") },
  { act = "turnin", quest = { "Unfortunate News", 92644 }, npc = "Talaanis Shadowsong", wp = W(66.2, 76.5, "Talaanis Shadowsong") },
  { act = "accept", quest = { "The Cult's True Plans", 94568 }, npc = "Talaanis Shadowsong", wp = W(66.2, 76.5, "Talaanis Shadowsong") },
  { act = "use",    quest = { "The Cult's True Plans", 94568 }, text = "Speak with Talaanis and watch the conversation", wp = W(66.2, 76.5, "Talaanis Shadowsong") },
  { act = "turnin", quest = { "The Cult's True Plans", 94568 }, npc = "Talaanis Shadowsong", wp = W(66.2, 76.5, "Talaanis Shadowsong") },
  { act = "accept", quest = { "Desperate Times", 92640 }, npc = "Talaanis Shadowsong", wp = W(66.2, 76.5, "Talaanis Shadowsong") },
  { act = "use",    quest = { "Desperate Times", 92640 }, text = "Rally Valennia Stormfist, Ayessa Dawnsinger (west side) and Elaadrin Evengale (south)", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "turnin", quest = { "Desperate Times", 92640 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  { act = "accept", quest = { "Prepare for Battle", 93065 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  -- Shadowgale Forest quests from Valanaar, taken before heading north
  { act = "accept", quest = { "Unnerving Silence", 94484 }, npc = "Lotheluum Starbreeze", wp = W(64.0, 75.1, "Lotheluum Starbreeze") },
  { act = "accept", quest = { "Aid For The Refugees", 94896 }, npc = "Ealaane Nimbuswalker", wp = W(66.0, 74.3, "Ealaane Nimbuswalker") },
  { act = "accept", quest = { "The Fate of a Loved One", 94897 }, npc = "Ealaane Nimbuswalker", wp = W(66.0, 74.3, "Ealaane Nimbuswalker") },
}

local assault = {
  { act = "turnin", quest = { "Prepare for Battle", 93065 }, npc = "Valennia Stormfist", wp = W(61.2, 71.0, "Valennia (gate)") },
  { act = "accept", quest = { "Making Our Move", 92947 }, npc = "Valennia Stormfist", wp = W(61.2, 71.0, "Valennia (gate)") },
  { act = "kill",   quest = { "Making Our Move", 92947 }, text = "Kill 7 Al'Aketh Guardians, 7 Spiritcallers and 7 Blademasters at the Shrine of Akir", wp = W(64.7, 55.7, "Shrine of Akir") },
  { act = "turnin", quest = { "Making Our Move", 92947 }, npc = "Hyusaa Quickbreeze", wp = W(63.8, 50.5, "Hyusaa Quickbreeze") },
  { act = "accept", quest = { "The Inner Sanctum", 93958 }, npc = "Hyusaa Quickbreeze", wp = W(63.8, 50.5, "Hyusaa Quickbreeze") },
  { act = "turnin", quest = { "The Inner Sanctum", 93958 }, npc = "Valennia Stormfist", wp = W(65.2, 50.4, "Valennia (inner sanctum)") },
}

local shadowgale = {
  { act = "turnin", quest = { "Unnerving Silence", 94484 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "accept", quest = { "Tears of the Lady", 94485 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "accept", quest = { "Feathers for Binding", 94486 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "accept", quest = { "Unwanted and Unworthy", 94487 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "accept", quest = { "Mercy Falls on Deaf Ears", 93165 }, npc = "Vayn Moongaze", wp = W(63.8, 36.0, "Vayn Moongaze") },
  { act = "collect",quest = { "Feathers for Binding", 94486 }, text = "Collect 20 feathers from Shadowgale Shrieklings around Elegael's camp", wp = W(61.5, 39.2, "Shadowgale Shrieklings") },
  { act = "collect",quest = { "Tears of the Lady", 94485 }, text = "Pick 8 Lady's Tear Moss along the stream west of the camp", wp = W(59.9, 39.3, "Lady's Tear Moss") },
  { act = "collect",quest = { "Unwanted and Unworthy", 94487 }, text = "Loot 10 Bloodied Heirlooms from Al'Aketh Footsoldiers and Stormchasers", wp = W(63.7, 37.1, "Al'Aketh camp") },
  { act = "collect",quest = { "Mercy Falls on Deaf Ears", 93165 }, text = "Loot 5 Al'Aketh Cultist's Ears from the same cultists", wp = W(63.7, 37.1, "Al'Aketh camp") },
  { act = "turnin", quest = { "Mercy Falls on Deaf Ears", 93165 }, npc = "Vayn Moongaze", wp = W(63.8, 36.0, "Vayn Moongaze") },
  { act = "turnin", quest = { "Tears of the Lady", 94485 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "turnin", quest = { "Feathers for Binding", 94486 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "turnin", quest = { "Unwanted and Unworthy", 94487 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "accept", quest = { "The Ties That Bind", 94488 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "accept", quest = { "The Wounds of Betrayal", 94489 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "use",    quest = { "The Wounds of Betrayal", 94489 }, text = "Enter the Nightfang Den, heal 7 druids and find Jorel Windsinger", wp = W(64.5, 34.7, "Jorel Windsinger") },
  { act = "collect",quest = { "The Ties That Bind", 94488 }, text = "Kill Commander Haalien and take his head", wp = W(65.5, 36.3, "Commander Haalien") },
  { act = "accept", quest = { "Ripped Missive", 94490 }, text = "Click the Ripped Missive that Commander Haalien drops", wp = W(65.5, 36.3, "Commander Haalien") },
  { act = "turnin", quest = { "The Ties That Bind", 94488 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "turnin", quest = { "The Wounds of Betrayal", 94489 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "turnin", quest = { "Ripped Missive", 94490 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "accept", quest = { "The Fate of the Den", 94491 }, npc = "Elegael Thornpaw", wp = W(61.8, 39.1, "Elegael Thornpaw") },
  { act = "accept", quest = { "The Strange Hermit", 93159 }, npc = "Strange Hermit", wp = W(54.0, 38.9, "Strange Hermit") },
  { act = "use",    quest = { "The Strange Hermit", 93159 }, text = "Talk to the Strange Hermit and learn more about him", wp = W(54.0, 38.9, "Strange Hermit") },
  { act = "turnin", quest = { "The Strange Hermit", 93159 }, npc = "Strange Hermit", wp = W(54.0, 38.9, "Strange Hermit") },
  { act = "accept", quest = { "The Forest's Bounty", 93160 }, npc = "Strange Hermit", wp = W(54.0, 38.9, "Strange Hermit") },
  { act = "accept", quest = { "Free the Hollows", 93172 }, npc = "Strange Hermit", wp = W(54.0, 38.9, "Strange Hermit") },
}

local refugees = {
  { act = "collect",quest = { "The Forest's Bounty", 93160 }, text = "Gather 8 Shadowgale Acorns while you clear the forest" },
  { act = "turnin", quest = { "Free the Hollows", 93172 }, npc = "Strange Hermit", wp = W(54.0, 38.9, "Strange Hermit") },
  { act = "turnin", quest = { "The Forest's Bounty", 93160 }, npc = "Strange Hermit", wp = W(54.0, 38.9, "Strange Hermit") },
  { act = "collect",quest = { "Aid For The Refugees", 94896 }, text = "Loot 8 Abandoned Belongings in the ruins of Ban'aethal (north shore of the lake)", wp = W(56.9, 33.6, "Ruins of Ban'aethal") },
  { act = "collect",quest = { "The Fate of a Loved One", 94897 }, text = "Find Resaan and take Resaan's Heirloom", wp = W(57.0, 29.4, "Resaan's Heirloom") },
  { act = "accept", quest = { "The Ancient Hilt", 93161 }, text = "Optional: loot the Ancient Hilt in the ruins (starts the Dawn Waker chain)", wp = W(58.2, 24.0, "Ancient Hilt") },
  { act = "go",     text = "Head back south to Valanaar", wp = W(66.2, 76.6, "Valanaar") },
}

local homecoming = {
  { act = "turnin", quest = { "The Fate of the Den", 94491 }, npc = "Lotheluum Starbreeze", wp = W(64.0, 75.1, "Lotheluum Starbreeze") },
  { act = "turnin", quest = { "Aid For The Refugees", 94896 }, npc = "Ealaane Nimbuswalker", wp = W(66.0, 74.3, "Ealaane Nimbuswalker") },
  { act = "turnin", quest = { "The Fate of a Loved One", 94897 }, npc = "Ealaane Nimbuswalker", wp = W(66.0, 74.3, "Ealaane Nimbuswalker") },
  { act = "turnin", quest = { "The Ancient Hilt", 93161 }, npc = "Ealaane Nimbuswalker", wp = W(66.0, 74.3, "Ealaane Nimbuswalker") },
}

local function cat(...)
  local out = {}
  for _, t in ipairs({ ... }) do for _, v in ipairs(t) do out[#out + 1] = v end end
  return out
end

-- Alliance (High Order): Elaadrin Evengale, the Missing Scholar and Catching Wind
ns.AddQuestPlan("a_valanaar", cat(arrival, {
  { act = "turnin", quest = { "To Valanaar", 92701 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  { act = "accept", quest = { "The Supreme Magister", 92699 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  { act = "accept", quest = { "Bugged", 93949 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  { act = "turnin", quest = { "The Supreme Magister", 92699 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "accept", quest = { "A Grand Adventure", 92709 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "use",    quest = { "A Grand Adventure", 92709 }, text = "Listen to what Elaadrin Evengale has to say", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "turnin", quest = { "A Grand Adventure", 92709 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "accept", quest = { "The Missing Scholar", 92727 }, npc = "Dondallion Whisperwind", wp = W(66.3, 79.8, "Dondallion Whisperwind") },
  { act = "kill",   quest = { "Bugged", 93949 }, text = "Kill Skyhoppers in the fields west of Valennia until 8 Enchanted Skyhoppers die", wp = W(66.3, 79.7, "Skyhoppers") },
  { act = "turnin", quest = { "Bugged", 93949 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
}, windfield, {
  { act = "turnin", quest = { "The Missing Scholar", 92727 }, npc = "Bloodstained Satchel", wp = W(53.3, 72.1, "Bloodstained Satchel") },
  { act = "accept", quest = { "The Missing Scholar", 92849 }, npc = "Bloodstained Satchel", wp = W(53.3, 72.1, "Bloodstained Satchel") },
  { act = "turnin", quest = { "The Missing Scholar", 92849 }, npc = "Fillion Flamebreeze", wp = W(52.1, 69.4, "Fillion Flamebreeze") },
  { act = "accept", quest = { "The Missing Scholar", 92850 }, npc = "Fillion Flamebreeze", wp = W(52.1, 69.4, "Fillion Flamebreeze") },
  { act = "collect",quest = { "The Missing Scholar", 92850 }, text = "Kill the Shriekling Matriarch in the den just north of the camp, take its head", wp = W(52.3, 66.8, "Shriekling Matriarch") },
  { act = "turnin", quest = { "Deliver the News", 92703 }, npc = "Alvarion Windfield", wp = W(62.1, 73.3, "Alvarion Windfield") },
  { act = "turnin", quest = { "The Missing Scholar", 92850 }, npc = "Fillion Flamebreeze", wp = W(66.2, 79.9, "Fillion (Valanaar)") },
  { act = "accept", quest = { "Fillion's Mission", 99260 }, npc = "Fillion Flamebreeze", wp = W(66.2, 79.9, "Fillion Flamebreeze") },
  { act = "turnin", quest = { "Fillion's Mission", 99260 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "accept", quest = { "Catching Wind", 92840 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "use",    quest = { "Catching Wind", 92840 }, text = "Use the Index Esoteria on the Windstone Formations west of Fillion's camp", wp = W(48.6, 68.5, "Windstone Formations") },
  { act = "turnin", quest = { "Catching Wind", 92840 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "accept", quest = { "Avenged Tenfold", 92834 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "accept", quest = { "In Service of Zephras", 92860 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "turnin", quest = { "In Service of Zephras", 92860 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  { act = "accept", quest = { "Tower Defense", 93320 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
}, tower, {
  { act = "collect",quest = { "Avenged Tenfold", 92834 }, text = "Loot 10 Al'Aketh Windstone Charms from the cultists by the tower", wp = W(69.2, 67.8, "Al'Aketh cultists") },
}, turncoat, {
  { act = "turnin", quest = { "Avenged Tenfold", 92834 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
}, shrine, {
  { act = "accept", quest = { "Unwelcome Visitors", 92741 }, npc = "Iaadaria Bitterwind", wp = W(66.3, 79.5, "Iaadaria Bitterwind") },
}, assault, {
  { act = "accept", quest = { "Confront Lorthuna", 93835 }, npc = "Valennia Stormfist", wp = W(65.2, 50.4, "Valennia (inner sanctum)") },
  { act = "use",    quest = { "Confront Lorthuna", 93835 }, text = "Take the portal to the Rohashi Spires and face High Priestess Lorthuna", wp = W(74.3, 53.7, "High Priestess Lorthuna") },
  { act = "go",     text = "Run north from the shrine into Shadowgale Forest", wp = W(61.8, 39.1, "Elegael Thornpaw") },
}, shadowgale, {
  { act = "collect",quest = { "Unwelcome Visitors", 92741 }, text = "Collect 8 Shriekling Talons from the Shadowgale Shrieklings", wp = W(58.9, 39.5, "Shadowgale Shrieklings") },
  { act = "kill",   quest = { "Free the Hollows", 93172 }, text = "Destroy 10 Wind Hollows", wp = W(56.7, 35.3, "Wind Hollows") },
}, refugees, {
  { act = "turnin", quest = { "Confront Lorthuna", 93835 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "turnin", quest = { "Unwelcome Visitors", 92741 }, npc = "Iaadaria Bitterwind", wp = W(66.3, 79.5, "Iaadaria Bitterwind") },
}, homecoming))

-- Horde (Windshaper): Ayessa Dawnsinger, the Broken Construct
ns.AddQuestPlan("h_valanaar", cat(arrival, {
  { act = "turnin", quest = { "To Valanaar", 92579 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  { act = "accept", quest = { "The Grand Skyseer", 92700 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  { act = "accept", quest = { "Bugged", 93949 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  { act = "kill",   quest = { "Bugged", 93949 }, text = "Kill Skyhoppers in the fields just west until 8 Enchanted Skyhoppers die", wp = W(66.3, 79.7, "Skyhoppers") },
  { act = "turnin", quest = { "Bugged", 93949 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  { act = "turnin", quest = { "The Grand Skyseer", 92700 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "accept", quest = { "A Grand Adventure", 92708 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "use",    quest = { "A Grand Adventure", 92708 }, text = "Listen to what Ayessa Dawnsinger has to say", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "turnin", quest = { "A Grand Adventure", 92708 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "accept", quest = { "The Broken Construct", 93735 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "accept", quest = { "Unwelcome Spirits", 93736 }, npc = "Endaria Mistgaze", wp = W(58.2, 78.3, "Endaria Mistgaze") },
  { act = "turnin", quest = { "The Broken Construct", 93735 }, npc = "Riaani Nightwind", wp = W(59.0, 72.9, "Riaani Nightwind") },
  { act = "accept", quest = { "The Broken Construct", 93737 }, npc = "Riaani Nightwind", wp = W(59.0, 72.9, "Riaani Nightwind") },
}, windfield, {
  { act = "collect",quest = { "The Broken Construct", 93737 }, text = "Find the Air Construct Core in the lowlands NE of the orchard", wp = W(44.7, 73.4, "Air Construct Core") },
  { act = "collect",quest = { "The Broken Construct", 93737 }, text = "Find the Crystallized Lightning", wp = W(51.4, 67.5, "Crystallized Lightning") },
  { act = "collect",quest = { "The Broken Construct", 93737 }, text = "Loot an Enchanted Gyrozephyr from Construct Parts north of the lowlands", wp = W(52.4, 45.8, "Construct Parts") },
  { act = "turnin", quest = { "Deliver the News", 92703 }, npc = "Alvarion Windfield", wp = W(62.1, 73.3, "Alvarion Windfield") },
  { act = "use",    quest = { "The Broken Construct", 93737 }, text = "Speak with Riaani Nightwind and listen to him", wp = W(59.0, 72.9, "Riaani Nightwind") },
  { act = "turnin", quest = { "The Broken Construct", 93737 }, npc = "Riaani Nightwind", wp = W(59.0, 72.9, "Riaani Nightwind") },
  { act = "accept", quest = { "The Broken Construct", 93738 }, npc = "Riaani Nightwind", wp = W(59.0, 72.9, "Riaani Nightwind") },
  { act = "turnin", quest = { "The Broken Construct", 93738 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "accept", quest = { "A Firm Response", 93746 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "use",    quest = { "A Firm Response", 93746 }, text = "Confront Belathaan Brightwish on the road to the Shrine of Akir", wp = W(59.2, 58.1, "Belathaan Brightwish") },
  { act = "turnin", quest = { "A Firm Response", 93746 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "accept", quest = { "In Service of Zephras", 92871 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "accept", quest = { "Blood for Blood", 93740 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "turnin", quest = { "In Service of Zephras", 92871 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
  { act = "accept", quest = { "Tower Defense", 93320 }, npc = "Valennia Stormfist", wp = W(66.2, 76.6, "Valennia Stormfist") },
}, tower, {
  { act = "collect",quest = { "Blood for Blood", 93740 }, text = "Loot 10 Al'Aketh Windstone Charms from cultists west of the tower", wp = W(65.3, 65.4, "Al'Aketh cultists") },
}, turncoat, {
  { act = "turnin", quest = { "Blood for Blood", 93740 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
}, shrine, assault, {
  { act = "accept", quest = { "Confront Lorthuna", 92646 }, npc = "Valennia Stormfist", wp = W(65.2, 50.4, "Valennia (inner sanctum)") },
  { act = "use",    quest = { "Confront Lorthuna", 92646 }, text = "Take the portal to the Rohashi Spires and face High Priestess Lorthuna", wp = W(74.8, 53.4, "High Priestess Lorthuna") },
  { act = "go",     text = "Run north from the shrine into Shadowgale Forest", wp = W(61.8, 39.1, "Elegael Thornpaw") },
}, shadowgale, {
  { act = "kill",   quest = { "Free the Hollows", 93172 }, text = "Destroy 10 Wind Hollows", wp = W(56.7, 35.3, "Wind Hollows") },
  { act = "collect",quest = { "Unwelcome Spirits", 93736 }, text = "Gather 10 Wind Hollow Essences from the same Wind Hollows", wp = W(56.7, 35.3, "Wind Hollows") },
}, refugees, {
  { act = "turnin", quest = { "Confront Lorthuna", 92646 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "turnin", quest = { "Unwelcome Spirits", 93736 }, npc = "Endaria Mistgaze", wp = W(58.2, 78.3, "Endaria Mistgaze") },
}, homecoming))

---------------------------------------------------------------------------
-- Leaving the isle (13-14)
---------------------------------------------------------------------------
ns.AddQuestPlan("a_zephras_exit", {
  { act = "accept", quest = { "The Fate of Zephras", 94369 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "turnin", quest = { "The Fate of Zephras", 94369 }, npc = "Talaanis Shadowsong", wp = W(66.2, 76.5, "Talaanis Shadowsong") },
  { act = "accept", quest = { "What Comes Next", 93089 }, npc = "Talaanis Shadowsong", wp = W(66.2, 76.5, "Talaanis Shadowsong") },
  { act = "turnin", quest = { "What Comes Next", 93089 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "accept", quest = { "The Magical City of Dalaran", 94946 }, npc = "Elaadrin Evengale", wp = W(66.6, 79.9, "Elaadrin Evengale") },
  { act = "note",   text = "Fairweather Stables (W of Valanaar) is where Skyborne learn to ride at 40 - remember it", wp = W(53.8, 81.3, "Genn Fairweather") },
  { act = "go",     text = "Board the skycutter at the easternmost dock of Valanaar", wp = W(65.9, 83.5, "Skycutter to Dalaran") },
  { act = "go",     text = "Ride it to Dalaran (northern skyboat dock)", wp = { 1416, 12.5, 51.8, "Dalaran skyboat dock" } },
  { act = "turnin", quest = { "The Magical City of Dalaran", 94946 }, npc = "Denaaris Stargale", wp = { 1416, 12.3, 56.3, "Denaaris Stargale" } },
  { act = "accept", quest = { "Welcome to Azeroth", 94947 }, npc = "Denaaris Stargale", wp = { 1416, 12.3, 56.3, "Denaaris Stargale" } },
  { act = "go",     text = "Take the Skyborne Portal in the Violet Citadel to Stormwind", wp = { 1416, 12.3, 56.3, "Skyborne Portal" } },
  { act = "turnin", quest = { "Welcome to Azeroth", 94947 }, npc = "Highlord Bolvar Fordragon", wp = { 1453, 80.2, 38.4, "Bolvar Fordragon" } },
  { act = "accept", quest = { "Exploring the Alliance", 93963 }, npc = "Highlord Bolvar Fordragon", text = "Optional capital tour; finish it as you pass through", wp = { 1453, 80.2, 38.4, "Bolvar Fordragon" } },
  { act = "fp",     text = "Get the Stormwind flight path" },
  { act = "note",   text = "Next: Westfall (or the Deeprun Tram to Ironforge)" },
})

ns.AddQuestPlan("h_skyborne_join_horde", {
  { act = "accept", quest = { "The Fate of Zephras", 93836 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "turnin", quest = { "The Fate of Zephras", 93836 }, npc = "Talaanis Shadowsong", wp = W(66.2, 76.5, "Talaanis Shadowsong") },
  { act = "accept", quest = { "What Comes Next", 93090 }, npc = "Talaanis Shadowsong", wp = W(66.2, 76.5, "Talaanis Shadowsong") },
  { act = "turnin", quest = { "What Comes Next", 93090 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "accept", quest = { "The Earthen Ring", 95349 }, npc = "Ayessa Dawnsinger", wp = W(59.1, 79.7, "Ayessa Dawnsinger") },
  { act = "note",   text = "Fairweather Stables (W of Valanaar) is where Skyborne learn to ride at 40 - remember it", wp = W(53.8, 81.3, "Genn Fairweather") },
  { act = "go",     text = "Board the Horde airship at the westernmost dock of Valanaar", wp = W(57.9, 80.9, "Horde airship") },
  { act = "go",     text = "Ride it to the cliffs south of Skywatcher Plateau, north of Thunder Bluff", wp = { 1412, 34.3, 25.8, "Skyboat landing" } },
  { act = "turnin", quest = { "The Earthen Ring", 95349 }, npc = "Alaana Stormwalker", wp = { 1412, 33.4, 22.6, "Alaana Stormwalker" } },
  { act = "accept", quest = { "Welcome to Azeroth", 95350 }, npc = "Alaana Stormwalker", wp = { 1412, 33.4, 22.6, "Alaana Stormwalker" } },
  { act = "fp",     text = "Get the Thunder Bluff flight path" },
  { act = "go",     text = "Travel to Orgrimmar (Valley of Wisdom)" },
  { act = "turnin", quest = { "Welcome to Azeroth", 95350 }, npc = "Thrall", wp = { 1454, 31.7, 37.8, "Thrall" } },
  { act = "accept", quest = { "Exploring the Horde", 93739 }, npc = "Thrall", text = "Optional capital tour; finish it as you pass through", wp = { 1454, 31.7, 37.8, "Thrall" } },
  { act = "note",   text = "Next: The Barrens (or Silverpine via the zeppelin)" },
})
