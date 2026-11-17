-- Coffey's Leveling Guide: namespace, data registries and small shared helpers.
local ADDON, ns = ...

ns.ADDON = ADDON
ns.AUTHOR = "Coffey Labs LLC"
ns.WEBSITE = "https://coffeylabs.org"
ns.SUPPORT = "https://coffeylabs.org/support/"
ns.BUILDS, ns.SPELLS, ns.SPECGUIDES, ns.PROFESSIONS = {}, {}, {}, {}
ns.ALLSTEPS, ns.GEAR = {}, {}

local loadIndex = 0
function ns.AddSteps(list)
  for _, step in ipairs(list) do
    loadIndex = loadIndex + 1
    step._order = loadIndex
    ns.ALLSTEPS[#ns.ALLSTEPS + 1] = step
  end
end

ns.PLANS = {}
function ns.AddQuestPlan(parentID, steps)
  local list = ns.PLANS[parentID] or {}
  for _, s in ipairs(steps) do list[#list + 1] = s end
  ns.PLANS[parentID] = list
end

function ns.AddGear(class, spec, items)
  ns.GEAR[class] = ns.GEAR[class] or {}
  local list = ns.GEAR[class][spec] or {}
  for _, it in ipairs(items) do list[#list + 1] = it end
  ns.GEAR[class][spec] = list
end

-- Step kinds: which ones are part of the main route vs. the tips tabs.
ns.ROUTE_KINDS = { zone = true, quest = true, class = true, dungeon = true, travel = true, train = true, mount = true }
ns.TIP_KINDS   = { gold = true, extra = true, profession = true }

ns.KIND_ICONS = {
  zone       = "Interface\\Icons\\INV_Misc_Map_01",
  quest      = "Interface\\Icons\\INV_Misc_Note_01",
  dungeon    = "Interface\\Icons\\INV_Misc_Bone_ElfSkull_01",
  travel     = "Interface\\Icons\\INV_Misc_Rune_01",
  train      = "Interface\\Icons\\INV_Misc_Book_09",
  mount      = "Interface\\Icons\\Ability_Mount_RidingHorse",
  gold       = "Interface\\Icons\\INV_Misc_Coin_01",
  extra      = "Interface\\Icons\\INV_Misc_Bag_10",
  profession = "Interface\\Icons\\Trade_BlackSmithing",
}

ns.PROF_ICONS = {
  ["Alchemy"] = "Interface\\Icons\\Trade_Alchemy",
  ["Blacksmithing"] = "Interface\\Icons\\Trade_BlackSmithing",
  ["Enchanting"] = "Interface\\Icons\\Trade_Engraving",
  ["Engineering"] = "Interface\\Icons\\Trade_Engineering",
  ["Leatherworking"] = "Interface\\Icons\\INV_Misc_ArmorKit_17",
  ["Tailoring"] = "Interface\\Icons\\Trade_Tailoring",
  ["Herbalism"] = "Interface\\Icons\\Trade_Herbalism",
  ["Mining"] = "Interface\\Icons\\Trade_Mining",
  ["Skinning"] = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01",
  ["Cooking"] = "Interface\\Icons\\INV_Misc_Food_15",
  ["First Aid"] = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
  ["Fishing"] = "Interface\\Icons\\Trade_Fishing",
}

ns.COLORS = {
  accent = { 1.00, 0.82, 0.00 },
  done   = { 0.30, 0.90, 0.30 },
  active = { 1.00, 0.85, 0.20 },
  todo   = { 0.55, 0.55, 0.55 },
  bg     = { 0.04, 0.04, 0.06, 0.90 },
  border = { 0.55, 0.45, 0.25, 1.00 },
}

-- Status colors as chat escape codes. The colorblind palette (Okabe-Ito) swaps green and red
-- for blue and vermillion; status icons differ in shape too, so color is never the only cue.
local PALETTES = {
  standard   = { good = "4ce64c", warn = "ff8040", bad = "ff4040", skip = "cc4444", cur = "ffd100", dim = "808080", info = "8080ff" },
  colorblind = { good = "56b4e9", warn = "e69f00", bad = "d55e00", skip = "d55e00", cur = "f0e442", dim = "808080", info = "cc79a7" },
}
function ns.C(key)
  local pal = PALETTES[(ns.db and ns.db.colorblind) and "colorblind" or "standard"]
  return "|cff" .. (pal[key] or "ffffff")
end
-- Same color as r, g, b (0-1), for textures and font strings.
function ns.RGB(key)
  local hex = ns.C(key):sub(5)
  return tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255
end

-- Key bindings (Bindings.xml). Shown under Options > Keybindings > AddOns.
BINDING_HEADER_COFFEYGUIDE = "Coffey's Leveling Guide"
BINDING_NAME_COFFEYGUIDE_TOGGLE = "Show or hide the tracker"
BINDING_NAME_COFFEYGUIDE_GUIDE = "Open the full guide"
BINDING_NAME_COFFEYGUIDE_CHECK = "Check off the current objective"
BINDING_NAME_COFFEYGUIDE_NEXT = "View the next step"
BINDING_NAME_COFFEYGUIDE_PREV = "View the previous step"
BINDING_NAME_COFFEYGUIDE_WAYPOINT = "Set waypoints for the current objective"
BINDING_NAME_COFFEYGUIDE_COMPACT = "Switch the tracker between compact and full"

local PREFIX = "|cffffd100Coffey's Guide:|r "
function ns.Print(msg) DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. tostring(msg)) end

function ns.Hex(c) return ("|cff%02x%02x%02x"):format(c[1] * 255, c[2] * 255, c[3] * 255) end

-- Level band text coloured by difficulty relative to the player.
function ns.BandText(step)
  local band = (step.min == step.max or not step.max) and tostring(step.min) or (step.min .. "-" .. step.max)
  local mid = step.max and math.floor((step.min + step.max) / 2) or step.min
  local c = GetQuestDifficultyColor and GetQuestDifficultyColor(mid) or { r = 1, g = 1, b = 1 }
  return ("|cff%02x%02x%02xLv %s|r"):format(c.r * 255, c.g * 255, c.b * 255, band)
end

function ns.Contains(list, value)
  if not list then return true end
  for _, v in ipairs(list) do if v == value then return true end end
  return false
end

-- Strip "|c...|r" codes etc. for width-insensitive comparisons.
function ns.Trim(s) return (s or ""):match("^%s*(.-)%s*$") end
