-- ForeverGuide core: player detection, route building, progress, talents, professions, events.
local ADDON, ns = ...
local Print = ns.Print

local DEFAULTS = {
  arrow = true, pins = true, autoWaypoint = true, toasts = true, lock = false, scale = 1.0,
  autoSkip = true, useTomTom = true, showOptional = true, talentGlow = true, minimized = false,
  gearAdvisor = true, rewardHints = true,
  autoAccept = false, autoTurnIn = false, sellGreys = false, autoRepair = false,
  minimap = { hide = false },
}

ns.player = {}
ns.route, ns.tips = {}, {}
ns.activeQuests = {}   -- quest title -> true (in quest log)
ns.logIDs = {}         -- questID -> title (in quest log)
ns.talents = { byName = {}, tabs = {}, total = 0 }
ns.profs = {}

local listeners = {}
function ns.On(name, fn) listeners[name] = listeners[name] or {}; table.insert(listeners[name], fn) end
function ns.Fire(name, ...)
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

function ns.IsQuestDone(q)
  local name, id = QuestNameID(q)
  -- Fill in IDs learned from the quest log for quests the data only knows by name.
  id = id or (name and ns.char.questIDs and ns.char.questIDs[name])
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
  return (id and ns.logIDs[id]) or (name and ns.activeQuests[name]) or false
end

-- Returns nil (not done) or one of "done", "skipped", "outleveled".
function ns.StepState(step)
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
  if step.reach and level >= step.reach then return "done" end
  if ns.ZoneStats then
    local zd, zt = ns.ZoneStats(step)
    if zd and zt >= 5 and zd / zt >= 0.9 then return "done" end
  end
  if ns.PlanProgress then
    local plan, first = ns.PlanProgress(step)
    if plan and #plan > 0 and not first then return "done" end
  end
  if ns.db.autoSkip and step.max and level > step.max + 3 and step.kind ~= "class" and step.kind ~= "mount" then
    return "outleveled"
  end
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
      if ns.StepState(step) then done = done + 1 end
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
  if ns.char.done[step.id] or ns.char.skip[step.id] then
    ns.char.done[step.id], ns.char.skip[step.id] = nil, nil
  else
    ns.char.done[step.id] = true
  end
  ns.char.view = nil
  ns.Fire("Refresh")
end

function ns.Skip(step)
  ns.char.skip[step.id] = true
  ns.char.view = nil
  ns.Fire("Refresh")
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
local function TabInfo(t)
  local a, b, c, d, e = GetTalentTabInfo(t)
  if type(a) == "number" then return b, d, e end -- id, name, description, icon, pointsSpent
  return a, b, c                                 -- name, icon, pointsSpent
end

local function TalentGroup()
  if C_SpecializationInfo and C_SpecializationInfo.GetActiveSpecGroup then
    local ok, g = pcall(C_SpecializationInfo.GetActiveSpecGroup); if ok and g then return g end
  end
  if GetActiveTalentGroup then
    local ok, g = pcall(GetActiveTalentGroup); if ok and g then return g end
  end
  return 1
end

-- One talent: name, icon, tier, column, rank, maxRank. Newer clients (WoW Forever included) use
-- C_SpecializationInfo.GetTalentInfo(query), which returns a table; older ones use the global
-- GetTalentInfo(tab, index), which some builds return with a talent ID in front.
local function TalentInfo(t, i, group)
  if C_SpecializationInfo and C_SpecializationInfo.GetTalentInfo then
    local ok, x = pcall(C_SpecializationInfo.GetTalentInfo,
      { specializationIndex = t, talentIndex = i, isInspect = false, isPet = false, groupIndex = group })
    if ok and type(x) == "table" and x.name then
      return x.name, x.icon, x.tier, x.column, x.rank, x.maxRank, "C_SpecializationInfo"
    end
  end
  if GetTalentInfo then
    local ok, a, b, c, d, e, f, g = pcall(GetTalentInfo, t, i)
    if ok and type(a) == "string" then return a, b, c, d, e, f, "GetTalentInfo" end
    if ok and type(a) == "number" and type(b) == "string" then return b, c, d, e, f, g, "GetTalentInfo(id)" end
  end
end

local MAX_TALENTS = 40
ns.talentSource = nil

