-- Loadstring script (dán toàn bộ code này vào executor)
-- Mod Menu Anime Theme V24.8 - Có nền nhân vật nữ, thanh trượt, nút bấm, đế chân
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. KHỞI TẠO GIAO DIỆN MENU V24.8
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuCustomTheme_V24_8"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- NÚT O MỞ MENU HÌNH TRÒN
local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 55, 0, 55) 
OpenButton.Position = UDim2.new(0, 15, 0, 70) 
OpenButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
OpenButton.BackgroundTransparency = 0.3
OpenButton.Image = "rbxthumb://type=Asset&id=92781042692285&w=420&h=420"
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

-- KHUNG MENU CHÍNH
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 250) 
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.95
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- HÌNH NỀN MENU (NHÂN VẬT NỮ)
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "MenuBackground"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
BackgroundImage.Image = "rbxthumb://type=Asset&id=134759374241732&w=420&h=420"
BackgroundImage.ScaleType = Enum.ScaleType.Stretch
BackgroundImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
BackgroundImage.ZIndex = 0 
BackgroundImage.Parent = MainFrame

local BGCorner = Instance.new("UICorner")
BGCorner.CornerRadius = UDim.new(0, 12)
BGCorner.Parent = BackgroundImage

-- TIÊU ĐỀ MENU
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Anime Theme Menu V24.8"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2
Title.Parent = MainFrame

-- NÚT ẨN MENU (—)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
MinimizeButton.Position = UDim2.new(1, -40, 0, 0)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 85, 85)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.ZIndex = 2
MinimizeButton.Parent = MainFrame

-- CỘT TRÁI (SLIDERS)
local LeftColumn = Instance.new("Frame", MainFrame)
LeftColumn.Size = UDim2.new(0.45, -10, 1, -45)
LeftColumn.Position = UDim2.new(0, 10, 0, 40)
LeftColumn.BackgroundTransparency = 1
LeftColumn.ZIndex = 2

-- CỘT PHẢI (NÚT BẤM)
local RightColumn = Instance.new("Frame", MainFrame)
RightColumn.Size = UDim2.new(0.38, -10, 1, -45)
RightColumn.Position = UDim2.new(1, -175, 0, 40)
RightColumn.BackgroundTransparency = 1
RightColumn.ZIndex = 2

local RainbowObjects = {} 
local GlobalRainbowColor = Color3.fromRGB(255, 255, 255)

-- BIẾN TRẠNG THÁI
local SpinActive = false
local HitboxEspActive = false   
local KillAuraActive = false     
local AimActive = false
local PlatformActive = false 

local OptimizeLevel = 0 
local currentSpeed = 16
local currentJump = 50
local AimDistance = 150

if setfpscap then setfpscap(999) end

-- =====================================================================
-- TẤM ĐẾ ĐỠ CHÂN
local CharacterPlatform = nil

local function updatePlatform()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if PlatformActive and hrp then
        if not CharacterPlatform or not CharacterPlatform.Parent then
            CharacterPlatform = Instance.new("Part")
            CharacterPlatform.Name = "ClientWalkPlatform"
            CharacterPlatform.Size = Vector3.new(5, 0.5, 5)
            CharacterPlatform.Anchored = true
            CharacterPlatform.CanCollide = true
            CharacterPlatform.Material = Enum.Material.ForceField
            CharacterPlatform.Color = Color3.fromRGB(0, 255, 0)
            CharacterPlatform.Transparency = 0.4 
            CharacterPlatform.Parent = workspace
        end
        CharacterPlatform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.25, hrp.Position.Z)
    else
        if CharacterPlatform then
            CharacterPlatform:Destroy()
            CharacterPlatform = nil
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if CharacterPlatform then 
        CharacterPlatform:Destroy() 
        CharacterPlatform = nil 
    end
    task.wait(0.5)
    local humanoid = char:WaitForChild("Humanoid")
    if humanoid then 
        humanoid.UseJumpPower = true
        humanoid.WalkSpeed = currentSpeed
        humanoid.JumpPower = currentJump 
    end
end)

