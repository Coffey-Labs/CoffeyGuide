-- Coffey's Leveling Guide shared UI helpers.
local ADDON, ns = ...
local UI = {}
ns.UI = UI
local C = ns.COLORS

---------------------------------------------------------------------------
-- Fonts: private copies of the stock fonts so the guide's text size can change
-- without touching anything else in the game UI.
---------------------------------------------------------------------------
local fonts = {}
function UI.Font(base)
  base = base or "GameFontHighlightSmall"
  if type(base) ~= "string" then return base end
  local f = fonts[base]
  if f then return f.obj end
  local src = _G[base]
  if not CreateFont or not src or not src.GetFont then return base end
  local obj = CreateFont("CoffeyGuide_" .. base)
  obj:CopyFontObject(src)
  local path, size, flags = src:GetFont()
  fonts[base] = { obj = obj, path = path, size = size, flags = flags }
  if path and size then obj:SetFont(path, size * ((ns.db and ns.db.fontScale) or 1), flags) end
  return obj
end

function UI.ApplyFontScale()
  local scale = (ns.db and ns.db.fontScale) or 1
  for _, f in pairs(fonts) do
    if f.path and f.size then f.obj:SetFont(f.path, f.size * scale, f.flags) end
  end
end
---------------------------------------------------------------------------
-- Theme: flat dark glass panels, hairline borders, a soft shadow and an accent
-- color (your class color, or gold). Everything is drawn from one white pixel
-- texture, so it looks the same on every client and scales cleanly.
---------------------------------------------------------------------------
local FLAT = "Interface\\Buttons\\WHITE8x8"
UI.FLAT = FLAT

function UI.Accent()
  if ns.db and ns.db.accentGold then return 1, 0.78, 0.18 end
  local cls = ns.player and ns.player.class
  local c = cls and ((C_ClassColor and C_ClassColor.GetClassColor and C_ClassColor.GetClassColor(cls))
                     or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[cls]))
  if c and c.r then return c.r, c.g, c.b end
  return 1, 0.78, 0.18
end

function UI.AccentHex()
  local r, g, b = UI.Accent()
  return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
end

function UI.Gradient(tex, orient, a, b)
  if tex.SetGradient and CreateColor then
    pcall(tex.SetGradient, tex, orient, CreateColor(a[1], a[2], a[3], a[4]), CreateColor(b[1], b[2], b[3], b[4]))
  elseif tex.SetGradientAlpha then
    pcall(tex.SetGradientAlpha, tex, orient, a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
  end
end

-- Anything tinted with the accent registers here, so changing the accent repaints it.
local accented, painted = {}, {}
function UI.AccentTexture(tex, alpha)
  tex.cgAlpha = alpha or 1
  local r, g, b = UI.Accent()
  tex:SetColorTexture(r, g, b, tex.cgAlpha)
  accented[#accented + 1] = tex
  return tex
end

function UI.Restyle()
  local r, g, b = UI.Accent()
  for _, t in ipairs(accented) do t:SetColorTexture(r, g, b, t.cgAlpha or 1) end
  for _, w in ipairs(painted) do if w.Paint then w:Paint() end end
end

local function Flat(f, bg, border)
  f:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1, insets = { left = 1, right = 1, top = 1, bottom = 1 } })
  f:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
  f:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end
UI.Flat = Flat

