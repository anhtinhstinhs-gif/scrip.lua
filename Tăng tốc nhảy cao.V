-- MÃ NGUỒN PHIÊN BẢN V20.0 - TÍCH HỢP DRAWING ESP 2D & REMOTE KILL AURA SỬA LỖI TRỰC TIẾP
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. KHỞI TẠO GIAO DIỆN MENU
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuMobileFPS_V20"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- NÚT NỔI O
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

-- KHUNG BẢNG MENU CHÍNH HÌNH CHỮ NHẬT RỘNG (CHIỀU CAO 280)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 430, 0, 280)
MainFrame.Position = UDim2.new(0.5, -215, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Premium Hub Expert V20.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
MinimizeButton.Position = UDim2.new(1, -40, 0, 0)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 50, 50)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = MainFrame

local LeftColumn = Instance.new("Frame", MainFrame)
LeftColumn.Size = UDim2.new(0.5, -15, 1, -45)
LeftColumn.Position = UDim2.new(0, 10, 0, 40)
LeftColumn.BackgroundTransparency = 1

local RightColumn = Instance.new("Frame", MainFrame)
RightColumn.Size = UDim2.new(0.5, -15, 1, -45)
RightColumn.Position = UDim2.new(0.5, 5, 0, 40)
RightColumn.BackgroundTransparency = 1

local RainbowObjects = { OpenButton }
local GlobalRainbowColor = Color3.fromRGB(255, 255, 255)

-- 2. KHỞI TẠO BIẾN TRẠNG THÁI TÍNH NĂNG
local SpinActive = false
local HitboxEspActive = false   -- Biến bật/tắt Drawing ESP mới từ code của bạn
local KillAuraActive = false     -- Biến bật/tắt AutoHit Weapon cũ/mới
local AimActive = false
local AutoGachaActive = false    -- Tính năng phụ thêm từ code mở rương của bạn

local OptimizeLevel = 0 
local currentSpeed = 16
local currentJump = 50
local AimDistance = 100

if setfpscap then setfpscap(999) end

-- =====================================================================
-- 3. CÀI ĐẶT HỆ THỐNG DRAWING ESP TOÀN CỤC (TỪ CODE CỦA BẠN)
local ESP_Storage = {}

local function createESP(plr)
    if not Drawing then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Visible = false

    local name = Drawing.new("Text")
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Visible = false

    ESP_Storage[plr] = {box = box, name = name}
end

-- Khởi tạo ESP ban đầu cho người chơi hiện tại
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end
-- Tự động nạp khi có người chơi mới vào phòng
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then createESP(p) end
end)
-- Tự dọn dẹp khi người chơi rời phòng tránh rò rỉ bộ nhớ
Players.PlayerRemoving:Connect(function(p)
    if ESP_Storage[p] then
        ESP_Storage[p].box:Remove()
        ESP_Storage[p].name:Remove()
        ESP_Storage[p] = nil
    end
end)

