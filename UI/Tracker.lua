-- Coffey's Leveling Guide tracker: the compact always-on panel showing the current step.
local ADDON, ns = ...
local UI = ns.UI
local W = 340
local frame

local function SavePos(self)
  self:StopMovingOrSizing()
  local p, _, rp, x, y = self:GetPoint()
  ns.char.pos = { p, rp, x, y }
end

local function ApplyPos()
  frame:ClearAllPoints()
  local p = ns.char.pos
  if p then frame:SetPoint(p[1], UIParent, p[2], p[3], p[4])
  else frame:SetPoint("RIGHT", UIParent, "RIGHT", -60, 140) end
end

local function KindIcon(step)
  if step.kind == "class" then return nil end
  return ns.KIND_ICONS[step.kind] or ns.KIND_ICONS.quest
end

local function Create()
  frame = UI.Panel("CoffeyGuideTracker", UIParent, W, 200)
  frame:SetFrameStrata("MEDIUM")
  frame:SetClampedToScreen(true)
  frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self) if not ns.db.lock then self:StartMoving() end end)
  frame:SetScript("OnDragStop", SavePos)
  frame:SetScale(ns.db.scale or 1)
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

  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 2, 2)
  close:SetScript("OnClick", function() frame:Hide(); ns.char.hidden = true end)

  frame.minBtn = UI.IconButton(frame, 18, "Interface\\Buttons\\UI-MinusButton-Up", "Minimize", "Collapse to one line.",
    function() ns.db.minimized = not ns.db.minimized; ns.Fire("Refresh") end)
  frame.minBtn.icon:SetTexCoord(0, 1, 0, 1)
  frame.minBtn:SetPoint("RIGHT", close, "LEFT", 0, 0)
  frame.guideBtn = UI.IconButton(frame, 20, "Interface\\Icons\\INV_Misc_Book_09", "Full guide",
    "Route, talents, spec guide, gear, professions, gold & extras.", function() ns.Fire("OpenGuide") end)
  frame.guideBtn:SetPoint("RIGHT", frame.minBtn, "LEFT", -4, 0)

  -- Progress bar.
  frame.bar = UI.Bar(frame, W - 20, 12)
  frame.bar:SetPoint("TOPLEFT", 10, -42)

  -- Step card.
  frame.kindIcon = UI.Icon(frame, 36)
  frame.kindIcon:SetPoint("TOPLEFT", frame.bar, "BOTTOMLEFT", 0, -8)
  frame.title = UI.Text(frame, "GameFontNormalLarge")
  frame.title:SetPoint("TOPLEFT", frame.kindIcon, "TOPRIGHT", 8, 0)
  frame.title:SetWidth(W - 70)
  frame.band = UI.Text(frame, "GameFontHighlightSmall")
  frame.band:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -2)
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

  -- Tip row.
  frame.tip = UI.Text(frame, "GameFontHighlightSmall")
  frame.tip:SetWidth(W - 24)

  -- Next step preview.
  frame.nextLine = UI.Text(frame, "GameFontDisableSmall")
  frame.nextLine:SetWidth(W - 24)

  -- Bottom buttons.
  local function nav(delta) return function() ns.SetView(ns.ViewIndex() + delta) end end
  frame.prev = UI.IconButton(frame, 22, "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up", "Previous step", nil, nav(-1))
  frame.prev.icon:SetTexCoord(0, 1, 0, 1)
  frame.nextB = UI.IconButton(frame, 22, "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", "Next step", nil, nav(1))
  frame.nextB.icon:SetTexCoord(0, 1, 0, 1)
  frame.cur = UI.Button(frame, "Current", 62, function() ns.SetView(nil) end)
  frame.done = UI.Button(frame, "Done", 54, function() ns.ToggleDone(ns.route[ns.ViewIndex()]) end)
  frame.skip = UI.Button(frame, "Skip", 46, function() ns.Skip(ns.route[ns.ViewIndex()]) end)
  frame.wp = UI.IconButton(frame, 22, "Interface\\Icons\\INV_Misc_Map_01", "Waypoints",
    "Show this step on your map, minimap and arrow.", function() ns.Fire("SetWaypoints", ns.route[ns.ViewIndex()], true) end)

  frame.prev:SetPoint("BOTTOMLEFT", 10, 9)
  frame.nextB:SetPoint("LEFT", frame.prev, "RIGHT", 2, 0)
  frame.cur:SetPoint("LEFT", frame.nextB, "RIGHT", 6, 0)
  frame.done:SetPoint("LEFT", frame.cur, "RIGHT", 2, 0)
  frame.skip:SetPoint("LEFT", frame.done, "RIGHT", 2, 0)
  frame.wp:SetPoint("BOTTOMRIGHT", -10, 9)

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

