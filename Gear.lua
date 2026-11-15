-- Coffey's Leveling Guide gear advisor: scores items with spec stat weights, flags bag upgrades,
-- annotates tooltips and recommends quest rewards.
local ADDON, ns = ...
ns.WEIGHTS = ns.WEIGHTS or {}
local G = {}
ns.Gear = G

-- GetItemStats key (with _SHORT removed) -> weight key
local STATMAP = {
  ITEM_MOD_STRENGTH = "STR", ITEM_MOD_AGILITY = "AGI", ITEM_MOD_STAMINA = "STA", ITEM_MOD_INTELLECT = "INT",
  ITEM_MOD_SPIRIT = "SPI", ITEM_MOD_ATTACK_POWER = "AP", ITEM_MOD_RANGED_ATTACK_POWER = "RAP",
  ITEM_MOD_FERAL_ATTACK_POWER = "AP", ITEM_MOD_SPELL_DAMAGE_DONE = "SP", ITEM_MOD_SPELL_POWER = "SP",
  ITEM_MOD_SPELL_HEALING_DONE = "HEAL", ITEM_MOD_HIT_RATING = "HIT", ITEM_MOD_HIT_MELEE_RATING = "HIT",
  ITEM_MOD_HIT_RANGED_RATING = "HIT", ITEM_MOD_CRIT_RATING = "CRIT", ITEM_MOD_CRIT_MELEE_RATING = "CRIT",
  ITEM_MOD_CRIT_RANGED_RATING = "CRIT", ITEM_MOD_HIT_SPELL_RATING = "SPELLHIT", ITEM_MOD_CRIT_SPELL_RATING = "SPELLCRIT",
  ITEM_MOD_MANA_REGENERATION = "MP5", ITEM_MOD_HEALTH_REGENERATION = "HP5", ITEM_MOD_DAMAGE_PER_SECOND = "DPS",
  RESISTANCE0_NAME = "ARMOR", ITEM_MOD_DEFENSE_SKILL_RATING = "DEF", ITEM_MOD_DODGE_RATING = "DODGE",
  ITEM_MOD_PARRY_RATING = "PARRY", ITEM_MOD_BLOCK_RATING = "BLOCK", ITEM_MOD_BLOCK_VALUE = "BLOCKVALUE",
}

-- Fallback weights when no research data exists for the spec.
local FALLBACK = {
  WARRIOR = { STR = 1, AGI = 0.6, STA = 0.5, AP = 0.45, HIT = 10, CRIT = 10, DPS = 3, ARMOR = 0.01 },
  PALADIN = { STR = 1, AGI = 0.5, STA = 0.5, INT = 0.35, SPI = 0.2, AP = 0.45, HIT = 10, CRIT = 10, DPS = 3, ARMOR = 0.01 },
  ROGUE   = { AGI = 1, STR = 0.5, STA = 0.4, AP = 0.45, HIT = 12, CRIT = 10, DPS = 3, ARMOR = 0.01 },
  HUNTER  = { AGI = 1, STA = 0.4, INT = 0.3, RAP = 0.45, AP = 0.2, HIT = 12, CRIT = 10, DPS = 2.5, ARMOR = 0.01 },
  SHAMAN  = { STR = 1, AGI = 0.6, INT = 0.5, STA = 0.5, SPI = 0.2, AP = 0.45, SP = 0.6, CRIT = 10, DPS = 3 },
  DRUID   = { AGI = 1, STR = 0.8, STA = 0.6, INT = 0.4, SPI = 0.3, AP = 0.45, CRIT = 10, HIT = 10 },
  PRIEST  = { INT = 1, SPI = 0.9, STA = 0.5, SP = 0.9, HEAL = 0.5, SPELLCRIT = 8, MP5 = 1.5 },
  MAGE    = { INT = 1, SPI = 0.6, STA = 0.5, SP = 1.1, SPELLHIT = 10, SPELLCRIT = 8, MP5 = 1.2 },
  WARLOCK = { INT = 0.8, SPI = 0.7, STA = 1, SP = 1.1, SPELLHIT = 10, SPELLCRIT = 6, MP5 = 1 },
}

