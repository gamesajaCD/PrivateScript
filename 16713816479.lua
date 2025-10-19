-- Memuat library Rayfield dengan error handling
local Rayfield
local success, errorMsg = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success then
    warn("Failed to load Rayfield library: " .. tostring(errorMsg))
    return
end

-- Mendapatkan nama game secara otomatis
local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

-- Membuat jendela utama dengan judul otomatis
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
        FolderName = "PetQuestSaving",
        FileName = "PetQuestSaving"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = false
    },
    KeySystem = true,
    KeySettings = {
        Title = gameName .. " Key System",
        Subtitle = "Enter Your Key",
        Note = "Key In Description or Join discord.gg/WFjWKwBv8p",
        FileName = "PetQuestKey",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/vTu6rCev"}
    }
})

-- Membuat tab Main
local MainTab = Window:CreateTab("Main")

-- Membuat section Tree & Stone
local TreeStoneSection = MainTab:CreateSection("Tree & Stone Features")

-- Fungsi untuk mendapatkan list zones (Tree/Stone)
local function getZoneList()
    local zoneList = {}
    local zonesFolder = workspace.__WORLD.MAP:FindFirstChild("Zones")
    if zonesFolder then
        for _, zone in ipairs(zonesFolder:GetChildren()) do
            table.insert(zoneList, zone.Name)
        end
    end
    return zoneList
end

local zoneList = getZoneList()
local selectedZone = zoneList[1] or "1"

-- Dropdown untuk Zone (Tree/Stone)
local ZoneDropdown = MainTab:CreateDropdown({
    Name = "Select Zone",
    Options = zoneList,
    CurrentOption = selectedZone,
    Flag = "ZoneDropdown",
    Callback = function(Option)
        selectedZone = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Zone Selected",
            Content = "Selected Zone: " .. tostring(selectedZone),
            Duration = 5
        })
    end
})

-- Variabel untuk Auto Tree
local AutoTreeEnabled = false
local autoTreeThread = nil

-- Toggle untuk Auto Tree
local AutoTreeToggle = MainTab:CreateToggle({
    Name = "Auto Tree",
    CurrentValue = false,
    Flag = "AutoTreeToggle",
    Callback = function(Value)
        AutoTreeEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Tree Enabled",
                Content = "Started auto farming trees in zone " .. selectedZone,
                Duration = 5
            })
            autoTreeThread = task.spawn(function()
                local player = game:GetService("Players").LocalPlayer
                local zonesFolder = workspace.__WORLD.MAP:FindFirstChild("Zones")
                while AutoTreeEnabled do
                    local zoneFolder = zonesFolder and zonesFolder:FindFirstChild(selectedZone)
                    local breakableTreesFolder = zoneFolder and zoneFolder.Assets:FindFirstChild("BREAKABLE_TREES")
                    if breakableTreesFolder then
                        for _, tree in ipairs(breakableTreesFolder:GetChildren()) do
                            if not AutoTreeEnabled then break end
                            if tree:IsA("Model") and tree.PrimaryPart then
                                local character = player.Character
                                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                                if rootPart then
                                    rootPart.CFrame = tree.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
                                end
                                local posId = tree:GetAttribute("PosId")
                                if posId and posId ~= "" then
                                    while AutoTreeEnabled and tree.Parent do
                                        local ohString1 = selectedZone
                                        local ohString2 = tostring(posId)
                                        local ohBoolean3 = true
                                        pcall(function()
                                            game:GetService("ReplicatedStorage").Packages.Knit.Services.FarmingService.RF.DamageTree:InvokeServer(ohString1, ohString2, ohBoolean3)
                                        end)
                                        task.wait(0.1)
                                    end
                                else
                                    Rayfield:Notify({
                                        Title = "Auto Tree Warning",
                                        Content = "Tree in zone " .. selectedZone .. " is missing PosId",
                                        Duration = 5
                                    })
                                end
                            end
                        end
                    else
                        Rayfield:Notify({
                            Title = "Auto Tree Warning",
                            Content = "No BREAKABLE_TREES found in zone " .. selectedZone,
                            Duration = 5
                        })
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Tree Disabled",
                Content = "Auto Tree has been stopped",
                Duration = 5
            })
        end
    end
})

