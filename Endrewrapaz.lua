-- ==========================================================
--  💀 PAINEL PRO v4 — FOV Studio UI + Aim (mais próximo) + Assist + NPC + ESP + Speed + Noclip + Voo + TP + AutoClick
--  🎨 UI: FOV Studio (nova)
--  🧠 Lógica: tudo igual (AIM sempre o mais próximo)
-- ==========================================================

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Lighting          = game:GetService("Lighting")
local VirtualUser       = game:GetService("VirtualUser")
local CollectionService = game:GetService("CollectionService")

if not game:IsLoaded() then game.Loaded:Wait() end

local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================================
--  🔒 safeParent
-- ==========================================================
local function safeParent(g)
    local ok, ui = pcall(function() return gethui and gethui() end)
    if ok and ui then
        pcall(function() g.Parent = ui end)
        if g.Parent == ui then return end
    end
    local core = game:GetService("CoreGui")
    pcall(function() g.Parent = core end)
    if g.Parent == core then return end
    g.Parent = player:WaitForChild("PlayerGui")
end

local function showError(err)
    warn("[Painel] ERRO: " .. tostring(err))
    pcall(function()
        local g = Instance.new("ScreenGui")
        g.Name = "PainelError"
        g.DisplayOrder = 1000
        g.ResetOnSpawn = false
        safeParent(g)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -40, 0, 180)
        t.Position = UDim2.new(0, 20, 0, 20)
        t.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
        t.TextColor3 = Color3.fromRGB(255, 90, 100)
        t.TextWrapped = true
        t.TextSize = 13
        t.Font = Enum.Font.Code
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextYAlignment = Enum.TextYAlignment.Top
        t.Text = "Painel Pro - ERRO:\n" .. tostring(err)
        t.Parent = g
    end)
end

local ok, err = xpcall(function()

-- ==========================================================
--  🎨 FRAMEWORK UI — FOV STUDIO
-- ==========================================================
local W, H, TOP, SIDE = 500, 380, 44, 140

local Theme = {
    Background = Color3.fromRGB(10, 10, 12),
    Sidebar    = Color3.fromRGB(14, 14, 17),
    Surface    = Color3.fromRGB(20, 20, 25),
    Surface2   = Color3.fromRGB(30, 30, 38),
    Stroke     = Color3.fromRGB(42, 42, 52),
    Text       = Color3.fromRGB(240, 240, 246),
    SubText    = Color3.fromRGB(135, 135, 152),
    Accent     = Color3.fromRGB(124, 92, 255),
    Danger     = Color3.fromRGB(255, 82, 92),
    Success    = Color3.fromRGB(70, 210, 140),
}

local connections = {}
local notificationsEnabled = true

local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, child in ipairs(children or {}) do child.Parent = inst end
    return inst
end

local function corner(r) return create("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function pill() return create("UICorner", { CornerRadius = UDim.new(1, 0) }) end
local function stroke(color, thickness)
    return create("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function tween(inst, time, props, style, dir)
    local t = TweenService:Create(
        inst,
        TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local function label(parent, text, size, color, font, align, pos, sz)
    return create("TextLabel", {
        Text = text,
        Font = font or Enum.Font.GothamMedium,
        TextSize = size or 13,
        TextColor3 = color or Theme.Text,
        TextXAlignment = align or Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = pos or UDim2.new(),
        Size = sz or UDim2.new(1, 0, 1, 0),
        Parent = parent,
    })
end

local gui = create("ScreenGui", {
    Name = "PainelProUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
})
safeParent(gui)

local main = create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0.5, -H / 2),
    Size = UDim2.fromOffset(W, H),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = gui,
}, { corner(14), stroke() })

local uiScale = create("UIScale", { Parent = main })
local function fitScale()
    local vp = gui.AbsoluteSize
    if vp.X > 0 and vp.Y > 0 then
        uiScale.Scale = math.clamp(math.min(vp.X / (W + 40), vp.Y / (H + 40)), 0.5, 1)
    end
end
fitScale()
table.insert(connections, gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitScale))

-- TITLE BAR
local titleBar = create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, TOP),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    Parent = main,
})
create("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Theme.Stroke,
    BorderSizePixel = 0,
    Parent = titleBar,
})

local logo = create("Frame", {
    Position = UDim2.fromOffset(14, 11),
    Size = UDim2.fromOffset(22, 22),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Parent = titleBar,
}, { corner(7) })
label(logo, "💀", 13, Theme.Text, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
label(titleBar, "Painel Pro", 14, Theme.Text, Enum.Font.GothamBold, nil,
    UDim2.fromOffset(46, 6), UDim2.new(1, -150, 0, 18))
label(titleBar, "Aim • ESP • Voo • Speed", 11, Theme.SubText, Enum.Font.Gotham, nil,
    UDim2.fromOffset(46, 23), UDim2.new(1, -150, 0, 14))

local function titleButton(text, xOffset, hoverColor)
    local btn = create("TextButton", {
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.SubText,
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Surface2,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, xOffset, 0.5, 0),
        Size = UDim2.fromOffset(30, 30),
        Parent = titleBar,
    }, { corner(8) })
    btn.MouseEnter:Connect(function()
        tween(btn, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = hoverColor, TextColor3 = Theme.Text })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.15, { BackgroundTransparency = 1, TextColor3 = Theme.SubText })
    end)
    return btn
end

local closeBtn = titleButton("X", -10, Theme.Danger)
local minBtn   = titleButton("-", -46, Theme.Surface2)

-- BODY
local body = create("Frame", {
    Name = "Body",
    Position = UDim2.fromOffset(0, TOP),
    Size = UDim2.fromOffset(W, H - TOP),
    BackgroundTransparency = 1,
    Parent = main,
})

local sidebar = create("Frame", {
    Size = UDim2.fromOffset(SIDE, H - TOP),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0,
    Parent = body,
})
create("Frame", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    Size = UDim2.new(0, 1, 1, 0),
    BackgroundColor3 = Theme.Stroke,
    BorderSizePixel = 0,
    Parent = sidebar,
})

local indicator = create("Frame", {
    Position = UDim2.fromOffset(0, 20),
    Size = UDim2.fromOffset(3, 18),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Parent = sidebar,
}, { pill() })

label(sidebar, "2026", 10, Theme.SubText, Enum.Font.Gotham, Enum.TextXAlignment.Center,
    UDim2.new(0, 0, 1, -24), UDim2.new(1, 0, 0, 16))

