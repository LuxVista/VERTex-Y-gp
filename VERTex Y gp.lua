--[[
    💎 Azure Ultimate Hub v11 (Final Edition)
    -----------------------------------------
    Features:
    > Emergency Stop: Press 'ESC' to stop attacking instantly
    > Smart Underground: Teleport under nearest enemy
    > Aim Lock: Visual Red Indicator + Silent Hit
    > Fly & Noclip: Optimized flight and wall pass
    > Turbo Mode: Zero delay attacks
]]

--------------------------------------------------------------------------------
-- 1. 🛡️ CLEANUP & INIT (ล้างระบบเก่า)
--------------------------------------------------------------------------------
if getgenv().AzureHubConnection then getgenv().AzureHubConnection:Disconnect() end
if getgenv().AzureInputConnection then getgenv().AzureInputConnection:Disconnect() end
getgenv().AzureAutoLoop = false
task.wait(0.2) -- รอให้ระบบเก่าปิดสนิท

if game.CoreGui:FindFirstChild("AzureV11") then
    game.CoreGui.AzureV11:Destroy()
end

--------------------------------------------------------------------------------
-- 2. ⚡ SERVICES & CONFIG (ตั้งค่าระบบ)
--------------------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    UndergroundDepth = -12, -- ความลึกตอนมุดดิน
    TriggerRange = 15,      -- ระยะเริ่มทำงาน
    FlySpeed = 50,
    Active = {
        Master = true,      -- เปิดไว้เสมอ เพื่อให้ระบบพร้อมทำงาน
        Underground = false,
        AimLock = false,
        Fly = false,
        Noclip = false,
        Turbo = false,
        Click = false,
        Skill = false
    }
}
getgenv().AzureAutoLoop = true

--------------------------------------------------------------------------------
-- 3. 🧠 CORE FUNCTIONS (ฟังก์ชันหลัก)
--------------------------------------------------------------------------------

