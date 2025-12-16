--[[
    💎 Azure Ultimate Hub v7
    Features: 
    - ✅ Auto Reset: ปิดปุ่มไหน ค่าจะกลับเป็นปกติทันที (เนียนมาก)
    - ✅ Key Bar UI: แถบเลือกปุ่มสกิลแบบแนวนอน (จิ้มเลือกได้เลย)
    - ✅ Turbo Damage & Stability
]]

-- 1. 🛡️ SINGLETON SYSTEM
if getgenv().AzureHubConnection then
    getgenv().AzureHubConnection:Disconnect()
    getgenv().AzureHubConnection = nil
end
getgenv().AzureAutoLoop = false 
task.wait(0.1)

if game:GetService("CoreGui"):FindFirstChild("AzureV7") then
    game:GetService("CoreGui").AzureV7:Destroy()
end

-- 2. ⚡ SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Config
local Config = {
    MagicSize = 40,
    Speed = 0.1,
    SkillKey = "Q", -- ปุ่มเริ่มต้น
    AvailableKeys = {"Q", "E", "R", "F", "Z", "X", "C", "V"}, -- รายชื่อปุ่ม
    Active = {
        Master = true,
        MagicBullet = false,
        Noclip = false,
        AutoClick = false,
        AutoSkill = false,
        TurboMode = false
    }
}

getgenv().AzureAutoLoop = true 

-- 3. 🧠 SYSTEM LOGIC & RESET FUNCTIONS

-- Cache System
local HeadCache = {}
local function AddToCache(char)
    if not char then return end
    task.spawn(function()
        local head = char:WaitForChild("Head", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        if head and hum then HeadCache[char] = {Head = head, Humanoid = hum} end
    end)
end
local function RefreshCache()
    HeadCache = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then AddToCache(p.Character) end
    end
end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(AddToCache) end)
for _, p in ipairs(Players:GetPlayers()) do p.CharacterAdded:Connect(AddToCache) end
RefreshCache()

-- 🧹 Reset Functions (คืนค่าเดิม)
local function ResetHitbox()
    for _, data in pairs(HeadCache) do
        if data.Head then
            data.Head.Size = Vector3.new(2, 1, 1) -- คืนขนาดมาตรฐาน
            data.Head.Transparency = 0 -- คืนค่ามองเห็น
            data.Head.CanCollide = true -- คืนค่าการชน
            data.Head.Material = Enum.Material.Plastic -- คืนพื้นผิว
            data.Head.Color = Color3.fromRGB(255, 255, 255) -- คืนสี (คร่าวๆ)
        end
    end
end

local function ResetNoclip()
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = true end -- คืนค่าให้ชนกำแพงได้
        end
    end
end

-- 4. 🎨 UI SYSTEM
local Theme = {
    Bg = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(0, 255, 128), -- Spring Green (Clean Theme)
    Text = Color3.fromRGB(240, 240, 240),
    Off = Color3.fromRGB(40, 40, 45)
}

local function tween(obj, props)
    TweenService:Create(obj, TweenInfo.new(0.2, Enum.EasingStyle.Quad), props):Play()
end

local Screen = Instance.new("ScreenGui")
Screen.Name = "AzureV7"
Screen.Parent = CoreGui
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 260, 0, 480) -- สูงขึ้นเพื่อรองรับ Key Bar
Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.Active = true; Main.Draggable = true

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Theme.Accent; Stroke.Thickness = 1.5; Stroke.Transparency = 0.3
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Header
local Title = Instance.new("TextLabel", Main)
Title.Text = "AZURE <font color=\"rgb(0,255,128)\">CLEAN</font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 22
Title.TextColor3 = Theme.Text
Title.Size = UDim2.new(1, -40, 0, 45)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local MiniBtn = Instance.new("TextButton", Main)
MiniBtn.Text = "-"
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 24
MiniBtn.TextColor3 = Theme.Text
MiniBtn.BackgroundTransparency = 1
MiniBtn.Size = UDim2.new(0, 40, 0, 45)
MiniBtn.Position = UDim2.new(1, -40, 0, 0)

local Container = Instance.new("Frame", Main)
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 0, 0.1, 0)
Container.Size = UDim2.new(1, 0, 0.9, 0)
Container.ClipsDescendants = true

local isMin = false
MiniBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    if isMin then
        tween(Container, {GroupTransparency = 1})
        tween(Main, {Size = UDim2.new(0, 260, 0, 45)})
        MiniBtn.Text = "+"
    else
        tween(Main, {Size = UDim2.new(0, 260, 0, 480)})
        tween(Container, {GroupTransparency = 0})
        MiniBtn.Text = "-"
    end
end)

