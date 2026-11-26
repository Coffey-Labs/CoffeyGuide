-- Coffey's Leveling Guide progress detection: works out where a character really is when that differs
-- from the first unfinished route step. This happens to anyone who installs the guide mid-way, levels
-- off-route for a while, or follows a different zone order. Evidence comes from the quest log, the
-- completed-quest history and the zone the player is standing in. The guide never jumps on its own;
-- it offers the jump in the tracker, and a jump can be undone.
local ADDON, ns = ...

local D = {}
ns.Detect = D

local LOOKAHEAD = 15        -- how many route steps past the current one to consider
local dismissed = {}        -- step id -> true: "Not now" for this session

local SUGGEST_KINDS = { zone = true, quest = true, travel = true }

---------------------------------------------------------------------------
-- Where is the player?
---------------------------------------------------------------------------
local function PlayerMap()
  if C_Map and C_Map.GetBestMapForUnit then return C_Map.GetBestMapForUnit("player") end
end

-- The player's map and its parents (a city or sub-zone counts as the zone around it).
local function MapChain(mapID)
  local chain = {}
  local id = mapID
  for _ = 1, 4 do
    if not id or id == 0 then break end
    chain[id] = true
    local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(id)
    id = info and info.parentMapID
  end
  return chain
end

-- Maps a route step covers: its own map plus every map its quest plan points at.
local stepMaps = {}
local function StepMaps(step)
  local m = stepMaps[step.id]
  if m then return m end
  m = {}
  if step.map then m[step.map] = true end
  for _, s in ipairs(ns.PlanFor(step) or {}) do
    if s.wp and s.wp[1] then m[s.wp[1]] = true end
  end
  stepMaps[step.id] = m
  return m
end

function D.IsHere(step, chain)
  chain = chain or MapChain(PlayerMap())
  for map in pairs(StepMaps(step)) do
    if chain[map] then return true end
  end
  return false
end

---------------------------------------------------------------------------
-- Evidence for one step
---------------------------------------------------------------------------
-- Returns { inLog, ready, done, total, here } for the quests a step names (its own list and its plan).
function D.Evidence(step, chain)
  local e = { inLog = 0, ready = 0, done = 0, total = 0, here = false }
  local seen = {}
  local function count(q)
    local name, id = q, nil
    if type(q) == "table" then name, id = q[1], q[2] end
    local key = id or name
    if not key or seen[key] then return end
    seen[key] = true
    e.total = e.total + 1
    if ns.IsQuestActive(q) then
      e.inLog = e.inLog + 1
      if id and ns.logComplete and ns.logComplete[id] then e.ready = e.ready + 1 end
    elseif ns.IsQuestDone(q) then
      e.done = e.done + 1
    end
  end
  -- With a quest plan, only quests the plan turns in count: one picked up at the end of a zone
  -- and handed in at the next is evidence for the next zone, not this one.
  local plan = ns.PlanFor(step)
  if plan and #plan > 0 then
    for _, s in ipairs(plan) do if s.act == "turnin" and s.quest then count(s.quest) end end
  else
    for _, q in ipairs(step.quests or {}) do count(q) end
  end
  e.here = D.IsHere(step, chain)
  return e
end

local function Score(e)
  return e.inLog * 3 + e.ready * 2 + (e.here and 4 or 0) + math.min(e.done, 6)
end

---------------------------------------------------------------------------
-- Suggestion
---------------------------------------------------------------------------
local function Reason(step, e)
  local zone = step.zone or step.title or "this step"
  if e.here and e.inLog > 0 then
    return ("You're in %s with %d of its quests in your log."):format(zone, e.inLog)
  elseif e.inLog > 0 then
    return ("You have %d quests for %s in your log."):format(e.inLog, zone)
  end
  return ("You're in %s and have already done %d of its quests."):format(zone, e.done)
end

-- Returns index, step, reason when a later step fits better than the current one.
-- The tracker asks on every refresh; quest-log updates come in bursts while fighting,
-- so the answer is kept for a couple of seconds.
local cache = { t = -10 }
local Compute
function D.Suggestion()
  local now = GetTime and GetTime() or 0
  local cur = ns.route and ns.CurrentIndex and ns.CurrentIndex()
  if cache.cur == cur and now - cache.t < 2 then return cache.i, cache.step, cache.reason end
  local i, step, reason = Compute()
  cache.t, cache.cur, cache.i, cache.step, cache.reason = now, cur, i, step, reason
  return i, step, reason
end
function D.Invalidate() cache.t = -10 end

