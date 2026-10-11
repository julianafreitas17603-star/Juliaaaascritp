-- ==========================================================
--  💀 PAINEL PRO v3.6 — AIM Assist Turbo + ESP Moderno
-- ==========================================================

repeat task.wait(0.1) until game:IsLoaded()

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local VirtualUser      = game:GetService("VirtualUser")
local CollectionService= game:GetService("CollectionService")

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
        for k, v in pairs(p) do pcall(function() o[k] = v end) end
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
    BackgroundTransparency = 1, Visible = false, ZIndex = 100,
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
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 6),
    Size = UDim2.new(1, 46, 1, 46), BackgroundTransparency = 1,
    Image = "rbxassetid://1316045217", ImageColor3 = Color3.new(0, 0, 0),
    ImageTransparency = 0.45, ScaleType = Enum.ScaleType.Slice,
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
    Size = UDim2.new(1, -120, 0, 20), Text = "Painel Pro",
    TextColor3 = THEME.Text, TextSize = 17, Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, top)
make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(60, 31),
    Size = UDim2.new(1, -120, 0, 16), Text = "v3.6 • Aim Turbo + ESP Moderno",
    TextColor3 = THEME.SubText, TextSize = 11,
    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
}, top)

local minBtn = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
    Size = UDim2.fromOffset(36, 36), BackgroundColor3 = THEME.Card,
    Text = "–", TextColor3 = THEME.Text, TextSize = 22,
    Font = Enum.Font.GothamBold, AutoButtonColor = false,
}, top)
round(minBtn, 18); stroke(minBtn, THEME.White, 1, 0.8)
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
round(sidebar, 14); stroke(sidebar, THEME.White, 1, 0.88)

local tabHolder = make("Frame", { Size = UDim2.new(1, 0, 1, -64), BackgroundTransparency = 1 }, sidebar)
make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, tabHolder)
make("UIPadding", {
    PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
}, tabHolder)

local profile = make("Frame", {
    AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 8, 1, -8),
    Size = UDim2.new(1, -16, 0, 48), BackgroundColor3 = THEME.Card, Visible = true,
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
        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = THEME.Accent,
        BackgroundTransparency = 1, Text = icon .. "  " .. name,
        TextColor3 = THEME.SubText, TextSize = 12, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
        LayoutOrder = tabOrder,
    }, tabHolder)
    round(btn, 10)
    make("UIPadding", { PaddingLeft = UDim.new(0, 8) }, btn)
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
        TextWrapped = true, Size = UDim2.new(1, 0, 0, (size * 2) + 6),
        LayoutOrder = order(),
    }, parent)
end

local function card(parent, height)
    local c = make("Frame", {
        Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = THEME.Card,
        LayoutOrder = order(),
    }, parent)
    round(c, 12); stroke(c, THEME.White, 1, 0.86)
    return c
end

local function makeListHolder(parent)
    local h = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
        LayoutOrder = order(), AutomaticSize = Enum.AutomaticSize.Y,
    }, parent)
    make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, h)
    return h
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
        tween(knob, { Position = state and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, 0.3, Enum.EasingStyle.Back)
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
    round(fill, 4); accentGradient(fill, 0)
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
            sliding = true; parent.ScrollingEnabled = false; update(input)
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if isPointer(input) and sliding then
            sliding = false; parent.ScrollingEnabled = true
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
    if primary then accentGradient(holder, 20) else stroke(holder, THEME.White, 1, 0.8) end
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

local function addDropdown(parent, label, options, default, callback)
    local row = card(parent, 84)
    make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -100, 0, 20), Text = label,
        TextColor3 = THEME.Text, TextSize = 14, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local cycleBtn = make("TextButton", {
        Position = UDim2.new(0, 14, 0, 36), Size = UDim2.new(1, -28, 0, 34),
        BackgroundColor3 = THEME.Off, Text = default or options[1],
        TextColor3 = THEME.Text, TextSize = 13, Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    }, row)
    round(cycleBtn, 10)
    local idx = 1
    for i, o in ipairs(options) do if o == (default or options[1]) then idx = i break end end
    cycleBtn.Activated:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        cycleBtn.Text = options[idx]
        if callback then callback(options[idx]) end
    end)
    return row
end

