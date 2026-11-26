-- Loads Coffey's Leveling Guide against a mock WoW API and drives it through its main flows.
-- usage: lua5.1 harness.lua <addonDir> <dataDir> <race> <raceFile> <class> <faction> <level>
local dir, dataDir = arg[1], arg[2]
local P = { race = arg[3] or "Undead", raceFile = arg[4] or "Scourge", class = arg[5] or "PALADIN",
            faction = arg[6] or "Horde", level = tonumber(arg[7] or "12") }

---------------------------------------------------------------- mock objects
local function mock(name)
  local o = { _name = name, _shown = true, _text = "", _w = 300 }
  local creators = { CreateTexture = 1, CreateFontString = 1, CreateAnimationGroup = 1, CreateAnimation = 1,
                     GetFontString = 1, GetParent = 1 }
  return setmetatable(o, { __index = function(t, k)
    if creators[k] then return function() return mock(k) end end
    if k == "GetStringHeight" then return function() return 12 end end
    if k == "GetStringWidth" then return function() return 40 end end
    if k == "GetWidth" then return function(self) return self._w end end
    if k == "SetWidth" then return function(self, w) self._w = w end end
    if k == "GetHeight" then return function() return 20 end end
    if k == "GetText" then return function(self) return self._text end end
    if k == "SetText" then return function(self, v) self._text = v end end
    if k == "GetPoint" then return function() return "CENTER", nil, "CENTER", 0, 0 end end
    if k == "IsShown" then return function(self) return self._shown end end
    if k == "Show" then return function(self) self._shown = true; local f = rawget(self, "_scripts") and self._scripts.OnShow; if f then f(self) end end end
    if k == "Hide" then return function(self) self._shown = false end end
    if k == "SetShown" then return function(self, v) self._shown = v and true or false end end
    if k == "GetName" then return function(self) return self._name end end
    if k == "GetChecked" then return function() return true end end
    if k == "GetFrameLevel" then return function() return 1 end end
    if k == "SetScript" then return function(self, ev, fn) rawset(self, "_scripts", rawget(self, "_scripts") or {}); self._scripts[ev] = fn end end
    if k == "GetScript" then return function(self, ev) return rawget(self, "_scripts") and self._scripts[ev] end end
    if k == "HookScript" then return function() end end
    if k == "RegisterEvent" then return function(self, e) rawset(self, "_events", rawget(self, "_events") or {}); self._events[e] = true end end
    return function() end
  end })
end

local allFrames = {}
function CreateFrame(_, name)
  local f = mock(name)
  allFrames[#allFrames + 1] = f
  if name then _G[name] = f end
  return f
end
UIParent = mock("UIParent")
GameTooltip = mock("GameTooltip")
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) print("CHAT", (m:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))) end }
UISpecialFrames = {}
StaticPopupDialogs = {}
tinsert = table.insert
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
function geterrorhandler() return function(e) error(e, 0) end end
function hooksecurefunc() end
C_Timer = { After = function(_, f) f() end }
function GetTime() return 100 end
function IsShiftKeyDown() return false end
function GetQuestDifficultyColor() return { r = 1, g = 1, b = 0 } end
CLASS_ICON_TCOORDS = setmetatable({}, { __index = function() return { 0, 0.25, 0, 0.25 } end })
ITEM_QUALITY_COLORS = {}
function GetItemInfo() return nil end
C_Item = { RequestLoadItemDataByID = function() end, GetItemIconByID = function() return 134400 end,
           GetItemCount = function() return 0 end }
function IsEquippedItem() return false end
function GetInventoryItemLink(_, slot) return slot == 16 and "item:1001" or (slot == 1 and "item:1002" or nil) end
local ITEMS = { ["item:1001"] = { "INVTYPE_2HWEAPON", 2, 8, { ITEM_MOD_STRENGTH_SHORT = 5, ITEM_MOD_DAMAGE_PER_SECOND_SHORT = 10 } },
                ["item:1002"] = { "INVTYPE_HEAD", 4, 3, { ITEM_MOD_STAMINA_SHORT = 4 } },
                ["item:2001"] = { "INVTYPE_2HWEAPON", 2, 1, { ITEM_MOD_STRENGTH_SHORT = 9, ITEM_MOD_DAMAGE_PER_SECOND_SHORT = 14 } },
                ["item:2002"] = { "INVTYPE_HEAD", 4, 4, { ITEM_MOD_STAMINA_SHORT = 9 } } }
