-- ForeverGuide quest history: reads the server's completed-quest list and the live quest log so
-- route progress reflects everything the character has done, including before the addon existed.
-- Questie (optional) adds quest names for completed IDs and per-zone quest counts.
local ADDON, ns = ...

ns.completed = {}        -- questID -> true (server history)
ns.completedNames = {}   -- quest title -> true (resolved from completed IDs)
local resolved = false

---------------------------------------------------------------------------
-- Optional Questie helpers
---------------------------------------------------------------------------
local function Questie()
  if not ns.db.useQuestie or not QuestieLoader or not QuestieLoader.ImportModule then return end
  local ok, qdb = pcall(QuestieLoader.ImportModule, QuestieLoader, "QuestieDB")
  local ok2, zdb = pcall(QuestieLoader.ImportModule, QuestieLoader, "ZoneDB")
  if ok and qdb and qdb.QueryQuestSingle then return qdb, ok2 and zdb or nil end
end

local function QuestName(id)
  if C_QuestLog and C_QuestLog.GetTitleForQuestID then
    local t = C_QuestLog.GetTitleForQuestID(id)
    if t and t ~= "" then return t end
  end
  local qdb = Questie()
  if qdb then
    local ok, name = pcall(qdb.QueryQuestSingle, id, "name")
    if ok and type(name) == "string" then return name end
  end
end

---------------------------------------------------------------------------
-- Completed quests
---------------------------------------------------------------------------
function ns.LoadCompleted()
  wipe(ns.completed)
  if C_QuestLog and C_QuestLog.GetAllCompletedQuestIDs then
    for _, id in ipairs(C_QuestLog.GetAllCompletedQuestIDs() or {}) do ns.completed[id] = true end
  elseif GetQuestsCompleted then
    local t = GetQuestsCompleted()
    if type(t) == "table" then for id in pairs(t) do ns.completed[id] = true end end
  end
  local n = 0
  for _ in pairs(ns.completed) do n = n + 1 end
  return n
end

-- Resolve completed IDs to names in small batches (avoids a login hitch).
function ns.ResolveCompletedNames(onDone)
  local ids = {}
  for id in pairs(ns.completed) do ids[#ids + 1] = id end
  local i = 1
  local function batch()
    local stop = math.min(i + 150, #ids)
    for j = i, stop do
      local name = QuestName(ids[j])
      if name then ns.completedNames[name] = true end
    end
    i = stop + 1
    if i <= #ids then C_Timer.After(0.05, batch)
    else resolved = true; if onDone then onDone() end end
  end
  if #ids > 0 then batch() else resolved = true; if onDone then onDone() end end
end

---------------------------------------------------------------------------
-- Zone completion stats (Questie only)
---------------------------------------------------------------------------
local zoneMap, zoneMapBuilt
local zoneStatsCache = {}

local function BuildZoneMap()
  if zoneMapBuilt then return zoneMap end
  zoneMapBuilt = true
  local qdb, zdb = Questie()
  if not qdb or not zdb or not zdb.GetZonesWithQuests then return nil end
  local ok, map = pcall(zdb.GetZonesWithQuests, false)
  if ok and type(map) == "table" then zoneMap = map end
  return zoneMap
end

-- Returns done, total for quests in the step's zone within its level band (nil when unavailable).
function ns.ZoneStats(step)
  if not ns.historyReady or not step or not step.map or step.kind ~= "zone" then return nil end
  local key = step.id
  local cached = zoneStatsCache[key]
  if cached and cached.t > GetTime() - 30 then return cached.done, cached.total end
  local qdb, zdb = Questie()
  local map = BuildZoneMap()
  if not qdb or not zdb or not map then return nil end
  local okA, areaId = pcall(zdb.GetAreaIdByUiMapId, zdb, step.map)
  if not okA or not areaId or not map[areaId] then return nil end
  local lo, hi = (step.min or 1) - 2, (step.max or 60) + 2
  local done, total = 0, 0
  for id in pairs(map[areaId]) do
    local okL, lvl = pcall(qdb.QueryQuestSingle, id, "questLevel")
    lvl = okL and tonumber(lvl) or nil
    if lvl and lvl >= lo and lvl <= hi then
      total = total + 1
      if ns.completed[id] then done = done + 1 end
    end
  end
  zoneStatsCache[key] = { done = done, total = total, t = GetTime() }
  if total == 0 then return nil end
  return done, total
end

---------------------------------------------------------------------------
-- Wiring
---------------------------------------------------------------------------
function ns.SyncHistory(announce)
  local n = ns.LoadCompleted()
  wipe(zoneStatsCache)
  ns.ResolveCompletedNames(function()
    ns.historyReady = true
    ns.char.view = nil
    ns.Fire("Refresh")
    if announce then
      local step = ns.route[ns.CurrentIndex()]
      ns.Print(("Synced %d completed quests from your quest history. Current step: |cffffd100%s|r")
        :format(n, step and step.title or "?"))
    end
  end)
end

ns.On("Login", function()
  ns.char.questIDs = ns.char.questIDs or {}
  -- Wait a moment: the completed list and quest titles load shortly after login.
  C_Timer.After(3, function() ns.SyncHistory(not ns.char.syncedOnce); ns.char.syncedOnce = true end)
end)

ns.On("QuestTurnedIn", function(id, title)
  if id then ns.completed[id] = true end
  if title then ns.completedNames[title] = true end
  wipe(zoneStatsCache)
end)

-- Learn IDs for quests the data only knows by name, from whatever is in the quest log.
ns.On("QuestLogChanged", function()
  if not ns.char or not ns.char.questIDs then return end
  for id, title in pairs(ns.logIDs) do ns.char.questIDs[title] = id end
end)