local function notify(msg)
    local toast = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -70),
        Size = UDim2.fromOffset(280, 46), BackgroundColor3 = THEME.Card, ZIndex = 200,
    }, gui)
    round(toast, 14)
    local st = stroke(toast, THEME.Accent, 2, 0.2)
    local accentBar = make("Frame", {
        Position = UDim2.fromOffset(10, 10), Size = UDim2.new(0, 4, 1, -20),
        BackgroundColor3 = THEME.Accent, ZIndex = 201,
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
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 201,
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
--  🎯 AIM (Players + NPCs)
-- ==========================================================
local ACONFIG = {
    EnabledPlayers=false, EnabledNPCs=false,
    MaxDistance=5000, FOV=360, TeamCheck=true,
    Prediction=false, PredictionSpeed=400, Smoothness=0,
    AutoFire=false, AFCooldownMin=0.08, AFCooldownMax=0.15, AFMinDot=0.85,
    WeightDistance=10.0, WeightAngle=0.05, SwitchMargin=0,
    OnlyZombies=false, NPCTeamCheck=false,
}

-- ==========================================================
--  ✨ AIM ASSIST — MELHORADO (v3.6)
-- ==========================================================
local ASSIST = {
    Enabled = false,
    TeamCheck = true,
    Prediction = false,
    PredictionSpeed = 400,
    MaxDistance = 800,
    FOV = 90,

    -- Target mode: "closest" | "crosshair" | "lowest_hp" | "threat"
    TargetMode = "crosshair",

    -- Strength 0-1 (força base do puxão)
    Strength = 0.35,

    -- Smoothing 1-30 (maior = mais suave/lento)
    SmoothStrength = 6,

    -- TriggerRadius (px na tela): só ativa quando mira está perto do alvo
    TriggerRadius = 120,

    -- Adaptive: puxa mais forte quando longe do alvo, mais suave quando perto
    Adaptive = true,

    -- Magnetic: boost multiplicativo conforme aproxima
    Magnetic = true,
    MagneticBoost = 2.0,

    -- Vertical multiplier: reduz o puxão vertical (não trava em teto)
    VerticalAssist = true,
    VerticalMultiplier = 0.65,

    -- Wall check: ignora alvos atrás de parede
    WallCheck = true,

    -- Indicador visual (anel verde) quando assist ativo
    ShowIndicator = true,

    -- Curva de força: "linear" | "smooth" | "exponential"
    Curve = "smooth",

    -- Lock-On: multiplicador quando o alvo está bem no centro
    LockOn = 0.6,

    -- Sticky: reduz sensibilidade quando em cima do alvo
    Sticky = false,
    StickyStrength = 0.35,
}

-- Indicador visual do Assist (anel no alvo)
local assistIndicator = make("Frame", {
    Name = "AssistIndicator",
    AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(60, 60),
    BackgroundTransparency = 1, Visible = false, ZIndex = 5,
}, gui)
round(assistIndicator, 30)
local assistIndicatorStroke = stroke(assistIndicator, Color3.fromRGB(46, 255, 126), 2, 0.15)
local assistIndicatorScale = make("UIScale", { Scale = 1 }, assistIndicator)
local assistPulseInfo = TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
TweenService:Create(assistIndicatorStroke, assistPulseInfo, { Transparency = 0.75 }):Play()
TweenService:Create(assistIndicatorScale, assistPulseInfo, { Scale = 1.25 }):Play()

local function applyCurve(strength, distanceFactor)
    if ASSIST.Curve == "linear" then
        return strength
    elseif ASSIST.Curve == "exponential" then
        return strength * (distanceFactor ^ 2)
    else -- smooth
        return strength * (distanceFactor * (2 - distanceFactor))
    end
end

local function GetThreatScore(plr, char, camPos, look)
    -- Ameaça = combinação de proximidade, alinhamento e vida baixa
    local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not hrp then return math.huge end
    local to = hrp.Position - camPos
    local d = to.Magnitude
    local ang = AngleBetween(look, to)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hp = hum and hum.Health / math.max(hum.MaxHealth, 1) or 1
    return d * 0.5 + ang * 5 + hp * 100
end

local function AssistFindTarget()
    local camPos = Camera.CFrame.Position
    local look = Camera.CFrame.LookVector
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)

    local best, bestPart, bestChar, bestScore = nil, nil, nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local ok = true
            if ASSIST.TeamCheck then
                local m, h = GetTeamKey(player), GetTeamKey(plr)
                if m and h then ok = (m ~= h) else ok = false end
            end
            if ok then
                local char = plr.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if IsAliveHumanoid(hum) then
                    local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                    if part then
                        local to = part.Position - camPos
                        local d = to.Magnitude
                        if d <= ASSIST.MaxDistance then
                            local ang = AngleBetween(look, to)
                            if ang <= ASSIST.FOV then
                                -- Wall check
                                local visible = true
                                if ASSIST.WallCheck then
                                    local rayParams = RaycastParams.new()
                                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                    rayParams.FilterDescendantsInstances = { player.Character, char }
                                    local hit = workspace:Raycast(camPos, to, rayParams)
                                    visible = (hit == nil)
                                end
                                if visible then
                                    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                                    local crosshairDist = onScreen and (Vector2.new(sp.X, sp.Y) - center).Magnitude or math.huge

                                    local score
                                    if ASSIST.TargetMode == "closest" then
                                        score = d
                                    elseif ASSIST.TargetMode == "lowest_hp" then
                                        score = (hum.Health / math.max(hum.MaxHealth, 1)) * 1000 + d * 0.01
                                    elseif ASSIST.TargetMode == "threat" then
                                        score = GetThreatScore(plr, char, camPos, look)
                                    else -- "crosshair"
                                        score = crosshairDist
                                    end

                                    if score < bestScore then
                                        bestScore, best, bestPart, bestChar = score, plr, part, char
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best, bestPart, bestChar
end

local function UpdateAssist()
    if not ASSIST.Enabled then
        assistIndicator.Visible = false
        return
    end

    local myChar = player.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not IsAliveHumanoid(myHum) then
        assistIndicator.Visible = false
        return
    end

    local targetPlr, targetPart, targetChar = AssistFindTarget()
    if not targetPart then
        assistIndicator.Visible = false
        return
    end

    local camPos = Camera.CFrame.Position
    local look = Camera.CFrame.LookVector
    local aimPos = targetPart.Position

    if ASSIST.Prediction then
        local vel = targetPart.AssemblyLinearVelocity
        local d = (aimPos - camPos).Magnitude
        aimPos = aimPos + vel * (d / math.max(ASSIST.PredictionSpeed, 1))
    end

    -- Distância angular (graus)
    local to = aimPos - camPos
    local angle = AngleBetween(look, to)
    local distanceFactor = 1 - math.clamp(angle / ASSIST.FOV, 0, 1)  -- 0 = longe, 1 = no alvo

    -- Trigger radius: se o alvo em tela está fora do trigger, não ativa
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    local sp, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    local crosshairDist = onScreen and (Vector2.new(sp.X, sp.Y) - center).Magnitude or math.huge

    if crosshairDist > ASSIST.TriggerRadius then
        assistIndicator.Visible = false
        return
    end

    -- Força final
    local base = ASSIST.Strength
    if ASSIST.Adaptive then
        base = base * (0.4 + distanceFactor * 0.6)
    end
    if ASSIST.Magnetic then
        base = base * (1 + (ASSIST.MagneticBoost - 1) * distanceFactor)
    end
    if distanceFactor > 0.85 then
        base = base * (1 + ASSIST.LockOn)
    end

    base = applyCurve(base, distanceFactor)
    base = math.clamp(base * (ASSIST.SmoothStrength / 60), 0, 0.95)

    -- CFrame desejado
    local des = CFrame.lookAt(camPos, aimPos)

    -- Aplica puxão
    local newCF = Camera.CFrame:Lerp(des, base)

    -- Vertical multiplier: atenua o pitch
    if ASSIST.VerticalAssist then
        local x, y, z = newCF:ToOrientation()
        local _, curY = Camera.CFrame:ToOrientation()
        local blended = math.rad(math.deg(curY) + (math.deg(y) - math.deg(curY)) * ASSIST.VerticalMultiplier)
        newCF = CFrame.new(newCF.Position) * CFrame.Angles(x, blended, z)
    end

    Camera.CFrame = newCF

    -- Indicador
    if ASSIST.ShowIndicator then
        assistIndicator.Visible = true
        assistIndicator.Position = UDim2.fromOffset(sp.X, sp.Y)
        assistIndicator.Size = UDim2.fromOffset(
            math.clamp(2000 / math.max((aimPos - camPos).Magnitude, 1), 30, 160),
            math.clamp(2000 / math.max((aimPos - camPos).Magnitude, 1), 30, 160)
        )
        local targetColor = Color3.fromRGB(46, 255, 126)
        if ASSIST.TargetMode == "lowest_hp" then targetColor = Color3.fromRGB(239, 68, 68)
        elseif ASSIST.TargetMode == "threat" then targetColor = Color3.fromRGB(251, 146, 60)
        elseif ASSIST.TargetMode == "closest" then targetColor = Color3.fromRGB(56, 189, 248)
        end
        assistIndicatorStroke.Color = targetColor
    end

    -- Sticky: reduz sensibilidade do mouse (se possível)
    if ASSIST.Sticky then
        pcall(function()
            UserInputService.MouseDeltaSensitivity = 1 - ASSIST.StickyStrength * distanceFactor
        end)
    else
        pcall(function() UserInputService.MouseDeltaSensitivity = 1 end)
    end
end

-- ==========================================================
--  NPC detection
-- ==========================================================
local NPC_CACHE, NPC_CACHE_TIME = {}, 0
local ZOMBIE_KEYWORDS = {
    "zombie","zumbi","walker","undead","infected","ghoul","monster","mob","enemy","npc","bot","dummy",
    "creature","hostile","demon","skeleton","target","training","test",
    "morto","infectado","monstro","inimigo","criatura","esqueleto","fantasma",
    "chefe","horda","onda","ataque","carniceiro","mutante","podre",
    "boneco","puppet","manequim","stand","clone","sombra",
}
local ZOMBIE_FOLDERS = {
    "zombie","zumbi","mob","enemy","inimigo","monster","monstro","npc","bots","dummy","dummies",
    "creature","spawn","hostile","horda","onda","ataque","spawner",
    "bonecos","boneco","puppets","puppet","stands","stand","clones","clone",
}
local NPC_TEAM_KEYWORDS = {
    ["red"]="RED",["blue"]="BLUE",["green"]="GREEN",["yellow"]="YELLOW",
    ["team1"]="T1",["team2"]="T2",["team3"]="T3",["team4"]="T4",
    ["ally"]="ALLY",["enemy"]="ENEMY",["neutral"]="NEUTRAL",
    ["vermelho"]="RED",["azul"]="BLUE",["verde"]="GREEN",["amarelo"]="YELLOW",
    ["aliado"]="ALLY",["inimigo"]="ENEMY",["neutro"]="NEUTRAL",
}
local function NameHasKeyword(name, list)
    local lower = string.lower(tostring(name))
    for _, kw in ipairs(list) do
        if string.find(lower, kw, 1, true) then return true end
    end
    return false
end
local function IsInsideZombieFolder(model)
    local p, depth = model.Parent, 0
    while p and p ~= workspace and depth < 4 do
        if NameHasKeyword(p.Name, ZOMBIE_FOLDERS) then return true end
        p = p.Parent; depth = depth + 1
    end
    return false
end
local function IsPlayerCharacter(model)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == model then return true end
    end
    return false
end
local function IsNPC(model)
    if not model or not model.Parent or not model:IsA("Model") then return false end
    if IsPlayerCharacter(model) or player.Character == model then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not IsAliveHumanoid(hum) then return false end
    if not ACONFIG.OnlyZombies then return true end
    if NameHasKeyword(model.Name, ZOMBIE_KEYWORDS) then return true end
    if IsInsideZombieFolder(model) then return true end
    if model.Parent and NameHasKeyword(model.Parent.Name, ZOMBIE_KEYWORDS) then return true end
    if hum.WalkSpeed and hum.WalkSpeed > 0 and hum.WalkSpeed ~= 16 then return true end
    for _, tag in ipairs(CollectionService:GetTags(model)) do
        local lt = string.lower(tag)
        if string.find(lt,"zombie") or string.find(lt,"zumbi") or string.find(lt,"enemy") or string.find(lt,"inimigo") then return true end
    end
    local head, torso = model:FindFirstChild("Head"), model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
    if head and torso and hum.Health > 0 and hum.MaxHealth > 0 and not model:FindFirstChild("leaderstats") then return true end
    return false
end
local function NPCGetPart(model)
    if not IsNPC(model) then return nil end
    local part = model:FindFirstChild("Head")
    if part then return part end
    for _, n in ipairs({"UpperTorso","Torso","HumanoidRootPart","LowerTorso"}) do
        local p = model:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    if model.PrimaryPart then return model.PrimaryPart end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then return p end
    end
    return nil
end
local function RefreshNPCCache()
    local now = tick()
    if now - NPC_CACHE_TIME < 0.5 then return end
    NPC_CACHE_TIME = now
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if IsNPC(obj) then table.insert(list, obj) end
    end
    NPC_CACHE = list
end
local function GetAllNPCs() RefreshNPCCache(); return NPC_CACHE end
local function NameToTeamKey(name)
    local lower = string.lower(tostring(name))
    for kw, key in pairs(NPC_TEAM_KEYWORDS) do
        if string.find(lower, kw, 1, true) then return key end
    end
    return nil
end
local function GetNPCTeamKey(npc)
    if not npc then return nil end
    for _, a in ipairs(TEAM_ATTR_NAMES) do
        local v = npc:GetAttribute(a)
        if v ~= nil then return "A:" .. (NameToTeamKey(v) or tostring(v)) end
    end
    for _, n in ipairs(TEAM_CHILD_NAMES) do
        local v = npc:FindFirstChild(n)
        if v and (v:IsA("StringValue") or v:IsA("IntValue") or v:IsA("NumberValue")) then
            return "C:" .. (NameToTeamKey(v.Value) or tostring(v.Value))
        end
    end
    local nameKey = NameToTeamKey(npc.Name)
    if nameKey then return "N:" .. nameKey end
    local p, depth = npc.Parent, 0
    while p and p ~= workspace and depth < 4 do
        local fk = NameToTeamKey(p.Name)
        if fk then return "F:" .. fk end
        p = p.Parent; depth = depth + 1
    end
    for _, tag in ipairs(CollectionService:GetTags(npc)) do
        local tk = NameToTeamKey(tag)
        if tk then return "T:" .. tk end
    end
    return nil
end
local function NPCIsEnemy(npc)
    if not ACONFIG.NPCTeamCheck then return true end
    local nk, mk = GetNPCTeamKey(npc), GetTeamKey(player)
    if not nk or not mk then return true end
    local function strip(s) return s:match("^%a+:(.+)$") or s end
    return strip(nk) ~= strip(mk)
end

-- ==========================================================
--  AIM CORE
-- ==========================================================
local AIM_LAST_SWITCH, AIM_LOCK_START = 0, 0
local lockTarget, lockPart, lockKind = nil, nil, nil
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
    local best, bestPart, bestScore, bestDist, bestKind = nil, nil, math.huge, nil, nil
    if ACONFIG.EnabledPlayers then
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
                            bestScore, best, bestPart, bestDist, bestKind = score, plr, part, d, "player"
                        end
                    end
                end
            end
        end
    end
    if ACONFIG.EnabledNPCs then
        for _, npc in ipairs(GetAllNPCs()) do
            if NPCIsEnemy(npc) then
                local part = NPCGetPart(npc)
                if part then
                    local to = part.Position - mp
                    local d = to.Magnitude
                    if d <= ACONFIG.MaxDistance then
                        local ang = AngleBetween(ml, to)
                        if ang <= ACONFIG.FOV then
                            local score = d * ACONFIG.WeightDistance + ang * ACONFIG.WeightAngle
                            if score < bestScore then
                                bestScore, best, bestPart, bestDist, bestKind = score, npc, part, d, "npc"
                            end
                        end
                    end
                end
            end
        end
    end
    return best, bestPart, bestScore, bestDist, bestKind
end

local function GetDistToTarget()
    if not lockPart then return nil end
    return (lockPart.Position - Camera.CFrame.Position).Magnitude
end

local function UpdateLock()
    local myChar = player.Character
    if not myChar then
        lockTarget, lockPart, lockKind = nil, nil, nil
        return
    end
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not IsAliveHumanoid(myHum) then
        lockTarget, lockPart, lockKind = nil, nil, nil
        return
    end

    -- AIM PLAYERS + NPCs
    if ACONFIG.EnabledPlayers or ACONFIG.EnabledNPCs then
        local now = tick()
        local best, bestPart, _, bestDist, bestKind = FindBestTarget()
        local curStillValid = false
        if lockTarget then
            if lockKind == "player" then
                curStillValid = IsEnemy(lockTarget) and (GetPlayerPart(lockTarget) ~= nil)
            elseif lockKind == "npc" then
                curStillValid = (lockTarget.Parent ~= nil) and IsNPC(lockTarget) and NPCIsEnemy(lockTarget) and (NPCGetPart(lockTarget) ~= nil)
            end
        end
        if lockTarget and not curStillValid then
            lockTarget, lockPart, lockKind = nil, nil, nil
        end
        if best and bestPart then
            local shouldSwitch = false
            if not lockTarget then
                shouldSwitch = true
            elseif best ~= lockTarget then
                local curDist = GetDistToTarget()
                if not curDist then shouldSwitch = true
                elseif bestDist and (curDist - bestDist) >= (ACONFIG.SwitchMargin or 0) then shouldSwitch = true end
            else
                lockPart = bestPart
            end
            if shouldSwitch then
                lockTarget, lockPart, lockKind = best, bestPart, bestKind
                AIM_LAST_SWITCH = now
                AIM_LOCK_START = now
            end
        else
            lockTarget, lockPart, lockKind = nil, nil, nil
        end
        if lockTarget and lockPart then
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
        return
    end

    -- AIM ASSIST (v3.6)
    UpdateAssist()
end

local okBind = pcall(function()
    RunService:BindToRenderStep("AimUnified", Enum.RenderPriority.Last.Value, UpdateLock)
end)
if not okBind then
    RunService.RenderStepped:Connect(UpdateLock)
end

local function MaybeClearLock()
    if not ACONFIG.EnabledPlayers and not ACONFIG.EnabledNPCs then
        lockTarget, lockPart, lockKind = nil, nil, nil
        AIM_LAST_SWITCH = 0
        AIM_LOCK_START = 0
    end
end

-- ==========================================================
--  🚀 VOO
-- ==========================================================
local FlyEnabled, FlySpeed = false, 60
local FlyConnection, BodyVelocity, BodyForce = nil, nil, nil
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
    if FlyEnabled then task.wait(0.5) RemoveFlyParts() StartFly() end
end)

