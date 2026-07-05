-- MÃ KỊCH BẢN GIAO DIỆN ĐIỀU KHIỂN (GUI) - PHIÊN BẢN V16 (CENTER TRACERS + RAINBOW HITBOX + SMOOTH AIM)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. TẠO GIAO DIỆN CHÍNH (SCREEN GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuMobileGlitchV16"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 2. NÚT MỞ MENU TRÒN (O) - CỐ ĐỊNH PHÍA DƯỚI LOGO ROBLOX ĐỂ DỄ BẤM
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0, 15, 0, 70) 
OpenButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
OpenButton.Text = "O"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 22
OpenButton.Font = Enum.Font.SourceSansBold
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

-- 3. KHUNG MENU CHÍNH
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 390)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -195)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 150, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Glitch Menu V16"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 0)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 0, 0)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = MainFrame

local RainbowObjects = { OpenButton }
local GlobalRainbowColor = Color3.fromRGB(255, 255, 255)

-- CẤU HÌNH VÒNG TRÒN FOV GỐC VÀ ĐỘ MƯỢT AIM
local R = 130
local AimActive = true
local Smoothness = 0.12 -- Hệ số khóa màn hình nhẹ, bám tâm mượt mà

local F = Instance.new("Frame", ScreenGui)
F.Name = "FOV_Circle"
F.AnchorPoint = Vector2.new(0.5, 0.5)
F.Position = UDim2.new(0.5, 0, 0.5, 0)
F.Size = UDim2.new(0, R * 2, 0, R * 2)
F.BackgroundTransparency = 1
local Stroke = Instance.new("UIStroke", F)
Stroke.Color = Color3.new(0, 1, 0)
Stroke.Thickness = 1
Instance.new("UICorner", F).CornerRadius = UDim.new(1, 0)

-- 4. TÍNH NĂNG KÉO THẢ CHO MENU CHÍNH
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
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- HÀM RAYCAST KIỂM TRA TẦM NHÌN (KHÔNG CHO AIM XUYÊN TƯỜNG/RÀO CẢN)
local function isPlayerVisible(targetPart)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, ScreenGui}
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    
    if result then
        if result.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
    end
    return false
end

-- HÀM LỌC MỤC TIÊU THOẢ MÃN ĐIỀU KIỆN TRONG VÒNG TRÒN FOV
local function getClosestPlayerToCenter()
    local target = nil
    local maxDistance = R
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local distance = (Vector2.new(pos.X, pos.Y) - centerScreen).Magnitude
                if distance < maxDistance then
                    if isPlayerVisible(plr.Character.HumanoidRootPart) then
                        target = plr.Character.HumanoidRootPart
                        maxDistance = distance
                    end
                end
            end
        end
    end
    return target
end

-- 5. QUẢN LÝ HỆ THỐNG ĐỒ HỌA DÂY TỤ TÂM VÀ KHUNG VUÔNG HITBOX CẦU VỒNG
local VisualElements = {}

local function clearVisuals()
    for _, element in pairs(VisualElements) do
        element:Destroy()
    end
    VisualElements = {}
end

local function updateVisuals()
    clearVisuals()
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local distanceFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
                
                -- Chỉ hiển thị dây và khung vuông nếu mục tiêu nằm trong vòng tròn hình học FOV
                if distanceFromCenter <= R then
                    -- A. VẼ DÂY CẦU VỒNG XUẤT PHÁT TỪ GIỮA TÂM HÌNH TRÒN CHỈ ĐẾN ĐỐI THỦ
                    local LineFrame = Instance.new("Frame")
                    LineFrame.Name = "CenterTracer"
                    LineFrame.BorderSizePixel = 0
                    LineFrame.BackgroundColor3 = GlobalRainbowColor
                    LineFrame.Parent = ScreenGui
                    
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
                    local angle = math.deg(math.atan2(screenPos.Y - centerScreen.Y, screenPos.X - centerScreen.X))
                    
                    LineFrame.Size = UDim2.new(0, distance, 0, 1.2)
                    LineFrame.AnchorPoint = Vector2.new(0, 0.5)
                    LineFrame.Position = UDim2.new(0, centerScreen.X, 0, centerScreen.Y)
                    LineFrame.Rotation = angle
                    
                    table.insert(VisualElements, LineFrame)
                    
                    -- B. VẼ KHUNG VUÔNG HITBOX 2D MÀU CẦU VỒNG XUNG QUANH MỤC TIÊU
                    local BoxFrame = Instance.new("Frame")
                    BoxFrame.Name = "Hitbox2DBox"
                    BoxFrame.BackgroundTransparency = 1
                    BoxFrame.Parent = ScreenGui
                    
                    -- Tính toán kích thước hộp bao dựa trên khoảng cách camera để tỷ lệ chuẩn xác
                    local hrpHeight = plr.Character.HumanoidRootPart.Size.Y
                    local topPos = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position + Vector3.new(0, hrpHeight * 1.5, 0))
                    local bottomPos = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position - Vector3.new(0, hrpHeight * 1.8, 0))
                    local boxHeight = math.abs(topPos.Y - bottomPos.Y)
                    local boxWidth = boxHeight * 0.75
                    
                    BoxFrame.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                    BoxFrame.Position = UDim2.new(0, screenPos.X - (boxWidth / 2), 0, screenPos.Y - (boxHeight / 2))
                    
                    local BoxStroke = Instance.new("UIStroke", BoxFrame)
                    BoxStroke.Color = GlobalRainbowColor
                    BoxStroke.Thickness = 1.5
                    
                    table.insert(VisualElements, BoxFrame)
                end
            end
        end
    end