local pagesHolder = create("Frame", {
    Position = UDim2.fromOffset(SIDE, 0),
    Size = UDim2.fromOffset(W - SIDE, H - TOP),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Parent = body,
})

local pages, tabButtons = {}, {}
local currentTab = nil

local function selectTab(name)
    if currentTab == name then return end
    for n, p in pairs(pages) do
        if n ~= name then p.Visible = false end
    end
    local page = pages[name]
    page.Position = UDim2.fromOffset(22, 0)
    page.Visible = true
    tween(page, 0.4, { Position = UDim2.fromOffset(0, 0) })
    for n, b in pairs(tabButtons) do
        local active = n == name
        tween(b.button, 0.2, {
            TextColor3 = active and Theme.Text or Theme.SubText,
            BackgroundTransparency = active and 0 or 1,
        })
    end
    tween(indicator, 0.3, { Position = UDim2.fromOffset(0, tabButtons[name].y + 8) }, Enum.EasingStyle.Back)
    currentTab = name
end

local function addTab(name, index)
    local y = 12 + (index - 1) * 36
    local btn = create("TextButton", {
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Surface2,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, y),
        Size = UDim2.new(1, -20, 0, 32),
        Parent = sidebar,
    }, { corner(8), create("UIPadding", { PaddingLeft = UDim.new(0, 10) }) })
    tabButtons[name] = { button = btn, y = y }
    btn.MouseEnter:Connect(function()
        if currentTab ~= name then
            tween(btn, 0.15, { BackgroundTransparency = 0.6, TextColor3 = Theme.Text })
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then
            tween(btn, 0.15, { BackgroundTransparency = 1, TextColor3 = Theme.SubText })
        end
    end)
    btn.MouseButton1Click:Connect(function() selectTab(name) end)

    local page = create("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = pagesHolder,
    }, {
        create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
        create("UIPadding", {
            PaddingTop = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 14),
        }),
    })
    pages[name] = page
    return page
end

local order = 0
local function newCard(page, height)
    order = order + 1
    return create("Frame", {
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = page,
    }, { corner(10), stroke() })
end

local function addSection(page, text)
    order = order + 1
    local l = label(page, string.upper(text), 11, Theme.SubText, Enum.Font.GothamBold, nil,
        UDim2.new(), UDim2.new(1, 0, 0, 16))
    l.LayoutOrder = order
end

local function addInfo(page, title, text, height)
    local card = newCard(page, height or 72)
    label(card, title, 14, Theme.Text, Enum.Font.GothamBold, nil,
        UDim2.fromOffset(14, 10), UDim2.new(1, -28, 0, 18))
    local t = label(card, text, 12, Theme.SubText, Enum.Font.Gotham, nil,
        UDim2.fromOffset(14, 32), UDim2.new(1, -28, 1, -40))
    t.TextWrapped = true
    t.TextYAlignment = Enum.TextYAlignment.Top
end

local notify
local function addToggle(page, text, default, callback)
    local card = newCard(page, 42)
    label(card, text, 13, Theme.Text, nil, nil, UDim2.fromOffset(14, 0), UDim2.new(1, -80, 1, 0))
    local switch = create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(44, 24),
        BackgroundColor3 = Theme.Surface2,
        Parent = card,
    }, { pill() })
    local knob = create("Frame", {
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = Theme.SubText,
        BorderSizePixel = 0,
        Parent = switch,
    }, { pill() })
    local state = false
    local function set(v, silent)
        state = v
        tween(switch, 0.25, { BackgroundColor3 = v and Theme.Accent or Theme.Surface2 })
        tween(knob, 0.3, {
            Position = v and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
            BackgroundColor3 = v and Theme.Text or Theme.SubText,
        }, Enum.EasingStyle.Back)
        if callback and not silent then callback(v) end
    end
    switch.MouseButton1Click:Connect(function() set(not state) end)
    set(default or false, true)
    return { set = set, get = function() return state end }
end

local activeDrag, activeScroll = nil, nil
local function addSlider(page, text, minV, maxV, default, callback, suffix)
    local card = newCard(page, 60)
    label(card, text, 13, Theme.Text, nil, nil, UDim2.fromOffset(14, 8), UDim2.new(0.6, 0, 0, 18))
    local valueLabel = label(card, "", 13, Theme.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Right,
        UDim2.new(1, -74, 0, 8), UDim2.fromOffset(60, 18))
    local hit = create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 32),
        Size = UDim2.new(1, -28, 0, 22),
        Parent = card,
    })
    local bar = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Parent = hit,
    }, { pill() })
    local fill = create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = bar,
    }, { pill() })
    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = hit,
    }, { pill(), stroke(Theme.Accent, 2) })
    local value = default
    local function render()
        local rel = (value - minV) / (maxV - minV)
        valueLabel.Text = tostring(value) .. (suffix or "")
        fill.Size = UDim2.fromScale(rel, 1)
        knob.Position = UDim2.fromScale(rel, 0.5)
    end
    local function set(v, silent)
        value = math.clamp(math.floor(v + 0.5), minV, maxV)
        render()
        if callback and not silent then callback(value) end
    end
    local function fromX(x)
        local rel = math.clamp((x - hit.AbsolutePosition.X) / hit.AbsoluteSize.X, 0, 1)
        set(minV + (maxV - minV) * rel)
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            activeDrag = fromX
            activeScroll = page
            page.ScrollingEnabled = false
            fromX(input.Position.X)
        end
    end)
    render()
    return { set = set, get = function() return value end }
end

local function addButton(page, text, callback)
    order = order + 1
    local btn = create("TextButton", {
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Parent = page,
    }, { corner(10), stroke() })
    btn.MouseEnter:Connect(function() tween(btn, 0.15, { BackgroundColor3 = Theme.Accent }) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.2, { BackgroundColor3 = Theme.Surface2 }) end)
    btn.MouseButton1Down:Connect(function() tween(btn, 0.08, { Size = UDim2.new(1, -6, 0, 36) }) end)
    btn.MouseButton1Up:Connect(function() tween(btn, 0.2, { Size = UDim2.new(1, 0, 0, 38) }, Enum.EasingStyle.Back) end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
end

-- TOAST
local toastHolder = create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -16, 1, -16),
    Size = UDim2.new(0, 260, 1, -32),
    BackgroundTransparency = 1,
    Parent = gui,
    ZIndex = 500,
}, {
    create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
    }),
})

