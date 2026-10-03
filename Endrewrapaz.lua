-- ==========================================================
--  💀 PAINEL PRO v3.0 — Aim + Speed + ESP + Noclip + Voo + Fullbright + Config
-- ==========================================================

repeat task.wait(0.1) until game:IsLoaded()

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Stats            = game:GetService("Stats")
local Lighting         = game:GetService("Lighting")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Camera    = workspace.CurrentCamera

local THEME = {
    Bg      = Color3.fromRGB(26, 28, 46),
    Bg2     = Color3.fromRGB(40, 44, 70),
    Surface = Color3.fromRGB(33, 36, 58),
    Card    = Color3.fromRGB(47, 52, 80),
    Accent  = Color3.fromRGB(139, 108, 255),
    Accent2 = Color3.fromRGB(56, 189, 248),
    Text    = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(190, 196, 224),
    Off     = Color3.fromRGB(88, 94, 130),
    Success = Color3.fromRGB(52, 211, 153),
    Danger  = Color3.fromRGB(239, 68, 68),
    White   = Color3.new(1, 1, 1),
}

local PRESETS = {
    { "Roxo",    Color3.fromRGB(139, 108, 255), Color3.fromRGB(56, 189, 248) },
    { "Rosa",    Color3.fromRGB(244, 114, 182), Color3.fromRGB(251, 146, 60) },
    { "Verde",   Color3.fromRGB(52, 211, 153),  Color3.fromRGB(56, 189, 248) },
    { "Laranja", Color3.fromRGB(251, 146, 60),  Color3.fromRGB(250, 204, 21) },
    { "Azul",    Color3.fromRGB(59, 130, 246),  Color3.fromRGB(167, 139, 250) },
    { "Ciano",   Color3.fromRGB(34, 211, 238),  Color3.fromRGB(52, 211, 153) },
}

local ESP_COLORS = {
    { "Vermelho", Color3.fromRGB(255, 30, 30) },
    { "Azul",     Color3.fromRGB(56, 130, 255) },
    { "Verde",    Color3.fromRGB(52, 211, 100) },
    { "Amarelo",  Color3.fromRGB(250, 204, 21) },
    { "Roxo",     Color3.fromRGB(170, 60, 255) },
    { "Ciano",    Color3.fromRGB(34, 211, 238) },
    { "Rosa",     Color3.fromRGB(255, 100, 200) },
    { "Branco",   Color3.fromRGB(255, 255, 255) },
}

local BUBBLE = 64
local AnimEnabled = true

local connections = {}
local function connect(sig, fn)
    local c = sig:Connect(fn); table.insert(connections, c); return c
end

local function tween(o, p, t, style, dir)
    if not AnimEnabled then
        for k, v in pairs(p) do
            pcall(function() o[k] = v end)
        end
        return nil
    end
    local tw = TweenService:Create(o, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), p)
    tw:Play(); return tw
end

local function make(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    inst.Parent = parent
    return inst
end
local function round(o, r) return make("UICorner", { CornerRadius = UDim.new(0, r or 10) }, o) end
local function stroke(o, c, t, tr)
    return make("UIStroke", {
        Color = c or THEME.White, Thickness = t or 1, Transparency = tr or 0.9,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end

local updaters = {}
local function themed(fn) table.insert(updaters, fn); fn() end
local function applyTheme(a, b)
    THEME.Accent, THEME.Accent2 = a, b
    for _, fn in ipairs(updaters) do fn() end
end
local function accentSeq() return ColorSequence.new(THEME.Accent, THEME.Accent2) end
local function accentGradient(obj, rot)
    local g = make("UIGradient", { Rotation = rot or 0 }, obj)
    themed(function() g.Color = accentSeq() end)
    return g
end

local orderN = 0
local function order() orderN += 1; return orderN end
local function isPointer(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function isMove(i)
    return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local gui = make("ScreenGui", {
    Name = "PainelPro", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true, DisplayOrder = 100,
}, playerGui)

local root = make("Frame", {
    Name = "Root", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(520, 420),
    BackgroundTransparency = 1, Visible = false,
}, gui)

local PanelScaleMult = 1.0
local fit = make("UIScale", {}, root)
local function updateFit()
    local vp = gui.AbsoluteSize
    if vp.X > 0 and vp.Y > 0 then
        local base = math.clamp(math.min(vp.X / 560, vp.Y / 460), 0.5, 1)
        fit.Scale = base * PanelScaleMult
    end
end
connect(gui:GetPropertyChangedSignal("AbsoluteSize"), updateFit)
updateFit()

local win = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, root)
local anim = make("UIScale", { Scale = 0.7 }, win)

make("ImageLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 6),
    Size = UDim2.new(1, 46, 1, 46),
    BackgroundTransparency = 1,
    Image = "rbxassetid://1316045217",
    ImageColor3 = Color3.new(0, 0, 0),
    ImageTransparency = 0.45,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(10, 10, 118, 118),
}, win)

local main = make("Frame", {
    Name = "Main", Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = THEME.Bg, BorderSizePixel = 0, ClipsDescendants = true,
    BackgroundTransparency = 0,
}, win)
round(main, 18)
make("UIGradient", { Color = ColorSequence.new(THEME.Bg2, THEME.Bg), Rotation = 135 }, main)

local borderStroke = stroke(main, THEME.Accent, 2.5, 0.1)
local borderGrad = make("UIGradient", {}, borderStroke)
themed(function()
    borderGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.Accent),
        ColorSequenceKeypoint.new(0.5, THEME.Accent2),
        ColorSequenceKeypoint.new(1, THEME.Accent),
    })
end)
TweenService:Create(borderGrad, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), { Rotation = 360 }):Play()

local top = make("Frame", { Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1 }, main)
local logo = make("Frame", {
    Position = UDim2.fromOffset(14, 11), Size = UDim2.fromOffset(36, 36),
    BackgroundColor3 = THEME.Accent,
}, top)
round(logo, 11)
accentGradient(logo, 45)
make("TextLabel", {
    BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
    Text = "💀", TextColor3 = THEME.White, TextSize = 19, Font = Enum.Font.GothamBold,
}, logo)

make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(60, 11),
    Size = UDim2.new(1, -120, 0, 20),
    Text = "Painel Pro", TextColor3 = THEME.Text, TextSize = 17,
    Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
}, top)
make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(60, 31),
    Size = UDim2.new(1, -120, 0, 16),
    Text = "Aim • Speed • ESP • Noclip • Voo • Fullbright", TextColor3 = THEME.SubText, TextSize = 12,
    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
}, top)

local minBtn = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
    Size = UDim2.fromOffset(36, 36), BackgroundColor3 = THEME.Card,
    Text = "–", TextColor3 = THEME.Text, TextSize = 22,
    Font = Enum.Font.GothamBold, AutoButtonColor = false,
}, top)
round(minBtn, 18)
stroke(minBtn, THEME.White, 1, 0.8)
minBtn.MouseEnter:Connect(function() tween(minBtn, { BackgroundColor3 = THEME.Accent }) end)
minBtn.MouseLeave:Connect(function() tween(minBtn, { BackgroundColor3 = THEME.Card }) end)

