-- Memuat library Rayfield dengan error handling
local Rayfield
local success, errorMsg = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success then
    warn("Failed to load Rayfield library: " .. tostring(errorMsg))
    return
end
-- Services global
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
-- Mendapatkan nama game secara otomatis
local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
-- Fungsi untuk membersihkan instance script sebelumnya jika ada
local function cleanupPreviousScript()
    if _G.MyScriptWindow then
        pcall(function()
            _G.MyScriptWindow:Destroy()
        end)
        _G.MyScriptWindow = nil
    end
   
    -- Cancel semua threads yang sedang berjalan
    local threads = {
        _G.autoEnergyThread,
        _G.tpToFluxThread,
        _G.autoSurgeThread,
        _G.autoVoltageThread,
        _G.autoSurgeUpgradesThread,
        _G.autoCogUpgradesThread,
        _G.autoCloverUpgradesThread,
        _G.autoChipUpgradesThread,
        _G.autoVoltageUpgradesThread,
        _G.autoWoodUpgradesThread
    }
    for _, thread in ipairs(threads) do
        if thread then
            pcall(task.cancel, thread)
        end
    end
   
    -- Reset variabel global threads
    _G.autoEnergyThread = nil
    _G.tpToFluxThread = nil
    _G.autoSurgeThread = nil
    _G.autoVoltageThread = nil
    _G.autoSurgeUpgradesThread = nil
    _G.autoCogUpgradesThread = nil
    _G.autoCloverUpgradesThread = nil
    _G.autoChipUpgradesThread = nil
    _G.autoVoltageUpgradesThread = nil
    _G.autoWoodUpgradesThread = nil
   
    -- Reset flags enabled untuk menghentikan loop
    _G.AutoEnergyEnabled = false
    _G.TpToPrestigeEnabled = false
    _G.TpToFluxEnabled = false
    _G.AutoSurgeEnabled = false
    _G.AutoVoltageEnabled = false
    _G.AutoSurgeUpgradesEnabled = false
    _G.AutoCogUpgradesEnabled = false
    _G.AutoCloverUpgradesEnabled = false
    _G.AutoChipUpgradesEnabled = false
    _G.AutoVoltageUpgradesEnabled = false
    _G.AutoWoodUpgradesEnabled = false
   
    -- Disconnect event listeners jika ada
    if _G.MyScriptInputConnection then
        pcall(function()
            _G.MyScriptInputConnection:Disconnect()
        end)
        _G.MyScriptInputConnection = nil
    end
   
    -- Notify pembersihan
    if Rayfield then
        Rayfield:Notify({
            Title = "Script Cleanup",
            Content = "Previous script instance has been cleaned up.",
            Duration = 3
        })
    end
