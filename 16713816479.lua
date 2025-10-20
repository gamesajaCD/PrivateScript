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

-- =========================
-- Tree & Stone Features
-- =========================
local TreeStoneSection = MainTab:CreateSection("Tree & Stone Features")

-- Ambil list Zone dari workspace
local function getTreeZoneList()
    local zoneList = {}
    local zonesFolder = workspace.__WORLD and workspace.__WORLD.MAP and workspace.__WORLD.MAP:FindFirstChild("Zones")
    if zonesFolder then
        for _, zone in ipairs(zonesFolder:GetChildren()) do
            table.insert(zoneList, zone.Name)
        end
    end
    if #zoneList == 0 then
        zoneList = {"1"} -- fallback
    end
    return zoneList
end

local treeZoneList = getTreeZoneList()
local selectedTreeZone = treeZoneList[1] or "1"

-- Dropdown untuk Zone (Tree/Stone)
local TreeZoneDropdown = MainTab:CreateDropdown({
    Name = "Select Zone",
    Options = treeZoneList,
    CurrentOption = selectedTreeZone,
    Flag = "ZoneDropdown_TreeStone",
    Callback = function(Option)
        selectedTreeZone = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Zone Selected",
            Content = "Selected Zone: " .. tostring(selectedTreeZone),
            Duration = 4
        })
    end
})

-- =========================
-- Utils
-- =========================
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Remote untuk “klik” breakable (agar drop keluar)
local function getBreakableClickedRemote()
    local Packages = RS:FindFirstChild("Packages")
    local Knit = Packages and Packages:FindFirstChild("Knit")
    local Services = Knit and Knit:FindFirstChild("Services")
    local FarmingService = Services and Services:FindFirstChild("FarmingService")
    local RF = FarmingService and FarmingService:FindFirstChild("RF")
    local Remote = RF and RF:FindFirstChild("BreakableClicked")
    if not Remote then
        -- coba tunggu jika belum replicate
        local ok
        ok, Remote = pcall(function()
            local p = RS:WaitForChild("Packages", 5)
            local k = p and p:WaitForChild("Knit", 5)
            local s = k and k:WaitForChild("Services", 5)
            local f = s and s:WaitForChild("FarmingService", 5)
            local rf = f and f:WaitForChild("RF", 5)
            return rf and rf:WaitForChild("BreakableClicked", 5)
        end)
    end
    return Remote
end

-- Ambil angka zone dari nama "1" / "Zone 2" / dll
local function toZoneNumber(z)
    if type(z) == "number" then return z end
    local s = tostring(z or "")
    local num = s:match("%d+")
    return tonumber(num) or 1
end

-- Ambil ID unik breakable (prioritas PosId; fallback ke Name hex 32; lalu Name)
local function getBreakableId(model)
    if not model then return nil end
    local pid = model:GetAttribute("PosId")
    if pid and pid ~= "" then
        return tostring(pid)
    end
    if model.Name and model.Name:match("^%x+$") and #model.Name == 32 then
        return model.Name
    end
    return model.Name
end

-- Teleport aman ke atas target model
local function tpToModel(model, yOffset)
    yOffset = yOffset or 5
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not (root and model) then return end
    local pivotCF
    local ok = pcall(function()
        pivotCF = model:GetPivot()
    end)
    if ok and pivotCF then
        root.CFrame = pivotCF * CFrame.new(0, yOffset, 0)
    elseif model.PrimaryPart then
        root.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, yOffset, 0)
    else
        local anyPart = model:FindFirstChildWhichIsA("BasePart", true)
        if anyPart then
            root.CFrame = anyPart.CFrame * CFrame.new(0, yOffset, 0)
        end
    end
end

-- =========================
-- Auto Tree
-- =========================
local AutoTreeEnabled = false
local autoTreeThread = nil

