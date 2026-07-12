local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. KHỞI TẠO GIAO DIỆN MENU V24.6
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuMobileNoPC_V24_6"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 🔴 NÚT MỞ MENU HÌNH TRÒN - SỬ DỤNG HTTP LINK ẢNH BỘ XƯƠNG
local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 55, 0, 55)
OpenButton.Position = UDim2.new(0, 15, 0, 70) 
OpenButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
OpenButton.BackgroundTransparency = 0.3

-- Sử dụng dịch vụ proxy ảnh từ link gốc sang game rbx
OpenButton.Image = "https://assetgame.roblox.com/Asset/?id=135158652309194" or "rbxassetid://135158652309194"
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

-- KHUNG MENU CHÍNH
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 430, 0, 245) 
MainFrame.Position = UDim2.new(0.5, -215, 0.5, -122)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- 🔴 HÌNH NỀN MENU - SỬ DỤNG HTTP LINK ẢNH NỮ ANIME
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "MenuBackground"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.new(0, 0, 0, 0)

-- Tự động nạp cấu trúc bypass hiển thị ảnh trên mọi thiết bị
BackgroundImage.Image = "https://assetgame.roblox.com/Asset/?id=106526743937901" or "rbxassetid://106526743937901"
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.ZIndex = 0
BackgroundImage.Parent = MainFrame

local BGCorner = Instance.new("UICorner")
BGCorner.CornerRadius = UDim.new(0, 12)
BGCorner.Parent = BackgroundImage

-- TIÊU ĐỀ MENU
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Anime Mobile Menu V24.6"
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

-- HAI CỘT CHỨA TÍNH NĂNG
local LeftColumn = Instance.new("Frame", MainFrame)
LeftColumn.Size = UDim2.new(0.5, -15, 1, -45)
LeftColumn.Position = UDim2.new(0, 10, 0, 40)
LeftColumn.BackgroundTransparency = 1
LeftColumn.ZIndex = 2

local RightColumn = Instance.new("Frame", MainFrame)
RightColumn.Size = UDim2.new(0.5, -15, 1, -45)
RightColumn.Position = UDim2.new(0.5, 5, 0, 40)
RightColumn.BackgroundTransparency = 1
RightColumn.ZIndex = 2

local RainbowObjects = {}
local GlobalRainbowColor = Color3.fromRGB(255, 255, 255)

-- TRẠNG THÁI TÍNH NĂNG (GIỮ NGUYÊN)
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

-- TẤM ĐẾ ĐỠ CHÂN CỤC BỘ (GIỮ NGUYÊN)
local CharacterPlatform = nil
local function updatePlatform()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if PlatformActive and hrp then
        if not CharacterPlatform or not CharacterPlatform.Parent then
            CharacterPlatform = Instance.new("Part")
            CharacterPlatform.Name = "ClientWalkPlatform"
            CharacterPlatform.Size = Vector3.new(5, 0.5, 5)
            CharacterPlatform.Value = 0
            CharacterPlatform.Anchored = true
            CharacterPlatform.CanCollide = true
            CharacterPlatform.Material = Enum.Material.ForceField
            CharacterPlatform.Color = Color3.fromRGB(0, 255, 0)
            CharacterPlatform.Transparency = 0.4 
            CharacterPlatform.Parent = workspace
        end
        CharacterPlatform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.25, hrp.Position.Z)
    else
        if CharacterPlatform then CharacterPlatform:Destroy() CharacterPlatform = nil end
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

-- KHUNG HỘP 3D ESP (GIỮ NGUYÊN)
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
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if HitboxEspActive then apply3DESP(char) end
    end)
end)

-- AIMBOT (GIỮ NGUYÊN)
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

-- VÒNG LẶP RENDERSTEPPED CHÍNH
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

-- TỐI ƯU HÓA FPS (GIỮ NGUYÊN)
local function boostFPSSystem()
    OptimizeLevel = OptimizeLevel + 1
    if OptimizeLevel >= 1 then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then v.Enabled = false end
        end
    end
    if OptimizeLevel >= 2 then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() elseif v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0 end
        end
    end
    if OptimizeLevel >= 3 then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled = false elseif v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then v:Destroy() end
        end
    end
    RightColumn.FpsBoostBtn.Text = "Siêu Tối Ưu FPS: CẤP " .. OptimizeLevel
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

