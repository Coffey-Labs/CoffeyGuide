-- Coffey's Leveling Guide shared UI helpers.
local ADDON, ns = ...
local UI = {}
ns.UI = UI
local C = ns.COLORS

function UI.Style(f, alpha)
  f:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 14,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  f:SetBackdropColor(C.bg[1], C.bg[2], C.bg[3], alpha or C.bg[4])
  f:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], C.border[4])
end

function UI.Panel(name, parent, w, h)
  local f = CreateFrame("Frame", name, parent or UIParent, "BackdropTemplate")
  f:SetSize(w, h)
  UI.Style(f)
  return f
end

function UI.Text(parent, font, layer)
  local fs = parent:CreateFontString(nil, layer or "OVERLAY", font or "GameFontHighlightSmall")
  fs:SetJustifyH("LEFT")
  fs:SetJustifyV("TOP")
  return fs
end

function UI.Button(parent, text, width, onClick)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(width, 22)
  b:SetText(text)
  b:SetScript("OnClick", onClick)
  return b
end

function UI.Tooltip(owner, title, lines)
  owner:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    local t = type(title) == "function" and title() or title
    GameTooltip:AddLine(t or "", 1, 0.82, 0)
    local l = type(lines) == "function" and lines() or lines
    if type(l) == "string" then GameTooltip:AddLine(l, 1, 1, 1, true)
    elseif type(l) == "table" then for _, s in ipairs(l) do GameTooltip:AddLine(s, 1, 1, 1, true) end end
    GameTooltip:Show()
  end)
  owner:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function UI.IconButton(parent, size, texture, title, tip, onClick)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(size, size)
  b.icon = b:CreateTexture(nil, "ARTWORK")
  b.icon:SetAllPoints()
  b.icon:SetTexture(texture)
  b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
  b:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
  b:SetScript("OnClick", onClick)
  UI.Tooltip(b, title, tip)
  b.SetEnabledState = function(self, on)
    self:SetEnabled(on)
    self.icon:SetDesaturated(not on)
    self.icon:SetAlpha(on and 1 or 0.4)
  end
  return b
end

function UI.Icon(parent, size, texture)
  local t = parent:CreateTexture(nil, "ARTWORK")
  t:SetSize(size, size)
  if texture then t:SetTexture(texture) end
  t:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  return t
end

function UI.ClassIcon(tex, class)
  tex:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
  local c = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[class]
  if c then tex:SetTexCoord(c[1], c[2], c[3], c[4]) end
end

function UI.Bar(parent, w, h)
  local bar = CreateFrame("StatusBar", nil, parent, "BackdropTemplate")
  bar:SetSize(w, h)
  bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  bar:SetStatusBarColor(0.85, 0.65, 0.1)
  bar:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
  bar:SetBackdropColor(0, 0, 0, 0.6)
  bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  bar.text:SetPoint("CENTER")
  return bar
end

function UI.Check(parent, label, get, set)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetSize(24, 24)
  cb.label = UI.Text(cb, "GameFontHighlight")
  cb.label:SetPoint("LEFT", cb, "RIGHT", 2, 0)
  cb.label:SetText(label)
  cb:SetScript("OnShow", function(self) self:SetChecked(get()) end)
  cb:SetScript("OnClick", function(self) set(self:GetChecked() and true or false) end)
  cb:SetChecked(get())
  return cb
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

  local list = { scroll = scroll, content = content, rows = {}, used = 0, y = 0 }

  local function NewRow()
    local r = CreateFrame("Button", nil, content)
    r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    r.bg = r:CreateTexture(nil, "BACKGROUND")
    r.bg:SetAllPoints()
    r.status = r:CreateTexture(nil, "ARTWORK")
    r.status:SetSize(16, 16)
    r.icon = UI.Icon(r, 26)
    r.icon2 = UI.Icon(r, 18)
    r.title = UI.Text(r, "GameFontNormal")
    r.sub = UI.Text(r, "GameFontHighlightSmall")
    r.right = UI.Text(r, "GameFontHighlightSmall")
    r.right:SetJustifyH("RIGHT")
    r:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return r
  end

  function list:Clear()
    for i = 1, self.used do self.rows[i]:Hide() end
    self.used, self.y = 0, 0
  end

  function list:Add(o)
    self.used = self.used + 1
    local r = self.rows[self.used]
    if not r then r = NewRow(); self.rows[self.used] = r end
    local width = content:GetWidth() > 50 and content:GetWidth() or (scroll:GetWidth() > 50 and scroll:GetWidth() or 500)
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -self.y)
    r:SetWidth(width)

    local x = 4
    if o.header then
      r.status:Hide(); r.icon:Hide(); r.icon2:Hide(); r.sub:SetText(""); r.right:SetText("")
      r.title:SetFontObject("GameFontNormalLarge")
      r.title:ClearAllPoints(); r.title:SetPoint("TOPLEFT", r, "TOPLEFT", 4, -8)
      r.title:SetWidth(width - 8)
      r.title:SetText(o.title or "")
      r.bg:SetColorTexture(0.5, 0.4, 0.1, 0.25)
      local h = 30
      r:SetHeight(h); self.y = self.y + h + 2
      r:SetScript("OnClick", nil); r:SetScript("OnEnter", nil)
      r:Show()
      return r
    end

    r.title:SetFontObject(o.titleFont or "GameFontNormal")
    if o.status then r.status:Show(); r.status:SetTexture(o.status); r.status:SetPoint("TOPLEFT", r, "TOPLEFT", x, -6); x = x + 20
    else r.status:Hide() end
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
    if o.highlight then r.bg:SetColorTexture(1, 0.82, 0, 0.12)
    elseif self.used % 2 == 0 then r.bg:SetColorTexture(1, 1, 1, 0.03)
    else r.bg:SetColorTexture(0, 0, 0, 0) end

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
    local close = CreateFrame("Button", nil, linkBox, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 2, 2)
  end
  linkBox.url = url
  linkBox:Show()
  linkBox.eb:SetText(url); linkBox.eb:SetFocus(); linkBox.eb:HighlightText()
end
