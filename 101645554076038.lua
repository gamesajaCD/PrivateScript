-- Memuat library Tora dengan error handling
local library
local success, errorMsg = pcall(function()
    library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
end)

if not success then
    warn("Gagal memuat Tora library: " .. tostring(errorMsg))
    return
end

-- Mendapatkan judul game secara dinamis
local gameTitle = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

-- Membuat jendela utama dengan judul otomatis
local mainWindow = library:CreateWindow(gameTitle)

-- Membuat tab Main
local mainTab = mainWindow:AddFolder("Main")

-- Fungsi untuk notifikasi menggunakan StarterGui
local function notify(title, content, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = content,
            Duration = duration or 5
        })
    end)
end

-- Membuat folder untuk Zone dan Auto Win
local zoneAutoWinFolder = mainTab:AddFolder("Zone and Auto Win")

-- Fungsi untuk mendapatkan daftar Zone dari workspace.Zones
local function getZoneList()
    local zones = {}
    local zonesFolder = game.Workspace:FindFirstChild("Zones")
    if zonesFolder then
        for _, zone in pairs(zonesFolder:GetChildren()) do
            if zone:IsA("Model") then
                table.insert(zones, zone.Name)
            end
        end
    end
    return zones
end

-- Dropdown untuk memilih Zone
local SelectedZone = ""
local ZoneDropdown = zoneAutoWinFolder:AddList({
    text = "Select Zone",
    values = getZoneList(),
    flag = "ZoneDropdown",
    callback = function(value)
        SelectedZone = value
        local player = game.Players.LocalPlayer
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            notify("Teleport Failed", "Player character or HumanoidRootPart not found")
            return
        end
        local zonesFolder = game.Workspace:FindFirstChild("Zones")
        if not zonesFolder then
            notify("Teleport Failed", "Zones folder not found in Workspace")
            return
        end
        local zone = zonesFolder:FindFirstChild(SelectedZone)
        if not zone then
            notify("Teleport Failed", "Zone " .. SelectedZone .. " not found")
            return
        end
        local cframe
        if zone:IsA("BasePart") then
            cframe = zone.CFrame
        else
            local primaryPart = zone.PrimaryPart or zone:FindFirstChildWhichIsA("BasePart")
            if not primaryPart then
                notify("Teleport Failed", "Zone " .. SelectedZone .. " has no valid BasePart or PrimaryPart")
                return
            end
            cframe = primaryPart.CFrame
        end
        player.Character.HumanoidRootPart.CFrame = cframe + Vector3.new(0, 5, 0)
        notify("Teleport Success", "Teleported to " .. SelectedZone)
    end
})

-- Button untuk Refresh Zone List
zoneAutoWinFolder:AddButton({
    text = "Refresh Zone List",
    flag = "RefreshZoneButton",
    callback = function()
        local newZoneList = getZoneList()
        ZoneDropdown:SetValues(newZoneList)
        if SelectedZone ~= "" and not table.find(newZoneList, SelectedZone) then
            SelectedZone = ""
            ZoneDropdown:SetValue("")
        end
        notify("Zone List Refreshed", "Zone dropdown has been updated with the latest zones")
    end
})

-- Variabel untuk Auto Win
local AutoWinEnabled = false
local autoWinThread = nil

-- Toggle untuk Auto Win
zoneAutoWinFolder:AddToggle({
    text = "Auto Win",
    flag = "AutoWinToggle",
    callback = function(value)
        AutoWinEnabled = value
        if value then
            notify("Auto Win Enabled", "Started auto winning every 0.1 seconds for " .. (SelectedZone ~= "" and SelectedZone or "selected zone"))
            autoWinThread = spawn(function()
                while AutoWinEnabled do
                    if SelectedZone == "" then
                        notify("Auto Win Error", "Please select a zone from the dropdown")
                        AutoWinEnabled = false
                        zoneAutoWinFolder:SetToggle("AutoWinToggle", false)
                        break
                    end
                    local ohString1 = "Win"
                    local ohTable2 = {
                        [1] = SelectedZone,
                        [2] = {}
                    }
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage").Events.RewardAction:FireServer(ohString1, ohTable2)
                    end)
                    if not success then
                        notify("Auto Win Error", "Failed to trigger win: " .. tostring(err))
                        AutoWinEnabled = false
                        zoneAutoWinFolder:SetToggle("AutoWinToggle", false)
                        break
                    end
                    wait(0.1)
                end
            end)
        else
            if autoWinThread then
                coroutine.close(autoWinThread)
                autoWinThread = nil
            end
            notify("Auto Win Disabled", "Auto Win has been stopped")
        end
    end
})

-- Membuat folder untuk Auto Spin
local autoSpinFolder = mainTab:AddFolder("Auto Spin")

-- Variabel untuk Auto Spin
local AutoSpinEnabled = false
local autoSpinThread = nil