end
-- Jalankan cleanup sebelum memulai script baru
cleanupPreviousScript()
-- Inisialisasi variabel global untuk tracking
_G.AutoEnergyEnabled = false
_G.TpToPrestigeEnabled = false
_G.TpToFluxEnabled = false
_G.AutoSurgeEnabled = false
_G.AutoVoltageEnabled = false
_G.AutoSurgeUpgradesEnabled = false
_G.AutoCogUpgradesEnabled = false
_G.AutoCloverUpgradesEnabled = false
_G.AutoChipUpgradesEnabled = false
_G.AutoVoltageUpgradesEnabled = false
_G.AutoWoodUpgradesEnabled = false
-- Window
local Window = Rayfield:CreateWindow({
    Name = gameName,
    Icon = 0,
    LoadingTitle = gameName,
    LoadingSubtitle = "by ENZO-YT",
    Theme = "DarkBlue",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "EnergyIncrementalSaving",
        FileName = "EnergyIncrementalSaving"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = false
    },
    KeySystem = false,
    KeySettings = {
        Title = gameName .. " Key System",
        Subtitle = "Enter Your Key",
        Note = "Key In Description or Join discord.gg/WFjWKwBv8p",
        FileName = "EnergyIncrementalKey",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/vTu6rCev"}
    }
})
_G.MyScriptWindow = Window -- Simpan window ke global untuk cleanup nanti
-- Tab Main
local MainTab = Window:CreateTab("Main")
-- =========================
-- Auto Energy
-- =========================
local AutoEnergyToggle = MainTab:CreateToggle({
    Name = "Auto Energy",
    CurrentValue = false,
    Flag = "AutoEnergyToggle",
    Callback = function(Value)
        _G.AutoEnergyEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Energy Enabled",
                Content = "Started auto getting energy",
                Duration = 5
            })
            _G.autoEnergyThread = task.spawn(function()
                while _G.AutoEnergyEnabled do
                    pcall(function()
                        RS.Events.GetEnergy:FireServer()
                    end)
                    task.wait(0.001)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Energy Disabled",
                Content = "Auto Energy has been stopped",
                Duration = 5
            })
        end
    end
})
-- =========================
-- Section Prestige
-- =========================
MainTab:CreateSection("Prestige")
-- Tp To Prestige
local TpToPrestigeToggle = MainTab:CreateToggle({
    Name = "Tp To Prestige",
    CurrentValue = false,
    Flag = "TpToPrestigeToggle",
    Callback = function(Value)
        _G.TpToPrestigeEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Tp To Prestige Enabled",
                Content = "Teleporting to Prestige Button",
                Duration = 5
            })
            local char, hrp = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local prestigeHitbox = Workspace.Main and Workspace.Main.Prestige and Workspace.Main.Prestige.PrestigeButton and Workspace.Main.Prestige.PrestigeButton.Hitbox
            if char and hrp and prestigeHitbox then
                hrp.CFrame = prestigeHitbox.CFrame * CFrame.new(0, 5, 0)
            else
                Rayfield:Notify({
                    Title = "Teleport Warning",
                    Content = "Prestige Hitbox not found",
                    Duration = 5
                })
            end
        else
            Rayfield:Notify({
                Title = "Tp To Prestige Disabled",
                Content = "Teleport stopped",
                Duration = 5
            })
        end
    end
})
-- =========================
-- Section Flux
-- =========================
MainTab:CreateSection("Flux")
-- Dropdown Flux
local function getFluxList()
    local fluxList = {}
    local fluxFolder = Workspace.Main and Workspace.Main.Buttons and Workspace.Main.Buttons.Flux
    if fluxFolder then
        for _, flux in ipairs(fluxFolder:GetChildren()) do
            table.insert(fluxList, flux.Name)
        end
    end
    if #fluxList == 0 then
        fluxList = {"Default Flux"}
    end
    return fluxList
end
local fluxList = getFluxList()
local selectedFlux = fluxList[1]
local FluxDropdown = MainTab:CreateDropdown({
    Name = "Select Flux",
    Options = fluxList,
    CurrentOption = selectedFlux,
    Flag = "FluxDropdown",
    Callback = function(Option)
        selectedFlux = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Flux Selected",
            Content = "Selected Flux: " .. tostring(selectedFlux),
            Duration = 5
        })
    end
})
-- Tp To Flux
local TpToFluxToggle = MainTab:CreateToggle({
    Name = "Tp To Flux",
    CurrentValue = false,
    Flag = "TpToFluxToggle",
    Callback = function(Value)
        _G.TpToFluxEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Tp To Flux Enabled",
                Content = "Started checking and teleporting to Flux",
                Duration = 5
            })
            _G.tpToFluxThread = task.spawn(function()
                while _G.TpToFluxEnabled do
                    local energyValue = LocalPlayer.PlayerData and LocalPlayer.PlayerData.Energy and LocalPlayer.PlayerData.Energy.Value or 0
                    local fluxFolder = Workspace.Main and Workspace.Main.Buttons and Workspace.Main.Buttons.Flux
                    local selectedFluxItem = fluxFolder and fluxFolder:FindFirstChild(selectedFlux)
                    local costFrame = selectedFluxItem and selectedFluxItem.Hitbox and selectedFluxItem.Hitbox.ButtonOverlay and selectedFluxItem.Hitbox.ButtonOverlay.Frame and selectedFluxItem.Hitbox.ButtonOverlay.Frame.Cost
                    local costText = costFrame and costFrame.Text or "COST: 0 ENERGY"
                    local costNumber = tonumber(costText:match("COST: (%d+) ENERGY")) or 0
                    if energyValue >= costNumber then
                        local char, hrp = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local fluxHitbox = selectedFluxItem and selectedFluxItem.Hitbox
                        if char and hrp and fluxHitbox then
                            hrp.CFrame = fluxHitbox.CFrame * CFrame.new(0, 5, 0)
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Tp To Flux Disabled",
                Content = "Tp To Flux has been stopped",
                Duration = 5
            })
        end
    end
})
-- =========================
-- Section Surge
-- =========================
MainTab:CreateSection("Surge")
-- Dropdown Surge
local function getSurgeList()
    local surgeList = {}
    local surgeFolder = Workspace.Main and Workspace.Main.Buttons and Workspace.Main.Buttons.Surge
    if surgeFolder then
        for _, surge in ipairs(surgeFolder:GetChildren()) do
            table.insert(surgeList, surge.Name)
        end
    end
    if #surgeList == 0 then
        surgeList = {"Default Surge"}
    end
    return surgeList