function notify(title, text, duration, force)
    if not notificationsEnabled and not force then return end
    duration = duration or 3
    local wrapper = create("Frame", {
        Size = UDim2.fromOffset(260, 58),
        BackgroundTransparency = 1,
        ZIndex = 501,
        Parent = toastHolder,
    })
    local toast = create("Frame", {
        Position = UDim2.fromOffset(290, 0),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 501,
        Parent = wrapper,
    }, { corner(10), stroke() })
    create("Frame", {
        Position = UDim2.fromOffset(0, 10),
        Size = UDim2.fromOffset(3, 38),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = toast,
    }, { pill() })
    label(toast, title, 13, Theme.Text, Enum.Font.GothamBold, nil,
        UDim2.fromOffset(16, 8), UDim2.new(1, -28, 0, 18))
    label(toast, text, 12, Theme.SubText, Enum.Font.Gotham, nil,
        UDim2.fromOffset(16, 28), UDim2.new(1, -28, 0, 20))
    tween(toast, 0.45, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)
    task.delay(duration, function()
        if not toast.Parent then return end
        tween(toast, 0.3, { Position = UDim2.fromOffset(290, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Wait()
        wrapper:Destroy()
    end)
end

-- ==========================================================
--  🧠 LÓGICA — AIM / VOO / ESP / ETC
-- ==========================================================

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

-- CONFIGS
local ACONFIG = {
    EnabledPlayers=false, EnabledNPCs=false,
    MaxDistance=5000, FOV=360, TeamCheck=true,
    Prediction=false, PredictionSpeed=400, Smoothness=0,
    AutoFire=false, AFCooldownMin=0.08, AFCooldownMax=0.15, AFMinDot=0.85,
    WeightDistance=10.0, WeightAngle=0.05,
    SwitchMargin=0, MaxLockTime=999,
    OnlyZombies=false, NPCTeamCheck=false,
}

local ASSIST = {
    Enabled = false, Strength = 0.35, FOV = 90, MaxDistance = 800,
    TeamCheck = true, Prediction = false, PredictionSpeed = 400, SmoothStrength = 6,
}

-- NPC
local NPC_CACHE = {}
local NPC_CACHE_TIME = 0

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

local function NameHasZombieKeyword(nome)
    local lower = string.lower(tostring(nome))
    for _, kw in ipairs(ZOMBIE_KEYWORDS) do
        if string.find(lower, kw, 1, true) then return true end
    end
    return false
end
local function IsInsideZombieFolder(model)
    local p = model.Parent
    local depth = 0
    while p and p ~= workspace and depth < 4 do
        local lower = string.lower(p.Name)
        for _, kw in ipairs(ZOMBIE_FOLDERS) do
            if string.find(lower, kw, 1, true) then return true end
        end
        p = p.Parent
        depth = depth + 1
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
    if not model or not model.Parent then return false end
    if not model:IsA("Model") then return false end
    if IsPlayerCharacter(model) then return false end
    if player.Character == model then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not IsAliveHumanoid(hum) then return false end
    if not ACONFIG.OnlyZombies then return true end
    if NameHasZombieKeyword(model.Name) then return true end
    if IsInsideZombieFolder(model) then return true end
    if model.Parent and NameHasZombieKeyword(model.Parent.Name) then return true end
    if hum.WalkSpeed and hum.WalkSpeed > 0 and hum.WalkSpeed ~= 16 then return true end
    for _, tag in ipairs(CollectionService:GetTags(model)) do
        local lt = string.lower(tag)
        if string.find(lt,"zombie") or string.find(lt,"zumbi") or string.find(lt,"enemy") or string.find(lt,"inimigo") then return true end
    end
    local head  = model:FindFirstChild("Head")
    local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
    if head and torso and hum.Health > 0 and hum.MaxHealth > 0 then
        if not model:FindFirstChild("leaderstats") then return true end
    end
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

-- NPC TEAM
local NPC_TEAM_KEYWORDS = {
    ["red"]="RED",["blue"]="BLUE",["green"]="GREEN",["yellow"]="YELLOW",
    ["team1"]="T1",["team2"]="T2",["team3"]="T3",["team4"]="T4",
    ["ally"]="ALLY",["friendly"]="ALLY",["enemy"]="ENEMY",["hostile"]="ENEMY",
    ["vermelho"]="RED",["azul"]="BLUE",["verde"]="GREEN",["amarelo"]="YELLOW",
    ["aliado"]="ALLY",["inimigo"]="ENEMY",
}

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
        if v ~= nil then
            local key = NameToTeamKey(v)
            if key then return "A:" .. key end
            return "A:" .. tostring(v)
        end
    end
    for _, n in ipairs(TEAM_CHILD_NAMES) do
        local v = npc:FindFirstChild(n)
        if v and (v:IsA("StringValue") or v:IsA("IntValue") or v:IsA("NumberValue")) then
            local key = NameToTeamKey(v.Value)
            if key then return "C:" .. key end
            return "C:" .. tostring(v.Value)
        end
    end
    local nameKey = NameToTeamKey(npc.Name)
    if nameKey then return "N:" .. nameKey end
    return nil
end

local function NPCIsEnemy(npc)
    if not ACONFIG.NPCTeamCheck then return true end
    local npcKey = GetNPCTeamKey(npc)
    local myKey  = GetTeamKey(player)
    if not npcKey or not myKey then return true end
    local function strip(s) return s:match("^%a+:(.+)$") or s end
    return strip(npcKey) ~= strip(myKey)
end

-- AIM STATE
local AIM_LAST_SWITCH = 0
local AIM_LOCK_START  = 0
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

local assistTarget, assistPart = nil, nil

local function AssistFindTarget()
    local mp, ml = Camera.CFrame.Position, Camera.CFrame.LookVector
    local best, bestPart, bestDist = nil, nil, math.huge
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
                        local to = part.Position - mp
                        local d = to.Magnitude
                        if d <= ASSIST.MaxDistance then
                            local ang = AngleBetween(ml, to)
                            if ang <= ASSIST.FOV then
                                if d < bestDist then
                                    bestDist, best, bestPart = d, plr, part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

local function UpdateLock()
    local myChar = player.Character
    if not myChar then
        lockTarget, lockPart, lockKind = nil, nil, nil
        assistTarget, assistPart = nil, nil
        return
    end
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not IsAliveHumanoid(myHum) then
        lockTarget, lockPart, lockKind = nil, nil, nil
        assistTarget, assistPart = nil, nil
        return
    end

    if ACONFIG.EnabledPlayers or ACONFIG.EnabledNPCs then
        local now = tick()
        local best, bestPart, _, bestDist, bestKind = FindBestTarget()

        if best and bestPart then
            local shouldSwitch = false
            if not lockTarget then
                shouldSwitch = true
            elseif best ~= lockTarget then
                local curDist = GetDistToTarget()
                if not curDist then
                    shouldSwitch = true
                elseif bestDist and (curDist - bestDist) >= (ACONFIG.SwitchMargin or 0) then
                    shouldSwitch = true
                end
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

    if ASSIST.Enabled then
        assistTarget, assistPart = AssistFindTarget()
        if assistTarget and assistPart then
            local mp = Camera.CFrame.Position
            local aimPos = assistPart.Position
            if ASSIST.Prediction then
                local vel = assistPart.AssemblyLinearVelocity
                local dist = (aimPos - mp).Magnitude
                aimPos = aimPos + vel * (dist / math.max(ASSIST.PredictionSpeed, 1))
            end
            local des = CFrame.lookAt(mp, aimPos)
            local strength = math.clamp(ASSIST.Strength, 0, 1)
            local factor = math.clamp(strength * (ASSIST.SmoothStrength / 60), 0, 0.9)
            Camera.CFrame = Camera.CFrame:Lerp(des, factor)
        end
        return
    end

    lockTarget, lockPart, lockKind = nil, nil, nil
    assistTarget, assistPart = nil, nil
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
    assistTarget, assistPart = nil, nil
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
    if FlyEnabled then task.wait(0.5); RemoveFlyParts(); StartFly() end
end)

-- ==========================================================
--  ⚡ SPEED / JUMP / FOV
-- ==========================================================
local ConfigState = {
    SpeedEnabled=false, SpeedValue=16,
    JumpEnabled=false, JumpValue=50,
    FOVEnabled=false, FOVValue=70,
}
local function GetHumanoid()
    local c = player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local SpeedPropConn = nil
local function ApplySpeed()
    local hum = GetHumanoid()
    if hum and ConfigState.SpeedEnabled then hum.WalkSpeed = ConfigState.SpeedValue end
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
    if hum then
        if ConfigState.SpeedEnabled and hum.WalkSpeed ~= ConfigState.SpeedValue then
            hum.WalkSpeed = ConfigState.SpeedValue
        end
        if ConfigState.JumpEnabled then
            if not hum.UseJumpPower then hum.UseJumpPower = true end
            if hum.JumpPower ~= ConfigState.JumpValue then hum.JumpPower = ConfigState.JumpValue end
        end
    end
    if Camera and ConfigState.FOVEnabled and Camera.FieldOfView ~= ConfigState.FOVValue then
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

-- ==========================================================
--  🔦 FULLBRIGHT
-- ==========================================================
local FullbrightEnabled, FullbrightConns, FullbrightBackup = false, {}, nil
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
    for _, ef in ipairs(Lighting:GetChildren()) do
        if ef:IsA("Atmosphere") then ef.Density=0.1; ef.Haze=0; ef.Glare=0
        elseif ef:IsA("ColorCorrectionEffect") then ef.Brightness=0; ef.Contrast=0; ef.Saturation=0; ef.TintColor=Color3.fromRGB(255,255,255)
        elseif ef:IsA("BloomEffect") then ef.Intensity=0
        elseif ef:IsA("BlurEffect") then ef.Size=0 end
    end
end
local function FullbrightStart()
    FullbrightApply()
    for _, c in ipairs(FullbrightConns) do if c and c.Disconnect then pcall(function() c:Disconnect() end) end end
    FullbrightConns = {}
    table.insert(FullbrightConns, Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
        if FullbrightEnabled and (Lighting.ClockTime < 10 or Lighting.ClockTime > 17) then Lighting.ClockTime = 14 end
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
--  👁️ ESP
-- ==========================================================
local ESP_CONFIG = {
    Enabled = true, Skeleton = true, Box = false, Distance = true, Name = true,
    TeamCheck = true, Color = Color3.fromRGB(255, 30, 30),
    MaxDistance = 1500, TextSize = 12, Thickness = 1,
}

local SKELETON_R15 = {
    {"Head", "UpperTorso"},{"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},{"LeftUpperArm", "LeftLowerArm"},{"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},{"RightUpperArm", "RightLowerArm"},{"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},{"LeftUpperLeg", "LeftLowerLeg"},{"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},{"RightUpperLeg", "RightLowerLeg"},{"RightLowerLeg", "RightFoot"},
}
local SKELETON_R6 = {
    {"Head", "Torso"},{"Torso", "Left Arm"},{"Torso", "Right Arm"},
    {"Torso", "Left Leg"},{"Torso", "Right Leg"},
}

local ESP_DRAWS = {}
local ESP_MAX_LINES = 20

local ESPRemoveDraw
ESPRemoveDraw = function(plr)
    local d = ESP_DRAWS[plr]
    if d then
        for _, f in ipairs(d.skeleton) do pcall(function() f:Destroy() end) end
        for _, f in ipairs(d.box) do pcall(function() f:Destroy() end) end
        if d.name then pcall(function() d.name:Destroy() end) end
        if d.dist then pcall(function() d.dist:Destroy() end) end
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
    local draw = { char = char, plr = plr, skeleton = {}, box = {}, name = nil, dist = nil }
    for i = 1, ESP_MAX_LINES do
        draw.skeleton[i] = create("Frame", {
            BackgroundColor3 = ESP_CONFIG.Color,
            BorderSizePixel = 0, Visible = false, ZIndex = 20,
            AnchorPoint = Vector2.new(0.5, 0.5),
        }, gui)
    end
    for i = 1, 4 do
        draw.box[i] = create("Frame", {
            BackgroundColor3 = ESP_CONFIG.Color,
            BorderSizePixel = 0, Visible = false, ZIndex = 19,
            AnchorPoint = Vector2.new(0.5, 0.5),
        }, gui)
    end
    draw.name = create("TextLabel", {
        BackgroundTransparency = 1, TextColor3 = ESP_CONFIG.Color,
        TextStrokeTransparency = 0.3, TextStrokeColor3 = Color3.new(0,0,0),
        Font = Enum.Font.GothamBold, TextSize = ESP_CONFIG.TextSize,
        TextXAlignment = Enum.TextXAlignment.Center, Visible = false,
        ZIndex = 21, Size = UDim2.fromOffset(200, 16),
        AnchorPoint = Vector2.new(0.5, 1),
    }, gui)
    draw.dist = create("TextLabel", {
        BackgroundTransparency = 1, TextColor3 = ESP_CONFIG.Color,
        TextStrokeTransparency = 0.3, TextStrokeColor3 = Color3.new(0,0,0),
        Font = Enum.Font.GothamBold, TextSize = ESP_CONFIG.TextSize,
        TextXAlignment = Enum.TextXAlignment.Center, Visible = false,
        ZIndex = 21, Size = UDim2.fromOffset(200, 16),
        AnchorPoint = Vector2.new(0.5, 0),
    }, gui)
    ESP_DRAWS[plr] = draw
end

local function ESPHideAll(draw)
    for _, f in ipairs(draw.skeleton) do f.Visible = false end
    for _, f in ipairs(draw.box) do f.Visible = false end
    if draw.name then draw.name.Visible = false end
    if draw.dist then draw.dist.Visible = false end
end

local function DrawLine2D(frame, p1, p2, color, thickness)
    local diff = p2 - p1
    local length = diff.Magnitude
    if length < 1 or length > 4000 then
        frame.Visible = false
        return
    end
    local center = (p1 + p2) * 0.5
    local angle = math.deg(math.atan(diff.Y, diff.X))
    frame.Visible = true
    frame.Position = UDim2.fromOffset(center.X, center.Y)
    frame.Size = UDim2.fromOffset(length, thickness or 1)
    frame.Rotation = angle
    frame.BackgroundColor3 = color
end

local function ESPUpdateDraw(draw)
    local plr = draw.plr
    local char = plr.Character
    if not char or char ~= draw.char or not ESPIsEnemy(plr) then
        ESPHideAll(draw); return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then ESPHideAll(draw); return end
    local camPos = Camera.CFrame.Position
    local dist = (hrp.Position - camPos).Magnitude
    if dist > ESP_CONFIG.MaxDistance then ESPHideAll(draw); return end
    local toChar = hrp.Position - camPos
    if toChar.Magnitude > 0.01 and toChar.Unit:Dot(Camera.CFrame.LookVector) < -0.1 then
        ESPHideAll(draw); return
    end

    local color = ESP_CONFIG.Color
    local thickness = ESP_CONFIG.Thickness

    if ESP_CONFIG.Skeleton then
        local bones = char:FindFirstChild("UpperTorso") and SKELETON_R15 or SKELETON_R6
        local lineIdx = 0
        for _, pair in ipairs(bones) do
            local p1 = char:FindFirstChild(pair[1])
            local p2 = char:FindFirstChild(pair[2])
            if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
                local sp1, on1 = W2S(p1.Position)
                local sp2, on2 = W2S(p2.Position)
                if on1 and on2 then
                    lineIdx = lineIdx + 1
                    if draw.skeleton[lineIdx] then
                        DrawLine2D(draw.skeleton[lineIdx], sp1, sp2, color, thickness)
                    end
                end
            end
        end
        for i = lineIdx + 1, #draw.skeleton do
            draw.skeleton[i].Visible = false
        end
    else
        for _, f in ipairs(draw.skeleton) do f.Visible = false end
    end

    if ESP_CONFIG.Box then
        local ok, cf, size = pcall(function() return char:GetBoundingBox() end)
        if ok and cf then
            local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
            local anyOnScreen = false
            for x = -1, 1, 2 do
                for y = -1, 1, 2 do
                    for z = -1, 1, 2 do
                        local wp = cf:PointToWorldSpace(Vector3.new(size.X*x/2, size.Y*y/2, size.Z*z/2))
                        local sp, on = W2S(wp)
                        if on then
                            anyOnScreen = true
                            minX = math.min(minX, sp.X); minY = math.min(minY, sp.Y)
                            maxX = math.max(maxX, sp.X); maxY = math.max(maxY, sp.Y)
                        end
                    end
                end
            end
            if anyOnScreen then
                DrawLine2D(draw.box[1], Vector2.new(minX, minY), Vector2.new(maxX, minY), color, 2)
                DrawLine2D(draw.box[2], Vector2.new(maxX, minY), Vector2.new(maxX, maxY), color, 2)
                DrawLine2D(draw.box[3], Vector2.new(maxX, maxY), Vector2.new(minX, maxY), color, 2)
                DrawLine2D(draw.box[4], Vector2.new(minX, maxY), Vector2.new(minX, minY), color, 2)
            else
                for _, f in ipairs(draw.box) do f.Visible = false end
            end
        else
            for _, f in ipairs(draw.box) do f.Visible = false end
        end
    else
        for _, f in ipairs(draw.box) do f.Visible = false end
    end

    if ESP_CONFIG.Name then
        local head = char:FindFirstChild("Head") or hrp
        local sp, on = W2S(head.Position + Vector3.new(0, 1.2, 0))
        if on then
            draw.name.Visible = true
            draw.name.Text = plr.Name
            draw.name.TextColor3 = color
            draw.name.Position = UDim2.fromOffset(sp.X, sp.Y)
        else
            draw.name.Visible = false
        end
    else
        draw.name.Visible = false
    end

    if ESP_CONFIG.Distance then
        local head = char:FindFirstChild("Head") or hrp
        local sp, on = W2S(head.Position + Vector3.new(0, -0.8, 0))
        if on then
            draw.dist.Visible = true
            draw.dist.Text = "[" .. math.floor(dist) .. "m]"
            draw.dist.TextColor3 = color
            draw.dist.Position = UDim2.fromOffset(sp.X, sp.Y)
        else
            draw.dist.Visible = false
        end
    else
        draw.dist.Visible = false
    end
end

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
    while true do ESPRefresh(); task.wait(0.3) end
end)

local function ESPApplyColor(newColor)
    ESP_CONFIG.Color = newColor
    for _, d in pairs(ESP_DRAWS) do
        for _, f in ipairs(d.skeleton) do f.BackgroundColor3 = newColor end
        for _, f in ipairs(d.box) do f.BackgroundColor3 = newColor end
        if d.name then d.name.TextColor3 = newColor end
        if d.dist then d.dist.TextColor3 = newColor end
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
--  📍 TP
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

-- ==========================================================
--  🖱️ AUTO CLICKER (bolinha)
-- ==========================================================
local AutoClick = { Enabled=false, CPS=30, Thread=nil, Touching=false, BubbleVisible=false }
local AC_BUBBLE = 80

local acBubble = create("Frame", {
    Name = "AutoClickBubble",
    Size = UDim2.fromOffset(AC_BUBBLE, AC_BUBBLE),
    Position = UDim2.fromOffset(200, 300),
    BackgroundColor3 = Color3.fromRGB(239, 68, 68),
    Visible = false, ZIndex = 300,
}, gui)
create("UICorner", { CornerRadius = UDim.new(1, 0) }, acBubble)
create("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(239,68,68), Color3.fromRGB(250,204,21)), Rotation = 45 }, acBubble)
create("UIStroke", { Color = Color3.new(1,1,1), Thickness = 3, Transparency = 0.2 }, acBubble)
local acScale = create("UIScale", { Scale = 0 }, acBubble)
label(acBubble, "👆", 38, Color3.new(1,1,1), Enum.Font.GothamBold, Enum.TextXAlignment.Center,
    UDim2.new(), UDim2.fromScale(1,1))
local acHit = create("TextButton", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = "", ZIndex = 302 }, acBubble)

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
        tween(acScale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
    else
        tween(acScale, 0.2, { Scale = 0 })
        task.delay(0.22, function() if not AutoClick.BubbleVisible then acBubble.Visible = false end end)
        ACStopClickLoop()
    end
end

do
    local dragging, dragStart, startPos, moved = false, nil, nil, false
    acHit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false
            dragStart = input.Position; startPos = acBubble.Position
            if AutoClick.Enabled then
                AutoClick.Touching = true
                ACStartClickLoop()
                tween(acScale, 0.08, { Scale = 0.9 })
            end
        end
    end)
    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            if not moved and d.Magnitude > 8 then
                moved = true
                ACStopClickLoop()
                tween(acScale, 0.15, { Scale = 1 })
            end
            if moved then
                local vp = gui.AbsoluteSize
                acBubble.Position = UDim2.fromOffset(
                    math.clamp(startPos.X.Offset + d.X, 8, vp.X - AC_BUBBLE - 8),
                    math.clamp(startPos.Y.Offset + d.Y, 30, vp.Y - AC_BUBBLE - 8)
                )
            end
        end
    end))
    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = false
        tween(acScale, 0.15, { Scale = 1 })
        ACStopClickLoop()
    end))
