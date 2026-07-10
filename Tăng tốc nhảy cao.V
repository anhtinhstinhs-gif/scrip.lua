local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. KHỞI TẠO GIAO DIỆN MENU CHỮ NHẬT GỌN NHẸ
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuMobileFPS_V21"
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

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 430, 0, 245) -- Tăng nhẹ lên 245 để chứa thêm nút Wall Hop vừa vặn
MainFrame.Position = UDim2.new(0.5, -215, 0.5, -122)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "AOE Kill & 3D ESP Menu V21.5"
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

-- CÁC BIẾN TRẠNG THÁI TÍNH NĂNG
local SpinActive = false
local HitboxEspActive = false   
local KillAuraActive = false     
local AimActive = false
local WallHopActive = false -- Trạng thái tắt/bật của WallHop V2
local InfiniteJumpEnabled = true 

local OptimizeLevel = 0 
local currentSpeed = 16
local currentJump = 50
local AimDistance = 150

if setfpscap then setfpscap(999) end

-- KHỞI TẠO RAYCAST CHO WALLHOP V2
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

-- =====================================================================
-- HÀM QUÉT TƯỜNG CHÍNH XÁC (WALLHOP V2)
local function getWallRaycastResult()
    local character = LocalPlayer.Character
    if not character then return nil end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end

    raycastParams.FilterDescendantsInstances = {character}

    local directions = {
        humanoidRootPart.CFrame.LookVector,
        -humanoidRootPart.CFrame.LookVector,
        humanoidRootPart.CFrame.RightVector,
        -humanoidRootPart.CFrame.RightVector
    }
    local detectionDistance = 2
    local closestHit = nil
    local minDistance = detectionDistance + 1

    for _, direction in pairs(directions) do
        local ray = Workspace:Raycast(
            humanoidRootPart.Position,
            direction * detectionDistance,
            raycastParams
        )
        if ray and ray.Instance then
             if ray.Distance < minDistance then
                 minDistance = ray.Distance
                 closestHit = ray
             end
        end
    end
    return closestHit
end

-- LẮNG NGHE SỰ KIỆN NHẢY ĐỂ KÍCH HOẠT WALLHOP V2
UserInputService.JumpRequest:Connect(function()
    if not WallHopActive or not InfiniteJumpEnabled then return end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera

    if not (humanoid and rootPart and camera) then return end

    local wallRayResult = getWallRaycastResult()

    if wallRayResult then
        InfiniteJumpEnabled = false 

        local wallNormal = wallRayResult.Normal
        local horizontalWallNormal = Vector3.new(wallNormal.X, 0, wallNormal.Z).Unit
        if horizontalWallNormal.Magnitude < 0.1 then
             horizontalWallNormal = (rootPart.CFrame.LookVector * Vector3.new(1,0,1)).Unit
             if horizontalWallNormal.Magnitude < 0.1 then horizontalWallNormal = Vector3.new(0,0,-1) end
        end
        local baseDirectionAwayFromWall = horizontalWallNormal 

        local cameraLook = camera.CFrame.LookVector
        local horizontalCameraLook = Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit
        if horizontalCameraLook.Magnitude < 0.1 then horizontalCameraLook = baseDirectionAwayFromWall end

        local maxInfluenceAngle = math.rad(40)
        local dot = math.clamp(baseDirectionAwayFromWall:Dot(horizontalCameraLook), -1, 1)
        local angleBetween = math.acos(dot)
        local cross = baseDirectionAwayFromWall:Cross(horizontalCameraLook)
        local rotationSign = math.sign(cross.Y)
        if rotationSign == 0 then angleBetween = 0 end
        local actualInfluenceAngle = math.min(angleBetween, maxInfluenceAngle)
        local adjustmentRotation = CFrame.Angles(0, actualInfluenceAngle * rotationSign, 0)
        local initialTargetLookDirection = adjustmentRotation * baseDirectionAwayFromWall

        rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + initialTargetLookDirection)

        RunService.Heartbeat:Wait()

        local didJump = false
        if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
             humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
             didJump = true 
        end

        if didJump then
             local directionTowardsWall = -baseDirectionAwayFromWall 
             rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + directionTowardsWall)
        end

        task.wait(0.15)
        InfiniteJumpEnabled = true 
    end
end)

-- =====================================================================
-- HÀM TẠO BOX ESP 3D
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
-- HÀM TÌM MỤC TIÊU CHO AIMBOT
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

-- VÒNG LẶP RENDERSTEPPED 
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

-- TỐI ƯU HÓA ĐỒ HỌA BOOST FPS
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

-- CÁC HÀM XÂY DỰNG GIAO DIỆN SLIDER VÀ BUTTON
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
    local BtnCorner = Instance.new("UICorner"); BtnCorner.CornerRadius = UDim.new(0, 5); Parent = Btn; BtnCorner.Parent = Btn
    table.insert(RainbowObjects, Btn)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    if humanoid then humanoid.UseJumpPower = true; humanoid.WalkSpeed = currentSpeed; humanoid.JumpPower = currentJump end
end)

-- =====================================================================
-- 7. THIẾT LẬP CÁC PHẦN TỬ LÊN HAI CỘT MENU

-- --- CỘT TRÁI (SLIDERS CHỈ SỐ) ---
createSlider(LeftColumn, "Tốc độ chạy", 0, 16, 200, 16, function(val)
    currentSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = val end
end)

createSlider(LeftColumn, "Độ cao nhảy", 50, 50, 300, 50, function(val)
    currentJump = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = val end
end)

createSlider(LeftColumn, "Bán kính AOE Quét", 100, 10, 500, 150, function(val)
    AimDistance = val
end)

-- --- CỘT PHẢI (NÚT BẤM TÍNH NĂNG) ---
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

createButton(RightColumn, "EspBtn", "Bật/Tắt Khung Hộp 3D ESP", 70, function()
    HitboxEspActive = not HitboxEspActive
    RightColumn.EspBtn.Text = HitboxEspActive and "Khung Hộp 3D ESP: ON" or "Bật/Tắt Khung Hộp 3D ESP"
    updateAllESP()
end)

createButton(RightColumn, "AimBtn", "Bật/Tắt khóa mục tiêu AIM", 105, function()
    AimActive = not AimActive
    RightColumn.AimBtn.Text = AimActive and "Khóa mục tiêu AIM: ON" or "Bật/Tắt khóa mục tiêu AIM"
end)

createButton(RightColumn, "SwordBtn", "Bật/Tắt AOE K