local AutoTreeToggle = MainTab:CreateToggle({
    Name = "Auto Tree",
    CurrentValue = false,
    Flag = "AutoTreeToggle",
    Callback = function(Value)
        AutoTreeEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Tree Enabled",
                Content = "Menggunakan BreakableClicked agar drop keluar",
                Duration = 5
            })
            autoTreeThread = task.spawn(function()
                local zonesFolder = workspace.__WORLD and workspace.__WORLD.MAP and workspace.__WORLD.MAP:FindFirstChild("Zones")
                while AutoTreeEnabled do
                    local zoneName = selectedTreeZone or "1"
                    local zoneNum = toZoneNumber(zoneName)
                    local zoneFolder = zonesFolder and zonesFolder:FindFirstChild(tostring(zoneName))
                    local treesFolder = zoneFolder and zoneFolder.Assets and zoneFolder.Assets:FindFirstChild("BREAKABLE_TREES")
                    local BreakableClicked = getBreakableClickedRemote()

                    if BreakableClicked and treesFolder then
                        for _, tree in ipairs(treesFolder:GetChildren()) do
                            if not AutoTreeEnabled then break end
                            if tree:IsA("Model") then
                                tpToModel(tree, 5)
                                local bid = getBreakableId(tree)
                                if bid then
                                    while AutoTreeEnabled and tree.Parent do
                                        pcall(function()
                                            BreakableClicked:InvokeServer(zoneNum, tostring(bid))
                                        end)
                                        task.wait(0.08) -- rate “klik” (tuning sesuai kebutuhan)
                                    end
                                end
                            end
                        end
                    else
                        if not BreakableClicked then
                            Rayfield:Notify({
                                Title = "Auto Tree Warning",
                                Content = "Remote BreakableClicked tidak ditemukan.",
                                Duration = 4
                            })
                        else
                            Rayfield:Notify({
                                Title = "Auto Tree Warning",
                                Content = "BREAKABLE_TREES tidak ditemukan di zone " .. tostring(zoneName),
                                Duration = 4
                            })
                        end
                        task.wait(1)
                    end
                    task.wait(0.2)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Tree Disabled",
                Content = "Auto Tree dimatikan",
                Duration = 4
            })
        end
    end
})

-- =========================
-- Auto Mining
-- =========================
local AutoMiningEnabled = false
local autoMiningThread = nil

local AutoMiningToggle = MainTab:CreateToggle({
    Name = "Auto Mining",
    CurrentValue = false,
    Flag = "AutoMiningToggle",
    Callback = function(Value)
        AutoMiningEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Mining Enabled",
                Content = "Menggunakan BreakableClicked agar drop keluar",
                Duration = 5
            })
            autoMiningThread = task.spawn(function()
                local zonesFolder = workspace.__WORLD and workspace.__WORLD.MAP and workspace.__WORLD.MAP:FindFirstChild("Zones")
                while AutoMiningEnabled do
                    local zoneName = selectedTreeZone or "1"
                    local zoneNum = toZoneNumber(zoneName)
                    local zoneFolder = zonesFolder and zonesFolder:FindFirstChild(tostring(zoneName))
                    local oresFolder = zoneFolder and zoneFolder.Assets and zoneFolder.Assets:FindFirstChild("BREAKABLE_ORES")
                    local BreakableClicked = getBreakableClickedRemote()

                    if BreakableClicked and oresFolder then
                        for _, ore in ipairs(oresFolder:GetChildren()) do
                            if not AutoMiningEnabled then break end
                            if ore:IsA("Model") then
                                tpToModel(ore, 5)
                                local bid = getBreakableId(ore)
                                if bid then
                                    while AutoMiningEnabled and ore.Parent do
                                        pcall(function()
                                            BreakableClicked:InvokeServer(zoneNum, tostring(bid))
                                        end)
                                        task.wait(0.08) -- rate “klik”
                                    end
                                end
                            end
                        end
                    else
                        if not BreakableClicked then
                            Rayfield:Notify({
                                Title = "Auto Mining Warning",
                                Content = "Remote BreakableClicked tidak ditemukan.",
                                Duration = 4
                            })
                        else
                            Rayfield:Notify({
                                Title = "Auto Mining Warning",
                                Content = "BREAKABLE_ORES tidak ditemukan di zone " .. tostring(zoneName),
                                Duration = 4
                            })
                        end
                        task.wait(1)
                    end
                    task.wait(0.2)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Mining Disabled",
                Content = "Auto Mining dimatikan",
                Duration = 4
            })
        end
    end
})

