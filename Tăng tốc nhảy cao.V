-- MÃ NGUỒN PHIÊN BẢN V17.5 - FIX LỖI ĐỒNG BỘ SERVER - XOAY BLOCK NHƯ CON QUAY (NGƯỜI KHÁC PHẢI THẤY)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. KHỞI TẠO GIAO DIỆN
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuMobileGlitchV17_5"
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

-- KHUNG CHỮ NHẬT NẰM NGANG
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 430, 0, 240)
MainFrame.Position = UDim2.new(0.5, -215, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Glitch Con Quay V17.5"
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

-- KHỞI TẠO BIẾN
local GlitchDisasterActive = false
local SpinActive = false
local HitboxEspActive = false
local KillAuraActive = false

local BlockDistance = 30
local AngleOffset = 0
local currentSpeed = 16
local currentJump = 50

-- QUÉT CÁC KHỐI BLOCK TRONG MAP
local function getDisasterBlocks()
    local blocks = {}
    local struct = workspace:FindFirstChild("Structure") or workspace:FindFirstChild("Island") or workspace:FindFirstChild("Map")
    if struct then
        for _, v in ipairs(struct:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:IsA("Player") and v.Name ~= "Baseplate" then
                table.insert(blocks, v)
            end
        end
    end
    return blocks
end

-- VÒNG LẶP ĐỒNG BỘ VẬT LÝ MẠNG TÁC ĐỘNG TOÀN SERVER (50 TICK GIỚI HẠN)
RunService.Heartbeat:Connect(function(deltaTime)
    if GlitchDisasterActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local centerPos = LocalPlayer.Character.HumanoidRootPart.Position
        local blocks = getDisasterBlocks()
        
        AngleOffset = AngleOffset + (deltaTime * 90) -- Tăng tốc độ quay giống như con quay
        
        local maxBlocks = math.min(#blocks, 50)
        
        for i = 1, maxBlocks do
            local block = blocks[i]
            if block and block:IsA("BasePart") then
                -- CRITICAL FIX: Tước quyền neo và mở va chạm để kích hoạt mạng phân phối vật lý (Replication)
                block.Anchored = false
                block.CanCollide = true -- Để va chạm bật người chơi khác văng ra ngoài
                
                -- Tính toán vị trí quỹ đạo vòng tròn
                local angle = math.rad((i * (360 / maxBlocks)) + AngleOffset)
                local targetX = centerPos.X + math.cos(angle) * BlockDistance
                local targetZ = centerPos.Z + math.sin(angle) * BlockDistance
                local targetY = centerPos.Y + 2 -- Độ cao vừa tầm người
                
                local targetPosition = Vector3.new(targetX, targetY, targetZ)
                
                -- THAY THẾ CFRAME BẰNG VELOCITY (VẬN TỐC THỰC): Khiến server bắt buộc đồng bộ hình ảnh sang máy người khác
                local velocityVector = (targetPosition - block.Position) * 45
                block.Velocity = velocityVector
                
                -- Tạo hiệu ứng tự xoay tròn của bản thân khối block giống con quay
                block.RotVelocity = Vector3.new(0, 50, 0)
            end
        end
    end
end)

-- 4. KÉO THẢ DI CHUYỂN MENU
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

-- 5. HÀM TẠO THANH KÉO SLIDER
local function createSlider(parentCol, text, yOffset, minVal, maxVal, defaultVal, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.Position = UDim2.new(0, 0, 0, yOffset)
    Label.Text = text .. ": " .. defaultVal
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parentCol

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 8)
    SliderBar.Position = UDim2.new(0, 0, 0, yOffset + 20)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBar.Parent = parentCol

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(0, 16, 0, 16)
    SliderBtn.Position = UDim2.new(0, ((defaultVal - minVal) / (maxVal - minVal)) * 170, 0, -4)
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
            SliderBtn.Position = UDim2.new(0, percentage * (barWidth - 16), 0, -4)
            local calculatedValue = math.floor(minVal + (percentage * (maxVal - minVal)))
            Label.Text = text .. ": " .. calculatedValue
            callback(calculatedValue)
        end
    end)
end

-- 6. HÀM TẠO NÚT TÍNH NĂNG
local function createButton(parentCol, name, text, yOffset, callback)
    local Btn = Instance.new("TextButton")
    Btn.Name = name
    Btn.Size = UDim2.new(1, 0, 0, 26)
    Btn.Position = UDim2.new(0, 0, 0, yOffset)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.SourceSansBold
    Btn.Parent = parentCol

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Btn
    table.insert(RainbowObjects, Btn)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.WalkSpeed = currentSpeed
        humanoid.JumpPower = currentJump
    end
end)

-- 7. SẮP XẾP BẢNG CHỨC NĂNG CỘT TRÁI VÀ CỘT PHẢI
createSlider(LeftColumn, "Tốc độ chạy", 0, 16, 200, 16, function(val)
    if GlitchDisasterActive then return end
    currentSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = val end
end)

createSlider(LeftColumn, "Độ cao nhảy", 45, 50, 300, 50, function(val)
    if GlitchDisasterActive then return end
    currentJump = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = val end
end)

createSlider(LeftColumn, "Khoảng cách Block", 90, 5, 150, 30, function(val)
    BlockDistance = val
end)

-- NÚT BẬT / TẮT CHÍNH CÓ KIỂM SOÁT KHÓAƯU TIÊN LÚC ĐẦU
local DisasterBtn = createButton(RightColumn, "DisasterBtn", "Glitch Thảm Họa: OFF", 0, function()
    GlitchDisasterActive = not GlitchDisasterActive
    if GlitchDisasterActive then
        RightColumn.DisasterBtn.Text = "Glitch Thảm Họa: ON"
        SpinActive = false
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local oldSpin = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("SpinGlitchForce")
            if oldSpin then oldSpin:Destroy() end
        end
    else
        RightColumn.DisasterBtn.Text = "Glitch Thảm Họa: OFF"
        -- Khi tắt, trả lại trạng thái đứng yên cố định ban đầu cho map
        local blocks = getDisasterBlocks()
        for _, b in ipairs(blocks) do
            if b:IsA("BasePart") then 
                b.Velocity = Vector3.new(0,0,0) 
                b.RotVelocity = Vector3.new(0,0,0)
                b.Anchored = true 
            end
        end
    end
end)

createButton(RightColumn, "SpinBtn", "Bật/Tắt xoay nhân vật", 35, function()
    if GlitchDisasterActive then return end
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

createButton(RightColumn, "EspBtn", "Bật/Tắt Hitbox đặc trắng ESP", 70, function()
    if GlitchDisasterActive then return end
    HitboxEspActive = not HitboxEspActive
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            for _, v in ipairs(plr.Character:GetChildren()) do
                if v:IsA("BasePart") then
                    local oldEsp = v:FindFirstChild("HitboxESPMobile")
                    if oldEsp then oldEsp:Destroy() end
                    if HitboxEspActive and v.Name ~= "HumanoidRootPart" then
                        local box = Instance.new("BoxHandleAdornment", v)
                        box.Name = "HitboxESPMobile"
                        box.Size = v.Size + Vector3.new(0.05, 0.05, 0.05)
                        box.AlwaysOnTop = true
                        box.Color3 = Color3.fromRGB(255, 255, 255)
                        box.Transparency = 0.4
                        box.Adornee = v
                    end
                end
            end
        end
    end
end)

createButton(RightColumn, "SwordBtn", "Kill Aura Vũ Khí Toàn Map", 105, function()
    if GlitchDisasterActive then return end
    KillAuraActive = not KillAuraActive
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        if KillAuraActive then
            tool.Handle.Size = Vector3.new(5000, 5000, 5000)
            tool.Handle.CanCollide = false
        else
            tool.Handle.Size = Vector3.new(1, 1, 1)
            tool.Handle.CanCollide = true
        end
    end
end)

-- 8. VÒNG LẶP ĐỔI MÀU CẦU VỒNG (RAINBOW EFFECT)
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