end
local surgeList = getSurgeList()
local selectedSurge = surgeList[1]
local SurgeDropdown = MainTab:CreateDropdown({
    Name = "Select Surge",
    Options = surgeList,
    CurrentOption = selectedSurge,
    Flag = "SurgeDropdown",
    Callback = function(Option)
        selectedSurge = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Surge Selected",
            Content = "Selected Surge: " .. tostring(selectedSurge),
            Duration = 5
        })
    end
})
-- Auto Surge
local AutoSurgeToggle = MainTab:CreateToggle({
    Name = "Auto Surge",
    CurrentValue = false,
    Flag = "AutoSurgeToggle",
    Callback = function(Value)
        _G.AutoSurgeEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Surge Enabled",
                Content = "Started checking and teleporting to Surge",
                Duration = 5
            })
            _G.autoSurgeThread = task.spawn(function()
                while _G.AutoSurgeEnabled do
                    local energyValue = LocalPlayer.PlayerData and LocalPlayer.PlayerData.Energy and LocalPlayer.PlayerData.Energy.Value or 0
                    local surgeFolder = Workspace.Main and Workspace.Main.Buttons and Workspace.Main.Buttons.Surge
                    local selectedSurgeItem = surgeFolder and surgeFolder:FindFirstChild(selectedSurge)
                    local costFrame = selectedSurgeItem and selectedSurgeItem.Hitbox and selectedSurgeItem.Hitbox.ButtonOverlay and selectedSurgeItem.Hitbox.ButtonOverlay.Frame and selectedSurgeItem.Hitbox.ButtonOverlay.Frame.Cost
                    local costText = costFrame and costFrame.Text or "COST: 0 ENERGY"
                    local costNumber = tonumber(costText:match("COST: (%d+) ENERGY")) or 0
                    if energyValue >= costNumber then
                        local char, hrp = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local surgeHitbox = selectedSurgeItem and selectedSurgeItem.Hitbox
                        if char and hrp and surgeHitbox then
                            hrp.CFrame = surgeHitbox.CFrame * CFrame.new(0, 5, 0)
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Surge Disabled",
                Content = "Auto Surge has been stopped",
                Duration = 5
            })
        end
    end
})
-- =========================
-- Section Voltage
-- =========================
MainTab:CreateSection("Voltage")
-- Dropdown Voltage
local function getVoltageList()
    local voltageList = {}
    local voltageFolder = Workspace.Main and Workspace.Main.Buttons and Workspace.Main.Buttons.Voltage
    if voltageFolder then
        for _, voltage in ipairs(voltageFolder:GetChildren()) do
            table.insert(voltageList, voltage.Name)
        end
    end
    if #voltageList == 0 then
        voltageList = {"Default Voltage"}
    end
    return voltageList
