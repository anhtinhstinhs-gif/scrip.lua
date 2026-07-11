-- Script đã được giải mã từ MoonSec V3
-- Chức năng: Menu Mod đa năng (Speed, Jump, ESP, Aim, KillAura, Invisible)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- TẠO GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenu_V22_Stealth"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0, 15, 0, 70)
OpenButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
OpenButton.Text = "O"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 22
OpenButton.Font = Enum.Font.SourceSansBold
OpenButton.Visible = false
OpenButton.Parent = ScreenGui
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 430, 0, 245)
MainFrame.Position = UDim2.new(0.5, -215, 0.5, -122)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0, 250, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Mod Menu V22 Stealth"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeButton = Instance.new("TextButton", MainFrame)
MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
MinimizeButton.Position = UDim2.new(1, -40, 0, 0)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 50, 50)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

-- CỘT TRÁI: SLIDERS
local LeftColumn = Instance.new("Frame", MainFrame)
LeftColumn.Size = UDim2.new(0.5, -15, 1, -45)
LeftColumn.Position = UDim2.new(0, 10, 0, 40)
LeftColumn.BackgroundTransparency = 1

-- CỘT PHẢI: NÚT CHỨC NĂNG
local RightColumn = Instance.new("Frame", MainFrame)
RightColumn.Size = UDim2.new(0.5, -15, 1, -45)
RightColumn.Position = UDim2.new(0.5, 5, 0, 40)
RightColumn.BackgroundTransparency = 1

-- BIẾN TRẠNG THÁI
local SpinActive = false
local HitboxEspActive = false
local KillAuraActive = false
local AimActive = false
local InvisibleActive = false
local currentSpeed = 16
local currentJump = 50
local AimDistance = 150

-- HÀM TẠO SLIDER
local function createSlider(parent, text, yOffset, minVal, maxVal, defaultVal, callback)
    local Label = Instance.new("TextLabel", parent)
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.Position = UDim2.new(0, 0, 0, yOffset)
    Label.Text = text .. ": " .. defaultVal
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local SliderBar = Instance.new("Frame", parent)
    SliderBar.Size = UDim2.new(1, 0, 0, 8)
    SliderBar.Position = UDim2.new(0, 0, 0, yOffset + 20)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

    local SliderBtn = Instance.new("TextButton", SliderBar)
    SliderBtn.Size = UDim2.new(0, 16, 0, 16)
    SliderBtn.Position = UDim2.new(0, ((defaultVal - minVal) / (maxVal - minVal)) * 170, 0, -4)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SliderBtn.Text = ""
    Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)

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
            SliderBtn.Position = UDim2.new(0, percentage * (barWidth - 16), 0, -4)
            local calculatedValue = math.floor(minVal + (percentage * (maxVal - minVal)))
            Label.Text = text .. ": " .. calculatedValue
            callback(calculatedValue)
        end
    end)
end

-- HÀM TẠO NÚT
local function createButton(parent, name, text, yOffset, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Name = name
    Btn.Size = UDim2.new(1, 0, 0, 26)
    Btn.Position = UDim2.new(0, 0, 0, yOffset)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- SLIDERS CỘT TRÁI
createSlider(LeftColumn, "Tốc độ chạy", 0, 16, 200, 16, function(val)
    currentSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

createSlider(LeftColumn, "Độ cao nhảy", 50, 50, 300, 50, function(val)
    currentJump = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)

createSlider(LeftColumn, "Bán kính AOE", 100, 10, 500, 150, function(val)
    AimDistance = val
end)

-- TÀNG HÌNH + SELF ESP
local SelfHighlight = Instance.new("Highlight")
SelfHighlight.Name = "SelfHighlight"
SelfHighlight.FillColor = Color3.fromRGB(0, 255, 255)
SelfHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
SelfHighlight.FillTransparency = 0.5
SelfHighlight.OutlineTransparency = 0
SelfHighlight.Enabled = false

local function setVisibility(visible)
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            v.Transparency = visible and 0 or 1
        end
    end
    if visible then
        SelfHighlight.Parent = nil
        SelfHighlight.Enabled = false
    else
        SelfHighlight.Parent = char
        SelfHighlight.Enabled = true
    end
end

-- ESP 3D
local function apply3DESP(character)
    for _, v in ipairs(character:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            local oldEsp = v:FindFirstChild("3DESP_Box")
            if oldEsp then oldEsp:Destroy() end
            if HitboxEspActive then
                local box = Instance.new("BoxHandleAdornment", v)
                box.Name = "3DESP_Box"
                box.Size = v.Size + Vector3.new(0.04, 0.04, 0.04)
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Color3 = Color3.fromRGB(255, 255, 255)
                box.Transparency = 0.4
                box.Adornee = v
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

-- KILL AURA
local function doKillAura()
    if not KillAuraActive or not LocalPlayer.Character then return end
    local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local remote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("GameRemoteFunction")
    if not myHrp or not remote then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local enemyHrp = plr.Character.HumanoidRootPart
            local dist = (enemyHrp.Position - myHrp.Position).Magnitude
            if dist <= AimDistance then
                local dir = (enemyHrp.Position - myHrp.Position).Unit
                remote:InvokeServer("AttemptWeaponHit", {
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
                }, {{
                    knockback = 30,
                    isClosestEnemy = true,
                    origin = myHrp.Position,
                    enemyModel = plr.Character,
                    distance = dist,
                    direction = dir
                }})
            end
        end
    end
end

-- VÒNG LẶP CHÍNH
RunService.RenderStepped:Connect(function()
    -- Cập nhật Speed/Jump
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        if humanoid.WalkSpeed ~= currentSpeed then
            humanoid.WalkSpeed = currentSpeed
        end
        if humanoid.JumpPower ~= currentJump then
            humanoid.JumpPower = currentJump
        end
    end

    -- AIM
    if AimActive then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- KILL AURA
    doKillAura()
end)

-- NÚT CHỨC NĂNG CỘT PHẢI
createButton(RightColumn, "InvisBtn", "Bật Tàng Hình + Self ESP", 0, function()
    InvisibleActive = not InvisibleActive
    setVisibility(not InvisibleActive)
    RightColumn.InvisBtn.Text = InvisibleActive and "Tàng Hình: ON (Đang ẩn)" or "Bật Tàng Hình + Self ESP"
end)

createButton(RightColumn, "SpinBtn", "Bật/Tắt xoay nhân vật", 35, function()
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

createButton(RightColumn, "EspBtn", "Bật/Tắt ESP 3D", 70, function()
    HitboxEspActive = not HitboxEspActive
    RightColumn.EspBtn.Text = HitboxEspActive and "ESP 3D: ON" or "Bật/Tắt ESP 3D"
    updateAllESP()
end)

createButton(RightColumn, "AimBtn", "Bật/Tắt AIM", 105, function()
    AimActive = not AimActive
    RightColumn.AimBtn.Text = AimActive and "AIM: ON" or "Bật/Tắt AIM"
end)

createButton(RightColumn, "SwordBtn", "Bật/Tắt Kill Aura", 140, function()
    KillAuraActive = not KillAuraActive
    RightColumn.SwordBtn.Text = KillAuraActive and "Kill Aura: ON" or "Bật/Tắt Kill Aura"
end)

-- KÉO THẢ MENU
local dragging = false
local dragStart = nil
local startPos = nil

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

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- KHỞI TẠO ESP CHO NGƯỜI CHƠI HIỆN TẠI
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer and plr.Character then
        apply3DESP(plr.Character)
    end
end
