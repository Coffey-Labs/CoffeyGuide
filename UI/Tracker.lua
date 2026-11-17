-- Coffey's Leveling Guide tracker: the always-on panel showing what to do next.
-- Three layouts: compact (one action line), standard (step, next objectives, actions) and
-- detailed (everything: step text, quest checklist, a longer plan window, tips). The panel
-- grows downward from its top edge, so its title stays put while the content changes.
local ADDON, ns = ...
local UI = ns.UI
local W = 340
local frame
-- Set by instance state. A manual show/compact toggle wins until the next zone change.
local context = { hidden = false, compact = false, override = false }

---------------------------------------------------------------------------
-- Position
---------------------------------------------------------------------------
local function SavePos(self)
  self:StopMovingOrSizing()
  local left, top = self:GetLeft(), self:GetTop()
  if left and top then
    ns.char.pos = { "TOPLEFT", "BOTTOMLEFT", left, top }
  else
    local p, _, rp, x, y = self:GetPoint()
    ns.char.pos = { p, rp, x, y }
  end
end

local function ApplyPos()
  frame:ClearAllPoints()
  local p = ns.char.pos
  if p then frame:SetPoint(p[1], UIParent, p[2], p[3], p[4])
  else frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -60, -230) end
end

local function KindIcon(step)
  if step.kind == "class" then return nil end
  return ns.KIND_ICONS[step.kind] or ns.KIND_ICONS.quest
end

local function IsCompact() return ns.db.compact or (context.compact and not context.override) end
local function Detailed() return ns.db.density == "detailed" and not IsCompact() end

