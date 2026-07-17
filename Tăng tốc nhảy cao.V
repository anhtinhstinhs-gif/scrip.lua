-- Mod Menu Custom Theme V24.8.1 (Đã tích hợp Hệ thống Anti-AFK / Chống Server quét)
-- Tính năng mới: Gửi tín hiệu W ảo, gọi humanoid:Move() ảo và rung Camera góc nhỏ để bỏ qua bộ đếm thời gian của Server.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager") -- Hỗ trợ giả lập phím ảo

-- 1. KHỞI TẠO GIAO DIỆN MENU V24.8.1
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuCustomTheme_V24_8_1"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- NÚT O MỞ MENU HÌNH TRÒN BỘ XƯƠNG
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
MainFrame.Size = UDim2.new(0, 450, 0, 275) -- Tăng nhẹ chiều cao để chứa thêm nút mới ở cột phải
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -137)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.95
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- HÌNH NỀN MENU V24.8
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "MenuBackground"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Image = "rbxthumb://type=Asset&id=134759374241732&w=420&h=420"
BackgroundImage.ScaleType = Enum.ScaleType.Stretch
BackgroundImage.ZIndex = 0 
BackgroundImage.Parent = MainFrame

local BGCorner = Instance.new("UICorner")
BGCorner.CornerRadius = UDim.new(0, 12)
BGCorner.Parent = BackgroundImage

-- TIÊU ĐỀ MENU
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Anime Theme Menu V24.8.1"
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

-- BỐ CỤC HAI CỘT
local LeftColumn = Instance.new("Frame", MainFrame)
LeftColumn.Size = UDim2.new(0.45, -10, 1, -45)
LeftColumn.Position = UDim2.new(0, 10, 0, 40)
LeftColumn.BackgroundTransparency = 1
LeftColumn.ZIndex = 2

local RightColumn = Instance.new("Frame", MainFrame)
RightColumn.Size = UDim2.new(0.42, -10, 1, -45)
RightColumn.Position = UDim2.new(1, -190, 0, 40)
RightColumn.BackgroundTransparency = 1
RightColumn.ZIndex = 2

local RainbowObjects = {} 
local GlobalRainbowColor = Color3.fromRGB(255, 255, 255)

-- CÁC BIẾN TRẠNG THÁI TÍNH NĂNG
local SpinActive = false
local HitboxEspActive = false   
local KillAuraActive = false     
local AimActive = false
local PlatformActive = false 
local BypassServerActive = false -- Trạng thái nút Chống Server Phát Hiện

local OptimizeLevel = 0 
local currentSpeed = 16
local currentJump = 50
local AimDistance = 150

if setfpscap then setfpscap(999) end

-- =====================================================================
-- HÀM TẠO NÚT CÔNG TẮC GẠT TRÒN
local function createToggleSwitch(parentCol, text, yOffset, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 24)
    Container.Position = UDim2.new(0, 0, 0, yOffset)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 2
    Container.Parent = parentCol

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0.55, 0, 1, 0)
    TextLabel.Position = UDim2.new(0, 0, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = text
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 11
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.ZIndex = 2
    TextLabel.Parent = Container

    local SwitchBase = Instance.new("TextButton")
    SwitchBase.Size = UDim2.new(0, 50, 0, 22)
    SwitchBase.Position = UDim2.new(1, -52, 0, 1)
    SwitchBase.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    SwitchBase.Text = ""
    SwitchBase.ZIndex = 2
    SwitchBase.Parent = Container

    local BaseCorner = Instance.new("UICorner")
    BaseCorner.CornerRadius = UDim.new(1, 0)
    BaseCorner.Parent = SwitchBase

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, 0, 1, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "OFF"
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusText.TextSize = 10
    StatusText.Font = Enum.Font.SourceSansBold
    StatusText.Position = UDim2.new(0, 8, 0, 0)
    StatusText.ZIndex = 2
    StatusText.Parent = SwitchBase

    local CircleSlider = Instance.new("Frame")
    CircleSlider.Size = UDim2.new(0, 18, 0, 18)
    CircleSlider.Position = UDim2.new(0, 2, 0, 2)
    CircleSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CircleSlider.ZIndex = 3
    CircleSlider.Parent = SwitchBase

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = CircleSlider

    local isOn = false
    SwitchBase.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            SwitchBase.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
            CircleSlider.Position = UDim2.new(1, -20, 0, 2)
            StatusText.Text = "ON"
            StatusText.Position = UDim2.new(0, -8, 0, 0)
        else
            SwitchBase.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
            CircleSlider.Position = UDim2.new(0, 2, 0, 2)
            StatusText.Text = "OFF"
            StatusText.Position = UDim2.new(0, 8, 0, 0)
        end
        callback(isOn)
    end)