end
local voltageList = getVoltageList()
local selectedVoltage = voltageList[1]
local VoltageDropdown = MainTab:CreateDropdown({
    Name = "Select Voltage",
    Options = voltageList,
    CurrentOption = selectedVoltage,
    Flag = "VoltageDropdown",
    Callback = function(Option)
        selectedVoltage = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Voltage Selected",
            Content = "Selected Voltage: " .. tostring(selectedVoltage),
            Duration = 5
        })
    end
})
-- Auto Voltage
local AutoVoltageToggle = MainTab:CreateToggle({
    Name = "Auto Voltage",
    CurrentValue = false,
    Flag = "AutoVoltageToggle",
    Callback = function(Value)
        _G.AutoVoltageEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Voltage Enabled",
                Content = "Started checking and teleporting to Voltage",
                Duration = 5
            })
            _G.autoVoltageThread = task.spawn(function()
                while _G.AutoVoltageEnabled do
                    local energyValue = LocalPlayer.PlayerData and LocalPlayer.PlayerData.Energy and LocalPlayer.PlayerData.Energy.Value or 0
                    local voltageFolder = Workspace.Main and Workspace.Main.Buttons and Workspace.Main.Buttons.Voltage
                    local selectedVoltageItem = voltageFolder and voltageFolder:FindFirstChild(selectedVoltage)
                    local costFrame = selectedVoltageItem and selectedVoltageItem.Hitbox and selectedVoltageItem.Hitbox.ButtonOverlay and selectedVoltageItem.Hitbox.ButtonOverlay.Frame and selectedVoltageItem.Hitbox.ButtonOverlay.Frame.Cost
                    local costText = costFrame and costFrame.Text or "COST: 0 ENERGY"
                    local costNumber = tonumber(costText:match("COST: (%d+) ENERGY")) or 0
                    if energyValue >= costNumber then
                        local char, hrp = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local voltageHitbox = selectedVoltageItem and selectedVoltageItem.Hitbox
                        if char and hrp and voltageHitbox then
                            hrp.CFrame = voltageHitbox.CFrame * CFrame.new(0, 5, 0)
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Voltage Disabled",
                Content = "Auto Voltage has been stopped",
                Duration = 5
            })
        end
    end
})
-- =========================
-- Tab Upgrade
-- =========================
local UpgradeTab = Window:CreateTab("Upgrade")
-- =========================
-- Section Surge Upgrades
-- =========================
UpgradeTab:CreateSection("Surge Upgrades")
-- Dropdown Surge Upgrades (Multi)
local function getSurgeUpgradesList()
    local upgradesList = {}
    local scroll = Workspace.Main and Workspace.Main.UpgradeBoards and Workspace.Main.UpgradeBoards.SurgeUpgrades and Workspace.Main.UpgradeBoards.SurgeUpgrades.SurfaceGui and Workspace.Main.UpgradeBoards.SurgeUpgrades.SurfaceGui.Upgrades and Workspace.Main.UpgradeBoards.SurgeUpgrades.SurfaceGui.Upgrades.Scroll
    if scroll then
        for _, frame in ipairs(scroll:GetChildren()) do
            if frame:IsA("Frame") then
                table.insert(upgradesList, frame.Name)
            end
        end
    end
    if #upgradesList == 0 then
        upgradesList = {"Default Upgrade"}
    end
    return upgradesList
end
local surgeUpgradesList = getSurgeUpgradesList()
local selectedSurgeUpgrades = {}
local SurgeUpgradesDropdown = UpgradeTab:CreateDropdown({
    Name = "Select Surge Upgrades",
    Options = surgeUpgradesList,
    CurrentOption = selectedSurgeUpgrades,
    MultipleOptions = true,
    Flag = "SurgeUpgradesDropdown",
    Callback = function(Option)
        selectedSurgeUpgrades = Option
        Rayfield:Notify({
            Title = "Surge Upgrades Selected",
            Content = "Selected: " .. table.concat(selectedSurgeUpgrades, ", "),
            Duration = 5
        })
    end
})
-- Dropdown Buy
local buyOptions = {"Buy Once", "Buy MAX"}
local selectedBuySurge = buyOptions[1]
local BuySurgeDropdown = UpgradeTab:CreateDropdown({
    Name = "Buy Mode",
    Options = buyOptions,
    CurrentOption = selectedBuySurge,
    Flag = "BuySurgeDropdown",
    Callback = function(Option)
        selectedBuySurge = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Buy Mode Selected",
            Content = "Selected: " .. tostring(selectedBuySurge),
            Duration = 5
        })
    end
})
-- Auto Surge Upgrades
local AutoSurgeUpgradesToggle = UpgradeTab:CreateToggle({
    Name = "Auto Surge Upgrades",
    CurrentValue = false,
    Flag = "AutoSurgeUpgradesToggle",
    Callback = function(Value)
        _G.AutoSurgeUpgradesEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Surge Upgrades Enabled",
                Content = "Started auto upgrading Surge",
                Duration = 5
            })
            _G.autoSurgeUpgradesThread = task.spawn(function()
                while _G.AutoSurgeUpgradesEnabled do
                    local ohString1 = "Upgrades"
                    local ohBoolean3 = (selectedBuySurge == "Buy MAX") and true or false
                    for _, upgrade in ipairs(selectedSurgeUpgrades) do
                        local ohString2 = "Surge_" .. upgrade
                        pcall(function()
                            RS.Events.ToServer:FireServer(ohString1, ohString2, ohBoolean3)
                        end)
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Surge Upgrades Disabled",
                Content = "Auto Surge Upgrades stopped",
                Duration = 5
            })
        end
    end
})
-- =========================
-- Section Cog Upgrades
-- =========================
UpgradeTab:CreateSection("Cog Upgrades")
-- Dropdown Cog Upgrades (Multi)
local function getCogUpgradesList()
    local upgradesList = {}
    local scroll = Workspace.Main and Workspace.Main.UpgradeBoards and Workspace.Main.UpgradeBoards.CogUpgrades and Workspace.Main.UpgradeBoards.CogUpgrades.SurfaceGui and Workspace.Main.UpgradeBoards.CogUpgrades.SurfaceGui.Upgrades and Workspace.Main.UpgradeBoards.CogUpgrades.SurfaceGui.Upgrades.Scroll
    if scroll then
        for _, frame in ipairs(scroll:GetChildren()) do
            if frame:IsA("Frame") then
                table.insert(upgradesList, frame.Name)
            end
        end
    end
    if #upgradesList == 0 then
        upgradesList = {"Default Upgrade"}
    end
    return upgradesList
