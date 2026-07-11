local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. KHỞI TẠO MENU V22
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenu_V22_Stealth"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45); OpenButton.Position = UDim2.new(0, 15, 0, 70)
OpenButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255); OpenButton.Text = "O"; OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Visible = false; OpenButton.Parent = ScreenGui
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 430, 0, 245); MainFrame.Position = UDim2.new(0.5, -215, 0.5, -122)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- CÁC BIẾN TÍNH NĂNG
local SpinActive, HitboxEspActive, KillAuraActive, AimActive, InvisibleActive = false, false, false, false, false
local currentSpeed = 16; local currentJump = 50; local AimDistance = 150

-- =====================================================================
-- TÍNH NĂNG TÀNG HÌNH & SELF-ESP
local SelfHighlight = Instance.new("Highlight")
SelfHighlight.Name = "SelfHighlight"
SelfHighlight.FillColor = Color3.fromRGB(0, 255, 255)
SelfHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
SelfHighlight.FillTransparency = 0.5
SelfHighlight.OutlineTransparency = 0
SelfHighlight.Enabled = false

local function setVisibility(visible)
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            v.Transparency = visible and 0 or 1
        end
    end
    -- Cập nhật highlight cho chính mình
    if visible then
        SelfHighlight.Parent = nil
        SelfHighlight.Enabled = false
    else
        SelfHighlight.Parent = char
        SelfHighlight.Enabled = true
    end
end

-- =====================================================================
-- HÀM ESP & AIM (GIỮ NGUYÊN)
local function apply3DESP(character)
    for _, v in ipairs(character:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            local oldEsp = v:FindFirstChild("3DESP_Box")
            if oldEsp then oldEsp:Destroy() end
            if HitboxEspActive then
                local box = Instance.new("BoxHandleAdornment", v)
                box.Name = "3DESP_Box"; box.Size = v.Size + Vector3.new(0.04, 0.04, 0.04)
                box.AlwaysOnTop = true; box.ZIndex = 5; box.Color3 = Color3.fromRGB(255, 255, 255); box.Transparency = 0.4; box.Adornee = v
            end
        end
    end
end

-- VÒNG LẶP CHÍNH
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local targetHumanoid = LocalPlayer.Character.Humanoid
        if targetHumanoid.WalkSpeed ~= currentSpeed then targetHumanoid.WalkSpeed = currentSpeed end
        if targetHumanoid.JumpPower ~= currentJump then targetHumanoid.JumpPower = currentJump end
    end
    -- [KillAura & Aim logic same as before...]
end)

-- GIAO DIỆN NÚT BẤM (RIGHT COLUMN)
local RightColumn = Instance.new("Frame", MainFrame); RightColumn.Size = UDim2.new(0.5, -15, 1, -45); RightColumn.Position = UDim2.new(0.5, 5, 0, 40); RightColumn.BackgroundTransparency = 1

local function createBtn(name, text, y, callback)
    local Btn = Instance.new("TextButton", RightColumn); Btn.Name = name; Btn.Size = UDim2.new(1, 0, 0, 26); Btn.Position = UDim2.new(0, 0, 0, y)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); Btn.Text = text; Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

createBtn("InvisBtn", "Bật Tàng Hình + Self ESP", 0, function()
    InvisibleActive = not InvisibleActive
    setVisibility(not InvisibleActive) -- Tàng hình = false (ẩn đi)
    RightColumn.InvisBtn.Text = InvisibleActive and "Tàng Hình: ON (Đang ẩn)" or "Bật Tàng Hình + Self ESP"
end)

createBtn("EspBtn", "Bật/Tắt ESP", 35, function()
    HitboxEspActive = not HitboxEspActive
    RightColumn.EspBtn.Text = HitboxEspActive and "ESP: ON" or "Bật/Tắt ESP"
end)

createBtn("AimBtn", "Bật/Tắt AIM", 70, function()
    AimActive = not AimActive
    RightColumn.AimBtn.Text = AimActive and "AIM: ON" or "Bật/Tắt AIM"
end)

-- (Thêm các nút khác tùy ý tại đây...)

-- Minimize button
Instance.new("TextButton", MainFrame).MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenButton.Visible = false end)