function UI.Style(f, alpha)
  Flat(f, { 0.05, 0.055, 0.07, alpha or 0.92 }, { 1, 1, 1, 0.10 })
  if f.cgStyled then return end
  f.cgStyled = true
  -- Soft shadow just outside the edge.
  local sh = CreateFrame("Frame", nil, f, "BackdropTemplate")
  sh:SetPoint("TOPLEFT", -3, 3); sh:SetPoint("BOTTOMRIGHT", 3, -3)
  sh:SetFrameLevel(math.max(0, (f:GetFrameLevel() or 1) - 1))
  sh:SetBackdrop({ edgeFile = FLAT, edgeSize = 3 })
  sh:SetBackdropBorderColor(0, 0, 0, 0.35)
  -- A faint sheen across the top, and the accent stripe.
  local sheen = f:CreateTexture(nil, "BORDER")
  sheen:SetTexture(FLAT)
  sheen:SetPoint("TOPLEFT", 1, -1); sheen:SetPoint("TOPRIGHT", -1, -1); sheen:SetHeight(70)
  UI.Gradient(sheen, "VERTICAL", { 1, 1, 1, 0 }, { 1, 1, 1, 0.045 })
  local stripe = f:CreateTexture(nil, "ARTWORK")
  stripe:SetPoint("TOPLEFT", 1, -1); stripe:SetPoint("TOPRIGHT", -1, -1); stripe:SetHeight(2)
  UI.AccentTexture(stripe, 0.9)
  f.cgStripe = stripe
end

function UI.Panel(name, parent, w, h)
  local f = CreateFrame("Frame", name, parent or UIParent, "BackdropTemplate")
  f:SetSize(w, h)
  UI.Style(f)
  return f
end

-- Fade (and optionally slide) a frame in whenever it is shown.
function UI.FadeIn(f, slide)
  if not f.CreateAnimationGroup then return end
  local ag = f:CreateAnimationGroup()
  local a = ag:CreateAnimation("Alpha")
  a:SetFromAlpha(0); a:SetToAlpha(1); a:SetDuration(0.18)
  if a.SetSmoothing then a:SetSmoothing("OUT") end
  if slide then
    local t = ag:CreateAnimation("Translation")
    t:SetOffset(0, slide); t:SetDuration(0.01); t:SetOrder(1)
    local t2 = ag:CreateAnimation("Translation")
    t2:SetOffset(0, -slide); t2:SetDuration(0.22); t2:SetOrder(2)
    if t2.SetSmoothing then t2:SetSmoothing("OUT") end
    a:SetOrder(2)
  end
  f:HookScript("OnShow", function() ag:Stop(); ag:Play() end)
  return ag
end

function UI.Text(parent, font, layer)
  local fs = parent:CreateFontString(nil, layer or "OVERLAY")
  fs:SetFontObject(UI.Font(font or "GameFontHighlightSmall"))
  fs:SetJustifyH("LEFT")
  fs:SetJustifyV("TOP")
  return fs
end

-- Flat button. kind = "primary" fills it with the accent color.
function UI.Button(parent, text, width, onClick, kind)
  local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
  b:SetSize(width, 22)
  b.text = b:CreateFontString(nil, "OVERLAY")
  b.text:SetFontObject(UI.Font("GameFontHighlightSmall"))
  b.text:SetPoint("CENTER", 0, 0)
  b:SetFontString(b.text)
  b:SetText(text)
  if b.SetPushedTextOffset then b:SetPushedTextOffset(0, -1) end
  b.kind = kind
  function b:Paint()
    local r, g, bl = UI.Accent()
    if self.IsEnabled and not self:IsEnabled() then
      Flat(self, { 1, 1, 1, 0.02 }, { 1, 1, 1, 0.06 }); self.text:SetTextColor(0.45, 0.45, 0.45); return
    end
    if self.kind == "primary" then
      Flat(self, { r, g, bl, self.hover and 0.55 or 0.38 }, { r, g, bl, 0.95 }); self.text:SetTextColor(1, 1, 1)
    elseif self.active then
      Flat(self, { r, g, bl, self.hover and 0.32 or 0.22 }, { r, g, bl, 0.8 }); self.text:SetTextColor(1, 1, 1)
    else
      Flat(self, { 1, 1, 1, self.hover and 0.10 or 0.045 }, { 1, 1, 1, self.hover and 0.28 or 0.12 })
      self.text:SetTextColor(0.9, 0.9, 0.9)
    end
  end
  function b:SetActive(on) self.active = on and true or nil; self:Paint() end
  b:HookScript("OnEnter", function(self) self.hover = true; self:Paint() end)
  b:HookScript("OnLeave", function(self) self.hover = nil; self:Paint() end)
  b:HookScript("OnEnable", function(self) self:Paint() end)
  b:HookScript("OnDisable", function(self) self:Paint() end)
  b:SetScript("OnClick", onClick)
  b:Paint()
  painted[#painted + 1] = b
  return b
end

function UI.Tooltip(owner, title, lines)
  owner:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    local t = type(title) == "function" and title() or title
    GameTooltip:AddLine(t or "", 1, 0.82, 0)
    local l = type(lines) == "function" and lines() or lines
    if type(l) == "string" then GameTooltip:AddLine(l, 1, 1, 1, true)
    elseif type(l) == "table" then for _, s in ipairs(l) do GameTooltip:AddLine(s, 1, 1, 1, true) end end
    GameTooltip:Show()
  end)
  owner:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