make("Frame", {
    Position = UDim2.fromOffset(14, 58), Size = UDim2.new(1, -28, 0, 1),
    BackgroundColor3 = THEME.White, BackgroundTransparency = 0.88, BorderSizePixel = 0,
}, main)

do
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if isPointer(input) then
            dragging = true; dragStart = input.Position; startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if dragging and isMove(input) then
            local d = input.Position - dragStart
            root.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

local sidebar = make("Frame", {
    Position = UDim2.fromOffset(10, 68), Size = UDim2.new(0, 138, 1, -78),
    BackgroundColor3 = THEME.Surface, BorderSizePixel = 0,
}, main)
round(sidebar, 14)
stroke(sidebar, THEME.White, 1, 0.88)

local tabHolder = make("Frame", { Size = UDim2.new(1, 0, 1, -64), BackgroundTransparency = 1 }, sidebar)
make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, tabHolder)
make("UIPadding", {
    PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
}, tabHolder)

local profile = make("Frame", {
    AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 8, 1, -8),
    Size = UDim2.new(1, -16, 0, 48), BackgroundColor3 = THEME.Card,
    Visible = true,
}, sidebar)
round(profile, 12)

local avatar = make("ImageLabel", {
    Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(32, 32),
    BackgroundColor3 = THEME.Off, Image = "",
}, profile)
round(avatar, 16)
local avatarStroke = stroke(avatar, THEME.Accent, 2, 0)
themed(function() avatarStroke.Color = THEME.Accent end)
task.spawn(function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok then avatar.Image = img end
end)

make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(46, 8),
    Size = UDim2.new(1, -50, 0, 18), Text = player.DisplayName,
    TextColor3 = THEME.Text, TextSize = 13, Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
}, profile)
make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(46, 26),
    Size = UDim2.new(1, -50, 0, 14), Text = "● Online",
    TextColor3 = THEME.Success, TextSize = 11, Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
}, profile)

local content = make("Frame", {
    Position = UDim2.fromOffset(156, 59), Size = UDim2.new(1, -156, 1, -59),
    BackgroundTransparency = 1, ClipsDescendants = true,
}, main)

local pages, tabButtons = {}, {}
local currentTab

local function selectTab(name)
    currentTab = name
    for n, page in pairs(pages) do
        local active = (n == name)
        if active and not page.Visible then
            page.Position = UDim2.fromOffset(0, 16)
            tween(page, { Position = UDim2.fromOffset(0, 0) }, 0.35, Enum.EasingStyle.Quart)
        end
        page.Visible = active
        tween(tabButtons[n], {
            BackgroundTransparency = active and 0 or 1,
            TextColor3 = active and THEME.White or THEME.SubText,
        })
    end
end

local function newTab(name, icon, tabOrder)
    local btn = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = THEME.Accent,
        BackgroundTransparency = 1, Text = icon .. "  " .. name,
        TextColor3 = THEME.SubText, TextSize = 13, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
        LayoutOrder = tabOrder,
    }, tabHolder)
    round(btn, 10)
    make("UIPadding", { PaddingLeft = UDim.new(0, 10) }, btn)
    themed(function() btn.BackgroundColor3 = THEME.Accent end)

    btn.MouseEnter:Connect(function()
        if currentTab ~= name then tween(btn, { BackgroundTransparency = 0.8 }) end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then tween(btn, { BackgroundTransparency = 1 }) end
    end)

    local page = make("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 3,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, content)
    themed(function() page.ScrollBarImageColor3 = THEME.Accent end)
    make("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, page)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
    }, page)

    pages[name], tabButtons[name] = page, btn
    btn.Activated:Connect(function() selectTab(name) end)
    return page
end

local function text(parent, str, size, color, font)
    return make("TextLabel", {
        BackgroundTransparency = 1, Text = str, TextSize = size, TextColor3 = color,
        Font = font or Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, (size * 2) + 6), LayoutOrder = order(),
    }, parent)
end

local function card(parent, height)
    local c = make("Frame", {
        Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = THEME.Card,
        LayoutOrder = order(),
    }, parent)
    round(c, 12)
    stroke(c, THEME.White, 1, 0.86)
    return c
end

local function addToggle(parent, label, default, callback)
    local state = default or false
    local row = card(parent, 44)
    make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -80, 1, 0), Text = label,
        TextColor3 = THEME.Text, TextSize = 14, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local track = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(46, 26), BackgroundColor3 = THEME.Off,
        Text = "", AutoButtonColor = false,
    }, row)
    round(track, 13)
    themed(function() track.BackgroundColor3 = state and THEME.Accent or THEME.Off end)
    local knob = make("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = state and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(20, 20), BackgroundColor3 = THEME.White,
    }, track)
    round(knob, 10)
    track.Activated:Connect(function()
        state = not state
        tween(track, { BackgroundColor3 = state and THEME.Accent or THEME.Off })
        tween(knob, {
            Position = state and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        }, 0.3, Enum.EasingStyle.Back)
        if callback then callback(state) end
    end)
    return row
end

local function addSlider(parent, label, min, max, default, callback, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    local value = default or min
    local row = card(parent, 62)
    make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -100, 0, 20), Text = label,
        TextColor3 = THEME.Text, TextSize = 14, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local valueLabel = make("TextLabel", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 8), Size = UDim2.fromOffset(80, 20),
        Text = tostring(value), TextColor3 = THEME.Accent2, TextSize = 14,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right,
    }, row)
    themed(function() valueLabel.TextColor3 = THEME.Accent2 end)
    local bar = make("Frame", {
        Position = UDim2.new(0, 14, 0, 42), Size = UDim2.new(1, -28, 0, 8),
        BackgroundColor3 = THEME.Off,
    }, row)
    round(bar, 4)
    local fill = make("Frame", {
        Size = UDim2.fromScale((value - min) / (max - min), 1),
        BackgroundColor3 = THEME.Accent,
    }, bar)
    round(fill, 4)
    accentGradient(fill, 0)
    local knob = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(20, 20), BackgroundColor3 = THEME.White,
    }, fill)
    round(knob, 10)
    local knobStroke = stroke(knob, THEME.Accent, 3, 0)
    themed(function() knobStroke.Color = THEME.Accent end)
    local function update(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        value = math.floor((min + (max - min) * rel) * mult + 0.5) / mult
        valueLabel.Text = (decimals > 0) and string.format("%." .. decimals .. "f", value) or tostring(value)
        tween(fill, { Size = UDim2.fromScale(rel, 1) }, 0.06)
        if callback then callback(value) end
    end
    local sliding = false
    bar.InputBegan:Connect(function(input)
        if isPointer(input) then
            sliding = true
            parent.ScrollingEnabled = false
            update(input)
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if isPointer(input) and sliding then
            sliding = false
            parent.ScrollingEnabled = true
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if sliding and isMove(input) then update(input) end
    end)
    return row
end

local function addButton(parent, label, primary, callback)
    local holder = make("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = primary and THEME.Accent or THEME.Card,
        LayoutOrder = order(),
    }, parent)
    round(holder, 12)
    if primary then
        accentGradient(holder, 20)
    else
        stroke(holder, THEME.White, 1, 0.8)
    end
    local b = make("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = label, TextColor3 = THEME.White, TextSize = 14,
        Font = Enum.Font.GothamBold, AutoButtonColor = false,
    }, holder)
    b.MouseEnter:Connect(function()
        if not primary then tween(holder, { BackgroundColor3 = THEME.Off }) end
    end)
    b.MouseLeave:Connect(function()
        if not primary then tween(holder, { BackgroundColor3 = THEME.Card }) end
    end)
    b.Activated:Connect(function()
        tween(holder, { Size = UDim2.new(1, -8, 0, 38) }, 0.08)
        task.delay(0.09, function()
            tween(holder, { Size = UDim2.new(1, 0, 0, 42) }, 0.2, Enum.EasingStyle.Back)
        end)
        if callback then task.spawn(callback) end
    end)
    return holder
