--[[
    💎 Azure Ultimate Hub v6 (Turbo Damage Edition)
    New Feature: 
    - ⚡ Turbo Attack Mode (Sets attack delay to 0 for max DPS)
    - All previous features included (Hitbox, Noclip, Skills)
]]

-- 1. 🛡️ SINGLETON SYSTEM
if getgenv().AzureHubConnection then
    getgenv().AzureHubConnection:Disconnect()
    getgenv().AzureHubConnection = nil
end
getgenv().AzureAutoLoop = false 
task.wait(0.1)

if game:GetService("CoreGui"):FindFirstChild("AzureV6") then
    game:GetService("CoreGui").AzureV6:Destroy()
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
    SkillKey = "Q",
    AvailableKeys = {"Q", "E", "R", "F", "Z", "X", "C", "V", "Y"},
    KeyIndex = 1,
    Active = {
        Master = true,
        MagicBullet = false,
        Noclip = false,
        AutoClick = false,
        AutoSkill = false,
        TurboMode = false -- โหมดเร่งดาเมจ (ตีรัว)
    }
}

getgenv().AzureAutoLoop = true 

-- 3. 🧠 OPTIMIZED CACHE
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

-- 4. 🎨 UI SYSTEM
local Theme = {
    Bg = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(255, 170, 0), -- สีส้มทอง (Legendary/Damage)
    Text = Color3.fromRGB(240, 240, 240),
    Off = Color3.fromRGB(35, 35, 40)
}

local function tween(obj, props)
    TweenService:Create(obj, TweenInfo.new(0.3, Enum.EasingStyle.Circular), props):Play()
end

local Screen = Instance.new("ScreenGui")
Screen.Name = "AzureV6"
Screen.Parent = CoreGui
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 250, 0, 440) -- เพิ่มความสูง
Main.Position = UDim2.new(0.1, 0, 0.25, 0)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.Active = true; Main.Draggable = true

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Theme.Accent; Stroke.Thickness = 1.5; Stroke.Transparency = 0.3
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Header
local Title = Instance.new("TextLabel", Main)
Title.Text = "AZURE <font color=\"rgb(255,170,0)\">TURBO</font>"
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
Container.Position = UDim2.new(0, 0, 0.12, 0)
Container.Size = UDim2.new(1, 0, 0.88, 0)
Container.ClipsDescendants = true

local isMin = false
MiniBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    if isMin then
        tween(Container, {GroupTransparency = 1})
        tween(Main, {Size = UDim2.new(0, 250, 0, 45)})
        MiniBtn.Text = "+"
    else
        tween(Main, {Size = UDim2.new(0, 250, 0, 440)})
        tween(Container, {GroupTransparency = 0})
        MiniBtn.Text = "-"
    end
end)

-- UI Helpers
local yOffset = 0
local function createToggle(text, flag, extraAction)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.Position = UDim2.new(0, 0, 0, yOffset)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    yOffset = yOffset + 45

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
        if on then
            tween(Switch, {BackgroundColor3 = Theme.Accent})
            tween(Dot, {Position = UDim2.new(1, -16, 0.5, -7)})
        else
            tween(Switch, {BackgroundColor3 = Theme.Off})
            tween(Dot, {Position = UDim2.new(0, 2, 0.5, -7)})
        end
        if extraAction then extraAction(on) end
    end)
end

local function createSelector()
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(0.9, 0, 0, 32)
    Btn.Position = UDim2.new(0.05, 0, 0, yOffset + 5)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Btn.Text = "Skill Key: [ " .. Config.SkillKey .. " ]"
    Btn.TextColor3 = Theme.Accent
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    yOffset = yOffset + 42

    Btn.MouseButton1Click:Connect(function()
        Config.KeyIndex = Config.KeyIndex + 1
        if Config.KeyIndex > #Config.AvailableKeys then Config.KeyIndex = 1 end
        Config.SkillKey = Config.AvailableKeys[Config.KeyIndex]
        Btn.Text = "Skill Key: [ " .. Config.SkillKey .. " ]"
        tween(Btn, {BackgroundColor3 = Color3.fromRGB(60,60,65)})
        task.delay(0.1, function() tween(Btn, {BackgroundColor3 = Color3.fromRGB(40,40,45)}) end)
    end)
end

local function createDivider()
    local Line = Instance.new("Frame", Container)
    Line.Size = UDim2.new(0.9, 0, 0, 1)
    Line.Position = UDim2.new(0.05, 0, 0, yOffset + 5)
    Line.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Line.BorderSizePixel = 0
    yOffset = yOffset + 15
end

-- Create UI
createToggle("Master Switch", "Master", function(on) if not on then RefreshCache() end end)
createDivider()
createToggle("Magic Hitbox", "MagicBullet")
createToggle("Noclip (Wall Walk)", "Noclip")
createDivider()
createToggle("⚡ TURBO DAMAGE ⚡", "TurboMode") -- ปุ่มใหม่!
createToggle("Auto Attack (Click)", "AutoClick")
createDivider()
createSelector()
createToggle("Auto Skill (Use Key)", "AutoSkill")

-- 5. 🚀 LOGIC LOOPS

-- Visual/Physics Loop
getgenv().AzureHubConnection = RunService.RenderStepped:Connect(function()
    if not Config.Active.Master then return end
    local char = LocalPlayer.Character
    if not char then return end

    if Config.Active.Noclip then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    if Config.Active.MagicBullet then
        pcall(function()
            for enemyChar, data in pairs(HeadCache) do
                if enemyChar.Parent and data.Head and data.Humanoid.Health > 0 then
                    local h = data.Head
                    if h.Size.X ~= Config.MagicSize then
                        h.Size = Vector3.new(Config.MagicSize, Config.MagicSize, Config.MagicSize)
                        h.Transparency = 0.85
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

-- Input Loop (Turbo Logic)
task.spawn(function()
    while getgenv().AzureAutoLoop do
        -- Logic: ถ้าเปิด Turbo ให้ delay เป็น 0 (เร็วสุด) ถ้าปิดให้เป็น 0.1 (ปกติ)
        local delayTime = Config.Active.TurboMode and 0 or 0.1
        task.wait(delayTime)
        
        if Config.Active.Master then
            if Config.Active.AutoClick then
                pcall(function()
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    if not Config.Active.TurboMode then -- ถ้า Turbo ไม่ต้องรอก็ได้
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    else
                        -- Turbo Mode: ส่งคำสั่งรัวยิบ
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

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Azure Turbo";
    Text = "Turbo Damage Mode Available!";
    Duration = 3;
})