-- Variabel untuk Auto Mining
local AutoMiningEnabled = false
local autoMiningThread = nil

-- Toggle untuk Auto Mining
local AutoMiningToggle = MainTab:CreateToggle({
    Name = "Auto Mining",
    CurrentValue = false,
    Flag = "AutoMiningToggle",
    Callback = function(Value)
        AutoMiningEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Mining Enabled",
                Content = "Started auto mining ores in zone " .. selectedZone,
                Duration = 5
            })
            autoMiningThread = task.spawn(function()
                local player = game:GetService("Players").LocalPlayer
                local zonesFolder = workspace.__WORLD.MAP:FindFirstChild("Zones")
                local DamageOre = game:GetService("ReplicatedStorage").Packages.Knit.Services.FarmingService.RF.DamageOre
                while AutoMiningEnabled do
                    local zoneFolder = zonesFolder and zonesFolder:FindFirstChild(selectedZone)
                    local breakableOresFolder = zoneFolder and zoneFolder.Assets:FindFirstChild("BREAKABLE_ORES")
                    if breakableOresFolder then
                        for _, ore in ipairs(breakableOresFolder:GetChildren()) do
                            if not AutoMiningEnabled then break end
                            if ore:IsA("Model") and ore.PrimaryPart then
                                local character = player.Character
                                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                                if rootPart then
                                    rootPart.CFrame = ore.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
                                end
                                local posId = ore:GetAttribute("PosId")
                                if posId and posId ~= "" then
                                    while AutoMiningEnabled and ore.Parent do
                                        local ohString1 = selectedZone
                                        local ohString2 = tostring(posId)
                                        local ohNumber3 = 1
                                        pcall(function()
                                            DamageOre:InvokeServer(ohString1, ohString2, ohNumber3)
                                        end)
                                        task.wait(0.1)
                                    end
                                else
                                    Rayfield:Notify({
                                        Title = "Auto Mining Warning",
                                        Content = "Ore in zone " .. selectedZone .. " is missing PosId",
                                        Duration = 5
                                    })
                                end
                            end
                        end
                    else
                        Rayfield:Notify({
                            Title = "Auto Mining Warning",
                            Content = "No BREAKABLE_ORES found in zone " .. selectedZone,
                            Duration = 5
                        })
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Mining Disabled",
                Content = "Auto Mining has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat section Fish
local FishSection = MainTab:CreateSection("Fish Features")

-- Utils (Fish)
local function parseZoneIdFromName(name)
    if typeof(name) ~= "string" then return nil end
    local numStr = name:match("%d+")
    if numStr then return tonumber(numStr) end
    return tonumber(name)
end

local function getZoneData()
    local list = {}
    local nameToId = {}
    local RS = game:GetService("ReplicatedStorage")
    local assets = RS:FindFirstChild("Assets")
    local fishFolder = assets and assets:FindFirstChild("Fish")
    if fishFolder then
        for _, zone in ipairs(fishFolder:GetChildren()) do
            if zone.Name ~= "NOT USED" then
                table.insert(list, zone.Name)
                nameToId[zone.Name] = zone:GetAttribute("ZoneId") or parseZoneIdFromName(zone.Name)
            end
        end
    end
    return list, nameToId
end

local fishZoneList, zoneNameToId = getZoneData()
local selectedZoneName = fishZoneList[1] or "1"
local selectedZoneId = zoneNameToId[selectedZoneName] or parseZoneIdFromName(selectedZoneName) or 1

-- Dropdown untuk Zone (Fish)
local ZoneDropdownFish = MainTab:CreateDropdown({
    Name = "Select Zone (Fish)",
    Options = fishZoneList,
    CurrentOption = selectedZoneName,
    Flag = "ZoneDropdownFish",
    Callback = function(Option)
        selectedZoneName = (typeof(Option) == "table") and Option[1] or Option
        selectedZoneId = zoneNameToId[selectedZoneName] or parseZoneIdFromName(selectedZoneName) or 1
        -- REFRESH daftar ikan yang valid tiap zone berubah
        task.spawn(function()
            task.wait() -- kecil biar aman di thread UI
            local ok, err = pcall(function()
                local _ = selectedZoneId -- placeholder
            end)
            -- panggil refreshAllowedFishNames di luar error
        end)
        refreshAllowedFishNames()
        Rayfield:Notify({
            Title = "Zone Selected",
            Content = ("Selected Zone: %s (Id: %s)"):format(tostring(selectedZoneName), tostring(selectedZoneId)),
            Duration = 4
        })
    end
})

-- Variabel & helper (Fish)
local AutoFishEnabled = false
local autoFishThread = nil

local function getZoneFolderBySelection()
    local RS = game:GetService("ReplicatedStorage")
    local assets = RS:FindFirstChild("Assets")
    local fishFolder = assets and assets:FindFirstChild("Fish")
    if not fishFolder then return nil end
    if selectedZoneName then
        local z = fishFolder:FindFirstChild(selectedZoneName)
        if z then return z end
    end
    if selectedZoneId then
        for _, z in ipairs(fishFolder:GetChildren()) do
            if z.Name ~= "NOT USED" then
                local zid = z:GetAttribute("ZoneId") or parseZoneIdFromName(z.Name)
                if zid == selectedZoneId then
                    return z
                end
            end
        end
    end
    return nil
end

local allowedFishNamesSet = {}
local function refreshAllowedFishNames()
    table.clear(allowedFishNamesSet)
    local zoneFolder = getZoneFolderBySelection()
    if not zoneFolder then return end
    for _, fish in ipairs(zoneFolder:GetChildren()) do
        allowedFishNamesSet[fish.Name] = true
    end
end

-- Param lempar kail
local ohNumber1 = 0.9900000000000007
local ohVector32 = Vector3.new(-4068.049072265625, -6.796737194061279, -10.218384742736816)
local ohVector33 = Vector3.new(-4069.359130859375, -4.571030139923096, -8.79765510559082)
local ohVector34 = Vector3.new(-4077.1298828125, 2.1082305908203125, -1.9402313232421875)
local ohVector35 = Vector3.new(-4077.1298828125, -15.577600479125977, -1.9402313232421875)
local ohCFrame6 = CFrame.new(-4077.12964, -15.5775986, -1.94043732, 0.189035907, 0, 0.981970191, 0, 1, 0, -0.981970191, 0, 0.189035907)

-- Toggle untuk Auto Fish
local AutoFishToggle = MainTab:CreateToggle({
    Name = "Auto Fish",
    CurrentValue = false,
    Flag = "AutoFishToggle",
    Callback = function(Value)
        AutoFishEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Fish Enabled",
                Content = "Mulai auto fishing di zone " .. tostring(selectedZoneName) .. " (Id: " .. tostring(selectedZoneId) .. ")",
                Duration = 4
            })
            autoFishThread = task.spawn(function()
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local RS = game:GetService("ReplicatedStorage")
                local WS = game:GetService("Workspace")
                local fishPartsFolder = WS:FindFirstChild("Scripted") and WS.Scripted:FindFirstChild("FishParts")
                local castFishingRod = RS.Packages
                    and RS.Packages.Knit
                    and RS.Packages.Knit.Services
                    and RS.Packages.Knit.Services.FarmingService
                    and RS.Packages.Knit.Services.FarmingService.RF
                    and RS.Packages.Knit.Services.FarmingService.RF.CastFishingRod
                if not fishPartsFolder or not castFishingRod then
                    Rayfield:Notify({
                        Title = "Auto Fish Warning",
                        Content = "FishParts atau remote CastFishingRod tidak ditemukan.",
                        Duration = 5
                    })
                    return
                end
                refreshAllowedFishNames()
                while AutoFishEnabled do
                    local zoneFolder = getZoneFolderBySelection()
                    if zoneFolder and selectedZoneId then
                        pcall(function()
                            local ohNumber7 = selectedZoneId
                            castFishingRod:InvokeServer(ohNumber1, ohVector32, ohVector33, ohVector34, ohVector35, ohCFrame6, ohNumber7)
                        end)
                        task.wait(5)
                        for _, part in ipairs(fishPartsFolder:GetChildren()) do
                            if not AutoFishEnabled then break end
                            local fishName = part:GetAttribute("FishName")
                            local partZoneId = part:GetAttribute("ZoneId")
                            if fishName and partZoneId and allowedFishNamesSet[fishName] and partZoneId == selectedZoneId then
                                pcall(function()
                                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        local root = LocalPlayer.Character.HumanoidRootPart
                                        local targetCFrame = root.CFrame * CFrame.new(0, 0, -5)
                                        part.CFrame = targetCFrame
                                    end
                                end)
                                pcall(function()
                                    local ohNumber7 = selectedZoneId
                                    castFishingRod:InvokeServer(ohNumber1, ohVector32, ohVector33, ohVector34, ohVector35, ohCFrame6, ohNumber7)
                                end)
                                task.wait(0.1)
                            end
                        end
                    else
                        Rayfield:Notify({
                            Title = "Auto Fish Warning",
                            Content = "No zone folder found for " .. tostring(selectedZoneName),
                            Duration = 5
                        })
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Fish Disabled",
                Content = "Auto Fish dihentikan",
                Duration = 4
            })
        end
    end
})