-- =========================
-- Fish Features
-- =========================
local FishSection = MainTab:CreateSection("Fish Features")

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Ambil daftar zone mancing dari ReplicatedStorage.Assets.Fish
local function getFishZones()
    local options, labelToId = {}, {}
    local assets = RS:FindFirstChild("Assets")
    local fishFolder = assets and assets:FindFirstChild("Fish")
    if fishFolder then
        for _, zone in ipairs(fishFolder:GetChildren()) do
            if zone.Name ~= "NOT USED" then
                local zid = zone:GetAttribute("ZoneId") or tonumber(zone.Name:match("%d+")) or tonumber(zone.Name)
                if zid then
                    local label = ("Zone %d"):format(zid)
                    if not labelToId[label] then
                        labelToId[label] = zid
                        table.insert(options, label)
                    end
                end
            end
        end
    end
    table.sort(options, function(a, b)
        local ai = labelToId[a] or math.huge
        local bi = labelToId[b] or math.huge
        return ai < bi
    end)
    if #options == 0 then
        options = {"Zone 1"}
        labelToId = {["Zone 1"] = 1}
    end
    return options, labelToId
end

local fishOptions, fishLabelToId = getFishZones()
local selectedFishLabel = fishOptions[1]
local selectedFishZoneId = fishLabelToId[selectedFishLabel] or tonumber(selectedFishLabel:match("%d+")) or 1

-- Dropdown Zone (Fish)
local FishZoneDropdown = MainTab:CreateDropdown({
    Name = "Select Zone (Fish)",
    Options = fishOptions,
    CurrentOption = selectedFishLabel,
    Flag = "ZoneDropdownFish",
    Callback = function(Option)
        selectedFishLabel = (typeof(Option) == "table") and Option[1] or Option
        selectedFishZoneId = fishLabelToId[selectedFishLabel] or tonumber(tostring(selectedFishLabel):match("%d+")) or 1
        Rayfield:Notify({
            Title = "Zone Selected (Fish)",
            Content = ("Selected: %s -> ZoneId %s"):format(selectedFishLabel, tostring(selectedFishZoneId)),
            Duration = 4
        })
    end
})

-- Util: hitung parameter lempar kail di depan player
local function computeCastParamsAheadOfPlayer()
    local lp = Players.LocalPlayer
    local char = lp and lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local cf = hrp.CFrame
    local forward = cf.LookVector
    local up = cf.UpVector

    local castDistance = 20 -- jarak lempar ke depan player (ubah sesuai kebutuhan)
    local origin = hrp.Position + up * 1.5 + forward * 2
    local p2 = origin + forward * 6 + up * 2.5
    local p3 = origin + forward * 12 + up * 4

    local target = origin + forward * castDistance

    -- Raycast ke bawah untuk cari permukaan (air/tanah) di sekitar target
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}

    local result = Workspace:Raycast(target + up * 50, Vector3.new(0, -200, 0), params)
    local p4 = result and result.Position or (target - up * 4)

    local c6 = CFrame.lookAt(p4, p4 + forward)
    return origin, p2, p3, p4, c6
end

-- Remote CastFishingRod
local function getCastRemote()
    local Packages = RS:FindFirstChild("Packages")
    local Knit = Packages and Packages:FindFirstChild("Knit")
    local Services = Knit and Knit:FindFirstChild("Services")
    local FarmingService = Services and Services:FindFirstChild("FarmingService")
    local RF = FarmingService and FarmingService:FindFirstChild("RF")
    return RF and RF:FindFirstChild("CastFishingRod") or nil