local function Hover(b, alpha)
  b:SetHighlightTexture(FLAT)
  local h = b.GetHighlightTexture and b:GetHighlightTexture()
  if h then h:SetVertexColor(1, 1, 1, alpha or 0.12) end
end
UI.Hover = Hover

function UI.IconButton(parent, size, texture, title, tip, onClick)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(size, size)
  b.icon = b:CreateTexture(nil, "ARTWORK")
  b.icon:SetAllPoints()
  b.icon:SetTexture(texture)
  b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  Hover(b)
  b:SetScript("OnClick", onClick)
  UI.Tooltip(b, title, tip)
  b.SetEnabledState = function(self, on)
    self:SetEnabled(on)
    self.icon:SetDesaturated(not on)
    self.icon:SetAlpha(on and 1 or 0.4)
  end
  return b
end

-- Crisp line-drawn glyph buttons: close, minus, plus, left, right.
local function Line(b, w, h, deg, x, y)
  local t = b:CreateTexture(nil, "OVERLAY")
  t:SetTexture(FLAT); t:SetSize(w, h); t:SetPoint("CENTER", x or 0, y or 0)
  if deg ~= 0 and t.SetRotation then t:SetRotation(math.rad(deg)) end
  b.lines[#b.lines + 1] = t
  return t
end

function UI.Glyph(parent, size, glyph, title, tip, onClick)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(size, size)
  b.lines = {}
  local l, w = size * 0.55, 1.5
  if glyph == "close" then Line(b, l, w, 45); Line(b, l, w, -45)
  elseif glyph == "minus" then Line(b, l, w, 0)
  elseif glyph == "plus" then Line(b, l, w, 0); Line(b, w, l, 0)
  elseif glyph == "left" or glyph == "right" then
    local arm, d = l * 0.62, l * 0.22
    local s = glyph == "left" and 1 or -1
    Line(b, arm, w, 45 * s, 0, d); Line(b, arm, w, -45 * s, 0, -d)
  end
  b.bg = b:CreateTexture(nil, "BACKGROUND"); b.bg:SetAllPoints(); b.bg:SetColorTexture(1, 1, 1, 0)
  function b:Paint()
    local on = not self.IsEnabled or self:IsEnabled()
    local r, g, bl = UI.Accent()
    for _, t in ipairs(self.lines) do
      if not on then t:SetVertexColor(0.5, 0.5, 0.5, 0.35)
      elseif self.hover then t:SetVertexColor(glyph == "close" and 1 or r, glyph == "close" and 0.35 or g, glyph == "close" and 0.3 or bl, 1)
      else t:SetVertexColor(0.85, 0.85, 0.85, 0.9) end
    end
    self.bg:SetColorTexture(1, 1, 1, (on and self.hover) and 0.08 or 0)
  end
  b:HookScript("OnEnter", function(self) self.hover = true; self:Paint() end)
  b:HookScript("OnLeave", function(self) self.hover = nil; self:Paint() end)
  b:SetScript("OnClick", onClick)
  if title then UI.Tooltip(b, title, tip) end
  b.SetEnabledState = function(self, on) self:SetEnabled(on); self:Paint() end
  b.SetGlyph = function(self, g2)
    -- minus <-> plus: show or hide the vertical bar.
    if self.lines[2] then self.lines[2]:SetShown(g2 == "plus") end
  end
  b:Paint()
  painted[#painted + 1] = b
  return b
end

function UI.CloseButton(parent, onClick)
  local b = UI.Glyph(parent, 20, "close", nil, nil, onClick or function() parent:Hide() end)
  b:SetPoint("TOPRIGHT", -5, -5)
  return b
end

function UI.Icon(parent, size, texture)
  local t = parent:CreateTexture(nil, "ARTWORK")
  t:SetSize(size, size)
  if texture then t:SetTexture(texture) end
  t:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  return t
end

-- A 1px dark outline behind an icon texture (follows the icon wherever it is anchored).
function UI.IconBorder(icon)
  local p = icon:GetParent()
  local t = p:CreateTexture(nil, "BORDER")
  t:SetColorTexture(0, 0, 0, 0.8)
  t:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1); t:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
  return t
end

function UI.ClassIcon(tex, class)
  tex:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
  local c = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[class]
  if c then tex:SetTexCoord(c[1], c[2], c[3], c[4]) end
end

-- Progress bar: dark track, accent fill with a gentle gradient.
function UI.Bar(parent, w, h)
  local bar = CreateFrame("StatusBar", nil, parent, "BackdropTemplate")
  bar:SetSize(w, h)
  bar:SetStatusBarTexture(FLAT)
  Flat(bar, { 0, 0, 0, 0.45 }, { 1, 1, 1, 0.08 })
  function bar:Paint()
    local r, g, b = UI.Accent()
    local t = self:GetStatusBarTexture()
    if t then
      t:SetVertexColor(1, 1, 1, 1)
      UI.Gradient(t, "HORIZONTAL", { r * 0.55, g * 0.55, b * 0.55, 0.95 }, { r, g, b, 1 })
    else
      self:SetStatusBarColor(r, g, b)
    end
  end
  bar:Paint()
  painted[#painted + 1] = bar
  bar.text = bar:CreateFontString(nil, "OVERLAY")
  bar.text:SetFontObject(UI.Font("GameFontHighlightSmall"))
  bar.text:SetShadowOffset(1, -1)
  bar.text:SetPoint("CENTER")
  return bar
end

-- Flat checkbox; the label is part of the click area.
function UI.Check(parent, label, get, set, tip)
  local cb = CreateFrame("CheckButton", nil, parent, "BackdropTemplate")
  cb:SetSize(16, 16)
  local mark = cb:CreateTexture(nil, "ARTWORK")
  mark:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
  mark:SetSize(20, 20); mark:SetPoint("CENTER", 1, 0)
  cb:SetCheckedTexture(mark)
  function cb:Paint()
    local r, g, b = UI.Accent()
    mark:SetVertexColor(r, g, b)
    Flat(self, { 0, 0, 0, 0.45 }, self.hover and { r, g, b, 0.9 } or { 1, 1, 1, 0.25 })
  end
  cb.label = UI.Text(cb, "GameFontHighlight")
  cb.label:SetPoint("LEFT", cb, "RIGHT", 7, 0)
  cb.label:SetText(label)
  -- The label is part of the click area; settings pages call SetLabelWidth once the label's width is final.
  function cb:SetLabelWidth(w)
    self.label:SetWidth(w)
    self:SetHitRectInsets(0, -math.min(w, (self.label:GetStringWidth() or w) + 8), -3, -3)
  end
  cb:SetHitRectInsets(0, -math.min(260, (cb.label:GetStringWidth() or 100) + 8), -3, -3)
  cb:HookScript("OnEnter", function(self) self.hover = true; self:Paint() end)
  cb:HookScript("OnLeave", function(self) self.hover = nil; self:Paint() end)
  cb:SetScript("OnShow", function(self) self:SetChecked(get()) end)
  cb:SetScript("OnClick", function(self) set(self:GetChecked() and true or false) end)
  cb:SetChecked(get())
  cb:Paint()
  painted[#painted + 1] = cb
  if tip then UI.Tooltip(cb, label, tip) end
  return cb
end

-- Slider: a thin track with an accent thumb.
function UI.Slider(parent, label, width, minV, maxV, step, get, set, fmt)
  local holder = CreateFrame("Frame", nil, parent)
  holder:SetSize(width, 40)
  holder.label = UI.Text(holder, "GameFontHighlightSmall")
  holder.label:SetPoint("TOPLEFT", 2, 0)
  local s = CreateFrame("Slider", nil, holder)
  s:SetOrientation("HORIZONTAL")
  s:EnableMouse(true)
  s:SetSize(width - 10, 14)
  s:SetPoint("TOPLEFT", holder.label, "BOTTOMLEFT", 0, -6)
  local track = s:CreateTexture(nil, "BACKGROUND")
  track:SetColorTexture(1, 1, 1, 0.14); track:SetHeight(3)
  track:SetPoint("LEFT"); track:SetPoint("RIGHT")
  local thumb = s:CreateTexture(nil, "OVERLAY")
  thumb:SetSize(8, 14)
  UI.AccentTexture(thumb, 1)
  s:SetThumbTexture(thumb)
  s:SetMinMaxValues(minV, maxV)
  s:SetValueStep(step)
  if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
  local function show(v) holder.label:SetText(label .. ": |cffffffff" .. (fmt and fmt(v) or tostring(v)) .. "|r") end
  s:SetScript("OnValueChanged", function(_, v, user)
    v = math.floor(v / step + 0.5) * step
    show(v)
    if user ~= false then set(v) end
  end)
  holder:SetScript("OnShow", function() local v = get(); s:SetValue(v); show(v) end)
  s:SetValue(get()); show(get())
  s:EnableMouseWheel(true)
  s:SetScript("OnMouseWheel", function(self, d)
    local v = math.max(minV, math.min(maxV, self:GetValue() + d * step))
    self:SetValue(v); set(v)
  end)
  holder.slider = s
  return holder
end

-- A section title in the accent color with a hairline under it, for settings pages.
function UI.Section(parent, title)
  local t = UI.Text(parent, "GameFontNormal")
  t:SetText(title)
  local line = parent:CreateTexture(nil, "ARTWORK")
  line:SetColorTexture(1, 1, 1, 0.10)
  line:SetHeight(1)
  line:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -4)
  line:SetPoint("RIGHT", parent, "RIGHT", -8, 0)
  local tick = parent:CreateTexture(nil, "OVERLAY")
  tick:SetHeight(1); tick:SetWidth(28)
  tick:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -4)
  UI.AccentTexture(tick, 1)
  return t
end

-- Segmented control: one flat button per option, the active one filled with the accent.
function UI.Segmented(parent, options, get, set)
  local holder = CreateFrame("Frame", nil, parent)
  holder.buttons = {}
  local x = 0
  for i, opt in ipairs(options) do
    local b = UI.Button(holder, opt.label, 70, function() set(opt.value); holder:Update() end)
    b:SetWidth(math.max(70, b.text:GetStringWidth() + 26))
    b:SetPoint("LEFT", holder, "LEFT", x, 0)
    x = x + b:GetWidth() - 1
    if opt.tip then UI.Tooltip(b, opt.label, opt.tip) end
    holder.buttons[i] = b
  end
  holder:SetSize(math.max(x, 10), 22)
  function holder:Update()
    local cur = get()
    for i, opt in ipairs(options) do self.buttons[i]:SetActive(opt.value == cur) end
  end
  holder:SetScript("OnShow", function(self) self:Update() end)
  holder:Update()
  return holder
end

-- Slim scrollbar: no arrow buttons, a thin track and a soft thumb.
function UI.SkinScroll(scroll)
  pcall(function()
    local sb = scroll.ScrollBar or (scroll:GetName() and _G[scroll:GetName() .. "ScrollBar"])
    if not sb then return end
    for _, key in ipairs({ "ScrollUpButton", "ScrollDownButton" }) do
      local btn = sb[key] or (sb:GetName() and _G[sb:GetName() .. key])
      if btn then btn:SetAlpha(0); btn:EnableMouse(false); btn:SetSize(1, 1) end
    end
    sb:ClearAllPoints()
    sb:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 10, 0)
    sb:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 10, 0)
    sb:SetWidth(6)
    local track = sb:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints(); track:SetColorTexture(1, 1, 1, 0.05)
    local thumb = sb.ThumbTexture or (sb.GetThumbTexture and sb:GetThumbTexture())
    if thumb then thumb:SetTexture(FLAT); thumb:SetVertexColor(1, 1, 1, 0.28); thumb:SetSize(6, 40) end
  end)
