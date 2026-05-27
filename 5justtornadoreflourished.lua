-- 1. Load Key System
loadstring(game:HttpGet("https://pastefy.app/zrOtLJL9/raw"))()

-- 2. Tunggu verified (flag global dari key system)
repeat task.wait() until _G.BimzmaVerified

-- 3. Script utama jalan
print("Key valid, mulai...")

-- LOYZZAI v3.3 | Delta Executor | AutoTornado - Nearest Seat Mode
-- Fitur: auto sit ke VehicleSeat TERDEKAT, bukan hanya kendaraan sendiri.
-- Bisa dipakai untuk duduk di kendaraan player lain atau kendaraan statis map.

local Player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

-- Events
local SpawnVehicle = RS:FindFirstChild("SpawnVehicleEvent")
local CalloutEvent = RS:FindFirstChild("CalloutEvent")
local TeleportEvent = RS:FindFirstChild("TeleportEvent")

if not (SpawnVehicle and CalloutEvent) then
    warn("LOYZZAI: Remote tidak ditemukan.")
end

-- Konfigurasi
local Settings = {
    Enabled = true,
    SelectedVehicle = "TIV 1 Black",
    SafeDistance = 150,
    CalloutInterval = 8,
    InterceptEnabled = true,
    AutoReposition = true,
    lastCalloutTime = 0,
    lastInterceptTime = 0,
    SitMode = "Nearest",  -- "Nearest" atau "Own"
    Vehicles = {
        "Doppler On Wheels", "Armadillo", "Armadillo (2)", "TIV 1", "TIV 1 Black",
        "TIV 2", "Dominator Fore", "Dominator 1", "Dominator 2", "Dominator 3 (2)",
        "Hurricane Fighter", "Storm Reaver", "Storm Reaver (2)", "Storm Warrior",
        "TS1", "TEA 1", "TEA 2", "Relay Truck", "ELLEN T.V", "Raxpol", "TW",
        "Tornado Attack", "Tornado Wrangler", "Tornado Panther", "UTAV", "Titus"
    }
}

-- GUI (draggable)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoTornadoGUI"
ScreenGui.Parent = Player.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 380) -- lebih tinggi
MainFrame.Position = UDim2.new(0.8, -290, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,35)
Title.BackgroundColor3 = Color3.fromRGB(20,20,30)
Title.Text = "LOYZZAI v3.3 (Nearest Seat)"
Title.TextColor3 = Color3.fromRGB(255,200,100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

-- Toggle System
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8,0,0,35)
ToggleBtn.Position = UDim2.new(0.1,0,0.12,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
ToggleBtn.Text = "🟢 SYSTEM: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0,5)
toggleCorner.Parent = ToggleBtn

-- Mode toggle (Nearest / Own)
local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0.8,0,0,30)
ModeBtn.Position = UDim2.new(0.1,0,0.24,0)
ModeBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
ModeBtn.Text = "Mode: Nearest Seat"
ModeBtn.TextColor3 = Color3.fromRGB(255,255,200)
ModeBtn.Font = Enum.Font.Gotham
ModeBtn.TextSize = 12
ModeBtn.Parent = MainFrame
local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0,5)
modeCorner.Parent = ModeBtn

ModeBtn.MouseButton1Click:Connect(function()
    if Settings.SitMode == "Nearest" then
        Settings.SitMode = "Own"
        ModeBtn.Text = "Mode: Own Vehicle"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(80,60,60)
    else
        Settings.SitMode = "Nearest"
        ModeBtn.Text = "Mode: Nearest Seat"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(60,80,60)
    end
end)

-- Dropdown Vehicle (hanya relevan untuk mode Own)
local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(0.8,0,0,35)
DropdownBtn.Position = UDim2.new(0.1,0,0.34,0)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
DropdownBtn.Text = "🚗 " .. Settings.SelectedVehicle
DropdownBtn.TextColor3 = Color3.fromRGB(255,255,255)
DropdownBtn.Font = Enum.Font.Gotham
DropdownBtn.TextSize = 12
DropdownBtn.Parent = MainFrame
local dropCorner = Instance.new("UICorner")
dropCorner.CornerRadius = UDim.new(0,5)
dropCorner.Parent = DropdownBtn

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(0.8,0,0,150)
DropdownList.Position = UDim2.new(0.1,0,0.45,0)
DropdownList.BackgroundColor3 = Color3.fromRGB(30,30,40)
DropdownList.BorderSizePixel = 0
DropdownList.Visible = false
DropdownList.CanvasSize = UDim2.new(0,0,0, #Settings.Vehicles * 30)
DropdownList.ScrollBarThickness = 4
DropdownList.Parent = MainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0,2)
listLayout.Parent = DropdownList

for _, vName in ipairs(Settings.Vehicles) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = vName
    btn.BackgroundColor3 = Color3.fromRGB(45,45,55)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = DropdownList
    btn.MouseButton1Click:Connect(function()
        Settings.SelectedVehicle = vName
        DropdownBtn.Text = "🚗 " .. vName
        DropdownList.Visible = false
    end)
end