local function Plain(text) return (text or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") end

---------------------------------------------------------------------------
-- Construction
---------------------------------------------------------------------------
local function Create()
  frame = UI.Panel("CoffeyGuideTracker", UIParent, W, 200)
  frame:SetFrameStrata("MEDIUM")
  frame:SetClampedToScreen(true)
  frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self) if not ns.db.lock then self:StartMoving() end end)
  frame:SetScript("OnDragStop", SavePos)
  frame:SetScale(ns.db.scale or 1)
  UI.Style(frame, ns.db.bgAlpha)
  ApplyPos()

  -- Header: class icon, identity, buttons.
  frame.classIcon = frame:CreateTexture(nil, "ARTWORK")
  frame.classIcon:SetSize(26, 26)
  frame.classIcon:SetPoint("TOPLEFT", 10, -9)
  frame.who = UI.Text(frame, "GameFontNormal")
  frame.who:SetPoint("TOPLEFT", frame.classIcon, "TOPRIGHT", 6, -1)
  frame.who:SetWidth(W - 150)
  frame.spec = UI.Text(frame, "GameFontHighlightSmall")
  frame.spec:SetPoint("TOPLEFT", frame.who, "BOTTOMLEFT", 0, -2)
  frame.spec:SetWidth(W - 150)

  local close = UI.CloseButton(frame, function() frame:Hide(); ns.char.hidden = true end)
  UI.Tooltip(close, "Hide tracker", "Bring it back with /cguide, the minimap button or a key binding.")

  frame.minBtn = UI.Glyph(frame, 20, "plus", "Compact",
    "Switch between the compact tracker (just the next action) and the full one.",
    function() ns.Fire("ToggleCompact") end)
  frame.minBtn:SetPoint("RIGHT", close, "LEFT", -2, 0)
  frame.guideBtn = UI.IconButton(frame, 20, "Interface\\Icons\\INV_Misc_Book_09", "Full guide",
    "Route, quest log, talents and spec guide, gear, professions, gold and extras.", function() ns.Fire("OpenGuide") end)
  frame.guideBtn:SetPoint("RIGHT", frame.minBtn, "LEFT", -4, 0)
  frame.guideBtn.border = UI.IconBorder(frame.guideBtn.icon)

  -- Progress bar (a thin strip at the bottom in compact mode).
  frame.bar = UI.Bar(frame, W - 20, 14)

  -- Suggestion / undo banner.
  local bn = CreateFrame("Frame", nil, frame)
  bn:SetSize(W - 20, 44)
  bn.bg = bn:CreateTexture(nil, "BACKGROUND"); bn.bg:SetAllPoints(); UI.AccentTexture(bn.bg, 0.12)
  bn.edge = bn:CreateTexture(nil, "BORDER"); bn.edge:SetPoint("TOPLEFT"); bn.edge:SetPoint("BOTTOMLEFT"); bn.edge:SetWidth(2)
  UI.AccentTexture(bn.edge, 0.95)
  bn.icon = UI.Icon(bn, 18, "Interface\\Icons\\INV_Misc_Map_01"); bn.icon:SetPoint("TOPLEFT", 8, -5)
  UI.IconBorder(bn.icon)
  bn.text = UI.Text(bn, "GameFontHighlightSmall")
  bn.text:SetPoint("TOPLEFT", bn.icon, "TOPRIGHT", 6, 0); bn.text:SetWidth(W - 52)
  bn.yes = UI.Button(bn, "Go there", 80, function() if bn.onYes then bn.onYes() end end, "primary")
  bn.no = UI.Button(bn, "Not now", 70, function() if bn.onNo then bn.onNo() end end)
  bn.no:SetPoint("BOTTOMRIGHT", -4, 3)
  bn.yes:SetPoint("RIGHT", bn.no, "LEFT", -4, 0)
  bn.yes:SetHeight(20); bn.no:SetHeight(20)
  frame.banner = bn

  -- Step card.
  frame.kindIcon = UI.Icon(frame, 36)
  frame.kindBorder = UI.IconBorder(frame.kindIcon)
  frame.title = UI.Text(frame, "GameFontNormalLarge")
  frame.title:SetWidth(W - 70)
  frame.band = UI.Text(frame, "GameFontHighlightSmall")
  frame.band:SetWidth(W - 70)

  frame.body = UI.Text(frame, "GameFontHighlight")
  frame.body:SetWidth(W - 24)
  frame.body:SetSpacing(2)

  -- Quest checklist rows and quest-plan rows (pooled).
  frame.qrows, frame.prows = {}, {}
  frame.planHeader = UI.Text(frame, "GameFontHighlightSmall")

  -- Talent row.
  frame.talentRow = CreateFrame("Button", nil, frame)
  frame.talentRow:SetSize(W - 20, 22)
  frame.talentIcon = UI.Icon(frame.talentRow, 20)
  frame.talentIcon:SetPoint("LEFT")
  frame.talentText = UI.Text(frame.talentRow, "GameFontHighlightSmall")
  frame.talentText:SetPoint("LEFT", frame.talentIcon, "RIGHT", 6, 0)
  frame.talentText:SetWidth(W - 50)
  frame.talentRow:SetScript("OnClick", function()
    if ToggleTalentFrame then ToggleTalentFrame() end
  end)
  UI.Tooltip(frame.talentRow, "Talent plan", function()
    local b = ns.GetActiveBuild()
    return { b and (b.name .. " - " .. (b.summary or "")) or "No build data", "Click to open your talents. The next pick glows in the talent window." }
  end)

  -- Tip row and next-step preview.
  frame.tip = UI.Text(frame, "GameFontHighlightSmall")
  frame.tip:SetWidth(W - 24)
  frame.nextLine = UI.Text(frame, "GameFontDisableSmall")
  frame.nextLine:SetWidth(W - 24)

  -- Bottom buttons.
  local function nav(delta) return function() ns.SetView(ns.ViewIndex() + delta) end end
  frame.prev = UI.Glyph(frame, 22, "left", "Previous step", nil, nav(-1))
  frame.nextB = UI.Glyph(frame, 22, "right", "Next step", nil, nav(1))
  frame.cur = UI.Button(frame, "Current", 62, function() ns.SetView(nil) end)
  UI.Tooltip(frame.cur, "Back to the current step", "Stop browsing and show the step you are on.")
  frame.done = UI.Button(frame, "Done", 54, function() ns.ToggleDone(ns.route[ns.ViewIndex()]) end)
  UI.Tooltip(frame.done, "Mark the whole step done", "Undo puts it back.")
  frame.skip = UI.Button(frame, "Skip", 46, function() ns.Skip(ns.route[ns.ViewIndex()]) end)
  UI.Tooltip(frame.skip, "Skip this step", "Skipped steps stay in the Route tab; click Undo there or here to bring one back.")
  frame.wp = UI.IconButton(frame, 22, "Interface\\Icons\\INV_Misc_Map_01", "Waypoints",
    "Show the current objective on your map, minimap and arrow.", function() ns.Fire("WaypointCurrent") end)
  UI.IconBorder(frame.wp.icon)

  frame.prev:SetPoint("BOTTOMLEFT", 10, 9)
  frame.nextB:SetPoint("LEFT", frame.prev, "RIGHT", 2, 0)
  frame.cur:SetPoint("LEFT", frame.nextB, "RIGHT", 6, 0)
  frame.done:SetPoint("LEFT", frame.cur, "RIGHT", 2, 0)
  frame.skip:SetPoint("LEFT", frame.done, "RIGHT", 2, 0)
  frame.wp:SetPoint("BOTTOMRIGHT", -10, 9)

  -- "Still open" reminder for class quests and mounts left behind.
  frame.reminder = CreateFrame("Button", nil, frame)
  frame.reminder:SetSize(W - 24, 16)
  frame.reminder.text = UI.Text(frame.reminder, "GameFontHighlightSmall")
  frame.reminder.text:SetPoint("LEFT"); frame.reminder.text:SetWidth(W - 24)
  if frame.reminder.text.SetMaxLines then frame.reminder.text:SetMaxLines(1) end
  frame.reminder:SetScript("OnClick", function(self) if self.idx then ns.SetView(self.idx) end end)
  UI.Tooltip(frame.reminder, "Still open", "A class quest or mount you've outleveled without doing. It no longer holds up the route. Click to view it; Done or Skip there clears the reminder.")

  -- Compact action line: checkbox + the next objective.
  frame.action = CreateFrame("Button", nil, frame)
  frame.action:SetSize(W - 20, 18)
  frame.action.check = CreateFrame("Button", nil, frame.action)
  frame.action.check:SetSize(16, 16); frame.action.check:SetPoint("TOPLEFT", 0, -1)
  frame.action.check.tex = frame.action.check:CreateTexture(nil, "ARTWORK"); frame.action.check.tex:SetAllPoints()
  UI.Hover(frame.action.check, 0.15)
  frame.action.check:SetScript("OnClick", function() ns.CheckCurrent() end)
  UI.Tooltip(frame.action.check, "Check off", "Mark this objective done. Key binding: Options > Keybindings > AddOns.")
  frame.action.text = UI.Text(frame.action, "GameFontHighlight")
  frame.action.text:SetPoint("TOPLEFT", frame.action.check, "TOPRIGHT", 5, 1)
  frame.action.text:SetWidth(W - 70)
  frame.action:SetScript("OnClick", function() ns.Fire("WaypointCurrent", true) end)
  UI.Tooltip(frame.action, "Next objective", "Click for a waypoint. Tick the box when it's done.")

  if ns.char.hidden then frame:Hide() end