-- Armor types: classID 4 subclasses 1 cloth, 2 leather, 3 mail, 4 plate.
local ARMOR_BEST = {
  WARRIOR = function(l) return l >= 40 and 4 or 3 end, PALADIN = function(l) return l >= 40 and 4 or 3 end,
  HUNTER = function(l) return l >= 40 and 3 or 2 end, SHAMAN = function(l) return l >= 40 and 3 or 2 end,
  ROGUE = function() return 2 end, DRUID = function() return 2 end,
  PRIEST = function() return 1 end, MAGE = function() return 1 end, WARLOCK = function() return 1 end,
}
-- Weapon subclasses (classID 2) each class can use.
local WEAPONS = {
  WARRIOR = { [0]=1, [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [10]=1, [13]=1, [15]=1, [16]=1, [18]=1 },
  PALADIN = { [0]=1, [1]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1 },
  HUNTER  = { [0]=1, [1]=1, [2]=1, [3]=1, [6]=1, [7]=1, [8]=1, [10]=1, [13]=1, [15]=1, [16]=1, [18]=1 },
  ROGUE   = { [2]=1, [3]=1, [4]=1, [7]=1, [13]=1, [15]=1, [16]=1, [18]=1 },
  SHAMAN  = { [0]=1, [1]=1, [4]=1, [5]=1, [10]=1, [13]=1, [15]=1 },
  DRUID   = { [4]=1, [5]=1, [6]=1, [10]=1, [13]=1, [15]=1 },
  PRIEST  = { [4]=1, [10]=1, [15]=1, [19]=1 },
  MAGE    = { [7]=1, [10]=1, [15]=1, [19]=1 },
  WARLOCK = { [7]=1, [10]=1, [15]=1, [19]=1 },
}
local CAN_SHIELD = { WARRIOR = true, PALADIN = true, SHAMAN = true }
local RELIC = { PALADIN = 7, DRUID = 8, SHAMAN = 9 } -- libram / idol / totem subclass

local SLOTS = {
  INVTYPE_HEAD = { 1 }, INVTYPE_NECK = { 2 }, INVTYPE_SHOULDER = { 3 }, INVTYPE_CHEST = { 5 }, INVTYPE_ROBE = { 5 },
  INVTYPE_WAIST = { 6 }, INVTYPE_LEGS = { 7 }, INVTYPE_FEET = { 8 }, INVTYPE_WRIST = { 9 }, INVTYPE_HAND = { 10 },
  INVTYPE_FINGER = { 11, 12 }, INVTYPE_TRINKET = { 13, 14 }, INVTYPE_CLOAK = { 15 },
  INVTYPE_WEAPON = { 16 }, INVTYPE_WEAPONMAINHAND = { 16 }, INVTYPE_2HWEAPON = { 16 },
  INVTYPE_SHIELD = { 17 }, INVTYPE_WEAPONOFFHAND = { 17 }, INVTYPE_HOLDABLE = { 17 },
  INVTYPE_RANGED = { 18 }, INVTYPE_RANGEDRIGHT = { 18 }, INVTYPE_THROWN = { 18 }, INVTYPE_RELIC = { 18 },
}

function G.Weights()
  local class = ns.player.class
  local byClass = ns.WEIGHTS[class]
  local spec = byClass and ns.MatchSpec(byClass, ns.ActiveSpec())
  local w = spec and byClass[spec]
  if w then
    local t = ((ns.player.level or 1) >= 60 and w.endgame) or w.leveling or w.endgame
    if t then return t, spec end
  end
  return FALLBACK[class] or FALLBACK.WARRIOR, spec or "general"
end

local function GetStats(link)
  if C_Item and C_Item.GetItemStats then return C_Item.GetItemStats(link) end
  if GetItemStats then return GetItemStats(link) end
end

local function ItemInstant(link)
  if C_Item and C_Item.GetItemInfoInstant then return C_Item.GetItemInfoInstant(link) end
  return GetItemInfoInstant(link)
end

-- Can the player use this item type at all (and is it their best armor type)?
-- Returns usable, multiplier
function G.Usable(link)
  local _, _, _, equipLoc, _, classID, subclassID = ItemInstant(link)
  local class, level = ns.player.class, ns.player.level or 1
  if not equipLoc or equipLoc == "" or not SLOTS[equipLoc] then return false, 0 end
  if classID == 2 then
    if not (WEAPONS[class] or {})[subclassID] then return false, 0 end
    if equipLoc == "INVTYPE_2HWEAPON" and (class == "ROGUE") then return false, 0 end
  elseif classID == 4 then
    if subclassID == 6 then return CAN_SHIELD[class] or false, 1 end
    if subclassID >= 7 and subclassID <= 9 then return RELIC[class] == subclassID, 1 end
    if equipLoc == "INVTYPE_CLOAK" or subclassID == 0 then return true, 1 end
    local best = (ARMOR_BEST[class] or function() return 1 end)(level)
    if subclassID > best then
      -- e.g. plate before level 40: not wearable yet.
      local maxType = (ARMOR_BEST[class] or function() return 1 end)(60)
      return false, subclassID <= maxType and 0 or 0
    end
    return true, subclassID == best and 1 or 0.85
  end
  return true, 1
end

local CASTERS = { PRIEST = true, MAGE = true, WARLOCK = true }

local function DefenseCapped()
  if not UnitDefense then return false end
  local base, mod = UnitDefense("player")
  return (base or 0) + (mod or 0) >= 440
end

function G.Score(link)
  if not link then return nil end
  local stats = GetStats(link)
  if not stats then return nil end
  local w = G.Weights()
  local equipLoc = select(4, ItemInstant(link))
  local class = ns.player.class
  local score = 0
  for key, value in pairs(stats) do
    local k = STATMAP[(key:gsub("_SHORT$", ""))]
    local weight = k and w[k]
    -- Generic spell power also heals: healers without an SP weight use their healing weight.
    if k == "SP" and not weight and w.HEAL then weight = w.HEAL end
    if k == "DPS" and weight then
      if CASTERS[class] and equipLoc ~= "INVTYPE_RANGEDRIGHT" then weight = 0          -- only wands count for casters
      elseif class == "HUNTER" and equipLoc ~= "INVTYPE_RANGED" and equipLoc ~= "INVTYPE_RANGEDRIGHT" then
        weight = weight * 0.3                                                          -- hunters: melee weapon matters less
      end
    end
    -- Defense is worth far less once the 440 cap is reached.
    if k == "DEF" and weight and DefenseCapped() then weight = weight * 0.1 end
    if weight then score = score + weight * value end
  end
  return score
end

local function EquippedScore(slot)
  local link = GetInventoryItemLink("player", slot)
  return link and (G.Score(link) or 0) or 0, link
end

-- Returns percent improvement over what's equipped (nil if not comparable), and the slot it would go in.
function G.Upgrade(link)
  local usable, mult = G.Usable(link)
  if not usable then return nil end
  local reqLevel = select(5, GetItemInfo(link))
  if reqLevel and reqLevel > (ns.player.level or 1) + 0 and reqLevel > 0 then
    -- Not usable yet; still compare so the player knows what's coming.
  end
  local score = G.Score(link)
  if not score then return nil end
  score = score * mult
  local equipLoc = select(4, ItemInstant(link))
  local slots = SLOTS[equipLoc]
  local old, slot
  if equipLoc == "INVTYPE_2HWEAPON" then
    old = EquippedScore(16) + EquippedScore(17); slot = 16
  elseif #slots == 2 then
    local a, b = EquippedScore(slots[1]), EquippedScore(slots[2])
    if a <= b then old, slot = a, slots[1] else old, slot = b, slots[2] end
  else
    old = EquippedScore(slots[1]); slot = slots[1]
  end
  if old <= 0 then return score > 0 and 100 or nil, slot end
  return (score - old) / old * 100, slot
end

---------------------------------------------------------------------------
-- Tooltip annotation
---------------------------------------------------------------------------
local function OnItemTooltip(tooltip)
  if not ns.db or not ns.db.gearAdvisor or not tooltip.GetItem then return end
  local _, link = tooltip:GetItem()
  if not link then return end
  local pct = G.Upgrade(link)
  if not pct then return end
  local _, spec = G.Weights()
  if ns.rewardPick and ns.rewardPick == link then
    tooltip:AddLine("|TInterface\\RaidFrame\\ReadyCheck-Ready:14|t Coffey's Guide: recommended quest reward", 0.3, 0.9, 0.3)
  end
  if pct >= 1 then
    tooltip:AddLine(("Coffey's Guide: |cff4ce64c+%d%% upgrade|r for %s"):format(pct, spec), 1, 0.82, 0)
  elseif pct <= -1 then
    tooltip:AddLine(("Coffey's Guide: %d%% vs equipped (%s)"):format(pct, spec), 0.6, 0.6, 0.6)
  end
  tooltip:Show()
end

local function InstallTooltip()
  local done = false
  if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
    done = pcall(TooltipDataProcessor.AddTooltipPostCall, Enum.TooltipDataType.Item,
      function(tt) pcall(OnItemTooltip, tt) end)
  end
  if not done then
    for _, tt in ipairs({ GameTooltip, ItemRefTooltip }) do
      if tt and tt.HookScript then pcall(tt.HookScript, tt, "OnTooltipSetItem", function(t) pcall(OnItemTooltip, t) end) end
    end
  end
end

---------------------------------------------------------------------------
-- Bag upgrade popup
---------------------------------------------------------------------------
local popup
local announced = {}

local function CreatePopup()
  local UI = ns.UI
  popup = UI.Panel("CoffeyGuideUpgrade", UIParent, 300, 64)
  popup:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 220)
  popup:SetFrameStrata("DIALOG")
  popup:Hide()
  popup.icon = UI.Icon(popup, 36); popup.icon:SetPoint("LEFT", 12, 0)
  popup.title = UI.Text(popup, "GameFontNormal"); popup.title:SetPoint("TOPLEFT", popup.icon, "TOPRIGHT", 8, 0)
  popup.title:SetWidth(240)
  popup.sub = UI.Text(popup, "GameFontHighlightSmall"); popup.sub:SetPoint("TOPLEFT", popup.title, "BOTTOMLEFT", 0, -2)
  popup.equip = UI.Button(popup, "Equip", 60, function()
    if InCombatLockdown() then ns.Print("Can't equip in combat."); return end
    if popup.bag and C_Container and C_Container.UseContainerItem then C_Container.UseContainerItem(popup.bag, popup.slot)
    elseif popup.bag and UseContainerItem then UseContainerItem(popup.bag, popup.slot) end
    popup:Hide()
  end)
  popup.equip:SetPoint("BOTTOMRIGHT", -70, 6)
  popup.ignore = UI.Button(popup, "Ignore", 60, function() popup:Hide() end)
  popup.ignore:SetPoint("LEFT", popup.equip, "RIGHT", 4, 0)
  local hover = CreateFrame("Frame", nil, popup)
  hover:SetAllPoints(popup.icon)
  hover:EnableMouse(true)
  hover:SetScript("OnEnter", function(self)
    if popup.link then GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:SetHyperlink(popup.link); GameTooltip:Show() end
  end)
  hover:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function ContainerLink(bag, slot)
  if C_Container and C_Container.GetContainerItemLink then return C_Container.GetContainerItemLink(bag, slot) end
  return GetContainerItemLink and GetContainerItemLink(bag, slot)