end

local function notify(msg)
    local toast = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -70),
        Size = UDim2.fromOffset(280, 46), BackgroundColor3 = THEME.Card, ZIndex = 20,
    }, gui)
    round(toast, 14)
    local st = stroke(toast, THEME.Accent, 2, 0.2)
    local accentBar = make("Frame", {
        Position = UDim2.fromOffset(10, 10), Size = UDim2.new(0, 4, 1, -20),
        BackgroundColor3 = THEME.Accent, ZIndex = 21,
    }, toast)
    round(accentBar, 2)
    themed(function()
        accentBar.BackgroundColor3 = THEME.Accent
        st.Color = THEME.Accent
    end)
    make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(26, 0),
        Size = UDim2.new(1, -34, 1, 0), Text = msg,
        TextColor3 = THEME.Text, TextSize = 14, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 21,
    }, toast)
    tween(toast, { Position = UDim2.new(0.5, 0, 0, 20) }, 0.45, Enum.EasingStyle.Back)
    task.delay(2.2, function()
        tween(toast, { Position = UDim2.new(0.5, 0, 0, -70) }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.35)
        toast:Destroy()
    end)
end

local NEUTRAL_COLORS = {
    ["Medium stone grey"]=true, ["Medium Stone Grey"]=true,
    ["Institutional white"]=true, ["White"]=true,
    ["Really black"]=true, ["Black"]=true,
}
local TEAM_ATTR_NAMES  = {"Team","team","TeamId","teamId","TeamName","teamName","Side","side","Faction","faction","Group","group"}
local TEAM_CHILD_NAMES = {"Team","team","TeamId","TeamName","Side","Faction"}

local function GetTeamKey(plr)
    if plr.Team then return "T:" .. plr.Team.Name end
    local tc = plr.TeamColor
    if tc and not NEUTRAL_COLORS[tc.Name] then return "C:" .. tc.Name end
    for _, a in ipairs(TEAM_ATTR_NAMES) do
        local v = plr:GetAttribute(a)
        if v ~= nil then return "A:" .. tostring(v) end
    end
    local ls = plr:FindFirstChild("leaderstats")
    if ls then
        for _, n in ipairs(TEAM_CHILD_NAMES) do
            local v = ls:FindFirstChild(n)
            if v and (v:IsA("StringValue") or v:IsA("IntValue") or v:IsA("NumberValue")) then
                return "L:" .. tostring(v.Value)
            end
        end
    end
    local char = plr.Character
    if char then
        for _, a in ipairs(TEAM_ATTR_NAMES) do
            local v = char:GetAttribute(a)
            if v ~= nil then return "CA:" .. tostring(v) end
        end
        for _, n in ipairs(TEAM_CHILD_NAMES) do
            local v = char:FindFirstChild(n)
            if v and (v:IsA("StringValue") or v:IsA("IntValue") or v:IsA("NumberValue")) then
                return "F:" .. tostring(v.Value)
            end
        end
    end
    return nil
end

local function AngleBetween(a, b)
    return math.deg(math.acos(math.clamp(a.Unit:Dot(b.Unit), -1, 1)))
end

local function IsAliveHumanoid(h)
    if not h or h.Health <= 0 then return false end
    local ok, st = pcall(function() return h:GetState() end)
    if ok and st and (st == Enum.HumanoidStateType.Dead or st == Enum.HumanoidStateType.None) then
        return false
    end
    return true
end

-- ==========================================================
--  🎯 AIM
-- ==========================================================
local ACONFIG = {
    Enabled=false, MaxDistance=5000, FOV=360, TeamCheck=true,
    Prediction=false, PredictionSpeed=400, Smoothness=0,
    AutoFire=false, AFCooldownMin=0.08, AFCooldownMax=0.15, AFMinDot=0.85,
    SmartSwitch=true, WeightDistance=1.0, WeightAngle=0.35,
    SwitchMargin=3, SwitchCooldown=0.08, MaxLockTime=5,
}
local AIM_LAST_SWITCH = 0
local AIM_LOCK_START  = 0
local lockTarget, lockPart = nil, nil
local lastFire = 0

local function TryAutoFire()
    if not lockTarget or not lockPart then return end
    if not ACONFIG.AutoFire then return end
    local now = tick()
    if now - lastFire < ACONFIG.AFCooldownMin + math.random() * (ACONFIG.AFCooldownMax - ACONFIG.AFCooldownMin) then return end
    local cam = Camera.CFrame
    local to = lockPart.Position - cam.Position
    if to.Magnitude < 0.01 then return end
    if cam.LookVector:Dot(to.Unit) < ACONFIG.AFMinDot then return end
    local myChar = player.Character
    local tool = myChar and myChar:FindFirstChildOfClass("Tool")
    if not tool then return end
    pcall(function() tool:Activate() end)
    lastFire = now
end

local function IsEnemy(plr)
    if plr == player then return false end
    if ACONFIG.TeamCheck then
        local m, h = GetTeamKey(player), GetTeamKey(plr)
        if m and h then return m ~= h end
        return false
    end
    return true
end

local function GetPlayerPart(plr)
    if not plr or not IsEnemy(plr) then return nil end
    local char = plr.Character
    if not char or not char.Parent then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not IsAliveHumanoid(hum) then return nil end
    local part = char:FindFirstChild("Head")
    if part then return part end
    for _, n in ipairs({"UpperTorso","Torso","HumanoidRootPart","LowerTorso"}) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    return char.PrimaryPart
end

local function FindBestTarget()
    local mp, ml = Camera.CFrame.Position, Camera.CFrame.LookVector
    local best, bestPart, bestScore, bestDist = nil, nil, math.huge, nil
    for _, plr in ipairs(Players:GetPlayers()) do
        local part = GetPlayerPart(plr)
        if part then
            local to = part.Position - mp
            local d = to.Magnitude
            if d <= ACONFIG.MaxDistance then
                local ang = AngleBetween(ml, to)
                if ang <= ACONFIG.FOV then
                    local score = d * ACONFIG.WeightDistance + ang * ACONFIG.WeightAngle
                    if score < bestScore then
                        bestScore, best, bestPart, bestDist = score, plr, part, d
                    end
                end
            end
        end
    end
    return best, bestPart, bestScore, bestDist
end

local function GetDistToTarget(plr)
    local part = GetPlayerPart(plr)
    if not part then return nil end
    return (part.Position - Camera.CFrame.Position).Magnitude
end