function ns.ScanTalents()
  local T = ns.talents
  wipe(T.byName); wipe(T.tabs); T.total = 0
  local numTabs = GetNumTalentTabs and GetNumTalentTabs() or 3
  local group = TalentGroup()
  for t = 1, numTabs do
    local ok, name, icon, points = pcall(TabInfo, t)
    if not ok then name, icon, points = nil, nil, 0 end
    T.tabs[t] = { name = name, icon = icon, points = points or 0 }
    T.total = T.total + (points or 0)
    local count = GetNumTalents and GetNumTalents(t) or MAX_TALENTS
    if not count or count == 0 then count = MAX_TALENTS end
    for i = 1, count do
      local tname, ticon, tier, column, rank, maxRank, source = TalentInfo(t, i, group)
      if tname then
        ns.talentSource = source
        T.byName[tname] = { tab = t, index = i, icon = ticon, rank = rank or 0, maxRank = maxRank or 1,
                            tier = tier, column = column, tabName = name }
      end
    end
  end
  T.scannedAt = GetTime and GetTime() or 0
  -- Short record of what the client returned, kept in saved variables for troubleshooting.
  if ns.char then
    local n = 0; for _ in pairs(T.byName) do n = n + 1 end
    local tabs = {}
    for t, tab in ipairs(T.tabs) do tabs[t] = tostring(tab.name) .. ":" .. tostring(tab.points) end
    local sample
    if GetTalentInfo then
      local ok, a, b, c, d, e, f = pcall(GetTalentInfo, 1, 1)
      sample = ok and table.concat({ tostring(a), tostring(b), tostring(c), tostring(d), tostring(e), tostring(f) }, ", ") or ("error: " .. tostring(a))
    end
    local newSample
    if C_SpecializationInfo and C_SpecializationInfo.GetTalentInfo then
      local ok, x = pcall(C_SpecializationInfo.GetTalentInfo,
        { specializationIndex = 1, talentIndex = 1, isInspect = false, isPet = false, groupIndex = group })
      if not ok then newSample = "error: " .. tostring(x)
      elseif type(x) ~= "table" then newSample = tostring(x)
      else
        local keys = {}
        for k, v in pairs(x) do keys[#keys + 1] = tostring(k) .. "=" .. tostring(v) end
        table.sort(keys); newSample = table.concat(keys, ", ")
      end
    end
    ns.char.talentDiag = {
      level = ns.player and ns.player.level, found = n, spent = T.total, source = ns.talentSource,
      numTabs = numTabs, group = group, tabs = table.concat(tabs, " | "),
      hasGlobal = GetTalentInfo ~= nil, hasNew = C_SpecializationInfo ~= nil and C_SpecializationInfo.GetTalentInfo ~= nil,
      hasNumTalents = GetNumTalents ~= nil, numTalents1 = GetNumTalents and select(2, pcall(GetNumTalents, 1)) or nil,
      globalSample = sample, newSample = newSample,
    }
  end
end

-- Rescan when the talent list is empty (talent data can arrive after login). Throttled.
function ns.EnsureTalents()
  if next(ns.talents.byName) then return end
  local now = GetTime and GetTime() or 0
  if ns.talents.scannedAt and now - ns.talents.scannedAt < 1 then return end
  ns.ScanTalents()
end

-- /fg talentdebug: what the client's talent API returns, for bug reports.
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
      ForeverGuideDB = ForeverGuideDB or {}
      for k, v in pairs(DEFAULTS) do if ForeverGuideDB[k] == nil then ForeverGuideDB[k] = v end end
      ForeverGuideCharDB = ForeverGuideCharDB or {}
      local c = ForeverGuideCharDB
      c.done, c.skip, c.questNames, c.plan = c.done or {}, c.skip or {}, c.questNames or {}, c.plan or {}
      if ForeverGuideDB.useQuestie == nil then ForeverGuideDB.useQuestie = true end
      ns.db, ns.char = ForeverGuideDB, ForeverGuideCharDB
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
    Print(("%s %s %s detected - %d route steps. /fg to toggle, /fg guide for the full guide.")
      :format(ns.player.raceName or "?", ns.player.className or "?", ns.player.faction or "", #ns.route))

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

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
SLASH_FOREVERGUIDE1, SLASH_FOREVERGUIDE2 = "/fg", "/foreverguide"
SlashCmdList.FOREVERGUIDE = function(msg)
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
    wipe(ns.char.done); wipe(ns.char.skip); wipe(ns.char.questNames); ns.char.view = nil
    Print("progress reset."); ns.Fire("Refresh")
  elseif msg == "resetpos" then
    ns.char.pos = nil; ns.Fire("ResetPosition")
  elseif msg == "talentdebug" then ns.TalentDebug()
  elseif msg == "support" or msg == "donate" then
    Print("ForeverGuide is free. To support Coffey Labs: " .. ns.SUPPORT); ns.ShowLink(ns.SUPPORT)
  else
    Print("/fg - show/hide tracker   /fg guide | talents | spec | gear | prof | gold | dungeons | settings")
    Print("/fg next | prev   /fg wp - waypoints for this step   /fg reset   /fg resetpos   /fg support")
  end
end
