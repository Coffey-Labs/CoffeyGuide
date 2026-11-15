-- ForeverGuide: the full guide window (route, talents, spec, gear, professions, gold & extras, dungeons, settings).
local ADDON, ns = ...
local UI = ns.UI
local g -- window
local currentTab = "route"
local sel = {} -- per-tab selector choice

local TABS = {
  { key = "route",       label = "Route",          icon = "Interface\\Icons\\INV_Misc_Map_01" },
  { key = "questlog",    label = "Quest Log",      icon = "Interface\\Icons\\INV_Misc_Note_06" },
  { key = "talents",     label = "Talents",        icon = "Interface\\Icons\\Ability_Marksmanship" },
  { key = "spec",        label = "Spec Guide",     icon = "Interface\\Icons\\INV_Misc_Book_11" },
  { key = "gear",        label = "Gear & BiS",     icon = "Interface\\Icons\\INV_Chest_Plate06" },
  { key = "professions", label = "Professions",    icon = "Interface\\Icons\\Trade_BlackSmithing" },
  { key = "extras",      label = "Gold & Extras",  icon = "Interface\\Icons\\INV_Misc_Coin_01" },
  { key = "dungeons",    label = "Dungeons",       icon = "Interface\\Icons\\INV_Misc_Bone_ElfSkull_01" },
  { key = "settings",    label = "Settings",       icon = "Interface\\Icons\\Trade_Engineering" },
}

