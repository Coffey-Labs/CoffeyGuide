-- Coffey's Leveling Guide quest plans: quest-by-quest checklists attached to route steps, live quest-log
-- tracking, and optional Questie database lookups for NPC locations (never required).
local ADDON, ns = ...

ns.logComplete = {}  -- questID -> true when objectives are complete (ready to turn in)

ns.ACT_ICONS = {
  accept  = "Interface\\GossipFrame\\AvailableQuestIcon",
  turnin  = "Interface\\GossipFrame\\ActiveQuestIcon",
  kill    = "Interface\\Icons\\Ability_DualWield",
  collect = "Interface\\Icons\\INV_Misc_Bag_08",
  use     = "Interface\\Icons\\INV_Misc_Gear_01",
  go      = "Interface\\Icons\\Ability_Tracking",
  fp      = "Interface\\Icons\\Ability_Hunter_EagleEye",
  hs      = "Interface\\Icons\\INV_Misc_Rune_01",
  note    = "Interface\\Icons\\INV_Misc_Note_01",
}
local ACT_VERB = { accept = "Accept", turnin = "Turn in", kill = "", collect = "", use = "", go = "", fp = "", hs = "", note = "" }

---------------------------------------------------------------------------
-- Optional Questie lookups
---------------------------------------------------------------------------
local function QuestieModules()
  if not QuestieLoader or not QuestieLoader.ImportModule then return end
  local ok, qdb = pcall(QuestieLoader.ImportModule, QuestieLoader, "QuestieDB")
  local ok2, zdb = pcall(QuestieLoader.ImportModule, QuestieLoader, "ZoneDB")
  if ok and qdb and qdb.GetQuest then return qdb, ok2 and zdb or nil end
end

local function NPCWaypoint(qdb, zdb, npcId)
  local npc = qdb.GetNPC and qdb:GetNPC(npcId)
  if not npc or not npc.spawns then return end
  for areaId, list in pairs(npc.spawns) do
    local first = list[1]
    local map = zdb and zdb.GetUiMapIdByAreaId and zdb:GetUiMapIdByAreaId(areaId)
    if first and map then return { map, first[1], first[2], npc.name or "NPC" } end
  end
end

-- which = "finish" | "start"
local wpCache = {}
function ns.QuestieWaypoint(questID, which)
  if not questID or not ns.db.useQuestie then return end
  local key = questID .. which
  if wpCache[key] ~= nil then return wpCache[key] or nil end
  local result = false
  local ok = pcall(function()
    local qdb, zdb = QuestieModules()
    if not qdb then return end
    local q = qdb.GetQuest(questID)
    if not q then return end
    local npcs = which == "finish" and (q.Finisher and q.Finisher.NPC) or (q.Starts and q.Starts.NPC)
    if npcs and npcs[1] then result = NPCWaypoint(qdb, zdb, npcs[1]) or false end
  end)
  if not ok then result = false end
  wpCache[key] = result
  return result or nil
end

---------------------------------------------------------------------------
-- Plan state
---------------------------------------------------------------------------
local function QuestID(s) return s.quest and s.quest[2] end

local function PlayerMatches(s)
  return not s.races or ns.Contains(s.races, ns.player.race)
end

function ns.PlanFor(step)
  local plan = step and ns.PLANS[step.id]
  if not plan then return nil end
  local out = {}
  for i, s in ipairs(plan) do
    if PlayerMatches(s) then s._i = i; out[#out + 1] = s end
  end
  return out
end

function ns.SubDone(step, s)
  local mark = ns.char.plan[step.id]
  if mark and mark[s._i] then return true end
  local q = s.quest
  local id = QuestID(s)
  if s.act == "note" then return true end
  if q then
    if ns.IsQuestDone(q) then return true end
    if s.act == "accept" then return ns.IsQuestActive(q) and true or false end
    if s.act == "kill" or s.act == "collect" or s.act == "use" then return id and ns.logComplete[id] or false end
    return false
  end
  return false
end

function ns.MarkSub(step, s, value)
  ns.char.plan[step.id] = ns.char.plan[step.id] or {}
  ns.char.plan[step.id][s._i] = value or nil
  ns.Fire("Refresh")
end

-- Returns plan list, index of first undone sub-step (or nil when finished), done count.
function ns.PlanProgress(step)
  local plan = ns.PlanFor(step)
  if not plan then return nil end
  local first, done = nil, 0
  for i, s in ipairs(plan) do
    if ns.SubDone(step, s) then done = done + 1 elseif not first then first = i end
  end
  return plan, first, done
end

function ns.SubText(s)
  local verb = ACT_VERB[s.act] or ""
  local name = s.quest and s.quest[1]
  if s.text and s.text ~= "" then
    if (s.act == "accept" or s.act == "turnin") and name then
      return verb .. " |cffffd100" .. name .. "|r" .. (s.npc and (" (" .. s.npc .. ")") or "") .. " - " .. s.text
    end
    return s.text
  end
  if name then return verb .. " |cffffd100" .. name .. "|r" .. (s.npc and (" from " .. s.npc) or "") end
  return s.act
end

-- Waypoints for the tracker: the current sub-step's location, or Questie's NPC location.
function ns.SubWaypoints(s)
  if not s then return nil end
  if s.wp then return { s.wp } end
  local id = QuestID(s)
  if id and s.act == "turnin" then local wp = ns.QuestieWaypoint(id, "finish"); if wp then return { wp } end end
  if id and s.act == "accept" then local wp = ns.QuestieWaypoint(id, "start"); if wp then return { wp } end end
end

---------------------------------------------------------------------------
-- Quest log snapshot (objectives + completion), used by the Quest Log tab
---------------------------------------------------------------------------
function ns.QuestLogSnapshot()
  local groups, header = {}, nil
  local num = (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
  for i = 1, num do
    local title, level, _, isHeader, _, isComplete, _, id = GetQuestLogTitle(i)
    if isHeader then
      header = { name = title, quests = {} }
      groups[#groups + 1] = header
    elseif title then
      if not header then header = { name = "Quests", quests = {} }; groups[#groups + 1] = header end
      local objectives = {}
      if id and C_QuestLog and C_QuestLog.GetQuestObjectives then
        for _, o in ipairs(C_QuestLog.GetQuestObjectives(id) or {}) do
          objectives[#objectives + 1] = { text = o.text, done = o.finished }
        end
      elseif GetNumQuestLeaderBoards then
        for j = 1, GetNumQuestLeaderBoards(i) do
          local text, _, finished = GetQuestLogLeaderBoard(j, i)
          objectives[#objectives + 1] = { text = text, done = finished }
        end
      end
      header.quests[#header.quests + 1] = { title = title, level = level, id = id,
        complete = (isComplete == 1 or isComplete == true), failed = (isComplete == -1), objectives = objectives }
    end
  end
  return groups
end

function ns.ScanLogCompletion()
  wipe(ns.logComplete)
  local num = (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
  for i = 1, num do
    local _, _, _, isHeader, _, isComplete, _, id = GetQuestLogTitle(i)
    if not isHeader and id and (isComplete == 1 or isComplete == true) then ns.logComplete[id] = true end
  end
end

ns.On("Login", function()
  ns.char.plan = ns.char.plan or {}
  if ns.db.useQuestie == nil then ns.db.useQuestie = true end
  ns.ScanLogCompletion()
end)
ns.On("QuestLogChanged", ns.ScanLogCompletion)