-- ==========================================================
--  SPEED / JUMP / FOV
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
        if hum then hum.UseJumpPower = true; hum.JumpPower = ConfigState.JumpValue end
    end
    if ConfigState.FOVEnabled and Camera then
        Camera.FieldOfView = ConfigState.FOVValue
    end
end)

-- ==========================================================
--  🧱 NOCLIP
-- ==========================================================
local NoclipEnabled, NoclipConn = false, nil
local function NoclipApplyToChar(char)
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
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
            if p:IsA("BasePart") then pcall(function() p.CanCollide = true end) end
        end
    end
end
player.CharacterAdded:Connect(function(char)
    if NoclipEnabled then task.wait(0.2) NoclipApplyToChar(char) NoclipStart() end
end)

-- ==========================================================
--  🔦 FULLBRIGHT
-- ==========================================================
local FullbrightEnabled = false
local FullbrightConns   = {}
local FullbrightBackup  = nil
local function SaveOriginalLighting()
    FullbrightBackup = {
        Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, FogColor = Lighting.FogColor,
        GlobalShadows = Lighting.GlobalShadows,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        ExposureCompensation = Lighting.ExposureCompensation,
        Effects = {},
    }
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("Atmosphere") then
            FullbrightBackup.Effects[e] = { Density=e.Density, Haze=e.Haze, Glare=e.Glare, Color=e.Color, Decay=e.Decay }
        elseif e:IsA("ColorCorrectionEffect") then
            FullbrightBackup.Effects[e] = { Brightness=e.Brightness, Contrast=e.Contrast, Saturation=e.Saturation, TintColor=e.TintColor }
        elseif e:IsA("BloomEffect") then
            FullbrightBackup.Effects[e] = { Intensity=e.Intensity }
        elseif e:IsA("BlurEffect") then
            FullbrightBackup.Effects[e] = { Size=e.Size }
        elseif e:IsA("SunRaysEffect") then
            FullbrightBackup.Effects[e] = { Intensity=e.Intensity }
        end
    end
end
local function FullbrightApply()
    if not FullbrightBackup then SaveOriginalLighting() end
    Lighting.Ambient = Color3.fromRGB(130,130,130)
    Lighting.OutdoorAmbient = Color3.fromRGB(140,140,140)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000; Lighting.FogStart = 100000
    Lighting.GlobalShadows = true
    Lighting.EnvironmentDiffuseScale = 0.5
    Lighting.EnvironmentSpecularScale = 0.5
    Lighting.ExposureCompensation = 0
    for _, ef in ipairs(Lighting:GetChildren()) do
        if ef:IsA("Atmosphere") then ef.Density=0.1; ef.Haze=0; ef.Glare=0
        elseif ef:IsA("ColorCorrectionEffect") then ef.Brightness=0; ef.Contrast=0; ef.Saturation=0; ef.TintColor=Color3.fromRGB(255,255,255)
        elseif ef:IsA("BloomEffect") then ef.Intensity=0
        elseif ef:IsA("BlurEffect") then ef.Size=0
        elseif ef:IsA("SunRaysEffect") then ef.Intensity=0 end
    end
end
local function FullbrightStart()
    FullbrightApply()
    for _, c in ipairs(FullbrightConns) do if c and c.Disconnect then pcall(function() c:Disconnect() end) end end
    FullbrightConns = {}
    table.insert(FullbrightConns, Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
        if FullbrightEnabled and (Lighting.ClockTime < 10 or Lighting.ClockTime > 17) then Lighting.ClockTime = 14 end
    end))
    table.insert(FullbrightConns, Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
        if FullbrightEnabled and Lighting.Brightness < 1.5 then Lighting.Brightness = 2 end
    end))
end
local function FullbrightStop()
    for _, c in ipairs(FullbrightConns) do if c and c.Disconnect then pcall(function() c:Disconnect() end) end end
    FullbrightConns = {}
    if FullbrightBackup then
        Lighting.Ambient = FullbrightBackup.Ambient
        Lighting.OutdoorAmbient = FullbrightBackup.OutdoorAmbient
        Lighting.Brightness = FullbrightBackup.Brightness
        Lighting.ClockTime = FullbrightBackup.ClockTime
        Lighting.FogEnd = FullbrightBackup.FogEnd
        Lighting.FogStart = FullbrightBackup.FogStart
        Lighting.FogColor = FullbrightBackup.FogColor
        Lighting.GlobalShadows = FullbrightBackup.GlobalShadows
        Lighting.EnvironmentDiffuseScale = FullbrightBackup.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = FullbrightBackup.EnvironmentSpecularScale
        Lighting.ExposureCompensation = FullbrightBackup.ExposureCompensation
        for ef, vals in pairs(FullbrightBackup.Effects) do
            if ef and ef.Parent then for k, v in pairs(vals) do pcall(function() ef[k] = v end) end end
        end
        FullbrightBackup = nil
    end
end