-- Toggle untuk Uji Teleport Fish Spesifik
local TestTeleportEnabled = false
local TestTeleportToggle = MainTab:CreateToggle({
    Name = "Test Teleport Fish",
    CurrentValue = false,
    Flag = "TestTeleportToggle",
    Callback = function(Value)
        TestTeleportEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Test Teleport Enabled",
                Content = "Mencoba teleport fish spesifik",
                Duration = 4
            })
            task.spawn(function()
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local WS = game:GetService("Workspace")
                local fishPartsFolder = WS:FindFirstChild("Scripted") and WS.Scripted:FindFirstChild("FishParts")
                if not fishPartsFolder then
                    Rayfield:Notify({
                        Title = "Test Teleport Warning",
                        Content = "FishParts folder tidak ditemukan.",
                        Duration = 5
                    })
                    return
                end
                local specificFishName = "03617b563bc44f7ea4a6ef51fb2ef45b"
                local fishPart = fishPartsFolder:FindFirstChild(specificFishName)
                if not fishPart then
                    Rayfield:Notify({
                        Title = "Test Teleport Warning",
                        Content = "Fish part dengan nama " .. specificFishName .. " tidak ditemukan.",
                        Duration = 5
                    })
                    return
                end
                pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local root = LocalPlayer.Character.HumanoidRootPart
                        local targetCFrame = root.CFrame * CFrame.new(0, 0, -5)
                        fishPart.CFrame = targetCFrame
                        Rayfield:Notify({
                            Title = "Test Fish Teleported",
                            Content = "Teleported fish " .. specificFishName .. " to front of player",
                            Duration = 3
                        })
                    else
                        Rayfield:Notify({
                            Title = "Teleport Warning",
                            Content = "Player character or HumanoidRootPart not found.",
                            Duration = 3
                        })
                    end
                end)
            end)
        else
            Rayfield:Notify({
                Title = "Test Teleport Disabled",
                Content = "Uji teleport dihentikan",
                Duration = 4
            })
        end
    end
})