end

local function QuestRow(i)
  local r = frame.qrows[i]
  if not r then
    r = CreateFrame("Frame", nil, frame)
    r:SetSize(W - 30, 16)
    r.check = r:CreateTexture(nil, "ARTWORK")
    r.check:SetSize(14, 14)
    r.check:SetPoint("LEFT")
    r.text = UI.Text(r, "GameFontHighlightSmall")
    r.text:SetPoint("LEFT", r.check, "RIGHT", 4, 0)
    r.text:SetWidth(W - 52)
    frame.qrows[i] = r
  end
  return r
end

-- Plan rows: a real checkbox on the left (click to toggle), the row itself sets a waypoint.
local function PlanRow(i)
  local r = frame.prows[i]
  if not r then
    r = CreateFrame("Button", nil, frame)
    r:SetSize(W - 24, 18)
    r.bg = r:CreateTexture(nil, "BACKGROUND"); r.bg:SetAllPoints()
    r.edge = r:CreateTexture(nil, "BORDER"); r.edge:SetPoint("TOPLEFT", -2, 0); r.edge:SetPoint("BOTTOMLEFT", -2, 0); r.edge:SetWidth(2)
    r.box = CreateFrame("Button", nil, r)
    r.box:SetSize(14, 14); r.box:SetPoint("TOPLEFT", 0, -2)
    r.box.tex = r.box:CreateTexture(nil, "ARTWORK"); r.box.tex:SetAllPoints()
    UI.Hover(r.box, 0.15)
    r.box:SetScript("OnClick", function()
      local step = ns.route[ns.ViewIndex()]
      if step and r.s then ns.MarkSub(step, r.s, not ns.SubDone(step, r.s)) end
    end)
    UI.Tooltip(r.box, "Done?", "Click to mark this objective done or not done.")
    r.icon = r:CreateTexture(nil, "ARTWORK"); r.icon:SetSize(14, 14); r.icon:SetPoint("TOPLEFT", r.box, "TOPRIGHT", 3, 0)
    r.text = UI.Text(r, "GameFontHighlightSmall")
    r.text:SetPoint("TOPLEFT", r.icon, "TOPRIGHT", 5, 0)
    r.text:SetWidth(W - 66)
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    r:SetScript("OnClick", function(self, button)
      local step = ns.route[ns.ViewIndex()]
      if not step or not self.s then return end
      if button == "RightButton" then ns.MarkSub(step, self.s, not ns.SubDone(step, self.s))
      else ns.Fire("SetWaypoints", { id = step.id .. ":manual", title = step.title, wp = ns.SubWaypoints(self.s) }, true) end
    end)
    UI.Tooltip(r, function() return r.s and ns.SubText(r.s) or "" end, function()
      local lines = { "Click: waypoint to this objective", "Checkbox or right-click: mark done / not done" }
      if r.missed then table.insert(lines, 1, ns.C("dim") .. "You seem to have passed this one by (not in your log, later quests started). It no longer holds up the guide.|r") end
      return lines
    end)
    frame.prows[i] = r
  end
  return r