-- ==========================================================
--  👁️ ESP MODERNO (v3.6)
-- ==========================================================
local ESP_CONFIG = {
    Enabled = true,
    -- Elementos
    Skeleton = true,
    Box = true,        -- caixa completa
    CornerBox = true,  -- corner brackets (tipo FPS)
    Name = true,
    Distance = true,
    Health = true,
    HeadDot = true,
    Chams = false,     -- Highlight 3D
    Tracer = false,
    -- Filtros
    TeamCheck = true,
    WallCheck = true,  -- dim quando atrás de parede
    MaxDistance = 1500,
    FadeDistance = 400, -- começa a desbotar
    -- Estilo
    Color = Color3.fromRGB(255, 60, 60),
    HiddenColor = Color3.fromRGB(150, 40, 40),
    TargetColor = Color3.fromRGB(46, 255, 126),
    TextSize = 12,
    Thickness = 1.5,
    CornerLength = 0.28,
    Rounded = true,
    Glow = true,
    Pulse = true,
}

local SKELETON_R15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local SKELETON_R6 = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local ESP_DRAWS = {}
local ESP_MAX_SKEL = 20

local function ESPRemoveDraw(plr)
    local d = ESP_DRAWS[plr]
    if d then
        for _, f in ipairs(d.skeleton) do pcall(function() f:Destroy() end) end
        for _, f in ipairs(d.box) do pcall(function() f:Destroy() end) end
        for _, f in ipairs(d.corners) do pcall(function() f:Destroy() end) end
        if d.joint then for _, f in ipairs(d.joint) do pcall(function() f:Destroy() end) end end
        if d.name then pcall(function() d.name:Destroy() end) end
        if d.nameBg then pcall(function() d.nameBg:Destroy() end) end
        if d.dist then pcall(function() d.dist:Destroy() end) end
        if d.distBg then pcall(function() d.distBg:Destroy() end) end
        if d.healthBg then pcall(function() d.healthBg:Destroy() end) end
        if d.healthFill then pcall(function() d.healthFill:Destroy() end) end
        if d.healthStroke then pcall(function() d.healthStroke:Destroy() end) end
        if d.headDot then pcall(function() d.headDot:Destroy() end) end
        if d.headRing then pcall(function() d.headRing:Destroy() end) end
        if d.tracer then pcall(function() d.tracer:Destroy() end) end
        if d.chams then pcall(function() d.chams:Destroy() end) end
        ESP_DRAWS[plr] = nil
    end
end

local function ESPIsEnemy(plr)
    if plr == player then return false end
    local char = plr.Character
    if not char or not char.Parent then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not ESP_CONFIG.TeamCheck then return true end
    local m, h = GetTeamKey(player), GetTeamKey(plr)
    if m and h then return m ~= h end
    return false
end

local function W2S(worldPos)
    local sp, onScreen = Camera:WorldToViewportPoint(worldPos)
    return Vector2.new(sp.X, sp.Y), onScreen, sp.Z
end

local function ESPCreateDraw(plr, char)
    ESPRemoveDraw(plr)
    local d = { char = char, plr = plr,
        skeleton = {}, box = {}, corners = {}, joint = {},
    }

    -- Skeleton lines (com glow: dois strokes sobrepostos)
    for i = 1, ESP_MAX_SKEL do
        local f = make("Frame", {
            BackgroundColor3 = ESP_CONFIG.Color,
            BorderSizePixel = 0, Visible = false, ZIndex = 20,
            AnchorPoint = Vector2.new(0.5, 0.5),
        }, gui)
        d.skeleton[i] = f
    end

    -- Joint circles (nos cotovelos/joelhos/etc)
    for i = 1, 16 do
        local f = make("Frame", {
            Size = UDim2.fromOffset(6, 6),
            BackgroundColor3 = ESP_CONFIG.Color,
            BorderSizePixel = 0, Visible = false, ZIndex = 21,
            AnchorPoint = Vector2.new(0.5, 0.5),
        }, gui)
        round(f, 3)
        d.joint[i] = f
    end

    -- Box completa
    for i = 1, 4 do
        local f = make("Frame", {
            BackgroundColor3 = ESP_CONFIG.Color,
            BorderSizePixel = 0, Visible = false, ZIndex = 19,
            AnchorPoint = Vector2.new(0.5, 0.5),
        }, gui)
        d.box[i] = f
    end

    -- Corner brackets (4 cantos × 2 linhas = 8 frames)
    for i = 1, 8 do
        local f = make("Frame", {
            BackgroundColor3 = ESP_CONFIG.Color,
            BorderSizePixel = 0, Visible = false, ZIndex = 20,
            AnchorPoint = Vector2.new(0.5, 0.5),
        }, gui)
        d.corners[i] = f
    end

    -- Head dot
    d.headDot = make("Frame", {
        Size = UDim2.fromOffset(6, 6), BackgroundColor3 = ESP_CONFIG.Color,
        BorderSizePixel = 0, Visible = false, ZIndex = 22,
        AnchorPoint = Vector2.new(0.5, 0.5),
    }, gui)
    round(d.headDot, 3)
    d.headRing = make("Frame", {
        Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1,
        Visible = false, ZIndex = 22, AnchorPoint = Vector2.new(0.5, 0.5),
    }, gui)
    round(d.headRing, 7)
    d.headRingStroke = stroke(d.headRing, ESP_CONFIG.Color, 1.5, 0.3)

    -- Health bar (fundo + fill + gradiente)
    d.healthBg = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20), BackgroundTransparency = 0.35,
        BorderSizePixel = 0, Visible = false, ZIndex = 21,
        AnchorPoint = Vector2.new(1, 0),
    }, gui)
    round(d.healthBg, 3)
    d.healthFill = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(52, 211, 153),
        Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, Visible = false,
        ZIndex = 22, AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
    }, d.healthBg)
    round(d.healthFill, 3)
    d.healthStroke = stroke(d.healthBg, Color3.fromRGB(255,255,255), 1, 0.7)

    -- Nome com painel
    d.nameBg = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.45,
        Size = UDim2.fromOffset(120, 20), BorderSizePixel = 0, Visible = false,
        ZIndex = 22, AnchorPoint = Vector2.new(0.5, 1),
    }, gui)
    round(d.nameBg, 6)
    d.name = make("TextLabel", {
        BackgroundTransparency = 1, TextColor3 = ESP_CONFIG.Color,
        Font = Enum.Font.GothamBold, TextSize = ESP_CONFIG.TextSize,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
        Visible = false, ZIndex = 23, Size = UDim2.fromScale(1, 1),
    }, d.nameBg)

    -- Distância com painel
    d.distBg = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.45,
        Size = UDim2.fromOffset(80, 18), BorderSizePixel = 0, Visible = false,
        ZIndex = 22, AnchorPoint = Vector2.new(0.5, 0),
    }, gui)
    round(d.distBg, 5)
    d.dist = make("TextLabel", {
        BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.GothamMedium, TextSize = ESP_CONFIG.TextSize - 1,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
        Visible = false, ZIndex = 23, Size = UDim2.fromScale(1, 1),
    }, d.distBg)

    -- Tracer
    d.tracer = make("Frame", {
        BackgroundColor3 = ESP_CONFIG.Color, BorderSizePixel = 0,
        Visible = false, ZIndex = 18, AnchorPoint = Vector2.new(0.5, 0.5),
    }, gui)

    ESP_DRAWS[plr] = d
end

local function ESPHideAll(d)
    for _, f in ipairs(d.skeleton) do f.Visible = false end
    for _, f in ipairs(d.joint) do f.Visible = false end
    for _, f in ipairs(d.box) do f.Visible = false end
    for _, f in ipairs(d.corners) do f.Visible = false end
    if d.headDot then d.headDot.Visible = false end
    if d.headRing then d.headRing.Visible = false end
    if d.healthBg then d.healthBg.Visible = false end
    if d.healthFill then d.healthFill.Visible = false end
    if d.nameBg then d.nameBg.Visible = false end
    if d.distBg then d.distBg.Visible = false end
    if d.tracer then d.tracer.Visible = false end
    if d.chams then d.chams.OutlineTransparency = 1; d.chams.FillTransparency = 1 end
end

local function DrawLine2D(frame, p1, p2, color, thickness, transparency)
    local diff = p2 - p1
    local length = diff.Magnitude
    if length < 1 or length > 4000 then
        frame.Visible = false
        return
    end
    local center = (p1 + p2) * 0.5
    local angle = math.deg(math.atan2(diff.Y, diff.X))
    frame.Visible = true
    frame.Position = UDim2.fromOffset(center.X, center.Y)
    frame.Size = UDim2.fromOffset(length, thickness or 1)
    frame.Rotation = angle
    frame.BackgroundColor3 = color
    if transparency then frame.BackgroundTransparency = transparency end
end

local function CheckVisible(char)
    if not ESP_CONFIG.WallCheck then return true end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { player.Character, char }
    local camPos = Camera.CFrame.Position
    local hit = workspace:Raycast(camPos, hrp.Position - camPos, rayParams)
    return hit == nil
end