local function UpdateLock()
    if not ACONFIG.Enabled then
        lockTarget, lockPart = nil, nil
        return
    end

    local myChar = player.Character
    if not myChar then lockTarget, lockPart = nil, nil return end
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not IsAliveHumanoid(myHum) then lockTarget, lockPart = nil, nil return end

    if lockTarget then
        local p = GetPlayerPart(lockTarget)
        if not p then lockTarget, lockPart = nil, nil
        else lockPart = p end
    end

    local now = tick()
    if ACONFIG.SmartSwitch then
        if now - AIM_LAST_SWITCH >= ACONFIG.SwitchCooldown then
            local best, bestPart, _, bestDist = FindBestTarget()
            if best and bestPart then
                local shouldSwitch = false
                if not lockTarget then
                    shouldSwitch = true
                else
                    local curDist = GetDistToTarget(lockTarget)
                    if curDist then
                        if best ~= lockTarget and bestDist and (curDist - bestDist) >= ACONFIG.SwitchMargin then
                            shouldSwitch = true
                        end
                        if (now - AIM_LOCK_START) > ACONFIG.MaxLockTime then
                            if best ~= lockTarget then shouldSwitch = true end
                        end
                    else
                        shouldSwitch = true
                    end
                end
                if shouldSwitch then
                    lockTarget, lockPart = best, bestPart
                    AIM_LAST_SWITCH = now
                    AIM_LOCK_START = now
                end
            end
        end
    else
        if not lockTarget then
            local best, bestPart = FindBestTarget()
            if best and bestPart then
                lockTarget, lockPart = best, bestPart
                AIM_LAST_SWITCH = now
                AIM_LOCK_START = now
            end
        end
    end

    if not lockTarget or not lockPart then return end

    local mp = Camera.CFrame.Position
    local aimPos = lockPart.Position
    if ACONFIG.Prediction then
        local vel = lockPart.AssemblyLinearVelocity
        local dist = (aimPos - mp).Magnitude
        aimPos = aimPos + vel * (dist / math.max(ACONFIG.PredictionSpeed, 1))
    end
    local des = CFrame.lookAt(mp, aimPos)
    if ACONFIG.Smoothness <= 0 then
        Camera.CFrame = des
    else
        Camera.CFrame = Camera.CFrame:Lerp(des, 1 - ACONFIG.Smoothness)
    end
    TryAutoFire()
end

RunService:BindToRenderStep("AimUnified", Enum.RenderPriority.Last.Value, UpdateLock)

local function MaybeClearLock()
    if not ACONFIG.Enabled then
        lockTarget, lockPart = nil, nil
        AIM_LAST_SWITCH = 0
        AIM_LOCK_START = 0
    end
end

-- ==========================================================
--  🚀 VOO
-- ==========================================================
local FlyEnabled    = false
local FlySpeed      = 60
local FlyConnection = nil
local BodyVelocity  = nil
local BodyForce     = nil

local function GetRootPart()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function RemoveFlyParts()
    if BodyVelocity then pcall(function() BodyVelocity:Destroy() end) BodyVelocity = nil end
    if BodyForce then pcall(function() BodyForce:Destroy() end) BodyForce = nil end
end

local function StartFly()
    if FlyEnabled then return end
    FlyEnabled = true
    if FlyConnection then FlyConnection:Disconnect() end
    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then return end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root2 = GetRootPart()
        if not hum or not root2 then return end

        if not BodyVelocity or not BodyVelocity.Parent then
            RemoveFlyParts()
            BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BodyVelocity.P = 1250
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            BodyVelocity.Parent = root2
        end
        if not BodyForce or not BodyForce.Parent then
            BodyForce = Instance.new("BodyForce")
            BodyForce.Force = Vector3.new(0, 0, 0)
            BodyForce.Parent = root2
        end

        BodyForce.Force = Vector3.new(0, root2.AssemblyMass * workspace.Gravity, 0)

        local mDir = hum.MoveDirection
        local vel = Vector3.new(0, 0, 0)
        if mDir.Magnitude > 0 then
            local cf = Camera.CFrame
            local lf = cf.LookVector
            local rh = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
            local fh = Vector3.new(lf.X, 0, lf.Z)
            if fh.Magnitude > 0.001 then fh = fh.Unit else fh = Vector3.new(0,0,-1) end
            if rh.Magnitude > 0.001 then rh = rh.Unit else rh = Vector3.new(1,0,0) end
            vel = (lf * mDir:Dot(fh) + rh * mDir:Dot(rh)) * FlySpeed
        end
        BodyVelocity.Velocity = BodyVelocity.Velocity:Lerp(vel, 0.15)
    end)
end

local function StopFly()
    if not FlyEnabled then return end
    FlyEnabled = false
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    RemoveFlyParts()
end

player.CharacterAdded:Connect(function()
    if FlyEnabled then
        task.wait(0.5)
        RemoveFlyParts()
        StartFly()
    end
end)

-- ==========================================================
--  ⚡ SPEED / JUMP / FOV
-- ==========================================================
local ConfigState = {
    SpeedEnabled = false, SpeedValue = 16,
    JumpEnabled  = false, JumpValue  = 50,
    FOVEnabled   = false, FOVValue   = 70,
}

local function GetHumanoid()
    local c = player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local SpeedPropConn = nil
local function ApplySpeed()
    local hum = GetHumanoid()
    if not hum then return end
    if ConfigState.SpeedEnabled then hum.WalkSpeed = ConfigState.SpeedValue end
end
local function AttachSpeedTrap()
    if SpeedPropConn then SpeedPropConn:Disconnect() end
    local hum = GetHumanoid()
    if not hum then return end
    SpeedPropConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if ConfigState.SpeedEnabled and hum.WalkSpeed ~= ConfigState.SpeedValue then
            hum.WalkSpeed = ConfigState.SpeedValue
        end
    end)
end

RunService.RenderStepped:Connect(function()
    local hum = GetHumanoid()
    if not hum then return end
    if ConfigState.SpeedEnabled and hum.WalkSpeed ~= ConfigState.SpeedValue then
        hum.WalkSpeed = ConfigState.SpeedValue
    end
    if ConfigState.JumpEnabled then
        if not hum.UseJumpPower then hum.UseJumpPower = true end
        if hum.JumpPower ~= ConfigState.JumpValue then
            hum.JumpPower = ConfigState.JumpValue
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not Camera then return end
    if ConfigState.FOVEnabled and Camera.FieldOfView ~= ConfigState.FOVValue then
        Camera.FieldOfView = ConfigState.FOVValue
    end
end)

player.CharacterAdded:Connect(function(char)
    task.wait(1)
    if ConfigState.SpeedEnabled then ApplySpeed(); AttachSpeedTrap() end
    if ConfigState.JumpEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = ConfigState.JumpValue
        end
    end
    if ConfigState.FOVEnabled and Camera then
        Camera.FieldOfView = ConfigState.FOVValue
    end
end)

-- ==========================================================
--  🧱 NOCLIP
-- ==========================================================
local NoclipEnabled = false
local NoclipConn    = nil

local function NoclipApplyToChar(char)
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function() p.CanCollide = false end)
        end
    end
end