-- Toggle untuk Auto Spin
autoSpinFolder:AddToggle({
    text = "Auto Spin",
    flag = "AutoSpinToggle",
    callback = function(value)
        AutoSpinEnabled = value
        if value then
            notify("Auto Spin Enabled", "Started auto spinning every 0.1 seconds")
            autoSpinThread = spawn(function()
                while AutoSpinEnabled do
                    local ohString1 = "Spin"
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage").Events.RewardActionFunction:InvokeServer(ohString1)
                    end)
                    if not success then
                        notify("Auto Spin Error", "Failed to trigger spin: " .. tostring(err))
                        AutoSpinEnabled = false
                        autoSpinFolder:SetToggle("AutoSpinToggle", false)
                        break
                    end
                    wait(0.1)
                end
            end)
        else
            if autoSpinThread then
                coroutine.close(autoSpinThread)
                autoSpinThread = nil
            end
            notify("Auto Spin Disabled", "Auto Spin has been stopped")
        end
    end
})

-- Membuat folder untuk Auto Rebirth
local autoRebirthFolder = mainTab:AddFolder("Auto Rebirth")

-- Variabel untuk Auto Rebirth
local AutoRebirthEnabled = false
local autoRebirthThread = nil

-- Toggle untuk Auto Rebirth
autoRebirthFolder:AddToggle({
    text = "Auto Rebirth",
    flag = "AutoRebirthToggle",
    callback = function(value)
        AutoRebirthEnabled = value
        if value then
            notify("Auto Rebirth Enabled", "Started auto rebirthing every 0.1 seconds")
            autoRebirthThread = spawn(function()
                while AutoRebirthEnabled do
                    local ohString1 = "Rebirth"
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage").Events.RewardAction:FireServer(ohString1)
                    end)
                    if not success then
                        notify("Auto Rebirth Error", "Failed to trigger rebirth: " .. tostring(err))
                        AutoRebirthEnabled = false
                        autoRebirthFolder:SetToggle("AutoRebirthToggle", false)
                        break
                    end
                    wait(0.1)
                end
            end)
        else
            if autoRebirthThread then
                coroutine.close(autoRebirthThread)
                autoRebirthThread = nil
            end
            notify("Auto Rebirth Disabled", "Auto Rebirth has been stopped")
        end
    end
})

-- Membuat folder untuk Auto Claim Gift
local autoClaimGiftFolder = mainTab:AddFolder("Auto Claim Gift")

-- Dropdown untuk memilih Gift
local SelectedGift = ""
local GiftDropdown = autoClaimGiftFolder:AddList({
    text = "Select Gift",
    values = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"},
    flag = "GiftDropdown",
    callback = function(value)
        SelectedGift = value
    end
})

-- Variabel untuk Auto Claim Gift All
local AutoClaimGiftAllEnabled = false
local autoClaimGiftAllThread = nil

-- Toggle untuk Auto Claim Gift All
autoClaimGiftFolder:AddToggle({
    text = "Auto Claim Gift All",
    flag = "AutoClaimGiftAllToggle",
    callback = function(value)
        AutoClaimGiftAllEnabled = value
        if value then
            notify("Auto Claim Gift All Enabled", "Started claiming gifts 1-12 every 0.1 seconds")
            autoClaimGiftAllThread = spawn(function()
                while AutoClaimGiftAllEnabled do
                    for i = 1, 12 do
                        if not AutoClaimGiftAllEnabled then break end
                        local ohString1 = "Playtime"
                        local ohNumber2 = i
                        local success, err = pcall(function()
                            game:GetService("ReplicatedStorage").Events.RewardAction:FireServer(ohString1, ohNumber2)
                        end)
                        if not success then
                            notify("Auto Claim Gift All Error", "Failed to claim gift " .. tostring(i) .. ": " .. tostring(err))
                        end
                    end
                    wait(0.1)
                end
            end)
        else
            if autoClaimGiftAllThread then
                coroutine.close(autoClaimGiftAllThread)
                autoClaimGiftAllThread = nil
            end
            notify("Auto Claim Gift All Disabled", "Auto Claim Gift All has been stopped")
        end
    end
})

-- Variabel untuk Auto Claim Gift On
local AutoClaimGiftOnEnabled = false
local autoClaimGiftOnThread = nil

-- Toggle untuk Auto Claim Gift On
autoClaimGiftFolder:AddToggle({
    text = "Auto Claim Gift On",
    flag = "AutoClaimGiftOnToggle",
    callback = function(value)
        AutoClaimGiftOnEnabled = value
        if value then
            if SelectedGift == "" then
                notify("Auto Claim Gift On Error", "Please select a gift from the dropdown")
                AutoClaimGiftOnEnabled = false
                autoClaimGiftFolder:SetToggle("AutoClaimGiftOnToggle", false)
                return
            end
            notify("Auto Claim Gift On Enabled", "Started claiming gift " .. SelectedGift .. " every 0.1 seconds")
            autoClaimGiftOnThread = spawn(function()
                while AutoClaimGiftOnEnabled do
                    local ohString1 = "Playtime"
                    local ohNumber2 = tonumber(SelectedGift)
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage").Events.RewardAction:FireServer(ohString1, ohNumber2)
                    end)
                    if not success then
                        notify("Auto Claim Gift On Error", "Failed to claim gift " .. SelectedGift .. ": " .. tostring(err))
                        AutoClaimGiftOnEnabled = false
                        autoClaimGiftFolder:SetToggle("AutoClaimGiftOnToggle", false)
                        break
                    end
                    wait(0.1)
                end
            end)
        else
            if autoClaimGiftOnThread then
                coroutine.close(autoClaimGiftOnThread)
                autoClaimGiftOnThread = nil
            end
            notify("Auto Claim Gift On Disabled", "Auto Claim Gift On has been stopped")
        end
    end
})