end
local cogUpgradesList = getCogUpgradesList()
local selectedCogUpgrades = {}
local CogUpgradesDropdown = UpgradeTab:CreateDropdown({
    Name = "Select Cog Upgrades",
    Options = cogUpgradesList,
    CurrentOption = selectedCogUpgrades,
    MultipleOptions = true,
    Flag = "CogUpgradesDropdown",
    Callback = function(Option)
        selectedCogUpgrades = Option
        Rayfield:Notify({
            Title = "Cog Upgrades Selected",
            Content = "Selected: " .. table.concat(selectedCogUpgrades, ", "),
            Duration = 5
        })
    end
})
-- Dropdown Buy
local selectedBuyCog = buyOptions[1]
local BuyCogDropdown = UpgradeTab:CreateDropdown({
    Name = "Buy Mode",
    Options = buyOptions,
    CurrentOption = selectedBuyCog,
    Flag = "BuyCogDropdown",
    Callback = function(Option)
        selectedBuyCog = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Buy Mode Selected",
            Content = "Selected: " .. tostring(selectedBuyCog),
            Duration = 5
        })
    end
})
-- Auto Cog Upgrades
local AutoCogUpgradesToggle = UpgradeTab:CreateToggle({
    Name = "Auto Cog Upgrades",
    CurrentValue = false,
    Flag = "AutoCogUpgradesToggle",
    Callback = function(Value)
        _G.AutoCogUpgradesEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Cog Upgrades Enabled",
                Content = "Started auto upgrading Cog",
                Duration = 5
            })
            _G.autoCogUpgradesThread = task.spawn(function()
                while _G.AutoCogUpgradesEnabled do
                    local ohString1 = "Upgrades"
                    local ohBoolean3 = (selectedBuyCog == "Buy MAX") and true or false
                    for _, upgrade in ipairs(selectedCogUpgrades) do
                        local ohString2 = "Cog_" .. upgrade
                        pcall(function()
                            RS.Events.ToServer:FireServer(ohString1, ohString2, ohBoolean3)
                        end)
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Cog Upgrades Disabled",
                Content = "Auto Cog Upgrades stopped",
                Duration = 5
            })
        end
    end
})
-- =========================
-- Section Clover Upgrades
-- =========================
UpgradeTab:CreateSection("Clover Upgrades")
-- Dropdown Clover Upgrades (Multi)
local function getCloverUpgradesList()
    local upgradesList = {}
    local scroll = Workspace.Main and Workspace.Main.UpgradeBoards and Workspace.Main.UpgradeBoards.CloverUpgrades and Workspace.Main.UpgradeBoards.CloverUpgrades.SurfaceGui and Workspace.Main.UpgradeBoards.CloverUpgrades.SurfaceGui.Upgrades and Workspace.Main.UpgradeBoards.CloverUpgrades.SurfaceGui.Upgrades.Scroll
    if scroll then
        for _, frame in ipairs(scroll:GetChildren()) do
            if frame:IsA("Frame") then
                table.insert(upgradesList, frame.Name)
            end
        end
    end
    if #upgradesList == 0 then
        upgradesList = {"Default Upgrade"}
    end
    return upgradesList