DropdownBtn.MouseButton1Click:Connect(function()
    DropdownList.Visible = not DropdownList.Visible
end)

-- Jarak aman
local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0.6,0,0,25)
DistLabel.Position = UDim2.new(0.05,0,0.62,0)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "Jarak aman: " .. Settings.SafeDistance
DistLabel.TextColor3 = Color3.fromRGB(200,200,200)
DistLabel.Font = Enum.Font.Gotham
DistLabel.TextSize = 12
DistLabel.Parent = MainFrame

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0.15,0,0,25)
MinusBtn.Position = UDim2.new(0.7,0,0.62,0)
MinusBtn.Text = "-10"
MinusBtn.BackgroundColor3 = Color3.fromRGB(80,40,40)
MinusBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinusBtn.Font = Enum.Font.Gotham
MinusBtn.TextSize = 12
MinusBtn.Parent = MainFrame

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0.15,0,0,25)
PlusBtn.Position = UDim2.new(0.85,0,0.62,0)
PlusBtn.Text = "+10"
PlusBtn.BackgroundColor3 = Color3.fromRGB(40,80,40)
PlusBtn.TextColor3 = Color3.fromRGB(255,255,255)
PlusBtn.Font = Enum.Font.Gotham
PlusBtn.TextSize = 12
PlusBtn.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9,0,0,50)
StatusLabel.Position = UDim2.new(0.05,0,0.75,0)
StatusLabel.BackgroundTransparency = 0.5
StatusLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
StatusLabel.Text = "Idle"
StatusLabel.TextColor3 = Color3.fromRGB(150,255,150)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

-- Fungsi update jarak
local function updateDistanceDisplay()
    DistLabel.Text = "Jarak aman: " .. Settings.SafeDistance
end
MinusBtn.MouseButton1Click:Connect(function()
    Settings.SafeDistance = math.max(50, Settings.SafeDistance - 10)
    updateDistanceDisplay()
end)
PlusBtn.MouseButton1Click:Connect(function()
    Settings.SafeDistance = math.min(400, Settings.SafeDistance + 10)
    updateDistanceDisplay()
end)

ToggleBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    if Settings.Enabled then
        ToggleBtn.Text = "🟢 SYSTEM: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
        StatusLabel.Text = "System ON - mode " .. Settings.SitMode
    else
        ToggleBtn.Text = "🔴 SYSTEM: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
        StatusLabel.Text = "System OFF"
    end
end)

-- Helper functions

local function getPrimaryPart(model)
    if model.PrimaryPart and model.PrimaryPart.Parent then
        return model.PrimaryPart
    end
    return model:FindFirstChildWhichIsA("BasePart")
end

local function setModelCFrame(model, cf)
    local primary = getPrimaryPart(model)
    if primary then
        if model.PrimaryPart then
            model:SetPrimaryPartCFrame(cf)
        else
            primary.CFrame = cf
        end
    end
end

-- Cari kendaraan yang sedang diduduki player
local function getPlayerVehicle()
    local char = Player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local seat = hum.SeatPart
    if not seat then return nil end
    return seat:FindFirstAncestorOfClass("Model")
end

