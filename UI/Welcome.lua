-- Coffey's Leveling Guide welcome panel: shown once per character after the quest history has been
-- read. It says what the guide detected (character, build, progress already made), lets the player
-- pick a tracker layout and the automation they want, and gets out of the way.
local ADDON, ns = ...
local UI = ns.UI
local panel

local function Line(parent, font)
  local t = UI.Text(parent, font or "GameFontHighlight")
  t:SetWidth(400)
  return t
end

local function Create()
  panel = UI.Panel("CoffeyGuideWelcome", UIParent, 440, 420)
  panel:SetPoint("CENTER", 0, 60)
  panel:SetFrameStrata("DIALOG")
  panel:SetClampedToScreen(true)
  panel:SetMovable(true); panel:EnableMouse(true); panel:RegisterForDrag("LeftButton")
  panel:SetScript("OnDragStart", panel.StartMoving)
  panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
  panel:Hide()
  tinsert(UISpecialFrames, "CoffeyGuideWelcome")

  UI.CloseButton(panel)
  UI.FadeIn(panel, 12)

  panel.classIcon = panel:CreateTexture(nil, "ARTWORK")
  panel.classIcon:SetSize(40, 40); panel.classIcon:SetPoint("TOPLEFT", 18, -18)
  UI.IconBorder(panel.classIcon)
  panel.head = UI.Text(panel, "GameFontNormalLarge")
  panel.head:SetPoint("TOPLEFT", panel.classIcon, "TOPRIGHT", 10, -2)
  panel.head:SetText("Welcome to Coffey's Leveling Guide")
  panel.who = UI.Text(panel, "GameFontHighlight")
  panel.who:SetPoint("TOPLEFT", panel.head, "BOTTOMLEFT", 0, -4)

  panel.found = Line(panel)
  panel.found:SetPoint("TOPLEFT", 20, -72)
  panel.found:SetSpacing(3)

  panel.layoutHead = UI.Section(panel, "Tracker layout")
  panel.layout = UI.Segmented(panel, {
    { label = "Compact", value = "compact", tip = "One line: the next thing to do, with a checkbox." },
    { label = "Standard", value = "standard", tip = "The step, your next few objectives and the step buttons." },
    { label = "Detailed", value = "detailed", tip = "Everything, including step notes, the quest checklist and level tips." },
  }, function() return ns.db.compact and "compact" or ns.db.density end, function(v)
    if v == "compact" then ns.db.compact = true else ns.db.compact = false; ns.db.density = v end
    ns.Fire("SettingsChanged")
  end)

  panel.autoHead = UI.Section(panel, "Automation (all optional; hold Shift to bypass)")
  panel.checks = {}
  for i, o in ipairs({
    { "autoAccept", "Accept quests" }, { "autoTurnIn", "Turn in quests (no reward choice)" },
    { "sellGreys", "Sell gray items" }, { "autoRepair", "Repair at vendors" },
  }) do
    local cb = UI.Check(panel, o[2], function() return ns.db[o[1]] end, function(v) ns.db[o[1]] = v; ns.Fire("SettingsChanged") end)
    cb.label:SetFontObject(UI.Font("GameFontHighlightSmall"))
    panel.checks[i] = cb
  end

  panel.keys = Line(panel, "GameFontDisableSmall")
  panel.keys:SetText("Tip: bind keys under Options > Keybindings > AddOns (check off the next objective, waypoint, compact). Everything else is in /cguide settings.")

  panel.go = UI.Button(panel, "Let's go", 100, function()
    ns.char.welcomed = true; panel:Hide()
    ns.Fire("ToggleTracker", true)
  end, "primary")
  panel.go:SetPoint("BOTTOMRIGHT", -16, 14)
  panel.guide = UI.Button(panel, "Open the full guide", 150, function()
    ns.char.welcomed = true; panel:Hide(); ns.Fire("OpenGuide", "route")
  end)
  panel.guide:SetPoint("RIGHT", panel.go, "LEFT", -6, 0)
  panel.jump = UI.Button(panel, "Jump there", 100, function()
    ns.char.welcomed = true; panel:Hide()
    if panel.jumpIndex and ns.Detect then ns.Detect.JumpTo(panel.jumpIndex) end
  end, "primary")
  panel.jump:SetPoint("BOTTOMLEFT", 16, 14)
  panel:SetScript("OnHide", function() ns.char.welcomed = true end)