---------------------------------------------------------------------------
-- Selector row (pooled small buttons)
---------------------------------------------------------------------------
local selButtons = {}
local function SetSelector(options, current, onPick)
  for _, b in ipairs(selButtons) do b:Hide() end
  local x = 0
  for i, opt in ipairs(options or {}) do
    local b = selButtons[i]
    if not b then
      b = CreateFrame("Button", nil, g.content, "UIPanelButtonTemplate")
      b:SetHeight(22)
      selButtons[i] = b
    end
    b:SetText(opt.label)
    b:SetWidth(math.max(70, b:GetFontString():GetStringWidth() + 24))
    b:ClearAllPoints()
    b:SetPoint("TOPLEFT", g.content, "TOPLEFT", x, -46)
    x = x + b:GetWidth() + 4
    local active = opt.value == current
    b:GetFontString():SetTextColor(active and 1 or 0.7, active and 0.82 or 0.7, active and 0 or 0.7)
    b:SetScript("OnClick", function() onPick(opt.value) end)
    b:Show()
  end
  g.listHolder:ClearAllPoints()
  g.listHolder:SetPoint("TOPLEFT", g.content, "TOPLEFT", 0, (options and #options > 0) and -74 or -48)
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
      local status = state == "skipped" and UI.STATUS.skipped or state and UI.STATUS.done
                  or (i == cur and UI.STATUS.current or UI.STATUS.todo)
      local icon, coords = ns.KIND_ICONS[step.kind] or ns.KIND_ICONS.quest, nil
      if step.kind == "class" then
        icon = "Interface\\TargetingFrame\\UI-Classes-Circles"
        local c = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[ns.player.class]
        if c then coords = { c[1], c[2], c[3], c[4] } end
      end
      list:Add({
        status = status, icon = icon, iconCoords = coords, dim = state ~= nil,
        title = (step.title or "?") .. (step.optional and "  |cff8080ff(optional)|r" or ""),
        sub = ns.BandText(step) .. "  |cffaaaaaa" .. (step.zone or "") .. "|r" .. ZoneStatText(step) .. "\n" .. (step.text or ""),
        right = i == cur and "|cffffd100CURRENT|r" or (i == view and "|cff8080ffviewing|r" or nil),
        rightWidth = 70,
        highlight = i == cur,
        onClick = function() ns.SetView(i); ns.Fire("ToggleTracker", true); ns.char.view = i; ns.Fire("Refresh") end,
        onEnter = function(self)
          GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
          GameTooltip:AddLine(step.title or "", 1, 0.82, 0)
          GameTooltip:AddLine(step.text or "", 1, 1, 1, true)
          for _, q in ipairs(step.quests or {}) do
            local name = type(q) == "table" and q[1] or q
            local d = ns.IsQuestDone(q)
            GameTooltip:AddLine((d and "|cff4ce64c[done]|r " or "|cff808080[todo]|r ") .. name, 1, 1, 1)
          end
          GameTooltip:AddLine("Click to show this step in the tracker.", 0.5, 0.5, 0.5)
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
  Header("Quest Log", ("%d quests, |cff4ce64c%d ready to turn in|r. Click a quest for a waypoint%s.")
    :format(total, ready, (QuestieLoader and ns.db.useQuestie) and " (turn-in NPC via Questie)" or ""))
  SetSelector(nil)
  -- Ready-to-turn-in first, then by zone.
  local readyList = {}
  for _, gr in ipairs(groups) do for _, q in ipairs(gr.quests) do if q.complete then readyList[#readyList + 1] = q end end end
  local function addQuest(q)
    local objs = {}
    for _, o in ipairs(q.objectives) do objs[#objs + 1] = (o.done and "|cff4ce64c" or "|cffcccccc") .. (o.text or "") .. "|r" end
    local diff = GetQuestDifficultyColor and GetQuestDifficultyColor(q.level or 1) or { r = 1, g = 1, b = 1 }
    list:Add({
      status = q.complete and UI.STATUS.done or (q.failed and UI.STATUS.skipped or UI.STATUS.current),
      icon = q.complete and ns.ACT_ICONS.turnin or ns.ACT_ICONS.accept,
      title = ("|cff%02x%02x%02x[%d]|r %s"):format(diff.r * 255, diff.g * 255, diff.b * 255, q.level or 0, q.title),
      sub = q.complete and "|cff4ce64cReady to turn in|r" or table.concat(objs, "\n"),
      highlight = q.complete,
      onClick = function()
        local wp = q.id and ns.QuestieWaypoint(q.id, "finish")
        if q.complete and wp then
          ns.Fire("SetWaypoints", { id = "ql:" .. q.id, title = q.title, wp = { wp } }, true)
        elseif not q.complete then
          ns.Print("Objective locations need Questie (or check your map). Turn-in arrow appears once it's complete.")
        else
          ns.Print("No turn-in location known for " .. q.title .. ".")
        end
      end,
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
    for i, s in ipairs(plan) do
      local done = ns.SubDone(step, s)
      list:Add({ status = done and UI.STATUS.done or (i == first and UI.STATUS.current or UI.STATUS.todo),
        icon = ns.ACT_ICONS[s.act] or ns.ACT_ICONS.note, title = ns.SubText(s), dim = done, highlight = i == first,
        onClick = function() ns.MarkSub(step, s, not done) end })
    end
  end
end

function render.talents(list)
  local builds = ns.GetBuilds()
  local build, auto = ns.GetActiveBuild()
  local opts = { { label = "Auto-detect", value = "__auto" } }
  for _, b in ipairs(builds) do opts[#opts + 1] = { label = b.name, value = b.key } end
  SetSelector(opts, ns.char.build or "__auto", function(v)
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
        sub = (plan[3] or "") .. ((L == build.respecAt) and "  |cffff8040RESPEC here (see summary)|r" or "")
              .. (info and "" or "  |cffff4040(talent name not found in your talent tree)|r"),
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

function render.spec(list)
  local guides = ns.SPECGUIDES[ns.player.class] or {}
  local opts = {}
  for name in pairs(guides) do opts[#opts + 1] = { label = name, value = name } end
  table.sort(opts, function(a, b) return a.label < b.label end)
  local chosen = sel.spec or ns.MatchSpec(guides, ns.ActiveSpec())
  if not guides[chosen] and opts[1] then chosen = opts[1].value end
  SetSelector(opts, chosen, function(v) sel.spec = v; ns.Fire("RefreshGuide") end)
  local sg = guides[chosen]
  if not sg then Header("Spec Guide", "No spec guide data for your class."); return end
  local best = {}
  for k, v in pairs(sg.best or {}) do if v then best[#best + 1] = k end end
  table.sort(best)
  Header(chosen .. "  |cffaaaaaa" .. (sg.role or "") .. "|r",
    #best > 0 and ("Best for: |cff4ce64c" .. table.concat(best, ", ") .. "|r") or "")
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
    right = have and "|cff4ce64cowned|r" or nil, rightWidth = 50,
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
            (level >= phase - 5 and level < phase + 10) and "  |cff4ce64c(your level)|r" or "") })
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
      title = "|cffff8040Skill capped - visit a trainer to raise your max skill.|r" })
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
          title = (t.title or "") .. (inRange and "  |cff4ce64c(now)|r" or ""),
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
      list:Add({ icon = ns.KIND_ICONS.dungeon, title = (s.title or "") .. (inRange and "  |cff4ce64c(your level)|r" or ""),
        sub = ns.BandText(s) .. "  |cffaaaaaa" .. (s.zone or "") .. "|r\n" .. (s.text or ""),
        dim = level > (s.max or 60) + 3, highlight = inRange,
        onClick = function() if s.wp then ns.Fire("SetWaypoints", s, true) end end })
    end
  end
end

---------------------------------------------------------------------------
-- Settings tab (separate frame, not a list)
---------------------------------------------------------------------------
local settingsFrame
local function BuildSettings()
  settingsFrame = CreateFrame("Frame", nil, g.content)
  settingsFrame:SetPoint("TOPLEFT", 0, -50)
  settingsFrame:SetPoint("BOTTOMRIGHT")
  local opts = {
    { "arrow", "Show the built-in direction arrow (when TomTom isn't used)" },
    { "pins", "Show waypoints on the world map and minimap" },
    { "autoWaypoint", "Automatically set waypoints for the current step" },
    { "useTomTom", "Use TomTom's arrow and waypoints when installed" },
    { "toasts", "Show level-up popups (talent, spells, next step)" },
    { "talentGlow", "Highlight the next talent in the talent window" },
    { "autoSkip", "Treat steps you've outleveled by 4+ levels as done" },
    { "showOptional", "Show optional steps (dungeons, side content)" },
    { "lock", "Lock tracker and arrow position" },
    { "gearAdvisor", "Gear advisor: upgrade % on tooltips + popup for bag upgrades" },
    { "rewardHints", "Recommend the best quest reward (upgrade, else highest sell value)" },
    { "autoAccept", "Auto-accept quests (hold Shift to skip) - off if you use DialogueUI/Immersion automation" },
    { "autoTurnIn", "Auto turn in completed quests when there's no reward choice" },
    { "sellGreys", "Auto-sell grey items at vendors" },
    { "autoRepair", "Auto-repair at vendors" },
    { "useQuestie", "Use Questie's database (if installed) for quest NPC locations" },
  }
  local y = 0
  local perCol = math.ceil(#opts / 2)
  for i, o in ipairs(opts) do
    local cb = UI.Check(settingsFrame, o[2], function() return ns.db[o[1]] end,
      function(v) ns.db[o[1]] = v; ns.Fire("SettingsChanged") end)
    cb.label:SetWidth(245); cb.label:SetFontObject("GameFontHighlightSmall")
    local col, row = (i > perCol) and 1 or 0, (i - 1) % perCol
    cb:SetPoint("TOPLEFT", col * 285, -row * 32)
  end
  y = perCol * 32 + 6
  local mm = UI.Check(settingsFrame, "Show minimap button", function() return not ns.db.minimap.hide end,
    function(v) ns.db.minimap.hide = not v; ns.Fire("MinimapChanged") end)
  mm:SetPoint("TOPLEFT", 0, -y); y = y + 36

  local scaleText = UI.Text(settingsFrame, "GameFontHighlight")
  scaleText:SetPoint("TOPLEFT", 4, -y)
  local function upd() scaleText:SetText(("Tracker scale: %.0f%%"):format((ns.db.scale or 1) * 100)) end
  upd()
  local minus = UI.Button(settingsFrame, "-", 26, function() ns.db.scale = math.max(0.6, (ns.db.scale or 1) - 0.1); upd(); ns.Fire("SettingsChanged") end)
  minus:SetPoint("LEFT", scaleText, "RIGHT", 10, 0)
  local plus = UI.Button(settingsFrame, "+", 26, function() ns.db.scale = math.min(1.6, (ns.db.scale or 1) + 0.1); upd(); ns.Fire("SettingsChanged") end)
  plus:SetPoint("LEFT", minus, "RIGHT", 2, 0)
  y = y + 40

  local reset = UI.Button(settingsFrame, "Reset route progress", 170, function() SlashCmdList.FOREVERGUIDE("reset") end)
  reset:SetPoint("TOPLEFT", 0, -y)
  local site = UI.Button(settingsFrame, "coffeylabs.org", 120, function() ns.ShowLink(ns.WEBSITE) end)
  local pos = UI.Button(settingsFrame, "Reset tracker position", 170, function() SlashCmdList.FOREVERGUIDE("resetpos") end)
  pos:SetPoint("LEFT", reset, "RIGHT", 8, 0)
  site:SetPoint("LEFT", pos, "RIGHT", 8, 0)
  y = y + 36
  local info = UI.Text(settingsFrame, "GameFontDisableSmall")
  info:SetPoint("TOPLEFT", 0, -y); info:SetWidth(520)
  info:SetText("ForeverGuide by Coffey Labs LLC - " .. ns.WEBSITE .. "\nCommands: /fg (toggle tracker), /fg guide, /fg quests, /fg talents, /fg spec, /fg gear, /fg prof, /fg gold, /fg dungeons, /fg sync, /fg wp, /fg next, /fg prev, /fg reset.\nData: wowhandbook.com, icy-veins.com, warcrafttavern.com, warcraftmaps.com, topbuilds.gg (Nov 2026). Level bands are approximate.")
end

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------
local function Render()
  if not g or not g:IsShown() then return end
  for _, t in ipairs(g.tabButtons) do
    local on = t.key == currentTab
    t.bg:SetColorTexture(1, 0.82, 0, on and 0.18 or 0)
    t.text:SetTextColor(on and 1 or 0.85, on and 0.82 or 0.85, on and 0 or 0.85)
  end
  local isSettings = currentTab == "settings"
  g.listHolder:SetShown(not isSettings)
  if isSettings then
    for _, b in ipairs(selButtons) do b:Hide() end
    Header("Settings", "")
    if not settingsFrame then BuildSettings() end
    settingsFrame:Show()
    return
  end
  if settingsFrame then settingsFrame:Hide() end
  g.list:Clear()
  render[currentTab](g.list)
  g.list:Done()
end

local function Create()
  g = UI.Panel("ForeverGuideWindow", UIParent, 760, 540)
  g:SetPoint("CENTER")
  g:SetFrameStrata("HIGH")
  g:SetClampedToScreen(true)
  g:SetMovable(true); g:EnableMouse(true); g:RegisterForDrag("LeftButton")
  g:SetScript("OnDragStart", g.StartMoving)
  g:SetScript("OnDragStop", g.StopMovingOrSizing)
  g:Hide()
  tinsert(UISpecialFrames, "ForeverGuideWindow") -- close with Escape

  local logo = g:CreateTexture(nil, "ARTWORK")
  logo:SetSize(30, 30); logo:SetPoint("TOPLEFT", 12, -10)
  UI.ClassIcon(logo, ns.player.class)
  local name = UI.Text(g, "GameFontNormalLarge")
  name:SetPoint("LEFT", logo, "RIGHT", 8, 0)
  name:SetText("ForeverGuide")
  local credit = CreateFrame("Button", nil, g)
  credit:SetPoint("LEFT", name, "RIGHT", 10, -1)
  credit.text = UI.Text(credit, "GameFontHighlightSmall")
  credit.text:SetPoint("LEFT")
  credit.text:SetText("by |cffffd100Coffey Labs LLC|r  |cff66bbffcoffeylabs.org|r")
  credit:SetSize(credit.text:GetStringWidth() + 4, 16)
  credit:SetScript("OnClick", function() ns.ShowLink(ns.WEBSITE) end)
  UI.Tooltip(credit, "Coffey Labs LLC", "Click to copy the website link (" .. ns.WEBSITE .. ").")
  local close = CreateFrame("Button", nil, g, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 2, 2)

  -- Left navigation.
  g.tabButtons = {}
  for i, t in ipairs(TABS) do
    local b = CreateFrame("Button", nil, g)
    b:SetSize(150, 30)
    b:SetPoint("TOPLEFT", 10, -48 - (i - 1) * 32)
    b.bg = b:CreateTexture(nil, "BACKGROUND"); b.bg:SetAllPoints()
    b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    b.icon = UI.Icon(b, 24, t.icon); b.icon:SetPoint("LEFT", 4, 0)
    b.text = UI.Text(b, "GameFontNormal"); b.text:SetPoint("LEFT", b.icon, "RIGHT", 8, 0); b.text:SetText(t.label)
    b.key = t.key
    b:SetScript("OnClick", function() currentTab = t.key; Render() end)
    g.tabButtons[i] = b
  end

  -- Content area.
  g.content = CreateFrame("Frame", nil, g)
  g.content:SetPoint("TOPLEFT", 172, -14)
  g.content:SetPoint("BOTTOMRIGHT", -12, 12)
  local sep = g:CreateTexture(nil, "ARTWORK")
  sep:SetColorTexture(0.55, 0.45, 0.25, 0.6)
  sep:SetPoint("TOPLEFT", g, "TOPLEFT", 166, -44); sep:SetPoint("BOTTOMLEFT", g, "BOTTOMLEFT", 166, 12); sep:SetWidth(1)

  g.title = UI.Text(g.content, "GameFontNormalLarge")
  g.title:SetPoint("TOPLEFT", 0, 0); g.title:SetWidth(540)
  g.sub = UI.Text(g.content, "GameFontHighlightSmall")
  g.sub:SetPoint("TOPLEFT", g.title, "BOTTOMLEFT", 0, -4); g.sub:SetWidth(550)

  g.listHolder = CreateFrame("Frame", nil, g.content)
  g.listHolder:SetPoint("TOPLEFT", 0, -48); g.listHolder:SetPoint("BOTTOMRIGHT")
  g.list = UI.ScrollList(g.listHolder)
  g.list.scroll:SetPoint("TOPLEFT", 0, 0)
  g.list.scroll:SetPoint("BOTTOMRIGHT", -26, 0)

  g:SetScript("OnShow", Render)

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

ns.On("Login", Create)
ns.On("OpenGuide", function(tab)
  if not g then return end
  if tab then currentTab = tab end
  if g:IsShown() and not tab then g:Hide() else g:Show(); Render() end
end)
ns.On("Refresh", Render)
ns.On("RefreshGuide", Render)