local function NoclipStart()
    if NoclipConn then NoclipConn:Disconnect() end
    NoclipConn = RunService.Stepped:Connect(function()
        if not NoclipEnabled then return end
        local char = player.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                pcall(function() p.CanCollide = false end)
            end
        end
    end)
end

local function NoclipStop()
    if NoclipConn then NoclipConn:Disconnect() NoclipConn = nil end
    local char = player.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function() p.CanCollide = true end)
            end
        end
    end
end

player.CharacterAdded:Connect(function(char)
    if NoclipEnabled then
        task.wait(0.2)
        NoclipApplyToChar(char)
        NoclipStart()
    end
end)

-- ==========================================================
--  🔦 FULLBRIGHT
-- ==========================================================
local FullbrightEnabled = false
local FullbrightConns   = {}
local FullbrightBackup  = nil

local function SaveOriginalLighting()
    FullbrightBackup = {
        Ambient          = Lighting.Ambient,
        OutdoorAmbient   = Lighting.OutdoorAmbient,
        Brightness       = Lighting.Brightness,
        ClockTime        = Lighting.ClockTime,
        FogEnd           = Lighting.FogEnd,
        FogStart         = Lighting.FogStart,
        FogColor         = Lighting.FogColor,
        GlobalShadows    = Lighting.GlobalShadows,
        EnvironmentDiffuseScale  = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        ExposureCompensation = Lighting.ExposureCompensation,
        Effects = {},
    }
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("Atmosphere") then
            FullbrightBackup.Effects[e] = {
                Density = e.Density, Haze = e.Haze, Glare = e.Glare,
                Color = e.Color, Decay = e.Decay,
            }
        elseif e:IsA("ColorCorrectionEffect") then
            FullbrightBackup.Effects[e] = {
                Brightness = e.Brightness, Contrast = e.Contrast,
                Saturation = e.Saturation, TintColor = e.TintColor,
            }
        elseif e:IsA("BloomEffect") then
            FullbrightBackup.Effects[e] = { Intensity = e.Intensity }
        elseif e:IsA("BlurEffect") then
            FullbrightBackup.Effects[e] = { Size = e.Size }
        elseif e:IsA("SunRaysEffect") then
            FullbrightBackup.Effects[e] = { Intensity = e.Intensity }
        end
    end
end

local function FullbrightApply()
    if not FullbrightBackup then SaveOriginalLighting() end
    Lighting.Ambient        = Color3.fromRGB(130, 130, 130)
    Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
    Lighting.Brightness     = 2
    Lighting.ClockTime      = 14
    Lighting.FogEnd         = 100000
    Lighting.FogStart       = 100000
    Lighting.GlobalShadows  = true
    Lighting.EnvironmentDiffuseScale  = 0.5
    Lighting.EnvironmentSpecularScale = 0.5
    Lighting.ExposureCompensation = 0
    for _, ef in ipairs(Lighting:GetChildren()) do
        if ef:IsA("Atmosphere") then
            ef.Density = 0.1; ef.Haze = 0; ef.Glare = 0
        elseif ef:IsA("ColorCorrectionEffect") then
            ef.Brightness = 0; ef.Contrast = 0; ef.Saturation = 0
            ef.TintColor = Color3.fromRGB(255, 255, 255)
        elseif ef:IsA("BloomEffect") then
            ef.Intensity = 0
        elseif ef:IsA("BlurEffect") then
            ef.Size = 0
        elseif ef:IsA("SunRaysEffect") then
            ef.Intensity = 0
        end
    end
end

local function FullbrightStart()
    FullbrightApply()
    for _, c in ipairs(FullbrightConns) do
        if c and c.Disconnect then pcall(function() c:Disconnect() end) end
    end
    FullbrightConns = {}
    table.insert(FullbrightConns, Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
        if not FullbrightEnabled then return end
        if Lighting.ClockTime < 10 or Lighting.ClockTime > 17 then
            Lighting.ClockTime = 14
        end
    end))
    table.insert(FullbrightConns, Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
        if not FullbrightEnabled then return end
        if Lighting.Brightness < 1.5 then Lighting.Brightness = 2 end
    end))
    table.insert(FullbrightConns, Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
        if not FullbrightEnabled then return end
        if Lighting.Ambient.R < 0.3 or Lighting.Ambient.G < 0.3 or Lighting.Ambient.B < 0.3 then
            Lighting.Ambient = Color3.fromRGB(130, 130, 130)
        end
    end))
    table.insert(FullbrightConns, Lighting:GetPropertyChangedSignal("OutdoorAmbient"):Connect(function()
        if not FullbrightEnabled then return end
        if Lighting.OutdoorAmbient.R < 0.3 then
            Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
        end
    end))
end

local function FullbrightStop()
    for _, c in ipairs(FullbrightConns) do
        if c and c.Disconnect then pcall(function() c:Disconnect() end) end
    end
    FullbrightConns = {}
    if FullbrightBackup then
        Lighting.Ambient        = FullbrightBackup.Ambient
        Lighting.OutdoorAmbient = FullbrightBackup.OutdoorAmbient
        Lighting.Brightness     = FullbrightBackup.Brightness
        Lighting.ClockTime      = FullbrightBackup.ClockTime
        Lighting.FogEnd         = FullbrightBackup.FogEnd
        Lighting.FogStart       = FullbrightBackup.FogStart
        Lighting.FogColor       = FullbrightBackup.FogColor
        Lighting.GlobalShadows  = FullbrightBackup.GlobalShadows
        Lighting.EnvironmentDiffuseScale  = FullbrightBackup.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = FullbrightBackup.EnvironmentSpecularScale
        Lighting.ExposureCompensation = FullbrightBackup.ExposureCompensation
        for ef, vals in pairs(FullbrightBackup.Effects) do
            if ef and ef.Parent then
                for k, v in pairs(vals) do
                    pcall(function() ef[k] = v end)
                end
            end
        end
        FullbrightBackup = nil
    end
end

-- ==========================================================
--  👁️ ESP
-- ==========================================================
local ESPEnabled      = true
local ESPMustHaveTeam = true
local ESPColor        = Color3.fromRGB(255, 30, 30)
local ESP_ACTIVE      = {}

local function ESPIsValid(plr)
    if plr == player then return false end
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not ESPMustHaveTeam then return true end
    local m, h = GetTeamKey(player), GetTeamKey(plr)
    if m and h then return m ~= h end
    return false
end

local function createBeacon(char, color)
    local root2 = char:FindFirstChild("HumanoidRootPart")
    if not root2 then return nil end
    local b = Instance.new("Part")
    b.Name = "ESP_Beacon"
    b.Anchored = true
    b.CanCollide = false
    b.CanQuery = false
    b.CanTouch = false
    b.Material = Enum.Material.Neon
    b.Color = color
    b.Transparency = 0
    b.Size = Vector3.new(1.2, 300, 1.2)
    b.CFrame = root2.CFrame * CFrame.new(0, 150, 0)
    b.Parent = workspace
    Instance.new("CylinderMesh", b)

    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = b
    hl.Parent = b

    local li = Instance.new("PointLight")
    li.Color = color
    li.Range = 60
    li.Brightness = 5
    li.Parent = b

    task.spawn(function()
        while b and b.Parent do
            local t1 = TweenService:Create(b, TweenInfo.new(0.6, Enum.EasingStyle.Sine), { Transparency = 0.5 })
            t1:Play()
            local ok = pcall(function() t1.Completed:Wait() end)
            if not ok or not b.Parent then break end
            local t2 = TweenService:Create(b, TweenInfo.new(0.6, Enum.EasingStyle.Sine), { Transparency = 0 })
            t2:Play()
            pcall(function() t2.Completed:Wait() end)
            if not b.Parent then break end
        end
    end)

    return b
