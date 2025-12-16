--[[
    💎 AZURE ULTIMATE HUB - ELITE EDITION 💎
    -------------------------------------------
    Version: 7.0 (Stable)
    Theme: Midnight Neon
    Developer: Gemini AI
    
    [ FEATURES ]
    > Auto Reset System (Smart Toggle)
    > Key Bar Selector (Touch Friendly)
    > Turbo Damage Mode (Zero Delay)
    > Magic Hitbox (Optimized Cache)
]]

--------------------------------------------------------------------------------
-- 1. 🛡️ SINGLETON & CLEANUP (ระบบป้องกันการรันซ้อน)
--------------------------------------------------------------------------------
if getgenv().AzureHubConnection then
    getgenv().AzureHubConnection:Disconnect()
    getgenv().AzureHubConnection = nil
end
getgenv().AzureAutoLoop = false 
task.wait(0.2) -- รอให้ระบบเก่าปิดสมบูรณ์

if game:GetService("CoreGui"):FindFirstChild("AzureElite") then
    game:GetService("CoreGui").AzureElite:Destroy()
end

--------------------------------------------------------------------------------
-- 2. ⚡ SERVICES & CONFIGURATION
--------------------------------------------------------------------------------
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local VIM           = game:GetService("VirtualInputManager")
local CoreGui       = game:GetService("CoreGui")
local StarterGui    = game:GetService("StarterGui")
local LocalPlayer   = Players.LocalPlayer

-- Global Config Table
local Config = {
    MagicSize    = 35,    -- ขนาดหัว (Hitbox)
    TurboSpeed   = 0,     -- ความเร็ว Turbo (0 = เร็วสุด)
    NormalSpeed  = 0.1,   -- ความเร็วปกติ
    SkillKey     = "Q",   -- ปุ่มสกิลเริ่มต้น
    AvailableKeys = {"Q", "E", "R", "F", "Z", "X", "C", "V", "T", "Y", "G"},
    
    Active = {
        Master      = true,
        MagicBullet = false,
        Noclip      = false,
        TurboMode   = false,
        AutoClick   = false,
        AutoSkill   = false
    }
}

getgenv().AzureAutoLoop = true 

--------------------------------------------------------------------------------
-- 3. 🧠 SYSTEM LOGIC (ระบบสมองกล)
--------------------------------------------------------------------------------

-- [ Cache System ] : จำค่าผู้เล่นเพื่อลดอาการแลค
local HeadCache = {}

local function AddToCache(char)
    if not char then return end
    task.spawn(function()
        local head = char:WaitForChild("Head", 10)
        local hum  = char:WaitForChild("Humanoid", 10)
        if head and hum then 
            HeadCache[char] = {Head = head, Humanoid = hum} 
        end
    end)
end

local function RefreshCache()
    HeadCache = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then 
            AddToCache(p.Character) 
        end
    end
end

-- Hook Events
Players.PlayerAdded:Connect(function(p) 
    p.CharacterAdded:Connect(AddToCache) 
end)

for _, p in ipairs(Players:GetPlayers()) do 
    if p.Character then AddToCache(p.Character) end
    p.CharacterAdded:Connect(AddToCache) 
end
RefreshCache()

-- [ Reset Functions ] : คืนค่าเดิมเมื่อปิดโปร
local function ResetHitbox()
    for _, data in pairs(HeadCache) do
        if data.Head then
            data.Head.Size          = Vector3.new(2, 1, 1) -- ขนาดเดิม
            data.Head.Transparency  = 0
            data.Head.CanCollide    = true
            data.Head.Material      = Enum.Material.Plastic
            data.Head.Color         = Color3.fromRGB(255, 255, 255)
        end
    end
end

local function ResetNoclip()
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end

--------------------------------------------------------------------------------
-- 4. 🎨 UI CONSTRUCTION (สร้างหน้าต่างสวยงาม)
--------------------------------------------------------------------------------
local Theme = {
    Background  = Color3.fromRGB(18, 18, 24),
    Accent      = Color3.fromRGB(0, 255, 213), -- Cyan Neon
    Text        = Color3.fromRGB(255, 255, 255),
    SubText     = Color3.fromRGB(150, 150, 160),
    ButtonOff   = Color3.fromRGB(35, 35, 45),
    ButtonOn    = Color3.fromRGB(0, 255, 213)
}

-- Main Screen
local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "AzureElite"
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 280, 0, 500)
Main.Position = UDim2.new(0.1, 0, 0.25, 0)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true

-- Glow Effect (Shadow)
local Shadow = Instance.new("UIStroke", Main)
Shadow.Color = Theme.Accent
Shadow.Thickness = 1.2
Shadow.Transparency = 0.5

-- Rounded Corners
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Header Area
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "AZURE <font color=\"rgb(0,255,213)\">ELITE</font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.TextColor3 = Theme.Text
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Minimize Button
local MiniBtn = Instance.new("TextButton", Header)
MiniBtn.Text = "-"
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 28
MiniBtn.TextColor3 = Theme.Accent
MiniBtn.BackgroundTransparency = 1
MiniBtn.Size = UDim2.new(0, 50, 1, 0)
MiniBtn.Position = UDim2.new(1, -50, 0, 0)

-- Container (Content Area)
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, 0, 1, -50)
Container.Position = UDim2.new(0, 0, 0, 50)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 2
Container.ScrollBarImageColor3 = Theme.Accent

local UIList = Instance.new("UIListLayout", Container)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

-- Padding for Container
local UIPadding = Instance.new("UIPadding", Container)
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)