-- =====================================================================
-- ESP 3D
local function apply3DESP(character)
    for _, v in ipairs(character:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            local oldEsp = v:FindFirstChild("3DESP_Box")
            if oldEsp then oldEsp:Destroy() end
            
            if HitboxEspActive then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "3DESP_Box"
                box.Size = v.Size + Vector3.new(0.04, 0.04, 0.04)
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Color3 = Color3.fromRGB(255, 255, 255)
                box.Transparency = 0.4
                box.Adornee = v
                box.Parent = v
            end
        end
    end
end

local function updateAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            apply3DESP(plr.Character)
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if HitboxEspActive then apply3DESP(char) end
    end)
end)

-- =====================================================================
-- AIMBOT
local function getClosestPlayer()
    local closestTarget = nil
    local maxDist = AimDistance
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                if dist < maxDist then
                    maxDist = dist
                    closestTarget = plr.Character.HumanoidRootPart
                end
            end
        end
    end
    return closestTarget
end

-- =====================================================================
-- VÒNG LẶP CHÍNH
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local targetHumanoid = LocalPlayer.Character.Humanoid
        if targetHumanoid.WalkSpeed ~= currentSpeed then
            targetHumanoid.WalkSpeed = currentSpeed
        end
        if targetHumanoid.UseJumpPower then
            if targetHumanoid.JumpPower ~= currentJump then
                targetHumanoid.JumpPower = currentJump
            end
        else
            local calculatedHeight = (currentJump * currentJump) / (2 * workspace.Gravity)
            if math.abs(targetHumanoid.JumpHeight - calculatedHeight) > 1 then
                targetHumanoid.JumpHeight = calculatedHeight
            end
        end
    end

    updatePlatform()

    local target = getClosestPlayer()
    if AimActive and target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end

    if KillAuraActive and LocalPlayer.Character then
        local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        local remote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("GameRemoteFunction")
        
        if myHrp and remote then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                    local enemyHrp = plr.Character.HumanoidRootPart
                    local dist = (enemyHrp.Position - myHrp.Position).Magnitude
                    
                    if dist <= AimDistance then
                        local dir = (enemyHrp.Position - myHrp.Position).Unit
                        remote:InvokeServer(
                            "AttemptWeaponHit",
                            {
                                hitboxOffset = Vector3.new(0, 0, 0),
                                knockback = 30,
                                shouldLock = true,
                                shouldSlow = false,
                                attackCooldown = 0,
                                hitboxSize = Vector3.new(100, 100, 100),
                                lungeKnockback = 35,
                                slowTime = 0,
                                slowMult = 1,
                                cycleIndex = 1,
                                damage = 100, 
                                tool = myTool,
                                shouldLunge = false
                            },
                            {{
                                knockback = 30,
                                isClosestEnemy = true,
                                origin = myHrp.Position,
                                enemyModel = plr.Character,
                                distance = dist,
                                direction = dir
                            }}
                        )
                    end
                end
            end
        end
    end
end)

-- =====================================================================
-- TỐI ƯU FPS
local function boostFPSSystem()
    OptimizeLevel = OptimizeLevel + 1
    if OptimizeLevel >= 1 then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
        end
    end
    if OptimizeLevel >= 2 then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") then
                v:Destroy()
            elseif v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            end
        end
    end
    if OptimizeLevel >= 3 then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            elseif v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
                v:Destroy()
            end
        end
    end
    RightColumn.FpsBoostBtn.Text = "FPS: CẤP " .. OptimizeLevel
end

-- =====================================================================
-- KÉO THẢ MENU
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- =====================================================================
-- HÀM TẠO SLIDER
local function createSlider(parentCol, text, yOffset, minVal, maxVal, defaultVal, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.Position = UDim2.new(0, 0, 0, yOffset)
    Label.Text = text .. ": " .. defaultVal
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 12
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 2
    Label.Parent = parentCol

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 6)
    SliderBar.Position = UDim2.new(0, 0, 0, yOffset + 18)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBar.ZIndex = 2
    SliderBar.Parent = parentCol

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(0, 14, 0, 14)
    SliderBtn.Position = UDim2.new(0, ((defaultVal - minVal) / (maxVal - minVal)) * 170, 0, -4)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SliderBtn.Text = ""
    SliderBtn.ZIndex = 2
    SliderBtn.Parent = SliderBar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(1, 0)
    BtnCorner.Parent = SliderBtn
    table.insert(RainbowObjects, SliderBtn)

    local sliding = false
    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.X
            local barStart = SliderBar.AbsolutePosition.X
            local barWidth = SliderBar.AbsoluteSize.X
            local percentage = math.clamp((mousePos - barStart) / barWidth, 0, 1)
            SliderBtn.Position = UDim2.new(0, percentage * (barWidth - 14), 0, -4)
            local calculatedValue = math.floor(minVal + (percentage * (maxVal - minVal)))
            Label.Text = text .. ": " .. calculatedValue
            callback(calculatedValue)
        end
    end)