local function ESPUpdateDraw(d)
    local plr = d.plr
    local char = plr.Character
    if not char or char ~= d.char or not ESPIsEnemy(plr) then
        ESPHideAll(d); return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then ESPHideAll(d); return end

    local camPos = Camera.CFrame.Position
    local dist = (hrp.Position - camPos).Magnitude
    if dist > ESP_CONFIG.MaxDistance then ESPHideAll(d); return end

    -- Viewport cull
    local spCheck, onCheck = Camera:WorldToViewportPoint(hrp.Position)
    if not onCheck then ESPHideAll(d); return end

    -- Fade por distância
    local fadeAlpha = 1
    if dist > ESP_CONFIG.FadeDistance then
        fadeAlpha = math.clamp(1 - (dist - ESP_CONFIG.FadeDistance) / (ESP_CONFIG.MaxDistance - ESP_CONFIG.FadeDistance), 0.25, 1)
    end
    local fadeTr = 1 - fadeAlpha

    -- Cor base
    local isTarget = (lockTarget == plr)
    local baseColor = ESP_CONFIG.Color
    if isTarget then
        baseColor = ESP_CONFIG.TargetColor
    elseif not CheckVisible(char) then
        baseColor = ESP_CONFIG.HiddenColor
    end

    local thickness = ESP_CONFIG.Thickness

    -- ============ SKELETON ============
    if ESP_CONFIG.Skeleton then
        local bones = char:FindFirstChild("UpperTorso") and SKELETON_R15 or SKELETON_R6
        local lineIdx, jointIdx = 0, 0
        local seenParts = {}
        for _, pair in ipairs(bones) do
            local p1 = char:FindFirstChild(pair[1])
            local p2 = char:FindFirstChild(pair[2])
            if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
                local sp1, on1 = W2S(p1.Position)
                local sp2, on2 = W2S(p2.Position)
                if on1 and on2 then
                    lineIdx = lineIdx + 1
                    if d.skeleton[lineIdx] then
                        DrawLine2D(d.skeleton[lineIdx], sp1, sp2, baseColor, thickness + 0.5, fadeTr)
                    end
                    -- joint dots
                    for _, pp in ipairs({pair[1], pair[2]}) do
                        if not seenParts[pp] and jointIdx < #d.joint then
                            seenParts[pp] = true
                            jointIdx = jointIdx + 1
                            local part = char:FindFirstChild(pp)
                            if part and part:IsA("BasePart") then
                                local sp = W2S(part.Position)
                                d.joint[jointIdx].Visible = true
                                d.joint[jointIdx].Position = UDim2.fromOffset(sp.X, sp.Y)
                                d.joint[jointIdx].BackgroundColor3 = baseColor
                                d.joint[jointIdx].BackgroundTransparency = fadeTr
                            end
                        end
                    end
                end
            end
        end
        for i = lineIdx + 1, #d.skeleton do d.skeleton[i].Visible = false end
        for i = jointIdx + 1, #d.joint do d.joint[i].Visible = false end
    else
        for _, f in ipairs(d.skeleton) do f.Visible = false end
        for _, f in ipairs(d.joint) do f.Visible = false end
    end

    -- ============ BOX (com corner brackets) ============
    local minX, minY, maxX, maxY
    local ok, cf, size = pcall(function() return char:GetBoundingBox() end)
    if ok and cf then
        local corners = {}
        for x = -1, 1, 2 do
            for y = -1, 1, 2 do
                for z = -1, 1, 2 do
                    table.insert(corners, cf:PointToWorldSpace(Vector3.new(
                        size.X * x / 2, size.Y * y / 2, size.Z * z / 2)))
                end
            end
        end
        minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local anyOnScreen = false
        for _, wp in ipairs(corners) do
            local sp, on = W2S(wp)
            if on then
                anyOnScreen = true
                minX = math.min(minX, sp.X); minY = math.min(minY, sp.Y)
                maxX = math.max(maxX, sp.X); maxY = math.max(maxY, sp.Y)
            end
        end
        if anyOnScreen then
            -- Caixa completa
            if ESP_CONFIG.Box then
                local tl = Vector2.new(minX, minY)
                local tr = Vector2.new(maxX, minY)
                local br = Vector2.new(maxX, maxY)
                local bl = Vector2.new(minX, maxY)
                DrawLine2D(d.box[1], tl, tr, baseColor, 1.5, fadeTr + 0.2)
                DrawLine2D(d.box[2], tr, br, baseColor, 1.5, fadeTr + 0.2)
                DrawLine2D(d.box[3], br, bl, baseColor, 1.5, fadeTr + 0.2)
                DrawLine2D(d.box[4], bl, tl, baseColor, 1.5, fadeTr + 0.2)
            else
                for _, f in ipairs(d.box) do f.Visible = false end
            end

            -- Corner brackets
            if ESP_CONFIG.CornerBox then
                local w = maxX - minX
                local h = maxY - minY
                local cw = w * ESP_CONFIG.CornerLength
                local ch = h * ESP_CONFIG.CornerLength
                local cornerSize = 3

                local function drawCorner(idx, cornerX, cornerY, dirX, dirY)
                    -- Horizontal
                    local cx = cornerX + dirX * cw / 2
                    local cy = cornerY
                    d.corners[idx].Visible = true
                    d.corners[idx].Position = UDim2.fromOffset(cx, cy)
                    d.corners[idx].Size = UDim2.fromOffset(cw, cornerSize)
                    d.corners[idx].Rotation = 0
                    d.corners[idx].BackgroundColor3 = baseColor
                    d.corners[idx].BackgroundTransparency = fadeTr
                    -- Vertical
                    local vx = cornerX
                    local vy = cornerY + dirY * ch / 2
                    d.corners[idx + 1].Visible = true
                    d.corners[idx + 1].Position = UDim2.fromOffset(vx, vy)
                    d.corners[idx + 1].Size = UDim2.fromOffset(cornerSize, ch)
                    d.corners[idx + 1].Rotation = 0
                    d.corners[idx + 1].BackgroundColor3 = baseColor
                    d.corners[idx + 1].BackgroundTransparency = fadeTr
                end

                drawCorner(1, minX, minY, 1, 1)
                drawCorner(3, maxX, minY, -1, 1)
                drawCorner(5, minX, maxY, 1, -1)
                drawCorner(7, maxX, maxY, -1, -1)
            else
                for _, f in ipairs(d.corners) do f.Visible = false end
            end

            -- Health bar
            if ESP_CONFIG.Health then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local ratio = hum.MaxHealth > 0 and math.clamp(hum.Health / hum.MaxHealth, 0, 1) or 0
                    local hbX = minX - 8
                    local hbY = minY
                    local hbW = 4
                    local hbH = maxY - minY
                    d.healthBg.Visible = true
                    d.healthBg.Position = UDim2.fromOffset(hbX + hbW, hbY)
                    d.healthBg.Size = UDim2.fromOffset(hbW, hbH)
                    d.healthBg.BackgroundTransparency = 0.35 + fadeTr * 0.4
                    d.healthFill.Visible = true
                    d.healthFill.Size = UDim2.fromScale(1, ratio)
                    d.healthFill.BackgroundTransparency = fadeTr * 0.5
                    -- Cor por vida: verde→amarelo→vermelho
                    local col
                    if ratio > 0.6 then col = Color3.fromRGB(52, 211, 153)
                    elseif ratio > 0.3 then col = Color3.fromRGB(250, 204, 21)
                    else col = Color3.fromRGB(239, 68, 68) end
                    d.healthFill.BackgroundColor3 = col
                else
                    d.healthBg.Visible = false; d.healthFill.Visible = false
                end
            else
                d.healthBg.Visible = false; d.healthFill.Visible = false
            end
        end
    else
        for _, f in ipairs(d.box) do f.Visible = false end
        for _, f in ipairs(d.corners) do f.Visible = false end
        d.healthBg.Visible = false; d.healthFill.Visible = false
    end

    -- ============ HEAD DOT ============
    if ESP_CONFIG.HeadDot then
        local head = char:FindFirstChild("Head") or hrp
        local sp, on = W2S(head.Position + Vector3.new(0, 0.6, 0))
        if on then
            d.headDot.Visible = true
            d.headDot.Position = UDim2.fromOffset(sp.X, sp.Y)
            d.headDot.BackgroundColor3 = baseColor
            d.headDot.BackgroundTransparency = fadeTr
            d.headRing.Visible = true
            d.headRing.Position = UDim2.fromOffset(sp.X, sp.Y)
            d.headRingStroke.Color = baseColor
            d.headRingStroke.Transparency = 0.3 + fadeTr * 0.4
        else
            d.headDot.Visible = false; d.headRing.Visible = false
        end
    else
        d.headDot.Visible = false; d.headRing.Visible = false
    end

    -- ============ NAME ============
    if ESP_CONFIG.Name then
        local head = char:FindFirstChild("Head") or hrp
        local sp, on = W2S(head.Position + Vector3.new(0, 2.2, 0))
        if on then
            d.nameBg.Visible = true
            d.name.Visible = true
            d.nameBg.Position = UDim2.fromOffset(sp.X, sp.Y)
            d.nameBg.BackgroundTransparency = 0.45 + fadeTr * 0.3
            d.name.Text = plr.DisplayName
            d.name.TextColor3 = baseColor
            d.name.TextTransparency = fadeTr * 0.6
        else
            d.nameBg.Visible = false; d.name.Visible = false
        end
    else
        d.nameBg.Visible = false; d.name.Visible = false
    end

    -- ============ DISTANCE ============
    if ESP_CONFIG.Distance then
        local head = char:FindFirstChild("Head") or hrp
        local sp, on = W2S(head.Position - Vector3.new(0, 1.0, 0))
        if on then
            d.distBg.Visible = true
            d.dist.Visible = true
            d.distBg.Position = UDim2.fromOffset(sp.X, sp.Y)
            d.distBg.BackgroundTransparency = 0.45 + fadeTr * 0.3
            d.dist.Text = string.format("%d m", math.floor(dist))
            d.dist.TextTransparency = fadeTr * 0.4
        else
            d.distBg.Visible = false; d.dist.Visible = false
        end
    else
        d.distBg.Visible = false; d.dist.Visible = false
    end

    -- ============ TRACER ============
    if ESP_CONFIG.Tracer then
        local from = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
        local to = Vector2.new((minX or 0 + maxX or 0) / 2, maxY or 0)
        if minX then
            to = Vector2.new((minX + maxX) / 2, maxY)
        else
            local sp, on = W2S(hrp.Position)
            if on then to = sp else to = from end
        end
        local diff = to - from
        d.tracer.Visible = true
        d.tracer.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
        d.tracer.Size = UDim2.fromOffset(diff.Magnitude, thickness)
        d.tracer.Rotation = math.deg(math.atan2(diff.Y, diff.X))
        d.tracer.BackgroundColor3 = baseColor
        d.tracer.BackgroundTransparency = 0.35 + fadeTr * 0.4
    else
        d.tracer.Visible = false
    end

    -- ============ CHAMS ============
    if ESP_CONFIG.Chams then
        if not d.chams then
            d.chams = Instance.new("Highlight")
            d.chams.Name = "PP_Chams"
            d.chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            d.chams.FillTransparency = 0.75
            d.chams.Parent = char
        end
        d.chams.OutlineColor = baseColor
        d.chams.FillColor = baseColor
        d.chams.OutlineTransparency = fadeTr * 0.6
        d.chams.FillTransparency = 0.75 + fadeTr * 0.2
    elseif d.chams then
        d.chams:Destroy()
        d.chams = nil
    end
