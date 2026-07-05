-- MÃ KỊCH BẢN GIAO GIỆN ĐIỀU KHIỂN (GUI) - PHIÊN BẢN V12 (KILL AURA TOÀN BẢN ĐỒ SIÊU BÁ ĐẠO)
-- Chức năng: WalkSpeed, JumpPower, Infinite Jump, Xoay vòng, Nằm sàn, Hitbox ESP, Kill Aura Kiếm Toàn Bản Đồ, God Boost FPS

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- 1. TẠO GIAO DIỆN CHÍNH (SCREEN GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuMobileGlitchV12"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 2. NÚT MỞ MENU TRÒN (O)
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 10, 0, 10)
OpenButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
OpenButton.Text = "O"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 24
OpenButton.Font = Enum.Font.SourceSansBold
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

-- 3. KHUNG MENU CHÍNH
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 360)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 150, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Glitch Menu V12"
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

-- 4. TÍNH NĂNG KÉO THẢ (DRAGGABLE) CHO MOBILE
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

-- 5. HÀM TẠO THANH TRƯỢT (SLIDER)
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

-- 6. HÀM TẠO NÚT BẤM CHỨC NĂNG (BUTTON)
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

-- 7. LOGIC DIỀU KHIỂN NHÂN VẬT GỐC
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

-- NÚT 1: XOAY VÒNG TRÒN
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

-- NÚT 2: NẰM SÀN LỖI
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

-- NÚT 3: HITBOX ESP HÌNH VUÔNG TRẮNG
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
        btn.Text = "Hitbox Trắng: ON"
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

-- =========================================================================
-- NÚT 4 BÁ ĐẠO NHẤT: KILL AURA PHÓNG TO KIẾM TOÀN BẢN ĐỒ (5000 x 5000 x 5000)
-- =========================================================================
local hitboxSwordActive = false
local swordConnection = nil
local originalSizes = {}
local lastAttackTime = 0
local attackCooldown = 0.15 -- Nhịp nghỉ nhỏ chuẩn xác để nhân vật di chuyển mượt mà không bị khựng lại

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
                
                -- Đẩy kích thước hộp va chạm lên cực đại bao phủ toàn bộ bản đồ game
                tool.Handle.Size = Vector3.new(5000, 5000, 5000)
                tool.Handle.CanCollide = false -- Tắt va chạm để không bị kẹt hay văng khỏi bản đồ
                
                -- Tự động vung kiếm chém liên tục theo thời gian thực mượt mà
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

LocalPlayer.CharacterRemoving:Connect(function()
    hitboxSwordActive = false
    if swordConnection then swordConnection:Disconnect() swordConnection = nil end
    originalSizes = {}
end)

-- NÚT 5: GOD BOOST FPS CẤP SỐ NHÂN
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

-- 8. KHỞI TẠO CÁC SLIDER VÀ NÚT BẤM V12
createSlider("Speed", "Tốc độ", 40, 16, 200, 16, function(val)
    currentSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = val end
end)

createSlider("Jump", "Nhảy cao", 95, 50, 300, 50, function(val)
    currentJump = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = val end
end)

createButton("SpinBtn", "Bật/Tắt xoay vòng tròn", 160, function() toggleSpin(MainFrame.SpinBtn) end)
createButton("LayBtn", "Bật/Tắt nằm sàn lỗi", 195, function() toggleLayDown(MainFrame.LayBtn) end)
createButton("EspBtn", "Bật/Tắt Hitbox trắng", 230, function() toggleHitboxESP(MainFrame.EspBtn) end)
createButton("SwordBtn", "Kill Aura Toàn Map: OFF", 265, function() toggleHitboxSword(MainFrame.SwordBtn) end)
createButton("BoostBtn", "God Boost FPS (Click để Nhân)", 300, function() toggleBoostFPS(MainFrame.BoostBtn) end)

-- 9. VÒNG LẶP ĐỔI MÀU CẦU VỒNG (RAINBOW LOOP)
local hue = 0
RunService.RenderStepped:Connect(function(deltaTime)
    hue = (hue + (deltaTime * 0.1)) % 1
    local rainbowColor = Color3.fromHSV(hue, 1, 1)
    for _, object in ipairs(RainbowObjects) do
        if object and object:IsA("GuiObject") then object.BackgroundColor3 = rainbowColor end
    end
end)

MinimizeButton.MouseButton1Click:Connect(function() MainFrame.Visible = false OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = true OpenButton.Visible = false end)