-- UI Helpers
local yOffset = 0
local function createToggle(text, flag, resetFunc)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, 0, 0, 42)
    Btn.Position = UDim2.new(0, 0, 0, yOffset)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    yOffset = yOffset + 42

    local Label = Instance.new("TextLabel", Btn)
    Label.Text = text
    Label.Font = Enum.Font.GothamBold
    Label.TextColor3 = Theme.Text
    Label.TextSize = 13
    Label.Position = UDim2.new(0.08, 0, 0, 0)
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Switch = Instance.new("Frame", Btn)
    Switch.Size = UDim2.new(0, 36, 0, 18)
    Switch.Position = UDim2.new(0.78, 0, 0.32, 0)
    Switch.BackgroundColor3 = Theme.Off
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    
    local Dot = Instance.new("Frame", Switch)
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    Btn.MouseButton1Click:Connect(function()
        Config.Active[flag] = not Config.Active[flag]
        local on = Config.Active[flag]
        
        -- Animation
        if on then
            tween(Switch, {BackgroundColor3 = Theme.Accent})
            tween(Dot, {Position = UDim2.new(1, -16, 0.5, -7)})
        else
            tween(Switch, {BackgroundColor3 = Theme.Off})
            tween(Dot, {Position = UDim2.new(0, 2, 0.5, -7)})
            -- 🛑 AUTO RESET LOGIC 🛑
            if resetFunc then resetFunc() end
        end
        
        -- Special Logic for Master Switch
        if flag == "Master" and not on then
            ResetHitbox()
            ResetNoclip()
        end
    end)
end

local function createDivider(text)
    local Label = Instance.new("TextLabel", Container)
    Label.Text = text or ""
    Label.Font = Enum.Font.GothamBold
    Label.TextColor3 = Color3.fromRGB(100, 100, 100)
    Label.TextSize = 11
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, yOffset)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    yOffset = yOffset + 25
end

-- 🔥 New Key Bar Selector (แถบเลือกปุ่ม)
local function createKeyBar()
    local Label = Instance.new("TextLabel", Container)
    Label.Text = "Select Skill Key:"
    Label.Font = Enum.Font.GothamBold
    Label.TextColor3 = Theme.Text
    Label.TextSize = 12
    Label.Position = UDim2.new(0.05, 0, 0, yOffset)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    yOffset = yOffset + 20

    local Scroll = Instance.new("ScrollingFrame", Container)
    Scroll.Size = UDim2.new(0.9, 0, 0, 40)
    Scroll.Position = UDim2.new(0.05, 0, 0, yOffset)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.CanvasSize = UDim2.new(0, #Config.AvailableKeys * 45, 0, 0)
    Scroll.ScrollBarThickness = 2
    
    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 5)

    -- สร้างปุ่มเรียงกัน
    local keyBtns = {}
    for _, key in ipairs(Config.AvailableKeys) do
        local Btn = Instance.new("TextButton", Scroll)
        Btn.Size = UDim2.new(0, 40, 0, 35)
        Btn.BackgroundColor3 = (key == Config.SkillKey) and Theme.Accent or Theme.Off
        Btn.Text = key
        Btn.TextColor3 = (key == Config.SkillKey) and Color3.new(0,0,0) or Theme.Text
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 14
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

        Btn.MouseButton1Click:Connect(function()
            Config.SkillKey = key
            -- Update Visuals
            for _, b in pairs(keyBtns) do
                if b.Text == key then
                    tween(b, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.new(0,0,0)})
                else
                    tween(b, {BackgroundColor3 = Theme.Off, TextColor3 = Theme.Text})
                end
            end
        end)
        table.insert(keyBtns, Btn)
    end
    yOffset = yOffset + 45
end

-- Create UI Components
createToggle("Master Switch", "Master")

createDivider("--- Visuals ---")
createToggle("Magic Hitbox", "MagicBullet", ResetHitbox) -- ส่งฟังก์ชัน Reset เข้าไป
createToggle("Noclip (Wall Walk)", "Noclip", ResetNoclip) -- ส่งฟังก์ชัน Reset เข้าไป

createDivider("--- Combat ---")
createToggle("⚡ TURBO DAMAGE ⚡", "TurboMode")
createToggle("Auto Attack (Click)", "AutoClick")

createDivider("--- Skill Settings ---")
createKeyBar() -- แถบเลือกปุ่มใหม่!
createToggle("Auto Skill (Active Key)", "AutoSkill")

-- 5. 🚀 LOGIC LOOPS

-- Visual/Physics Loop
getgenv().AzureHubConnection = RunService.RenderStepped:Connect(function()
    if not Config.Active.Master then return end
    local char = LocalPlayer.Character
    if not char then return end

    -- Noclip Logic
    if Config.Active.Noclip then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    -- Magic Hitbox Logic
    if Config.Active.MagicBullet then
        pcall(function()
            for enemyChar, data in pairs(HeadCache) do
                if enemyChar.Parent and data.Head and data.Humanoid.Health > 0 then
                    local h = data.Head
                    if h.Size.X ~= Config.MagicSize then
                        h.Size = Vector3.new(Config.MagicSize, Config.MagicSize, Config.MagicSize)
                        h.Transparency = 0.8
                        h.CanCollide = false
                        h.Color = Theme.Accent
                        h.Material = Enum.Material.Neon
                    end
                else
                    HeadCache[enemyChar] = nil
                end
            end
        end)
    end
end)

-- Input Loop
task.spawn(function()
    while getgenv().AzureAutoLoop do
        local delayTime = Config.Active.TurboMode and 0 or 0.1
        task.wait(delayTime)
        
        if Config.Active.Master then
            if Config.Active.AutoClick then
                pcall(function()
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    if not Config.Active.TurboMode then
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    else
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                end)
            end
            
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