end
local cloverUpgradesList = getCloverUpgradesList()
local selectedCloverUpgrades = {}
local CloverUpgradesDropdown = UpgradeTab:CreateDropdown({
    Name = "Select Clover Upgrades",
    Options = cloverUpgradesList,
    CurrentOption = selectedCloverUpgrades,
    MultipleOptions = true,
    Flag = "CloverUpgradesDropdown",
    Callback = function(Option)
        selectedCloverUpgrades = Option
        Rayfield:Notify({
            Title = "Clover Upgrades Selected",
            Content = "Selected: " .. table.concat(selectedCloverUpgrades, ", "),
            Duration = 5
        })
    end
})
-- Dropdown Buy
local selectedBuyClover = buyOptions[1]
local BuyCloverDropdown = UpgradeTab:CreateDropdown({
    Name = "Buy Mode",
    Options = buyOptions,
    CurrentOption = selectedBuyClover,
    Flag = "BuyCloverDropdown",
    Callback = function(Option)
        selectedBuyClover = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Buy Mode Selected",
            Content = "Selected: " .. tostring(selectedBuyClover),
            Duration = 5
        })
    end
})
-- Auto Clover Upgrades
local AutoCloverUpgradesToggle = UpgradeTab:CreateToggle({
    Name = "Auto Clover Upgrades",
    CurrentValue = false,
    Flag = "AutoCloverUpgradesToggle",
    Callback = function(Value)
        _G.AutoCloverUpgradesEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Clover Upgrades Enabled",
                Content = "Started auto upgrading Clover",
                Duration = 5
            })
            _G.autoCloverUpgradesThread = task.spawn(function()
                while _G.AutoCloverUpgradesEnabled do
                    local ohString1 = "Upgrades"
                    local ohBoolean3 = (selectedBuyClover == "Buy MAX") and true or false
                    for _, upgrade in ipairs(selectedCloverUpgrades) do
                        local ohString2 = "Clover_" .. upgrade
                        pcall(function()
                            RS.Events.ToServer:FireServer(ohString1, ohString2, ohBoolean3)
                        end)
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Clover Upgrades Disabled",
                Content = "Auto Clover Upgrades stopped",
                Duration = 5
            })
        end
    end
})
-- =========================
-- Section Chip Upgrades
-- =========================
UpgradeTab:CreateSection("Chip Upgrades")
-- Dropdown Chip Upgrades (Multi)
local function getChipUpgradesList()
    local upgradesList = {}
    local scroll = Workspace.Main and Workspace.Main.UpgradeBoards and Workspace.Main.UpgradeBoards.ChipUpgrades and Workspace.Main.UpgradeBoards.ChipUpgrades.SurfaceGui and Workspace.Main.UpgradeBoards.ChipUpgrades.SurfaceGui.Upgrades and Workspace.Main.UpgradeBoards.ChipUpgrades.SurfaceGui.Upgrades.Scroll
    if scroll then
        for _, frame in ipairs(scroll:GetChildren()) do
            if frame:IsA("Frame") then
                table.insert(upgradesList, frame.Name)
            end
        end
    end
    if #upgradesList == 0 then
        upgradesList = {"Default Upgrade"}
    end
    return upgradesList
end
local chipUpgradesList = getChipUpgradesList()
local selectedChipUpgrades = {}
local ChipUpgradesDropdown = UpgradeTab:CreateDropdown({
    Name = "Select Chip Upgrades",
    Options = chipUpgradesList,
    CurrentOption = selectedChipUpgrades,
    MultipleOptions = true,
    Flag = "ChipUpgradesDropdown",
    Callback = function(Option)
        selectedChipUpgrades = Option
        Rayfield:Notify({
            Title = "Chip Upgrades Selected",
            Content = "Selected: " .. table.concat(selectedChipUpgrades, ", "),
            Duration = 5
        })
    end
})
-- Dropdown Buy
local selectedBuyChip = buyOptions[1]
local BuyChipDropdown = UpgradeTab:CreateDropdown({
    Name = "Buy Mode",
    Options = buyOptions,
    CurrentOption = selectedBuyChip,
    Flag = "BuyChipDropdown",
    Callback = function(Option)
        selectedBuyChip = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Buy Mode Selected",
            Content = "Selected: " .. tostring(selectedBuyChip),
            Duration = 5
        })
    end
})
-- Auto Chip Upgrades
local AutoChipUpgradesToggle = UpgradeTab:CreateToggle({
    Name = "Auto Chip Upgrades",
    CurrentValue = false,
    Flag = "AutoChipUpgradesToggle",
    Callback = function(Value)
        _G.AutoChipUpgradesEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Chip Upgrades Enabled",
                Content = "Started auto upgrading Chip",
                Duration = 5
            })
            _G.autoChipUpgradesThread = task.spawn(function()
                while _G.AutoChipUpgradesEnabled do
                    local ohString1 = "Upgrades"
                    local ohBoolean3 = (selectedBuyChip == "Buy MAX") and true or false
                    for _, upgrade in ipairs(selectedChipUpgrades) do
                        local ohString2 = "Chip_" .. upgrade
                        pcall(function()
                            RS.Events.ToServer:FireServer(ohString1, ohString2, ohBoolean3)
                        end)
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Chip Upgrades Disabled",
                Content = "Auto Chip Upgrades stopped",
                Duration = 5
            })
        end
    end
})
-- =========================
-- Section Voltage Upgrades
-- =========================
UpgradeTab:CreateSection("Voltage Upgrades")
-- Dropdown Voltage Upgrades (Multi)
local function getVoltageUpgradesList()
    local upgradesList = {}
    local scroll = Workspace.Main and Workspace.Main.UpgradeBoards and Workspace.Main.UpgradeBoards.VoltageUpgrades and Workspace.Main.UpgradeBoards.VoltageUpgrades.SurfaceGui and Workspace.Main.UpgradeBoards.VoltageUpgrades.SurfaceGui.Upgrades and Workspace.Main.UpgradeBoards.VoltageUpgrades.SurfaceGui.Upgrades.Scroll
    if scroll then
        for _, frame in ipairs(scroll:GetChildren()) do
            if frame:IsA("Frame") then
                table.insert(upgradesList, frame.Name)
            end
        end
    end
    if #upgradesList == 0 then
        upgradesList = {"Default Upgrade"}
    end
    return upgradesList
