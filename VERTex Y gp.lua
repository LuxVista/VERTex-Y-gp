--[[ 
    VERTex Y gp (Ultimate Fixed) 🔧
    - SYSTEM REWRITE: เขียนระบบหยุดการทำงาน (Kill Switch) ใหม่หมด
    - FIX CLOSE BUTTON: กด X แล้วสคริปต์หยุดจริง 100% ไม่กินเครื่อง
    - FIX BUGS: ใส่กัน Error ทุกจุด (Anti-Crash)
]]

-- 1. KILL OLD PROCESS (ล้างค่าเก่าให้เกลี้ยงก่อนรัน)
getgenv().VERTex_Running = false -- สั่งหยุดสคริปต์ตัวเก่า
task.wait(0.2) -- รอให้ตัวเก่าหยุดทำงาน
if getgenv().AzCon then getgenv().AzCon:Disconnect() end
if getgenv().NoclipCon then getgenv().NoclipCon:Disconnect() end
if getgenv().FlyCon then getgenv().FlyCon:Disconnect() end
for _,v in pairs(game.CoreGui:GetChildren()) do if v.Name=="VERTex_UltFixed" then v:Destroy() end end

-- เริ่มต้นระบบใหม่
getgenv().VERTex_Running = true 

-- 2. CONFIG & SERVICES
local Players, Run, Tween, Input, StarterGui, Workspace = game:GetService("Players"), game:GetService("RunService"), game:GetService("TweenService"), game:GetService("UserInputService"), game:GetService("StarterGui"), game:GetService("Workspace")
local LP = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

local Config = {
    FlySpeed = 210,
    SkyHeight = 500,
    Radius = 50,
    OldPos = nil,
    Active = { 
        Master = true, 
        GhostMode = false, 
        SkyGod = false, 
        Fly = false, 
        Noclip = false 
    }
}
Config.Active.Master = false 

local UI_Elements = {} -- เก็บข้อมูลปุ่มเพื่อรีเฟรช

-- 3. SAFETY UTILS (กันบัค)
local function GetChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function GetRoot()
    local C = LP.Character
    return C and C:FindFirstChild("HumanoidRootPart")
end

local function Reset()
    pcall(function() -- ใช้ pcall กัน Error
        local H = GetRoot()
        local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
        
        -- คืนค่าการเคลื่อนไหว
        if Hum then Hum.PlatformStand = false end
        if H then H.Velocity = Vector3.new(0,0,0) end
        
        -- ลบอุปกรณ์ช่วยบิน
        if H and H:FindFirstChild("AzVel") then H.AzVel:Destroy() end
        if H and H:FindFirstChild("AzGyro") then H.AzGyro:Destroy() end
        
        -- ลบพื้น Sky God
        local plat = Workspace:FindFirstChild("AzSkyPlat")
        if plat then plat:Destroy() end
        
        -- วาร์ปกลับจุดเดิม (ถ้ามี)
        if Config.OldPos and H then
            H.CFrame = Config.OldPos
            Config.OldPos = nil
        end
        
        -- คืนค่าการชน (Noclip)
        if LP.Character then
            for _,v in pairs(LP.Character:GetDescendants()) do 
                if v:IsA("BasePart") then v.CanCollide = true end 
            end
        end
    end)
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
local Gui = Instance.new("ScreenGui", game.CoreGui); Gui.Name="VERTex_UltFixed"

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

-- [FIXED CLOSE BUTTON]
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

CreateCtrlBtn("X", Th.Err, -40, function() 
    -- 1. สั่งหยุด Loop ทั้งหมด
    getgenv().VERTex_Running = false 
    -- 2. รีเซ็ตตัวละคร
    Reset()
    -- 3. ตัดการเชื่อมต่อ Event
    if getgenv().AzCon then getgenv().AzCon:Disconnect() end
    if getgenv().NoclipCon then getgenv().NoclipCon:Disconnect() end
    if getgenv().FlyCon then getgenv().FlyCon:Disconnect() end
    -- 4. ลบ GUI
    Gui:Destroy() 
end)

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

