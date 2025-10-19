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

--[[
-- Fungsi untuk mendapatkan list plots
local function getPlotList()
    local plotList = {}
    local plotsFolder = workspace.Scripted:FindFirstChild("Plots")
    if plotsFolder then
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            table.insert(plotList, plot.Name)
        end
    end
    return plotList
end
local plotList = getPlotList()
local selectedPlot = plotList[1] or "1"
-- Dropdown untuk Plots
local PlotsDropdown = MainTab:CreateDropdown({
    Name = "Select Plot",
    Options = plotList,
    CurrentOption = selectedPlot,
    Flag = "PlotsDropdown",
    Callback = function(Option)
        selectedPlot = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Plot Selected",
            Content = "Selected Plot: " .. tostring(selectedPlot),
            Duration = 5
        })
    end
})
-- Variabel untuk Auto Click
local AutoClickEnabled = false
local autoClickThread = nil
-- Fungsi untuk mendapatkan current coin models di selected plot
local function getCoinsInPlot(plotName)
    local coins = {}
    local plotsFolder = workspace.Scripted:FindFirstChild("Plots")
    local plotFolder = plotsFolder and plotsFolder:FindFirstChild(plotName)
    if plotFolder then
        for _, coin in ipairs(plotFolder:GetChildren()) do
            if coin:IsA("Model") and coin.Name:match("^%x+$") and #coin.Name == 32 then
                table.insert(coins, coin)
            end
        end
    end
    return coins
end
-- Toggle untuk Auto Click
local AutoClickToggle = MainTab:CreateToggle({
    Name = "Auto Click",
    CurrentValue = false,
    Flag = "AutoClickToggle",
    Callback = function(Value)
        AutoClickEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Click Enabled",
                Content = "Started auto clicking coins in plot " .. selectedPlot,
                Duration = 5
            })
            autoClickThread = spawn(function()
                while AutoClickEnabled do
                    local coins = getCoinsInPlot(selectedPlot)
                    if #coins > 0 then
                        for _, coinModel in ipairs(coins) do
                            if not AutoClickEnabled then break end
                            while AutoClickEnabled and coinModel.Parent do
                                -- Click (BreakableClicked)
                                local ohNumber1 = tonumber(selectedPlot) or 1
                                local ohString2 = coinModel.Name
                                pcall(function()
                                    game:GetService("ReplicatedStorage").Packages.Knit.Services.FarmingService.RF.BreakableClicked:InvokeServer(ohNumber1, ohString2)
                                end)
                                wait(0.1)
                            end
                        end
                    else
                        Rayfield:Notify({
                            Title = "Auto Click Warning",
                            Content = "No coins found in plot " .. selectedPlot,
                            Duration = 5
                        })
                        wait(1)
                    end
                    wait(0.5) -- Delay loop utama
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Click Disabled",
                Content = "Auto Click has been stopped",
                Duration = 5
            })
        end
    end
})
]]

-- Membuat section Tree & Stone
local TreeStoneSection = MainTab:CreateSection("Tree & Stone Features")

-- Fungsi untuk mendapatkan list zones
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