end

-- ==========================================================
--  🎨 ABAS E CONTEÚDO
-- ==========================================================
local aimTab = addTab("🎯  Aim", 1)
local assistTab = addTab("✨  Assist", 2)
local npcTab = addTab("👹  NPC", 3)
local spdTab = addTab("⚡  Speed", 4)
local espTab = addTab("👁  ESP", 5)
local noclipTab = addTab("🧱  Noclip", 6)
local vooTab = addTab("🚀  Voo", 7)
local fullTab = addTab("🔦  Fullbright", 8)
local tpTab = addTab("📍  TP", 9)
local acTab = addTab("🖱  Auto Click", 10)
local cfgTab = addTab("⚙  Config", 11)

-- AIM
addSection(aimTab, "Aimbot Players")
addInfo(aimTab, "Aim (mais próximo)", "Trava no inimigo mais perto. Troca sozinho se outro ficar mais perto.", 60)
addToggle(aimTab, "Ativar Aim 100% em Players", false, function(v)
    ACONFIG.EnabledPlayers = v
    MaybeClearLock()
    notify("Aim Players", v and "Ativado" or "Desativado")
end)
addToggle(aimTab, "Team Check", true, function(v) ACONFIG.TeamCheck = v end)
addToggle(aimTab, "Predição", false, function(v) ACONFIG.Prediction = v end)
addToggle(aimTab, "Auto Fire", false, function(v) ACONFIG.AutoFire = v end)
addToggle(aimTab, "Ignorar ângulo (pega atrás)", true, function(v)
    ACONFIG.WeightAngle = v and 0.05 or 1.0
end)
addSection(aimTab, "Ajustes")
addSlider(aimTab, "FOV (graus)", 5, 360, 360, function(v) ACONFIG.FOV = v end)
addSlider(aimTab, "Distância máx", 20, 8000, 5000, function(v) ACONFIG.MaxDistance = v end)
addSlider(aimTab, "Velocidade da bala", 50, 3000, 400, function(v) ACONFIG.PredictionSpeed = v end)
addSlider(aimTab, "Suavidade (0 = colado)", 0, 100, 0, function(v) ACONFIG.Smoothness = v/100 end, "%")
addSlider(aimTab, "Prioridade por distância", 1, 20, 10, function(v) ACONFIG.WeightDistance = v end)
addSlider(aimTab, "Tolerância de troca", 0, 100, 0, function(v) ACONFIG.SwitchMargin = v end, " s")
addButton(aimTab, "🔄 Recontar alvos agora", function()
    lockTarget, lockPart, lockKind = nil, nil, nil
    AIM_LAST_SWITCH = 0
    AIM_LOCK_START = 0
    notify("Aim", "Vai escolher o mais próximo no próximo frame")
end)

