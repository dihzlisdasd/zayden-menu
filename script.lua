-- =============================================
-- Zayden Menu | Aimbot + ESP + Silent Aim + FOV
-- Universal Roblox Cheat
-- =============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Zayden Menu",
    LoadingTitle = "Zayden Menu",
    LoadingSubtitle = "Aimbot + ESP + Silent Aim + More",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ZaydenMenu",
        FileName = "Config"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local aimbotEnabled = false
local silentAimEnabled = false
local aimKey = Enum.KeyCode.E
local aimPartName = "Head"
local fovRadius = 150
local smoothness = 0.35
local predictionEnabled = false
local predictionAmount = 0.12
local teamCheckEnabled = true
local wallCheckEnabled = true
local fovCircleEnabled = true
local fovCircleColor = Color3.fromRGB(255, 0, 255)

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Radius = fovRadius
fovCircle.Color = fovCircleColor
fovCircle.Filled = false
fovCircle.Transparency = 0.8
fovCircle.Visible = fovCircleEnabled

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Radius = fovRadius
    fovCircle.Color = fovCircleColor
    fovCircle.Visible = fovCircleEnabled
end)

local ESPEnabled = { Box = true, Name = true, Health = true, Tracer = true, Distance = true }
local ESPObjects = {}

local function createESP(plr)
    if plr == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Thickness = 2; box.Filled = false; box.Transparency = 1; box.Color = Color3.fromRGB(255,0,0)
    local nameText = Drawing.new("Text")
    nameText.Size = 14; nameText.Center = true; nameText.Outline = true; nameText.Color = Color3.fromRGB(255,255,255)
    local healthBar = Drawing.new("Square")
    healthBar.Thickness = 1; healthBar.Filled = true; healthBar.Color = Color3.fromRGB(0,255,0)
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1; tracer.Color = Color3.fromRGB(0,255,255)
    local distanceText = Drawing.new("Text")
    distanceText.Size = 12; distanceText.Center = true; distanceText.Outline = true; distanceText.Color = Color3.fromRGB(200,200,200)
    ESPObjects[plr] = {Box = box, Name = nameText, HealthBar = healthBar, Tracer = tracer, Distance = distanceText}
end

local function updateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 then
            if ESPObjects[plr] then for _, obj in pairs(ESPObjects[plr]) do obj.Visible = false end end
            continue
        end
        local char = plr.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local headPos, onScreen = Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0))
        if not onScreen then
            if ESPObjects[plr] then for _, obj in pairs(ESPObjects[plr]) do obj.Visible = false end end
            continue
        end
        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
        local boxHeight = (headPos.Y - legPos.Y) * 1.2
        local boxWidth = boxHeight / 2
        local esp = ESPObjects[plr] or createESP(plr) and ESPObjects[plr]
        if ESPEnabled.Box then esp.Box.Size = Vector2.new(boxWidth, boxHeight); esp.Box.Position = Vector2.new(headPos.X - boxWidth/2, headPos.Y); esp.Box.Visible = true else esp.Box.Visible = false end
        if ESPEnabled.Name then esp.Name.Text = plr.Name; esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 20); esp.Name.Visible = true else esp.Name.Visible = false end
        if ESPEnabled.Health then
            local health = plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth
            esp.HealthBar.Size = Vector2.new(4, boxHeight * health)
            esp.HealthBar.Position = Vector2.new(headPos.X - boxWidth/2 - 6, headPos.Y + boxHeight * (1 - health))
            esp.HealthBar.Color = Color3.fromRGB(255 - (255 * health), 255 * health, 0)
            esp.HealthBar.Visible = true
        else esp.HealthBar.Visible = false end
        if ESPEnabled.Tracer then esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); esp.Tracer.To = Vector2.new(headPos.X, headPos.Y); esp.Tracer.Visible = true else esp.Tracer.Visible = false end
        if ESPEnabled.Distance then
            local distance = (root.Position - Camera.CFrame.Position).Magnitude
            esp.Distance.Text = math.floor(distance) .. " studs"
            esp.Distance.Position = Vector2.new(headPos.X, headPos.Y + boxHeight + 5)
            esp.Distance.Visible = true
        else esp.Distance.Visible = false end
    end
end

