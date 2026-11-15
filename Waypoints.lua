-- ForeverGuide waypoints: world map + minimap pins (HereBeDragons), TomTom integration, built-in arrow.
local ADDON, ns = ...

local HBD = LibStub and LibStub("HereBeDragons-2.0", true)
local Pins = LibStub and LibStub("HereBeDragons-Pins-2.0", true)

local W = {}
ns.Waypoints = W

local pinPool, activePins = {}, {}
local tomtomUIDs = {}
local targets = {}      -- current list of { map, x, y, label }
local targetIndex = 1
local lastStepID

---------------------------------------------------------------------------
-- Pins
---------------------------------------------------------------------------
local function AcquirePin(size)
  local pin = table.remove(pinPool)
  if not pin then
    pin = CreateFrame("Frame", nil, UIParent)
    pin.icon = pin:CreateTexture(nil, "ARTWORK")
    pin.icon:SetAllPoints()
    pin.icon:SetTexture("Interface\\Minimap\\ObjectIcons")
    pin.icon:SetTexCoord(0.5, 0.625, 0, 0.125) -- yellow "!"-style object icon
    pin.num = pin:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pin.num:SetPoint("BOTTOM", pin, "TOP", 0, -2)
    pin:EnableMouse(true)
    pin:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:AddLine(self.label or "", 1, 0.82, 0)
      if self.stepTitle then GameTooltip:AddLine(self.stepTitle, 1, 1, 1) end
      GameTooltip:AddLine("ForeverGuide", 0.5, 0.5, 0.5)
      GameTooltip:Show()
    end)
    pin:SetScript("OnLeave", function() GameTooltip:Hide() end)
  end
  pin:SetSize(size, size)
  return pin
end