local function PlanRow(i)
  local r = frame.prows[i]
  if not r then
    r = CreateFrame("Button", nil, frame)
    r:SetSize(W - 24, 18)
    r.bg = r:CreateTexture(nil, "BACKGROUND"); r.bg:SetAllPoints()
    r.icon = r:CreateTexture(nil, "ARTWORK"); r.icon:SetSize(14, 14); r.icon:SetPoint("TOPLEFT", 0, -2)
    r.text = UI.Text(r, "GameFontHighlightSmall")
    r.text:SetPoint("TOPLEFT", r.icon, "TOPRIGHT", 5, 0)
    r.text:SetWidth(W - 48)
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    r:SetScript("OnClick", function(self, button)
      local step = ns.route[ns.ViewIndex()]
      if not step or not self.s then return end
      if button == "RightButton" then ns.MarkSub(step, self.s, not ns.SubDone(step, self.s))
      else ns.Fire("SetWaypoints", { id = step.id .. ":manual", title = step.title, wp = ns.SubWaypoints(self.s) }, true) end
    end)
    UI.Tooltip(r, function() return r.s and ns.SubText(r.s) or "" end,
      { "Left-click: waypoint to this step", "Right-click: mark done / not done" })
    frame.prows[i] = r
  end
  return r
end

local function Refresh()
  if not frame then return end
  local p = ns.player
  p.level = UnitLevel("player")

  UI.ClassIcon(frame.classIcon, p.class)
  frame.who:SetText(("%s %s  |cffffffffLv %d|r"):format(p.raceName or "", p.className or "", p.level or 0))
  local build, auto = ns.GetActiveBuild()
  frame.spec:SetText(build and ((auto and "|cff808080auto:|r " or "") .. build.name) or "|cff808080no build data|r")

  local done, total = ns.Progress()
  frame.bar:SetMinMaxValues(0, math.max(total, 1))
  frame.bar:SetValue(done)
  frame.bar.text:SetText(("Route %d / %d steps  ·  %d%%"):format(done, total, total > 0 and math.floor(done * 100 / total) or 0))

  local cur = ns.CurrentIndex()
  local idx = ns.ViewIndex()
  local step = ns.route[idx]
  local minimized = ns.db.minimized

  if not step then
    frame.title:SetText("No route data for your character")
    frame.band:SetText(""); frame.body:SetText("")
    frame:SetHeight(110)
    return
  end

  -- Step card.
  local icon = KindIcon(step)
  if icon then frame.kindIcon:SetTexture(icon); frame.kindIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  else UI.ClassIcon(frame.kindIcon, p.class) end
  local state = ns.StepState(step)
  local status = state == "done" and "  |cff4ce64cdone|r"
              or state == "skipped" and "  |cffcc4444skipped|r"
              or state == "outleveled" and "  |cff808080outleveled|r"
              or (idx == cur and "  |cffffd100current|r" or "")
  if step.optional then status = status .. "  |cff8080ffoptional|r" end
  frame.title:SetText(step.title or step.zone or "?")
  local zd, zt = ns.ZoneStats(step)
  local zs = zd and ("  ·  |cffffffff%d/%d|r quests done"):format(zd, zt) or ""
  frame.band:SetText(("%s  ·  %s%s%s"):format(ns.BandText(step), step.zone or "", zs, status))

  -- Collapse everything below the title when minimized.
  local showBody = not minimized
  for _, w in ipairs({ frame.body, frame.talentRow, frame.tip, frame.nextLine, frame.prev, frame.nextB,
                       frame.cur, frame.done, frame.skip, frame.wp }) do w:SetShown(showBody) end
  for _, r in ipairs(frame.qrows) do r:Hide() end
  for _, r in ipairs(frame.prows) do r:Hide() end
  frame.planHeader:SetShown(showBody)
  frame.minBtn.icon:SetTexture(minimized and "Interface\\Buttons\\UI-PlusButton-Up" or "Interface\\Buttons\\UI-MinusButton-Up")
  if minimized then frame:SetHeight(100); return end

  local y = 42 + 12 + 8 + math.max(36, frame.title:GetStringHeight() + frame.band:GetStringHeight() + 4) + 8
  frame.body:ClearAllPoints()
  frame.body:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -y)
  frame.body:SetText(step.text or "")
  y = y + frame.body:GetStringHeight() + 8

  -- Quest checklist.
  if step.quests then
    for i, q in ipairs(step.quests) do
      local name = type(q) == "table" and q[1] or q
      local r = QuestRow(i)
      r:ClearAllPoints(); r:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -y)
      if ns.IsQuestDone(q) then
        r.check:SetTexture(UI.STATUS.done); r.text:SetText("|cff4ce64c" .. name .. "|r")
      elseif ns.IsQuestActive(q) then
        r.check:SetTexture(UI.STATUS.current); r.text:SetText("|cffffd100" .. name .. "|r  |cff808080(in log)|r")
      else
        r.check:SetTexture(UI.STATUS.todo); r.text:SetText("|cffaaaaaa" .. name .. "|r")
      end
      r:Show()
      y = y + 17
    end
    y = y + 6
  end

  -- Quest plan (quest-by-quest checklist): show a window of upcoming sub-steps.
  for _, r in ipairs(frame.prows) do r:Hide() end
  local qplan, first, pdone = ns.PlanProgress(step)
  if qplan and #qplan > 0 then
    frame.planHeader:ClearAllPoints(); frame.planHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -y)
    frame.planHeader:SetText(("|cffffd100Quest plan|r  %d / %d"):format(pdone, #qplan)); frame.planHeader:Show()
    y = y + 16
    local startI = math.max(1, (first or #qplan) - 1)
    local shown = 0
    for i = startI, #qplan do
      if shown >= 6 then break end
      local s = qplan[i]
      local r = PlanRow(shown + 1)
      shown = shown + 1
      r.s = s
      r:ClearAllPoints(); r:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -y)
      r.icon:SetTexture(ns.ACT_ICONS[s.act] or ns.ACT_ICONS.note)
      local isDone = ns.SubDone(step, s)
      local isCur = (i == first)
      local text = ns.SubText(s)
      if isDone then text = "|cff4ce64c" .. text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") .. "|r"
      elseif not isCur then text = "|cffaaaaaa" .. text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") .. "|r" end
      r.text:SetText((isCur and "|TInterface\\ChatFrame\\ChatFrameExpandArrow:12|t " or "") .. text)
      r.icon:SetDesaturated(isDone)
      r.bg:SetColorTexture(1, 0.82, 0, isCur and 0.12 or 0)
      r:SetHeight(math.max(18, r.text:GetStringHeight() + 4))
      r:Show()
      y = y + r:GetHeight() + 1
    end
    y = y + 6
  else
    frame.planHeader:Hide()
  end

  -- Talent row.
  local L, plan, info, behind = ns.PendingTalent()
  local unspent = ns.UnspentTalentPoints()
  frame.talentRow:ClearAllPoints(); frame.talentRow:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -y)
  if plan then
    frame.talentIcon:SetTexture(info and info.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    local head = behind and (unspent > 0 and "|cff4ce64cSpend now:|r " or "|cffff8040Missing:|r ") or ("|cffffd100Lv " .. L .. ":|r ")
    frame.talentText:SetText(head .. ns.TalentText(plan) .. "  |cff808080(" .. (plan[3] or "") .. ")|r"
      .. (unspent > 0 and ("  |cff4ce64c" .. unspent .. " unspent|r") or ""))
  else
    frame.talentIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    frame.talentText:SetText("|cff808080No talent plan for this class yet|r")
  end
  y = y + 26

  -- Gold / extras tip for this level.
  local tips = ns.TipsForLevel(p.level or 1)
  if #tips > 0 then
    local t = tips[(math.floor(GetTime() / 60) % #tips) + 1]
    frame.tip:ClearAllPoints(); frame.tip:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -y)
    local ic = ns.KIND_ICONS[t.kind] or ns.KIND_ICONS.extra
    frame.tip:SetText(("|T%s:14|t |cffffd100%s:|r %s"):format(ic, t.title or "", t.text or ""))
    frame.tip:Show()
    y = y + frame.tip:GetStringHeight() + 6
  else
    frame.tip:Hide()
  end

  -- Next step preview.
  local nxt
  for i = idx + 1, #ns.route do
    if not ns.StepState(ns.route[i]) and (ns.db.showOptional or not ns.route[i].optional) then nxt = ns.route[i]; break end
  end
  frame.nextLine:ClearAllPoints(); frame.nextLine:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -y)
  frame.nextLine:SetText(nxt and ("Next: " .. (nxt.title or "?") .. "  (Lv " .. (nxt.min or "?") .. ")") or "")
  y = y + (nxt and 16 or 0)

  frame.done:SetText((ns.char.done[step.id] or ns.char.skip[step.id]) and "Undo" or "Done")
  frame.skip:SetEnabled(not state)
  frame.prev:SetEnabledState(idx > 1)
  frame.nextB:SetEnabledState(idx < #ns.route)
  frame.wp:SetEnabledState(step.wp ~= nil)

  frame:SetHeight(y + 40)
end

ns.On("Login", function() Create(); Refresh() end)
ns.On("Refresh", Refresh)
ns.On("ToggleTracker", function(forceShow)
  if not frame then return end
  if frame:IsShown() and not forceShow then frame:Hide(); ns.char.hidden = true
  else frame:Show(); ns.char.hidden = nil; ns.char.view = nil; Refresh() end
end)
ns.On("ResetPosition", function() if frame then ApplyPos() end end)
ns.On("SettingsChanged", function()
  if frame then frame:SetScale(ns.db.scale or 1); Refresh() end
end)
