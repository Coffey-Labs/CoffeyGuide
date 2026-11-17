-- Coffey's Leveling Guide: talent window highlight, level-up popup, minimap/compartment button.
local ADDON, ns = ...
local UI = ns.UI

---------------------------------------------------------------------------
-- Talent window highlight (overlay only; Blizzard frames are never modified)
---------------------------------------------------------------------------
local glow

local function TalentFrameInfo()
  local f = PlayerTalentFrame or TalentFrame
  if not f then return end
  local tab = (PanelTemplates_GetSelectedTab and PanelTemplates_GetSelectedTab(f)) or f.selectedTab or f.currentSelectedTab
  return f, f:GetName(), tab
end

local function UpdateTalentGlow()
  if not glow then return end
  glow:Hide()
  if not ns.db or not ns.db.talentGlow then return end
  local f, name, tab = TalentFrameInfo()
  if not f or not f:IsShown() then return end
  local _, plan, info = ns.PendingTalent()
  if not plan or not info or info.tab ~= tab then return end
  local button = _G[name .. "Talent" .. info.index]
  if not button or not button:IsShown() then return end
  glow:SetParent(button)
  glow:ClearAllPoints()
  glow:SetPoint("CENTER", button, "CENTER")
  glow:SetFrameLevel(button:GetFrameLevel() + 5)
  glow:Show()
end

local function SetupTalentHook()
  local f = PlayerTalentFrame or TalentFrame
  if not f or glow then return end
  glow = CreateFrame("Frame", nil, f)
  glow:SetSize(64, 64)
  local t = glow:CreateTexture(nil, "OVERLAY")
  t:SetAllPoints()
  t:SetTexture("Interface\\Buttons\\CheckButtonHilight")
  t:SetBlendMode("ADD")
  t:SetVertexColor(1, 0.82, 0)
  local ag = glow:CreateAnimationGroup()
  ag:SetLooping("BOUNCE")
  local a = ag:CreateAnimation("Alpha")
  a:SetFromAlpha(1); a:SetToAlpha(0.25); a:SetDuration(0.6)
  ag:Play()
  glow.label = glow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  glow.label:SetPoint("BOTTOM", glow, "TOP", 0, -14)
  glow.label:SetText("next")
  glow:Hide()

  f:HookScript("OnShow", function() ns.EnsureTalents(); C_Timer.After(0, UpdateTalentGlow) end)
  for _, fn in ipairs({ "PlayerTalentFrame_Update", "TalentFrame_Update", "PlayerTalentFrame_UpdateTalents" }) do
    if type(_G[fn]) == "function" then hooksecurefunc(fn, function() C_Timer.After(0, UpdateTalentGlow) end) end
  end
  for i = 1, 5 do
    local tabBtn = _G[f:GetName() .. "Tab" .. i]
    if tabBtn then tabBtn:HookScript("OnClick", function() C_Timer.After(0, UpdateTalentGlow) end) end
  end
end

ns.On("AddonLoaded", function(name)
  if name == "Blizzard_TalentUI" then SetupTalentHook() end
end)
ns.On("Login", function()
  if PlayerTalentFrame or TalentFrame then SetupTalentHook() end
end)
ns.On("Refresh", UpdateTalentGlow)

---------------------------------------------------------------------------
-- Level-up popup
---------------------------------------------------------------------------
local toast

local function CreateToast()
  toast = UI.Panel("CoffeyGuideToast", UIParent, 360, 120)
  local tp = ns.db.toastPos
  if tp then toast:SetPoint("TOP", UIParent, "BOTTOMLEFT", tp[1], tp[2])
  else toast:SetPoint("TOP", UIParent, "TOP", 0, -180) end
  toast:SetFrameStrata("DIALOG")
  toast:Hide()
  UI.FadeIn(toast, 16)
  toast.title = UI.Text(toast, "GameFontNormalHuge")
  toast.title:SetPoint("TOP", 0, -12); toast.title:SetJustifyH("CENTER"); toast.title:SetWidth(340)
  toast.lines = UI.Text(toast, "GameFontHighlight")
  toast.lines:SetPoint("TOP", toast.title, "BOTTOM", 0, -8); toast.lines:SetWidth(330); toast.lines:SetJustifyH("CENTER")
  toast.lines:SetSpacing(3)
  -- Click to dismiss; drag (when not locked) to move it somewhere out of the way.
  toast:EnableMouse(true)
  toast:SetMovable(true); toast:SetClampedToScreen(true); toast:RegisterForDrag("LeftButton")
  toast:SetScript("OnDragStart", function(self)
    if ns.db.lock then return end
    self.dragged = true; self.anim:Stop(); self:SetAlpha(1); self:StartMoving()
  end)
  toast:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local l, t, w = self:GetLeft(), self:GetTop(), self:GetWidth()
    if l and t and w then ns.db.toastPos = { l + w / 2, t } end
    self.anim:Play()
  end)
  toast:SetScript("OnMouseUp", function(self)
    if self.dragged then self.dragged = nil; return end
    self:Hide()
  end)
  UI.Tooltip(toast, "Coffey's Leveling Guide", "Click to dismiss. Drag to move it.")

  local ag = toast:CreateAnimationGroup()
  local fade = ag:CreateAnimation("Alpha")
  fade:SetFromAlpha(1); fade:SetToAlpha(0); fade:SetDuration(1.2); fade:SetStartDelay(9)
  ag:SetScript("OnFinished", function() toast:Hide(); toast:SetAlpha(1) end)
  toast.anim = ag