end
local voltageUpgradesList = getVoltageUpgradesList()
local selectedVoltageUpgrades = {}
local VoltageUpgradesDropdown = UpgradeTab:CreateDropdown({
    Name = "Select Voltage Upgrades",
    Options = voltageUpgradesList,
    CurrentOption = selectedVoltageUpgrades,
    MultipleOptions = true,
    Flag = "VoltageUpgradesDropdown",
    Callback = function(Option)
        selectedVoltageUpgrades = Option
        Rayfield:Notify({
            Title = "Voltage Upgrades Selected",
            Content = "Selected: " .. table.concat(selectedVoltageUpgrades, ", "),
            Duration = 5
        })
    end
})
-- Dropdown Buy
local selectedBuyVoltage = buyOptions[1]
local BuyVoltageDropdown = UpgradeTab:CreateDropdown({
    Name = "Buy Mode",
    Options = buyOptions,
    CurrentOption = selectedBuyVoltage,
    Flag = "BuyVoltageDropdown",
    Callback = function(Option)
        selectedBuyVoltage = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Buy Mode Selected",
            Content = "Selected: " .. tostring(selectedBuyVoltage),
            Duration = 5
        })
    end
})
-- Auto Voltage Upgrades
local AutoVoltageUpgradesToggle = UpgradeTab:CreateToggle({
    Name = "Auto Voltage Upgrades",
    CurrentValue = false,
    Flag = "AutoVoltageUpgradesToggle",
    Callback = function(Value)
        _G.AutoVoltageUpgradesEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Voltage Upgrades Enabled",
                Content = "Started auto upgrading Voltage",
                Duration = 5
            })
            _G.autoVoltageUpgradesThread = task.spawn(function()
                while _G.AutoVoltageUpgradesEnabled do
                    local ohString1 = "Upgrades"
                    local ohBoolean3 = (selectedBuyVoltage == "Buy MAX") and true or false
                    for _, upgrade in ipairs(selectedVoltageUpgrades) do
                        local ohString2 = "Voltage_" .. upgrade
                        pcall(function()
                            RS.Events.ToServer:FireServer(ohString1, ohString2, ohBoolean3)
                        end)
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Voltage Upgrades Disabled",
                Content = "Auto Voltage Upgrades stopped",
                Duration = 5
            })
        end
    end
})
-- =========================
-- Section Wood Upgrades
-- =========================
UpgradeTab:CreateSection("Wood Upgrades")
-- Dropdown Wood Upgrades (Multi)
local function getWoodUpgradesList()
    local upgradesList = {}
    local scroll = Workspace.Main and Workspace.Main.UpgradeBoards and Workspace.Main.UpgradeBoards.WoodUpgrades and Workspace.Main.UpgradeBoards.WoodUpgrades.SurfaceGui and Workspace.Main.UpgradeBoards.WoodUpgrades.SurfaceGui.Upgrades and Workspace.Main.UpgradeBoards.WoodUpgrades.SurfaceGui.Upgrades.Scroll
    if scroll then
        for _, frame in ipairs(scroll:GetChildren()) do
            if frame:IsA("Frame") then
                table.insert(upgradesList, frame.Name)
            end
        end
    end
    if #upgradesList == 0 then
        upgradesList = {"Default Upgrade"}
    end
    return upgradesList
