-- Coffey's Leveling Guide quality-of-life automation. Everything here is OFF by default so it never
-- fights other addons (DialogueUI, Immersion, Leatrix Plus...). Hold Shift to bypass.
local ADDON, ns = ...

local function Bypass() return IsShiftKeyDown() end

local function NumSlots(bag)
  if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(bag) end
  return GetContainerNumSlots and GetContainerNumSlots(bag) or 0
end

local function SellGreys()
  local total, count = 0, 0
  for bag = 0, 4 do
    for slot = 1, NumSlots(bag) do
      local info = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(bag, slot)
      if info and info.quality == 0 and not info.hasNoValue and info.hyperlink then
        local price = select(11, GetItemInfo(info.hyperlink)) or 0
        if price > 0 then
          total = total + price * (info.stackCount or 1)
          count = count + 1
          C_Container.UseContainerItem(bag, slot)
        end
      end
    end
  end
  if count > 0 then
    ns.Print(("Sold %d grey item(s) for %s"):format(count, GetCoinTextureString and GetCoinTextureString(total) or total))
  end
end

local function Repair()
  if not CanMerchantRepair or not CanMerchantRepair() then return end
  local cost, canRepair = GetRepairAllCost()
  if canRepair and cost > 0 and GetMoney() >= cost then
    RepairAllItems()
    ns.Print("Repaired for " .. (GetCoinTextureString and GetCoinTextureString(cost) or cost))
  end
end

local ev = CreateFrame("Frame")
for _, e in ipairs({ "QUEST_DETAIL", "QUEST_PROGRESS", "QUEST_COMPLETE", "GOSSIP_SHOW", "QUEST_GREETING", "MERCHANT_SHOW" }) do
  pcall(ev.RegisterEvent, ev, e)
end

ev:SetScript("OnEvent", function(_, event)
  local db = ns.db
  if not db or Bypass() then return end

  if event == "QUEST_DETAIL" and db.autoAccept then
    AcceptQuest()

  elseif event == "QUEST_PROGRESS" and db.autoTurnIn then
    if IsQuestCompletable() then CompleteQuest() end

  elseif event == "QUEST_COMPLETE" and db.autoTurnIn then
    -- Only auto-complete when there's no reward choice to make.
    if (GetNumQuestChoices() or 0) <= 1 then GetQuestReward(GetNumQuestChoices()) end

  elseif event == "GOSSIP_SHOW" and C_GossipInfo then
    if db.autoTurnIn and C_GossipInfo.GetActiveQuests then
      for _, q in ipairs(C_GossipInfo.GetActiveQuests() or {}) do
        if q.isComplete then C_GossipInfo.SelectActiveQuest(q.questID); return end
      end
    end
    if db.autoAccept and C_GossipInfo.GetAvailableQuests then
      local avail = C_GossipInfo.GetAvailableQuests() or {}
      if avail[1] then C_GossipInfo.SelectAvailableQuest(avail[1].questID) end
    end

  elseif event == "QUEST_GREETING" then
    if db.autoTurnIn and GetNumActiveQuests then
      for i = 1, GetNumActiveQuests() do
        local _, isComplete = GetActiveTitle(i)
        if isComplete then SelectActiveQuest(i); return end
      end
    end
    if db.autoAccept and GetNumAvailableQuests and GetNumAvailableQuests() > 0 then SelectAvailableQuest(1) end

  elseif event == "MERCHANT_SHOW" then
    if db.sellGreys then SellGreys() end
    if db.autoRepair then Repair() end
  end
end)