end

-- Vòng lặp Render liên tục bám sát xử lý tọa độ màn hình và bám tâm mịn
RunService.RenderStepped:Connect(function()
    F.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    updateVisuals()
    
    if AimActive then
        local target = getClosestPlayerToCenter()
        if target then
            -- Thực hiện nội suy góc quay giúp khóa màn hình nhẹ, giảm thiểu rung màn hình trên Mobile
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Smoothness)
        end
    end
end)

-- 6. HÀM TẠO THANH TRƯỢT (SLIDER)
local function createSlider(name, text, yOffset, minVal, maxVal, defaultVal, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, yOffset)
    Label.Text = text .. ": " .. defaultVal
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 14
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = MainFrame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 10)
    SliderBar.Position = UDim2.new(0, 10, 0, yOffset + 22)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBar.Parent = MainFrame

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(0, 20, 0, 20)
    SliderBtn.Position = UDim2.new(0, ((defaultVal - minVal) / (maxVal - minVal)) * 180, 0, -5)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SliderBtn.Text = ""
    SliderBtn.Parent = SliderBar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(1, 0)
    BtnCorner.Parent = SliderBtn
    table.insert(RainbowObjects, SliderBtn)

    local sliding = false
    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.X
            local barStart = SliderBar.AbsolutePosition.X
            local barWidth = SliderBar.AbsoluteSize.X
            local percentage = math.clamp((mousePos - barStart) / barWidth, 0, 1)
            SliderBtn.Position = UDim2.new(0, percentage * (barWidth - 20), 0, -5)
            local calculatedValue = math.floor(minVal + (percentage * (maxVal - minVal)))
            Label.Text = text .. ": " .. calculatedValue
            callback(calculatedValue)
        end
    end)
end

-- 7. HÀM TẠO NÚT BẤM CHỨC NĂNG (BUTTON)
local function createButton(name, text, yOffset, callback)
    local Btn = Instance.new("TextButton")
    Btn.Name = name
    Btn.Size = UDim2.new(1, -20, 0, 26)
    Btn.Position = UDim2.new(0, 10, 0, yOffset)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.SourceSansBold
    Btn.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Btn
    table.insert(RainbowObjects, Btn)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- LOGIC ĐIỀU KHIỂN THÔNG SỐ NHÂN VẬT GỐC
local currentSpeed = 16
local currentJump = 50
local function updateCharacter(char)
    local humanoid = char:WaitForChild("Humanoid")
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.WalkSpeed = currentSpeed
        humanoid.JumpPower = currentJump
    end
end
LocalPlayer.CharacterAdded:Connect(updateCharacter)
if LocalPlayer.Character then updateCharacter(LocalPlayer.Character) end

UserInputService.JumpRequest:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- TÍNH NĂNG XOAY VÒNG
local isSpinning = false
local spinVelocity = nil
local function toggleSpin(btn)
    isSpinning = not isSpinning
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if isSpinning and hrp then
        btn.Text = "Xoay Vòng: ON"
        spinVelocity = Instance.new("BodyAngularVelocity")
        spinVelocity.Name = "SpinGlitchForce"
        spinVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
        spinVelocity.AngularVelocity = Vector3.new(0, 60, 0)
        spinVelocity.Parent = hrp
    else
        btn.Text = "Bật/Tắt xoay vòng tròn"
        if hrp and hrp:FindFirstChild("SpinGlitchForce") then hrp.SpinGlitchForce:Destroy() end
        if spinVelocity then spinVelocity:Destroy() spinVelocity = nil end
        isSpinning = false
    end