-- Variabel untuk Auto Claim Gift
local AutoClaimGiftEnabled = false
local autoClaimGiftThread = nil

-- Toggle untuk Auto Claim Gift
local AutoClaimGiftToggle = MainTab:CreateToggle({
    Name = "Auto Claim Gift",
    CurrentValue = false,
    Flag = "AutoClaimGiftToggle",
    Callback = function(Value)
        AutoClaimGiftEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Claim Gift Enabled",
                Content = "Started auto claiming gifts",
                Duration = 5
            })
            autoClaimGiftThread = task.spawn(function()
                while AutoClaimGiftEnabled do
                    local giftsFolder
                    pcall(function()
                        giftsFolder = game:GetService("Players").LocalPlayer.PlayerGui.FreeGifts.Frame.Playtime.Gifts
                    end)
                    if giftsFolder then
                        for _, gift in ipairs(giftsFolder:GetChildren()) do
                            if not AutoClaimGiftEnabled then break end
                            local timerLabel = gift:FindFirstChild("Timer")
                            if timerLabel and timerLabel.Text == "Claim!" then
                                local ohString1 = gift.Name
                                local ok, err = pcall(function()
                                    game:GetService("ReplicatedStorage").Packages.Knit.Services.DataService.RF.ClaimPlaytimeGift:InvokeServer(ohString1)
                                end)
                                if not ok then
                                    Rayfield:Notify({
                                        Title = "Auto Claim Gift Error",
                                        Content = "Failed to claim " .. gift.Name .. ": " .. tostring(err),
                                        Duration = 5
                                    })
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Claim Gift Disabled",
                Content = "Auto Claim Gift has been stopped",
                Duration = 5
            })
        end
    end
})