end

local function clearESP(plr)
    local d = ESP_ACTIVE[plr]
    if d then
        if d.conn then pcall(function() d.conn:Disconnect() end) end
        if d.hl and d.hl.Parent then pcall(function() d.hl:Destroy() end) end
        if d.b and d.b.Parent then pcall(function() d.b:Destroy() end) end
        ESP_ACTIVE[plr] = nil
    end
end

local function applyESP(plr, char)
    if not char or not char.Parent then return end
    local root2 = char:FindFirstChild("HumanoidRootPart")
    if not root2 then return end

    clearESP(plr)

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.FillColor = ESPColor
    hl.OutlineColor = ESPColor
    hl.FillTransparency = 0.15
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = char
    hl.Parent = char

    local b = createBeacon(char, ESPColor)

    local conn = RunService.RenderStepped:Connect(function()
        if not b or not b.Parent then return end
        if not root2 or not root2.Parent then return end
        b.CFrame = root2.CFrame * CFrame.new(0, 150, 0)
    end)

    ESP_ACTIVE[plr] = { hl = hl, b = b, conn = conn, char = char }
end

local function ESPClearAll()
    local keys = {}
    for k in pairs(ESP_ACTIVE) do table.insert(keys, k) end
    for _, k in ipairs(keys) do clearESP(k) end
end

local function ESPRefreshPlayers()
    if not ESPEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            local root2 = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local valid = ESPIsValid(plr)
            local data = ESP_ACTIVE[plr]

            if valid and root2 and hum and hum.Health > 0 then
                if not data
                    or data.char ~= char
                    or not data.hl or not data.hl.Parent
                    or not data.b or not data.b.Parent then
                    clearESP(plr)
                    applyESP(plr, char)
                end
            else
                if data then clearESP(plr) end
            end
        end
    end
end

local function ESPApplyColor(newColor)
    ESPColor = newColor
    for _, data in pairs(ESP_ACTIVE) do
        if data.hl and data.hl.Parent then
            data.hl.FillColor = ESPColor
            data.hl.OutlineColor = ESPColor
        end
        if data.b and data.b.Parent then
            data.b.Color = ESPColor
            local li = data.b:FindFirstChildOfClass("PointLight")
            if li then li.Color = ESPColor end
            local hlb = data.b:FindFirstChildOfClass("Highlight")
            if hlb then
                hlb.FillColor = ESPColor
                hlb.OutlineColor = ESPColor
            end
        end
    end
end

task.spawn(function()
    while true do
        if ESPEnabled then ESPRefreshPlayers() end
        task.wait(0.15)
    end
end)