-- Cari VehicleSeat terdekat dari player (bisa milik siapa saja)
local function getNearestSeat()
    local char = Player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest = nil
    local nearestDist = math.huge
    for _, seat in ipairs(workspace:GetDescendants()) do
        if seat:IsA("VehicleSeat") and seat.Parent and seat.Parent:IsA("Model") then
            local dist = (hrp.Position - seat.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = seat
            end
        end
    end
    return nearest, nearestDist
end

-- Duduk di seat tertentu
local function sitOnSeat(seat)
    if not seat then return false end
    local char = Player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = seat.CFrame
        task.wait(0.2)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Sit = true
            return true
        end
    end
    return false
end

-- Spawn vehicle dan duduk (mode Own)
local function spawnAndSit(vehicleName)
    if not SpawnVehicle then return false end
    SpawnVehicle:FireServer(vehicleName)
    StatusLabel.Text = "Spawning " .. vehicleName .. "..."
    task.wait(2.5)
    -- cari model kendaraan terbaru
    local targetModel = nil
    for _ = 1, 15 do
        for _, model in ipairs(workspace:GetChildren()) do
            if model:IsA("Model") and (model.Name:lower():find(vehicleName:lower()) or model:FindFirstChild("DriveSeat")) then
                targetModel = model
                break
            end
        end
        if targetModel then break end
        task.wait(0.5)
    end
    if not targetModel then
        StatusLabel.Text = "Gagal spawn vehicle"
        return false
    end
    local seat = targetModel:FindFirstChild("DriveSeat")
    if seat then
        return sitOnSeat(seat)
    end
    return false
end

-- Deteksi tornado
local function getAllTornadoes()
    local list = {}
    local activeFolder = workspace:FindFirstChild("ActiveTornadoes")
    if activeFolder then
        for _, child in ipairs(activeFolder:GetChildren()) do
            if child:IsA("Model") then
                local part = getPrimaryPart(child)
                if part then
                    table.insert(list, {Model = child, Part = part, Pos = part.Position})
                end
            end
        end
    else
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Size.Magnitude > 30 then
                local name = part.Name:lower()
                if name:find("tornado") or name:find("ef") or part:FindFirstChild("Tornado") then
                    table.insert(list, {Model = part.Parent, Part = part, Pos = part.Position})
                end
            end
        end
    end
    return list
end

-- Teleport vehicle ke posisi aman
local function teleportToSafePosition(vehicle, tornadoPos)
    local primary = getPrimaryPart(vehicle)
    if not primary then return end
    local rawDir = Vector3.new(math.random(-100,100), 0, math.random(-100,100))
    if rawDir.Magnitude == 0 then rawDir = Vector3.new(1,0,0) end
    local dir = rawDir.Unit
    local targetPos = tornadoPos + dir * Settings.SafeDistance
    local rayOrigin = targetPos + Vector3.new(0, 150, 0)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {vehicle, Player.Character}
    local hit = workspace:Raycast(rayOrigin, Vector3.new(0, -300, 0), rayParams)
    local groundPos = hit and hit.Position or targetPos
    groundPos = groundPos + Vector3.new(0, 3, 0)
    local cf = CFrame.new(groundPos, tornadoPos) * CFrame.Angles(0, math.rad(90), 0)
    setModelCFrame(vehicle, cf)
    -- pastikan player tetap di seat
    task.wait(0.1)
    local seat = vehicle:FindFirstChild("DriveSeat")
    if seat and Player.Character then
        sitOnSeat(seat)
    end
    StatusLabel.Text = "Teleport ke posisi aman"
end

-- Auto callout
local function doCallout(typeStr)
    if not CalloutEvent then return end
    local now = tick()
    if now - Settings.lastCalloutTime < Settings.CalloutInterval then return end
    Settings.lastCalloutTime = now
    pcall(function()
        CalloutEvent:FireServer(typeStr)
    end)
    StatusLabel.Text = "Callout: " .. typeStr
end

local function doIntercept()
    if not Settings.InterceptEnabled then return end
    if not CalloutEvent then return end
    local now = tick()
    if now - Settings.lastInterceptTime < 5 then return end
    Settings.lastInterceptTime = now
    pcall(function()
        CalloutEvent:FireServer("INTERCEPT")
    end)
    StatusLabel.Text = "Intercept!"
end

-- Main loop
local vehicle = nil
local lastTornadoPos = nil

coroutine.wrap(function()
    while true do
        task.wait(1.5)
        if not Settings.Enabled then
            vehicle = nil
            task.wait(2)
        else
            -- Mode Nearest Seat: cari seat terdekat jika tidak punya kendaraan
            if Settings.SitMode == "Nearest" then
                local currentVehicle = getPlayerVehicle()
                if not currentVehicle then
                    local nearestSeat, dist = getNearestSeat()
                    if nearestSeat and dist and dist < 50 then -- jarak maks 50 studs
                        sitOnSeat(nearestSeat)
                        StatusLabel.Text = "Duduk di seat terdekat"
                        task.wait(1)
                    else
                        StatusLabel.Text = "Tidak ada seat terdekat dalam 50 studs"
                    end
                end
                vehicle = getPlayerVehicle()
            else
                -- Mode Own: spawn vehicle sendiri jika tidak punya
                vehicle = getPlayerVehicle()
                if not vehicle then
                    StatusLabel.Text = "Tidak ada kendaraan, spawn..."
                    spawnAndSit(Settings.SelectedVehicle)
                else
                    vehicle = getPlayerVehicle()
                end
            end

            -- Lanjut ke logika tornado jika ada kendaraan
            if vehicle then
                local tornadoes = getAllTornadoes()
                if #tornadoes == 0 then
                    StatusLabel.Text = "Tidak ada tornado aktif"
                else
                    local hrp = getPrimaryPart(vehicle)
                    if hrp then
                        local closest = nil
                        local closestDist = math.huge
                        for _, t in ipairs(tornadoes) do
                            local dist = (hrp.Position - t.Pos).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = t
                            end
                        end
                        if closest then
                            lastTornadoPos = closest.Pos
                            if Settings.AutoReposition and (closestDist < 80 or closestDist > Settings.SafeDistance + 50) then
                                teleportToSafePosition(vehicle, closest.Pos)
                            else
                                if closestDist < 150 then
                                    doCallout("EF5_SPOTTED")
                                    if closestDist < 120 then
                                        doIntercept()
                                    end
                                elseif closestDist < 250 then
                                    doCallout("TORNADO_TOUCHING_DOWN")
                                else
                                    doCallout("TORNADO_OUTBREAK")
                                end
                                StatusLabel.Text = string.format("Tornado jarak: %.0f", closestDist)
                            end
                        end
                    end
                end
            end
        end
    end
end)()

-- Manual reposition key (B)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.B and vehicle and lastTornadoPos then
        teleportToSafePosition(vehicle, lastTornadoPos)
    end
end)

print("LOYZZAI v3.3 loaded - Mode Nearest Seat aktif. GUI bisa dipindah, tekan B reposition.")
