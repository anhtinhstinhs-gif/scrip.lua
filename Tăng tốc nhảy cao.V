-- MÃ NGUỒN PHIÊN BẢN V16.7 - TỐI ƯU 50 TICK - TỰ ĐỘNG NGẮT TÍNH NĂNG KHÁC
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local GlitchDisasterActive = false
local BlockDistance = 30
local AngleOffset = 0
local ActiveConnections = {} -- Quản lý luồng để tắt các tính năng khác

-- HÀM DỪNG TẤT CẢ TÍNH NĂNG KHÁC
local function stopOtherFeatures()
    for _, conn in pairs(ActiveConnections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    ActiveConnections = {}
end

-- VÒNG LẶP XỬ LÝ CHÍNH (50 TICK / SEC)
local function startDisasterGlitch()
    stopOtherFeatures() -- Tắt hết cái khác khi bật glitch này
    
    local connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not GlitchDisasterActive then return end
        
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local centerPos = hrp.Position
        local struct = workspace:FindFirstChild("Structure") or workspace:FindFirstChild("Map")
        if not struct then return end
        
        AngleOffset = AngleOffset + (deltaTime * 20)
        local count = 0
        
        for _, v in ipairs(struct:GetDescendants()) do
            if v:IsA("BasePart") and v:GetAttribute("IsManaged") == nil then
                count = count + 1
                if count > 50 then break end -- Giới hạn 50 block để tránh lag
                
                v.Anchored = false
                v.CanCollide = false
                
                local angle = math.rad((count * (360 / 50)) + AngleOffset)
                local targetPos = centerPos + Vector3.new(math.cos(angle) * BlockDistance, 5, math.sin(angle) * BlockDistance)
                
                -- Di chuyển mượt để người chơi khác cũng thấy hiệu ứng
                v.Velocity = (targetPos - v.Position) * 10
            end
        end
    end)
    table.insert(ActiveConnections, connection)
end

-- GIAO DIỆN (RÚT GỌN ĐỂ CHẠY NHANH)
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 150)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.8, 0, 0.4, 0)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleBtn.Text = "BẬT GLITCH THẢM HỌA"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

ToggleBtn.MouseButton1Click:Connect(function()
    GlitchDisasterActive = not GlitchDisasterActive
    if GlitchDisasterActive then
        ToggleBtn.Text = "ĐANG CHẠY (OFF CÁC TÍNH NĂNG KHÁC)"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        startDisasterGlitch()
    else
        ToggleBtn.Text = "BẬT GLITCH THẢM HỌA"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        stopOtherFeatures()
        -- Trả lại trạng thái vật lý cho block khi tắt
        local struct = workspace:FindFirstChild("Structure") or workspace:FindFirstChild("Map")
        if struct then
            for _, v in ipairs(struct:GetDescendants()) do
                if v:IsA("BasePart") then v.Anchored = true v.CanCollide = true end
            end
        end
    end
end)

local Slider = Instance.new("TextButton", MainFrame)
Slider.Size = UDim2.new(0.8, 0, 0.2, 0)
Slider.Position = UDim2.new(0.1, 0, 0.6, 0)
Slider.Text = "Kéo để chỉnh khoảng cách (Xa/Gần)"
Slider.MouseButton1Down:Connect(function()
    local mouse = LocalPlayer:GetMouse()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not UserInputService:IsTouchEnabled() then
            connection:Disconnect()
        end
        BlockDistance = (mouse.X - MainFrame.AbsolutePosition.X) / 2
    end)
end)