-- Variabel untuk Instant Catch Fish
local InstantCatchFishEnabled = false
local instantCatchFishThread = nil

-- Toggle untuk Instant Catch Fish
local InstantCatchFishToggle = MainTab:CreateToggle({
    Name = "Instant Catch Fish",
    CurrentValue = false,
    Flag = "InstantCatchFishToggle",
    Callback = function(Value)
        InstantCatchFishEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Instant Catch Fish Enabled",
                Content = "Started instant catching fish",
                Duration = 5
            })
            instantCatchFishThread = task.spawn(function()
                while InstantCatchFishEnabled do
                    local ohBoolean1 = true
                    local ohBoolean2 = true
                    pcall(function()
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.FarmingService.RF.CatchSequenceFinish:InvokeServer(ohBoolean1, ohBoolean2)
                    end)
                    task.wait(0.1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Instant Catch Fish Disabled",
                Content = "Instant Catch Fish has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat section Other
local OtherSection = MainTab:CreateSection("Other Features")

-- Variabel untuk Auto Spin
local AutoSpinEnabled = false
local autoSpinThread = nil

-- Toggle untuk Auto Spin
local AutoSpinToggle = MainTab:CreateToggle({
    Name = "Auto Spin",
    CurrentValue = false,
    Flag = "AutoSpinToggle",
    Callback = function(Value)
        AutoSpinEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Spin Enabled",
                Content = "Started auto spinning",
                Duration = 5
            })
            autoSpinThread = task.spawn(function()
                while AutoSpinEnabled do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.DataService.RF.StartWheelSpin:InvokeServer()
                    end)
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Spin Disabled",
                Content = "Auto Spin has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat tab Hatch
local HatchTab = Window:CreateTab("Hatch")

-- Fungsi untuk mendapatkan list eggs
local function getEggList()
    local eggList = {}
    local eggsFolder = workspace.Scripted:FindFirstChild("Eggs")
    if eggsFolder then
        for _, egg in ipairs(eggsFolder:GetChildren()) do
            table.insert(eggList, egg.Name)
        end
    end
    return eggList
end

local eggList = getEggList()
local selectedEgg = eggList[1] or "Basic Egg"

-- Dropdown untuk Egg
local EggDropdown = HatchTab:CreateDropdown({
    Name = "Select Egg",
    Options = eggList,
    CurrentOption = selectedEgg,
    Flag = "EggDropdown",
    Callback = function(Option)
        selectedEgg = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Egg Selected",
            Content = "Selected Egg: " .. tostring(selectedEgg),
            Duration = 5
        })
    end
})