end
local function NumSlots(bag)
  if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(bag) end
  return GetContainerNumSlots and GetContainerNumSlots(bag) or 0
end

function G.ScanBags()
  if not ns.db.gearAdvisor or InCombatLockdown() then return end
  local best, bestPct, bestBag, bestSlot
  for bag = 0, 4 do
    for slot = 1, NumSlots(bag) do
      local link = ContainerLink(bag, slot)
      if link and not announced[link] then
        local reqLevel = select(5, GetItemInfo(link))
        if not reqLevel or reqLevel <= (ns.player.level or 1) then
          local pct = G.Upgrade(link)
          if pct and pct >= 3 and (not bestPct or pct > bestPct) then best, bestPct, bestBag, bestSlot = link, pct, bag, slot end
        end
      end
    end
  end
  if best then
    announced[best] = true
    if not popup then CreatePopup() end
    popup.link, popup.bag, popup.slot = best, bestBag, bestSlot
    popup.icon:SetTexture(select(10, GetItemInfo(best)) or "Interface\\Icons\\INV_Misc_QuestionMark")
    popup.title:SetText("Upgrade: " .. best)
    local _, spec = G.Weights()
    popup.sub:SetText(("|cff4ce64c+%d%%|r for %s"):format(bestPct, spec))
    popup:Show()
  end