end

-- Auto Fish (CastFishingRod only)
local AutoFishEnabled = false
local autoFishThread = nil

local ohNumber1 = 0.99

local AutoFishToggle = MainTab:CreateToggle({
    Name = "Auto Fish",
    CurrentValue = false,
    Flag = "AutoFishToggle",
    Callback = function(Value)
        AutoFishEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Fish Enabled",
                Content = ("Mulai auto fishing (ZoneId %s)"):format(tostring(selectedFishZoneId)),
                Duration = 4
            })
            autoFishThread = task.spawn(function()
                local castFishingRod = getCastRemote()
                if not castFishingRod then
                    -- Coba tunggu sebentar kalau belum replicate
                    local ok
                    ok, castFishingRod = pcall(function()
                        local Packages = RS:WaitForChild("Packages", 5)
                        local Knit = Packages and Packages:WaitForChild("Knit", 5)
                        local Services = Knit and Knit:WaitForChild("Services", 5)
                        local FarmingService = Services and Services:WaitForChild("FarmingService", 5)
                        local RF = FarmingService and FarmingService:WaitForChild("RF", 5)
                        return RF and RF:WaitForChild("CastFishingRod", 5)
                    end)
                    if not ok or not castFishingRod then
                        Rayfield:Notify({
                            Title = "Auto Fish Warning",
                            Content = "Remote CastFishingRod tidak ditemukan.",
                            Duration = 5
                        })
                        return
                    end
                end

                while AutoFishEnabled do
                    local v1, v2, v3, v4, c6 = computeCastParamsAheadOfPlayer()
                    if v1 then
                        local ohNumber7 = tonumber(selectedFishZoneId) or tonumber(tostring(selectedFishLabel):match("%d+")) or 1
                        pcall(function()
                            castFishingRod:InvokeServer(ohNumber1, v1, v2, v3, v4, c6, ohNumber7)
                        end)
                    else
                        Rayfield:Notify({
                            Title = "Auto Fish",
                            Content = "Character/HumanoidRootPart belum siap.",
                            Duration = 3
                        })
                    end
                    task.wait(3) -- jeda biar tidak spam
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

-- Instant Catch Fish (opsional, masih di Fish Section)
local InstantCatchFishEnabled = false
local instantCatchFishThread = nil
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
                local catchRemote = RS.Packages
                    and RS.Packages.Knit
                    and RS.Packages.Knit.Services
                    and RS.Packages.Knit.Services.FarmingService
                    and RS.Packages.Knit.Services.FarmingService.RF
                    and RS.Packages.Knit.Services.FarmingService.RF.CatchSequenceFinish
                if not catchRemote then
                    Rayfield:Notify({
                        Title = "Instant Catch Warning",
                        Content = "Remote CatchSequenceFinish tidak ditemukan.",
                        Duration = 5
                    })
                    return
                end
                while InstantCatchFishEnabled do
                    pcall(function()
                        catchRemote:InvokeServer(true, true)
                    end)
                    task.wait(0.1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Instant Catch Fish Disabled",
                Content = "Instant Catch Fish dihentikan",
                Duration = 5
            })
        end
    end
})

-- =========================
-- Gift / Spin / Hatch
-- =========================

-- Auto Claim Gift
local AutoClaimGiftEnabled = false
local autoClaimGiftThread = nil
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
                                pcall(function()
                                    game:GetService("ReplicatedStorage").Packages.Knit.Services.DataService.RF.ClaimPlaytimeGift:InvokeServer(ohString1)
                                end)
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

-- Instant Catch Fish
local InstantCatchFishEnabled = false
local instantCatchFishThread = nil
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
    local eggsFolder = workspace.Scripted and workspace.Scripted:FindFirstChild("Eggs")
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
            local eggsFolder = workspace.Scripted and workspace.Scripted:FindFirstChild("Eggs")
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
                    local eggsFolderNow = workspace.Scripted and workspace.Scripted:FindFirstChild("Eggs")
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