-- =====================================================================
-- 4. HÀM TÌM KIẾM MỤC TIÊU GẦN NHẤT CHO AIMBOT
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
-- 5. VÒNG LẶP CHÍNH (RENDERSTEPPED THAY THẾ CHUẨN XÁC)
RunService.RenderStepped:Connect(function()
    local target = getClosestPlayer()
    
    -- [AIMBOT] Khóa góc nhìn camera mượt mà
    if AimActive and target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end

    -- [KILL AURA REMOTE LỖI] Tích hợp chuẩn từ đoạn mã gửi gói tin độc hại của bạn
    if KillAuraActive and LocalPlayer.Character then
        local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        local remote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("GameRemoteFunction")
        
        if myHrp and remote then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local enemyHrp = plr.Character.HumanoidRootPart
                    local dist = (enemyHrp.Position - myHrp.Position).Magnitude
                    
                    -- Chỉ tấn công nếu nằm trong khoảng cách slider cho phép
                    if dist <= AimDistance then
                        local dir = (enemyHrp.Position - myHrp.Position).Unit
                        -- Gửi lệnh tấn công ảo phá vỡ khoảng cách vật lý thẳng lên Server
                        remote:InvokeServer(
                            "AttemptWeaponHit",
                            {
                                hitboxOffset = Vector3.new(0, 0, -1.5),
                                knockback = 50,
                                shouldLock = true,
                                shouldSlow = true,
                                attackCooldown = 0,
                                hitboxSize = Vector3.new(9, 14, 8),
                                lungeKnockback = 55,
                                slowTime = 1.5,
                                slowMult = 0.2,
                                cycleIndex = 1,
                                damage = 100, -- Ép sát thương tối đa hạ gục luôn
                                tool = myTool,
                                shouldLunge = true
                            },
                            {{
                                knockback = 50,
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

    -- [DRAWING BOX ESP 2D] Xử lý hiển thị khung vuông và tên từ code của bạn
    for plr, esp in pairs(ESP_Storage) do
        if HitboxEspActive then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")

            if hrp and head then
                local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local bottom = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local h = math.abs(top.Y - bottom.Y)
                local w = h / 2

                if top.Z > 0 and bottom.Z > 0 then
                    esp.box.Size = Vector2.new(w, h)
                    esp.box.Position = Vector2.new(top.X - w / 2, top.Y)
                    esp.box.Visible = true
                    
                    esp.name.Position = Vector2.new(top.X, top.Y - 14)
                    esp.name.Text = plr.Name
                    esp.name.Visible = true
                else
                    esp.box.Visible = false
                    esp.name.Visible = false
                end
            else
                esp.box.Visible = false
                esp.name.Visible = false
            end
        else
            esp.box.Visible = false
            esp.name.Visible = false
        end
    end

    -- [AUTO GACHA] Mở rương Divine tự động tích hợp từ code của bạn
    if AutoGachaActive and ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("GameRemoteFunction") then
        ReplicatedStorage.Events.GameRemoteFunction:InvokeServer("AttemptRollGachaChest", "Divine")
    end
end)

-- =====================================================================
-- 6. HÀM TỐI ƯU HÓA FPS ĐỒ HỌA
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
    RightColumn.FpsBoostBtn.Text = "Siêu Tối Ưu FPS: CẤP " .. OptimizeLevel
end

-- =====================================================================
-- 7. THÀNH PHẦN KÉO THẢ DI CHUYỂN MENU VÀ THANH SLIDER / BUTTONS KHỞI TẠO GIAO DIỆN
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

local function createSlider(parentCol, text, yOffset, minVal, maxVal, defaultVal, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18); Label.Position = UDim2.new(0, 0, 0, yOffset); Label.Text = text .. ": " .. defaultVal
    Label.TextColor3 = Color3.fromRGB(220, 220, 220); Label.TextSize = 13; Label.BackgroundTransparency = 1; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = parentCol

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 8); SliderBar.Position = UDim2.new(0, 0, 0, yOffset + 20); SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); SliderBar.Parent = parentCol

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(0, 16, 0, 16); SliderBtn.Position = UDim2.new(0, ((defaultVal - minVal) / (maxVal - minVal)) * 170, 0, -4); SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); SliderBtn.Text = ""; SliderBtn.Parent = SliderBar
    local BtnCorner = Instance.new("UICorner"); BtnCorner.CornerRadius = UDim.new(1, 0); BtnCorner.Parent = SliderBtn
    table.insert(RainbowObjects, SliderBtn)

    local sliding = false
    SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.X; local barStart = SliderBar.AbsolutePosition.X; local barWidth = SliderBar.AbsoluteSize.X
            local percentage = math.clamp((mousePos - barStart) / barWidth, 0, 1)
            SliderBtn.Position = UDim2.new(0, percentage * (barWidth - 16), 0, -4)
            local calculatedValue = math.floor(minVal + (percentage * (maxVal - minVal)))
            Label.Text = text .. ": " .. calculatedValue
            callback(calculatedValue)
        end
    end)