end

---------------------------------------------------------------------------
-- Quest reward recommendation
---------------------------------------------------------------------------
function G.RecommendReward()
  if not ns.db.rewardHints then return end
  local n = GetNumQuestChoices and GetNumQuestChoices() or 0
  if n < 2 then ns.rewardPick = nil; return end
  local bestUp, bestUpPct, bestSell, bestSellVal
  for i = 1, n do
    local link = GetQuestItemLink("choice", i)
    if link then
      local pct = G.Upgrade(link)
      if pct and pct > 0 and (not bestUpPct or pct > bestUpPct) then bestUp, bestUpPct = i, pct end
      local sell = select(11, GetItemInfo(link)) or 0
      if not bestSellVal or sell > bestSellVal then bestSell, bestSellVal = i, sell end
    end
  end
  local pick, why
  if bestUp then
    pick = bestUp; why = ("+%d%% upgrade"):format(bestUpPct)
  elseif bestSell then
    pick = bestSell; why = "no upgrades - highest vendor value" ..
      (GetCoinTextureString and bestSellVal > 0 and (" (" .. GetCoinTextureString(bestSellVal) .. ")") or "")
  end
  if pick then
    ns.rewardPick = GetQuestItemLink("choice", pick)
    ns.Print(("Quest reward: take %s - %s"):format(ns.rewardPick or "?", why))
    ns.Fire("RewardPick", pick, ns.rewardPick, why)
  end
end

---------------------------------------------------------------------------
-- Wiring
---------------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("BAG_UPDATE_DELAYED")
ev:RegisterEvent("QUEST_COMPLETE")
ev:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
local pending = false
ev:SetScript("OnEvent", function(_, event)
  if not ns.db then return end
  if event == "QUEST_COMPLETE" then
    C_Timer.After(0.2, G.RecommendReward)
    return
  end
  if event == "PLAYER_EQUIPMENT_CHANGED" then wipe(announced) end
  if pending then return end
  pending = true
  C_Timer.After(1, function() pending = false; G.ScanBags() end)
end)

ns.On("Login", InstallTooltip)
ns.On("LevelUp", function() wipe(announced); C_Timer.After(2, G.ScanBags) end)