end

-- =====================================================================
-- LOGIC HỆ THỐNG ĐỐI PHÓ SERVER PHÁT HIỆN AFK / TRẠNG THÁI TĨNH
task.spawn(function()
    while true do
        task.wait(60) -- Lặp lại mỗi chu kỳ 60 giây
        if BypassServerActive then
            -- 1. Xử lý bộ đếm phím: Giả lập nhấn phím W ảo
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end)

            -- 2. Xử lý nhân vật tĩnh: Gọi di chuyển ảo không đổi tọa độ thực tế
            pcall(function()
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:Move(Vector3.new(0, 0, 0.001), false) -- Di chuyển cực nhỏ gần như đứng im
                end
            end)

            -- 3. Xử lý camera bất động: Xoay lệch 0.3 độ rồi phục hồi ngay lập tức
            pcall(function()
                local currentCFrame = Camera.CFrame
                Camera.CFrame = currentCFrame * CFrame.Angles(0, math.rad(0.3), 0)
                task.wait(0.05)
                Camera.CFrame = currentCFrame
            end)
        end
    end
end)

-- =====================================================================
-- TẤM ĐẾ ĐỠ CHÂN TRÁNH LỖI BAY LIÊN TỤC
local CharacterPlatform = nil
local LockedPlatformY = nil

local function updatePlatform()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if PlatformActive and hrp then
        if not CharacterPlatform or not CharacterPlatform.Parent then
            CharacterPlatform = Instance.new("Part")
            CharacterPlatform.Name = "ClientWalkPlatform"
            CharacterPlatform.Size = Vector3.new(6, 0.5, 6)
            CharacterPlatform.Anchored = true
            CharacterPlatform.CanCollide = true
            CharacterPlatform.Material = Enum.Material.ForceField
            CharacterPlatform.Color = Color3.fromRGB(0, 255, 0)
            CharacterPlatform.Transparency = 0.4 
            CharacterPlatform.Parent = workspace
            LockedPlatformY = hrp.Position.Y - 3.25
        end
        
        if hrp.Position.Y - 3.25 > LockedPlatformY + 1.5 then
            LockedPlatformY = hrp.Position.Y - 3.25
        elseif hrp.Position.Y - 3.25 < LockedPlatformY - 4 then
            LockedPlatformY = hrp.Position.Y - 3.25
        end
        
        CharacterPlatform.CFrame = CFrame.new(hrp.Position.X, LockedPlatformY, hrp.Position.Z)
    else
        if CharacterPlatform then CharacterPlatform:Destroy() CharacterPlatform = nil LockedPlatformY = nil end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if CharacterPlatform then CharacterPlatform:Destroy() CharacterPlatform = nil end
    task.wait(0.5)
    local humanoid = char:WaitForChild("Humanoid")
    if humanoid then 
        humanoid.UseJumpPower = true
        humanoid.WalkSpeed = currentSpeed
        humanoid.JumpPower = currentJump 
    end
end)

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
        if plr ~= LocalPlayer and plr.Character then apply3DESP(plr.Character) end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char) task.wait(0.5) if HitboxEspActive then apply3DESP(char) end end)
end)

local function getClosestPlayer()
    local closestTarget = nil
    local maxDist = AimDistance
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                if dist < maxDist then maxDist = dist; closestTarget = plr.Character.HumanoidRootPart end
            end
        end
    end
    return closestTarget
end

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local targetHumanoid = LocalPlayer.Character.Humanoid
        if targetHumanoid.WalkSpeed ~= currentSpeed then targetHumanoid.WalkSpeed = currentSpeed end
        if targetHumanoid.UseJumpPower then
            if targetHumanoid.JumpPower ~= currentJump then targetHumanoid.JumpPower = currentJump end
        else
            local calculatedHeight = (currentJump * currentJump) / (2 * workspace.Gravity)
            if math.abs(targetHumanoid.JumpHeight - calculatedHeight) > 1 then targetHumanoid.JumpHeight = calculatedHeight end
        end
    end

    updatePlatform()

    local target = getClosestPlayer()
    if AimActive and target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end

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
                        remote:InvokeServer("AttemptWeaponHit", {hitboxOffset = Vector3.new(0, 0, 0), knockback = 30, shouldLock = true, shouldSlow = false, attackCooldown = 0, hitboxSize = Vector3.new(100, 100, 100), lungeKnockback = 35, slowTime = 0, slowMult = 1, cycleIndex = 1, damage = 100, tool = myTool, shouldLunge = false}, {{knockback = 30, isClosestEnemy = true, origin = myHrp.Position, enemyModel = plr.Character, distance = dist, direction = dir}})
                    end
                end
            end
        end
    end
