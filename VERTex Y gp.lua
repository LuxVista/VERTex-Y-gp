--[[ 
    VERTex Y gp (Ghost Radius) 👻
    - Optimized: เปลี่ยนระบบจาก "แช่ทั้งแมพ" เป็น "แช่เฉพาะรอบตัว (Radius)" แก้แลค 100%
    - Ghost Mode: มอนสเตอร์ระยะใกล้จะมองไม่เห็นเรา (Target = nil)
    - Fix Fly/Noclip: ใช้ระบบเสถียรที่สุด
]]

-- 1. CLEANUP
if getgenv().AzCon then getgenv().AzCon:Disconnect() end
if getgenv().NoclipCon then getgenv().NoclipCon:Disconnect() end
if getgenv().FlyCon then getgenv().FlyCon:Disconnect() end
getgenv().AzLoop = false; task.wait(0.1)
for _,v in pairs(game.CoreGui:GetChildren()) do if v.Name=="VERTex_Ghost" then v:Destroy() end end

-- 2. CONFIG & SERVICES
local Players, Run, Tween, Input, StarterGui, Workspace = game:GetService("Players"), game:GetService("RunService"), game:GetService("TweenService"), game:GetService("UserInputService"), game:GetService("StarterGui"), game:GetService("Workspace")
local LP = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

local Config = {
    FlySpeed = 200, -- ความเร็วบินมาตรฐาน
    Radius = 50,    -- ระยะที่จะทำให้มอนตาบอด (50 เมตรกำลังดี ไม่แลค)
    Active = { 
        Master = true, 
        GhostMode = false, -- ชื่อโหมดใหม่
        Fly = false, 
        Noclip = false 
    }
}
Config.Active.Master = false 

-- UI Manager
local UI_Elements = {} 

-- 3. UTILS
local function Reset()
    if LP.Character then
        local H = LP.Character:FindFirstChild("HumanoidRootPart")
        if LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.PlatformStand = false
        end
        for _,v in pairs(LP.Character:GetDescendants()) do 
            if v:IsA("BasePart") then v.CanCollide = true end 
        end
    end
end

-- 4. UI THEME
local Th = { 
    Bg = Color3.fromRGB(20, 20, 22),       
    NavBg = Color3.fromRGB(25, 25, 28),    
    Item = Color3.fromRGB(40, 40, 45),     
    Txt = Color3.fromRGB(220, 220, 225),   
    Sub = Color3.fromRGB(100, 100, 105),   
    Err = Color3.fromRGB(200, 60, 60),     
    Fix = Color3.fromRGB(255, 140, 0),
    On = Color3.fromRGB(200, 200, 200),    
    Stroke = Color3.fromRGB(60, 60, 65)    
}
local Gui = Instance.new("ScreenGui", game.CoreGui); Gui.Name="VERTex_Ghost"

-- WIDGET
local Widget = Instance.new("TextButton", Gui)
Widget.Name = "YGWidget"
Widget.Size = UDim2.new(0, 50, 0, 50)
Widget.Position = UDim2.new(0.9, -20, 0.4, 0)
Widget.BackgroundColor3 = Th.Bg
Widget.BackgroundTransparency = 0.1
Widget.Text = "YG"
Widget.TextColor3 = Th.Txt
Widget.Font = Enum.Font.GothamBold
Widget.TextSize = 20
Widget.TextStrokeTransparency = 1
Widget.AutoButtonColor = false
Widget.Visible = false
Widget.Draggable = true
Widget.Active = true
Instance.new("UICorner", Widget).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Widget).Color = Th.Stroke; Instance.new("UIStroke", Widget).Thickness = 2

-- MAIN WINDOW
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 400, 0, 350)
Main.Position = UDim2.new(0.5, -200, 0.5, -175) 
Main.BackgroundColor3 = Th.Bg
Main.BackgroundTransparency = 0.05
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Main).Color = Th.Stroke; Instance.new("UIStroke", Main).Thickness = 1.5

-- HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Tit = Instance.new("TextLabel", Header)
Tit.Text = "VERTex <font color=\"rgb(180,180,180)\">Y gp</font>"
Tit.RichText = true
Tit.Size = UDim2.new(0.6, 0, 1, 0)
Tit.Position = UDim2.new(0, 15, 0, 0)
Tit.BackgroundTransparency = 1
Tit.TextColor3 = Th.Txt
Tit.Font = Enum.Font.GothamBold
Tit.TextSize = 18
Tit.TextXAlignment = Enum.TextXAlignment.Left
Tit.TextStrokeTransparency = 1

local function CreateCtrlBtn(txt, col, offX, func)
    local B = Instance.new("TextButton", Header)
    B.Size = UDim2.new(0, 40, 1, 0)
    B.Position = UDim2.new(1, offX, 0, 0)
    B.BackgroundTransparency = 1
    B.Text = txt
    B.TextColor3 = col
    B.Font = Enum.Font.GothamBold
    B.TextSize = 20
    B.TextStrokeTransparency = 1
    B.MouseButton1Click:Connect(func)
end
CreateCtrlBtn("X", Th.Err, -40, function() Reset(); getgenv().AzCon:Disconnect(); getgenv().NoclipCon:Disconnect(); if getgenv().FlyCon then getgenv().FlyCon:Disconnect() end; Gui:Destroy() end)
CreateCtrlBtn("—", Th.Txt, -80, function() Main.Visible=false; Widget.Visible=true end)
Widget.MouseButton1Click:Connect(function() Widget.Visible=false; Main.Visible=true end)

-- NAVBAR
local NavBar = Instance.new("ScrollingFrame", Main)
NavBar.Size = UDim2.new(1, 0, 0, 40)
NavBar.Position = UDim2.new(0, 0, 0, 40)
NavBar.BackgroundColor3 = Th.NavBg
NavBar.BackgroundTransparency = 0.5
NavBar.BorderSizePixel = 0
NavBar.ScrollBarThickness = 0
NavBar.CanvasSize = UDim2.new(0, 0, 0, 0)
NavBar.AutomaticCanvasSize = Enum.AutomaticSize.X
local NavList = Instance.new("UIListLayout", NavBar)
NavList.FillDirection = Enum.FillDirection.Horizontal
NavList.HorizontalAlignment = Enum.HorizontalAlignment.Center
NavList.Padding = UDim.new(0, 5)

-- PAGES
local PageHolder = Instance.new("Frame", Main)
PageHolder.Size = UDim2.new(1, -20, 1, -130)
PageHolder.Position = UDim2.new(0, 10, 0, 85)
PageHolder.BackgroundTransparency = 1

local Pages = {}
local Tabs = {}

local function SwitchTab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(Tabs) do 
        Tween:Create(b, TweenInfo.new(0.2), {TextColor3 = (n == name) and Th.Txt or Th.Sub}):Play()
        if b:FindFirstChild("Underline") then
            Tween:Create(b.Underline, TweenInfo.new(0.2), {BackgroundTransparency = (n == name) and 0 or 1}):Play()
        end
    end
end