local function isVisible(targetPart)
    if not wallCheckEnabled then return true end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * (targetPart.Position - Camera.CFrame.Position).Magnitude, params)
    return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function getClosestTarget()
    local closest, shortest = nil, fovRadius
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 then continue end
        if teamCheckEnabled and plr.Team == LocalPlayer.Team then continue end
        local targetPart = plr.Character:FindFirstChild(aimPartName) or plr.Character:FindFirstChild("Head")
        if not targetPart then continue end
        local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        local screenPos = Vector2.new(vector.X, vector.Y)
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local dist = (screenPos - center).Magnitude
        if dist > fovRadius or not isVisible(targetPart) then continue end
        if dist < shortest then shortest = dist; closest = {Player = plr, Part = targetPart} end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    updateESP()
    if not aimbotEnabled or not UserInputService:IsKeyDown(aimKey) then return end
    local targetData = getClosestTarget()
    if not targetData then return end
    local targetPos = targetData.Part.Position
    if predictionEnabled and targetData.Player.Character:FindFirstChild("HumanoidRootPart") then
        targetPos = targetPos + (targetData.Player.Character.HumanoidRootPart.Velocity * predictionAmount)
    end
    if silentAimEnabled then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        task.wait(0.01)
    else
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothness)
    end
end)

local AimbotTab = Window:CreateTab("Aimbot", 0)
AimbotTab:CreateToggle({Name = "✅ Aimbot Enabled", CurrentValue = false, Callback = function(v) aimbotEnabled = v end})
AimbotTab:CreateToggle({Name = "🔇 Silent Aim", CurrentValue = false, Callback = function(v) silentAimEnabled = v end})
AimbotTab:CreateKeybind({Name = "Aimbot Keybind", CurrentKey = Enum.KeyCode.E, Callback = function(k) aimKey = k end})
AimbotTab:CreateDropdown({Name = "Aim Part", Options = {"Head", "Torso"}, CurrentOption = {"Head"}, Callback = function(o) aimPartName = o[1] == "Torso" and "UpperTorso" or "Head" end})
AimbotTab:CreateSlider({Name = "FOV Radius", Range = {10,500}, Increment = 1, CurrentValue = 150, Callback = function(v) fovRadius = v end})
AimbotTab:CreateSlider({Name = "Smoothness", Range = {0,1}, Increment = 0.01, CurrentValue = 0.35, Callback = function(v) smoothness = v end})
AimbotTab:CreateToggle({Name = "Prediction", CurrentValue = false, Callback = function(v) predictionEnabled = v end})
AimbotTab:CreateSlider({Name = "Prediction Strength", Range = {0,0.5}, Increment = 0.01, CurrentValue = 0.12, Callback = function(v) predictionAmount = v end})
AimbotTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) teamCheckEnabled = v end})
AimbotTab:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(v) wallCheckEnabled = v end})

local VisualsTab = Window:CreateTab("Visuals", 0)
VisualsTab:CreateToggle({Name = "FOV Circle", CurrentValue = true, Callback = function(v) fovCircleEnabled = v end})
VisualsTab:CreateColorPicker({Name = "FOV Circle Color", Color = Color3.fromRGB(255,0,255), Callback = function(c) fovCircleColor = c end})

local ESPTab = Window:CreateTab("ESP", 0)
ESPTab:CreateToggle({Name = "Box ESP", CurrentValue = true, Callback = function(v) ESPEnabled.Box = v end})
ESPTab:CreateToggle({Name = "Name ESP", CurrentValue = true, Callback = function(v) ESPEnabled.Name = v end})
ESPTab:CreateToggle({Name = "Health Bar", CurrentValue = true, Callback = function(v) ESPEnabled.Health = v end})
ESPTab:CreateToggle({Name = "Tracer ESP", CurrentValue = true, Callback = function(v) ESPEnabled.Tracer = v end})
ESPTab:CreateToggle({Name = "Distance ESP", CurrentValue = true, Callback = function(v) ESPEnabled.Distance = v end})

Rayfield:Notify({Title = "✅ Zayden Menu Loaded!", Content = "Enjoy!", Duration = 5})

for _, plr in ipairs(Players:GetPlayers()) do createESP(plr) end
Players.PlayerAdded:Connect(createESP)
