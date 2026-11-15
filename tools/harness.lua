-- Loads ForeverGuide against a mock WoW API and drives it through its main flows.
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
LibStub = nil

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
function GetNumSkillLines() return 2 end
function GetSkillLineInfo(i)
  if i == 1 then return "Professions", true end
  return "Mining", false, nil, 37, 0, 0, 75
end

---------------------------------------------------------------- load files from the toc
local ns = {}
local toc = io.open(dir .. "/ForeverGuide.toc"):read("*a")
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
      chunk("ForeverGuide", ns)
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
fire("ADDON_LOADED", "ForeverGuide")
fire("PLAYER_LOGIN")
fire("ADDON_LOADED", "Blizzard_TalentUI")
print(("route=%d tips=%d builds=%d"):format(#ns.route, #ns.tips, #(ns.BUILDS[P.class] or {})))
local cur = ns.route[ns.CurrentIndex()]
print("current:", cur and (cur.id .. " " .. cur.min .. "-" .. (cur.max or "?") .. " " .. cur.title) or "none")
local b = ns.GetActiveBuild()
print("build:", b and b.name, "spec:", ns.ActiveSpec())
local L, plan = ns.PendingTalent()
print("pending talent:", L, plan and ns.TalentText(plan))
ns.TalentDebug()

for _, tab in ipairs({ "quests", "route", "talents", "spec", "gear", "professions", "extras", "dungeons", "settings" }) do
  SlashCmdList.FOREVERGUIDE(tab == "route" and "guide" or tab)
  print("rendered tab", tab)
end
SlashCmdList.FOREVERGUIDE("next"); SlashCmdList.FOREVERGUIDE("prev"); SlashCmdList.FOREVERGUIDE("wp")
SlashCmdList.FOREVERGUIDE("")   -- hide
SlashCmdList.FOREVERGUIDE("")   -- show
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
SlashCmdList.FOREVERGUIDE("reset")
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
SlashCmdList.FOREVERGUIDE("quests")
ns.ShowLink(ns.WEBSITE); print("website:", ns.WEBSITE)
print("HARNESS_OK")
