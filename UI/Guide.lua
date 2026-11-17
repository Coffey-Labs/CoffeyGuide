-- Coffey's Leveling Guide: the full guide window (route, talents, spec, gear, professions, gold & extras, dungeons, settings).
local ADDON, ns = ...
local UI = ns.UI
local g -- window
local currentTab = "route"
local sel = {} -- per-tab selector choice

local TABS = {
  { key = "route",       label = "Route",          icon = "Interface\\Icons\\INV_Misc_Map_01" },
  { key = "questlog",    label = "Quest Log",      icon = "Interface\\Icons\\INV_Misc_Note_06" },
  { key = "class",       label = "Talents & Spec", icon = "Interface\\Icons\\Ability_Marksmanship" },
  { key = "gear",        label = "Gear & BiS",     icon = "Interface\\Icons\\INV_Chest_Plate06" },
  { key = "professions", label = "Professions",    icon = "Interface\\Icons\\Trade_BlackSmithing" },
  { key = "extras",      label = "Gold & Extras",  icon = "Interface\\Icons\\INV_Misc_Coin_01" },
  { key = "dungeons",    label = "Dungeons",       icon = "Interface\\Icons\\INV_Misc_Bone_ElfSkull_01" },
  { key = "settings",    label = "Settings",       icon = "Interface\\Icons\\Trade_Engineering" },
}

---------------------------------------------------------------------------
-- Selector row (pooled small buttons)
---------------------------------------------------------------------------
-- Up to two rows of option buttons above the list (e.g. view, then build or spec).
local selButtons = { {}, {} }
local function SelectorRow(row, options, current, onPick)
  local pool = selButtons[row]
  for _, b in ipairs(pool) do b:Hide() end
  local x, y = 0, -46 - (row - 1) * 26
  for i, opt in ipairs(options or {}) do
    local b = pool[i]
    if not b then
      b = UI.Button(g.content, "", 70, nil)
      pool[i] = b
    end
    b:SetText(opt.label)
    b:SetWidth(math.max(70, b.text:GetStringWidth() + 26))
    b:ClearAllPoints()
    b:SetPoint("TOPLEFT", g.content, "TOPLEFT", x, y)
    x = x + b:GetWidth() + 4
    b:SetActive(opt.value == current)
    b:SetScript("OnClick", function() onPick(opt.value) end)
    b:Show()
  end
  return options and #options > 0
end

local function SetSelector(options, current, onPick, options2, current2, onPick2)
  local rows = 0
  if SelectorRow(1, options, current, onPick) then rows = 1 end
  if SelectorRow(2, options2, current2, onPick2) then rows = 2 end
  g.listHolder:ClearAllPoints()
  g.listHolder:SetPoint("TOPLEFT", g.content, "TOPLEFT", 0, -48 - rows * 26)
  g.listHolder:SetPoint("BOTTOMRIGHT", g.content, "BOTTOMRIGHT", 0, 0)
end

local function Header(title, sub)
  g.title:SetText(title or "")
  g.sub:SetText(sub or "")
end

