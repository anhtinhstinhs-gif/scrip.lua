-- MÃ NGUỒN PHIÊN BẢN V16.4 - AIM HEAD XỬ LÝ QUA TƯỜNG + FOV CẦU VỒNG ĐỔI SIZE
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. KHỞI TẠO HỆ THỐNG PHẦN TỬ ĐỒ HỌA GIAO DIỆN
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuMobileGlitchV16_4"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 2. NÚT NỔI O - ĐẶT DƯỚI LOGO ROBLOX ĐỂ KHÔNG BỊ KHUẤT
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

-- 3. KHUNG BẢNG MENU CHÍNH CHỨA TẤT CẢ CHỨC NĂNG
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 415)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -207)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 150, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Glitch Menu V16.4"
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

-- CẤU HÌNH THÔNG SỐ VÒNG TRÒN FOV GỐC VÀ ĐỘ MƯỢT AIM
local R = 130
local AimActive = true
local Smoothness = 0.12

-- KHỞI TẠO VÒNG TRÒN FOV CẦU VỒNG TẠI TÂM MÀN HÌNH
local F = Instance.new("Frame", ScreenGui)
F.Name = "FOV_Circle"
F.AnchorPoint = Vector2.new(0.5, 0.5)
F.Position = UDim2.new(0.5, 0, 0.5, 0)
F.Size = UDim2.new(0, R * 2, 0, R * 2)
F.BackgroundTransparency = 1
local Stroke = Instance.new("UIStroke", F)
Stroke.Thickness = 1.5
Instance.new("UICorner", F).CornerRadius = UDim.new(1, 0)

-- 4. TÍNH NĂNG DI CHUYỂN KHUNG MENU (KÉO THẢ TRÊN ĐIỆN THOẠI)
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

-- HÀM KIỂM TRA CHƯỚNG NGẠI VẬT BẰNG RAYCAST (TRÁNH KHÓA QUA TƯỜNG / BLOCK)
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

-- HÀM TÌM KIẾM ĐỐI THỦ GẦN TÂM NHẤT VÀ KHÓA VÀO VỊ TRÍ "HEAD" (ĐẦU) ĐÚNG NHƯ ẢNH IMG_20260706_053241.jpg
local function getClosestPlayerToCenter()
    local target = nil
    local maxDistance = R
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen then
                local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local distance = (Vector2.new(pos.X, pos.Y) - centerScreen).Magnitude
                if distance < maxDistance then
                    -- Kiểm tra xem trước mặt có bị cản bởi tường hoặc block không
                    if isPlayerVisible(plr.Character.Head) then
                        target = plr.Character.Head
                        maxDistance = distance
                    end
                end
            end
        end
    end
    return target
end

-- VÒNG LẶP RENDER CHÍNH - XỬ LÝ LOCK NHẸ VÀO ĐẦU KHI CÓ NGƯỜI TRONG FOV VÀ TRƯỚC MẶT KHÔNG CÓ VẬT CẢN
RunService.RenderStepped:Connect(function()
    F.Position = UDim2.new(0.5, 0, 0.5, 0)
    Stroke.Color = GlobalRainbowColor -- Cập nhật màu cầu vồng cho vòng tròn FOV liên tục
    if AimActive then
        local target = getClosestPlayerToCenter()
        if target then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Smoothness)
        end
    end
end)

-- 5. HÀM TẠO CÁC THANH ĐIỀU CHỈNH SLIDER CỦA MENU
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

-- 6. HÀM TẠO CÁC NÚT TÍNH NĂNG CHỨC NĂNG TRÊN KHUNG MENU
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

-- ĐIỀU KHIỂN GIÁ TRỊ GỐC CHO HỆ THỐNG NHÂN VẬT CHÍNH
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

-- XOAY VÒNG TRÒN NHÂN VẬT (SPIN)
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

-- NẰM SÀN TRƯỢT LỖI GÓC NHÌN
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

-- HITBOX ĐẶC 3D MÀU TRẮNG XUYÊN TƯỜNG
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

-- KILL AURA VŨ KHÍ PHÓNG TO TOÀN MAP
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

-- TỐI ƯU HÓA HỆ THỐNG GIẢM ĐỒ HỌA ĐỂ TĂNG FPS
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

-- 7. THIẾT KẾ CẤU TRÚC DANH MỤC TRÊN KHUNG MENU

-- NÚT BẬT/TẮT TÍNH NĂNG AIM KHÓA NHẸ ĐẦU NGƯỜI CHƠI KHÁC
local AimBtn = createButton("AimBtn", "AIM (Lock Head): ON", 35, function()
    AimActive = not AimActive
    if AimActive then
        MainFrame.AimBtn.Text = "AIM (Lock Head): ON"
        MainFrame.AimBtn.TextColor3 = Color3.new(0, 1, 0)
        F.Visible = true
    else
        MainFrame.AimBtn.Text = "AIM (Lock Head): OFF"
        MainFrame.AimBtn.TextColor3 = Color3.new(1, 0, 0)
        F.Visible = false
    end
end)
AimBtn.TextColor3 = Color3.new(0, 1, 0)

-- THANH KÉO SLIDER ĐIỀU CHỈNH KÍCH THƯỚC VÒNG TRÒN FOV CẦU VỒNG
createSlider("FOVSize", "Kích thước FOV tâm", 75, 30, 500, 130, function(val)
    R = val
    F.Size = UDim2.new(0, val * 2, 0, val * 2)
end)

createSlider("Speed", "Tốc độ di chuyển", 130, 16, 200, 16, function(val)
    currentSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = val end
end)

createSlider("Jump", "Nhảy cao gốc", 185, 50, 300, 50, function(val)
    currentJump = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = val end
end)

createButton("SpinBtn", "Bật/Tắt xoay vòng tròn", 245, function() toggleSpin(MainFrame.SpinBtn) end)
createButton("LayBtn", "Bật/Tắt nằm sàn lỗi", 280, function() toggleLayDown(MainFrame.LayBtn) end)
createButton("EspBtn", "Bật/Tắt Hitbox trắng", 315, function() toggleHitboxESP(MainFrame.EspBtn) end)
createButton("SwordBtn", "Kill Aura Toàn Map: OFF", 350, function() toggleHitboxSword(MainFrame.SwordBtn) end)

-- 8. VÒNG LẶP ĐỔI MÀU CẦU VỒNG ĐỒNG BỘ TOÀN HỆ THỐNG ĐỒ HỌA
local hue = 0
RunService.RenderStepped:Connect(function(deltaTime)
    hue = (hue + (deltaTime * 0.1)) % 1
    GlobalRainbowColor = Color3.fromHSV(hue, 1, 1)
    for _, object in ipairs(RainbowObjects) do
        if object and object:IsA("GuiObject") then object.BackgroundColor3 = GlobalRainbowColor end
    end
end)

MinimizeButton.MouseButton1Click:Connect(function() MainFrame.Visible = false OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = true OpenButton.Visible = false end)