C_Item.GetItemStats = function(l) return ITEMS[l] and ITEMS[l][4] end
C_Item.GetItemInfoInstant = function(l) local x = ITEMS[l]; if x then return 1, "", "", x[1], 1, x[2], x[3] end end
function InCombatLockdown() return false end
C_Container = { GetContainerNumSlots = function(b) return b == 0 and 2 or 0 end,
  GetContainerItemLink = function(b, s) return s == 1 and "item:2001" or "item:2002" end,
  UseContainerItem = function() end, GetContainerItemInfo = function() return nil end }
function GetNumQuestChoices() return 2 end
function GetQuestItemLink(_, i) return i == 1 and "item:2001" or "item:2002" end
SlashCmdList = {}
-- HereBeDragons stand-in: the player stands at PLAYER_POS (map, x, y with x/y 0-1), and the
-- distance is straight-line on a map 1000 yards across. Every other library is missing.
PLAYER_POS = nil
local HBD_MOCK = setmetatable({
  GetPlayerZonePosition = function() if PLAYER_POS then return PLAYER_POS[2], PLAYER_POS[3], PLAYER_POS[1] end end,
  GetZoneDistance = function(_, m1, x1, y1, m2, x2, y2)
    if m1 ~= m2 then return nil end
    return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2) * 1000
  end,
}, { __index = function() return function() end end })
LibStub = setmetatable({}, { __call = function(_, name) if name == "HereBeDragons-2.0" then return HBD_MOCK end end })

function UnitRace() return P.race, P.raceFile, 5 end
function UnitClass() return P.class:sub(1, 1) .. P.class:sub(2):lower(), P.class, 2 end
function UnitFactionGroup() return P.faction end
function UnitLevel() return P.level end
function UnitName() return "Tester" end
function UnitCharacterPoints() return 1 end