end

-- Status icons drawn from stock textures.
UI.STATUS = {
  done    = "Interface\\RaidFrame\\ReadyCheck-Ready",
  current = "Interface\\RaidFrame\\ReadyCheck-Waiting",
  todo    = "Interface\\Buttons\\UI-CheckBox-Up",
  skipped = "Interface\\RaidFrame\\ReadyCheck-NotReady",
}

---------------------------------------------------------------------------
-- Scrollable row list with pooled rows.
-- list:Clear(); list:Add{ icon=, icon2=, title=, sub=, right=, status=, onClick=, onEnter=, header= }; list:Done()
---------------------------------------------------------------------------
function UI.ScrollList(parent)
  local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(10, 10)
  scroll:SetScrollChild(content)
  scroll:SetScript("OnSizeChanged", function(self, w) content:SetWidth(w) end)
  UI.SkinScroll(scroll)

  local list = { scroll = scroll, content = content, rows = {}, used = 0, y = 0, marks = {} }

  local function NewRow()
    local r = CreateFrame("Button", nil, content)
    Hover(r)
    r.bg = r:CreateTexture(nil, "BACKGROUND")
    r.bg:SetAllPoints()
    r.bar = r:CreateTexture(nil, "BORDER")
    r.bar:SetPoint("TOPLEFT"); r.bar:SetPoint("BOTTOMLEFT"); r.bar:SetWidth(2)
    r.status = r:CreateTexture(nil, "ARTWORK")
    r.status:SetSize(16, 16)
    r.icon = UI.Icon(r, 26)
    r.icon2 = UI.Icon(r, 18)
    r.title = UI.Text(r, "GameFontNormal")
    r.check = CreateFrame("Button", nil, r)
    r.check:SetSize(18, 18)
    Hover(r.check)
    r.check:SetScript("OnClick", function(self) if self.fn then self.fn() end end)
    r.check:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(self.tip or "Mark done / not done"); GameTooltip:Show()
    end)
    r.check:SetScript("OnLeave", function() GameTooltip:Hide() end)
    r.sub = UI.Text(r, "GameFontHighlightSmall")
    r.right = UI.Text(r, "GameFontHighlightSmall")
    r.right:SetJustifyH("RIGHT")
    r:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return r
  end

  function list:Clear()
    for i = 1, self.used do self.rows[i]:Hide() end
    self.used, self.y = 0, 0
    self.pendingHeader, self.matches = nil, 0
    wipe(self.marks)
  end

  -- Filter rows by a search string (headers show only above a matching row).
  function list:SetFilter(text)
    text = text and text:lower():gsub("^%s+", ""):gsub("%s+$", "") or ""
    self.filter = text ~= "" and text or nil
  end

  local function Plain(s) return ((s or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):lower()) end

  -- Remember where a row lands, so the view can scroll to it after Done().
  function list:Mark(key) self.marks[key] = self.y end

  function list:ScrollToMark(key, offset)
    local y = self.marks[key]
    if not y then return end
    local max = self.scroll.GetVerticalScrollRange and self.scroll:GetVerticalScrollRange() or 0
    self.scroll:SetVerticalScroll(math.max(0, math.min(max, y - (offset or 40))))
  end

  function list:Add(o)
    if self.filter then
      if o.header then self.pendingHeader = o; return end
      if not o.always then
        local hay = Plain(o.title) .. " " .. Plain(o.sub) .. " " .. Plain(o.search)
        if not hay:find(self.filter, 1, true) then return end
      end
      self.matches = self.matches + 1
      if self.pendingHeader then local h = self.pendingHeader; self.pendingHeader = nil; self:Place(h) end
    end
    return self:Place(o)
  end

  function list:Place(o)
    self.used = self.used + 1
    local r = self.rows[self.used]
    if not r then r = NewRow(); self.rows[self.used] = r end
    local width = content:GetWidth() > 50 and content:GetWidth() or (scroll:GetWidth() > 50 and scroll:GetWidth() or 500)
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -self.y)
    r:SetWidth(width)

    local x = 4
    if o.header then
      r.status:Hide(); r.icon:Hide(); r.icon2:Hide(); r.check:Hide(); r.sub:SetText(""); r.right:SetText("")
      r.title:SetFontObject(UI.Font("GameFontNormalLarge"))
      r.title:SetAlpha(1); r.sub:SetAlpha(1)
      r.title:ClearAllPoints(); r.title:SetPoint("TOPLEFT", r, "TOPLEFT", 4, -8)
      r.title:SetWidth(width - 8)
      r.title:SetText(o.title or "")
      local ar, ag, ab = UI.Accent()
      r.bg:SetTexture(FLAT); r.bg:SetVertexColor(1, 1, 1, 1)
      UI.Gradient(r.bg, "HORIZONTAL", { ar, ag, ab, 0.16 }, { ar, ag, ab, 0 })
      r.bar:SetColorTexture(ar, ag, ab, 0.9); r.bar:Show()
      local h = 30
      r:SetHeight(h); self.y = self.y + h + 2
      r:SetScript("OnClick", nil); r:SetScript("OnEnter", nil)
      r:Show()
      return r
    end

    r.title:SetFontObject(UI.Font(o.titleFont or "GameFontNormal"))
    -- A status icon with onCheck becomes a real checkbox: click it to toggle.
    if o.status and o.onCheck then
      r.status:Show(); r.status:SetTexture(o.status)
      r.status:ClearAllPoints(); r.status:SetPoint("TOPLEFT", r, "TOPLEFT", x, -6)
      r.check:Show(); r.check:ClearAllPoints(); r.check:SetPoint("CENTER", r.status, "CENTER")
      r.check.fn, r.check.tip = o.onCheck, o.checkTip
      x = x + 20
    elseif o.status then
      r.check:Hide()
      r.status:Show(); r.status:SetTexture(o.status)
      r.status:ClearAllPoints(); r.status:SetPoint("TOPLEFT", r, "TOPLEFT", x, -6); x = x + 20
    else r.status:Hide(); r.check:Hide() end
    if o.icon then
      r.icon:Show(); r.icon:SetTexture(o.icon)
      if o.iconCoords then r.icon:SetTexCoord(unpack(o.iconCoords)) else r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
      r.icon:SetDesaturated(o.dim and true or false)
      r.icon:SetPoint("TOPLEFT", r, "TOPLEFT", x, -3); x = x + 30
    else r.icon:Hide() end
    if o.icon2 then r.icon2:Show(); r.icon2:SetTexture(o.icon2); r.icon2:SetPoint("TOPLEFT", r, "TOPLEFT", x, -6); x = x + 22
    else r.icon2:Hide() end

    local rightW = o.right and (o.rightWidth or 110) or 0
    r.right:SetText(o.right or "")
    r.right:SetWidth(rightW)
    r.right:ClearAllPoints(); r.right:SetPoint("TOPRIGHT", r, "TOPRIGHT", -6, -6)

    local textW = width - x - rightW - 10
    r.title:ClearAllPoints(); r.title:SetPoint("TOPLEFT", r, "TOPLEFT", x, -4)
    r.title:SetWidth(textW); r.title:SetText(o.title or "")
    r.sub:ClearAllPoints(); r.sub:SetPoint("TOPLEFT", r.title, "BOTTOMLEFT", 0, -2)
    r.sub:SetWidth(textW); r.sub:SetText(o.sub or "")

    local alpha = o.dim and 0.55 or 1
    r.title:SetAlpha(alpha); r.sub:SetAlpha(alpha)
    local ar, ag, ab = UI.Accent()
    if r.bg.SetGradient and CreateColor then UI.Gradient(r.bg, "HORIZONTAL", { 1, 1, 1, 1 }, { 1, 1, 1, 1 }) end
    if o.highlight then r.bg:SetColorTexture(ar, ag, ab, 0.13); r.bar:SetColorTexture(ar, ag, ab, 0.9); r.bar:Show()
    elseif self.used % 2 == 0 then r.bg:SetColorTexture(1, 1, 1, 0.025); r.bar:Hide()
    else r.bg:SetColorTexture(0, 0, 0, 0); r.bar:Hide() end

    local h = 8 + r.title:GetStringHeight() + ((o.sub and o.sub ~= "") and (r.sub:GetStringHeight() + 2) or 0)
    h = math.max(h, o.icon and 32 or 22)
    r:SetHeight(h)
    self.y = self.y + h + 1
    r:SetScript("OnClick", o.onClick)
    r:SetScript("OnEnter", o.onEnter)
    r:Show()
    return r
  end

  function list:Done()
    if self.filter and self.matches == 0 then
      self:Place({ title = "|cff808080No matches for \"" .. self.filter .. "\".|r", sub = "Clear the search box to see everything." })
    end
    content:SetHeight(math.max(self.y, 10))
  end

  return list