end

local function Fill()
  local p = ns.player
  UI.ClassIcon(panel.classIcon, p.class)
  local build, auto = ns.GetActiveBuild()
  panel.who:SetText(("Level %d %s %s%s|r  |cff9a9a9a%s|r"):format(p.level or UnitLevel("player") or 1, p.raceName or "",
    UI.AccentHex(), p.className or "", p.faction or ""))

  local sum = ns.Detect.Summary()
  local lines = {}
  if build then
    lines[#lines + 1] = ("Talent plan: |cffffd100%s|r%s. Change it in the Talents & Spec tab."):format(build.name, auto and " (picked from your talents)" or "")
  end
  if sum.completed > 0 then
    lines[#lines + 1] = ("Found %s%d|r completed quests in your history: %d of %d route steps are already done%s.")
      :format(ns.C("good"), sum.completed, sum.done, sum.total,
        sum.outleveled > 0 and (", " .. sum.outleveled .. " more you've outleveled") or "")
  else
    lines[#lines + 1] = ("A fresh start: %d route steps from here to 60."):format(sum.total)
  end
  if sum.behind > 0 then
    lines[#lines + 1] = ("%s%d|r class quest or mount step(s) are still open from earlier levels; the tracker reminds you."):format(ns.C("warn"), sum.behind)
  end
  if sum.current then
    lines[#lines + 1] = ("You're on: %s%s|r (%s)."):format(ns.C("cur"), sum.current.title or "?", ns.BandText(sum.current))
  end
  if sum.suggestStep then
    lines[#lines + 1] = sum.suggestReason .. " Jump to " .. ns.C("cur") .. (sum.suggestStep.title or "?") .. "|r? Earlier steps get marked skipped, and Undo puts them back."
    panel.jumpIndex = sum.suggestIndex
    panel.jump:Show()
  else
    panel.jumpIndex = nil
    panel.jump:Hide()
  end
  panel.found:SetText(table.concat(lines, "\n"))

  -- Lay out below the detection text.
  local y = 72 + panel.found:GetStringHeight() + 16
  panel.layoutHead:ClearAllPoints(); panel.layoutHead:SetPoint("TOPLEFT", 20, -y); y = y + 24
  panel.layout:ClearAllPoints(); panel.layout:SetPoint("TOPLEFT", 20, -y); panel.layout:Update(); y = y + 34
  panel.autoHead:ClearAllPoints(); panel.autoHead:SetPoint("TOPLEFT", 20, -y); y = y + 22
  for i, cb in ipairs(panel.checks) do
    cb:ClearAllPoints(); cb:SetPoint("TOPLEFT", 18 + ((i - 1) % 2) * 200, -y)
    cb:SetChecked(ns.db[({ "autoAccept", "autoTurnIn", "sellGreys", "autoRepair" })[i]] and true or false)
    if i % 2 == 0 then y = y + 26 end
  end
  y = y + 8
  panel.keys:ClearAllPoints(); panel.keys:SetPoint("TOPLEFT", 20, -y)
  y = y + panel.keys:GetStringHeight() + 50
  panel:SetHeight(y)
end

local function Show(force)
  if not panel then Create() end
  if not force and ns.char.welcomed then return end
  Fill()
  panel:Show()
end

ns.On("ShowWelcome", function(force) Show(force) end)
-- First time on each character: wait for the quest history, so the summary is right.
ns.On("HistoryReady", function()
  if ns.char and not ns.char.welcomed and not (InCombatLockdown and InCombatLockdown()) then Show(false) end
end)