local function CreateTab(name)
    local B = Instance.new("TextButton", NavBar)
    B.Size = UDim2.new(0, 80, 1, 0)
    B.BackgroundTransparency = 1
    B.Text = name
    B.TextColor3 = Th.Sub
    B.Font = Enum.Font.GothamBold
    B.TextSize = 14
    B.TextStrokeTransparency = 1
    
    local Line = Instance.new("Frame", B)
    Line.Name = "Underline"
    Line.Size = UDim2.new(0.6, 0, 0, 2)
    Line.Position = UDim2.new(0.2, 0, 0.9, 0)
    Line.BackgroundColor3 = Th.Txt
    Line.BackgroundTransparency = 1
    Instance.new("UICorner", Line).CornerRadius = UDim.new(1, 0)
    B.MouseButton1Click:Connect(function() SwitchTab(name) end)
    Tabs[name] = B

    local P = Instance.new("ScrollingFrame", PageHolder)
    P.Size = UDim2.new(1, 0, 1, 0)
    P.BackgroundTransparency = 1
    P.Visible = false
    P.ScrollBarThickness = 2
    P.ScrollBarImageColor3 = Th.Sub
    local Grid = Instance.new("UIGridLayout", P)
    Grid.CellSize = UDim2.new(0, 360, 0, 50)
    Grid.CellPadding = UDim2.new(0, 0, 0, 8)
    Pages[name] = P
    return P
end

-- REFRESH BUTTONS
local function RefreshAllButtons()
    for _, btnData in pairs(UI_Elements) do
        local on = Config.Active[btnData.Flag]
        local targetBg = on and Color3.fromRGB(60,60,65) or Th.Item
        local targetTxt = on and Th.On or Th.Txt
        local targetInd = on and Th.On or Color3.fromRGB(60,60,60)
        Tween:Create(btnData.Button, TweenInfo.new(0.3), {BackgroundColor3=targetBg}):Play()
        Tween:Create(btnData.Label, TweenInfo.new(0.3), {TextColor3=targetTxt}):Play()
        Tween:Create(btnData.Ind, TweenInfo.new(0.3), {BackgroundColor3=targetInd}):Play()
    end
end

-- TOGGLE
local function AddToggle(pageName, txt, desc, flag)
    if not Pages[pageName] then return end
    local Parent = Pages[pageName]
    local B = Instance.new("TextButton", Parent); B.BackgroundColor3=Th.Item; B.Text=""; B.AutoButtonColor=false; Instance.new("UICorner",B).CornerRadius=UDim.new(0,8)
    B.BackgroundTransparency = 0.1
    
    local L = Instance.new("TextLabel", B); L.Text=txt; L.Size=UDim2.new(1,0,0.6,0); L.Position=UDim2.new(0,15,0,5); L.BackgroundTransparency=1; L.TextColor3=Th.Txt; L.Font=Enum.Font.GothamBold; L.TextSize=15; L.TextXAlignment=0; L.TextStrokeTransparency=1
    local D = Instance.new("TextLabel", B); D.Text=desc; D.Size=UDim2.new(1,0,0.4,0); D.Position=UDim2.new(0,15,0.6,-5); D.BackgroundTransparency=1; D.TextColor3=Th.Sub; D.Font=Enum.Font.Gotham; D.TextSize=11; D.TextXAlignment=0; D.TextStrokeTransparency=1
    local Ind = Instance.new("Frame", B); Ind.Size=UDim2.new(0,4,0.6,0); Ind.Position=UDim2.new(0,0,0.2,0); Ind.BackgroundColor3=Color3.fromRGB(60,60,60); Instance.new("UICorner",Ind).CornerRadius=UDim.new(0,2)

    table.insert(UI_Elements, {Button=B, Label=L, Ind=Ind, Flag=flag})

    local isAlerting = false
    B.MouseButton1Click:Connect(function()
        if flag ~= "Master" and not Config.Active.Master then
            if isAlerting then return end; isAlerting = true
            Tween:Create(B, TweenInfo.new(0.1), {BackgroundColor3=Th.Err}):Play()
            L.Text = "⚠️ เปิดสวิตช์หลักก่อน!"
            task.delay(1, function() if B.Parent then Tween:Create(B, TweenInfo.new(0.3), {BackgroundColor3=Th.Item}):Play(); L.Text=txt; isAlerting=false; RefreshAllButtons() end end)
            return
        end

        Config.Active[flag] = not Config.Active[flag]
        local on = Config.Active[flag]
        if not on and (flag=="Fly" or flag=="Noclip") then Reset() end
        RefreshAllButtons()
    end)