end

---------------------------------------------------------------------------
-- Copyable link popup (WoW can't open URLs; select + Ctrl+C instead)
---------------------------------------------------------------------------
local linkBox
function ns.ShowLink(url)
  if not linkBox then
    linkBox = UI.Panel("CoffeyGuideLinkPopup", UIParent, 340, 74)
    linkBox:SetPoint("CENTER", 0, 120)
    linkBox:SetFrameStrata("FULLSCREEN_DIALOG")
    local t = UI.Text(linkBox, "GameFontNormal")
    t:SetPoint("TOP", 0, -10); t:SetJustifyH("CENTER")
    t:SetText("Press Ctrl+C to copy, then Escape")
    local eb = CreateFrame("EditBox", nil, linkBox, "InputBoxTemplate")
    eb:SetSize(290, 22); eb:SetPoint("TOP", t, "BOTTOM", 0, -8)
    eb:SetAutoFocus(true)
    eb:SetScript("OnEscapePressed", function() linkBox:Hide() end)
    eb:SetScript("OnEnterPressed", function() linkBox:Hide() end)
    eb:SetScript("OnTextChanged", function(self) self:SetText(linkBox.url or ""); self:HighlightText() end)
    linkBox.eb = eb
    UI.CloseButton(linkBox)
  end
  linkBox.url = url
  linkBox:Show()
  linkBox.eb:SetText(url); linkBox.eb:SetFocus(); linkBox.eb:HighlightText()
end