end

---------------------------------------------------------------------------
-- Banner: "you seem to be further along" or "undo the jump"
---------------------------------------------------------------------------
local function BannerContent()
  local D = ns.Detect
  if not D then return nil end
  local j = D.RecentJump()
  if j then
    return { icon = "Interface\\Buttons\\UI-RefreshButton",
      text = ("Skipped %d earlier step(s) to get here%s."):format(#j.ids,
        #(j.deferred or {}) > 0 and ("; " .. #j.deferred .. " class quest or mount step(s) stay on the reminder list") or ""),
      yes = "Undo", onYes = D.UndoJump, no = "OK", onNo = function() ns.char.lastJump = nil; ns.Fire("Refresh") end }
  end
  if ns.char.view then return nil end -- browsing: don't nag
  local i, step, reason = D.Suggestion()
  if i then
    return { icon = KindIcon(step) or ns.KIND_ICONS.zone,
      text = reason .. " " .. ns.C("cur") .. "Jump to " .. (step.title or "?") .. "?|r",
      yes = "Go there", onYes = function() D.JumpTo(i) end, no = "Not now", onNo = function() D.Dismiss(step) end }
  end
end

local function LayoutBanner(y)
  local b = BannerContent()
  local bn = frame.banner
  if not b then bn:Hide(); return y end
  bn.icon:SetTexture(b.icon); bn.text:SetText(b.text)
  bn.yes:SetText(b.yes); bn.no:SetText(b.no)
  bn.onYes, bn.onNo = b.onYes, b.onNo
  local h = math.max(44, bn.text:GetStringHeight() + 30)
  bn:SetHeight(h)
  bn:ClearAllPoints(); bn:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -y)
  bn:Show()
  return y + h + 6
end