end)

local function boostFPSSystem()
    OptimizeLevel = OptimizeLevel + 1
    if OptimizeLevel >= 1 then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, v in ipairs(Lighting:GetChildren()) do if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then v.Enabled = false end end
    end
    if OptimizeLevel >= 2 then
        for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() elseif v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0 end end
    end
    RightColumn.FpsBoostBtn.Text = "Tối Ưu FPS: CẤP " .. OptimizeLevel
end

-- DI CHUYỂN MENU TRÊN MOBILE
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- HÀM TẠO SLIDER ĐỔI MÀU GỐC
local function createSlider(parentCol, text, yOffset, minVal, maxVal, defaultVal, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 16); Label.Position = UDim2.new(0, 0, 0, yOffset); Label.Text = text .. ": " .. defaultVal
    Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 12; Label.BackgroundTransparency = 1; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.ZIndex = 2; Label.Parent = parentCol

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 6); SliderBar.Position = UDim2.new(0, 0, 0, yOffset + 18); SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); SliderBar.ZIndex = 2; SliderBar.Parent = parentCol

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(0, 14, 0, 14); SliderBtn.Position = UDim2.new(0, ((defaultVal - minVal) / (maxVal - minVal)) * 170, 0, -4); SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); SliderBtn.Text = ""; SliderBtn.ZIndex = 2; SliderBtn.Parent = SliderBar
    Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)
    table.insert(RainbowObjects, SliderBtn)

    local sliding = false
    SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.X; local barStart = SliderBar.AbsolutePosition.X; local barWidth = SliderBar.AbsoluteSize.X
            local percentage = math.clamp((mousePos - barStart) / barWidth, 0, 1)
            SliderBtn.Position = UDim2.new(0, percentage * (barWidth - 14), 0, -4)
            local calculatedValue = math.floor(minVal + (percentage * (maxVal - minVal)))
            Label.Text = text .. ": " .. calculatedValue
            callback(calculatedValue)
        end
    end)
end

-- =====================================================================
-- PHÂN BỔ THIẾT LẬP GIAO DIỆN

-- --- CỘT TRÁI ---
createSlider(LeftColumn, "Tốc độ chạy", 0, 16, 200, 16, function(val) currentSpeed = val end)
createSlider(LeftColumn, "Độ cao nhảy", 45, 50, 300, 50, function(val) currentJump = val end)
createSlider(LeftColumn, "Bán kính AOE Quét", 90, 10, 500, 150, function(val) AimDistance = val end)

-- --- CỘT PHẢI ---
local FpsBoostBtn = Instance.new("TextButton")
FpsBoostBtn.Name = "FpsBoostBtn"; FpsBoostBtn.Size = UDim2.new(1, 0, 0, 24); FpsBoostBtn.Position = UDim2.new(0, 0, 0, 0)
FpsBoostBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); FpsBoostBtn.Text = "Tối Ưu FPS: CLICK"
FpsBoostBtn.TextColor3 = Color3.fromRGB(255, 255, 255); FpsBoostBtn.TextSize = 12; FpsBoostBtn.Font = Enum.Font.SourceSansBold; FpsBoostBtn.ZIndex = 2; FpsBoostBtn.Parent = RightColumn
Instance.new("UICorner", FpsBoostBtn).CornerRadius = UDim.new(0, 5)
table.insert(RainbowObjects, FpsBoostBtn)
FpsBoostBtn.MouseButton1Click:Connect(boostFPSSystem)

createToggleSwitch(RightColumn, "Xoay nhân vật", 30, function(state)
    SpinActive = state
    local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local oldSpin = hrp:FindFirstChild("SpinGlitchForce")
        if oldSpin then oldSpin:Destroy() end
        if SpinActive then
            local spin = Instance.new("BodyAngularVelocity", hrp); spin.Name = "SpinGlitchForce"
            spin.MaxTorque = Vector3.new(0, math.huge, 0); spin.AngularVelocity = Vector3.new(0, 60, 0)
        end
    end
end)

createToggleSwitch(RightColumn, "Khung Hộp 