-- Dropdown untuk Zone
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
            autoTreeThread = spawn(function()
                local player = game:GetService("Players").LocalPlayer
                local zonesFolder = workspace.__WORLD.MAP:FindFirstChild("Zones")
                while AutoTreeEnabled do
                    local zoneFolder = zonesFolder and zonesFolder:FindFirstChild(selectedZone)
                    local breakableTreesFolder = zoneFolder and zoneFolder.Assets:FindFirstChild("BREAKABLE_TREES")
                    if breakableTreesFolder then
                        for _, tree in ipairs(breakableTreesFolder:GetChildren()) do
                            if not AutoTreeEnabled then break end
                            if tree:IsA("Model") and tree.PrimaryPart then
                                -- Teleport player ke tree
                                local character = player.Character
                                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                                if rootPart then
                                    rootPart.CFrame = tree.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
                                end
                                -- Periksa PosId sebelum memanggil DamageTree
                                local posId = tree:GetAttribute("PosId")
                                if posId and posId ~= "" then
                                    -- Loop damage sampai hilang
                                    while AutoTreeEnabled and tree.Parent do
                                        local ohString1 = selectedZone
                                        local ohString2 = tostring(posId) -- Convert to string if needed
                                        local ohBoolean3 = true
                                        pcall(function()
                                            game:GetService("ReplicatedStorage").Packages.Knit.Services.FarmingService.RF.DamageTree:InvokeServer(ohString1, ohString2, ohBoolean3)
                                        end)
                                        wait(0.1)
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
                    wait(1) -- Delay loop utama
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
            autoMiningThread = spawn(function()
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
                                -- Teleport player ke ore
                                local character = player.Character
                                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                                if rootPart then
                                    rootPart.CFrame = ore.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
                                end
                                -- Periksa PosId sebelum memanggil DamageOre
                                local posId = ore:GetAttribute("PosId")
                                if posId and posId ~= "" then
                                    -- Loop damage sampai hilang
                                    while AutoMiningEnabled and ore.Parent do
                                        local ohString1 = selectedZone
                                        local ohString2 = tostring(posId) -- Convert to string if needed
                                        local ohNumber3 = 1
                                        pcall(function()
                                            DamageOre:InvokeServer(ohString1, ohString2, ohNumber3)
                                        end)
                                        wait(0.1)
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
                    wait(1) -- Delay loop utama
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
local FishSection = MainTab:CreateSection("Fish xx Features")

-- Fungsi untuk mendapatkan list zones
local function getZoneList()
    local zoneList = {}
    local fishFolder = game:GetService("ReplicatedStorage").Assets:FindFirstChild("Fish")
    if fishFolder then
        for _, zone in ipairs(fishFolder:GetChildren()) do
            if zone.Name ~= "NOT USED" then
                table.insert(zoneList, zone.Name)
            end
        end
    end
    return zoneList
end

local zoneList = getZoneList()
local selectedZone = zoneList[1] or "1"

-- Dropdown untuk Zone
local ZoneDropdown = MainTab:CreateDropdown({
    Name = "Select Zone",
    Options = zoneList,
    CurrentOption = selectedZone,
    Flag = "ZoneDropdownFish",  -- Ubah flag agar tidak konflik dengan dropdown sebelumnya
    Callback = function(Option)
        selectedZone = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Zone Selected",
            Content = "Selected Zone: " .. tostring(selectedZone),
            Duration = 5
        })
    end
})