end

-- Loop do ESP
RunService.RenderStepped:Connect(function()
    if not ESP_CONFIG.Enabled then
        for _, d in pairs(ESP_DRAWS) do ESPHideAll(d) end
        return
    end
    for _, d in pairs(ESP_DRAWS) do ESPUpdateDraw(d) end
end)

local function ESPRefresh()
    if not ESP_CONFIG.Enabled then
        for plr, _ in pairs(ESP_DRAWS) do ESPRemoveDraw(plr) end
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            if ESPIsEnemy(plr) and plr.Character then
                local d = ESP_DRAWS[plr]
                if not d or d.char ~= plr.Character then
                    ESPCreateDraw(plr, plr.Character)
                end
            else
                if ESP_DRAWS[plr] then ESPRemoveDraw(plr) end
            end
        end
    end
end
task.spawn(function()
    while true do
        ESPRefresh()
        task.wait(0.3)
    end
end)

local function ESPApplyColor(newColor)
    ESP_CONFIG.Color = newColor
    for _, d in pairs(ESP_DRAWS) do
        for _, f in ipairs(d.skeleton) do f.BackgroundColor3 = newColor end
        for _, f in ipairs(d.joint) do f.BackgroundColor3 = newColor end
        for _, f in ipairs(d.box) do f.BackgroundColor3 = newColor end
        for _, f in ipairs(d.corners) do f.BackgroundColor3 = newColor end
        if d.headDot then d.headDot.BackgroundColor3 = newColor end
        if d.headRingStroke then d.headRingStroke.Color = newColor end
        if d.name then d.name.TextColor3 = newColor end
        if d.tracer then d.tracer.BackgroundColor3 = newColor end
    end
end
local function ESPClearAll()
    for plr, _ in pairs(ESP_DRAWS) do ESPRemoveDraw(plr) end
end
local function ESPUpdateTeamCheck()
    for plr, _ in pairs(ESP_DRAWS) do
        if not ESPIsEnemy(plr) then ESPRemoveDraw(plr) end
    end
    ESPRefresh()
end

-- ==========================================================
--  TP + AUTO CLICK
-- ==========================================================
local TPPoints = {}
local function TeleportTo(pos)
    local c = player.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r then return false end
    pcall(function()
        r.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        r.Velocity = Vector3.new(0, 0, 0)
    end)
    return true
end

local AutoClick = { Enabled=false, CPS=30, Thread=nil, Touching=false, BubbleVisible=false }
local AC_BUBBLE = 80
local acBubble = make("Frame", {
    Name = "AutoClickBubble", Size = UDim2.fromOffset(AC_BUBBLE, AC_BUBBLE),
    Position = UDim2.fromOffset(200, 300), BackgroundColor3 = Color3.fromRGB(239, 68, 68),
    Visible = false, ZIndex = 300,
}, gui)
round(acBubble, AC_BUBBLE / 2)
make("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(239,68,68), Color3.fromRGB(250,204,21)), Rotation = 45 }, acBubble)
stroke(acBubble, THEME.White, 3, 0.2)
local acScale = make("UIScale", { Scale = 0 }, acBubble)
make("TextLabel", {
    BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
    Text = "👆", TextColor3 = THEME.White, TextSize = 38,
    Font = Enum.Font.GothamBold, ZIndex = 301,
}, acBubble)
local acHit = make("TextButton", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = "", ZIndex = 302 }, acBubble)
local function ACStartClickLoop()
    if AutoClick.Thread then return end
    AutoClick.Thread = task.spawn(function()
        while AutoClick.Touching and AutoClick.Enabled do
            pcall(function() VirtualUser:Button1Down(Vector2.new(0,0)) end)
            pcall(function() VirtualUser:Button1Up(Vector2.new(0,0)) end)
            task.wait(1 / math.max(AutoClick.CPS, 1))
        end
        AutoClick.Thread = nil
    end)
end
local function ACStopClickLoop() AutoClick.Touching = false end
local function ACShowBubble(show)
    AutoClick.BubbleVisible = show
    if show then
        acBubble.Visible = true; acScale.Scale = 0
        tween(acScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back)
    else
        tween(acScale, { Scale = 0 }, 0.2)
        task.delay(0.22, function() if not AutoClick.BubbleVisible then acBubble.Visible = false end end)
        ACStopClickLoop()
    end
end
do
    local dragging, dragStart, startPos, moved = false, nil, nil, false
    acHit.InputBegan:Connect(function(input)
        if isPointer(input) then
            dragging = true; moved = false
            dragStart = input.Position; startPos = acBubble.Position
            if AutoClick.Enabled then
                AutoClick.Touching = true
                ACStartClickLoop()
                tween(acScale, { Scale = 0.9 }, 0.08)
            end
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if dragging and isMove(input) then
            local d = input.Position - dragStart
            if not moved and d.Magnitude > 8 then moved = true; ACStopClickLoop() end
            if moved then
                local vp = gui.AbsoluteSize
                acBubble.Position = UDim2.fromOffset(
                    math.clamp(startPos.X.Offset + d.X, 8, vp.X - AC_BUBBLE - 8),
                    math.clamp(startPos.Y.Offset + d.Y, 30, vp.Y - AC_BUBBLE - 8))
            end
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if dragging and isPointer(input) then
            dragging = false
            tween(acScale, { Scale = 1 }, 0.15)
            ACStopClickLoop()
        end
    end)
end

-- ==========================================================
--  TABS
-- ==========================================================
local aimTab = newTab("Aim", "🎯", 1)
text(aimTab, "Aimbot Players", 20, THEME.Text, Enum.Font.GothamBold)
addToggle(aimTab, "🎯 Ativar Aim Players", false, function(v)
    ACONFIG.EnabledPlayers = v; MaybeClearLock()
    notify(v and "🎯 Aim Players ON" or "OFF")
end)
addToggle(aimTab, "🛡️ Team Check", true, function(v) ACONFIG.TeamCheck = v end)
addToggle(aimTab, "🎯 Predição", false, function(v) ACONFIG.Prediction = v end)
addToggle(aimTab, "🔥 Auto Fire", false, function(v) ACONFIG.AutoFire = v end)
addToggle(aimTab, "🎯 Ignorar ângulo", true, function(v)
    ACONFIG.WeightAngle = v and 0.05 or 1.0
end)
addSlider(aimTab, "FOV", 5, 360, 360, function(v) ACONFIG.FOV = v end)
addSlider(aimTab, "Distância máx", 20, 8000, 5000, function(v) ACONFIG.MaxDistance = v end)
addSlider(aimTab, "Velocidade bala", 50, 3000, 400, function(v) ACONFIG.PredictionSpeed = v end)
addSlider(aimTab, "Suavidade", 0, 1, 0, function(v) ACONFIG.Smoothness = v end, 2)