local questLog = {}
function GetNumQuestLogEntries() return #questLog end
function GetQuestLogTitle(i) local q = questLog[i]; return q[1], 1, nil, false, nil, q[3] and 1 or nil, nil, q[2] end
local completed = {}
C_QuestLog = { IsQuestFlaggedCompleted = function(id) return completed[id] or false end,
  GetAllCompletedQuestIDs = function() local t = {} for id in pairs(completed) do t[#t+1] = id end return t end,
  GetTitleForQuestID = function(id) return QNAMES[id] end }
QNAMES = {}

-- Talent trees built from the class's builds so names resolve.
local env = { ns = nil }
local tabs, talentsByTab = {}, {}
function GetNumTalentTabs() return #tabs end
function GetTalentTabInfo(t) return 100 + t, tabs[t], "", 1, 3 end
function GetNumTalents(t) return #(talentsByTab[t] or {}) end
function GetTalentInfo(t, i) local x = talentsByTab[t][i]; return x[1], 1, 1, 1, x[2], x[3] end
-- TALENT_API=new: only C_SpecializationInfo.GetTalentInfo (table); TALENT_API=id: talent ID first.
if os.getenv("TALENT_API") == "new" then
  GetTalentInfo = nil
  C_SpecializationInfo = C_SpecializationInfo or {}
  C_SpecializationInfo.GetTalentInfo = function(q)
    local x = talentsByTab[q.specializationIndex] and talentsByTab[q.specializationIndex][q.talentIndex]
    if x then return { name = x[1], icon = 1, tier = 1, column = 1, rank = x[2], maxRank = x[3], talentID = 7 } end
  end
elseif os.getenv("TALENT_API") == "id" then
  function GetTalentInfo(t, i) local x = talentsByTab[t][i]; return 7, x[1], 1, 1, 1, x[2], x[3] end
end
-- TALENT_API=tier: WoW Forever style. No global talent functions; C_SpecializationInfo.GetTalentInfo
-- needs a tier and column; tree names come from C_SpecializationInfo.GetSpecializationInfo.
-- TALENT_API=traits: only C_ClassTalents / C_Traits.
local mode = os.getenv("TALENT_API")
if mode == "tier" or mode == "traits" then
  local byTab = talentsByTab
  GetTalentInfo, GetNumTalents, GetTalentTabInfo, GetNumTalentTabs = nil, nil, nil, nil
  C_SpecializationInfo = C_SpecializationInfo or {}
  C_SpecializationInfo.GetSpecializationInfo = function(t) return 100 + t, tabs[t], "", 1, "DAMAGER", 1 end
  if mode == "tier" then
    C_SpecializationInfo.GetTalentInfo = function(q)
      if not q.tier then error("C_SpecializationInfo.GetTalent: query.tier must be specified.") end
      local i = (q.tier - 1) * 4 + q.column
      local x = byTab[q.specializationIndex] and byTab[q.specializationIndex][i]
      if x then return { name = x[1], icon = 1, tier = q.tier, column = q.column, rank = x[2], maxRank = x[3], talentID = 7 } end
    end
  else
    C_SpecializationInfo.GetTalentInfo = nil
    local nodes, defs = {}, {}
    C_ClassTalents = { GetActiveConfigID = function() return 5 end }
    C_Traits = {
      GetConfigInfo = function() return { treeIDs = { 1 } } end,
      GetTreeNodes = function()
        wipe(nodes); wipe(defs)
        for _, list in ipairs(byTab) do for _, x in ipairs(list) do nodes[#nodes + 1] = #nodes + 1; defs[#nodes] = x end end
        return nodes
      end,
      GetNodeInfo = function(_, n) return { isVisible = true, entryIDs = { n }, currentRank = defs[n][2], maxRanks = defs[n][3] } end,
      GetEntryInfo = function(_, e) return { definitionID = e } end,
      GetDefinitionInfo = function(d) return { overrideName = defs[d][1] } end,
    }
  end
end
-- TALENT_LATE=1: talent data is empty until after login (as on a slow client).
if os.getenv("TALENT_LATE") then
  local gti, gnt = GetTalentInfo, GetNumTalents
  function GetNumTalents(t) if TALENTS_READY then return gnt(t) end return 0 end
  function GetTalentInfo(t, i) if TALENTS_READY then return gti(t, i) end return nil end
end
function GetNumSkillLines() return 2 end
function GetSkillLineInfo(i)
  if i == 1 then return "Professions", true end
  return "Mining", false, nil, 37, 0, 0, 75
end

---------------------------------------------------------------- load files from the toc
local ns = {}
local toc = io.open(dir .. "/CoffeyGuide.toc"):read("*a")
local missing = {}
for line in toc:gmatch("[^\r\n]+") do
  if not line:match("^##") and line:match("%.lua$") and not line:match("^Libs") then
    local path = line:gsub("\\", "/")
    local full = path:match("^Data/") and (dataDir .. "/" .. path:sub(6)) or (dir .. "/" .. path)
    local chunk, err = loadfile(full)
    if not chunk then
      if err:match("No such file") or err:match("cannot open") then missing[#missing + 1] = path
      else error(err) end
    else
      chunk("CoffeyGuide", ns)
    end
  end
end
if #missing > 0 then print("MISSING (not yet written): " .. table.concat(missing, ", ")) end

-- Build fake talent tabs from data.
for _, b in ipairs(ns.BUILDS[P.class] or {}) do
  for _, plan in pairs(b.talents) do
    local tname, rank, tab = plan[1], plan[2], plan[3]
    local ti
    for i, n in ipairs(tabs) do if n == tab then ti = i end end
    if not ti then tabs[#tabs + 1] = tab; ti = #tabs; talentsByTab[ti] = {} end
    local found
    for _, x in ipairs(talentsByTab[ti]) do if x[1] == tname then found = x; x[3] = math.max(x[3], rank) end end
    if not found then table.insert(talentsByTab[ti], { tname, 0, rank }) end
  end
end

---------------------------------------------------------------- drive
local function fire(ev, ...)
  for _, f in ipairs(allFrames) do
    if rawget(f, "_events") and f._events[ev] and rawget(f, "_scripts") and f._scripts.OnEvent then
      f._scripts.OnEvent(f, ev, ...)
    end
  end
end

if os.getenv("HISTORY") then
  for _, st in ipairs(ns.ALLSTEPS) do
    if st.classes and st.classes[1] == P.class and st.quests and (st.max or 60) <= P.level then
      for _, q in ipairs(st.quests) do
        local name, id = type(q) == "table" and q[1] or q, type(q) == "table" and q[2] or nil
        local fid = id or (90000 + #name)
        completed[fid] = true; QNAMES[fid] = name
      end
    end
  end
end
fire("ADDON_LOADED", "CoffeyGuide")
fire("PLAYER_LOGIN")
fire("ADDON_LOADED", "Blizzard_TalentUI")
if os.getenv("TALENT_LATE") then
  print("talents at login:", ns.char.talentDiag.found)
  TALENTS_READY = true
  fire("SPELLS_CHANGED")
  print("talents after SPELLS_CHANGED:", ns.char.talentDiag.found)
end
print(("route=%d tips=%d builds=%d"):format(#ns.route, #ns.tips, #(ns.BUILDS[P.class] or {})))
local cur = ns.route[ns.CurrentIndex()]
print("current:", cur and (cur.id .. " " .. cur.min .. "-" .. (cur.max or "?") .. " " .. cur.title) or "none")
local b = ns.GetActiveBuild()
print("build:", b and b.name, "spec:", ns.ActiveSpec())
local L, plan = ns.PendingTalent()
print("pending talent:", L, plan and ns.TalentText(plan))
ns.TalentDebug()
if os.getenv("TALENT_API") then for k, v in pairs(ns.char.talentDiag) do print("diag", k, v) end end

for _, tab in ipairs({ "quests", "route", "talents", "spec", "gear", "professions", "extras", "dungeons", "settings" }) do
  SlashCmdList.COFFEYGUIDE(tab == "route" and "guide" or tab)
  print("rendered tab", tab)
end
SlashCmdList.COFFEYGUIDE("next"); SlashCmdList.COFFEYGUIDE("prev"); SlashCmdList.COFFEYGUIDE("wp")
SlashCmdList.COFFEYGUIDE("")   -- hide
SlashCmdList.COFFEYGUIDE("")   -- show
ns.db.minimized = true; ns.Fire("Refresh"); ns.db.minimized = false
for i = 1, #ns.route do ns.SetView(i) end
ns.SetView(nil)

-- Turn in a step's quests and level up.
local s = ns.route[ns.CurrentIndex()]
if s and s.quests then
  for _, q in ipairs(s.quests) do
    local name, id = type(q) == "table" and q[1] or q, type(q) == "table" and q[2] or nil
    questLog = { { name, id or 999 } }
    fire("QUEST_ACCEPTED", id or 999)
    questLog = {}
    if id then completed[id] = true end
    fire("QUEST_TURNED_IN", id or 999)
  end
end
P.level = P.level + 1
fire("PLAYER_LEVEL_UP", P.level)
ns.ToggleDone(ns.route[ns.CurrentIndex()]); ns.Skip(ns.route[ns.CurrentIndex()])
SlashCmdList.COFFEYGUIDE("reset")
print("after: current", ns.route[ns.CurrentIndex()].id)
fire("BAG_UPDATE_DELAYED")
print("upgrade 2H:", ns.Gear.Upgrade("item:2001"), "plate head usable:", ns.Gear.Usable("item:2002"))
fire("QUEST_COMPLETE")
local tstep; for _, st in ipairs(ns.route) do if st.id == "h_tirisfal_late" then tstep = st end end
if tstep and ns.PlanFor(tstep) and #ns.PlanFor(tstep) >= 4 then
  local function show(label) local _, first, done = ns.PlanProgress(tstep); print("plan", label, "first=", first, "done=", done) end
  show("start")
  questLog = { { "Test Quest", 5001 } }; fire("QUEST_LOG_UPDATE"); show("accepted")
  questLog = { { "Test Quest", 5001, true } }; fire("QUEST_LOG_UPDATE"); show("objectives complete")
  questLog = {}; completed[5001] = true; fire("QUEST_TURNED_IN", 5001); show("turned in")
  local plan = ns.PlanFor(tstep); ns.MarkSub(tstep, plan[4], true); show("go marked")
  print("tirisfal step state:", ns.StepState(tstep))
end
-- Flight path, hearthstone and travel sub-steps tick off by themselves.
local sp; for _, st in ipairs(ns.route) do if st.id == "h_silverpine" then sp = st end end
if sp and ns.PlanFor(sp) then
  local plan = ns.PlanFor(sp)
  local fp, hs = plan[1], plan[2]
  ns.SetView(nil); for i, st in ipairs(ns.route) do if st == sp then ns.SetView(i) end end
  print("silverpine fp/hs before:", ns.SubDone(sp, fp), ns.SubDone(sp, hs))
  function GetBindLocation() return "The Sepulcher" end
  fire("HEARTHSTONE_BOUND")
  local nodes = { { "Undercity, Tirisfal", "REACHABLE" }, { "The Sepulcher, Silverpine Forest", "CURRENT" } }
  function NumTaxiNodes() return #nodes end
  function TaxiNodeName(i) return nodes[i][1] end
  function TaxiNodeGetType(i) return nodes[i][2] end
  fire("TAXIMAP_OPENED")
  print("silverpine fp/hs after:", ns.SubDone(sp, fp), ns.SubDone(sp, hs))
  function GetBindLocation() return "Tarren Mill" end
  print("silverpine hs after rebinding elsewhere:", ns.SubDone(sp, hs))
  local tl = ns.PlanFor(tstep)
  print("tirisfal last go (next step started):", ns.SubDone(tstep, tl[#tl]))
  ns.SetView(nil)
end
SlashCmdList.COFFEYGUIDE("quests")
ns.ShowLink(ns.WEBSITE); print("website:", ns.WEBSITE)

-- Progress detection: quests from a later step in the log, standing in its zone.
SlashCmdList.COFFEYGUIDE("reset")
completed = {}; ns.completed = {}; wipe(ns.completedNames); questLog = {}
fire("QUEST_LOG_UPDATE")
local cur0 = ns.CurrentIndex()
local target
for i = cur0 + 2, math.min(#ns.route, cur0 + 12) do
  local st = ns.route[i]
  local plan = ns.PlanFor(st)
  if st.kind == "zone" and not st.optional and plan and #plan >= 6 and (st.min or 1) <= P.level + 2
     and not ns.StepState(st) then target = i; break end
end
if target then
  local st = ns.route[target]
  local seen, log = {}, {}
  for _, s in ipairs(ns.PlanFor(st)) do
    if s.quest and s.quest[2] and not seen[s.quest[2]] and #log < 3 then seen[s.quest[2]] = true; log[#log + 1] = { s.quest[1], s.quest[2] } end
  end
  questLog = log; fire("QUEST_LOG_UPDATE")
  C_Map = { GetBestMapForUnit = function() return st.map end, GetMapInfo = function() return nil end }
  ns.Detect.Invalidate()
  local i, sst, reason = ns.Detect.Suggestion()
  print("detect: current", cur0, "target", target, "suggested", i, reason)
  assert(i == target, "suggestion should point at the step whose quests are in the log")
  ns.Fire("Refresh") -- tracker renders the banner
  ns.Detect.JumpTo(i)
  print("detect: after jump current", ns.CurrentIndex(), "skipped", #ns.char.lastJump.ids)
  assert(ns.CurrentIndex() == target, "jump should land on the target")
  ns.Fire("Refresh")
  ns.Detect.UndoJump()
  print("detect: after undo current", ns.CurrentIndex())
  assert(ns.CurrentIndex() == cur0, "undo should restore the original current step")
  -- Missed: the first quest of the plan untouched, three later quests in the log.
  local plan = ns.PlanFor(st)
  local firstKey, firstName, nLater = nil, nil, 0
  questLog = {}
  local inLog = {}
  for _, s in ipairs(plan) do
    if s.quest and s.quest[2] then
      if not firstKey then firstKey, firstName = s.quest[2], s.quest[1]
      elseif s.quest[2] ~= firstKey and s.quest[1] ~= firstName and not inLog[s.quest[2]] and nLater < 3 then
        inLog[s.quest[2]] = true; nLater = nLater + 1
        questLog[#questLog + 1] = { s.quest[1], s.quest[2] }
      end
    end
  end
  fire("QUEST_LOG_UPDATE")
  local _, first, _, missed = ns.PlanProgress(st)
  local firstIdx; for k, s in ipairs(plan) do if s.quest and s.quest[2] == firstKey then firstIdx = k; break end end
  print("detect: first quest at", firstIdx, "missed:", missed[firstIdx] and "yes" or "no", "cursor at", first, "passed by", ns.MissedCount(missed))
  assert(missed[firstIdx], "an untouched quest before three active ones should count as passed by")
  ns.Fire("Refresh")
  ns.db.compact = true; ns.Fire("Refresh"); ns.db.density = "detailed"; ns.db.compact = false; ns.Fire("Refresh")
  ns.Fire("ShowWelcome", true)
  C_Map = nil
else
  print("detect: no later zone step with a plan for this character; skipped")
end
-- Same-name quests: finishing one part of a chain must not tick off the others.
SlashCmdList.COFFEYGUIDE("reset")
completed = {}; ns.completed = {}; wipe(ns.completedNames); questLog = {}
completed[70001] = true; QNAMES[70001] = "Shared Name Test"
ns.LoadCompleted(); ns.ResolveCompletedNames(); fire("QUEST_LOG_UPDATE")
assert(ns.IsQuestDone({ "Shared Name Test", 70001 }), "the finished part counts as done")
assert(not ns.IsQuestDone({ "Shared Name Test", 70002 }), "another quest with the same name must not count as done")
assert(ns.IsQuestDone({ "Shared Name Test" }), "a quest known only by name still matches by name")
questLog = { { "Shared Name Test", 70003 } }; fire("QUEST_LOG_UPDATE")
assert(not ns.IsQuestActive({ "Shared Name Test", 70002 }), "a later part in the log is not this part")
assert(ns.IsQuestActive({ "Shared Name Test", 70003 }), "the part in the log is active")
assert(ns.IsQuestActive({ "Shared Name Test" }), "a quest known only by name is active by name")
questLog = {}; fire("QUEST_LOG_UPDATE")
print("names: same-name chain parts stay separate")

-- Levels: reaching a zone's last level must not close it while you are working on it.
completed = {}; ns.completed = {}; wipe(ns.completedNames); questLog = {}
fire("QUEST_LOG_UPDATE")
local hold
for _, st in ipairs(ns.route) do
  local plan = ns.PlanFor(st)
  if st.kind == "zone" and not st.optional and st.reach and plan and #plan >= 6 then hold = st; break end
end
-- Quests each step turns in, and which quests more than one step turns in.
local owners = {}
for _, st in ipairs(ns.route) do
  local seen = {}
  for _, s in ipairs(ns.PlanFor(st) or {}) do
    if s.act == "turnin" and s.quest and s.quest[2] and not seen[s.quest[2]] then
      seen[s.quest[2]] = true; owners[s.quest[2]] = (owners[s.quest[2]] or 0) + 1
    end
  end
end
if hold then
  local qs, seen = {}, {}
  for _, s in ipairs(ns.PlanFor(hold)) do
    local id = s.act == "turnin" and s.quest and s.quest[2]
    if id and owners[id] == 1 and not seen[id] then seen[id] = true; qs[#qs + 1] = s.quest end
  end
  local saved = P.level
  local function at(level) P.level = level; ns.player.level = level; ns.Invalidate(); return ns.StepState(hold) end
  assert(at(hold.reach) == "done", "a zone you never started closes at its reach level")
  completed[qs[1][2]] = true; QNAMES[qs[1][2]] = qs[1][1]; ns.LoadCompleted()
  questLog = { { qs[2][1], qs[2][2] }, { qs[3][1], qs[3][2] } }; fire("QUEST_LOG_UPDATE")
  assert(at(hold.reach) == nil, "quests in the log keep the zone open at its reach level")
  assert(at(hold.reach + 4) == nil, "quests in the log keep the zone open up to 4 levels past it")
  assert(at(hold.reach + 5) ~= nil, "a zone left 5+ levels behind closes even with quests in the log")
  questLog = {}; fire("QUEST_LOG_UPDATE")
  assert(at(hold.reach + 2) == nil, "a started zone with quests left stays open for 2 levels past it")
  assert(at(hold.reach + 3) ~= nil, "a started zone closes 3 levels past it")
  at(saved)
  print("levels: " .. hold.id .. " held while working, closes when left behind")
end

-- A quest the route turns in at two steps (put off to a second visit) holds neither of them.
completed = {}; ns.completed = {}; wipe(ns.completedNames); questLog = {}
local shared, sharedStep
for _, st in ipairs(ns.route) do
  if st.kind == "zone" and not st.optional and st.reach then
    for _, s in ipairs(ns.PlanFor(st) or {}) do
      local id = s.act == "turnin" and s.quest and s.quest[2]
      if id and (owners[id] or 0) > 1 then shared, sharedStep = s.quest, st; break end
    end
  end
  if shared then break end
end
if shared then
  local saved = P.level
  questLog = { { shared[1], shared[2] } }; fire("QUEST_LOG_UPDATE")
  P.level = sharedStep.reach; ns.player.level = sharedStep.reach; ns.Invalidate()
  assert(ns.StepState(sharedStep) == "done", "a quest turned in at two steps must not hold the first one open")
  P.level = saved; ns.player.level = saved; questLog = {}; fire("QUEST_LOG_UPDATE")
  print("levels: shared turn-in " .. shared[2] .. " does not hold " .. sharedStep.id)
end

-- Objectives: a quest split over several rows ticks off row by row.
SlashCmdList.COFFEYGUIDE("reset")
completed = {}; ns.completed = {}; wipe(ns.completedNames); questLog = {}
local OBJECTIVES = {}
C_QuestLog.GetQuestObjectives = function(id) return OBJECTIVES[id] end
local objStep, objRows
for _, st in ipairs(ns.route) do
  local byQuest = {}
  for _, s in ipairs(ns.PlanFor(st) or {}) do
    if s.obj and #s.obj > 0 and s.quest and s.quest[2] then
      byQuest[s.quest[2]] = byQuest[s.quest[2]] or {}
      table.insert(byQuest[s.quest[2]], s)
    end
  end
  for _, rows in pairs(byQuest) do
    if #rows >= 2 and rows[1].obj[1] ~= rows[2].obj[1] then objStep, objRows = st, rows; break end
  end
  if objStep then break end
end
if objStep then
  local q = objRows[1].quest
  local function setObjectives(retail)
    local list = {}
    for k, s in ipairs(objRows) do
      for _, n in ipairs(s.obj) do
        local have = k == 1 and 8 or 3
        local text = retail and (have .. "/8 " .. n .. " slain") or (n .. " slain: " .. have .. "/8")
        list[#list + 1] = { text = text, finished = k == 1, numFulfilled = have, numRequired = 8 }
      end
    end
    OBJECTIVES[q[2]] = list
    questLog = { { q[1], q[2] } }; fire("QUEST_LOG_UPDATE")
  end
  for _, retail in ipairs({ false, true }) do
    setObjectives(retail)
    assert(ns.SubDone(objStep, objRows[1]), "a row whose objectives are done ticks off before the quest is complete")
    assert(not ns.SubDone(objStep, objRows[2]), "a row whose objectives are open stays open")
    assert(ns.SubProgress(objRows[2]):find("3/8"), "an open row shows its live count")
  end
  OBJECTIVES[q[2]] = { { text = "Something else: 0/1", finished = false } }
  questLog = { { q[1], q[2] } }; fire("QUEST_LOG_UPDATE")
  assert(not ns.SubDone(objStep, objRows[1]), "unmatched objective names fall back to the whole quest")
  OBJECTIVES = {}; questLog = {}; fire("QUEST_LOG_UPDATE")
  print("objectives: " .. q[1] .. " ticks off row by row")
end

-- Arrival: a travel row ticks off when you get there, but only while it is the current row.
SlashCmdList.COFFEYGUIDE("reset")
local goStep = ns.route[ns.CurrentIndex()]
local goRow, laterGo
for _, s in ipairs(ns.PlanFor(goStep) or {}) do
  if s.act == "go" and s.wp and s.wp[2] and s.arrive ~= false then
    if not goRow then goRow = s elseif not laterGo then laterGo = s end
  end
end
if goRow then
  local function at(s, dx) PLAYER_POS = { s.wp[1], s.wp[2] / 100 + (dx or 0), s.wp[3] / 100 } end
  for _, s in ipairs(ns.PlanFor(goStep)) do if s == goRow then break end; ns.MarkSub(goStep, s, true) end
  local _, first = ns.PlanProgress(goStep)
  assert(ns.PlanFor(goStep)[first] == goRow, "the travel row is the current row")
  if laterGo then
    at(laterGo); ns.CheckArrival()
    assert(not (ns.char.plan[goStep.id] or {})[laterGo._i], "standing at a later stop doesn't tick it")
  end
  -- Browsing ahead: a later step's travel row must not tick from where you stand.
  for j = ns.CurrentIndex() + 1, #ns.route do
    local st = ns.route[j]
    local plan, f = ns.PlanProgress(st)
    local row = plan and f and plan[f]
    if row and row.act == "go" and row.wp and row.wp[2] then
      ns.SetView(j); at(row); ns.CheckArrival()
      assert(not (ns.char.plan[st.id] or {})[row._i], "a step you are only browsing doesn't tick on arrival")
      ns.SetView(nil); break
    end
  end
  at(goRow, 0.2)
  assert(not ns.CheckArrival(), "far from the waypoint the row stays open")
  UnitOnTaxi = function() return true end; at(goRow, 0.01)
  assert(not ns.CheckArrival(), "flying over the waypoint doesn't tick it")
  UnitOnTaxi = nil
  ns.MarkSub(goStep, goRow, false)
  assert(not ns.CheckArrival(), "a row you unticked by hand stays unticked")
  ns.char.plan[goStep.id][goRow._i] = nil
  assert(ns.CheckArrival() and ns.SubDone(goStep, goRow), "arriving ticks the travel row")
  PLAYER_POS = nil
  print("arrival: " .. goStep.id .. " travel row ticks off on arrival")
end

-- Preparation rows (obj = {}) show no count and follow the whole quest.
for _, st in ipairs(ns.route) do
  for _, s in ipairs(ns.PlanFor(st) or {}) do
    if s.obj and #s.obj == 0 and s.quest and s.quest[2] then
      OBJECTIVES[s.quest[2]] = { { text = "Something: 0/5", finished = false, numFulfilled = 0, numRequired = 5 } }
      questLog = { { s.quest[1], s.quest[2] } }; fire("QUEST_LOG_UPDATE")
      assert(ns.SubProgress(s) == nil, "a preparation row shows no count")
      assert(not ns.SubDone(st, s), "a preparation row waits for the whole quest")
      OBJECTIVES = {}; questLog = {}; fire("QUEST_LOG_UPDATE")
      print("objectives: preparation row in " .. st.id .. " shows no count")
      break
    end
  end
end

CoffeyGuide_Binding("check"); CoffeyGuide_Binding("compact"); CoffeyGuide_Binding("waypoint")
ns.db.colorblind = true; ns.db.accentGold = true; ns.Fire("SettingsChanged")
SlashCmdList.COFFEYGUIDE("settings"); g_search = _G.CoffeyGuideSearch
if g_search then g_search._text = "a"; SlashCmdList.COFFEYGUIDE("guide") end
print("HARNESS_OK")