-- Variabel untuk Auto Fish
local AutoFishEnabled = false
local autoFishThread = nil

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
                Content = "Started auto fishing in zone " .. selectedZone,
                Duration = 5
            })
            autoFishThread = spawn(function()
                local replicatedStorage = game:GetService("ReplicatedStorage")
                local workspace = game:GetService("Workspace")
                local fishFolder = replicatedStorage.Assets:FindFirstChild("Fish")
                local tempFolder = workspace:FindFirstChild("__TEMP")
                local targetFolder = workspace:GetChildren()[9]  -- Sesuai permintaan, workspace:GetChildren()[9]
                
                while AutoFishEnabled do
                    local zoneFolder = fishFolder and fishFolder:FindFirstChild(selectedZone)
                    if zoneFolder then
                        local tempContainer = tempFolder and tempFolder:GetChildren()[84]  -- Sesuai contoh [84]
                        if tempContainer then
                            for _, fish in ipairs(zoneFolder:GetChildren()) do
                                if not AutoFishEnabled then break end
                                local fishName = fish.Name
                                local fishBody = tempContainer:FindFirstChild(fishName .. " Body")
                                if fishBody then
                                    -- Pindahkan fish ke target
                                    fishBody.Parent = targetFolder
                                    Rayfield:Notify({
                                        Title = "Fish Caught",
                                        Content = "Moved " .. fishName .. " to target folder",
                                        Duration = 3
                                    })
                                else
                                    Rayfield:Notify({
                                        Title = "Auto Fish Warning",
                                        Content = "Fish body for " .. fishName .. " not found in __TEMP[84]",
                                        Duration = 5
                                    })
                                end
                                wait(0.1)  -- Delay per fish
                            end
                        else
                            Rayfield:Notify({
                                Title = "Auto Fish Warning",
                                Content = "No __TEMP[84] container found",
                                Duration = 5
                            })
                        end
                    else
                        Rayfield:Notify({
                            Title = "Auto Fish Warning",
                            Content = "No zone folder found for " .. selectedZone,
                            Duration = 5
                        })
                    end
                    wait(1)  -- Delay loop utama
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Fish Disabled",
                Content = "Auto Fish has been stopped",
                Duration = 5
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
            autoClaimGiftThread = spawn(function()
                local giftsFolder = game:GetService("Players").LocalPlayer.PlayerGui.FreeGifts.Frame.Playtime.Gifts
                while AutoClaimGiftEnabled do
                    for _, gift in ipairs(giftsFolder:GetChildren()) do
                        if AutoClaimGiftEnabled then
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
                    wait(1) -- Check setiap detik
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
            instantCatchFishThread = spawn(function()
                while InstantCatchFishEnabled do
                    local ohBoolean1 = true
                    local ohBoolean2 = true
                    pcall(function()
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.FarmingService.RF.CatchSequenceFinish:InvokeServer(ohBoolean1, ohBoolean2)
                    end)
                    wait(0.1)
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
            autoSpinThread = spawn(function()
                while AutoSpinEnabled do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.DataService.RF.StartWheelSpin:InvokeServer()
                    end)
                    wait(1)
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
            autoHatchThread = spawn(function()
                while AutoHatchEnabled do
                    if eggsFolder and eggsFolder:FindFirstChild(selectedEgg) then
                        -- Fungsi pertama: HatchEgg
                        local ohString1 = selectedEgg
                        local ohString2 = selectedHowMany
                        pcall(function()
                            game:GetService("ReplicatedStorage").Packages.Knit.Services.InventoryService.RF.HatchEgg:InvokeServer(ohString1, ohString2)
                        end)
                        -- Fungsi kedua: OnHatchFinish
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
                    wait(1)
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

--[[
-- Membuat tab Merchant
local MerchantTab = Window:CreateTab("Merchant")
-- Membuat section Merchant
local MerchantSection = MerchantTab:CreateSection("Merchant")
-- Fungsi untuk mendapatkan list merchant items
local function getMerchantList()
    local list = {"All Item"}
    local scrollingFrame = game:GetService("Players").LocalPlayer.PlayerGui.Merchant.Frame.MerchantTypes["1"].ScrollingFrame
    for _, template in ipairs(scrollingFrame:GetChildren()) do
        if template:IsA("Frame") and template:FindFirstChild("ItemName") and template:FindFirstChild("StockLeft") then
            local stockText = template.StockLeft.Text
            local itemText = template.ItemName.Text
            local stockNum = tonumber(stockText:match("%d+")) or 0
            if stockNum > 0 then
                table.insert(list, stockText .. " - " .. itemText)
            end
        end
    end
    return list
end
local merchantList = getMerchantList()
local selectedMerchants = {}
-- Dropdown untuk Merchant (multi)
local MerchantDropdown = MerchantTab:CreateDropdown({
    Name = "Select Merchant Item",
    Options = merchantList,
    CurrentOption = selectedMerchants,
    MultipleOptions = true,
    Flag = "MerchantDropdown",
    Callback = function(Option)
        selectedMerchants = (typeof(Option) == "table") and Option or {Option}
        Rayfield:Notify({
            Title = "Merchant Item Selected",
            Content = "Selected: " .. table.concat(selectedMerchants, ", "),
            Duration = 5
        })
    end
})
-- Button Refresh Merchant List
local RefreshMerchantButton = MerchantTab:CreateButton({
    Name = "Refresh Merchant List",
    Callback = function()
        merchantList = getMerchantList()
        MerchantDropdown:Refresh(merchantList, true)
        Rayfield:Notify({
            Title = "Merchant List Refreshed",
            Content = "Merchant list has been updated",
            Duration = 5
        })
    end
})
-- Dropdown untuk How Many
local howManyMerchantList = {"Purchase 1", "Purchase All"}
local selectedHowManyMerchant = howManyMerchantList[1]
local HowManyMerchantDropdown = MerchantTab:CreateDropdown({
    Name = "How Many",
    Options = howManyMerchantList,
    CurrentOption = selectedHowManyMerchant,
    Flag = "HowManyMerchantDropdown",
    Callback = function(Option)
        selectedHowManyMerchant = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "How Many Selected",
            Content = "Selected: " .. tostring(selectedHowManyMerchant),
            Duration = 5
        })
    end
})
-- Variabel untuk Auto Buy Merchant
local AutoBuyMerchantEnabled = false
local autoBuyMerchantThread = nil
-- Toggle untuk Auto Buy Merchant
local AutoBuyMerchantToggle = MerchantTab:CreateToggle({
    Name = "Auto Buy Merchant",
    CurrentValue = false,
    Flag = "AutoBuyMerchantToggle",
    Callback = function(Value)
        AutoBuyMerchantEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Buy Merchant Enabled",
                Content = "Started auto buying merchant items",
                Duration = 5
            })
            autoBuyMerchantThread = spawn(function()
                local ohString1 = "Basic"
                while AutoBuyMerchantEnabled do
                    local scrollingFrame = game:GetService("Players").LocalPlayer.PlayerGui.Merchant.Frame.MerchantTypes["1"].ScrollingFrame
                    local isAll = table.find(selectedMerchants, "All Item")
                    for id = 1467120, 1467140 do
                        if not AutoBuyMerchantEnabled then break end
                        local template = scrollingFrame:FindFirstChild(tostring(id)) or scrollingFrame:FindFirstChild(tostring(id - 1467124 + 19)) -- Attempt to find template by ID or adjusted
                        if template and template:IsA("Frame") and template:FindFirstChild("ItemName") and template:FindFirstChild("StockLeft") then
                            local stockText = template.StockLeft.Text
                            local itemText = template.ItemName.Text
                            local option = stockText .. " - " .. itemText
                            local stockNum = tonumber(stockText:match("%d+")) or 0
                            if stockNum > 0 and (isAll or table.find(selectedMerchants, option)) then
                                local ohNumber2 = id
                                local ohNumber3 = tonumber(template.Name) or id
                                local ok, err = pcall(function()
                                    if selectedHowManyMerchant == "Purchase All" then
                                        game:GetService("ReplicatedStorage").Packages.Knit.Services.DataService.RF.PurchaseMerchantItem:InvokeServer(ohString1, ohNumber2, ohNumber3, true)
                                    else
                                        game:GetService("ReplicatedStorage").Packages.Knit.Services.DataService.RF.PurchaseMerchantItem:InvokeServer(ohString1, ohNumber2, ohNumber3)
                                    end
                                end)
                                if not ok then
                                    Rayfield:Notify({
                                        Title = "Auto Buy Merchant Error",
                                        Content = "Failed to buy " .. itemText .. ": " .. tostring(err),
                                        Duration = 5
                                    })
                                end
                                wait(0.1) -- Delay lebih cepat
                            end
                        end
                    end
                    wait(0.5) -- Delay loop utama lebih cepat
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Buy Merchant Disabled",
                Content = "Auto Buy Merchant has been stopped",
                Duration = 5
            })
        end
    end
})
]]

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
        wait(1)
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
            spawn(function()
                while AutoRejoinEnabled do
                    local player = game:GetService("Players").LocalPlayer
                    local success, err = pcall(function()
                        return player.Character and player.Character.Parent ~= nil
                    end)
                    if not success or not player.Character or player.Character.Parent == nil then
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
                        wait(60)
                    end
                    wait(10)
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
local defaultPlayerSpeed = 16 -- Asumsi default WalkSpeed
local defaultPetSpeed = 16 -- Asumsi default untuk pets
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
            autoSpeedThread = spawn(function()
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
                    wait(0.1)
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
-- Aktifkan Anti AFK dan Auto Rejoin
AutoAntiAFKToggle:Set(true)
AutoRejoinToggle:Set(true)
Rayfield:Notify({
    Title = "Script Loaded",
    Content = gameName .. " script has been loaded successfully!",
    Duration = 5
})