end

local function createButton(parentCol, name, text, yOffset, callback)
    local Btn = Instance.new("TextButton")
    Btn.Name = name; Btn.Size = UDim2.new(1, 0, 0, 26); Btn.Position = UDim2.new(0, 0, 0, yOffset); Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255); Btn.TextSize = 13; Btn.Font = Enum.Font.SourceSansBold; Btn.Parent = parentCol
    local BtnCorner = Instance.new("UICorner"); BtnCorner.CornerRadius = UDim.new(0, 5); BtnCorner.Parent = Btn
    table.insert(RainbowObjects, Btn)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    if humanoid then humanoid.UseJumpPower = true; humanoid.WalkSpeed = currentSpeed; humanoid.JumpPower = currentJump end
end)

-- =====================================================================
-- 8. THIẾT LẬP CÁC NÚT VÀ THANH TRƯỢT LÊN HAI CỘT MENU

-- --- CỘT TRÁI (SLIDERS) ---
createSlider(LeftColumn, "Tốc độ chạy", 0, 16, 200, 16, function(val)
    currentSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = val end
end)

createSlider(LeftColumn, "Độ cao nhảy", 45, 50, 300, 50, function(val)
    currentJump = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = val end
end)

createSlider(LeftColumn, "Khoảng cách Aim/Aura", 90, 10, 500, 100, function(val)
    AimDistance = val
end)

-- --- CỘT PHẢI (BUTTONS) ---
local FpsBoostBtn = createButton(RightColumn, "FpsBoostBtn", "Siêu Tối Ưu FPS: CLICK", 0, function()
    boostFPSSystem()
end)

createButton(RightColumn, "SpinBtn", "Bật/Tắt xoay nhân vật", 35, function()
    SpinActive = not SpinActive
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

-- NÚT ESP: Đã cập nhật thuật toán vẽ Box 2D siêu nhẹ theo code của bạn!
createButton(RightColumn, "EspBtn", "Bật/Tắt Khung Box ESP 2D", 70, function()
    HitboxEspActive = not HitboxEspActive
    RightColumn.EspBtn.Text = HitboxEspActive and "Khung Box ESP 2D: ON" or "Bật/Tắt Khung Box ESP 2D"
end)

createButton(RightColumn, "AimBtn", "Bật/Tắt khóa mục tiêu AIM", 105, function()
    AimActive = not AimActive
    RightColumn.AimBtn.Text = AimActive and "Khóa mục tiêu AIM: ON" or "Bật/Tắt khóa mục tiêu AIM"
end)

-- NÚT SWORD: Sửa lỗi dùng lệnh AttemptWeaponHit độc hại quét sát thương toàn map từ code của bạn!
createButton(RightColumn, "SwordBtn", "Kill Aura Vũ Khí Cực Mạnh", 140, function()
    KillAuraActive = not KillAuraActive
    RightColumn.SwordBtn.Text = KillAuraActive and "Kill Aura Remote: ON" or "Kill Aura Vũ Khí Cực Mạnh"
end)

-- NÚT BONUS: Tự động mở hòm Divine rương thần thánh
createButton(RightColumn, "GachaBtn", "Auto Gacha Chest: OFF", 175, function()
    AutoGachaActive = not AutoGachaActive
    RightColumn.GachaBtn.Text = AutoGachaActive and "Auto Gacha Chest: ON" or "Auto Gacha Chest: OFF"
end)

-- 9. HIỆU ỨNG ĐỔI MÀU CẦU VỒNG ĐỒNG BỘ
local hue = 0
RunService.RenderStepped:Connect(function(deltaTime)
    hue = (hue + (deltaTime * 0.1)) % 1
    GlobalRainbowColor = Color3.fromHSV(hue, 1, 1)
    for _, object in ipairs(RainbowObjects) do
        if object and object:IsA("GuiObject") then object.BackgroundColor3 = GlobalRainbowColor end
    end
end)

MinimizeButton.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenButton.Visible = false end)