local function hookPlayer(plr)
    if plr == player then return end
    if plr.Character then
        task.defer(function()
            if ESPEnabled then ESPRefreshPlayers() end
        end)
    end
    plr.CharacterAdded:Connect(function()
        task.wait(0.1)
        if ESPEnabled then ESPRefreshPlayers() end
        task.delay(1, function()
            if ESPEnabled then ESPRefreshPlayers() end
        end)
    end)
    plr.CharacterRemoving:Connect(function()
        clearESP(plr)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(function(p) clearESP(p) end)

-- ==========================================================
--  🎯 ABA AIM
-- ==========================================================
local aimTab = newTab("Aim", "🎯", 1)
text(aimTab, "Aimbot Players", 20, THEME.Text, Enum.Font.GothamBold)
text(aimTab, "Cola no inimigo. IA de troca incluída.", 12, THEME.SubText)

addToggle(aimTab, "🎯 Ativar Aim", false, function(v)
    ACONFIG.Enabled = v
    MaybeClearLock()
    notify(v and "Aim ATIVADO" or "Aim desativado")
end)
addToggle(aimTab, "🛡️ Team Check (não mira aliados)", true, function(v) ACONFIG.TeamCheck = v end)
addToggle(aimTab, "🧠 IA de troca (sempre o mais próximo)", true, function(v)
    ACONFIG.SmartSwitch = v
    notify(v and "🧠 IA de troca ON" or "IA de troca OFF")
end)
addToggle(aimTab, "🎯 Predição (mira na frente)", false, function(v) ACONFIG.Prediction = v end)
addToggle(aimTab, "🔥 Auto Fire", false, function(v) ACONFIG.AutoFire = v end)

addSlider(aimTab, "FOV (graus)", 5, 360, 360, function(v) ACONFIG.FOV = v end)
addSlider(aimTab, "Distância máx", 20, 8000, 5000, function(v) ACONFIG.MaxDistance = v end)
addSlider(aimTab, "Velocidade da bala", 50, 3000, 400, function(v) ACONFIG.PredictionSpeed = v end)
addSlider(aimTab, "Suavidade (0 = colado)", 0, 1, 0, function(v) ACONFIG.Smoothness = v end, 2)

text(aimTab, "🧠 IA DE TROCA", 12, THEME.SubText, Enum.Font.GothamBold)
addSlider(aimTab, "Velocidade de troca (ms)", 30, 500, 80, function(v)
    ACONFIG.SwitchCooldown = v / 1000
end)
addSlider(aimTab, "Margem p/ trocar (studs)", 0, 30, 3, function(v)
    ACONFIG.SwitchMargin = v
end)
addSlider(aimTab, "Peso da distância", 0.1, 5, 1.0, function(v)
    ACONFIG.WeightDistance = v
end, 1)
addSlider(aimTab, "Peso do ângulo", 0, 3, 0.35, function(v)
    ACONFIG.WeightAngle = v
end, 2)

text(aimTab, "💡 IA ON = sempre troca pro mais próximo.\n⚡ Margem baixa (0-2) = troca mais agressivo.\n⚡ Velocidade baixa (30-80ms) = reage rápido.", 12, Color3.fromRGB(250, 204, 21))

-- ==========================================================
--  ⚡ ABA SPEED
-- ==========================================================
local spdTab = newTab("Speed", "⚡", 2)
text(spdTab, "Speed / Pulo / FOV", 20, THEME.Text, Enum.Font.GothamBold)
text(spdTab, "Ajustes persistentes — sobrevivem ao respawn.", 12, THEME.SubText)

addToggle(spdTab, "⚡ Ativar Speed personalizado", false, function(v)
    ConfigState.SpeedEnabled = v
    local hum = GetHumanoid()
    if hum then
        if v then
            hum.WalkSpeed = ConfigState.SpeedValue
            AttachSpeedTrap()
        else
            hum.WalkSpeed = 16
            if SpeedPropConn then SpeedPropConn:Disconnect() SpeedPropConn = nil end
        end
    end
    notify(v and "⚡ Speed ON" or "Speed OFF")
end)
-- ✅ VELOCIDADE ATÉ 1000
addSlider(spdTab, "Velocidade (WalkSpeed)", 16, 1000, 16, function(v)
    ConfigState.SpeedValue = v
    if ConfigState.SpeedEnabled then
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = v end
    end
end)

addToggle(spdTab, "🦘 Ativar Pulo Alto", false, function(v)
    ConfigState.JumpEnabled = v
    local hum = GetHumanoid()
    if hum then
        if v then
            hum.UseJumpPower = true
            hum.JumpPower = ConfigState.JumpValue
        else
            hum.UseJumpPower = true
            hum.JumpPower = 50
        end
    end
    notify(v and "🦘 Pulo Alto ON" or "Pulo normal")
end)
addSlider(spdTab, "Força do Pulo", 50, 500, 50, function(v)
    ConfigState.JumpValue = v
    if ConfigState.JumpEnabled then
        local hum = GetHumanoid()
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = v
        end
    end
end)

addToggle(spdTab, "📷 Ativar FOV personalizado", false, function(v)
    ConfigState.FOVEnabled = v
    if Camera then
        if v then Camera.FieldOfView = ConfigState.FOVValue
        else Camera.FieldOfView = 70 end
    end
    notify(v and "📷 FOV ON" or "FOV padrão")
end)
addSlider(spdTab, "FOV da câmera", 40, 120, 70, function(v)
    ConfigState.FOVValue = v
    if ConfigState.FOVEnabled and Camera then
        Camera.FieldOfView = v
    end
end)

text(spdTab, "💡 Speed e Pulo ficam travados. Só desliga no toggle.\n💡 FOV reaplica sozinho se o jogo resetar.\n⚠️ Velocidade alta (>500) pode dar kick.", 12, Color3.fromRGB(250, 204, 21))

-- ==========================================================
--  👁️ ABA ESP
-- ==========================================================
local espTab = newTab("ESP", "👁️", 3)
text(espTab, "ESP — Antena Neon", 20, THEME.Text, Enum.Font.GothamBold)
text(espTab, "Coluna neon + Highlight nos inimigos.", 12, THEME.SubText)

addToggle(espTab, "👁️ Ativar ESP", true, function(v)
    ESPEnabled = v
    if v then ESPRefreshPlayers() else ESPClearAll() end
    notify(v and "👁️ ESP ON" or "ESP OFF")
end)
addToggle(espTab, "🛡️ Só time inimigo (não mostra aliados)", true, function(v)
    ESPMustHaveTeam = v
    ESPClearAll()
    ESPRefreshPlayers()
end)

text(espTab, "🎨 COR DO ESP", 12, THEME.SubText, Enum.Font.GothamBold)

local colorCard = card(espTab, 130)
make("UIPadding", {
    PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
}, colorCard)
make("UIGridLayout", {
    CellSize = UDim2.new(1 / 4, -6, 0, 44),
    CellPadding = UDim2.fromOffset(8, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, colorCard)

local colorStrokes = {}
for i, preset in ipairs(ESP_COLORS) do
    local name, c = preset[1], preset[2]
    local sw = make("Frame", { BackgroundColor3 = c, LayoutOrder = i }, colorCard)
    round(sw, 10)
    local sst = stroke(sw, THEME.White, 3, 1)
    colorStrokes[i] = sst

    local btn = make("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = name, TextColor3 = Color3.new(1, 1, 1),
        TextStrokeTransparency = 0.3, TextStrokeColor3 = Color3.new(0, 0, 0),
        TextSize = 11, Font = Enum.Font.GothamBold, AutoButtonColor = false,
    }, sw)
    btn.Activated:Connect(function()
        ESPApplyColor(c)
        for j, s in ipairs(colorStrokes) do
            tween(s, { Transparency = (j == i) and 0 or 1 })
        end
        notify("Cor do ESP: " .. name)
    end)
end
colorStrokes[1].Transparency = 0

text(espTab, "💡 Escolha uma cor acima. Aplica na hora nos inimigos.", 12, Color3.fromRGB(250, 204, 21))

-- ==========================================================
--  🧱 ABA NOCLIP
-- ==========================================================
local noclipTab = newTab("Noclip", "🧱", 4)
text(noclipTab, "Noclip", 20, THEME.Text, Enum.Font.GothamBold)
text(noclipTab, "Atravessa paredes e objetos. Persiste no respawn.", 12, THEME.SubText)

addToggle(noclipTab, "🧱 Ativar Noclip", false, function(v)
    NoclipEnabled = v
    if v then
        NoclipStart()
        NoclipApplyToChar(player.Character)
        notify("🧱 Noclip ON")
    else
        NoclipStop()
        notify("🧱 Noclip OFF")
    end
end)

text(noclipTab, "💡 Fica ativo até desligar no toggle.\n💡 Sobrevive ao respawn automaticamente.", 12, Color3.fromRGB(250, 204, 21))

-- ==========================================================
--  🚀 ABA VOO
-- ==========================================================
local vooTab = newTab("Voo", "🚀", 5)
text(vooTab, "Voo", 20, THEME.Text, Enum.Font.GothamBold)
text(vooTab, "Voe livre pelo mapa. Persiste no respawn.", 12, THEME.SubText)

addToggle(vooTab, "🚀 Ativar Voo", false, function(v)
    if v then
        StartFly()
        notify("🚀 Voo ON")
    else
        StopFly()
        notify("🚀 Voo OFF")
    end
end)
-- ✅ VELOCIDADE DO VOO ATÉ 800
addSlider(vooTab, "Velocidade do Voo", 20, 800, 60, function(v) FlySpeed = v end)

text(vooTab, "💡 Olhe pra cima + ande = SOBE.\n💡 Olhe pra baixo + ande = DESCE.\n💡 Sobrevive ao respawn automaticamente.", 12, Color3.fromRGB(250, 204, 21))

-- ==========================================================
--  🔦 ABA FULLBRIGHT
-- ==========================================================
local fullTab = newTab("Fullbright", "🔦", 6)
text(fullTab, "Fullbright", 20, THEME.Text, Enum.Font.GothamBold)
text(fullTab, "Clareia o mapa inteiro sem estourar a luz.", 12, THEME.SubText)

addToggle(fullTab, "🔦 Ativar Fullbright", false, function(v)
    FullbrightEnabled = v
    if v then
        FullbrightStart()
        notify("🔦 Fullbright ON")
    else
        FullbrightStop()
        notify("🔦 Fullbright OFF")
    end
end)

text(fullTab, "💡 Ajusta luz, sombras e remove efeitos escuros.\n💡 Restaura tudo ao desligar.", 12, Color3.fromRGB(250, 204, 21))

-- ==========================================================
--  ⚙️ ABA CONFIG
-- ==========================================================
local cfgTab = newTab("Config", "⚙️", 7)
text(cfgTab, "Config", 20, THEME.Text, Enum.Font.GothamBold)
text(cfgTab, "Personalize o painel do seu jeito.", 12, THEME.SubText)

text(cfgTab, "🎨 COR DA INTERFACE", 12, THEME.SubText, Enum.Font.GothamBold)

local themeCard = card(cfgTab, 132)
make("UIPadding", {
    PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
}, themeCard)
make("UIGridLayout", {
    CellSize = UDim2.new(1 / 3, -6, 0, 50),
    CellPadding = UDim2.fromOffset(8, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, themeCard)

local themeStrokes = {}
for i, preset in ipairs(PRESETS) do
    local name, c1, c2 = preset[1], preset[2], preset[3]
    local sw = make("Frame", { BackgroundColor3 = c1, LayoutOrder = i }, themeCard)
    round(sw, 12)
    make("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = 30 }, sw)
    local sst = stroke(sw, THEME.White, 2.5, i == 1 and 0 or 1)
    themeStrokes[i] = sst

    local btn = make("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = name, TextColor3 = THEME.White, TextSize = 13,
        Font = Enum.Font.GothamBold, AutoButtonColor = false,
    }, sw)
    btn.Activated:Connect(function()
        applyTheme(c1, c2)
        for j, s in ipairs(themeStrokes) do
            tween(s, { Transparency = (j == i) and 0 or 1 })
        end
        notify("Tema " .. name .. " aplicado")
    end)
end

text(cfgTab, "📏 TAMANHO DO PAINEL", 12, THEME.SubText, Enum.Font.GothamBold)

addSlider(cfgTab, "Escala do painel (%)", 60, 130, 100, function(v)
    PanelScaleMult = v / 100
    updateFit()
end)

addSlider(cfgTab, "Transparência do fundo (%)", 0, 60, 0, function(v)
    main.BackgroundTransparency = v / 100
end)

text(cfgTab, "✨ COMPORTAMENTO", 12, THEME.SubText, Enum.Font.GothamBold)

addToggle(cfgTab, "✨ Animações ativadas", true, function(v)
    AnimEnabled = v
    notify(v and "✨ Animações ON" or "Animações OFF")
end)

addToggle(cfgTab, "👤 Mostrar perfil", true, function(v)
    profile.Visible = v
end)

text(cfgTab, "🔄 RESET", 12, THEME.SubText, Enum.Font.GothamBold)

addButton(cfgTab, "🔄 Resetar painel ao centro", false, function()
    root.Position = UDim2.fromScale(0.5, 0.5)
    notify("Painel centralizado")
end)

addButton(cfgTab, "🔄 Resetar personalização", true, function()
    PanelScaleMult = 1.0
    updateFit()
    main.BackgroundTransparency = 0
    profile.Visible = true
    AnimEnabled = true
    applyTheme(Color3.fromRGB(139, 108, 255), Color3.fromRGB(56, 189, 248))
    for j, s in ipairs(themeStrokes) do
        tween(s, { Transparency = (j == 1) and 0 or 1 })
    end
    notify("Personalização resetada")
end)

text(cfgTab, "💡 Ajuste do seu jeito. Tudo em tempo real.", 12, Color3.fromRGB(250, 204, 21))

selectTab("Aim")

-- ==========================================================
--  🔵 BOLINHA
-- ==========================================================
local bubble = make("Frame", {
    Name = "Bubble", Size = UDim2.fromOffset(BUBBLE, BUBBLE),
    Position = UDim2.fromOffset(16, 180), BackgroundColor3 = THEME.Accent,
    Visible = false, ZIndex = 50,
}, gui)
round(bubble, BUBBLE / 2)
accentGradient(bubble, 45)
local bubbleStroke = stroke(bubble, THEME.White, 3, 0.4)
local bubbleScale = make("UIScale", { Scale = 0 }, bubble)

TweenService:Create(
    bubbleStroke,
    TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    { Transparency = 0.05 }
):Play()

local ring = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 49,
}, bubble)
round(ring, BUBBLE / 2)
local ringStroke = stroke(ring, THEME.White, 2, 0.35)
local ringScale = make("UIScale", { Scale = 1 }, ring)
local ringInfo = TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, false)
TweenService:Create(ringScale, ringInfo, { Scale = 1.7 }):Play()
TweenService:Create(ringStroke, ringInfo, { Transparency = 1 }):Play()

local hit = make("TextButton", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    Text = "💀", TextColor3 = THEME.White, TextSize = 30,
    Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 51,
}, bubble)