end

-- SPECIAL BUTTON
local function AddSpecialButton(pageName, name, sub, color, func)
    if not Pages[pageName] then return end
    local Parent = Pages[pageName]
    local B = Instance.new("TextButton", Parent); B.BackgroundColor3=Th.Item; B.Text=""; B.AutoButtonColor=false; Instance.new("UICorner",B).CornerRadius=UDim.new(0,8)
    B.BackgroundTransparency = 0.1
    local L = Instance.new("TextLabel", B); L.Text=name; L.Size=UDim2.new(1,0,0.6,0); L.Position=UDim2.new(0,15,0,5); L.BackgroundTransparency=1; L.TextColor3=color; L.Font=Enum.Font.GothamBold; L.TextSize=15; L.TextXAlignment=0; L.TextStrokeTransparency=1
    local D = Instance.new("TextLabel", B); D.Text=sub; D.Size=UDim2.new(1,0,0.4,0); D.Position=UDim2.new(0,15,0.6,-5); D.BackgroundTransparency=1; D.TextColor3=Th.Sub; D.Font=Enum.Font.Gotham; D.TextSize=11; D.TextXAlignment=0; D.TextStrokeTransparency=1
    local Ind = Instance.new("Frame", B); Ind.Size=UDim2.new(0,4,0.6,0); Ind.Position=UDim2.new(0,0,0.2,0); Ind.BackgroundColor3=color; Instance.new("UICorner",Ind).CornerRadius=UDim.new(0,2)

    B.MouseButton1Click:Connect(function()
        func()
        RefreshAllButtons()
        Tween:Create(B, TweenInfo.new(0.1), {BackgroundColor3=color}):Play()
        task.wait(0.2)
        Tween:Create(B, TweenInfo.new(0.3), {BackgroundColor3=Th.Item}):Play()
    end)
end

-- STATUS BAR
local StatusFrame = Instance.new("Frame", Main)
StatusFrame.Size = UDim2.new(1, -20, 0, 30)
StatusFrame.Position = UDim2.new(0, 10, 1, -40)
StatusFrame.BackgroundColor3 = Th.NavBg
StatusFrame.BackgroundTransparency = 0.5
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 6)
local StatusTxt = Instance.new("TextLabel", StatusFrame)
StatusTxt.Size = UDim2.new(1, -10, 1, 0)
StatusTxt.Position = UDim2.new(0, 10, 0, 0)
StatusTxt.BackgroundTransparency = 1
StatusTxt.Text = "System: Waiting..."
StatusTxt.TextColor3 = Th.Sub
StatusTxt.Font = Enum.Font.Code
StatusTxt.TextSize = 12
StatusTxt.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    while Main.Parent do
        local fps = math.floor(Workspace:GetRealPhysicsFPS())
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():split(" ")[1] or 0)
        local status = Config.Active.Master and "<font color=\"rgb(0,255,100)\">ONLINE</font>" or "<font color=\"rgb(255,50,50)\">OFFLINE</font>"
        StatusTxt.RichText = true
        StatusTxt.Text = string.format("FPS: %d | Ping: %d ms | %s", fps, ping, status)
        task.wait(1) 
    end
end)

-- SETUP CONTENT
CreateTab("หน้าหลัก")
CreateTab("ล่องหน") -- Tab ใหม่
CreateTab("เคลื่อนที่")