-- Assist
addSection(assistTab, "Aim Assist")
addInfo(assistTab, "Aim Assist", "Puxa a mira suavemente pro inimigo.", 60)
addToggle(assistTab, "Ativar Aim Assist", false, function(v)
    ASSIST.Enabled = v
    notify("Assist", v and "Ativado" or "Desativado")
end)
addToggle(assistTab, "Team Check", true, function(v) ASSIST.TeamCheck = v end)
addToggle(assistTab, "Predição", false, function(v) ASSIST.Prediction = v end)
addSlider(assistTab, "Força (%)", 5, 100, 35, function(v) ASSIST.Strength = v/100 end, "%")
addSlider(assistTab, "FOV", 5, 360, 90, function(v) ASSIST.FOV = v end)
addSlider(assistTab, "Distância máx", 50, 5000, 800, function(v) ASSIST.MaxDistance = v end)
addSlider(assistTab, "Reajuste (suavidade)", 1, 30, 6, function(v) ASSIST.SmoothStrength = v end)

-- NPC
addSection(npcTab, "Aimbot NPCs")
addToggle(npcTab, "Ativar Aim 100% em NPCs", false, function(v)
    ACONFIG.EnabledNPCs = v
    MaybeClearLock()
    notify("Aim NPCs", v and "Ativado" or "Desativado")
end)
addToggle(npcTab, "Team Check (ignora aliados)", false, function(v)
    ACONFIG.NPCTeamCheck = v
    NPC_CACHE_TIME = 0
end)
addToggle(npcTab, "Só zumbis / bonecos", false, function(v)
    ACONFIG.OnlyZombies = v
    NPC_CACHE_TIME = 0
end)
addButton(npcTab, "🔍 Contar NPCs", function()
    NPC_CACHE_TIME = 0
    local npcs = GetAllNPCs()
    local inimigos = 0
    for _, npc in ipairs(npcs) do
        if NPCIsEnemy(npc) then inimigos = inimigos + 1 end
    end
    if ACONFIG.NPCTeamCheck then
        notify("NPCs", #npcs .. " NPCs | " .. inimigos .. " inimigos")
    else
        notify("NPCs", #npcs .. " NPCs")
    end
end)

-- Speed
addSection(spdTab, "Speed / Pulo / FOV")
addToggle(spdTab, "Ativar Speed", false, function(v)
    ConfigState.SpeedEnabled = v
    local hum = GetHumanoid()
    if hum then
        if v then hum.WalkSpeed = ConfigState.SpeedValue; AttachSpeedTrap()
        else hum.WalkSpeed = 16; if SpeedPropConn then SpeedPropConn:Disconnect() SpeedPropConn = nil end end
    end
    notify("Speed", v and "Ativado" or "Desativado")
end)
addSlider(spdTab, "Velocidade (WalkSpeed)", 16, 1000, 16, function(v)
    ConfigState.SpeedValue = v
    if ConfigState.SpeedEnabled then local hum = GetHumanoid(); if hum then hum.WalkSpeed = v end end
end)
addToggle(spdTab, "Pulo Alto", false, function(v)
    ConfigState.JumpEnabled = v
    local hum = GetHumanoid()
    if hum then
        if v then hum.UseJumpPower = true; hum.JumpPower = ConfigState.JumpValue
        else hum.UseJumpPower = true; hum.JumpPower = 50 end
    end
end)
addSlider(spdTab, "Força do Pulo", 50, 500, 50, function(v)
    ConfigState.JumpValue = v
    if ConfigState.JumpEnabled then local hum = GetHumanoid(); if hum then hum.UseJumpPower = true; hum.JumpPower = v end end
end)
addToggle(spdTab, "FOV personalizado", false, function(v)
    ConfigState.FOVEnabled = v
    if Camera then
        if v then Camera.FieldOfView = ConfigState.FOVValue
        else Camera.FieldOfView = 70 end
    end
end)
addSlider(spdTab, "FOV da câmera", 40, 120, 70, function(v)
    ConfigState.FOVValue = v
    if ConfigState.FOVEnabled and Camera then Camera.FieldOfView = v end
end)

-- ESP
addSection(espTab, "ESP")
addToggle(espTab, "Ativar ESP", true, function(v)
    ESP_CONFIG.Enabled = v
    if v then ESPRefresh() else ESPClearAll() end
    notify("ESP", v and "Ativado" or "Desativado")
end)
addSection(espTab, "O que mostrar")
addToggle(espTab, "Esqueleto (ossos)", true, function(v) ESP_CONFIG.Skeleton = v end)
addToggle(espTab, "Caixa (box)", false, function(v) ESP_CONFIG.Box = v end)
addToggle(espTab, "Nome", true, function(v) ESP_CONFIG.Name = v end)
addToggle(espTab, "Distância", true, function(v) ESP_CONFIG.Distance = v end)
addToggle(espTab, "Só time inimigo", true, function(v)
    ESP_CONFIG.TeamCheck = v
    ESPUpdateTeamCheck()
end)
addSection(espTab, "Ajustes")
addSlider(espTab, "Distância máx (studs)", 50, 5000, 1500, function(v) ESP_CONFIG.MaxDistance = v end)
addSlider(espTab, "Tamanho do texto", 8, 24, 12, function(v)
    ESP_CONFIG.TextSize = v
    for _, d in pairs(ESP_DRAWS) do
        if d.name then d.name.TextSize = v end
        if d.dist then d.dist.TextSize = v end
    end
end)
addSlider(espTab, "Espessura das linhas", 1, 5, 1, function(v) ESP_CONFIG.Thickness = v end)
addSection(espTab, "Cor do ESP")
addButton(espTab, "🔴 Vermelho", function() ESPApplyColor(Color3.fromRGB(255, 30, 30)); notify("ESP", "Vermelho") end)
addButton(espTab, "🔵 Azul", function() ESPApplyColor(Color3.fromRGB(56, 130, 255)); notify("ESP", "Azul") end)
addButton(espTab, "🟢 Verde", function() ESPApplyColor(Color3.fromRGB(52, 211, 100)); notify("ESP", "Verde") end)
addButton(espTab, "🟡 Amarelo", function() ESPApplyColor(Color3.fromRGB(250, 204, 21)); notify("ESP", "Amarelo") end)
addButton(espTab, "🟣 Roxo", function() ESPApplyColor(Color3.fromRGB(170, 60, 255)); notify("ESP", "Roxo") end)
addButton(espTab, "⚪ Branco", function() ESPApplyColor(Color3.fromRGB(255, 255, 255)); notify("ESP", "Branco") end)

-- Noclip
addSection(noclipTab, "Noclip")
addToggle(noclipTab, "Ativar Noclip", false, function(v)
    NoclipEnabled = v
    if v then NoclipStart(); NoclipApplyToChar(player.Character); notify("Noclip", "Ativado")
    else NoclipStop(); notify("Noclip", "Desativado") end
end)

-- Voo
addSection(vooTab, "Voo")
addToggle(vooTab, "Ativar Voo", false, function(v)
    if v then StartFly(); notify("Voo", "Ativado") else StopFly(); notify("Voo", "Desativado") end
end)
addSlider(vooTab, "Velocidade do Voo", 20, 800, 60, function(v) FlySpeed = v end)

-- Fullbright
addSection(fullTab, "Fullbright")
addToggle(fullTab, "Ativar Fullbright", false, function(v)
    FullbrightEnabled = v
    if v then FullbrightStart(); notify("Fullbright", "Ativado")
    else FullbrightStop(); notify("Fullbright", "Desativado") end
end)

-- TP
addSection(tpTab, "Teleportes")
addButton(tpTab, "📍 Salvar Posição Atual", function()
    local c = player.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r then return end
    local idx = #TPPoints + 1
    table.insert(TPPoints, {
        name = "Ponto " .. idx .. " (" .. math.floor(r.Position.X) .. ", " .. math.floor(r.Position.Z) .. ")",
        pos = r.Position,
    })
    if _G.RefreshTPList then _G.RefreshTPList() end
    notify("TP", "Ponto " .. idx .. " salvo!")
end)
local savedHeader = label(tpTab, "📍 Pontos salvos: 0", 12, Theme.SubText, Enum.Font.GothamBold, nil,
    UDim2.new(), UDim2.new(1, 0, 0, 20))
order = order + 1
savedHeader.LayoutOrder = order
local savedHolder = create("Frame", {
    Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
    LayoutOrder = order + 1, AutomaticSize = Enum.AutomaticSize.Y, Parent = tpTab,
}, { create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })

_G.RefreshTPList = function()
    for _, ch in ipairs(savedHolder:GetChildren()) do
        if not ch:IsA("UIListLayout") then ch:Destroy() end
    end
    savedHeader.Text = "📍 Pontos salvos: " .. #TPPoints
    if #TPPoints == 0 then
        local empty = create("TextLabel", {
            Size = UDim2.new(1,0,0,26), BackgroundColor3 = Theme.Surface2,
            BackgroundTransparency = 0.4, Text = "Nenhum ponto salvo",
            TextColor3 = Theme.SubText, Font = Enum.Font.Gotham, TextSize = 12,
        }, savedHolder)
        empty.Parent = savedHolder
    else
        for i, p in ipairs(TPPoints) do
            local row = create("Frame", { Size = UDim2.new(1,0,0,36), BackgroundColor3 = Theme.Surface, LayoutOrder = i }, savedHolder)
            create("UICorner", { CornerRadius = UDim.new(0, 8) }, row)
            create("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, row)
            label(row, p.name, 12, Theme.Text, Enum.Font.GothamMedium, nil,
                UDim2.fromOffset(12, 0), UDim2.new(1, -100, 1, 0))
            local irBtn = create("TextButton", {
                Size = UDim2.fromOffset(48,26), Position = UDim2.new(1,-90,0.5,-13),
                BackgroundColor3 = Theme.Accent, Text = "IR", TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
            }, row)
            create("UICorner", { CornerRadius = UDim.new(0, 6) }, irBtn)
            irBtn.MouseButton1Click:Connect(function() TeleportTo(p.pos); notify("TP", "Feito!") end)
            local delBtn = create("TextButton", {
                Size = UDim2.fromOffset(32,26), Position = UDim2.new(1,-38,0.5,-13),
                BackgroundColor3 = Theme.Danger, Text = "X", TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
            }, row)
            create("UICorner", { CornerRadius = UDim.new(0, 6) }, delBtn)
            delBtn.MouseButton1Click:Connect(function()
                table.remove(TPPoints, i); _G.RefreshTPList(); notify("TP", "Ponto removido")
            end)
        end
    end
end
_G.RefreshTPList()

-- Auto Click
addSection(acTab, "Auto Clicker")
addInfo(acTab, "Auto Click", "Ativa e usa a bolinha 👆 arrastável pra segurar e clicar.", 60)
addToggle(acTab, "Ativar Auto Click", false, function(v)
    AutoClick.Enabled = v
    if v then ACShowBubble(true); notify("AutoClick", "Bolinha 👆 apareceu")
    else ACShowBubble(false); AutoClick.Touching = false
        if AutoClick.Thread then pcall(task.cancel, AutoClick.Thread); AutoClick.Thread = nil end
        notify("AutoClick", "Desativado")
    end
end)
addSlider(acTab, "CPS", 1, 500, 30, function(v) AutoClick.CPS = v end)
addButton(acTab, "🔥 MODO INSANO (300 CPS)", function() AutoClick.CPS = 300; notify("AutoClick", "CPS = 300") end)
addButton(acTab, "⚡ MODO TURBO (500 CPS)", function() AutoClick.CPS = 500; notify("AutoClick", "CPS = 500") end)

-- Config
addSection(cfgTab, "Painel")
addSlider(cfgTab, "Escala (%)", 60, 130, 100, function(v)
    uiScale.Scale = v/100
end, "%")
addSlider(cfgTab, "Transparência (%)", 0, 60, 0, function(v)
    main.BackgroundTransparency = v/100
end, "%")
addToggle(cfgTab, "Notificações", true, function(v)
    notificationsEnabled = v
    notify("Config", v and "Notificações ON" or "Notificações OFF", 2, true)
end)
addButton(cfgTab, "Testar notificação", function()
    notify("Teste", "Tudo funcionando perfeitamente!")
end)
addButton(cfgTab, "Centralizar janela", function()
    tween(main, 0.5, { Position = UDim2.new(0.5, 0, 0.5, -H / 2) }, Enum.EasingStyle.Back)
end)

-- ==========================================================
--  🖱️ DRAG DA JANELA
-- ==========================================================
local draggingWindow, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    local isMove = input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    if not isMove then return end
    if activeDrag then
        activeDrag(input.Position.X)
    elseif draggingWindow then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end))
table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        activeDrag = nil
        draggingWindow = false
        if activeScroll then
            activeScroll.ScrollingEnabled = true
            activeScroll = nil
        end
    end
end))

