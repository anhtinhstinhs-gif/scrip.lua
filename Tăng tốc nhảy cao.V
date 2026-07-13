local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. KHỞI TẠO GIAO DIỆN MENU V24.9
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuCustomTheme_V24_9"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- NÚT O MỞ MENU
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
MainFrame.Size = UDim2.new(0, 450, 0, 250) 
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.95
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- HÌNH NỀN NHÂN VẬT
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "MenuBackground"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Image = "rbxthumb://type=Asset&id=134759374241732&w=420&h=420"
BackgroundImage.ScaleType = Enum.ScaleType.Stretch
BackgroundImage.ZIndex = 0 
BackgroundImage.Parent = MainFrame

-- CỘT CHỨC NĂNG
local LeftColumn = Instance.new("Frame", MainFrame)
LeftColumn.Size = UDim2.new(0.45, -10, 1, -45)
LeftColumn.Position = UDim2.new(0, 10, 0, 40)
LeftColumn.BackgroundTransparency = 1
LeftColumn.ZIndex = 2

local RightColumn = Instance.new("Frame", MainFrame)
RightColumn.Size = UDim2.new(0.38, -10, 1, -45)
RightColumn.Position = UDim2.new(1, -175, 0, 40)
RightColumn.BackgroundTransparency = 1
RightColumn.ZIndex = 2

-- BIẾN TÍNH NĂNG
local SpinActive, HitboxEspActive, KillAuraActive, AimActive, PlatformActive = false, false, false, false, false
local AimDistance = 150
local currentSpeed = 16
local currentJump = 50

-- HÀM RAYCAST KIỂM TRA VẬT CẢN (WALL CHECK)
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function isVisible(target)
    if not target or not target:FindFirstChild("Head") then return false end
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local ray = workspace:Raycast(Camera.CFrame.Position, (target.Head.Position - Camera.CFrame.Position).Unit * AimDistance, rayParams)
    return ray and ray.Instance and ray.Instance:IsDescendantOf(target.Parent)
end

-- HÀM AIMBOT (CẬP NHẬT)
local function getClosestPlayer()
    local closestTarget = nil
    local minDistance = AimDistance
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    
    if myPos then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                local dist = (plr.Character.Head.Position - myPos).Magnitude
                if dist < minDistance and isVisible(plr.Character) then -- Kiểm tra tầm nhìn ở đây
                    minDistance = dist
                    closestTarget = plr.Character.Head
                end
            end
        end
    end
    return closestTarget
end

-- VÒNG LẶP CHÍNH
RunService.RenderStepped:Connect(function()
    -- Logic Aimbot với điều kiện PC/Mobile
    local target = getClosestPlayer()
    if AimActive and target then
        local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
        local isMouseDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        
        -- Nếu là mobile thì aim luôn, nếu là PC thì chỉ aim khi giữ chuột
        if isMobile or isMouseDown then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
    -- ... [CÁC LOGIC KHÁC GIỮ NGUYÊN: ESP, KILL AURA, PLATFORM] ...
end)

-- HÀM TẠO NÚT CÔNG TẮC (GREEN/RED SWITCH)
local function createSwitch(parentCol, text, yOffset, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 24); Btn.Position = UDim2.new(0, 0, 0, yOffset); Btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50); Btn.Text = text .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255); Btn.TextSize = 12; Btn.Font = Enum.Font.SourceSansBold; Btn.ZIndex = 2; Btn.Parent = parentCol
    local BtnCorner = Instance.new("UICorner"); BtnCorner.CornerRadius = UDim.new(0, 5); BtnCorner.Parent = Btn
    
    local isOn = false
    Btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        Btn.BackgroundColor3 = isOn and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        Btn.Text = text .. ": " .. (isOn and "ON" or "OFF")
        callback(isOn)
    end)
    return Btn
end

-- THIẾT LẬP NÚT BẤM (DÙNG CÔNG TẮC)
createSwitch(RightColumn, "AIMBOT", 90, function(state) AimActive = state end)
createSwitch(RightColumn, "KILL AURA", 120, function(state) KillAuraActive = state end)
-- ... [TƯƠNG TỰ VỚI CÁC NÚT KHÁC] ...