-- Button Refresh Egg List
local RefreshEggButton = HatchTab:CreateButton({
    Name = "Refresh Egg List",
    Callback = function()
        eggList = getEggList()
        EggDropdown:Refresh(eggList, true)
        selectedEgg = eggList[1] or "Basic Egg"
        Rayfield:Notify({
            Title = "Egg List Refreshed",
            Content = "Egg list has been updated",
            Duration = 5
        })
    end
})

-- Dropdown untuk How Many
local howManyList = {"One", "Multi"}
local selectedHowMany = howManyList[1]
local HowManyDropdown = HatchTab:CreateDropdown({
    Name = "How Many",
    Options = howManyList,
    CurrentOption = selectedHowMany,
    Flag = "HowManyDropdown",
    Callback = function(Option)
        selectedHowMany = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "How Many Selected",
            Content = "Selected: " .. tostring(selectedHowMany),
            Duration = 5
        })
    end
})

-- Variabel untuk Auto Hatch
local AutoHatchEnabled = false
local autoHatchThread = nil

-- Toggle untuk Auto Hatch
local AutoHatchToggle = HatchTab:CreateToggle({
    Name = "Auto Hatch",
    CurrentValue = false,
    Flag = "AutoHatchToggle",
    Callback = function(Value)
        AutoHatchEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Hatch Enabled",
                Content = "Started auto hatching eggs",
                Duration = 5
            })
            -- Teleport player sekali ke egg yang dipilih
            local player = game:GetService("Players").LocalPlayer
            local eggsFolder = workspace.Scripted:FindFirstChild("Eggs")
            local eggModel = eggsFolder and eggsFolder:FindFirstChild(selectedEgg)
            if eggModel and eggModel.PrimaryPart then
                local character = player.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = eggModel.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
                end
            else
                Rayfield:Notify({
                    Title = "Teleport Warning",
                    Content = "Selected egg not found for teleport",
                    Duration = 5
                })
            end
            -- Mulai loop auto hatch tanpa teleport berulang
            autoHatchThread = task.spawn(function()
                while AutoHatchEnabled do
                    local eggsFolderNow = workspace.Scripted:FindFirstChild("Eggs")
                    if eggsFolderNow and eggsFolderNow:FindFirstChild(selectedEgg) then
                        local ohString1 = selectedEgg
                        local ohString2 = selectedHowMany
                        pcall(function()
                            game:GetService("ReplicatedStorage").Packages.Knit.Services.InventoryService.RF.HatchEgg:InvokeServer(ohString1, ohString2)
                        end)
                        pcall(function()
                            game:GetService("ReplicatedStorage").Packages.Knit.Services.InventoryService.RF.OnHatchFinish:InvokeServer()
                        end)
                    else
                        Rayfield:Notify({
                            Title = "Auto Hatch Warning",
                            Content = "Selected egg not found",
                            Duration = 5
                        })
                    end
                    task.wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Hatch Disabled",
                Content = "Auto Hatch has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat tab Setting
local SettingTab = Window:CreateTab("Setting")

-- Membuat section General Settings
local GeneralSettingsSection = SettingTab:CreateSection("General Settings")

-- Anti AFK
local AutoAntiAFKEnabled = true
local AutoAntiAFKToggle = SettingTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = true,
    Flag = "AntiAFKToggle",
    Callback = function(Value)
        AutoAntiAFKEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Anti AFK Enabled",
                Content = "Anti AFK system activated",
                Duration = 5
            })
        else
            Rayfield:Notify({
                Title = "Anti AFK Disabled",
                Content = "Anti AFK system stopped",
                Duration = 5
            })
        end
    end
})