end

-- TÍNH NĂNG NẰM SÀN LỖI
local isLaidDown = false
local function toggleLayDown(btn)
    isLaidDown = not isLaidDown
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if isLaidDown then
            btn.Text = "Nằm Sàn: ON"
            humanoid.PlatformStand = true
        else
            btn.Text = "Bật/Tắt nằm sàn lỗi"
            humanoid.PlatformStand = false
        end
    end
end

-- TÍNH NĂNG HITBOX ESP KHỐI ĐẶC 3D MÀU TRẮNG
local hitboxActive = false
local espConnection = nil
local function removeHitboxESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            for _, v in ipairs(plr.Character:GetChildren()) do
                if v:IsA("BasePart") and v:FindFirstChild("HitboxESPMobile") then v.HitboxESPMobile:Destroy() end
            end
        end
    end
end
local function toggleHitboxESP(btn)
    hitboxActive = not hitboxActive
    if hitboxActive then
        btn.Text = "Hitbox Trắng 3D: ON"
        espConnection = RunService.Heartbeat:Connect(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    for _, v in ipairs(plr.Character:GetChildren()) do
                        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and not v:FindFirstChild("HitboxESPMobile") then
                            local box = Instance.new("BoxHandleAdornment")
                            box.Name = "HitboxESPMobile"
                            box.Size = v.Size + Vector3.new(0.05, 0.05, 0.05)
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
        end)
    else
        btn.Text = "Bật/Tắt Hitbox trắng"
        if espConnection then espConnection:Disconnect() espConnection = nil end
        removeHitboxESP()
    end
end

-- TÍNH NĂNG KILL AURA KIẾM PHÓNG TO TOÀN MAP
local hitboxSwordActive = false
local swordConnection = nil
local originalSizes = {}
local lastAttackTime = 0
local attackCooldown = 0.15

local function resetSword()
    for tool, oldSize in pairs(originalSizes) do
        if tool and tool.Parent and tool:FindFirstChild("Handle") then
            tool.Handle.Size = oldSize
            tool.Handle.CanCollide = true
        end
    end
    originalSizes = {}
end

local function toggleHitboxSword(btn)
    hitboxSwordActive = not hitboxSwordActive
    if hitboxSwordActive then
        btn.Text = "Kill Aura Toàn Map: ON"
        swordConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if not character then return end
            local tool = character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                if not originalSizes[tool] then originalSizes[tool] = tool.Handle.Size end
                tool.Handle.Size = Vector3.new(5000, 5000, 5000)
                tool.Handle.CanCollide = false
                local currentTime = tick()
                if currentTime - lastAttackTime >= attackCooldown then
                    tool:Activate()
                    lastAttackTime = currentTime
                end
            else
                resetSword()
            end
        end)
    else
        btn.Text = "Kill Aura Toàn Map: OFF"
        if swordConnection then swordConnection:Disconnect() swordConnection = nil end
        resetSword()
    end
end

-- TÍNH NĂNG TỐI ƯU HÓA ĐỒ HỌA BOOST FPS
local boostLevel = 0
local function toggleBoostFPS(btn)
    boostLevel = boostLevel + 1
    btn.Text = "God Boost FPS (Cấp " .. boostLevel .. ")"
    if setfpscap then setfpscap(999) end
    if boostLevel >= 1 then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end
    if boostLevel >= 2 then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.CastShadow = false end
        end
    end
    if boostLevel >= 3 then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then v:Destroy() end
        end
    end
end

-- 8. THIẾT KẾ CẤU TRÚC DANH MỤC TRÊN KHUNG MENU
local AimBtn = createButton("AimBtn", "AIM (Smooth Lock): ON", 35, function()
    AimActive = not AimActive
    if AimActive then
        MainFrame.AimBtn.Text = "AIM (Smooth Lock): ON"
        MainFrame.AimBtn.TextColor3 = Color3.new(0, 1, 0)
        Stroke.Color = Color3.new(0, 1, 0)
        F.Visible = true
    else
        MainFrame.AimBtn.Text = "AIM (Smooth Lock): OFF"
        MainFrame.AimBtn.TextColor3 = Color3.new(1, 0, 0)
        Stroke.Color = Color3.new(1, 0, 0)
        F.Visible = false
    end
end)
AimBtn.TextColor3 = Color3.new(0, 1, 0)

createSlider("Speed", "Tốc độ", 75, 16, 200, 16, function(val)
    currentSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:F