-- ==========================================================
--  ASSIST TAB (NOVO)
-- ==========================================================
local assistTab = newTab("Assist", "✨", 2)
text(assistTab, "Aim Assist Turbinado", 20, THEME.Text, Enum.Font.GothamBold)
text(assistTab, "Só ativa quando a mira está perto do alvo.", 12, THEME.SubText)
addToggle(assistTab, "✨ Ativar Aim Assist", false, function(v)
    ASSIST.Enabled = v
    if not v then assistIndicator.Visible = false end
    notify(v and "✨ Assist ON" or "OFF")
end)
addDropdown(assistTab, "🎯 Modo de alvo", {"crosshair", "closest", "lowest_hp", "threat"}, "crosshair", function(v)
    ASSIST.TargetMode = v
    notify("Modo: " .. v)
end)
addToggle(assistTab, "🛡️ Team Check", true, function(v) ASSIST.TeamCheck = v end)
addToggle(assistTab, "🎯 Predição", false, function(v) ASSIST.Prediction = v end)
addToggle(assistTab, "🧲 Magnetic", true, function(v) ASSIST.Magnetic = v end)
addToggle(assistTab, "📈 Adaptive", true, function(v) ASSIST.Adaptive = v end)
addToggle(assistTab, "↕️ Vertical suave", true, function(v) ASSIST.VerticalAssist = v end)
addToggle(assistTab, "🧱 Wall check", true, function(v) ASSIST.WallCheck = v end)
addToggle(assistTab, "👁️ Indicador visual", true, function(v) ASSIST.ShowIndicator = v end)
addDropdown(assistTab, "📈 Curva de força", {"smooth", "linear", "exponential"}, "smooth", function(v)
    ASSIST.Curve = v
end)
addSlider(assistTab, "Força base (%)", 5, 100, 35, function(v) ASSIST.Strength = v/100 end)
addSlider(assistTab, "Trigger radius (px)", 20, 400, 120, function(v) ASSIST.TriggerRadius = v end)
addSlider(assistTab, "Smooth strength", 1, 30, 6, function(v) ASSIST.SmoothStrength = v end)
addSlider(assistTab, "Magnetic boost", 1, 5, 2, function(v) ASSIST.MagneticBoost = v end, 1)
addSlider(assistTab, "Vertical mult", 0.1, 1, 0.65, function(v) ASSIST.VerticalMultiplier = v end, 2)
addSlider(assistTab, "Lock-on boost", 0, 2, 0.6, function(v) ASSIST.LockOn = v end, 2)
addSlider(assistTab, "FOV (graus)", 5, 360, 90, function(v) ASSIST.FOV = v end)
addSlider(assistTab, "Distância máx", 50, 5000, 800, function(v) ASSIST.MaxDistance = v end)
addSlider(assistTab, "Velocidade bala", 50, 3000, 400, function(v) ASSIST.PredictionSpeed = v end)

-- ==========================================================
--  AIM NPC TAB
-- ==========================================================
local npcTab = newTab("Aim NPC", "👹", 3)
addToggle(npcTab, "👹 Ativar Aim NPCs", false, function(v)
    ACONFIG.EnabledNPCs = v; MaybeClearLock()
    notify(v and "ON" or "OFF")
end)
addToggle(npcTab, "🛡️ Team Check", false, function(v)
    ACONFIG.NPCTeamCheck = v; NPC_CACHE_TIME = 0
end)
addToggle(npcTab, "🧟 Só zumbis", false, function(v)
    ACONFIG.OnlyZombies = v; NPC_CACHE_TIME = 0
end)
addButton(npcTab, "🔍 Contar NPCs", true, function()
    NPC_CACHE_TIME = 0
    local npcs = GetAllNPCs()
    local inimigos = 0
    for _, npc in ipairs(npcs) do
        if NPCIsEnemy(npc) then inimigos = inimigos + 1 end
    end
    notify("👹 " .. #npcs .. " NPCs | " .. inimigos .. " inimigos")
end)

-- ==========================================================
--  SPEED TAB
-- ==========================================================
local spdTab = newTab("Speed", "⚡", 4)
addToggle(spdTab, "⚡ Speed", false, function(v)
    ConfigState.SpeedEnabled = v
    local hum = GetHumanoid()
    if hum then
        if v then hum.WalkSpeed = ConfigState.SpeedValue; AttachSpeedTrap()
        else hum.WalkSpeed = 16; if SpeedPropConn then SpeedPropConn:Disconnect() SpeedPropConn = nil end end
    end
end)
addSlider(spdTab, "WalkSpeed", 16, 1000, 16, function(v)
    ConfigState.SpeedValue = v
    if ConfigState.SpeedEnabled then local hum = GetHumanoid(); if hum then hum.WalkSpeed = v end end
end)
addToggle(spdTab, "🦘 Pulo Alto", false, function(v)
    ConfigState.JumpEnabled = v
    local hum = GetHumanoid()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = v and ConfigState.JumpValue or 50
    end
end)
addSlider(spdTab, "Força Pulo", 50, 500, 50, function(v)
    ConfigState.JumpValue = v
    if ConfigState.JumpEnabled then local hum = GetHumanoid(); if hum then hum.UseJumpPower = true; hum.JumpPower = v end end
end)
addToggle(spdTab, "📷 FOV", false, function(v)
    ConfigState.FOVEnabled = v
    if Camera then Camera.FieldOfView = v and ConfigState.FOVValue or 70 end
end)
addSlider(spdTab, "FOV", 40, 120, 70, function(v)
    ConfigState.FOVValue = v
    if ConfigState.FOVEnabled and Camera then Camera.FieldOfView = v end
end)

-- ==========================================================
--  ESP TAB (NOVO visual)
-- ==========================================================
local espTab = newTab("ESP", "👁️", 5)
text(espTab, "ESP Moderno v3.6", 20, THEME.Text, Enum.Font.GothamBold)
addToggle(espTab, "👁️ Ativar ESP", true, function(v)
    ESP_CONFIG.Enabled = v
    if v then ESPRefresh() else ESPClearAll() end
end)

text(espTab, "🎯 ELEMENTOS", 12, THEME.SubText, Enum.Font.GothamBold)
addToggle(espTab, "🦴 Esqueleto", true, function(v) ESP_CONFIG.Skeleton = v end)
addToggle(espTab, "📦 Caixa completa", true, function(v) ESP_CONFIG.Box = v end)
addToggle(espTab, "🎯 Corner brackets", true, function(v) ESP_CONFIG.CornerBox = v end)
addToggle(espTab, "📍 Head dot", true, function(v) ESP_CONFIG.HeadDot = v end)
addToggle(espTab, "📛 Nome", true, function(v) ESP_CONFIG.Name = v end)
addToggle(espTab, "📏 Distância", true, function(v) ESP_CONFIG.Distance = v end)
addToggle(espTab, "❤️ Barra de vida", true, function(v) ESP_CONFIG.Health = v end)
addToggle(espTab, "📡 Tracer", false, function(v) ESP_CONFIG.Tracer = v end)
addToggle(espTab, "🎨 Chams 3D (Highlight)", false, function(v) ESP_CONFIG.Chams = v end)

text(espTab, "🛡️ FILTROS", 12, THEME.SubText, Enum.Font.GothamBold)
addToggle(espTab, "🛡️ Só inimigos", true, function(v)
    ESP_CONFIG.TeamCheck = v; ESPUpdateTeamCheck()
end)
addToggle(espTab, "🧱 Detectar parede (dim)", true, function(v) ESP_CONFIG.WallCheck = v end)

text(espTab, "⚙️ AJUSTES", 12, THEME.SubText, Enum.Font.GothamBold)
addSlider(espTab, "Distância máx", 50, 5000, 1500, function(v) ESP_CONFIG.MaxDistance = v end)
addSlider(espTab, "Fade após (dist)", 100, 2000, 400, function(v) ESP_CONFIG.FadeDistance = v end)
addSlider(espTab, "Tamanho texto", 8, 24, 12, function(v) ESP_CONFIG.TextSize = v end)
addSlider(espTab, "Espessura", 1, 5, 1.5, function(v) ESP_CONFIG.Thickness = v end, 1)
addSlider(espTab, "Corner length (%)", 10, 60, 28, function(v) ESP_CONFIG.CornerLength = v/100 end)

-- Cores ESP
text(espTab, "🎨 COR DO ESP", 12, THEME.SubText, Enum.Font.GothamBold)
local colorCard = card(espTab, 130)
make("UIPadding", { PaddingTop=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10), PaddingBottom=UDim.new(0,10) }, colorCard)
make("UIGridLayout", { CellSize=UDim2.new(1/4,-6,0,44), CellPadding=UDim2.fromOffset(8,8), SortOrder=Enum.SortOrder.LayoutOrder }, colorCard)
local colorStrokes = {}
for i, preset in ipairs(ESP_COLORS) do
    local name, c = preset[1], preset[2]
    local sw = make("Frame", { BackgroundColor3 = c, LayoutOrder = i }, colorCard)
    round(sw, 10)
    local sst = stroke(sw, THEME.White, 3, 1)
    colorStrokes[i] = sst
    local btn = make("TextButton", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = name,
        TextColor3 = Color3.new(1,1,1), TextStrokeTransparency = 0.3,
        TextStrokeColor3 = Color3.new(0,0,0), TextSize = 11,
        Font = Enum.Font.GothamBold, AutoButtonColor = false,
    }, sw)
    btn.Activated:Connect(function()
        ESPApplyColor(c)
        for j, s in ipairs(colorStrokes) do tween(s, { Transparency = (j == i) and 0 or 1 }) end
        notify("Cor: " .. name)
    end)
end
colorStrokes[1].Transparency = 0

-- ==========================================================
--  OUTRAS TABS (Noclip, Voo, Fullbright, TP, AutoClick, Config)
-- ==========================================================
local noclipTab = newTab("Noclip", "🧱", 6)
addToggle(noclipTab, "🧱 Ativar Noclip", false, function(v)
    NoclipEnabled = v
    if v then NoclipStart(); NoclipApplyToChar(player.Character); notify("Noclip ON")
    else NoclipStop(); notify("Noclip OFF") end
end)

local vooTab = newTab("Voo", "🚀", 7)
addToggle(vooTab, "🚀 Ativar Voo", false, function(v)
    if v then StartFly(); notify("Voo ON") else StopFly(); notify("Voo OFF") end
end)
addSlider(vooTab, "Velocidade", 20, 800, 60, function(v) FlySpeed = v end)