---------------------------------------------------------------------------
-- Refresh
---------------------------------------------------------------------------
local ALL_BODY
local function HideAll()
  ALL_BODY = ALL_BODY or { frame.classIcon, frame.who, frame.spec, frame.bar, frame.kindIcon, frame.title, frame.band,
    frame.body, frame.planHeader, frame.talentRow, frame.tip, frame.nextLine, frame.prev, frame.nextB, frame.cur,
    frame.done, frame.skip, frame.wp, frame.action, frame.banner, frame.reminder }
  for _, w in ipairs(ALL_BODY) do w:Hide() end
  frame.kindBorder:Hide()
  for _, r in ipairs(frame.qrows) do r:Hide() end
  for _, r in ipairs(frame.prows) do r:Hide() end
end

-- The next objective in one line: the first open plan sub-step, else the step text.
local function ActionText(step)
  local plan, first = ns.PlanProgress(step)
  if plan and first then return ns.SubText(plan[first]), true end
  return step.text or step.title or "", false
end

local function RefreshCompact(step, idx, cur)
  local y = 8
  frame.kindIcon:SetSize(18, 18)
  frame.kindIcon:ClearAllPoints(); frame.kindIcon:SetPoint("TOPLEFT", 10, -y)
  local icon = KindIcon(step)
  if icon then frame.kindIcon:SetTexture(icon); frame.kindIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  else UI.ClassIcon(frame.kindIcon, ns.player.class) end
  frame.kindIcon:Show(); frame.kindBorder:Show()
  frame.title:SetFontObject(UI.Font("GameFontNormal"))
  frame.title:ClearAllPoints(); frame.title:SetPoint("LEFT", frame.kindIcon, "RIGHT", 6, 0)
  frame.title:SetWidth(W - 110)
  frame.title:SetText((step.title or step.zone or "?") .. (idx ~= cur and ("  " .. ns.C("info") .. "(viewing)|r") or ""))
  if frame.title.SetMaxLines then frame.title:SetMaxLines(1) end
  frame.title:Show()
  y = y + 24

  y = LayoutBanner(y)

  local text, isPlan = ActionText(step)
  frame.action:ClearAllPoints(); frame.action:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -y)
  frame.action.text:SetText(text)
  if frame.action.text.SetMaxLines then frame.action.text:SetMaxLines(3) end
  frame.action.check.tex:SetTexture(UI.STATUS.todo)
  frame.action.check:SetShown(isPlan)
  local h = math.max(18, frame.action.text:GetStringHeight() + 4)
  frame.action:SetHeight(h)
  frame.action:Show()
  y = y + h + 6

  -- Thin progress strip along the bottom edge.
  frame.bar:SetSize(W - 20, 3)
  frame.bar.text:SetText("")
  frame.bar:ClearAllPoints(); frame.bar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 6)
  frame.bar:Show()
  frame:SetHeight(y + 10)
end