end
local woodUpgradesList = getWoodUpgradesList()
local selectedWoodUpgrades = {}
local WoodUpgradesDropdown = UpgradeTab:CreateDropdown({
    Name = "Select Wood Upgrades",
    Options = woodUpgradesList,
    CurrentOption = selectedWoodUpgrades,
    MultipleOptions = true,
    Flag = "WoodUpgradesDropdown",
    Callback = function(Option)
        selectedWoodUpgrades = Option
        Rayfield:Notify({
            Title = "Wood Upgrades Selected",
            Content = "Selected: " .. table.concat(selectedWoodUpgrades, ", "),
            Duration = 5
        })
    end
})
-- Dropdown Buy
local selectedBuyWood = buyOptions[1]
local BuyWoodDropdown = UpgradeTab:CreateDropdown({
    Name = "Buy Mode",
    Options = buyOptions,
    CurrentOption = selectedBuyWood,
    Flag = "BuyWoodDropdown",
    Callback = function(Option)
        selectedBuyWood = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Buy Mode Selected",
            Content = "Selected: " .. tostring(selectedBuyWood),
            Duration = 5
        })
    end
})
-- Auto Wood Upgrades
local AutoWoodUpgradesToggle = UpgradeTab:CreateToggle({
    Name = "Auto Wood Upgrades",
    CurrentValue = false,
    Flag = "AutoWoodUpgradesToggle",
    Callback = function(Value)
        _G.AutoWoodUpgradesEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Wood Upgrades Enabled",
                Content = "Started auto upgrading Wood",
                Duration = 5
            })
            _G.autoWoodUpgradesThread = task.spawn(function()
                while _G.AutoWoodUpgradesEnabled do
                    local ohString1 = "Upgrades"
                    local ohBoolean3 = (selectedBuyWood == "Buy MAX") and true or false
                    for _, upgrade in ipairs(selectedWoodUpgrades) do
                        local ohString2 = "Wood_" .. upgrade
                        pcall(function()
                            RS.Events.ToServer:FireServer(ohString1, ohString2, ohBoolean3)
                        end)
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Wood Upgrades Disabled",
                Content = "Auto Wood Upgrades stopped",
                Duration = 5
            })
        end
    end
})
-- Load saved configuration
Rayfield:LoadConfiguration()
-- Manually trigger callbacks for loaded values to start functions if enabled
local elements = {
    {elem = AutoEnergyToggle, type = "toggle"},
    {elem = TpToPrestigeToggle, type = "toggle"},
    {elem = FluxDropdown, type = "dropdown"},
    {elem = TpToFluxToggle, type = "toggle"},
    {elem = SurgeDropdown, type = "dropdown"},
    {elem = AutoSurgeToggle, type = "toggle"},
    {elem = VoltageDropdown, type = "dropdown"},
    {elem = AutoVoltageToggle, type = "toggle"},
    {elem = SurgeUpgradesDropdown, type = "dropdown"},
    {elem = BuySurgeDropdown, type = "dropdown"},
    {elem = AutoSurgeUpgradesToggle, type = "toggle"},
    {elem = CogUpgradesDropdown, type = "dropdown"},
    {elem = BuyCogDropdown, type = "dropdown"},
    {elem = AutoCogUpgradesToggle, type = "toggle"},
    {elem = CloverUpgradesDropdown, type = "dropdown"},
    {elem = BuyCloverDropdown, type = "dropdown"},
    {elem = AutoCloverUpgradesToggle, type = "toggle"},
    {elem = ChipUpgradesDropdown, type = "dropdown"},
    {elem = BuyChipDropdown, type = "dropdown"},
    {elem = AutoChipUpgradesToggle, type = "toggle"},
    {elem = VoltageUpgradesDropdown, type = "dropdown"},
    {elem = BuyVoltageDropdown, type = "dropdown"},
    {elem = AutoVoltageUpgradesToggle, type = "toggle"},
    {elem = WoodUpgradesDropdown, type = "dropdown"},
    {elem = BuyWoodDropdown, type = "dropdown"},
    {elem = AutoWoodUpgradesToggle, type = "toggle"}
}
for _, item in ipairs(elements) do
    local elem = item.elem
    if elem and elem.Callback then
        if item.type == "toggle" then
            if elem.CurrentValue then
                elem.Callback(true)
            end
        elseif item.type == "dropdown" then
            elem.Callback(elem.CurrentOption)
        end
    end
end
Rayfield:Notify({
    Title = "Script Loaded",
    Content = gameName .. " script has been loaded successfully!",
    Duration = 5
})