local fullTab = newTab("Fullbright", "🔦", 8)
addToggle(fullTab, "🔦 Ativar", false, function(v)
    FullbrightEnabled = v
    if v then FullbrightStart(); notify("ON") else FullbrightStop(); notify("OFF") end
end)

local tpTab = newTab("TP", "📍", 9)
addButton(tpTab, "📍 Salvar Posição", true, function()
    local c = player.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r then return end
    local idx = #TPPoints + 1
    table.insert(TPPoints, {
        name = "Ponto " .. idx .. " (" .. math.floor(r.Position.X) .. ", " .. math.floor(r.Position.Z) .. ")",
        pos = r.Position,
    })
    if _G.RefreshTPList then _G.RefreshTPList() end
end)
local savedHeader = make("TextLabel", {
    Size = UDim2.new(1,0,0,26), BackgroundColor3 = THEME.Off, BackgroundTransparency = 0.4,
    Text = "📍 Pontos salvos: 0", TextColor3 = THEME.SubText,
    Font = Enum.Font.GothamBold, TextSize = 12, LayoutOrder = order(),
}, tpTab)
round(savedHeader, 8)
local savedHolder = makeListHolder(tpTab)
_G.RefreshTPList = function()
    for _, ch in ipairs(savedHolder:GetChildren()) do
        if not ch:IsA("UIListLayout") then ch:Destroy() end
    end
    savedHeader.Text = "📍 Pontos salvos: " .. #TPPoints
    if #TPPoints == 0 then
        local empty = make("TextLabel", {
            Size = UDim2.new(1,0,0,30), BackgroundColor3 = THEME.Off, BackgroundTransparency = 0.6,
            Text = "Nenhum ponto salvo", TextColor3 = THEME.SubText,
            Font = Enum.Font.Gotham, TextSize = 12,
        }, savedHolder)
        round(empty, 8)
    else
        for i, p in ipairs(TPPoints) do
            local row = make("Frame", { Size = UDim2.new(1,0,0,38), BackgroundColor3 = THEME.Card, LayoutOrder = i }, savedHolder)
            round(row, 10); stroke(row, THEME.White, 1, 0.85)
            make("TextLabel", {
                Size = UDim2.new(1,-110,1,0), Position = UDim2.fromOffset(12,0),
                BackgroundTransparency = 1, Text = p.name, TextColor3 = THEME.Text,
                TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium, TextSize = 12,
            }, row)
            local irBtn = make("TextButton", {
                Size = UDim2.fromOffset(50,26), Position = UDim2.new(1,-96,0.5,-13),
                BackgroundColor3 = THEME.Accent, Text = "IR", TextColor3 = THEME.White,
                Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
            }, row)
            round(irBtn, 6)
            irBtn.Activated:Connect(function() TeleportTo(p.pos) end)
            local delBtn = make("TextButton", {
                Size = UDim2.fromOffset(34,26), Position = UDim2.new(1,-40,0.5,-13),
                BackgroundColor3 = THEME.Danger, Text = "X", TextColor3 = THEME.White,
                Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
            }, row)
            round(delBtn, 6)
            delBtn.Activated:Connect(function()
                table.remove(TPPoints, i); _G.RefreshTPList()
            end)
        end
    end
end
_G.RefreshTPList()

local acTab = newTab("Auto Click", "🖱️", 10)
addToggle(acTab, "🖱️ Ativar", false, function(v)
    AutoClick.Enabled = v
    if v then ACShowBubble(true); notify("👆 Bolinha!")
    else ACShowBubble(false); AutoClick.Touching = false
        if AutoClick.Thread then pcall(task.cancel, AutoClick.Thread); AutoClick.Thread = nil end end
end)
addSlider(acTab, "CPS", 1, 500, 30, function(v) AutoClick.CPS = v end)
addButton(acTab, "🔥 300 CPS", true, function() AutoClick.CPS = 300; notify("🔥") end)
addButton(acTab, "⚡ 500 CPS", false, function() AutoClick.CPS = 500; notify("⚡") end)

local cfgTab = newTab("Config", "⚙️", 11)
text(cfgTab, "🎨 COR DA INTERFACE", 12, THEME.SubText, Enum.Font.GothamBold)
local themeCard = card(cfgTab, 132)
make("UIPadding", { PaddingTop=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10), PaddingBottom=UDim.new(0,10) }, themeCard)
make("UIGridLayout", { CellSize=UDim2.new(1/3,-6,0,50), CellPadding=UDim2.fromOffset(8,8), SortOrder=Enum.SortOrder.LayoutOrder }, themeCard)
local themeStrokes = {}
for i, preset in ipairs(PRESETS) do
    local name, c1, c2 = preset[1], preset[2], preset[3]
    local sw = make("Frame", { BackgroundColor3 = c1, LayoutOrder = i }, themeCard)
    round(sw, 12)
    make("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = 30 }, sw)
    local sst = stroke(sw, THEME.White, 2.5, i == 1 and 0 or 1)
    themeStrokes[i] = sst
    local btn = make("TextButton", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
        Text = name, TextColor3 = THEME.White, TextSize = 13,
        Font = Enum.Font.GothamBold, AutoButtonColor = false,
    }, sw)
    btn.Activated:Connect(function()
        applyTheme(c1, c2)
        for j, s in ipairs(themeStrokes) do tween(s, { Transparency = (j == i) and 0 or 1 }) end
    end)
end
addSlider(cfgTab, "Escala (%)", 60, 130, 100, function(v) PanelScaleMult = v/100; updateFit() end)
addSlider(cfgTab, "Transparência (%)", 0, 60, 0, function(v) main.BackgroundTransparency = v/100 end)
addToggle(cfgTab, "✨ Animações", true, function(v) AnimEnabled = v end)
addToggle(cfgTab, "👤 Mostrar perfil", true, function(v) profile.Visible = v end)

selectTab("Aim")

-- ==========================================================
--  BOLINHA DO PAINEL
-- ==========================================================
local bubble = make("Frame", {
    Name = "Bubble", Size = UDim2.fromOffset(BUBBLE, BUBBLE),
    Position = UDim2.fromOffset(16, 180), BackgroundColor3 = THEME.Accent,
    Visible = false, ZIndex = 50,
}, gui)
round(bubble, BUBBLE / 2); accentGradient(bubble, 45)
local bubbleStroke = stroke(bubble, THEME.White, 3, 0.4)
local bubbleScale = make("UIScale", { Scale = 0 }, bubble)
TweenService:Create(bubbleStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.05 }):Play()

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
local savedMouseBehavior, savedMouseIcon

local function unlockMouse()
    pcall(function()
        savedMouseBehavior = UserInputService.MouseBehavior
        savedMouseIcon = UserInputService.MouseIconEnabled
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end)
end
local function lockMouse()
    pcall(function()
        UserInputService.MouseBehavior = savedMouseBehavior or Enum.MouseBehavior.LockCenter
        if savedMouseIcon ~= nil then UserInputService.MouseIconEnabled = savedMouseIcon end
    end)
end

local function showBubble(show)
    if show then
        bubble.Visible = true; bubbleScale.Scale = 0
        tween(bubbleScale, { Scale = 1 }, 0.45, Enum.EasingStyle.Back)
    else
        tween(bubbleScale, { Scale = 0 }, 0.18)
        task.delay(0.2, function() if isOpen then bubble.Visible = false end end)
    end
end
local function openWindow()
    if isOpen or busy then return end
    busy, isOpen = true, true
    showBubble(false)
    root.Visible = true
    anim.Scale = 0.7
    tween(anim, { Scale = 1 }, 0.55, Enum.EasingStyle.Back)
    unlockMouse()
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
        lockMouse()
    end)
end
minBtn.Activated:Connect(minimizeWindow)

local function clampPos(x, y)
    local vp = gui.AbsoluteSize
    return UDim2.fromOffset(
        math.clamp(x, 8, math.max(8, vp.X - BUBBLE - 8)),
        math.clamp(y, 30, math.max(30, vp.Y - BUBBLE - 8)))
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
    local justDragged = false
    hit.InputBegan:Connect(function(input)
        if isPointer(input) then
            pressing = true; moved = false; justDragged = false
            startMouse = input.Position; startPos = bubble.Position
            tween(bubbleScale, { Scale = 0.9 }, 0.1)
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if pressing and isMove(input) then
            local d = input.Position - startMouse
            if not moved and d.Magnitude > 8 then moved = true; justDragged = true end
            if moved then
                bubble.Position = clampPos(startPos.X.Offset + d.X, startPos.Y.Offset + d.Y)
            end
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if not pressing or not isPointer(input) then return end
        pressing = false
        tween(bubbleScale, { Scale = 1 }, 0.25, Enum.EasingStyle.Back)
        if moved then snapToSide(); task.delay(0.1, function() justDragged = false end) end
    end)
    hit.MouseButton1Click:Connect(function()
        if justDragged then justDragged = false; return end
        openWindow()
    end)
end

connect(UserInputService.InputBegan, function(input, processed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode == Enum.KeyCode.J or input.KeyCode == Enum.KeyCode.RightShift then
        if isOpen then minimizeWindow() else openWindow() end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    lockTarget, lockPart, lockKind = nil, nil, nil
    AIM_LAST_SWITCH = 0; AIM_LOCK_START = 0
    ESPClearAll()
    task.wait(1)
    ESPRefresh()
end)

ESPRefresh()
showBubble(true)

print("✅ Painel Pro v3.6 — AIM Turbo + ESP Moderno")