-- Membuat tab Egg
local eggTab = mainWindow:AddFolder("Egg")

-- Membuat folder untuk Egg Settings
local eggSettingsFolder = eggTab:AddFolder("Egg Settings")

-- Fungsi untuk mendapatkan daftar Egg dari semua Zones
local function getEggList()
    local eggs = {}
    local zonesFolder = game.Workspace:FindFirstChild("Zones")
    if zonesFolder then
        for _, zone in pairs(zonesFolder:GetChildren()) do
            if zone:IsA("Model") then
                local eggsFolder = zone:FindFirstChild("Eggs")
                if eggsFolder then
                    for _, egg in pairs(eggsFolder:GetChildren()) do
                        if egg:IsA("Model") then
                            table.insert(eggs, zone.Name .. "/" .. egg.Name)
                        end
                    end
                end
            end
        end
    end
    return eggs
end

-- Dropdown untuk memilih Egg
local SelectedEgg = ""
local EggDropdown = eggSettingsFolder:AddList({
    text = "Select Egg",
    values = getEggList(),
    flag = "EggDropdown",
    callback = function(value)
        SelectedEgg = value
    end
})

-- Button untuk Refresh Egg List
eggSettingsFolder:AddButton({
    text = "Refresh Egg List",
    flag = "RefreshEggButton",
    callback = function()
        local newEggList = getEggList()
        EggDropdown:SetValues(newEggList)
        if SelectedEgg ~= "" and not table.find(newEggList, SelectedEgg) then
            SelectedEgg = ""
            EggDropdown:SetValue("")
        end
        notify("Egg List Refreshed", "Egg dropdown has been updated with the latest eggs")
    end
})

-- Dropdown untuk memilih How Many
local SelectedHowMany = "1"
local HowManyDropdown = eggSettingsFolder:AddList({
    text = "How Many",
    values = {"1", "3", "5", "10", "15"},
    flag = "HowManyDropdown",
    callback = function(value)
        SelectedHowMany = value
    end
})

-- Variabel untuk Auto Hatch Egg
local AutoHatchEggEnabled = false
local autoHatchEggThread = nil

-- Toggle untuk Auto Hatch Egg
eggSettingsFolder:AddToggle({
    text = "Auto Hatch Egg",
    flag = "AutoHatchEggToggle",
    callback = function(value)
        AutoHatchEggEnabled = value
        if value then
            if SelectedEgg == "" then
                notify("Auto Hatch Egg Error", "Please select an egg from the dropdown")
                AutoHatchEggEnabled = false
                eggSettingsFolder:SetToggle("AutoHatchEggToggle", false)
                return
            end
            local eggName = SelectedEgg:match(".*/(.*)")
            notify("Auto Hatch Egg Enabled", "Started hatching " .. (eggName or "selected egg") .. " (" .. SelectedHowMany .. " at a time) every 0.1 seconds")
            autoHatchEggThread = spawn(function()
                while AutoHatchEggEnabled do
                    local eggName = SelectedEgg:match(".*/(.*)")
                    if not eggName then
                        notify("Auto Hatch Egg Error", "Invalid egg selection")
                        AutoHatchEggEnabled = false
                        eggSettingsFolder:SetToggle("AutoHatchEggToggle", false)
                        break
                    end
                    local ohString1 = eggName
                    local ohNumber2 = tonumber(SelectedHowMany)
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage").Events.GetRandomPet:InvokeServer(ohString1, ohNumber2)
                    end)
                    if not success then
                        notify("Auto Hatch Egg Error", "Failed to hatch egg: " .. tostring(err))
                        AutoHatchEggEnabled = false
                        eggSettingsFolder:SetToggle("AutoHatchEggToggle", false)
                        break
                    end
                    wait(0.1)
                end
            end)
        else
            if autoHatchEggThread then
                coroutine.close(autoHatchEggThread)
                autoHatchEggThread = nil
            end
            notify("Auto Hatch Egg Disabled", "Auto Hatch Egg has been stopped")
        end
    end
})

-- Inisialisasi UI
library:Init()

-- Notifikasi saat script selesai dimuat
notify("Script Loaded", "Paper Plane Simulator script has been loaded successfully!")