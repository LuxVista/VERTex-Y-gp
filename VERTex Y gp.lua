--[[ 💎 Azure Ultimate Hub v7 - PART 1: SYSTEM ]]

-- 1. เคลียร์ระบบเก่า (Singleton)
if getgenv().AzureHubConnection then
    getgenv().AzureHubConnection:Disconnect()
    getgenv().AzureHubConnection = nil
end
getgenv().AzureAutoLoop = false 
task.wait(0.1)

-- 2. ตั้งค่าตัวแปร (Config)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

getgenv().Config = {
    MagicSize = 40,
    SkillKey = "Q",
    AvailableKeys = {"Q", "E", "R", "F", "Z", "X", "C", "V"},
    Active = { Master = true, MagicBullet = false, Noclip = false, TurboMode = false, AutoClick = false, AutoSkill = false }
}
getgenv().AzureAutoLoop = true 

-- 3. ระบบจำค่าหัวศัตรู (Cache System)
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

-- 4. ระบบคืนค่าเดิม (Reset Functions)
getgenv().ResetFuncs = {
    Hitbox = function()
        for _, data in pairs(HeadCache) do
            if data.Head then
                data.Head.Size = Vector3.new(2,1,1); data.Head.Transparency = 0
                data.Head.CanCollide = true; data.Head.Material = Enum.Material.Plastic
            end
        end
    end,
    Noclip = function()
        local c = LocalPlayer.Character
        if c then for _, v in ipairs(c:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = true end end end
    end
}

-- 5. ลูปการทำงานหลัก (Main Loops)
getgenv().AzureHubConnection = RunService.RenderStepped:Connect(function()
    if not Config.Active.Master then return end
    local char = LocalPlayer.Character
    if not char then return end

    if Config.Active.Noclip then
        for _, v in ipairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end

    if Config.Active.MagicBullet then
        pcall(function()
            for enemyChar, data in pairs(HeadCache) do
                if enemyChar.Parent and data.Head and data.Humanoid.Health > 0 then
                    local h = data.Head
                    if h.Size.X ~= Config.MagicSize then
                        h.Size = Vector3.new(Config.MagicSize, Config.MagicSize, Config.MagicSize)
                        h.Transparency = 0.8; h.CanCollide = false
                        h.Color = Color3.fromRGB(0, 255, 128); h.Material = Enum.Material.Neon
                    end
                else HeadCache[enemyChar] = nil end
            end
        end)
    end
end)

task.spawn(function()
    while getgenv().AzureAutoLoop do
        task.wait(Config.Active.TurboMode and 0 or 0.1)
        if Config.Active.Master then
            if Config.Active.AutoClick then
                pcall(function()
                    VIM:SendMouseButtonEvent(0,0,0,true,game,1)
                    if not Config.Active.TurboMode then VIM:SendMouseButtonEvent(0,0,0,false,game,1) end
                    if Config.Active.TurboMode then VIM:SendMouseButtonEvent(0,0,0,false,game,1) end
                end)
            end
            if Config.Active.AutoSkill then
                pcall(function()
                    local k = Enum.KeyCode[Config.SkillKey]
                    VIM:SendKeyEvent(true,k,false,game); VIM:SendKeyEvent(false,k,false,game)
                end)
            end
        end
    end
end)
--[[ 💎 Azure Ultimate Hub v7 - PART 2: UI ]]

local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("AzureV7") then CoreGui.AzureV7:Destroy() end

-- Theme setup
local Theme = { Bg = Color3.fromRGB(20,20,25), Accent = Color3.fromRGB(0,255,128), Text = Color3.fromRGB(240,240,240), Off = Color3.fromRGB(40,40,45) }
local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = "AzureV7"
local Main = Instance.new("Frame", Screen); Main.Size = UDim2.new(0,260,0,480); Main.Position = UDim2.new(0.1,0,0.2,0)
Main.BackgroundColor3 = Theme.Bg; Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,8)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Theme.Accent; Stroke.Transparency = 0.4; Stroke.Thickness = 1.5

-- Header & Minify
local Title = Instance.new("TextLabel", Main); Title.Text = "AZURE <font color=\"rgb(0,255,128)\">CLEAN</font>"; Title.RichText = true
Title.Size = UDim2.new(1,-40,0,45); Title.Position = UDim2.new(0,10,0,0); Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBlack; Title.TextSize = 22; Title.TextColor3 = Theme.Text; Title.TextXAlignment = Enum.TextXAlignment.Left

local MiniBtn = Instance.new("TextButton", Main); MiniBtn.Text = "-"; MiniBtn.Size = UDim2.new(0,40,0,45); MiniBtn.Position = UDim2.new(1,-40,0,0)
MiniBtn.BackgroundTransparency = 1; MiniBtn.TextColor3 = Theme.Text; MiniBtn.TextSize = 24; MiniBtn.Font = Enum.Font.GothamBold