-- TẠO SLIDER VÀ BUTTON ĐÈ LÊN BACKGROUND
local function createSlider(parentCol, text, yOffset, minVal, maxVal, defaultVal, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18); Label.Position = UDim2.new(0, 0, 0, yOffset); Label.Text = text .. ": " .. defaultVal
    Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.TextSize = 13; Label.BackgroundTransparency = 1; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.ZIndex = 2; Label.Parent = parentCol

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 8); SliderBar.Position = UDim2.new(0, 0, 0, yOffset + 20); SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); SliderBar.ZIndex = 2; SliderBar.Parent = parentCol

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(0, 16, 0, 16); SliderBtn.Position = UDim2.new(0, ((defaultVal - minVal) / (maxVal - minVal)) * 170, 0, -4); SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); SliderBtn.Text = ""; SliderBtn.ZIndex = 2; SliderBtn.Parent = SliderBar
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
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255); Btn.TextSize = 13; Btn.Font = Enum.Font.SourceSansBold; Btn.ZIndex = 2; Btn.Parent = parentCol
    local BtnCorner = Instance.new("UICorner"); BtnCorner.CornerRadius = UDim.new(0, 5); BtnCorner.Parent = Btn
    table.insert(RainbowObjects, Btn)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- THIẾT LẬP CÁC NÚT LÊN GIAO DIỆN
createSlider(LeftColumn, "Tốc độ chạy", 0, 16, 200, 16, function(val) currentSpeed = val; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = val end end)
createSlider(LeftColumn, "Độ cao nhảy", 50, 50, 300, 50, function(val) currentJump = val; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = val end end)
createSlider(LeftColumn, "Bán kính AOE Quét", 100, 10, 500, 150, function(val) AimDistance = val end)

local FpsBoostBtn = createButton(RightColumn, "FpsBoostBtn", "Siêu Tối Ưu FPS: CLICK", 0, function() boostFPSSystem() end)
createButton(RightColumn, "SpinBtn", "Bật/Tắt xoay nhân vật", 35, function() SpinActive = not SpinActive; local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); if hrp then local oldSpin = hrp:FindFirstChild("SpinGlitchForce") if oldSpin then oldSpin:Destroy() end if SpinActive then local spin = Instance.new("BodyAngularVelocity", hrp); spin.Name = "SpinGlitchForce"; spin.MaxTorque = Vector3.new(0, math.huge, 0); spin.AngularVelocity = Vector3.new(0, 60, 0) end end end)
createButton(RightColumn, "EspBtn", "Bật/Tắt Khung Hộp 3D ESP", 70, function() HitboxEspActive = not HitboxEspActive; RightColumn.EspBtn.Text = HitboxEspActive and "Khung Hộp 3D ESP: ON" or "Bật/Tắt Khung Hộp 3D ESP"; updateAllESP() end)
createButton(RightColumn, "AimBtn", "Bật/Tắt khóa mục tiêu AIM", 105, function() AimActive = not AimActive; RightColumn.AimBtn.Text = AimActive and "Khóa mục tiêu AIM: ON" or "Bật/Tắt khóa mục tiêu AIM" end)
createButton(RightColumn, "SwordBtn", "Bật/Tắt AOE Kill Toàn Bản Đồ", 140, function() KillAuraActive = not KillAuraActive; RightColumn.SwordBtn.Text = KillAuraActive and "AOE Kill Aura: ON" or "Bật/Tắt AOE Kill Toàn Bản Đồ" end)
createButton(RightColumn, "PlatformBtn", "Bật Tấm Đế Đỡ Chân", 175, function() PlatformActive = not PlatformActive; RightColumn.PlatformBtn.Text = PlatformActive and "Đế Đỡ Chân: BẬT" or "Bật Tấm Đế Đỡ Chân" end)

-- ĐỔI MÀU CẦU VỒNG
local hue = 0
RunService.RenderStepped:Connect(function(deltaTime)
    hue = (hue + (deltaTime * 0.1)) % 1; GlobalRainbowColor = Color3.fromHSV(hue, 1, 1)
    for _, object in ipairs(RainbowObjects) do if object and object:IsA("GuiObject") then object.BackgroundColor3 = GlobalRainbowColor end end
end)

MinimizeButton.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenButton.Visible = false end)
