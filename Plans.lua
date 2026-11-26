-- Coffey's Leveling Guide quest plans: quest-by-quest checklists attached to route steps, live quest-log
-- tracking, and optional Questie database lookups for NPC locations (never required).
local ADDON, ns = ...

ns.logComplete = {}   -- questID -> true when objectives are complete (ready to turn in)
ns.logObjectives = {} -- questID -> { { name, done, have, need }, ... } for quests in the log

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

-- Sub-steps of a route step for this player's race (cached; the race never changes).
local planCache, planCacheRace = {}, nil
function ns.PlanFor(step)
  local plan = step and ns.PLANS[step.id]
  if not plan then return nil end
  if planCacheRace ~= ns.player.race then planCache, planCacheRace = {}, ns.player.race end
  local out = planCache[step.id]
  if out then return out end
  out = {}
  for i, s in ipairs(plan) do
    if PlayerMatches(s) then s._i = i; out[#out + 1] = s; s._pos = #out end
  end
  planCache[step.id] = out
  return out
end

local AutoDone -- defined below: flight paths, hearthstone and travel steps

---------------------------------------------------------------------------
-- Objectives: a quest split over several plan rows ticks off row by row.
-- Rows name their objectives (obj = { "Hexed Troll", "Voodoo Troll" }), matched against
-- the objective text in the quest log, so the order the game lists them in doesn't matter.
---------------------------------------------------------------------------
-- "Hexed Troll slain: 3/8", "3/8 Hexed Troll slain" or "Zalazane's Head: 0/1"
-- -> "hexed troll", 3, 8
local function ParseObjective(text)
  local t = (text or ""):lower()
  local have, need = t:match("(%d+)%s*/%s*(%d+)")
  t = t:gsub("^%s*%d+%s*/%s*%d+%s*", "")
  t = t:gsub("%s*:%s*%d+%s*/%s*%d+%s*$", "")
  t = t:gsub("%s*%(%d+%s*/%s*%d+%)%s*$", "")
  t = t:gsub("%s+slain$", ""):gsub("^%s+", ""):gsub("%s+$", "")
  return t, tonumber(have), tonumber(need)
end

-- The log objective a row names: an exact name first, else the only one containing it.
local function FindObjective(list, want)
  want = want:lower()
  for _, o in ipairs(list) do if o.name == want then return o end end
  local hit
  for _, o in ipairs(list) do
    if o.name:find(want, 1, true) then
      if hit then return nil end
      hit = o
    end
  end
  return hit
end

-- The objectives a row covers, or nil when the log can't tell (quest not in the log, or a
-- name that doesn't match): then the row falls back to the whole quest.
local function RowObjectives(s)
  local id = QuestID(s)
  local list = id and ns.logObjectives[id]
  if not list or #list == 0 then return nil end
  if not s.obj then return list end
  local out = {}
  for _, n in ipairs(s.obj) do
    local o = FindObjective(list, n)
    if not o then return nil end
    out[#out + 1] = o
  end
  return out
end

-- Live counts for a row in progress, e.g. "3/8" or "8/8, 2/4"; nil when there are none.
function ns.SubProgress(s)
  if not s or not (s.act == "kill" or s.act == "collect" or s.act == "use") then return nil end
  local objs = RowObjectives(s)
  if not objs then return nil end
  local parts = {}
  for _, o in ipairs(objs) do
    if o.have and o.need and o.need > 1 then parts[#parts + 1] = o.have .. "/" .. o.need end
  end
  return #parts > 0 and table.concat(parts, ", ") or nil
end

function ns.SubDone(step, s)
  local mark = ns.char.plan[step.id]
  if mark and mark[s._i] then return true end
  local q = s.quest
  local id = QuestID(s)
  if s.act == "note" then return true end
  if s.act == "fp" or s.act == "hs" or s.act == "go" then return AutoDone(step, s) end
  if q then
    if ns.IsQuestDone(q) then return true end
    if s.act == "accept" then return ns.IsQuestActive(q) and true or false end
    if s.act == "kill" or s.act == "collect" or s.act == "use" then
      if not id then return false end
      if ns.logComplete[id] then return true end
      if s.obj then
        local objs = RowObjectives(s)
        if objs then
          for _, o in ipairs(objs) do if not o.done then return false end end
          return true
        end
      end
      return false
    end
    return false
  end
  return false
end

function ns.MarkSub(step, s, value)
  ns.char.plan[step.id] = ns.char.plan[step.id] or {}
  ns.char.plan[step.id][s._i] = value or nil
  ns.Invalidate()
  ns.Fire("Refresh")
end

-- How many different quests past a sub-step must show progress before an untouched
-- quest is treated as passed by (never picked up, or abandoned).
local MISSED_AFTER = 3

-- Returns plan list, index of the first open sub-step (nil when finished), done count, and a
-- set of indexes the player has moved past.
--
-- A quest counts as passed by when it is untouched (not in the log, not completed) and at
-- least MISSED_AFTER other quests whose *first* row comes later in the plan have been picked
-- up or finished. Only a quest's first row counts: the objectives and turn-ins of quests you
-- accepted earlier always sit further down the list, and counting those would flag the next
-- hub's quests while you're simply following the plan. An accept that comes after the turn-in
-- of a quest still in your log is never flagged either, since it may be that quest's follow-up.
-- If more than 40% of the plan would be passed by, nothing is: that's a different route
-- through the zone, not a few skipped quests, so the plan is followed as written.
-- Passed-by rows stay listed (dimmed) but no longer hold the cursor.
local memo = {}
local Compute
function ns.PlanProgress(step)
  if not step then return nil end
  local key = ns.MemoKey()
  local m = memo[step.id]
  if m and m.key == key then return m.plan, m.first, m.done, m.missed end
  local plan, first, done, missed = Compute(step)
  memo[step.id] = { key = key, plan = plan, first = first, done = done, missed = missed }
  return plan, first, done, missed
end

Compute = function(step)
  local plan = ns.PlanFor(step)
  if not plan then return nil end
  local n = #plan
  local doneAt, keyAt, firstPos, touched = {}, {}, {}, {}
  local done = 0
  for i, s in ipairs(plan) do
    if ns.SubDone(step, s) then doneAt[i] = true; done = done + 1 end
    local k = s.quest and (s.quest[2] or s.quest[1])
    if k then
      keyAt[i] = k
      if not firstPos[k] then
        firstPos[k] = i
        touched[k] = (ns.IsQuestActive(s.quest) or ns.IsQuestDone(s.quest)) and true or false
      end
    end
  end
  -- Open turn-ins of quests in the log, by position: accepts after them may be follow-ups.
  local openTurninBefore, open = {}, false
  for i, s in ipairs(plan) do
    openTurninBefore[i] = open
    if s.act == "turnin" and s.quest and not doneAt[i] and ns.IsQuestActive(s.quest) then open = true end
  end
  local missed, missedKey, ahead = {}, {}, 0
  for i = n, 1, -1 do
    local k = keyAt[i]
    if k and firstPos[k] == i then
      if touched[k] then
        ahead = ahead + 1
      elseif not doneAt[i] and ahead >= MISSED_AFTER and not openTurninBefore[i] then
        missedKey[k] = true
      end
    elseif not k and not doneAt[i] and (plan[i].act == "fp" or plan[i].act == "hs") and ahead >= MISSED_AFTER + 1 then
      missed[i] = true
    end
  end
  -- Every row of a passed-by quest goes together (accept, objectives and turn-in).
  for i = 1, n do
    if keyAt[i] and missedKey[keyAt[i]] and not doneAt[i] then missed[i] = true end
  end
  if ns.MissedCount(missed) > n * 0.4 then missed = {} end
  local first
  for i = 1, n do
    if not doneAt[i] and not missed[i] then first = i; break end
  end
  return plan, first, done, missed
end

function ns.MissedCount(missed)
  local c = 0
  for _ in pairs(missed or {}) do c = c + 1 end
  return c
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
  ns.Invalidate()
  wipe(ns.logComplete); wipe(ns.logObjectives)
  local num = (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
  for i = 1, num do
    local _, _, _, isHeader, _, isComplete, _, id = GetQuestLogTitle(i)
    if not isHeader and id then
      if isComplete == 1 or isComplete == true then ns.logComplete[id] = true end
      local list = {}
      local objs = C_QuestLog and C_QuestLog.GetQuestObjectives and C_QuestLog.GetQuestObjectives(id)
      if type(objs) == "table" and #objs > 0 then
        for _, o in ipairs(objs) do
          local name, have, need = ParseObjective(o.text)
          list[#list + 1] = { name = name, done = o.finished and true or false,
                              have = o.numFulfilled or have, need = o.numRequired or need }
        end
      elseif GetNumQuestLeaderBoards and GetQuestLogLeaderBoard then
        for j = 1, GetNumQuestLeaderBoards(i) or 0 do
          local text, _, finished = GetQuestLogLeaderBoard(j, i)
          local name, have, need = ParseObjective(text)
          list[#list + 1] = { name = name, done = finished and true or false, have = have, need = need }
        end
      end
      ns.logObjectives[id] = list
    end
  end
end

ns.On("Login", function()
  ns.char.plan = ns.char.plan or {}
  if ns.db.useQuestie == nil then ns.db.useQuestie = true end
  ns.ScanLogCompletion()
end)
ns.On("QuestLogChanged", ns.ScanLogCompletion)

---------------------------------------------------------------------------
-- Flight paths, hearthstone and travel steps tick off by themselves:
--  fp: the flight path shows up as known on any flight map you open, or you
--      open a flight map / discover a path next to the step's flight master.
--  hs: your hearthstone is bound there (GetBindLocation), or you bind it next
--      to the step's innkeeper. "Hearth to X" ticks when you use the hearthstone.
--  go: done once you have done anything later in the same plan (or, for the
--      last step of a plan, in the next route step that has a plan).
---------------------------------------------------------------------------
local HBD = LibStub and LibStub("HereBeDragons-2.0", true)
local HEARTHSTONE = 8690

local function Lower(t) return (t or ""):lower() end

-- The part of a step's text that names the place: drop "(...)" and ", then ..."
local function Place(s)
  local t = Lower(s.text)
  t = t:gsub("%(.*", ""):gsub(", then .*", "")
  return t
end

local function IsHearthTo(s) return s.act == "hs" and Lower(s.text):find("^hearth to") ~= nil end

local function Mark(step, s)
  ns.char.plan[step.id] = ns.char.plan[step.id] or {}
  ns.char.plan[step.id][s._i] = true
  ns.Invalidate()
end

local function NodeShort(name) return Lower((name or ""):match("^%s*([^,]+)")):gsub("%s+$", "") end

-- Remember every flight path the taxi map lists as known.
function ns.RecordTaxiNodes()
  ns.Invalidate()
  ns.char.taxi = ns.char.taxi or {}
  local known, n = ns.char.taxi, 0
  if NumTaxiNodes and TaxiNodeName then
    for i = 1, NumTaxiNodes() or 0 do
      local kind = TaxiNodeGetType and TaxiNodeGetType(i)
      local name = TaxiNodeName(i)
      if name and (kind == "CURRENT" or kind == "REACHABLE" or not TaxiNodeGetType) then
        known[NodeShort(name)] = true; n = n + 1
      end
    end
  end
  if n == 0 and C_TaxiMap and C_TaxiMap.GetAllTaxiNodes and GetTaxiMapID then
    local ok, nodes = pcall(C_TaxiMap.GetAllTaxiNodes, GetTaxiMapID())
    for _, node in ipairs(ok and nodes or {}) do
      if node.name and (node.state == 0 or node.state == 1) then known[NodeShort(node.name)] = true; n = n + 1 end
    end
  end
  return n
end

local function KnowsFlightPath(s)
  local place = Place(s)
  for short in pairs(ns.char.taxi or {}) do
    if #short >= 4 and place:find(short, 1, true) then return true end
  end
  return false
end

local function BoundHere(s)
  local bind = GetBindLocation and Lower(GetBindLocation())
  return bind ~= nil and #bind >= 4 and Place(s):find(bind, 1, true) ~= nil
end

local function Near(s, yards)
  if not (HBD and s.wp and s.wp[1]) then return false end
  local px, py, pmap = HBD:GetPlayerZonePosition()
  if not px then return false end
  local d = HBD:GetZoneDistance(pmap, px, py, s.wp[1], s.wp[2] / 100, s.wp[3] / 100)
  return d ~= nil and d <= yards
end

local routeIndex, routeIndexFor = {}, nil
local function NextStep(step)
  if routeIndexFor ~= ns.route then
    routeIndex, routeIndexFor = {}, ns.route
    for i, st in ipairs(ns.route or {}) do routeIndex[st.id] = i end
  end
  -- The next route step that has a quest plan (class quest and dungeon steps in between have none).
  local i = routeIndex[step.id]
  if not i then return nil end
  for j = i + 1, math.min(i + 6, #ns.route) do
    local st = ns.route[j]
    if ns.PLANS[st.id] and not st.optional then return st end
  end
end

-- Anything after sub-step s (quest steps, flight paths, hearthstone binds) done?
local function LaterDone(step, s, plan)
  for i = (s._pos or 0) + 1, #plan do
    local o = plan[i]
    if o.act ~= "go" and o.act ~= "note" and not IsHearthTo(o) and ns.SubDone(step, o) then return true end
  end
  return false
end

AutoDone = function(step, s)
  if s.act == "fp" then
    return KnowsFlightPath(s)
  elseif s.act == "hs" and not IsHearthTo(s) then
    return BoundHere(s)
  end
  -- "go" and "Hearth to X": done once you have moved on.
  local plan = ns.PlanFor(step)
  if not plan then return false end
  if LaterDone(step, s, plan) then return true end
  if s._pos == #plan then
    local nxt = NextStep(step)
    local nplan = nxt and ns.PlanFor(nxt)
    if nplan then
      for _, o in ipairs(nplan) do
        if o.act ~= "go" and o.act ~= "note" and not IsHearthTo(o) and ns.SubDone(nxt, o) then return true end
      end
    end
  end
  return false
end

-- Steps the player is working on: the current one and the one being viewed.
local function ActiveSteps()
  local out = {}
  for _, i in ipairs({ ns.CurrentIndex(), ns.ViewIndex() }) do
    local st = ns.route[i]
    if st and st ~= out[1] then out[#out + 1] = st end
  end
  return out
end

-- Mark undone sub-steps of the active steps that match; true if any changed.
local function MarkActive(match)
  local hit = false
  for _, step in ipairs(ActiveSteps()) do
    for _, s in ipairs(ns.PlanFor(step) or {}) do
      local marks = ns.char.plan[step.id]
      if not (marks and marks[s._i]) and match(s) then Mark(step, s); hit = true end
    end
  end
  return hit
end

local function FirstHearthTo()
  for _, step in ipairs(ActiveSteps()) do
    for _, s in ipairs(ns.PlanFor(step) or {}) do
      if IsHearthTo(s) and not ns.SubDone(step, s) then Mark(step, s); return true end
    end
  end
  return false
end

-- A bind only counts while it lasts, so save it on the steps you are working on;
-- otherwise moving your hearthstone later would undo them.
local function SaveBinds()
  if ns.char and ns.char.plan and ns.route then
    MarkActive(function(s) return s.act == "hs" and not IsHearthTo(s) and BoundHere(s) end)
  end
end
ns.On("Refresh", SaveBinds)

-- Travel rows ("go") tick off when you arrive within ARRIVE yards of their waypoint. Only the
-- current row of the steps you are working on counts, so riding past a later stop doesn't.
local ARRIVE = 50
function ns.CheckArrival()
  if not (ns.char and ns.char.plan and ns.route and HBD) then return false end
  local hit = false
  for _, step in ipairs(ActiveSteps()) do
    local plan, first = ns.PlanProgress(step)
    local s = plan and first and plan[first]
    if s and s.act == "go" and s.wp and Near(s, ARRIVE) then Mark(step, s); hit = true end
  end
  if hit then ns.Fire("Refresh") end
  return hit
end
if C_Timer and C_Timer.NewTicker then C_Timer.NewTicker(2, function() pcall(ns.CheckArrival) end) end

local ev = CreateFrame("Frame")
for _, e in ipairs({ "TAXIMAP_OPENED", "UI_INFO_MESSAGE", "HEARTHSTONE_BOUND", "UNIT_SPELLCAST_SUCCEEDED" }) do
  pcall(ev.RegisterEvent, ev, e)
end
ev:SetScript("OnEvent", function(_, e, a1, a2, a3)
  if not ns.char or not ns.char.plan or not ns.route then return end
  local changed = false
  if e == "TAXIMAP_OPENED" then
    ns.RecordTaxiNodes()
    MarkActive(function(s) return s.act == "fp" and Near(s, 60) end)
    changed = true
  elseif e == "UI_INFO_MESSAGE" then
    if ERR_NEWTAXIPATH and (a1 == ERR_NEWTAXIPATH or a2 == ERR_NEWTAXIPATH) then
      changed = MarkActive(function(s) return s.act == "fp" and Near(s, 100) end) or true
    end
  elseif e == "HEARTHSTONE_BOUND" then
    MarkActive(function(s) return s.act == "hs" and not IsHearthTo(s) and (BoundHere(s) or Near(s, 60)) end)
    changed = true
  elseif e == "UNIT_SPELLCAST_SUCCEEDED" then
    local spell = a3 or a2
    if a1 == "player" and spell == HEARTHSTONE then changed = FirstHearthTo() end
  end
  if changed then ns.Fire("Refresh") end
end)