local function Refresh()
  if not frame or not frame:IsShown() then return end
  local p = ns.player
  p.level = UnitLevel("player")
  HideAll()

  local done, total = ns.Progress()
  frame.bar:SetMinMaxValues(0, math.max(total, 1))
  frame.bar:SetValue(done)

  local cur = ns.CurrentIndex()
  local idx = ns.ViewIndex()
  local step = ns.route[idx]
  local compact = IsCompact()
  frame.minBtn:SetGlyph(compact and "plus" or "minus")

  if not step then
    frame.title:SetFontObject(UI.Font("GameFontNormalLarge"))
    frame.title:ClearAllPoints(); frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -12)
    frame.title:SetText("No route for this character yet")
    frame.title:Show()
    frame.band:ClearAllPoints(); frame.band:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -4)
    frame.band:SetText("The guide covers levels 1-60 for every race. Type /cguide sync, or open the full guide for talents, gear and professions.")
    frame.band:Show()
    frame:SetHeight(80)
    return
  end

  if compact then RefreshCompact(step, idx, cur); return end

  -- Header.
  frame.classIcon:Show(); frame.who:Show(); frame.spec:Show()
  UI.ClassIcon(frame.classIcon, p.class)
  frame.who:SetText(("|cffffffff%s|r %s%s|r  |cff9a9a9aLv|r |cffffffff%d|r"):format(p.raceName or "", UI.AccentHex(), p.className or "", p.level or 0))
  local build, auto = ns.GetActiveBuild()
  frame.spec:SetText(build and ((auto and "|cff808080auto:|r " or "") .. build.name) or "|cff808080no build data|r")

  frame.bar:SetSize(W - 20, 14)
  frame.bar:ClearAllPoints(); frame.bar:SetPoint("TOPLEFT", 10, -42)
  frame.bar.text:SetText(("Route %d / %d steps  ·  %d%%"):format(done, total, total > 0 and math.floor(done * 100 / total) or 0))
  frame.bar:Show()

  local y = LayoutBanner(42 + 14 + 8)

  -- Step card.
  local icon = KindIcon(step)
  frame.kindIcon:SetSize(36, 36)
  frame.kindIcon:ClearAllPoints(); frame.kindIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -y)
  if icon then frame.kindIcon:SetTexture(icon); frame.kindIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  else UI.ClassIcon(frame.kindIcon, p.class) end
  frame.kindIcon:Show(); frame.kindBorder:Show()
  local state = ns.StepState(step)
  local status = state == "done" and ("  " .. ns.C("good") .. "done|r")
              or state == "skipped" and ("  " .. ns.C("skip") .. "skipped|r")
              or state == "outleveled" and "  |cff808080outleveled|r"
              or state == "behind" and ("  " .. ns.C("warn") .. "still open|r")
              or (idx == cur and ("  " .. ns.C("cur") .. "current|r") or "")
  if step.optional then status = status .. "  " .. ns.C("info") .. "optional|r" end
  frame.title:SetFontObject(UI.Font("GameFontNormalLarge"))
  if frame.title.SetMaxLines then frame.title:SetMaxLines(0) end
  frame.title:SetWidth(W - 70)
  frame.title:ClearAllPoints(); frame.title:SetPoint("TOPLEFT", frame.kindIcon, "TOPRIGHT", 8, 0)
  frame.title:SetText(step.title or step.zone or "?")
  frame.title:Show()
  local zd, zt = ns.ZoneStats(step)
  local zs = zd and ("  ·  |cffffffff%d/%d|r quests done"):format(zd, zt) or ""
  frame.band:ClearAllPoints(); frame.band:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -2)
  frame.band:SetText(("%s  ·  %s%s%s"):format(ns.BandText(step), step.zone or "", zs, status))
  frame.band:Show()
  y = y + math.max(36, frame.title:GetStringHeight() + frame.band:GetStringHeight() + 4) + 8

  local detailed = Detailed()
  local qplan, first, pdone, missed = ns.PlanProgress(step)
  local hasPlan = qplan and #qplan > 0

  -- Step text: always in detailed mode; in standard mode only when there's no plan to follow.
  if detailed or not hasPlan then
    frame.body:ClearAllPoints(); frame.body:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -y)
    frame.body:SetText(step.text or "")
    frame.body:Show()
    y = y + frame.body:GetStringHeight() + 8
  end

  -- Quest checklist (detailed, or standard when there's no plan).
  if step.quests and (detailed or not hasPlan) then
    for i, q in ipairs(step.quests) do
      local name = type(q) == "table" and q[1] or q
      local r = QuestRow(i)
      r:ClearAllPoints(); r:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -y)
      if ns.IsQuestDone(q) then
        r.check:SetTexture(UI.STATUS.done); r.text:SetText(ns.C("good") .. name .. "|r")
      elseif ns.IsQuestActive(q) then
        r.check:SetTexture(UI.STATUS.current); r.text:SetText(ns.C("cur") .. name .. "|r  |cff808080(in log)|r")
      else
        r.check:SetTexture(UI.STATUS.todo); r.text:SetText("|cffaaaaaa" .. name .. "|r")
      end
      r:Show()
      y = y + 17
    end
    y = y + 6
  end

  -- Quest plan window.
  if hasPlan then
    local nMissed = ns.MissedCount(missed)
    frame.planHeader:ClearAllPoints(); frame.planHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -y)
    frame.planHeader:SetText(("%sQuest plan|r  %d / %d%s"):format(ns.C("cur"), pdone, #qplan,
      nMissed > 0 and ("  |cff808080·  %d passed by|r"):format(nMissed) or ""))
    frame.planHeader:Show()
    y = y + 16
    local maxRows = detailed and 6 or 3
    local startI = detailed and math.max(1, (first or #qplan) - 1) or (first or #qplan)
    local shown = 0
    for i = startI, #qplan do
      if shown >= maxRows then break end
      local s = qplan[i]
      local isMissed = missed and missed[i]
      if not (isMissed and not detailed) then
        local r = PlanRow(shown + 1)
        shown = shown + 1
        r.s, r.missed = s, isMissed
        r:ClearAllPoints(); r:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -y)
        r.icon:SetTexture(ns.ACT_ICONS[s.act] or ns.ACT_ICONS.note)
        local isDone = ns.SubDone(step, s)
        local isCur = (i == first)
        local text = ns.SubText(s)
        if isDone then text = ns.C("good") .. Plain(text) .. "|r"
        elseif isMissed then text = "|cff707070" .. Plain(text) .. "  (passed by)|r"
        elseif not isCur then text = "|cffaaaaaa" .. Plain(text) .. "|r" end
        r.text:SetText(text)
        r.box.tex:SetTexture(isDone and UI.STATUS.done or (isCur and UI.STATUS.current or UI.STATUS.todo))
        r.icon:SetDesaturated(isDone or isMissed)
        local ar, ag, ab = UI.Accent()
        r.bg:SetColorTexture(ar, ag, ab, isCur and 0.13 or 0)
        r.edge:SetColorTexture(ar, ag, ab, 0.95); r.edge:SetShown(isCur)
        r:SetHeight(math.max(18, r.text:GetStringHeight() + 4))
        r:Show()
        y = y + r:GetHeight() + 1
      end
    end
    y = y + 6
  end

  -- Talent row: in standard mode only when there's something to do about it.
  local L, plan, info, behind = ns.PendingTalent()
  local unspent = ns.UnspentTalentPoints()
  local actionable = plan and (unspent > 0 or behind or L == p.level)
  if detailed or actionable then
    frame.talentRow:ClearAllPoints(); frame.talentRow:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -y)
    if plan then
      frame.talentIcon:SetTexture(info and info.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
      local head = behind and (unspent > 0 and (ns.C("good") .. "Spend now:|r ") or (ns.C("warn") .. "Missing:|r "))
                   or (ns.C("cur") .. "Lv " .. L .. ":|r ")
      frame.talentText:SetText(head .. ns.TalentText(plan) .. "  |cff808080(" .. (plan[3] or "") .. ")|r"
        .. (unspent > 0 and ("  " .. ns.C("good") .. unspent .. " unspent|r") or ""))
    else
      frame.talentIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
      frame.talentText:SetText("|cff808080No talent plan for this class yet|r")
    end
    frame.talentRow:Show()
    y = y + 26
  end

  -- Gold / extras tip for this level (detailed). It changes with your level, not on a timer.
  if detailed then
    local tips = ns.TipsForLevel(p.level or 1)
    if #tips > 0 then
      local t = tips[((p.level or 1) % #tips) + 1]
      frame.tip:ClearAllPoints(); frame.tip:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -y)
      local ic = ns.KIND_ICONS[t.kind] or ns.KIND_ICONS.extra
      frame.tip:SetText(("|T%s:14|t %s%s:|r %s"):format(ic, ns.C("cur"), t.title or "", t.text or ""))
      frame.tip:Show()
      y = y + frame.tip:GetStringHeight() + 6
    end
  end

  -- Next step preview.
  local nxt
  for i = idx + 1, #ns.route do
    if not ns.StepState(ns.route[i]) and (ns.db.showOptional or not ns.route[i].optional) then nxt = ns.route[i]; break end
  end
  if nxt then
    frame.nextLine:ClearAllPoints(); frame.nextLine:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -y)
    frame.nextLine:SetText("Next: " .. (nxt.title or "?") .. "  (Lv " .. (nxt.min or "?") .. ")")
    frame.nextLine:Show()
    y = y + 16
  end

  -- Reminder: class quests or mounts left behind.
  local open = ns.StillOpen()
  if #open > 0 and frame.reminder then
    local first = ns.route[open[1]]
    frame.reminder.idx = open[1]
    frame.reminder.text:SetText(ns.C("warn") .. "Still open:|r " .. (first.title or "?")
      .. (#open > 1 and ("  |cff808080+" .. (#open - 1) .. " more|r") or ""))
    frame.reminder:ClearAllPoints(); frame.reminder:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -y)
    frame.reminder:Show()
    y = y + 18
  end

  for _, w in ipairs({ frame.prev, frame.nextB, frame.cur, frame.done, frame.skip, frame.wp }) do w:Show() end
  frame.done:SetText((ns.char.done[step.id] or ns.char.skip[step.id]) and "Undo" or "Done")
  frame.skip:SetEnabled(not state or state == "behind")
  frame.cur:SetEnabled(idx ~= cur)
  frame.prev:SetEnabledState(idx > 1)
  frame.nextB:SetEnabledState(idx < #ns.route)
  frame.wp:SetEnabledState(step.wp ~= nil or hasPlan)

  frame:SetHeight(y + 40)
end

---------------------------------------------------------------------------
-- Context: instances, combat, mouseover
---------------------------------------------------------------------------
local inCombat = false
local function ApplyContext()
  if not frame then return end
  local db = ns.db
  local itype = IsInInstance and select(2, IsInInstance())
  local wasCompact = context.compact
  context.hidden = db.instanceHide and (itype == "raid" or itype == "pvp" or itype == "arena") or false
  context.compact = db.instanceHide and itype == "party" or false
  if context.hidden and not context.override then frame:Hide()
  elseif not ns.char.hidden and not frame:IsShown() then frame:Show(); Refresh() end
  if wasCompact ~= context.compact then Refresh() end
  local alpha = 1
  if inCombat and db.combatFade then alpha = 0.35
  elseif db.mouseoverFade and not (frame.IsMouseOver and frame:IsMouseOver()) then alpha = 0.4 end
  frame:SetAlpha(alpha)
end

local ctx = CreateFrame("Frame")
for _, e in ipairs({ "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED" }) do
  pcall(ctx.RegisterEvent, ctx, e)
end
ctx:SetScript("OnEvent", function(_, e)
  if e == "PLAYER_REGEN_DISABLED" then inCombat = true elseif e == "PLAYER_REGEN_ENABLED" then inCombat = false
  else context.override = false end
  if ns.db then ApplyContext() end
end)
-- Mouseover fade needs polling; only runs while that option is on.
local acc = 0
ctx:SetScript("OnUpdate", function(_, elapsed)
  acc = acc + elapsed
  if acc < 0.2 then return end
  acc = 0
  if frame and ns.db and ns.db.mouseoverFade and frame:IsShown() then ApplyContext() end
end)

---------------------------------------------------------------------------
-- Wiring
---------------------------------------------------------------------------
ns.On("Login", function() Create(); Refresh(); ApplyContext() end)
ns.On("Refresh", Refresh)
ns.On("ToggleTracker", function(forceShow)
  if not frame then return end
  if frame:IsShown() and not forceShow then frame:Hide(); ns.char.hidden = true
  else
    if context.hidden then context.override = true end
    frame:Show(); ns.char.hidden = nil; ns.char.view = nil; Refresh()
  end
end)
ns.On("ToggleCompact", function()
  -- In a dungeon the tracker is compact by context; the first press expands it for this zone.
  if context.compact then
    if IsCompact() then ns.db.compact = false; context.override = true else context.override = false end
  else
    ns.db.compact = not ns.db.compact
  end
  if frame and not frame:IsShown() and not context.hidden then frame:Show(); ns.char.hidden = nil end
  Refresh()
end)
ns.On("ResetPosition", function() if frame then ApplyPos() end end)
ns.On("SettingsChanged", function()
  if not frame then return end
  frame:SetScale(ns.db.scale or 1)
  UI.Style(frame, ns.db.bgAlpha)
  UI.ApplyFontScale()
  UI.Restyle()
  Refresh()
  ApplyContext()
end)