local function ClearPins()
  if Pins then
    Pins:RemoveAllWorldMapIcons(W)
    Pins:RemoveAllMinimapIcons(W)
  end
  for _, pin in ipairs(activePins) do pin:Hide(); pinPool[#pinPool + 1] = pin end
  wipe(activePins)
  if TomTom and TomTom.RemoveWaypoint then
    for _, uid in ipairs(tomtomUIDs) do pcall(TomTom.RemoveWaypoint, TomTom, uid) end
  end
  wipe(tomtomUIDs)
end

local function UsingTomTom()
  return ns.db.useTomTom and TomTom and TomTom.AddWaypoint
end

function W.Set(step, announce)
  ClearPins()
  wipe(targets)
  targetIndex = 1
  lastStepID = step and step.id
  if not step or not step.wp then W.UpdateArrowVisibility(); return end

  for i, wp in ipairs(step.wp) do
    local map, x, y, label = wp[1], wp[2], wp[3], wp[4] or step.title
    if map and x and y then
      targets[#targets + 1] = { map = map, x = x / 100, y = y / 100, label = label }
      if ns.db.pins and Pins then
        local wpin = AcquirePin(18)
        wpin.label, wpin.stepTitle = label, step.title
        wpin.num:SetText(#step.wp > 1 and i or "")
        Pins:AddWorldMapIconMap(W, wpin, map, x / 100, y / 100, HBD_PINS_WORLDMAP_SHOW_CONTINENT or 2)
        activePins[#activePins + 1] = wpin
        local mpin = AcquirePin(14)
        mpin.label, mpin.stepTitle = label, step.title
        mpin.num:SetText("")
        Pins:AddMinimapIconMap(W, mpin, map, x / 100, y / 100, true, true)
        activePins[#activePins + 1] = mpin
      end
      if UsingTomTom() then
        local ok, uid = pcall(TomTom.AddWaypoint, TomTom, map, x / 100, y / 100,
          { title = label, from = ADDON, persistent = false, crazy = (i == 1) })
        if ok and uid then tomtomUIDs[#tomtomUIDs + 1] = uid end
      end
    end
  end
  if announce and targets[1] then
    ns.Print(("Waypoint: %s (%.1f, %.1f)"):format(targets[1].label or "?", targets[1].x * 100, targets[1].y * 100))
  end
  W.UpdateArrowVisibility()
end

---------------------------------------------------------------------------
-- Built-in arrow (used when TomTom is not installed or disabled in settings)
---------------------------------------------------------------------------
local arrow

local function CreateArrow()
  arrow = CreateFrame("Button", "ForeverGuideArrow", UIParent)
  arrow:SetSize(64, 80)
  arrow:SetPoint("TOP", UIParent, "TOP", 0, -120)
  arrow:SetMovable(true); arrow:EnableMouse(true); arrow:RegisterForDrag("LeftButton")
  arrow:SetClampedToScreen(true)
  arrow:SetScript("OnDragStart", function(self) if not ns.db.lock then self:StartMoving() end end)
  arrow:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, _, rp, x, y = self:GetPoint(); ns.db.arrowPos = { p, rp, x, y }
  end)
  if ns.db.arrowPos then
    local p = ns.db.arrowPos
    arrow:ClearAllPoints(); arrow:SetPoint(p[1], UIParent, p[2], p[3], p[4])
  end
  arrow.tex = arrow:CreateTexture(nil, "ARTWORK")
  arrow.tex:SetSize(48, 48)
  arrow.tex:SetPoint("TOP")
  arrow.tex:SetTexture("Interface\\Minimap\\MinimapArrow")
  arrow.tex:SetVertexColor(1, 0.82, 0)
  arrow.label = arrow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  arrow.label:SetPoint("TOP", arrow.tex, "BOTTOM", 0, 2)
  arrow.dist = arrow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  arrow.dist:SetPoint("TOP", arrow.label, "BOTTOM", 0, -1)
  arrow:SetScript("OnClick", function() ns.Fire("ToggleTracker", true) end)

  local acc = 0
  arrow:SetScript("OnUpdate", function(self, elapsed)
    acc = acc + elapsed
    if acc < 0.05 then return end
    acc = 0
    local t = targets[targetIndex]
    if not t or not HBD then self:Hide(); return end
    local px, py, pinst = HBD:GetPlayerWorldPosition()
    local tx, ty, tinst = HBD:GetWorldCoordinatesFromZone(t.x, t.y, t.map)
    self.label:SetText(t.label or "")
    if not px or not tx then self.dist:SetText(""); return end
    if pinst ~= tinst then
      self.tex:SetRotation(0)
      self.tex:SetVertexColor(0.6, 0.6, 0.6)
      self.dist:SetText("other continent")
      return
    end
    local angle, dist = HBD:GetWorldVector(pinst, px, py, tx, ty)
    local facing = GetPlayerFacing and GetPlayerFacing()
    if not angle or not facing then self.dist:SetText(""); return end
    self.tex:SetRotation(angle - facing)
    if dist < 15 then
      self.tex:SetVertexColor(0.3, 1, 0.3)
      if targets[targetIndex + 1] then targetIndex = targetIndex + 1 end
    else
      self.tex:SetVertexColor(1, 0.82, 0)
    end
    self.dist:SetText(("%d yd"):format(dist))
  end)
end

function W.UpdateArrowVisibility()
  if not arrow then return end
  if ns.db.arrow and #targets > 0 and not UsingTomTom() then arrow:Show() else arrow:Hide() end
end

---------------------------------------------------------------------------
-- Wiring
---------------------------------------------------------------------------
ns.On("Login", function()
  CreateArrow()
  W.UpdateArrowVisibility()
end)

-- The target is the current quest-plan sub-step when the step has a plan, else the step itself.
local function CurrentTarget()
  local step = ns.route[ns.ViewIndex()]
  if not step then return nil end
  local plan, first = ns.PlanProgress(step)
  if plan and first then
    local wps = ns.SubWaypoints(plan[first])
    if wps then return { id = step.id .. ":" .. first, title = ns.SubText(plan[first]), wp = wps } end
  end
  return step
end

ns.On("Refresh", function()
  if not ns.db.autoWaypoint then return end
  local target = CurrentTarget()
  if target and target.id ~= lastStepID then W.Set(target, false) end
end)

ns.On("SetWaypoints", function(step, announce) W.Set(step, announce) end)
ns.On("SettingsChanged", function()
  local step = ns.route[ns.ViewIndex()]
  W.Set(step, false)
end)