local function RefreshAllButtons()
    for _, btnData in pairs(UI_Elements) do
        local on = Config.Active[btnData.Flag]
        local targetBg = on and Color3.fromRGB(60,60,65) or Th.Item
        local targetTxt = on and Th.On or Th.Txt
        local targetInd = on and Th.On or Color3.fromRGB(60,60,60)
        Tween:Create(btnData.Button, TweenInfo.new(0.2), {BackgroundColor3=targetBg}):Play()
        Tween:Create(btnData.Label, TweenInfo.new(0.2), {TextColor3=targetTxt}):Play()
        Tween:Create(btnData.Ind, TweenInfo.new(0.2), {BackgroundColor3=targetInd}):Play()
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

    B.MouseButton1Click:Connect(function()
        if flag ~= "Master" and not Config.Active.Master then
            Tween:Create(B, TweenInfo.new(0.1), {BackgroundColor3=Th.Err}):Play()
            task.delay(0.2, function() if B.Parent then Tween:Create(B, TweenInfo.new(0.3), {BackgroundColor3=Th.Item}):Play(); RefreshAllButtons() end end)
            return
        end

        Config.Active[flag] = not Config.Active[flag]
        local on = Config.Active[flag]

        if flag == "SkyGod" then
            local H = GetRoot()
            if on and H then
                Config.OldPos = H.CFrame
                H.CFrame = H.CFrame * CFrame.new(0, Config.SkyHeight, 0)
                local p = Instance.new("Part", Workspace)
                p.Name = "AzSkyPlat"; p.Anchored = true; p.Size = Vector3.new(50, 1, 50)
                p.Position = H.Position - Vector3.new(0, 3.5, 0)
                p.Transparency = 0; p.Material = Enum.Material.Plastic; p.Color = Color3.fromRGB(80, 80, 80); p.CanCollide = true
            elseif not on then
                local plat = Workspace:FindFirstChild("AzSkyPlat")
                if plat then plat:Destroy() end
                if Config.OldPos and H then H.CFrame = Config.OldPos; Config.OldPos = nil end
            end
        end

        if not on and (flag=="Fly" or flag=="Noclip" or flag=="GhostMode") then Reset() end
        RefreshAllButtons()
    end)
end

-- PANIC / FIX BUTTON
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
StatusTxt.Text = "Status: OK"
StatusTxt.TextColor3 = Th.Sub
StatusTxt.Font = Enum.Font.Code
StatusTxt.TextSize = 12
StatusTxt.TextXAlignment = Enum.TextXAlignment.Left

-- SETUP CONTENT
CreateTab("หน้าหลัก")
CreateTab("ล่องหน")
CreateTab("ป้องกัน") 
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
    StarterGui:SetCore("SendNotification", {Title = "VERTex Fix", Text = "ล้างค่าบัคทั้งหมดแล้ว!", Duration = 3})
end)

AddToggle("ล่องหน", "ไม่ให้มอนเห็น (Ghost Mode)", "มอนระยะใกล้ 50m มองไม่เห็นเรา", "GhostMode")
AddToggle("ป้องกัน", "อมตะบนฟ้า (Sky God)", "วาร์ปขึ้นฟ้า + พื้นสีเทา", "SkyGod")
AddToggle("เคลื่อนที่", "บินอัจฉริยะ (Smart Fly)", "บินลื่นๆ (รองรับมือถือ/PC)", "Fly")
AddToggle("เคลื่อนที่", "เดินทะลุ (God Noclip)", "เดินผ่านกำแพง", "Noclip")

SwitchTab("หน้าหลัก")

-- 5. RUNTIME LOGIC

-- [ UPDATE STATUS BAR ]
task.spawn(function()
    while getgenv().VERTex_Running and Main.Parent do
        local fps = math.floor(Workspace:GetRealPhysicsFPS())
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():split(" ")[1] or 0)
        local status = Config.Active.Master and "<font color=\"rgb(0,255,100)\">ACTIVE</font>" or "<font color=\"rgb(255,50,50)\">OFFLINE</font>"
        StatusTxt.RichText = true
        StatusTxt.Text = string.format("FPS: %d | Ping: %d ms | %s", fps, ping, status)
        task.wait(1)
    end
end)

-- [ GHOST MODE (Safe Loop) ]
task.spawn(function()
    while getgenv().VERTex_Running and Main.Parent do
        task.wait(0.2)
        if Config.Active.Master and Config.Active.GhostMode then
            local H = GetRoot()
            if H then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("Humanoid") and v.Parent ~= LP.Character and v.Parent:FindFirstChild("HumanoidRootPart") then
                        if (v.Parent.HumanoidRootPart.Position - H.Position).Magnitude <= Config.Radius then
                            v.Target = nil
                            v.WalkToPoint = v.Parent.HumanoidRootPart.Position 
                        end
                    end
                end
            end
        end
    end
end)

-- [ FLY SYSTEM (CFrame) ]
getgenv().FlyCon = Run.RenderStepped:Connect(function()
    if not getgenv().VERTex_Running then return end -- Double Check
    if Config.Active.Master and Config.Active.Fly then
        local H = GetRoot()
        local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
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
    if not getgenv().VERTex_Running then return end
    if Config.Active.Master and Config.Active.Noclip and LP.Character then
        for _,v in pairs(LP.Character:GetDescendants()) do 
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end 
        end
    end
end)

StarterGui:SetCore("SendNotification", {Title = "VERTex Y gp", Text = "พร้อมใช้งาน! (Fixed Edition)", Duration = 5})