local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1,0,0.9,0); Container.Position = UDim2.new(0,0,0.1,0); Container.BackgroundTransparency = 1
local isMin = false
MiniBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    if isMin then Main:TweenSize(UDim2.new(0,260,0,45),"Out","Quad",0.3); Container.Visible = false; MiniBtn.Text = "+"
    else Main:TweenSize(UDim2.new(0,260,0,480),"Out","Quad",0.3); Container.Visible = true; MiniBtn.Text = "-" end
end)

-- UI Creators
local yOffset = 0
local function AddToggle(text, flag, resetFunc)
    local Btn = Instance.new("TextButton", Container); Btn.Size = UDim2.new(1,0,0,40); Btn.Position = UDim2.new(0,0,0,yOffset); Btn.BackgroundTransparency = 1; Btn.Text = ""
    local Label = Instance.new("TextLabel", Btn); Label.Text = text; Label.Size = UDim2.new(0.6,0,1,0); Label.Position = UDim2.new(0.08,0,0,0); Label.BackgroundTransparency = 1; Label.TextColor3 = Theme.Text; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Font = Enum.Font.GothamBold; Label.TextSize = 13
    local Switch = Instance.new("Frame", Btn); Switch.Size = UDim2.new(0,36,0,18); Switch.Position = UDim2.new(0.78,0,0.3,0); Switch.BackgroundColor3 = Theme.Off; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)
    local Dot = Instance.new("Frame", Switch); Dot.Size = UDim2.new(0,14,0,14); Dot.Position = UDim2.new(0,2,0.5,-7); Dot.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)
    
    Btn.MouseButton1Click:Connect(function()
        Config.Active[flag] = not Config.Active[flag]
        local on = Config.Active[flag]
        if on then game:GetService("TweenService"):Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play(); game:GetService("TweenService"):Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1,-16,0.5,-7)}):Play()
        else game:GetService("TweenService"):Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Off}):Play(); game:GetService("TweenService"):Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0,2,0.5,-7)}):Play()
             if resetFunc then resetFunc() end end
        if flag == "Master" and not on then getgenv().ResetFuncs.Hitbox(); getgenv().ResetFuncs.Noclip() end
    end)
    yOffset = yOffset + 40
end
local function AddDivider(txt) local L = Instance.new("TextLabel", Container); L.Text = txt; L.Size = UDim2.new(1,-20,0,20); L.Position = UDim2.new(0,10,0,yOffset); L.BackgroundTransparency = 1; L.TextColor3 = Color3.fromRGB(100,100,100); L.TextSize = 11; L.TextXAlignment = Enum.TextXAlignment.Left; L.Font = Enum.Font.GothamBold; yOffset = yOffset + 25 end

-- Key Bar Logic
local function AddKeyBar()
    local L = Instance.new("TextLabel", Container); L.Text = "Select Skill Key:"; L.Size = UDim2.new(1,0,0,20); L.Position = UDim2.new(0.05,0,0,yOffset); L.BackgroundTransparency = 1; L.TextColor3 = Theme.Text; L.TextSize = 12; L.TextXAlignment = Enum.TextXAlignment.Left; L.Font = Enum.Font.GothamBold; yOffset = yOffset + 20
    local Scroll = Instance.new("ScrollingFrame", Container); Scroll.Size = UDim2.new(0.9,0,0,40); Scroll.Position = UDim2.new(0.05,0,0,yOffset); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, #Config.AvailableKeys*45, 0, 0); Scroll.ScrollBarThickness = 2
    local UIList = Instance.new("UIListLayout", Scroll); UIList.FillDirection = Enum.FillDirection.Horizontal; UIList.Padding = UDim.new(0,5)
    local btns = {}
    for _, k in ipairs(Config.AvailableKeys) do
        local b = Instance.new("TextButton", Scroll); b.Size = UDim2.new(0,40,0,35); b.BackgroundColor3 = Theme.Off; b.Text = k; b.TextColor3 = Theme.Text; b.Font = Enum.Font.GothamBold; Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        b.MouseButton1Click:Connect(function() Config.SkillKey = k; for _,x in pairs(btns) do x.BackgroundColor3 = (x.Text == k) and Theme.Accent or Theme.Off; x.TextColor3 = (x.Text == k) and Color3.new(0,0,0) or Theme.Text end end)
        table.insert(btns, b)
    end
    yOffset = yOffset + 45
end

-- Create Menu Items
AddToggle("Master Switch", "Master")
AddDivider("--- Visuals ---")
AddToggle("Magic Hitbox", "MagicBullet", getgenv().ResetFuncs.Hitbox)
AddToggle("Noclip (Wall Walk)", "Noclip", getgenv().ResetFuncs.Noclip)
AddDivider("--- Combat ---")
AddToggle("⚡ TURBO DAMAGE ⚡", "TurboMode")
AddToggle("Auto Attack (Click)", "AutoClick")
AddDivider("--- Skill Settings ---")
AddKeyBar()
AddToggle("Auto Skill (Active Key)", "AutoSkill")