-- Aktifkan Anti AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    if AutoAntiAFKEnabled then
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- Auto Rejoin
local AutoRejoinEnabled = true
local AutoRejoinToggle = SettingTab:CreateToggle({
    Name = "Auto Rejoin",
    CurrentValue = true,
    Flag = "AutoRejoinToggle",
    Callback = function(Value)
        AutoRejoinEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Rejoin Enabled",
                Content = "Auto rejoin on disconnect activated",
                Duration = 5
            })
            task.spawn(function()
                while AutoRejoinEnabled do
                    local player = game:GetService("Players").LocalPlayer
                    local ok, isAlive = pcall(function()
                        return player.Character and player.Character.Parent ~= nil
                    end)
                    if not ok or not isAlive then
                        Rayfield:Notify({
                            Title = "Auto Rejoin",
                            Content = "Detected disconnect, attempting to rejoin...",
                            Duration = 5
                        })
                        local teleportSuccess, teleportErr = pcall(function()
                            game:GetService("TeleportService"):Teleport(game.PlaceId, player)
                        end)
                        if not teleportSuccess then
                            Rayfield:Notify({
                                Title = "Auto Rejoin Error",
                                Content = "Failed to rejoin: " .. tostring(teleportErr),
                                Duration = 5
                            })
                        end
                        task.wait(60)
                    end
                    task.wait(10)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Rejoin Disabled",
                Content = "Auto rejoin stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat section Player
local PlayerSection = SettingTab:CreateSection("Player")

-- Variabel untuk Speed
local customSpeed = 50
local defaultPlayerSpeed = 16
local defaultPetSpeed = 16
local AutoSpeedEnabled = false
local autoSpeedThread = nil

-- Input untuk Speed
local SpeedInput = SettingTab:CreateInput({
    Name = "Speed",
    PlaceholderText = "Enter speed value",
    CurrentValue = tostring(customSpeed),
    Flag = "SpeedInput",
    Callback = function(Value)
        customSpeed = tonumber(Value) or 50
        Rayfield:Notify({
            Title = "Speed Updated",
            Content = "Speed set to " .. tostring(customSpeed),
            Duration = 5
        })
    end
})

-- Toggle untuk Activate Speed
local ActivateSpeedToggle = SettingTab:CreateToggle({
    Name = "Activate Speed",
    CurrentValue = false,
    Flag = "ActivateSpeedToggle",
    Callback = function(Value)
        AutoSpeedEnabled = Value
        local player = game:GetService("Players").LocalPlayer
        local activePetsFolder = workspace:FindFirstChild("ActivePets")
        local playerPetFolderName = tostring(player.UserId)
      
        if Value then
            Rayfield:Notify({
                Title = "Speed Activated",
                Content = "Speed set to " .. tostring(customSpeed),
                Duration = 5
            })
            autoSpeedThread = task.spawn(function()
                while AutoSpeedEnabled do
                    local character = player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = customSpeed
                    end
                  
                    if activePetsFolder then
                        local petFolder = activePetsFolder:FindFirstChild(playerPetFolderName)
                        if petFolder then
                            for _, petModel in ipairs(petFolder:GetChildren()) do
                                if petModel:IsA("Model") then
                                    local petHumanoid = petModel:FindFirstChildOfClass("Humanoid")
                                    if petHumanoid then
                                        petHumanoid.WalkSpeed = customSpeed
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
              
                -- Kembalikan ke default saat dimatikan
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = defaultPlayerSpeed
                    if activePetsFolder then
                        local petFolder = activePetsFolder:FindFirstChild(playerPetFolderName)
                        if petFolder then
                            for _, petModel in ipairs(petFolder:GetChildren()) do
                                if petModel:IsA("Model") then
                                    local petHumanoid = petModel:FindFirstChildOfClass("Humanoid")
                                    if petHumanoid then
                                        petHumanoid.WalkSpeed = defaultPetSpeed
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            Rayfield:Notify({
                Title = "Speed Deactivated",
                Content = "Speed returned to default",
                Duration = 5
            })
        end
    end
})

-- Aktifkan Anti AFK dan Auto Rejoin saat load
AutoAntiAFKToggle:Set(true)
AutoRejoinToggle:Set(true)

Rayfield:Notify({
    Title = "Script Loaded",
    Content = gameName .. " script has been loaded successfully!",
    Duration = 5
})