-- Minimize Logic
local isMin = false
MiniBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    if isMin then
        Main:TweenSize(UDim2.new(0, 280, 0, 50), "Out", "Quart", 0.3)
        MiniBtn.Text = "+"
        Container.Visible = false
    else
        Main:TweenSize(UDim2.new(0, 280, 0, 500), "Out", "Quart", 0.3)
        MiniBtn.Text = "-"
        Container.Visible = true
    end
end)

-- [ UI HELPER FUNCTIONS ]
local function CreateToggle(text, flag, callback)
    local Frame = Instance.new("Frame", Container)
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Font = Enum.Font.GothamBold
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0.05, 0, 0, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    
    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0, 44, 0, 22)
    ToggleBtn.Position = UDim2.new(0.95, -44, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Theme.ButtonOff
    ToggleBtn.Text = ""
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", ToggleBtn)
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = UDim2.new(0, 2, 0.5, -9)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Config.Active[flag] = not Config.Active[flag]
        local state = Config.Active[flag]
        
        if state then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ButtonOff}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        end
        
        if callback then callback(state) end
        
        -- Master Switch Logic
        if flag == "Master" and not state then
            ResetHitbox()
            ResetNoclip()
        end
    end)
end

local function CreateDivider(text)
    local Div = Instance.new("TextLabel", Container)
    Div.Text = text
    Div.Font = Enum.Font.GothamBold
    Div.TextColor3 = Theme.SubText
    Div.TextSize = 12
    Div.Size = UDim2.new(1, 0, 0, 25)
    Div.BackgroundTransparency = 1
    Div.TextXAlignment = Enum.TextXAlignment.Left
end

local function CreateKeyBar()
    CreateDivider("SELECT SKILL KEY")
    
    local Scroll = Instance.new("ScrollingFrame", Container)
    Scroll.Size = UDim2.new(1, 0, 0, 45)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 0
    Scroll.CanvasSize = UDim2.new(0, #Config.AvailableKeys * 45, 0, 0)
    
    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 5)
    
    local Buttons = {}
    
    for _, key in ipairs(Config.AvailableKeys) do
        local Btn = Instance.new("TextButton", Scroll)
        Btn.Size = UDim2.new(0, 40, 0, 40)
        Btn.BackgroundColor3 = (key == Config.SkillKey) and Theme.Accent or Theme.ButtonOff
        Btn.Text = key
        Btn.TextColor3 = (key == Config.SkillKey) and Color3.new(0,0,0) or Theme.Text
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 14
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        
        Btn.MouseButton1Click:Connect(function()
            Config.SkillKey = key
            for _, b in pairs(Buttons) do
                local isSelected = (b.Text == key)
                TweenService:Create(b, TweenInfo.new(0.2), {
                    BackgroundColor3 = isSelected and Theme.Accent or Theme.ButtonOff,
                    TextColor3 = isSelected and Color3.new(0,0,0) or Theme.Text
                }):Play()
            end
        end)
        table.insert(Buttons, Btn)
    end
end

-- [ BUILD MENU ITEMS ]
CreateToggle("Master Switch", "Master")

CreateDivider("VISUALS & PHYSICS")
CreateToggle("Magic Hitbox", "MagicBullet", function(s) if not s then ResetHitbox() end end)
CreateToggle("Noclip / Wall Walk", "Noclip", function(s) if not s then ResetNoclip() end end)

CreateDivider("COMBAT SYSTEMS")
CreateToggle("⚡ TURBO DAMAGE ⚡", "TurboMode")
CreateToggle("Auto Attack (Click)", "AutoClick")

CreateKeyBar() -- แถบเลือกปุ่ม
CreateToggle("Auto Skill (Use Key)", "AutoSkill")

--------------------------------------------------------------------------------
-- 5. 🚀 MAIN EXECUTION LOOPS
--------------------------------------------------------------------------------

-- Loop 1: Visuals & Physics (RenderStepped)
getgenv().AzureHubConnection = RunService.RenderStepped:Connect(function()
    if not Config.Active.Master then return end
    
    local char = LocalPlayer.Character
    if not char then return end

    -- Noclip Logic
    if Config.Active.Noclip then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- Hitbox Logic
    if Config.Active.MagicBullet then
        pcall(function()
            for enemyChar, data in pairs(HeadCache) do
                if enemyChar.Parent and data.Head and data.Humanoid.Health > 0 then
                    local h = data.Head
                    if h.Size.X ~= Config.MagicSize then
                        h.Size          = Vector3.new(Config.MagicSize, Config.MagicSize, Config.MagicSize)
                        h.Transparency  = 0.75
                        h.CanCollide    = false
                        h.Color         = Theme.Accent
                        h.Material      = Enum.Material.Neon
                    end
                else
                    HeadCache[enemyChar] = nil -- Clean up
                end
            end
        end)
    end
end)

-- Loop 2: Inputs (Click & Skill)
task.spawn(function()
    while getgenv().AzureAutoLoop do
        local currentSpeed = Config.Active.TurboMode and Config.TurboSpeed or Config.NormalSpeed
        task.wait(currentSpeed)
        
        if Config.Active.Master then
            -- Auto Click
            if Config.Active.AutoClick then
                pcall(function()
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    if not Config.Active.TurboMode then
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    else
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1) -- Turbo technique
                    end
                end)
            end
            
            -- Auto Skill
            if Config.Active.AutoSkill then
                pcall(function()
                    local k = Enum.KeyCode[Config.SkillKey]
                    VIM:SendKeyEvent(true, k, false, game)
                    VIM:SendKeyEvent(false, k, false, game)
                end)
            end
        end
    end
end)

-- [ NOTIFICATION ]
StarterGui:SetCore("SendNotification", {
    Title = "Azure Elite";
    Text = "Script Loaded Successfully!";
    Icon = "rbxassetid://12832598380"; -- Shield Icon
    Duration = 5;
})


