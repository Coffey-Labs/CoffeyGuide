-- Coffey's Leveling Guide core: player detection, route building, progress, talents, professions, events.
local ADDON, ns = ...
local Print = ns.Print

local DEFAULTS = {
  arrow = true, pins = true, autoWaypoint = true, toasts = true, lock = false, scale = 1.0,
  autoSkip = true, useTomTom = true, showOptional = true, talentGlow = true,
  gearAdvisor = true, rewardHints = true,
  autoAccept = false, autoTurnIn = false, sellGreys = false, autoRepair = false,
  minimap = { hide = false },
  -- Tracker layout: density is "standard" or "detailed"; compact collapses it to the next action.
  density = "standard", compact = false, fontScale = 1.0, bgAlpha = 0.90,
  combatFade = true, instanceHide = true, mouseoverFade = false,
  suggest = true, quiet = true, colorblind = false, accentGold = false,
}

ns.player = {}
ns.route, ns.tips = {}, {}
ns.activeQuests = {}   -- quest title -> true (in quest log)
ns.logIDs = {}         -- questID -> title (in quest log)
ns.talents = { byName = {}, tabs = {}, total = 0 }
ns.profs = {}

-- Step and plan state is worked out many times per refresh (progress bar, current step,
-- next-step preview, suggestions, the Route tab). It is cached per "generation": anything
-- that can change it calls ns.Invalidate(), and every Refresh starts a new generation. The
-- cache is also keyed on the frame time, so a missed Invalidate can never outlive a frame.
ns.gen = 0
function ns.Invalidate() ns.gen = ns.gen + 1 end
function ns.MemoKey() return ns.gen .. ":" .. tostring(GetTime and GetTime() or 0) end

local listeners = {}
function ns.On(name, fn) listeners[name] = listeners[name] or {}; table.insert(listeners[name], fn) end
function ns.Fire(name, ...)
  if name == "Refresh" or name == "SettingsChanged" then ns.Invalidate() end
  for _, fn in ipairs(listeners[name] or {}) do
    local ok, err = pcall(fn, ...)
    if not ok then geterrorhandler()(err) end
  end
end

---------------------------------------------------------------------------
-- Player
---------------------------------------------------------------------------
local function DetectPlayer()
  local p = ns.player
  local raceName, raceFile, raceID = UnitRace("player")
  p.raceName, p.raceID = raceName, raceID
  p.race = raceFile
  if (raceName and raceName:find("Skyborne")) or (raceFile and raceFile:find("Skyborne")) then p.race = "Skyborne" end
  p.className, p.class = UnitClass("player")
  p.faction = UnitFactionGroup("player")
  if p.faction ~= "Horde" and p.faction ~= "Alliance" then
    -- Skyborne before choosing a side: High Order = Alliance, Windshaper = Horde.
    if raceName and raceName:find("High Order") then p.faction = "Alliance"
    elseif raceName and raceName:find("Windshaper") then p.faction = "Horde" end
  end
  p.level = UnitLevel("player")
  p.name = UnitName("player")
end

local function Matches(step)
  local p = ns.player
  if step.faction and p.faction and step.faction ~= p.faction then return false end
  if step.races and not ns.Contains(step.races, p.race) then return false end
  if step.classes and not ns.Contains(step.classes, p.class) then return false end
  return true
end