end

-- =====================================================================
-- HÀM TẠO NÚT
local function createButton(parentCol, name, text, yOffset, callback)
    local Btn = Instance.new("TextButton")
    Btn.Name = name
    Btn.Size = UDim2.new(1, 0, 0, 24)
    Btn.Position = UDim2.new(0, 0, 0, yOffset)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.SourceSansBold
    Btn.ZIndex = 2
    Btn.Parent = parentCol
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Btn
    table.insert(RainbowObjects, Btn)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- =====================================================================
-- THIẾT LẬP GIAO DIỆN
-- CỘT TRÁI (SLIDERS)
createSlider(LeftColumn, "Tốc độ chạy", 0, 16, 200, 16, function(val)
    currentSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

createSlider(LeftColumn, "Độ cao nhảy", 45, 50, 300, 50, function(val)
    currentJump = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)

createSlider(LeftColumn, "Bán kính AOE Quét", 90, 10, 500, 150, function(val)
    AimDistance = val
end)

-- CỘT PHẢI (NÚT BẤM)
local FpsBoostBtn = createButton(RightColumn, "FpsBoostBtn", "Tối Ưu FPS: CLICK", 0, function()
    boostFPSSystem()
end)

createButton(RightColumn, "SpinBtn", "Xoay nhân vật", 30, function()
    SpinActive = not SpinActive
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local oldSpin = hrp:FindFirstChild("SpinGlitchForce")
        if oldSpin then oldSpin:Destroy() end
        if SpinActive then
            local spin = Instance.new("BodyAngularVelocity", hrp)
            spin.Name = "SpinGlitchForce"
            spin.MaxTorque = Vector3.new(0, math.huge, 0)
            spin.AngularVelocity = Vector3.new(0, 60, 0)
        end
    end
end)

createButton(RightColumn, "EspBtn", "Khung Hộp 3D ESP", 60, function()
    HitboxEspActive = not HitboxEspActive
    RightColumn.EspBtn.Text = HitboxEspActive and "3D ESP: ON" or "Khung Hộp 3D ESP"
    updateAllESP()
end)

createButton(RightColumn, "AimBtn", "Mục tiêu AIM", 90, function()
    AimActive = not AimActive
    RightColumn.AimBtn.Text = AimActive and "AIM: ON" or "Mục tiêu AIM"
end)

createButton(RightColumn, "SwordBtn", "AOE Kill Toàn Bản Đồ", 120, function()
    KillAuraActive = not KillAuraActive
    RightColumn.SwordBtn.Text = KillAuraActive and "Kill Aura: ON" or "AOE Kill Toàn Bản Đồ"
end)

createButton(RightColumn, "PlatformBtn", "Tấm Đế Đỡ Chân", 150, function()
    PlatformActive = not PlatformActive
    RightColumn.PlatformBtn.Text = PlatformActive and "Đế Chân: BẬT" or "Tấm Đế Đỡ Chân"
end)

-- =====================================================================
-- HIỆU ỨNG CẦU VỒNG
local hue = 0
RunService.RenderStepped:Connect(function(deltaTime)
    hue = (hue + (deltaTime * 0.1)) % 1
    GlobalRainbowColor = Color3.fromHSV(hue, 1, 1)
    for _, object in ipairs(RainbowObjects) do
        if object and object:IsA("GuiObject") then
            object.BackgroundColor3 = GlobalRainbowColor
        end
    end
end)

-- =====================================================================
-- ĐÓNG/MỞ MENU
MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

-- KHỞI TẠO ESP CHO NGƯỜI CHƠI HIỆN TẠI
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer and plr.Character then
        apply3