local function wrapLines(lines, prefix)
  local out = {}
  for i, l in ipairs(lines or {}) do out[#out + 1] = (prefix == "#" and (i .. ". ") or (prefix or "")) .. l end
  return table.concat(out, "\n")
end

---------------------------------------------------------------------------
-- Tabs
---------------------------------------------------------------------------
local render = {}

local function ZoneStatText(step)
  local d, t = ns.ZoneStats(step)
  return d and ("  |cffffffff%d/%d quests done|r"):format(d, t) or ""
end

function render.route(list)
  local done, total = ns.Progress()
  Header("Leveling Route", ("%s %s · %s · %d of %d steps done"):format(ns.player.raceName or "", ns.player.className or "",
    ns.player.faction or "", done, total))
  SetSelector(nil)
  local cur, view = ns.CurrentIndex(), ns.ViewIndex()
  local lastBand
  for i, step in ipairs(ns.route) do
    if ns.db.showOptional or not step.optional then
      local band = math.floor((step.min or 1) / 10) * 10
      if band ~= lastBand then
        lastBand = band
        list:Add({ header = true, title = ("Levels %d - %d"):format(math.max(1, band), band + 9) })
      end
      local state = ns.StepState(step)
      local status = state == "skipped" and UI.STATUS.skipped or state == "behind" and UI.STATUS.current
                  or state and UI.STATUS.done or (i == cur and UI.STATUS.current or UI.STATUS.todo)
      if i == cur then g.list:Mark("current") end
      local icon, coords = ns.KIND_ICONS[step.kind] or ns.KIND_ICONS.quest, nil
      if step.kind == "class" then
        icon = "Interface\\TargetingFrame\\UI-Classes-Circles"
        local c = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[ns.player.class]
        if c then coords = { c[1], c[2], c[3], c[4] } end
      end
      local manual = ns.char.done[step.id] or ns.char.skip[step.id]
      list:Add({
        status = status, icon = icon, iconCoords = coords, dim = state ~= nil and state ~= "behind",
        onCheck = function() ns.ToggleDone(step) end,
        checkTip = manual and "Undo: put this step back on the route" or "Mark this step done",
        title = (step.title or "?") .. (step.optional and ("  " .. ns.C("info") .. "(optional)|r") or ""),
        sub = ns.BandText(step) .. "  |cffaaaaaa" .. (step.zone or "") .. "|r" .. ZoneStatText(step) .. "\n" .. (step.text or ""),
        search = step.zone,
        right = i == cur and (ns.C("cur") .. "CURRENT|r") or (i == view and (ns.C("info") .. "viewing|r")
                or (state == "behind" and (ns.C("warn") .. "still open|r")) or nil),
        rightWidth = 70,
        highlight = i == cur,
        onClick = function()
          if IsShiftKeyDown() and i > cur and ns.Detect then ns.Detect.JumpTo(i); return end
          ns.Fire("ToggleTracker", true); ns.char.view = i; ns.Fire("Refresh")
        end,
        onEnter = function(self)
          GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
          GameTooltip:AddLine(step.title or "", 1, 0.82, 0)
          GameTooltip:AddLine(step.text or "", 1, 1, 1, true)
          for _, q in ipairs(step.quests or {}) do
            local name = type(q) == "table" and q[1] or q
            local d = ns.IsQuestDone(q)
            GameTooltip:AddLine((d and (ns.C("good") .. "[done]|r ") or "|cff808080[todo]|r ") .. name, 1, 1, 1)
          end
          GameTooltip:AddLine("Click: show this step in the tracker.", 0.5, 0.5, 0.5)
          if i > cur then GameTooltip:AddLine("Shift-click: start from here (earlier unfinished steps are skipped; undo in the tracker).", 0.5, 0.5, 0.5, true) end
          GameTooltip:AddLine("Checkbox: mark done, or undo a done or skipped step.", 0.5, 0.5, 0.5)
          GameTooltip:Show()
        end,
      })
    end
  end
end

function render.questlog(list)
  local groups = ns.QuestLogSnapshot()
  local total, ready = 0, 0
  for _, gr in ipairs(groups) do
    for _, q in ipairs(gr.quests) do total = total + 1; if q.complete then ready = ready + 1 end end
  end
  local questie = QuestieLoader and ns.db.useQuestie
  Header("Quest Log", ("%d quests, %s%d ready to turn in|r. %s")
    :format(total, ns.C("good"), ready, questie and "Click a finished quest for an arrow to its turn-in NPC."
      or "Install Questie to get arrows to turn-in NPCs."))
  SetSelector(nil)
  -- Ready-to-turn-in first, then by zone.
  local readyList = {}
  for _, gr in ipairs(groups) do for _, q in ipairs(gr.quests) do if q.complete then readyList[#readyList + 1] = q end end end
  local function addQuest(q)
    local objs = {}
    for _, o in ipairs(q.objectives) do objs[#objs + 1] = (o.done and ns.C("good") or "|cffcccccc") .. (o.text or "") .. "|r" end
    local diff = GetQuestDifficultyColor and GetQuestDifficultyColor(q.level or 1) or { r = 1, g = 1, b = 1 }
    local wp = q.complete and q.id and ns.QuestieWaypoint(q.id, "finish")
    list:Add({
      status = q.complete and UI.STATUS.done or (q.failed and UI.STATUS.skipped or UI.STATUS.current),
      icon = q.complete and ns.ACT_ICONS.turnin or ns.ACT_ICONS.accept,
      title = ("|cff%02x%02x%02x[%d]|r %s"):format(diff.r * 255, diff.g * 255, diff.b * 255, q.level or 0, q.title),
      sub = q.complete and (ns.C("good") .. "Ready to turn in|r") or table.concat(objs, "\n"),
      right = q.complete and (wp and (ns.C("cur") .. "click: arrow|r") or "|cff808080no NPC location|r") or nil,
      rightWidth = 90,
      highlight = q.complete,
      onClick = wp and function() ns.Fire("SetWaypoints", { id = "ql:" .. q.id, title = q.title, wp = { wp } }, true) end or nil,
    })
  end
  if #readyList > 0 then
    list:Add({ header = true, title = "Ready to turn in" })
    for _, q in ipairs(readyList) do addQuest(q) end
  end
  for _, gr in ipairs(groups) do
    local any = false
    for _, q in ipairs(gr.quests) do
      if not q.complete then
        if not any then list:Add({ header = true, title = gr.name or "" }); any = true end
        addQuest(q)
      end
    end
  end
  -- Quest plan for the current step, in full.
  local step = ns.route[ns.ViewIndex()]
  local plan, first = ns.PlanProgress(step)
  if plan then
    list:Add({ header = true, title = "Quest plan: " .. (step.title or "") })
    local _, _, _, missed = ns.PlanProgress(step)
    for i, s in ipairs(plan) do
      local done = ns.SubDone(step, s)
      local m = missed and missed[i]
      list:Add({ status = done and UI.STATUS.done or (i == first and UI.STATUS.current or UI.STATUS.todo),
        icon = ns.ACT_ICONS[s.act] or ns.ACT_ICONS.note,
        title = ns.SubText(s) .. (m and "  |cff808080(passed by)|r" or ""), dim = done or m, highlight = i == first,
        onCheck = function() ns.MarkSub(step, s, not done) end, checkTip = done and "Mark not done" or "Mark done",
        onClick = function()
          local wps = ns.SubWaypoints(s)
          if wps then ns.Fire("SetWaypoints", { id = step.id .. ":ql" .. i, title = ns.SubText(s), wp = wps }, true) end
        end })
    end
  end
end

local CLASS_VIEWS = { { label = "Talent plan", value = "talents" }, { label = "Spec guide", value = "spec" } }
local function PickClassView(v) sel.classView = v; ns.Fire("RefreshGuide") end

local renderTalents, renderSpec
function render.class(list)
  if (sel.classView or "talents") == "spec" then renderSpec(list) else renderTalents(list) end
end

function renderTalents(list)
  ns.EnsureTalents()
  local builds = ns.GetBuilds()
  local build, auto = ns.GetActiveBuild()
  local opts = { { label = "Auto-detect", value = "__auto" } }
  for _, b in ipairs(builds) do opts[#opts + 1] = { label = b.name, value = b.key } end
  SetSelector(CLASS_VIEWS, "talents", PickClassView, opts, ns.char.build or "__auto", function(v)
    ns.char.build = (v ~= "__auto") and v or nil
    ns.Fire("Refresh")
  end)
  if not build then Header("Talents", "No talent data for your class."); return end
  Header("Talents: " .. build.name .. (auto and "  |cff808080(auto-detected)|r" or ""),
    (build.role or "") .. " - " .. (build.summary or ""))

  local level = ns.player.level or 1
  local pendingL = ns.PendingTalent()
  local start = (build.respecAt and level >= build.respecAt) and build.respecAt or 10
  for L = 10, 60 do
    local plan = build.talents and build.talents[L]
    if plan then
      local info = ns.talents.byName[plan[1]]
      local have = info and info.rank >= plan[2] and L >= start
      local status = (L <= level and have) and UI.STATUS.done or (L == pendingL and UI.STATUS.current or UI.STATUS.todo)
      list:Add({
        status = status,
        icon = info and info.icon or "Interface\\Icons\\INV_Misc_QuestionMark",
        title = ("|cffffd100Lv %d|r  %s"):format(L, ns.TalentText(plan)),
        sub = (plan[3] or "") .. ((L == build.respecAt) and ("  " .. ns.C("warn") .. "RESPEC here (see summary)|r") or "")
              .. (info and "" or ("  " .. ns.C("bad") .. "(talent name not found in your talent tree)|r")),
        dim = L > level, highlight = L == pendingL,
        onEnter = info and function(self)
          GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
          if GameTooltip.SetTalent then GameTooltip:SetTalent(info.tab, info.index) else GameTooltip:AddLine(plan[1]) end
          GameTooltip:Show()
        end or nil,
      })
    end
  end
  local spells = ns.SPELLS[ns.player.class]
  if spells then
    list:Add({ header = true, title = "New abilities by level" })
    for L = 1, 60 do
      if spells[L] then
        list:Add({ icon = "Interface\\Icons\\INV_Misc_Book_09", title = ("|cffffd100Lv %d|r  %s"):format(L, spells[L]),
                   dim = L > level, status = L <= level and UI.STATUS.done or UI.STATUS.todo })
      end
    end
  end
  if build.source then list:Add({ title = "|cff808080Source: " .. build.source .. "|r" }) end
end

function renderSpec(list)
  local guides = ns.SPECGUIDES[ns.player.class] or {}
  local opts = {}
  for name in pairs(guides) do opts[#opts + 1] = { label = name, value = name } end
  table.sort(opts, function(a, b) return a.label < b.label end)
  local chosen = sel.spec or ns.MatchSpec(guides, ns.ActiveSpec())
  if not guides[chosen] and opts[1] then chosen = opts[1].value end
  SetSelector(CLASS_VIEWS, "spec", PickClassView, opts, chosen, function(v) sel.spec = v; ns.Fire("RefreshGuide") end)
  local sg = guides[chosen]
  if not sg then Header("Spec Guide", "No spec guide data for your class."); return end
  local best = {}
  for k, v in pairs(sg.best or {}) do if v then best[#best + 1] = k end end
  table.sort(best)
  Header(chosen .. "  |cffaaaaaa" .. (sg.role or "") .. "|r",
    #best > 0 and ("Best for: " .. ns.C("good") .. table.concat(best, ", ") .. "|r") or "")
  list:Add({ icon = "Interface\\Icons\\INV_Misc_Book_11", title = "Overview", sub = sg.summary or "" })
  list:Add({ icon = "Interface\\Icons\\INV_Misc_Gem_Pearl_04", title = "Stat priority", sub = sg.stats or "" })
  list:Add({ header = true, title = "Rotation (priority order)" })
  for i, line in ipairs(sg.rotation or {}) do list:Add({ title = ("|cffffd100%d.|r %s"):format(i, line) }) end
  if sg.aoe and #sg.aoe > 0 then
    list:Add({ header = true, title = "AoE" })
    for _, line in ipairs(sg.aoe) do list:Add({ title = "• " .. line }) end
  end
  if sg.tips and #sg.tips > 0 then
    list:Add({ header = true, title = "Tips" })
    for _, line in ipairs(sg.tips) do list:Add({ title = "• " .. line }) end
  end
  if sg.source then list:Add({ title = "|cff808080Source: " .. sg.source .. "|r" }) end
end

local function ItemIcon(id)
  if not id then return "Interface\\Icons\\INV_Misc_QuestionMark" end
  local icon = (C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(id)) or (GetItemIcon and GetItemIcon(id))
  return icon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function ItemTitle(it)
  if it.id then
    local name, link, quality = GetItemInfo(it.id)
    if quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
      return ITEM_QUALITY_COLORS[quality].hex .. (name or it.item) .. "|r", link
    end
    if not name and C_Item and C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(it.id) end
    return it.item, link
  end
  return it.item
end

local function Owned(id)
  if not id then return false end
  if IsEquippedItem and IsEquippedItem(id) then return true end
  local n = (C_Item and C_Item.GetItemCount and C_Item.GetItemCount(id, true)) or (GetItemCount and GetItemCount(id, true)) or 0
  return n > 0
end

local function AddItemRow(list, it)
  local title, link = ItemTitle(it)
  local alts = {}
  for _, a in ipairs(it.alt or {}) do alts[#alts + 1] = a[1] end
  local have = Owned(it.id)
  list:Add({
    icon = ItemIcon(it.id),
    status = have and UI.STATUS.done or nil,
    title = title,
    sub = "|cffffd100" .. (it.slot or "") .. "|r  " .. (it.source or "") ..
          (#alts > 0 and ("\n|cff808080Alternatives: " .. table.concat(alts, ", ") .. "|r") or ""),
    right = have and (ns.C("good") .. "owned|r") or nil, rightWidth = 50,
    onEnter = function(self)
      if not it.id then return end
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      if GameTooltip.SetItemByID then GameTooltip:SetItemByID(it.id) else GameTooltip:SetHyperlink("item:" .. it.id) end
      GameTooltip:AddLine("Shift-click to link in chat.", 0.5, 0.5, 0.5)
      GameTooltip:Show()
    end,
    onClick = function()
      if IsShiftKeyDown() and link and ChatEdit_InsertLink then ChatEdit_InsertLink(link) end
    end,
  })
end

function render.gear(list)
  local specs = ns.GEAR[ns.player.class] or {}
  local opts = {}
  for name in pairs(specs) do opts[#opts + 1] = { label = name, value = name } end
  table.sort(opts, function(a, b) return a.label < b.label end)
  local chosen = sel.gear or ns.MatchSpec(specs, ns.ActiveSpec())
  if not specs[chosen] and opts[1] then chosen = opts[1].value end
  SetSelector(opts, chosen, function(v) sel.gear = v; ns.Fire("RefreshGuide") end)
  local items = specs[chosen]
  if not items then Header("Gear & BiS", "No gear data for your class."); return end
  Header("Gear: " .. chosen, "Leveling upgrades and pre-raid best in slot. Owned items are ticked. Hover for tooltips.")

  local level = ns.player.level or 1
  local function show(it) return not it.faction or it.faction == ns.player.faction end
  for _, phase in ipairs({ 20, 30, 40, 50 }) do
    local any = false
    for _, it in ipairs(items) do
      if it.phase == phase and show(it) then
        if not any then
          list:Add({ header = true, title = ("Leveling upgrades - around level %d%s"):format(phase,
            (level >= phase - 5 and level < phase + 10) and ("  " .. ns.C("good") .. "(your level)|r") or "") })
          any = true
        end
        AddItemRow(list, it)
      end
    end
  end
  list:Add({ header = true, title = "Pre-raid best in slot (level 60)" })
  for _, it in ipairs(items) do
    if it.phase == "prebis" and show(it) then AddItemRow(list, it) end
  end
end

function render.professions(list)
  local learned = {}
  for _, p in ipairs(ns.profs) do learned[p.name] = p end
  local opts = {}
  for _, p in ipairs(ns.profs) do opts[#opts + 1] = { label = ("%s %d"):format(p.name, p.rank), value = p.name } end
  opts[#opts + 1] = { label = sel.profAll and "Hide others" or "All professions...", value = "__all" }
  if sel.profAll then
    local names = {}
    for name in pairs(ns.PROFESSIONS) do if not learned[name] then names[#names + 1] = name end end
    table.sort(names)
    for _, n in ipairs(names) do table.insert(opts, #opts, { label = n, value = n }) end
  end
  local chosen = sel.prof or (ns.profs[1] and ns.profs[1].name)
  SetSelector(opts, chosen, function(v)
    if v == "__all" then sel.profAll = not sel.profAll else sel.prof = v end
    ns.Fire("RefreshGuide")
  end)
  local guide = chosen and ns.PROFESSIONS[chosen]
  if not guide then
    Header("Professions", #ns.profs == 0 and "You haven't learned any professions yet. Click 'All professions...' to browse guides."
      or "No guide data for this profession.")
    return
  end
  local p = learned[chosen]
  local rank = p and p.rank or 0
  Header(("|T%s:20|t  %s%s"):format(ns.PROF_ICONS[chosen] or ns.KIND_ICONS.profession, chosen,
    p and ("  |cffffffff%d / %d|r"):format(p.rank, p.maxRank) or "  |cff808080(not learned)|r"), guide.summary or "")

  if guide.trainers then
    local t = guide.trainers[ns.player.faction] or guide.trainers.Horde or guide.trainers.Alliance
    if type(t) == "table" then t = table.concat(t, "; ") end
    if t then list:Add({ icon = "Interface\\Icons\\INV_Misc_Book_09", title = "Trainers", sub = t }) end
  end
  if p and p.maxRank > 0 and p.rank >= p.maxRank and p.maxRank < 300 then
    list:Add({ icon = "Interface\\Icons\\Spell_Holy_SealOfWisdom", highlight = true,
      title = ns.C("warn") .. "Skill capped - visit a trainer to raise your max skill.|r" })
  end
  if guide.gather and #guide.gather > 0 then
    list:Add({ header = true, title = "Where to gather" })
    for _, line in ipairs(guide.gather) do list:Add({ title = "• " .. line }) end
  end
  if guide.steps and #guide.steps > 0 then
    list:Add({ header = true, title = "Skill-up path" })
    local _, curI = ns.ProfStep(chosen, rank)
    for i, s in ipairs(guide.steps) do
      local done = rank >= (s.to or 300)
      list:Add({
        status = done and UI.STATUS.done or (p and i == curI and UI.STATUS.current or UI.STATUS.todo),
        icon = s.id and ItemIcon(s.id) or (ns.PROF_ICONS[chosen] or ns.KIND_ICONS.profession),
        title = ("|cffffd100%d-%d|r  %s%s"):format(s.from or 1, s.to or 300, s.craft or "?", s.count and (" x" .. s.count) or ""),
        sub = (s.mats or "") .. (s.note and ("\n|cffaaaaaa" .. s.note .. "|r") or ""),
        dim = done, highlight = p and i == curI,
        onEnter = s.id and function(self)
          GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
          if GameTooltip.SetItemByID then GameTooltip:SetItemByID(s.id) else GameTooltip:SetHyperlink("item:" .. s.id) end
          GameTooltip:Show()
        end or nil,
      })
    end
  end
  if guide.recipes and #guide.recipes > 0 then
    list:Add({ header = true, title = "Notable recipes" })
    for _, line in ipairs(guide.recipes) do list:Add({ title = "• " .. line }) end
  end
  if guide.source then list:Add({ title = "|cff808080Source: " .. guide.source .. "|r" }) end
end

function render.extras(list)
  Header("Gold & Extras", "Gold-making, professions advice, mounts, attunements and more. Click a tip to hide it from the tracker.")
  SetSelector(nil)
  local level = ns.player.level or 1
  local groups = { { "gold", "Gold" }, { "profession", "Professions" }, { "extra", "Extras" } }
  for _, grp in ipairs(groups) do
    local any = false
    for _, t in ipairs(ns.tips) do
      if t.kind == grp[1] then
        if not any then list:Add({ header = true, title = grp[2] }); any = true end
        local inRange = (t.min or 1) <= level and level <= (t.max or 60)
        local hidden = ns.char.done[t.id]
        list:Add({
          icon = ns.KIND_ICONS[t.kind], status = hidden and UI.STATUS.done or nil,
          title = (t.title or "") .. (inRange and ("  " .. ns.C("good") .. "(now)|r") or ""),
          sub = ns.BandText(t) .. "  " .. (t.text or ""),
          dim = hidden or (not inRange), highlight = inRange and not hidden,
          onClick = function() ns.char.done[t.id] = not ns.char.done[t.id] or nil; ns.Fire("Refresh") end,
        })
      end
    end
  end
  -- Mount steps live in the route; list them here as well.
  local anyMount = false
  for _, s in ipairs(ns.route) do
    if s.kind == "mount" then
      if not anyMount then list:Add({ header = true, title = "Mounts" }); anyMount = true end
      list:Add({ icon = ns.KIND_ICONS.mount, status = ns.StepState(s) and UI.STATUS.done or nil,
                 title = s.title or "", sub = ns.BandText(s) .. "  " .. (s.text or "") })
    end
  end
end

function render.dungeons(list)
  Header("Dungeons", "Dungeons on your route. Highlighted ones match your level.")
  SetSelector(nil)
  local level = ns.player.level or 1
  if ForeverDungeonJournal_OnAddonCompartmentClick then
    list:Add({ icon = "Interface\\Icons\\INV_Misc_Book_09", title = "|cffffd100Open the Dungeon Journal|r",
      sub = "Bosses, loot and dungeon quests (ForeverDungeonJournal addon).", highlight = true,
      onClick = function() ForeverDungeonJournal_OnAddonCompartmentClick(ADDON, "LeftButton") end })
  end
  for _, s in ipairs(ns.route) do
    if s.kind == "dungeon" then
      local inRange = (s.min or 1) <= level and level <= (s.max or 60)
      list:Add({ icon = ns.KIND_ICONS.dungeon, title = (s.title or "") .. (inRange and ("  " .. ns.C("good") .. "(your level)|r") or ""),
        sub = ns.BandText(s) .. "  |cffaaaaaa" .. (s.zone or "") .. "|r\n" .. (s.text or ""),
        dim = level > (s.max or 60) + 3, highlight = inRange,
        onClick = function() if s.wp then ns.Fire("SetWaypoints", s, true) end end })
    end
  end
end
---------------------------------------------------------------------------
-- Settings (grouped, scrollable). Built into the guide's Settings tab and into the
-- game's Options > AddOns page; both copies read the same saved values when shown.
---------------------------------------------------------------------------
StaticPopupDialogs["COFFEYGUIDE_RESET"] = {
  text = "Clear this character's guide progress?\n\nSteps you have really finished tick themselves off again from your quest history. Manual checkmarks and skipped steps are lost.",
  button1 = "Reset", button2 = CANCEL or "Cancel",
  OnAccept = function() ns.ResetProgress() end,
  timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

local function ConfirmReset()
  if StaticPopup_Show then StaticPopup_Show("COFFEYGUIDE_RESET") else ns.ResetProgress() end
end

local SECTIONS = {
  { "Tracker", {
    { "combatFade", "Fade the tracker in combat" },
    { "instanceHide", "Compact in dungeons, hidden in raids and battlegrounds" },
    { "mouseoverFade", "Fade the tracker until you mouse over it" },
    { "toasts", "Level-up popups (talent, new spells, next step)" },
    { "lock", "Lock the tracker, arrow and popup in place" },
  } },
  { "Route and detection", {
    { "suggest", "Offer to jump ahead when your quest log shows you're further along",
      "Looks at your quest log, completed quests and current zone. The guide only asks; a jump can be undone." },
    { "autoSkip", "Treat steps you've outleveled by 4+ levels as done" },
    { "showOptional", "Show optional steps (dungeons, side content)" },
  } },
  { "Waypoints", {
    { "autoWaypoint", "Set waypoints for the current objective automatically" },
    { "arrow", "Show the built-in direction arrow (when TomTom isn't used)" },
    { "pins", "Show waypoints on the world map and minimap" },
    { "useTomTom", "Use TomTom's arrow and waypoints when installed" },
  } },
  { "Talents and gear", {
    { "talentGlow", "Highlight the next talent in the talent window" },
    { "gearAdvisor", "Upgrade % in item tooltips and a popup for bag upgrades" },
    { "rewardHints", "Recommend the best quest reward (upgrade, else highest sell value)" },
  } },
  { "Automation (hold Shift to bypass)", {
    { "autoAccept", "Auto-accept quests", "Leave this off if DialogueUI or Immersion already automates quests." },
    { "autoTurnIn", "Auto turn in completed quests when there's no reward choice" },
    { "sellGreys", "Sell gray items at vendors" },
    { "autoRepair", "Repair at vendors" },
  } },
  { "Accessibility, chat and add-ons", {
    { "accentGold", "Gold accent color instead of your class color" },
    { "colorblind", "Colorblind-friendly colors (blue for done, orange for problems)" },
    { "quiet", "Fewer chat messages (no login line, no level-up text when popups are on)" },
    { "useQuestie", "Use Questie's database (if installed) for quest NPC locations" },
  } },
}

function ns.BuildSettings(parent)
  local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 0, 0)
  scroll:SetPoint("BOTTOMRIGHT", -26, 0)
  local c = CreateFrame("Frame", nil, scroll)
  c:SetSize(560, 900)
  scroll:SetScrollChild(c)

  local function changed() ns.Fire("SettingsChanged") end
  local y = 0

  -- Tracker layout first: it's the setting people look for.
  local t = UI.Section(c, "Tracker layout"); t:SetPoint("TOPLEFT", 0, -y); y = y + 24
  local seg = UI.Segmented(c, {
    { label = "Standard", value = "standard", tip = "The step, your next few objectives and the buttons. Talent hints only when there's a point to spend." },
    { label = "Detailed", value = "detailed", tip = "Everything: step text, quest checklist, a longer objective list and level tips." },
  }, function() return ns.db.density end, function(v) ns.db.density = v; changed() end)
  seg:SetPoint("TOPLEFT", 0, -y)
  local compact = UI.Check(c, "Compact (just the next action)", function() return ns.db.compact end,
    function(v) ns.db.compact = v; changed() end, "The minus button on the tracker and a key binding switch this too.")
  compact:SetPoint("LEFT", seg, "RIGHT", 16, 0)
  y = y + 32
  local scale = UI.Slider(c, "Tracker size", 170, 0.6, 1.6, 0.05, function() return ns.db.scale or 1 end,
    function(v) ns.db.scale = v; changed() end, function(v) return ("%d%%"):format(v * 100 + 0.5) end)
  scale:SetPoint("TOPLEFT", 4, -y)
  local font = UI.Slider(c, "Text size", 170, 0.8, 1.4, 0.05, function() return ns.db.fontScale or 1 end,
    function(v) ns.db.fontScale = v; changed() end, function(v) return ("%d%%"):format(v * 100 + 0.5) end)
  font:SetPoint("TOPLEFT", 194, -y)
  local bg = UI.Slider(c, "Background", 170, 0, 1, 0.05, function() return ns.db.bgAlpha or 0.9 end,
    function(v) ns.db.bgAlpha = v; changed() end, function(v) return ("%d%%"):format(v * 100 + 0.5) end)
  bg:SetPoint("TOPLEFT", 384, -y)
  y = y + 48

  for _, sec in ipairs(SECTIONS) do
    local h = UI.Section(c, sec[1]); h:SetPoint("TOPLEFT", 0, -y); y = y + 22
    for i, o in ipairs(sec[2]) do
      local cb = UI.Check(c, o[2], function() return ns.db[o[1]] end, function(v) ns.db[o[1]] = v; changed() end, o[3])
      cb.label:SetFontObject(UI.Font("GameFontHighlightSmall")); cb:SetLabelWidth(240)
      local col = (i - 1) % 2
      cb:SetPoint("TOPLEFT", col * 285, -y)
      if col == 1 or i == #sec[2] then y = y + 30 end
    end
    if sec[1] == "Accessibility, chat and add-ons" then
      local mm = UI.Check(c, "Minimap button", function() return not ns.db.minimap.hide end,
        function(v) ns.db.minimap.hide = not v; ns.Fire("MinimapChanged") end)
      mm.label:SetFontObject(UI.Font("GameFontHighlightSmall"))
      mm:SetPoint("TOPLEFT", 0, -y); y = y + 30
    end
    y = y + 6
  end

  local h = UI.Section(c, "Progress and help"); h:SetPoint("TOPLEFT", 0, -y); y = y + 24
  local welcome = UI.Button(c, "Show welcome", 120, function() ns.Fire("ShowWelcome", true) end)
  welcome:SetPoint("TOPLEFT", 0, -y)
  local sync = UI.Button(c, "Re-read quest history", 160, function() ns.SyncHistory(true) end)
  sync:SetPoint("LEFT", welcome, "RIGHT", 6, 0)
  local reset = UI.Button(c, "Reset route progress...", 170, ConfirmReset)
  reset:SetPoint("LEFT", sync, "RIGHT", 6, 0)
  y = y + 28
  local pos = UI.Button(c, "Reset window positions", 170, function() SlashCmdList.COFFEYGUIDE("resetpos") end)
  pos:SetPoint("TOPLEFT", 0, -y)
  local site = UI.Button(c, "coffeylabs.org", 120, function() ns.ShowLink(ns.WEBSITE) end)
  site:SetPoint("LEFT", pos, "RIGHT", 6, 0)
  local support = UI.Button(c, "Support Coffey Labs", 150, function() ns.ShowLink(ns.SUPPORT) end)
  support:SetPoint("LEFT", site, "RIGHT", 6, 0)
  UI.Tooltip(support, "Support Coffey Labs", "Coffey's Leveling Guide is free. Click to copy the link to our funding options (" .. ns.SUPPORT .. ").")
  y = y + 34
  local info = UI.Text(c, "GameFontDisableSmall")
  info:SetPoint("TOPLEFT", 0, -y); info:SetWidth(540)
  info:SetText("Coffey's Leveling Guide by Coffey Labs LLC - " .. ns.WEBSITE ..
    "\nKey bindings: Options > Keybindings > AddOns > Coffey's Leveling Guide." ..
    "\nCommands: /cguide (toggle tracker), /cguide guide, quests, talents, spec, gear, prof, gold, dungeons, settings, next, prev, check, compact, wp, sync, welcome, reset, resetpos, talentdebug, support." ..
    "\nData: wowhandbook.com, icy-veins.com, warcrafttavern.com, warcraftmaps.com, topbuilds.gg and Blizzard's hotfix notes (Nov 2026). Level bands are approximate.")
  y = y + info:GetStringHeight() + 20
  c:SetHeight(y)
  return scroll
end

-- Options > AddOns page.
local function RegisterOptions()
  local panel = CreateFrame("Frame")
  panel.name = "Coffey's Leveling Guide"
  local title = UI.Text(panel, "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16); title:SetText("Coffey's Leveling Guide")
  local open = UI.Button(panel, "Open the full guide", 150, function()
    if SettingsPanel and SettingsPanel.Close then pcall(SettingsPanel.Close, SettingsPanel, true)
    elseif HideUIPanel and SettingsPanel then HideUIPanel(SettingsPanel) end
    ns.Fire("OpenGuide", "route")
  end)
  open:SetPoint("TOPRIGHT", -16, -14)
  local body = CreateFrame("Frame", nil, panel)
  body:SetPoint("TOPLEFT", 16, -48); body:SetPoint("BOTTOMRIGHT", -10, 10)
  panel:SetScript("OnShow", function(self)
    if not self.built then self.built = true; ns.BuildSettings(body) end
  end)
  if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
    local cat = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(cat)
    ns.optionsCategory = cat
  elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
  end
end

local settingsFrame
local function ShowSettingsTab()
  if not settingsFrame then
    settingsFrame = CreateFrame("Frame", nil, g.content)
    settingsFrame:SetPoint("TOPLEFT", 0, -50)
    settingsFrame:SetPoint("BOTTOMRIGHT")
    ns.BuildSettings(settingsFrame)
  end
  settingsFrame:Show()
end

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------
local scrollToCurrent = false

local function Render()
  if not g or not g:IsShown() then return end
  local ar, ag, ab = UI.Accent()
  for _, t in ipairs(g.tabButtons) do
    local on = t.key == currentTab
    t.bg:SetColorTexture(ar, ag, ab, on and 0.16 or 0)
    t.bar:SetColorTexture(ar, ag, ab, 1); t.bar:SetShown(on)
    t.text:SetTextColor(on and 1 or 0.72, on and 1 or 0.72, on and 1 or 0.72)
    t.icon:SetDesaturated(not on); t.icon:SetAlpha(on and 1 or 0.75)
  end
  local isSettings = currentTab == "settings"
  g.listHolder:SetShown(not isSettings)
  g.search:SetShown(not isSettings)
  if isSettings then
    for _, pool in ipairs(selButtons) do for _, b in ipairs(pool) do b:Hide() end end
    Header("Settings", "Changes apply right away. The same page is under Options > AddOns.")
    ShowSettingsTab()
    return
  end
  if settingsFrame then settingsFrame:Hide() end
  g.list:Clear()
  g.list:SetFilter(g.search:GetText())
  render[currentTab](g.list)
  g.list:Done()
  if scrollToCurrent then
    scrollToCurrent = false
    if currentTab == "route" and not g.list.filter then
      local list = g.list
      C_Timer.After(0, function() list:ScrollToMark("current", 80) end)
    else
      g.list.scroll:SetVerticalScroll(0)
    end
  end
end

local function SaveGuideLayout()
  local left, top = g:GetLeft(), g:GetTop()
  if left and top then ns.db.guidePos = { left, top } end
  local w, h = g:GetWidth(), g:GetHeight()
  if w and h and w > 0 then ns.db.guideSize = { w, h } end
end

local function Create()
  local size = ns.db.guideSize
  g = UI.Panel("CoffeyGuideWindow", UIParent, size and size[1] or 760, size and size[2] or 580)
  if ns.db.guidePos then g:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", ns.db.guidePos[1], ns.db.guidePos[2])
  else g:SetPoint("CENTER") end
  g:SetFrameStrata("HIGH")
  g:SetClampedToScreen(true)
  g:SetMovable(true); g:EnableMouse(true); g:RegisterForDrag("LeftButton")
  g:SetScript("OnDragStart", g.StartMoving)
  g:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); SaveGuideLayout() end)
  g:SetResizable(true)
  if g.SetResizeBounds then g:SetResizeBounds(760, 460, 1600, 1200)
  elseif g.SetMinResize then g:SetMinResize(760, 460) end
  g:Hide()
  tinsert(UISpecialFrames, "CoffeyGuideWindow") -- close with Escape

  local logo = g:CreateTexture(nil, "ARTWORK")
  logo:SetSize(30, 30); logo:SetPoint("TOPLEFT", 12, -10)
  UI.ClassIcon(logo, ns.player.class)
  local name = UI.Text(g, "GameFontNormalLarge")
  name:SetPoint("LEFT", logo, "RIGHT", 8, 0)
  name:SetText("Coffey's Leveling Guide")
  local credit = CreateFrame("Button", nil, g)
  credit:SetPoint("LEFT", name, "RIGHT", 10, -1)
  credit.text = UI.Text(credit, "GameFontHighlightSmall")
  credit.text:SetPoint("LEFT")
  credit.text:SetText("by |cffffd100Coffey Labs LLC|r  |cff66bbffcoffeylabs.org|r")
  credit:SetSize(credit.text:GetStringWidth() + 4, 16)
  credit:SetScript("OnClick", function() ns.ShowLink(ns.WEBSITE) end)
  UI.Tooltip(credit, "Coffey Labs LLC", "Click to copy the website link (" .. ns.WEBSITE .. ").")
  UI.CloseButton(g)
  UI.FadeIn(g)

  -- Search: filters the rows of whichever tab is open.
  local ok, box = pcall(CreateFrame, "EditBox", "CoffeyGuideSearch", g, "SearchBoxTemplate")
  if not ok or not box then box = CreateFrame("EditBox", "CoffeyGuideSearch", g, "InputBoxTemplate") end
  box:SetSize(190, 20)
  box:SetPoint("TOPRIGHT", g, "TOPRIGHT", -36, -15)
  box:SetAutoFocus(false)
  if type(box.Instructions) == "table" then box.Instructions:SetText("Search this tab") end
  box:HookScript("OnTextChanged", function() scrollToCurrent = true; Render() end)
  box:HookScript("OnEscapePressed", function(self) self:ClearFocus() end)
  box:HookScript("OnEnterPressed", function(self) self:ClearFocus() end)
  UI.Tooltip(box, "Search", "Filter steps, quests, talents, items and tips on this tab.")
  g.search = box

  -- Left navigation.
  g.tabButtons = {}
  for i, t in ipairs(TABS) do
    local b = CreateFrame("Button", nil, g)
    b:SetSize(150, 30)
    b:SetPoint("TOPLEFT", 10, -56 - (i - 1) * 32)
    b.bg = b:CreateTexture(nil, "BACKGROUND"); b.bg:SetAllPoints()
    UI.Hover(b, 0.05)
    b.bar = b:CreateTexture(nil, "BORDER"); b.bar:SetPoint("TOPLEFT"); b.bar:SetPoint("BOTTOMLEFT"); b.bar:SetWidth(3)
    b.icon = UI.Icon(b, 22, t.icon); b.icon:SetPoint("LEFT", 10, 0)
    UI.IconBorder(b.icon)
    b.text = UI.Text(b, "GameFontNormal"); b.text:SetPoint("LEFT", b.icon, "RIGHT", 8, 0); b.text:SetText(t.label)
    b.key = t.key
    b:SetScript("OnClick", function() currentTab = t.key; scrollToCurrent = true; Render() end)
    g.tabButtons[i] = b
  end

  -- Header divider: the title bar keeps its own strip above the tabs and content.
  local headerLine = g:CreateTexture(nil, "ARTWORK")
  headerLine:SetColorTexture(1, 1, 1, 0.08)
  headerLine:SetPoint("TOPLEFT", g, "TOPLEFT", 10, -48); headerLine:SetPoint("TOPRIGHT", g, "TOPRIGHT", -10, -48)
  headerLine:SetHeight(1)

  -- Content area.
  g.content = CreateFrame("Frame", nil, g)
  g.content:SetPoint("TOPLEFT", 172, -56)
  g.content:SetPoint("BOTTOMRIGHT", -12, 18)
  local sep = g:CreateTexture(nil, "ARTWORK")
  sep:SetColorTexture(1, 1, 1, 0.08)
  sep:SetPoint("TOPLEFT", g, "TOPLEFT", 166, -52); sep:SetPoint("BOTTOMLEFT", g, "BOTTOMLEFT", 166, 12); sep:SetWidth(1)

  g.title = UI.Text(g.content, "GameFontNormalLarge")
  g.title:SetPoint("TOPLEFT", 0, 0); g.title:SetPoint("RIGHT", g.content, "RIGHT", 0, 0)
  g.sub = UI.Text(g.content, "GameFontHighlightSmall")
  g.sub:SetPoint("TOPLEFT", g.title, "BOTTOMLEFT", 0, -4); g.sub:SetPoint("RIGHT", g.content, "RIGHT", 0, 0)

  g.listHolder = CreateFrame("Frame", nil, g.content)
  g.listHolder:SetPoint("TOPLEFT", 0, -48); g.listHolder:SetPoint("BOTTOMRIGHT")
  g.list = UI.ScrollList(g.listHolder)
  g.list.scroll:SetPoint("TOPLEFT", 0, 0)
  g.list.scroll:SetPoint("BOTTOMRIGHT", -26, 0)

  -- Resize grip.
  local grip = CreateFrame("Button", nil, g)
  grip:SetSize(16, 16); grip:SetPoint("BOTTOMRIGHT", -4, 4)
  grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  grip:SetScript("OnMouseDown", function() g:StartSizing("BOTTOMRIGHT") end)
  grip:SetScript("OnMouseUp", function() g:StopMovingOrSizing(); SaveGuideLayout(); Render() end)
  UI.Tooltip(grip, "Resize", "Drag to resize the guide.")

  g:HookScript("OnShow", function() scrollToCurrent = true; Render() end)

  -- Item data arrives asynchronously; re-render the gear tab when it does.
  local pending = false
  g:RegisterEvent("GET_ITEM_INFO_RECEIVED")
  g:SetScript("OnEvent", function()
    if currentTab ~= "gear" and currentTab ~= "professions" then return end
    if pending then return end
    pending = true
    C_Timer.After(0.5, function() pending = false; Render() end)
  end)
end

local TAB_ALIASES = { talents = { "class", "talents" }, spec = { "class", "spec" } }

ns.On("Login", function() Create(); RegisterOptions() end)
ns.On("OpenGuide", function(tab)
  if not g then return end
  local alias = tab and TAB_ALIASES[tab]
  if alias then tab = alias[1]; sel.classView = alias[2] end
  if tab then currentTab = tab; scrollToCurrent = true end
  if g:IsShown() and not tab then g:Hide() else g:Show(); Render() end
end)
ns.On("Refresh", Render)
ns.On("RefreshGuide", Render)
ns.On("SettingsChanged", Render)
ns.On("ResetPosition", function()
  if not g then return end
  ns.db.guidePos, ns.db.guideSize = nil, nil
  g:ClearAllPoints(); g:SetPoint("CENTER"); g:SetSize(760, 580)
end)