function ns.BuildRoute()
  wipe(ns.route); wipe(ns.tips)
  for _, step in ipairs(ns.ALLSTEPS) do
    step.kind = step.kind or "quest"
    if Matches(step) then
      if ns.TIP_KINDS[step.kind] then ns.tips[#ns.tips + 1] = step
      else ns.route[#ns.route + 1] = step end
    end
  end
  local function cmp(a, b)
    if (a.min or 1) ~= (b.min or 1) then return (a.min or 1) < (b.min or 1) end
    return a._order < b._order
  end
  table.sort(ns.route, cmp)
  table.sort(ns.tips, cmp)
end

---------------------------------------------------------------------------
-- Quests and step state
---------------------------------------------------------------------------
local function QuestNameID(q)
  if type(q) == "table" then return q[1], q[2] end
  return q, nil
end

local function FlaggedDone(id)
  if ns.completed and ns.completed[id] then return true end
  return (C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted and C_QuestLog.IsQuestFlaggedCompleted(id)) and true or false
end

function ns.IsQuestDone(q)
  local name, id = QuestNameID(q)
  -- A quest the data names by ID is judged by that ID alone. Hundreds of quests share a name
  -- (chains such as "A Dark Threat Looms" 161 > 199 > 250, faction copies), and finishing one
  -- must not tick off the others.
  if id then return FlaggedDone(id) end
  -- Quests the data only knows by name: use the ID learned from the quest log when there is one.
  id = name and ns.char.questIDs and ns.char.questIDs[name]
  if id then
    if ns.completed and ns.completed[id] then return true end
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted and C_QuestLog.IsQuestFlaggedCompleted(id) then return true end
    -- A quest that is in the log right now is not complete, whatever its name matches.
    if ns.logIDs[id] then return false end
  end
  if not name then return false end
  if ns.activeQuests[name] then return false end
  return (ns.completedNames and ns.completedNames[name]) or ns.char.questNames[name] or false
end

function ns.IsQuestActive(q)
  local name, id = QuestNameID(q)
  -- When the log reports quest IDs, a quest with an ID matches by ID alone: a later part of a
  -- same-name chain in the log is a different quest. Names are the fallback for clients
  -- that report no IDs.
  if id and next(ns.logIDs) then return ns.logIDs[id] or false end
  return (id and ns.logIDs[id]) or (name and ns.activeQuests[name]) or false
end

local stateMemo, stateKey = {}, nil
local ComputeState

-- How many route steps' plans turn in each quest (by ID, or name when there is no ID).
local turninSteps, turninFor = {}, nil
local function TurninSteps()
  if turninFor ~= ns.route then
    turninSteps, turninFor = {}, ns.route
    for _, st in ipairs(ns.route or {}) do
      local seen = {}
      for _, s in ipairs(ns.PlanFor and ns.PlanFor(st) or {}) do
        local key = s.act == "turnin" and s.quest and (s.quest[2] or s.quest[1])
        if key and not seen[key] then seen[key] = true; turninSteps[key] = (turninSteps[key] or 0) + 1 end
      end
    end
  end
  return turninSteps
end

-- How many of a step's quests are in the log, done, and in all. With a quest plan, only quests
-- the plan turns in count: a quest picked up at the end of a zone and handed in at the next
-- belongs to the next zone, and must not hold the old one open. A quest that several steps
-- turn in (one the route puts off to a second visit) holds none of them.
local function StepQuestCounts(step)
  local inLog, done, total, seen = 0, 0, 0, {}
  local function count(q)
    local name, id = QuestNameID(q)
    local key = id or name
    if not key or seen[key] then return end
    seen[key] = true
    total = total + 1
    if ns.IsQuestActive(q) then inLog = inLog + 1 elseif ns.IsQuestDone(q) then done = done + 1 end
  end
  local plan = ns.PlanFor and ns.PlanFor(step)
  if plan and #plan > 0 then
    local owners = TurninSteps()
    for _, s in ipairs(plan) do
      if s.act == "turnin" and s.quest and owners[s.quest[2] or s.quest[1]] == 1 then count(s.quest) end
    end
  else
    for _, q in ipairs(step.quests or {}) do count(q) end
  end
  return inLog, done, total
end

-- Levels alone never close a step you are still working on: Forever's extra XP (dungeons,
-- rested, camping) often takes you past a zone's last level with its quests still open.
-- Its quests in your log keep it open until you are HOLD_LOG levels past the step, and a step
-- you've started (with quests still to do) until HOLD_STARTED levels past it. A step you never
-- started, or whose quests are all done, closes on time. The limits stay small because grey,
-- elite and abandoned quests often sit in the log for a long time.
local HOLD_LOG, HOLD_STARTED = 4, 2
local function StillWorking(step, level)
  local top = step.reach or step.max
  if not top then return false end
  local inLog, done, total = StepQuestCounts(step)
  if inLog > 0 and level <= top + HOLD_LOG then return true end
  return done > 0 and done < total and level <= top + HOLD_STARTED
end

-- Returns nil (not done) or one of "done", "skipped", "outleveled", "behind".
-- "behind" is a class quest or mount step left 8+ levels behind: it stops holding up the
-- route (someone who installs the guide at 50 shouldn't be parked on a level-10 quest)
-- but stays on the list as a reminder, since those rewards matter at any level.
function ns.StepState(step)
  local key = ns.MemoKey()
  if stateKey ~= key then wipe(stateMemo); stateKey = key end
  local m = stateMemo[step]
  if m == nil then m = ComputeState(step) or false; stateMemo[step] = m end
  return m or nil
end

ComputeState = function(step)
  local c = ns.char
  if c.done[step.id] then return "done" end
  if c.skip[step.id] then return "skipped" end
  local level = ns.player.level or 1
  if step.quests and #step.quests > 0 then
    if step.any then
      for _, q in ipairs(step.quests) do if ns.IsQuestDone(q) then return "done" end end
    else
      local all = true
      for _, q in ipairs(step.quests) do if not ns.IsQuestDone(q) then all = false; break end end
      if all then return "done" end
    end
  end
  local working -- worked out only when a level rule would close the step
  local function Working()
    if working == nil then working = StillWorking(step, level) end
    return working
  end
  if step.reach and level >= step.reach and not Working() then return "done" end
  if ns.ZoneStats then
    local zd, zt = ns.ZoneStats(step)
    if zd and zt >= 5 and zd / zt >= 0.9 then return "done" end
  end
  if ns.PlanProgress then
    local plan, first = ns.PlanProgress(step)
    if plan and #plan > 0 and not first then return "done" end
  end
  local keep = step.kind == "class" or step.kind == "mount"
  if ns.db.autoSkip and step.max and level > step.max + 3 and not keep and not Working() then
    return "outleveled"
  end
  if ns.db.autoSkip and step.max and keep and level > step.max + 8 then return "behind" end
  -- Put off by a jump ahead: still open, but not holding up the route.
  if keep and c.defer and c.defer[step.id] then return "behind" end
  return nil
end

function ns.CurrentIndex()
  for i, step in ipairs(ns.route) do
    if not step.optional and not ns.StepState(step) then return i end
  end
  return #ns.route
end

function ns.Progress()
  local total, done = 0, 0
  for _, step in ipairs(ns.route) do
    if not step.optional then
      total = total + 1
      local st = ns.StepState(step)
      if st and st ~= "behind" then done = done + 1 end
    end
  end
  return done, total
end

function ns.ViewIndex()
  local v = ns.char.view
  if v and ns.route[v] then return v end
  return ns.CurrentIndex()
end

function ns.SetView(i)
  if i then i = math.max(1, math.min(#ns.route, i)) end
  ns.char.view = i
  ns.Fire("Refresh")
end

function ns.ToggleDone(step)
  local c = ns.char
  if c.done[step.id] or c.skip[step.id] then
    c.done[step.id], c.skip[step.id] = nil, nil
  else
    c.done[step.id] = true
  end
  if c.defer then c.defer[step.id] = nil end
  c.view = nil
  ns.Invalidate()
  ns.Fire("Refresh")
end

function ns.Skip(step)
  ns.char.skip[step.id] = true
  if ns.char.defer then ns.char.defer[step.id] = nil end
  ns.char.view = nil
  ns.Invalidate()
  ns.Fire("Refresh")
end

-- Class quests and mount steps the character has left behind (see StepState).
function ns.StillOpen()
  local out = {}
  for i, step in ipairs(ns.route) do
    if ns.StepState(step) == "behind" then out[#out + 1] = i end
  end
  return out
end

-- Tips for the current level band (gold / extras / professions).
function ns.TipsForLevel(level)
  local out = {}
  for _, t in ipairs(ns.tips) do
    if (t.min or 1) <= level and level <= (t.max or 60) and not ns.char.done[t.id] then out[#out + 1] = t end
  end
  return out
end

local function ScanQuestLog()
  ns.Invalidate()
  wipe(ns.activeQuests); wipe(ns.logIDs)
  local num = (GetNumQuestLogEntries and GetNumQuestLogEntries())
           or (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries()) or 0
  for i = 1, num do
    local title, isHeader, id
    if GetQuestLogTitle then
      local t, _, _, h, _, _, _, qid = GetQuestLogTitle(i)
      title, isHeader, id = t, h, qid
    elseif C_QuestLog and C_QuestLog.GetInfo then
      local info = C_QuestLog.GetInfo(i)
      if info then title, isHeader, id = info.title, info.isHeader, info.questID end
    end
    if title and not isHeader then
      ns.activeQuests[title] = true
      if id then ns.logIDs[id] = title end
    end
  end
  ns.Fire("QuestLogChanged")
end

local function TitleForQuest(id)
  if ns.logIDs[id] then return ns.logIDs[id] end
  if C_QuestLog and C_QuestLog.GetTitleForQuestID then
    local t = C_QuestLog.GetTitleForQuestID(id)
    if t and t ~= "" then return t end
  end
  if C_QuestLog and C_QuestLog.GetQuestInfo then
    local t = C_QuestLog.GetQuestInfo(id)
    if t and t ~= "" then return t end
  end
end

---------------------------------------------------------------------------
-- Talents
---------------------------------------------------------------------------
local CSI = C_SpecializationInfo

local function TalentGroup()
  if CSI and CSI.GetActiveSpecGroup then
    local ok, g = pcall(CSI.GetActiveSpecGroup); if ok and g then return g end
  end
  if GetActiveTalentGroup then
    local ok, g = pcall(GetActiveTalentGroup); if ok and g then return g end
  end
  return 1
end

-- Tree name, icon and points spent. Older clients have GetTalentTabInfo; WoW Forever only has
-- C_SpecializationInfo.GetSpecializationInfo (id, name, description, icon, role, primaryStat, pointsSpent, ...).
local function TabInfo(t, group)
  if GetTalentTabInfo then
    local ok, a, b, c, d, e = pcall(GetTalentTabInfo, t)
    if ok and type(a) == "number" then return b, d, e end -- id, name, description, icon, pointsSpent
    if ok and a then return a, b, c end                    -- name, icon, pointsSpent
  end
  if CSI and CSI.GetSpecializationInfo then
    local ok, _, name, _, icon, _, _, points = pcall(CSI.GetSpecializationInfo, t, false, false, nil, nil, group)
    if not (ok and name) then ok, _, name, _, icon, _, _, points = pcall(CSI.GetSpecializationInfo, t) end
    if ok and name then return name, icon, type(points) == "number" and points or nil end
  end
end

local function NumTabs()
  if GetNumTalentTabs then local ok, n = pcall(GetNumTalentTabs); if ok and n and n > 0 then return n end end
  if GetNumSpecializations then local ok, n = pcall(GetNumSpecializations); if ok and n and n > 0 then return n end end
  return 3
end

local function Add(T, source, t, index, name, icon, tier, column, rank, maxRank)
  if type(name) ~= "string" or name == "" or T.byName[name] then return end
  T.byName[name] = { tab = t, index = index, icon = icon, rank = rank or 0, maxRank = maxRank or 1,
                     tier = tier, column = column, tabName = T.tabs[t] and T.tabs[t].name }
  ns.talentSource = source
end

-- 1. By talent index: the global GetTalentInfo(tab, i), or C_SpecializationInfo with talentIndex.
local indexQueryFails = false
local function ScanByIndex(T, numTabs, group)
  for t = 1, numTabs do
    local count = GetNumTalents and select(2, pcall(GetNumTalents, t)) or 0
    if type(count) ~= "number" or count == 0 then count = 40 end
    for i = 1, count do
      if GetTalentInfo then
        local ok, a, b, c, d, e, f, g = pcall(GetTalentInfo, t, i)
        if ok and type(a) == "string" then Add(T, "GetTalentInfo", t, i, a, b, c, d, e, f)
        elseif ok and type(a) == "number" and type(b) == "string" then Add(T, "GetTalentInfo(id)", t, i, b, c, d, e, f, g) end
      elseif CSI and CSI.GetTalentInfo and not indexQueryFails then
        local ok, x = pcall(CSI.GetTalentInfo, { specializationIndex = t, talentIndex = i, isInspect = false, isPet = false, groupIndex = group })
        if not ok then indexQueryFails = true
        elseif type(x) == "table" then Add(T, "C_SpecializationInfo(index)", t, i, x.name, x.icon, x.tier, x.column, x.rank, x.maxRank) end
      end
    end
  end
end

-- 2. By tier and column: C_SpecializationInfo.GetTalentInfo{ tier, column, ... } (WoW Forever asks for a tier).
local function ScanByTier(T, numTabs, group)
  if not (CSI and CSI.GetTalentInfo) then return end
  for t = 1, numTabs do
    local index = 0
    for tier = 1, 11 do
      for column = 1, 4 do
        local ok, x = pcall(CSI.GetTalentInfo, { specializationIndex = t, tier = tier, column = column,
                                                  groupIndex = group, isInspect = false, isPet = false })
        if ok and type(x) == "table" and x.name then
          index = index + 1
          Add(T, "C_SpecializationInfo(tier)", t, x.talentIndex or x.index or index, x.name, x.icon or x.iconTexture,
              x.tier or tier, x.column or column, x.rank or x.currentRank, x.maxRank or x.maxRanks)
        end
      end
    end
  end
end

-- 3. Modern trait trees: C_ClassTalents / C_Traits.
local function ScanByTraits(T)
  if not (C_ClassTalents and C_Traits and C_ClassTalents.GetActiveConfigID) then return end
  local ok, config = pcall(C_ClassTalents.GetActiveConfigID)
  if not ok or not config then return end
  local okc, info = pcall(C_Traits.GetConfigInfo, config)
  if not okc or type(info) ~= "table" or not info.treeIDs then return end
  local index = 0
  for _, tree in ipairs(info.treeIDs) do
    local okn, nodes = pcall(C_Traits.GetTreeNodes, tree)
    for _, node in ipairs(okn and nodes or {}) do
      local okI, n = pcall(C_Traits.GetNodeInfo, config, node)
      if okI and type(n) == "table" and (n.isVisible ~= false) then
        local entry = (n.activeEntry and n.activeEntry.entryID) or (n.entryIDs and n.entryIDs[1])
        local okE, e = pcall(C_Traits.GetEntryInfo, config, entry)
        local okD, d = pcall(C_Traits.GetDefinitionInfo, okE and e and e.definitionID)
        if okD and type(d) == "table" then
          local name = d.overrideName
          if (not name or name == "") and d.spellID then
            name = (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(d.spellID)) or (GetSpellInfo and GetSpellInfo(d.spellID))
          end
          local icon = d.overrideIcon or (d.spellID and C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(d.spellID))
          index = index + 1
          Add(T, "C_Traits", 1, index, name, icon, nil, nil, n.currentRank or n.activeRank, n.maxRanks)
        end
      end
    end
  end
end

ns.talentSource = nil

function ns.ScanTalents()
  local T = ns.talents
  wipe(T.byName); wipe(T.tabs); T.total = 0
  ns.talentSource = nil
  local numTabs, group = NumTabs(), TalentGroup()
  local pointsKnown = false
  for t = 1, numTabs do
    local ok, name, icon, points = pcall(TabInfo, t, group)
    if not ok then name, icon, points = nil, nil, nil end
    if points then pointsKnown = true end
    T.tabs[t] = { name = name, icon = icon, points = points or 0 }
    T.total = T.total + (points or 0)
  end
  ScanByIndex(T, numTabs, group)
  if not next(T.byName) then ScanByTier(T, numTabs, group) end
  if not next(T.byName) then ScanByTraits(T) end
  -- No per-tree totals from the client: add up the ranks instead.
  if not pointsKnown then
    T.total = 0
    for _, info in pairs(T.byName) do
      T.total = T.total + (info.rank or 0)
      local tab = T.tabs[info.tab]
      if tab then tab.points = tab.points + (info.rank or 0) end
    end
  end
  T.scannedAt = GetTime and GetTime() or 0
  if ns.char then ns.char.talentDiag = ns.TalentDiag(numTabs, group) end
end

-- Short record of what the client returned, kept in saved variables for troubleshooting.
local function Keys(tbl)
  if type(tbl) ~= "table" then return tostring(tbl) end
  local k = {}; for name in pairs(tbl) do k[#k + 1] = tostring(name) end
  table.sort(k); return table.concat(k, ",")
end
local function Dump(x)
  if type(x) ~= "table" then return tostring(x) end
  local k = {}; for a, b in pairs(x) do k[#k + 1] = tostring(a) .. "=" .. tostring(b) end
  table.sort(k); return table.concat(k, ", ")
end
function ns.TalentDiag(numTabs, group)
  local T = ns.talents
  local n = 0; for _ in pairs(T.byName) do n = n + 1 end
  local tabs = {}
  for t, tab in ipairs(T.tabs) do tabs[t] = tostring(tab.name) .. ":" .. tostring(tab.points) end
  local d = { level = ns.player and ns.player.level, found = n, spent = T.total, source = ns.talentSource,
              numTabs = numTabs, group = group, tabs = table.concat(tabs, " | "),
              CSI = CSI and Keys(CSI), C_ClassTalents = C_ClassTalents and Keys(C_ClassTalents) or nil,
              C_Traits = C_Traits and Keys(C_Traits) or nil }
  if n == 0 and CSI and CSI.GetTalentInfo then
    local ok, x = pcall(CSI.GetTalentInfo, { specializationIndex = 1, tier = 1, column = 1, groupIndex = group, isInspect = false, isPet = false })
    d.tierSample = ok and Dump(x) or ("error: " .. tostring(x))
    ok, x = pcall(CSI.GetTalentInfo, { tier = 1, column = 1, groupIndex = group, isInspect = false })
    d.tierSampleNoSpec = ok and Dump(x) or ("error: " .. tostring(x))
  end
  if CSI and CSI.GetSpecializationInfo then
    local ok, a, b, c, e, f, g, h = pcall(CSI.GetSpecializationInfo, 1)
    d.specInfo1 = ok and table.concat({ tostring(a), tostring(b), tostring(e), tostring(f), tostring(g), tostring(h) }, ", ") or ("error: " .. tostring(a))
  end
  if C_ClassTalents and C_ClassTalents.GetActiveConfigID then
    local ok, c = pcall(C_ClassTalents.GetActiveConfigID); d.traitConfig = ok and tostring(c) or "error"
  end
  return d
end

-- Rescan when the talent list is empty (talent data can arrive after login). Throttled.
function ns.EnsureTalents()
  if next(ns.talents.byName) then return end
  local now = GetTime and GetTime() or 0
  if ns.talents.scannedAt and now - ns.talents.scannedAt < 1 then return end
  ns.ScanTalents()
end

-- /cguide talentdebug: what the client's talent API returns, for bug reports.
function ns.TalentDebug()
  ns.ScanTalents()
  local n = 0; for _ in pairs(ns.talents.byName) do n = n + 1 end
  ns.Print(("talents found: %d, points spent: %d, source: %s"):format(n, ns.talents.total, tostring(ns.talentSource)))
  ns.Print(("API: GetTalentInfo=%s, C_SpecializationInfo.GetTalentInfo=%s, GetNumTalents=%s, GetNumTalentTabs=%s"):format(
    tostring(GetTalentInfo ~= nil), tostring(C_SpecializationInfo ~= nil and C_SpecializationInfo.GetTalentInfo ~= nil),
    tostring(GetNumTalents ~= nil), tostring(GetNumTalentTabs ~= nil)))
  for t, tab in ipairs(ns.talents.tabs) do ns.Print(("tab %d: %s (%d points)"):format(t, tostring(tab.name), tab.points)) end
  if GetTalentInfo then
    local ok, a, b, c, d, e, f = pcall(GetTalentInfo, 1, 1)
    ns.Print("GetTalentInfo(1,1) -> " .. (ok and table.concat({ tostring(a), tostring(b), tostring(c), tostring(d), tostring(e), tostring(f) }, ", ") or ("error: " .. tostring(a))))
  end
  local build = ns.GetActiveBuild()
  if build and build.talents then
    local missing = {}
    for _, p in pairs(build.talents) do if not ns.talents.byName[p[1]] then missing[p[1]] = true end end
    local list = {}; for k in pairs(missing) do list[#list + 1] = k end
    table.sort(list)
    ns.Print(("build %s: %d talent names not in your tree%s"):format(build.name or build.key or "?", #list,
      #list > 0 and (": " .. table.concat(list, ", ", 1, math.min(#list, 8))) or ""))
  end
end

function ns.TabIndexByName(name)
  for t, info in ipairs(ns.talents.tabs) do if info.name == name then return t end end
end

function ns.GetBuilds() return ns.BUILDS[ns.player.class] or {} end

function ns.GetActiveBuild()
  local builds = ns.GetBuilds()
  if #builds == 0 then return nil, false end
  if ns.char.build then
    for _, b in ipairs(builds) do if b.key == ns.char.build then return b, false end end
  end
  -- Auto-detect: score each build by how many of the player's spent points it plans for.
  local fallback
  for _, b in ipairs(builds) do if b.default then fallback = b; break end end
  fallback = fallback or builds[1]
  if ns.talents.total == 0 then return fallback, true end
  local level = math.min(ns.player.level or 1, 60)
  local best, bestScore = fallback, -1
  for _, b in ipairs(builds) do
    local planned = {}
    for L = 10, level do
      local p = b.talents and b.talents[L]
      if p then planned[p[1]] = math.max(planned[p[1]] or 0, p[2]) end
    end
    local score = 0
    for name, info in pairs(ns.talents.byName) do
      if info.rank > 0 then score = score + math.min(info.rank, planned[name] or 0) end
    end
    if score > bestScore or (score == bestScore and b == fallback) then best, bestScore = b, score end
  end
  return best, true
end

-- The spec the player is effectively playing (tab name) for spec guides / gear.
function ns.ActiveSpec()
  if ns.char.spec then return ns.char.spec end
  local bestTab, bestPts = nil, 0
  for _, tab in ipairs(ns.talents.tabs) do
    if tab.points > bestPts then bestTab, bestPts = tab.name, tab.points end
  end
  if bestTab then return bestTab end
  local b = ns.GetActiveBuild()
  return b and b.tree
end

-- Find the key in `tbl` that matches a talent tab name, tolerating Forever renames
-- ("Shadow Magic" vs "Shadow", "Elemental Combat" vs "Elemental", "Feral Combat" vs "Feral").
function ns.MatchSpec(tbl, spec)
  if not tbl or not spec then return nil end
  if tbl[spec] then return spec end
  local s = spec:lower()
  for key in pairs(tbl) do
    local k = key:lower()
    if s:find(k, 1, true) == 1 or k:find(s, 1, true) == 1 then return key end
  end
  local first = s:match("^(%S+)")
  for key in pairs(tbl) do
    if key:lower():match("^(%S+)") == first then return key end
  end
end

function ns.UnspentTalentPoints()
  if UnitCharacterPoints then return UnitCharacterPoints("player") or 0 end
  if GetUnspentTalentPoints then return GetUnspentTalentPoints() or 0 end
  return 0
end

-- First planned talent the player hasn't taken yet (catch-up), else the next level's pick.
function ns.PendingTalent()
  local build = ns.GetActiveBuild()
  if not build or not build.talents then return nil end
  local level = math.min(ns.player.level or 1, 60)
  -- Builds that respec mid-way only check picks made after the respec.
  local start = (build.respecAt and level >= build.respecAt) and build.respecAt or 10
  for L = start, level do
    local plan = build.talents[L]
    if plan then
      local info = ns.talents.byName[plan[1]]
      if info and info.rank < plan[2] then return L, plan, info, true end
    end
  end
  local nextL = math.max(10, level + 1)
  local plan = build.talents[nextL]
  if plan then return nextL, plan, ns.talents.byName[plan[1]], false end
end

function ns.TalentText(plan)
  if not plan then return "" end
  return ("%s %d/%s"):format(plan[1], plan[2], (ns.talents.byName[plan[1]] or {}).maxRank or "?")
end

---------------------------------------------------------------------------
-- Professions
---------------------------------------------------------------------------
function ns.ScanProfessions()
  wipe(ns.profs)
  if GetNumSkillLines and GetSkillLineInfo then
    for i = 1, GetNumSkillLines() do
      local name, isHeader, _, rank, _, _, maxRank = GetSkillLineInfo(i)
      if name and not isHeader and (ns.PROFESSIONS[name] or ns.PROF_ICONS[name]) then
        ns.profs[#ns.profs + 1] = { name = name, rank = rank or 0, maxRank = maxRank or 0 }
      end
    end
  elseif GetProfessions then
    for _, idx in ipairs({ GetProfessions() }) do
      if idx then
        local name, _, rank, maxRank = GetProfessionInfo(idx)
        if name then ns.profs[#ns.profs + 1] = { name = name, rank = rank or 0, maxRank = maxRank or 0 } end
      end
    end
  end
  table.sort(ns.profs, function(a, b) return a.name < b.name end)
end

function ns.ProfStep(name, rank)
  local guide = ns.PROFESSIONS[name]
  if not guide or not guide.steps then return nil end
  for i, s in ipairs(guide.steps) do
    if rank >= (s.from or 1) and rank < (s.to or 300) then return s, i end
  end
  return guide.steps[#guide.steps], #guide.steps
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local events = CreateFrame("Frame")
for _, e in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_LEVEL_UP", "QUEST_TURNED_IN", "QUEST_LOG_UPDATE",
                     "QUEST_ACCEPTED", "CHARACTER_POINTS_CHANGED", "SKILL_LINES_CHANGED", "PLAYER_ENTERING_WORLD" }) do
  events:RegisterEvent(e)
end
pcall(events.RegisterEvent, events, "PLAYER_TALENT_UPDATE")
pcall(events.RegisterEvent, events, "SPELLS_CHANGED")

local refreshPending = false
local function QueueRefresh()
  if refreshPending then return end
  refreshPending = true
  C_Timer.After(0.2, function() refreshPending = false; ns.Fire("Refresh") end)
end
ns.QueueRefresh = QueueRefresh

events:SetScript("OnEvent", function(_, event, ...)
  if event == "ADDON_LOADED" then
    local name = ...
    if name == ADDON then
      CoffeyGuideDB = CoffeyGuideDB or {}
      for k, v in pairs(DEFAULTS) do if CoffeyGuideDB[k] == nil then CoffeyGuideDB[k] = v end end
      CoffeyGuideCharDB = CoffeyGuideCharDB or {}
      local c = CoffeyGuideCharDB
      c.done, c.skip, c.questNames, c.plan = c.done or {}, c.skip or {}, c.questNames or {}, c.plan or {}
      if CoffeyGuideDB.useQuestie == nil then CoffeyGuideDB.useQuestie = true end
      -- 3.1.0: "minimized" became the compact tracker.
      if CoffeyGuideDB.minimized ~= nil then
        CoffeyGuideDB.compact = CoffeyGuideDB.minimized and true or false
        CoffeyGuideDB.minimized = nil
      end
      ns.db, ns.char = CoffeyGuideDB, CoffeyGuideCharDB
    end
    ns.Fire("AddonLoaded", name)

  elseif event == "PLAYER_LOGIN" then
    DetectPlayer()
    ns.BuildRoute()
    ScanQuestLog()
    ns.ScanTalents()
    ns.ScanProfessions()
    ns.Fire("Login")
    ns.Fire("Refresh")
    -- Say hello once per character; after that only when quiet mode is off.
    if not ns.char.greeted or not ns.db.quiet then
      Print(("%s %s %s detected - %d route steps. /cguide to toggle, /cguide guide for the full guide.")
        :format(ns.player.raceName or "?", ns.player.className or "?", ns.player.faction or "", #ns.route))
      ns.char.greeted = true
    end

  elseif event == "PLAYER_ENTERING_WORLD" then
    ns.ScanTalents()
    QueueRefresh()
    -- Talent data can arrive a little after login; retry while the list is still empty.
    for _, delay in ipairs({ 2, 6, 15 }) do
      C_Timer.After(delay, function()
        if not next(ns.talents.byName) then ns.ScanTalents(); QueueRefresh() end
      end)
    end

  elseif event == "SPELLS_CHANGED" then
    if not next(ns.talents.byName) then ns.ScanTalents(); QueueRefresh() end

  elseif event == "PLAYER_LEVEL_UP" then
    local level = ...
    local before = ns.CurrentIndex()
    ns.player.level = level
    ns.Invalidate()
    ns.ScanTalents()
    ns.char.view = nil
    ns.Fire("LevelUp", level, before)
    ns.Fire("Refresh")

  elseif event == "QUEST_LOG_UPDATE" or event == "QUEST_ACCEPTED" then
    ScanQuestLog()
    QueueRefresh()

  elseif event == "QUEST_TURNED_IN" then
    local id = ...
    local title = TitleForQuest(id)
    local before = ns.CurrentIndex()
    if title then ns.char.questNames[title] = true end
    ns.Invalidate()
    ns.Fire("QuestTurnedIn", id, title)
    C_Timer.After(0.5, function()
      ScanQuestLog()
      local after = ns.CurrentIndex()
      if after ~= before then ns.Fire("StepAdvanced", ns.route[before], ns.route[after]) end
      ns.char.view = nil
      ns.Fire("Refresh")
    end)

  elseif event == "CHARACTER_POINTS_CHANGED" or event == "PLAYER_TALENT_UPDATE" then
    ns.ScanTalents()
    QueueRefresh()

  elseif event == "SKILL_LINES_CHANGED" then
    ns.ScanProfessions()
    QueueRefresh()
  end
end)

-- Clear this character's guide progress. Quest history comes from the game, so steps
-- you have really finished tick themselves off again; manual marks and skips are gone.
function ns.ResetProgress()
  local c = ns.char
  wipe(c.done); wipe(c.skip); wipe(c.questNames); wipe(c.plan)
  c.view, c.lastJump, c.defer = nil, nil, nil
  ns.Invalidate()
  Print("progress reset."); ns.Fire("Refresh")
end

-- Check off the current quest-plan objective (key binding and /cguide check).
function ns.CheckCurrent()
  local step = ns.route[ns.ViewIndex()]
  if not step then return end
  local plan, first = ns.PlanProgress(step)
  if plan and first then ns.MarkSub(step, plan[first], true)
  elseif not ns.StepState(step) then ns.ToggleDone(step) end
end

function CoffeyGuide_Binding(action)
  if not ns.char then return end
  if action == "toggle" then ns.Fire("ToggleTracker")
  elseif action == "guide" then ns.Fire("OpenGuide")
  elseif action == "check" then ns.CheckCurrent()
  elseif action == "next" then ns.SetView(ns.ViewIndex() + 1)
  elseif action == "prev" then ns.SetView(ns.ViewIndex() - 1)
  elseif action == "waypoint" then ns.Fire("WaypointCurrent")
  elseif action == "compact" then ns.Fire("ToggleCompact") end
end

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
SLASH_COFFEYGUIDE1, SLASH_COFFEYGUIDE2 = "/cguide", "/coffeyguide"
SlashCmdList.COFFEYGUIDE = function(msg)
  msg = ns.Trim((msg or ""):lower())
  local tabs = { guide = "route", route = "route", quests = "questlog", log = "questlog", talents = "talents", talent = "talents", spec = "spec",
                 gear = "gear", bis = "gear", prof = "professions", profs = "professions", professions = "professions",
                 gold = "extras", extras = "extras", dungeons = "dungeons", settings = "settings", options = "settings" }
  if msg == "" then
    ns.Fire("ToggleTracker")
  elseif tabs[msg] then
    ns.Fire("OpenGuide", tabs[msg])
  elseif msg == "next" then ns.SetView(ns.ViewIndex() + 1)
  elseif msg == "prev" then ns.SetView(ns.ViewIndex() - 1)
  elseif msg == "sync" then ns.SyncHistory(true)
  elseif msg == "wp" or msg == "way" then ns.Fire("SetWaypoints", ns.route[ns.ViewIndex()], true)
  elseif msg == "reset" then
    ns.ResetProgress()
  elseif msg == "resetpos" then
    ns.char.pos = nil; ns.Fire("ResetPosition")
  elseif msg == "talentdebug" then ns.TalentDebug()
  elseif msg == "welcome" then ns.Fire("ShowWelcome", true)
  elseif msg == "compact" then ns.Fire("ToggleCompact")
  elseif msg == "check" then ns.CheckCurrent()
  elseif msg == "support" or msg == "donate" then
    Print("Coffey's Leveling Guide is free. To support Coffey Labs: " .. ns.SUPPORT); ns.ShowLink(ns.SUPPORT)
  else
    Print("/cguide - show/hide tracker   /cguide guide | talents | spec | gear | prof | quests | gold | dungeons | settings")
    Print("/cguide next | prev | check | compact   /cguide wp - waypoints for this step   /cguide sync   /cguide welcome")
    Print("/cguide reset   /cguide resetpos   /cguide talentdebug   /cguide support")
  end
end