Compute = function()
  if not ns.db or not ns.db.suggest or not ns.route or #ns.route == 0 then return end
  local cur = ns.CurrentIndex()
  local curStep = ns.route[cur]
  if not curStep then return end
  local chain = MapChain(PlayerMap())
  local ce = D.Evidence(curStep, chain)
  -- Busy on the current step (its quests in the log and standing in its zone): never interrupt.
  if ce.here and ce.inLog > 0 then return end
  local level = ns.player.level or UnitLevel("player") or 1
  local best, bestScore, bestE
  for i = cur + 1, math.min(#ns.route, cur + LOOKAHEAD) do
    local st = ns.route[i]
    if not st.optional and SUGGEST_KINDS[st.kind] and not dismissed[st.id] and not ns.StepState(st)
       and (st.min or 1) <= level + 2 then
      local e = D.Evidence(st, chain)
      local strong = e.inLog >= 2 or (e.here and (e.inLog >= 1 or e.done >= 2))
      if strong then
        local sc = Score(e)
        if not bestScore or sc > bestScore then best, bestScore, bestE = i, sc, e end
      end
    end
  end
  if not best or bestScore <= Score(ce) + 2 then return end
  return best, ns.route[best], Reason(ns.route[best], bestE)
end

function D.Dismiss(step)
  if step then dismissed[step.id] = true end
  D.Invalidate()
  ns.Fire("Refresh")
end

-- Jump to route step i: earlier unfinished steps are marked skipped (and remembered, for Undo).
-- Class quests and mounts are put off instead of skipped: they stop holding up the route but
-- stay in the "still open" reminder, because their rewards matter at any level.
function D.JumpTo(i)
  local target = ns.route[i]
  if not target then return end
  local c = ns.char
  local prev = D.RecentJump()
  local skipped = prev and prev.ids or {}
  local deferred = prev and prev.deferred or {}
  c.defer = c.defer or {}
  for j = 1, i - 1 do
    local st = ns.route[j]
    if not st.optional and not ns.StepState(st) then
      if st.kind == "class" or st.kind == "mount" then
        c.defer[st.id] = true
        deferred[#deferred + 1] = st.id
      else
        c.skip[st.id] = true
        skipped[#skipped + 1] = st.id
      end
    end
  end
  ns.Invalidate()
  c.lastJump = { ids = skipped, deferred = deferred, to = target.id, t = time and time() or 0 }
  D.Invalidate()
  ns.char.view = nil
  ns.Print(("Jumped to |cffffd100%s|r. %d earlier step(s) marked skipped; Undo in the tracker.")
    :format(target.title or "?", #skipped))
  ns.Fire("Refresh")
end

function D.UndoJump()
  local j = ns.char.lastJump
  if not j then return end
  for _, id in ipairs(j.ids or {}) do ns.char.skip[id] = nil end
  for _, id in ipairs(j.deferred or {}) do if ns.char.defer then ns.char.defer[id] = nil end end
  ns.char.lastJump = nil
  ns.Invalidate()
  ns.char.view = nil
  D.Invalidate()
  ns.Fire("Refresh")
end

-- The Undo offer stays for a few minutes after a jump.
function D.RecentJump()
  local j = ns.char and ns.char.lastJump
  if not j or not j.ids or (#j.ids + #(j.deferred or {})) == 0 then return nil end
  if time and j.t and time() - j.t > 300 then return nil end
  return j
end

---------------------------------------------------------------------------
-- Catch-up summary (welcome panel and the first history sync)
---------------------------------------------------------------------------
function D.Summary()
  local s = { done = 0, outleveled = 0, behind = 0, total = 0, completed = 0 }
  for _, st in ipairs(ns.route) do
    if not st.optional then
      s.total = s.total + 1
      local state = ns.StepState(st)
      if state == "outleveled" then s.outleveled = s.outleveled + 1
      elseif state == "behind" then s.behind = s.behind + 1
      elseif state then s.done = s.done + 1 end
    end
  end
  for _ in pairs(ns.completed or {}) do s.completed = s.completed + 1 end
  s.current = ns.route[ns.CurrentIndex()]
  local i, step, reason = D.Suggestion()
  if i then s.suggestIndex, s.suggestStep, s.suggestReason = i, step, reason end
  return s
end

---------------------------------------------------------------------------
-- Wiring: zone changes can change the suggestion.
---------------------------------------------------------------------------
local ev = CreateFrame("Frame")
pcall(ev.RegisterEvent, ev, "ZONE_CHANGED_NEW_AREA")
ev:SetScript("OnEvent", function()
  D.Invalidate()
  if ns.char and ns.QueueRefresh then ns.QueueRefresh() end
end)