-- Min/Max/Close
local FULL_SIZE = UDim2.fromOffset(W, H)
local MINI_SIZE = UDim2.fromOffset(W, TOP)
local minimized, busy = false, false

minBtn.MouseButton1Click:Connect(function()
    if busy then return end
    busy = true
    minimized = not minimized
    if minimized then
        minBtn.Text = "+"
        tween(main, 0.4, { Size = MINI_SIZE }, Enum.EasingStyle.Quint).Completed:Wait()
        body.Visible = false
    else
        minBtn.Text = "-"
        body.Visible = true
        tween(main, 0.5, { Size = FULL_SIZE }, Enum.EasingStyle.Back).Completed:Wait()
    end
    busy = false
end)

closeBtn.MouseButton1Click:Connect(function()
    if busy then return end
    busy = true
    tween(main, 0.35, {
        Size = UDim2.fromOffset(W * 0.9, minimized and TOP or H * 0.9),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Wait()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    gui:Destroy()
end)

selectTab("🎯  Aim")
tween(main, 0.65, { Size = FULL_SIZE }, Enum.EasingStyle.Back)
task.delay(0.7, function()
    notify("Painel Pro", "Interface carregada com sucesso!")
end)

-- Character respawn
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    lockTarget, lockPart, lockKind = nil, nil, nil
    assistTarget, assistPart = nil, nil
    AIM_LAST_SWITCH = 0
    AIM_LOCK_START = 0
    ESPClearAll()
    task.wait(1)
    ESPRefresh()
end)

ESPRefresh()

print("[Painel Pro] interface carregada! Parent:", gui.Parent and gui.Parent.Name)

end, function(e)
    return tostring(e) .. "\n" .. debug.traceback()
end)

if not ok then
    showError(err)
end