-- หาศัตรูที่ใกล้ที่สุด
local function GetClosestEnemy()
    local closestDist = Config.TriggerRange
    local closestTarget = nil
    
    -- 1. หาผู้เล่นอื่น
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < closestDist then 
                closestDist = dist; closestTarget = p.Character 
            end
        end
    end
    
    -- 2. หา Mobs/NPCs (ถ้าไม่มีผู้เล่นใกล้ๆ)
    if not closestTarget then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= LP.Character then
                if v.Humanoid.Health > 0 then
                    local dist = (LP.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                    if dist < closestDist then 
                        closestDist = dist; closestTarget = v 
                    end
                end
            end
        end
    end
    return closestTarget
end

-- รีเซ็ตค่าเมื่อปิดโปร
local function ResetAll()
    if LP.Character then
        local HRP = LP.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            if HRP:FindFirstChild("AzureFlyVel") then HRP.AzureFlyVel:Destroy() end
            if HRP:FindFirstChild("AzureFlyGyro") then HRP.AzureFlyGyro:Destroy() end
        end
        for _, v in pairs(LP.Character:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end

-- 🚨 EMERGENCY STOP SYSTEM (ESC KEY) 🚨
getgenv().AzureInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Escape then
        -- ถ้ากำลังเปิด Auto Click หรือ Turbo อยู่
        if Config.Active.Click or Config.Active.Turbo then
            Config.Active.Click = false
            Config.Active.Turbo = false
            
            -- แจ้งเตือน
            StarterGui:SetCore("SendNotification", {
                Title = "Azure Safety",
                Text = "STOPPED: Auto Attack disabled via ESC",
                Duration = 3,
                Icon = "rbxassetid://12832598380"
            })
        end
    end
end)

--------------------------------------------------------------------------------
-- 4. 🎨 GUI INTERFACE (หน้าตาเมนู)
--------------------------------------------------------------------------------
local Theme = {
    Bg = Color3.fromRGB(20, 20, 25), 
    Acc = Color3.fromRGB(255, 165, 0), -- Safety Orange
    Txt = Color3.fromRGB(255, 255, 255), 
    Off = Color3.fromRGB(40, 40, 45)
}

local Gui = Instance.new("ScreenGui", game.CoreGui); Gui.Name = "AzureV11"
local Main = Instance.new("Frame", Gui); Main.Size = UDim2.new(0, 260, 0, 500); Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Theme.Bg; Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Theme.Acc; Stroke.Thickness = 1.5; Stroke.Transparency = 0.3

-- Header
local Title = Instance.new("TextLabel", Main); Title.Text = "AZURE <font color=\"rgb(255,165,0)\">FINAL</font>"; Title.RichText = true
Title.Size = UDim2.new(1, -40, 0, 45); Title.BackgroundTransparency = 1; Title.TextColor3 = Theme.Txt
Title.Font = Enum.Font.GothamBlack; Title.TextSize = 22; Title.Position = UDim2.new(0, 10, 0, 0)

-- Container
local Cont = Instance.new("Frame", Main); Cont.Size = UDim2.new(1, 0, 0.9, 0); Cont.Position = UDim2.new(0, 0, 0.1, 0); Cont.BackgroundTransparency = 1
local MinBtn = Instance.new("TextButton", Main); MinBtn.Text = "-"; MinBtn.Size = UDim2.new(0, 40, 0, 45); MinBtn.Position = UDim2.new(1, -40, 0, 0)
MinBtn.BackgroundTransparency = 1; MinBtn.TextColor3 = Theme.Txt; MinBtn.TextSize = 24
local isMin = false
MinBtn.MouseButton1Click:Connect(function() 
    isMin = not isMin
    Main:TweenSize(UDim2.new(0, 260, 0, isMin and 45 or 500), "Out", "Quad", 0.3)
    Cont.Visible = not isMin; MinBtn.Text = isMin and "+" or "-" 
end)

-- Button Generator
local yOff = 0
local function Toggle(txt, flag)
    local B = Instance.new("TextButton", Cont); B.Size = UDim2.new(1, 0, 0, 40); B.Position = UDim2.new(0, 0, 0, yOff); B.BackgroundTransparency = 1; B.Text = ""
    local L = Instance.new("TextLabel", B); L.Text = txt; L.Size = UDim2.new(0.6, 0, 1, 0); L.Position = UDim2.new(0.08, 0, 0, 0)
    L.BackgroundTransparency = 1; L.TextColor3 = Theme.Txt; L.TextXAlignment = Enum.TextXAlignment.Left; L.Font = Enum.Font.GothamBold; L.TextSize = 13
    local S = Instance.new("Frame", B); S.Size = UDim2.new(0, 36, 0, 18); S.Position = UDim2.new(0.78, 0, 0.3, 0); S.BackgroundColor3 = Theme.Off; Instance.new("UICorner", S).CornerRadius = UDim.new(1, 0)
    local D = Instance.new("Frame", S); D.Size = UDim2.new(0, 14, 0, 14); D.Position = UDim2.new(0, 2, 0.5, -7); D.BackgroundColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", D).CornerRadius = UDim.new(1, 0)
    
    -- Sync UI with Config (สำคัญมากสำหรับปุ่ม ESC)
    task.spawn(function()
        while B.Parent do
            local on = Config.Active[flag]
            local targetColor = on and Theme.Acc or Theme.Off
            local targetPos = UDim2.new(on and 1 or 0, on and -16 or 2, 0.5, -7)
            
            if S.BackgroundColor3 ~= targetColor then
                TweenService:Create(S, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                TweenService:Create(D, TweenInfo.new(0.2), {Position = targetPos}):Play()
            end
            task.wait(0.2)
        end
    end)

    B.MouseButton1Click:Connect(function()
        Config.Active[flag] = not Config.Active[flag]
        if not Config.Active[flag] then ResetAll() end
    end)
    yOff = yOff + 40
end

-- Create Menu Items
Toggle("Master Switch", "Master")
Toggle("Underground Farm", "Underground")
Toggle("Aim Lock (Red Target)", "AimLock")
Toggle("Fly Mode", "Fly")
Toggle("Noclip (Walls)", "Noclip")
Toggle("⚡ TURBO ⚡", "Turbo")
Toggle("Auto Attack", "Click")

--------------------------------------------------------------------------------
-- 5. 🚀 LOGIC LOOPS (ระบบทำงานจริง)
--------------------------------------------------------------------------------
getgenv().AzureHubConnection = RunService.RenderStepped:Connect(function()
    if not Config.Active.Master then return end
    local myChar = LP.Character
    if not myChar then return end

    -- [ Underground Farm ]
    if Config.Active.Underground then
        local target = GetClosestEnemy()
        if target and target:FindFirstChild("HumanoidRootPart") then
            local tHRP = target.HumanoidRootPart
            local mHRP = myChar:FindFirstChild("HumanoidRootPart")
            if mHRP then
                -- วาร์ปไปใต้เท้า + หันหน้าขึ้น
                mHRP.CFrame = CFrame.new(tHRP.Position) * CFrame.new(0, Config.UndergroundDepth, 0)
                mHRP.CFrame = CFrame.new(mHRP.Position, tHRP.Position)
                mHRP.Velocity = Vector3.new(0,0,0)
                -- Auto Noclip
                for _, v in pairs(myChar:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end
            end
        end
    
    -- [ Noclip ]
    elseif Config.Active.Noclip then
        for _, v in pairs(myChar:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end

    -- [ Aim Lock ]
    if Config.Active.AimLock then
        local target = GetClosestEnemy() -- ใช้ฟังก์ชันเดียวกันหาเป้า
        if target and target:FindFirstChild("Head") then
            local h = target.Head
            -- ทำ Silent Hitbox (หัวโตล่องหน)
            if h.Size.X < 10 then -- ถ้ายังไม่ขยาย
                h.Size = Vector3.new(15, 15, 15)
                h.Transparency = 1 -- มองไม่เห็น
                h.CanCollide = false
            end
            -- สร้าง Highlight สีแดง ถ้ายังไม่มี
            if not target:FindFirstChild("AzureHighlight") then
                local hl = Instance.new("Highlight", target)
                hl.Name = "AzureHighlight"
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineTransparency = 1
            end
        end
    end
    
    -- [ Fly ]
    if Config.Active.Fly and myChar:FindFirstChild("HumanoidRootPart") then
        local HRP = myChar.HumanoidRootPart
        local Vel = HRP:FindFirstChild("AzureFlyVel") or Instance.new("BodyVelocity", HRP)
        local Gyro = HRP:FindFirstChild("AzureFlyGyro") or Instance.new("BodyGyro", HRP)
        Vel.Name="AzureFlyVel"; Gyro.Name="AzureFlyGyro"
        Vel.MaxForce=Vector3.new(1e9,1e9,1e9); Gyro.MaxTorque=Vector3.new(1e9,1e9,1e9)
        Gyro.P=10000; Gyro.D=100
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move=move+Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move=move-Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move=move-Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move=move+Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move=move+Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move=move-Vector3.new(0,1,0) end
        Vel.Velocity=move*Config.FlySpeed; Gyro.CFrame=Camera.CFrame
    else
        if myChar:FindFirstChild("HumanoidRootPart") then
            local HRP = myChar.HumanoidRootPart
            if HRP:FindFirstChild("AzureFlyVel") then HRP.AzureFlyVel:Destroy() end
            if HRP:FindFirstChild("AzureFlyGyro") then HRP.AzureFlyGyro:Destroy() end
        end
    end
end)

-- [ Auto Clicker ]
task.spawn(function()
    while getgenv().AzureAutoLoop do
        task.wait(Config.Active.Turbo and 0 or 0.1)
        if Config.Active.Master and Config.Active.Click then
            pcall(function() 
                VIM:SendMouseButtonEvent(0,0,0,true,game,1)
                if not Config.Active.Turbo then VIM:SendMouseButtonEvent(0,0,0,false,game,1) end 
                if Config.Active.Turbo then VIM:SendMouseButtonEvent(0,0,0,false,game,1) end
            end)
        end
    end
end)