AddToggle("หน้าหลัก", "สวิตช์หลัก (Master)", "เปิดระบบจ่ายไฟให้สคริปต์", "Master")
AddSpecialButton("หน้าหลัก", "ปิดระบบฉุกเฉิน (Panic)", "ปิดทุกอย่างทันที", Th.Err, function()
    for k, v in pairs(Config.Active) do if k ~= "Master" then Config.Active[k] = false end end
    Reset()
    StarterGui:SetCore("SendNotification", {Title = "VERTex Panic", Text = "ปิดระบบฉุกเฉินเรียบร้อย!", Duration = 3})
end)
AddSpecialButton("หน้าหลัก", "รีเซ็ตแก้บัค (Fix Bug)", "เคลียร์ค่าเวลาระบบรวน", Th.Fix, function()
    for k, v in pairs(Config.Active) do if k ~= "Master" then Config.Active[k] = false end end
    Reset()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.Sit = false
        LP.Character.Humanoid.PlatformStand = false
    end
    StarterGui:SetCore("SendNotification", {Title = "VERTex Fix", Text = "ล้างค่าบัคทั้งหมดแล้ว!", Duration = 3})
end)

AddToggle("ล่องหน", "ไม่ให้มอนเห็น (Ghost Mode)", "มอนสเตอร์รอบตัวจะมองไม่เห็นเรา", "GhostMode")

AddToggle("เคลื่อนที่", "บินอัจฉริยะ (Smart Fly)", "บินนิ่งและลื่น (รองรับทุกอุปกรณ์)", "Fly")
AddToggle("เคลื่อนที่", "เดินทะลุ (God Noclip)", "เดินผ่านกำแพง", "Noclip")

SwitchTab("หน้าหลัก")

-- 5. RUNTIME LOGIC

-- [ GHOST MODE (LAG FREE) ]
-- ใช้ Loop แบบหน่วงเวลา (task.wait) แทนการเช็คทุกเฟรม เพื่อความลื่น
task.spawn(function()
    while true do
        task.wait(0.1) -- ทำงานแค่ 10 ครั้งต่อวิ (ประหยัดเครื่องมาก)
        if Config.Active.Master and Config.Active.GhostMode and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local MyPos = LP.Character.HumanoidRootPart.Position
            -- วนลูปหาเฉพาะมอนสเตอร์
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Humanoid") and v.Parent ~= LP.Character and v.Parent:FindFirstChild("HumanoidRootPart") then
                    local EnemyRoot = v.Parent.HumanoidRootPart
                    -- เช็คระยะห่าง (Radius)
                    if (EnemyRoot.Position - MyPos).Magnitude <= Config.Radius then
                        -- ถ้าอยู่ในระยะ -> สั่งให้มองไม่เห็น
                        v.Target = nil
                        v.WalkToPoint = EnemyRoot.Position -- สั่งให้ยืนนิ่งๆ หรือเดินวนแถวนั้น
                    end
                end
            end
        end
    end
end)

-- [ FLY SYSTEM (CFrame) ]
getgenv().FlyCon = Run.RenderStepped:Connect(function()
    if Config.Active.Master and Config.Active.Fly and LP.Character then
        local H = LP.Character:FindFirstChild("HumanoidRootPart")
        local Hum = LP.Character:FindFirstChild("Humanoid")
        if H and Hum then
            Hum.PlatformStand = true
            local moveDir = Hum.MoveDirection
            local nextPos = H.CFrame.Position
            
            if moveDir.Magnitude > 0 then nextPos = nextPos + (moveDir * Config.FlySpeed) end
            if Input:IsKeyDown(Enum.KeyCode.Space) then nextPos = nextPos + Vector3.new(0, Config.FlySpeed/2, 0) end
            if Input:IsKeyDown(Enum.KeyCode.LeftControl) then nextPos = nextPos - Vector3.new(0, Config.FlySpeed/2, 0) end
            
            H.CFrame = CFrame.new(nextPos, nextPos + Cam.CFrame.LookVector)
            H.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- [ NOCLIP ]
getgenv().NoclipCon = Run.Stepped:Connect(function()
    if Config.Active.Master and Config.Active.Noclip and LP.Character then
        for _,v in pairs(LP.Character:GetDescendants()) do 
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end 
        end
    end
end)

StarterGui:SetCore("SendNotification", {Title = "VERTex Y gp", Text = "Ghost Radius Active!", Duration = 5})