end

local function ShowToast(title, lines)
  if not ns.db.toasts then return end
  if not toast then CreateToast() end
  toast.title:SetText(UI.AccentHex() .. title .. "|r")
  toast.lines:SetText(table.concat(lines, "\n"))
  toast:SetHeight(46 + toast.lines:GetStringHeight() + 14)
  toast.anim:Stop(); toast:SetAlpha(1); toast:Show(); toast.anim:Play()
end

ns.On("LevelUp", function(level)
  local lines = {}
  -- The popup already says all this; repeat it in chat only when popups are off or quiet mode is.
  local chatty = not ns.db.toasts or not ns.db.quiet
  local build = ns.GetActiveBuild()
  local plan = build and build.talents and build.talents[level]
  if plan then
    local info = ns.talents.byName[plan[1]]
    lines[#lines + 1] = ("|T%s:16|t |cffffd100Talent:|r %s"):format(info and info.icon or "Interface\\Icons\\INV_Misc_QuestionMark", ns.TalentText(plan))
    if chatty then ns.Print(("Level %d talent: |cffffd100%s|r (%s)"):format(level, ns.TalentText(plan), plan[3] or "")) end
  end
  local spells = ns.SPELLS[ns.player.class]
  if spells and spells[level] then
    lines[#lines + 1] = "|TInterface\\Icons\\INV_Misc_Book_09:16|t |cffffd100Train:|r " .. spells[level]
    if chatty then ns.Print(("Level %d - visit your trainer: %s"):format(level, spells[level])) end
  elseif level % 2 == 0 then
    lines[#lines + 1] = "|TInterface\\Icons\\INV_Misc_Book_09:16|t Visit your class trainer"
  end
  C_Timer.After(0.6, function()
    local step = ns.route[ns.CurrentIndex()]
    if step then lines[#lines + 1] = "|cff808080Next:|r " .. (step.title or "") end
    ShowToast(("Level %d!"):format(level), lines)
  end)
end)

ns.On("StepAdvanced", function(_, nextStep)
  if nextStep and not ns.db.quiet then ns.Print(("Step done! Next: |cffffd100%s|r (%s)"):format(nextStep.title or "?", ns.BandText(nextStep))) end
end)

---------------------------------------------------------------------------
-- Minimap button (LibDBIcon) + addon compartment
---------------------------------------------------------------------------
local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
local DBIcon = LibStub and LibStub("LibDBIcon-1.0", true)

function CoffeyGuide_OnAddonCompartmentClick(_, button)
  if button == "RightButton" then ns.Fire("ToggleTracker") else ns.Fire("OpenGuide") end
end

ns.On("Login", function()
  if not LDB or not DBIcon then return end
  local obj = LDB:NewDataObject("CoffeyGuide", {
    type = "launcher", text = "Coffey's Leveling Guide", icon = "Interface\\Icons\\INV_Misc_Book_09",
    OnClick = function(_, button) CoffeyGuide_OnAddonCompartmentClick(nil, button) end,
    OnTooltipShow = function(tt)
      tt:AddLine("Coffey's Leveling Guide", 1, 0.82, 0)
      local step = ns.route[ns.CurrentIndex()]
      if step then tt:AddLine("Now: " .. (step.title or ""), 1, 1, 1) end
      tt:AddLine("Left-click: full guide", 0.6, 0.6, 0.6)
      tt:AddLine("Right-click: show/hide tracker", 0.6, 0.6, 0.6)
      tt:AddLine("by Coffey Labs LLC - coffeylabs.org", 0.4, 0.73, 1)
      tt:AddLine("Support us: coffeylabs.org/support (/cguide support)", 0.4, 0.73, 1)
    end,
  })
  DBIcon:Register("CoffeyGuide", obj, ns.db.minimap)
end)

ns.On("ResetPosition", function()
  ns.db.toastPos = nil
  if toast then toast:ClearAllPoints(); toast:SetPoint("TOP", UIParent, "TOP", 0, -180) end
end)

ns.On("MinimapChanged", function()
  if not DBIcon then return end
  if ns.db.minimap.hide then DBIcon:Hide("CoffeyGuide") else DBIcon:Show("CoffeyGuide") end
end)