local isOpen, busy = false, false

local function showBubble(show)
    if show then
        bubble.Visible = true
        bubbleScale.Scale = 0
        tween(bubbleScale, { Scale = 1 }, 0.45, Enum.EasingStyle.Back)
    else
        tween(bubbleScale, { Scale = 0 }, 0.18)
        task.delay(0.2, function()
            if isOpen then bubble.Visible = false end
        end)
    end
end

local function openWindow()
    if isOpen or busy then return end
    busy, isOpen = true, true
    showBubble(false)
    root.Visible = true
    anim.Scale = 0.7
    tween(anim, { Scale = 1 }, 0.55, Enum.EasingStyle.Back)
    task.delay(0.55, function() busy = false end)
end

local function minimizeWindow()
    if not isOpen or busy then return end
    busy, isOpen = true, false
    tween(anim, { Scale = 0.5 }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.delay(0.27, function()
        root.Visible = false
        showBubble(true)
        busy = false
    end)
end

minBtn.Activated:Connect(minimizeWindow)

local function clampPos(x, y)
    local vp = gui.AbsoluteSize
    return UDim2.fromOffset(
        math.clamp(x, 8, math.max(8, vp.X - BUBBLE - 8)),
        math.clamp(y, 30, math.max(30, vp.Y - BUBBLE - 8))
    )
end

connect(gui:GetPropertyChangedSignal("AbsoluteSize"), function()
    bubble.Position = clampPos(bubble.Position.X.Offset, bubble.Position.Y.Offset)
end)

do
    local function snapToSide()
        local vp = gui.AbsoluteSize
        local x = bubble.Position.X.Offset
        local target = (x + BUBBLE / 2 < vp.X / 2) and 10 or (vp.X - BUBBLE - 10)
        tween(bubble, { Position = UDim2.fromOffset(target, bubble.Position.Y.Offset) }, 0.45, Enum.EasingStyle.Back)
    end
    local pressing, moved, startMouse, startPos = false, false, nil, nil

    hit.InputBegan:Connect(function(input)
        if isPointer(input) then
            pressing, moved = true, false
            startMouse = input.Position
            startPos = bubble.Position
            tween(bubbleScale, { Scale = 0.9 }, 0.1)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    pressing = false
                    tween(bubbleScale, { Scale = 1 }, 0.25, Enum.EasingStyle.Back)
                    if moved then snapToSide() else openWindow() end
                end
            end)
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if pressing and isMove(input) then
            local d = input.Position - startMouse
            if not moved and d.Magnitude > 8 then moved = true end
            if moved then
                bubble.Position = clampPos(startPos.X.Offset + d.X, startPos.Y.Offset + d.Y)
            end
        end
    end)
end

connect(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if isOpen then minimizeWindow() else openWindow() end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    lockTarget, lockPart = nil, nil
    AIM_LAST_SWITCH = 0
    AIM_LOCK_START = 0
end)

ESPRefreshPlayers()
openWindow()

print("✅ Painel Pro v3.0 — 7 abas (Aim, Speed, ESP, Noclip, Voo, Fullbright, Config) carregado")
