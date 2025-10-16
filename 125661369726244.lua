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
        FolderName = "AnimeApexSetting",
        FileName = "AnimeApexConfig"
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
        FileName = "AnimeApexKey",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/hWYcDLRf"}
    }
})
-- Membuat tab Main
local MainTab = Window:CreateTab("Main")
-- Membuat section Farm di Tab Main
local FarmSection = MainTab:CreateSection("Farm Features")
-- Fungsi untuk mendapatkan list NPC unik
local function getNPCList()
    local npcList = {}
    local uniqueNames = {}
    local stageEnemiesFolder = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("StageEnemies")
    if stageEnemiesFolder then
        for _, subfolder in ipairs(stageEnemiesFolder:GetChildren()) do
            if subfolder:IsA("Folder") then
                for _, model in ipairs(subfolder:GetChildren()) do
                    if model:IsA("Model") and not uniqueNames[model.Name] then
                        uniqueNames[model.Name] = true
                        table.insert(npcList, model.Name)
                    end
                end
            end
        end
    end
    table.insert(npcList, "All Enemies")
    return npcList
end
local npcList = getNPCList()
local selectedNPCs = {npcList[1] or "Bloodthirsty Shark"}
-- Dropdown untuk NPC dengan multi select
local NPCDropdown = MainTab:CreateDropdown({
    Name = "Select NPC",
    Options = npcList,
    CurrentOption = selectedNPCs,
    MultipleOptions = true,
    Flag = "NPCDropdown",
    Callback = function(Option)
        selectedNPCs = (typeof(Option) == "table") and Option or {Option}
        Rayfield:Notify({
            Title = "NPC Selected",
            Content = "Selected NPCs: " .. table.concat(selectedNPCs, ", "),
            Duration = 5
        })
    end
})
-- Button Refresh NPC
local RefreshNPCButton = MainTab:CreateButton({
    Name = "Refresh NPC",
    Callback = function()
        npcList = getNPCList()
        NPCDropdown:Refresh(npcList, true)
        selectedNPCs = {npcList[1] or "Bloodthirsty Shark"}
        Rayfield:Notify({
            Title = "NPC List Refreshed",
            Content = "NPC list has been updated",
            Duration = 5
        })
    end
})
-- Dropdown untuk Method
local methodList = {"Walk To", "Tp To"}
local selectedMethod = methodList[1]
local MethodDropdown = MainTab:CreateDropdown({
    Name = "Select Method",
    Options = methodList,
    CurrentOption = selectedMethod,
    Flag = "MethodDropdown",
    Callback = function(Option)
        selectedMethod = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Method Selected",
            Content = "Selected Method: " .. tostring(selectedMethod),
            Duration = 5
        })
    end
})
-- Variabel untuk Auto Farm
local AutoFarmEnabled = false
local autoFarmThread = nil
local notifiedMissing = false
-- Toggle untuk Auto Farm
local AutoFarmToggle = MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        AutoFarmEnabled = Value
        notifiedMissing = false
        if Value then
            Rayfield:Notify({
                Title = "Auto Farm Enabled",
                Content = "Started auto farming selected NPCs using " .. tostring(selectedMethod),
                Duration = 5
            })
            autoFarmThread = spawn(function()
                local player = game:GetService("Players").LocalPlayer
                local stageEnemiesFolder = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("StageEnemies")
                local activePetsFolder = workspace:FindFirstChild("ActivePets")
                local playerPetFolderName = tostring(player.UserId)
               
                local lastTrainTime = tick() -- Untuk melacak waktu terakhir train
               
                while AutoFarmEnabled do
                    local character = player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                   
                    if not character or not humanoid or not rootPart then
                        if not notifiedMissing then
                            Rayfield:Notify({
                                Title = "Auto Farm Warning",
                                Content = "Character not found",
                                Duration = 5
                            })
                            notifiedMissing = true
                        end
                        wait(1)
                        continue
                    end
                   
                    -- Jika All Enemies dipilih, farm semua NPC
                    local isAllEnemies = table.find(selectedNPCs, "All Enemies")
                    local targetNPCs = {}
                    if stageEnemiesFolder then
                        for _, subfolder in ipairs(stageEnemiesFolder:GetChildren()) do
                            for _, model in ipairs(subfolder:GetChildren()) do
                                if model:IsA("Model") then
                                    if isAllEnemies or table.find(selectedNPCs, model.Name) then
                                        table.insert(targetNPCs, model)
                                    end
                                end
                            end
                        end
                    end
                   
                    if #targetNPCs == 0 then
                        if not notifiedMissing then
                            Rayfield:Notify({
                                Title = "Auto Farm Warning",
                                Content = "No NPCs found",
                                Duration = 5
                            })
                            notifiedMissing = true
                        end
                        wait(1)
                        continue
                    end
                   
                    notifiedMissing = false
                   
                    for _, targetNPC in ipairs(targetNPCs) do
                        if not AutoFarmEnabled then break end
                        local teleportedPets = false
                       
                        while AutoFarmEnabled and targetNPC and targetNPC.Parent do
                            if targetNPC.PrimaryPart then
                                if selectedMethod == "Walk To" then
                                    humanoid:MoveTo(targetNPC.PrimaryPart.Position)
                                elseif selectedMethod == "Tp To" then
                                    local newCFrame = targetNPC.PrimaryPart.CFrame * CFrame.new(0, 0, 5)
                                    rootPart.CFrame = newCFrame
                                    if not teleportedPets and activePetsFolder then
                                        local petFolder = activePetsFolder:FindFirstChild(playerPetFolderName)
                                        if petFolder then
                                            for _, petModel in ipairs(petFolder:GetChildren()) do
                                                if petModel:IsA("Model") and petModel.PrimaryPart then
                                                    petModel.PrimaryPart.CFrame = newCFrame
                                                end
                                            end
                                        end
                                        teleportedPets = true
                                    end
                                end
                               
                                local direction = (targetNPC.PrimaryPart.Position - rootPart.Position).Unit
                                local ohVector31 = Vector3.new(direction.X, 0, direction.Z).Unit
                                local ohBoolean2 = true
                               
                                pcall(function()
                                    game:GetService("ReplicatedStorage").Events.DamageIncreaseOnClickEvent:FireServer(ohVector31, ohBoolean2)
                                end)
                            end
                            wait(0.3) -- Tingkatkan wait untuk mengurangi lag (dari 0.1 ke 0.5)
                        end
                    end
                   
                    -- Gabungkan fungsi kedua ke dalam loop utama dengan pengecekan waktu
                    if tick() - lastTrainTime >= 2 then
                        if rootPart then
                            local direction = rootPart.CFrame.LookVector
                            local ohVector31 = Vector3.new(direction.X, 0, direction.Z).Unit
                            local ohBoolean2 = true
                            local ok, err = pcall(function()
                                game:GetService("ReplicatedStorage").Events.DamageIncreaseOnClickEvent:FireServer(ohVector31, ohBoolean2)
                            end)
                            if not ok then
                                Rayfield:Notify({
                                    Title = "Auto Farm Error (Second Function)",
                                    Content = "Failed to train: " .. tostring(err),
                                    Duration = 5
                                })
                            end
                        end
                        lastTrainTime = tick()
                    end
                   
                    wait(0.01) -- Wait kecil untuk loop utama agar tidak terlalu intens
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Farm Disabled",
                Content = "Auto Farm has been stopped",
                Duration = 5
            })
        end
    end
})
-- Variabel untuk Auto Train
local AutoTrainEnabled = false
local autoTrainThread = nil
-- Toggle untuk Auto Train
local AutoTrainToggle = MainTab:CreateToggle({
    Name = "Auto Train",
    CurrentValue = false,
    Flag = "AutoTrainToggle",
    Callback = function(Value)
        AutoTrainEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Train Enabled",
                Content = "Started auto training", -- Ubah deskripsi sesuai wait baru
                Duration = 5
            })
            autoTrainThread = spawn(function()
                local player = game:GetService("Players").LocalPlayer
                while AutoTrainEnabled do
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    -- Fungsi pertama
                    local ok1, err1 = pcall(function()
                        game:GetService("ReplicatedStorage").Events.DamageIncreaseOnClickEvent:FireServer()
                    end)
                    if not ok1 then
                        Rayfield:Notify({
                            Title = "Auto Train Error (First Function)",
                            Content = "Failed: " .. tostring(err1),
                            Duration = 5
                        })
                    end
                    wait(0.1) -- Tingkatkan wait dari 0.1 ke 1 untuk mengurangi spam dan lag
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Train Disabled",
                Content = "Auto Train has been stopped",
                Duration = 5
            })
        end
    end
})
-- Variabel untuk Auto Collect
local AutoCollectEnabled = false
local autoCollectThread = nil
-- Toggle untuk Auto Collect
local AutoCollectToggle = MainTab:CreateToggle({
    Name = "Auto Collect",
    CurrentValue = false,
    Flag = "AutoCollectToggle",
    Callback = function(Value)
        AutoCollectEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Collect Enabled",
                Content = "Started auto collecting from ClientCoinsGems",
                Duration = 5
            })
            autoCollectThread = spawn(function()
                local player = game:GetService("Players").LocalPlayer
                while AutoCollectEnabled do
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    local coinsGemsFolder = workspace:FindFirstChild("ClientCoinsGems")
                    if coinsGemsFolder and rootPart then
                        for _, item in ipairs(coinsGemsFolder:GetChildren()) do
                            if item:IsA("BasePart") or item:IsA("Model") then
                                local ok, err = pcall(function()
                                    if item:IsA("BasePart") then
                                        item.CFrame = rootPart.CFrame
                                    elseif item:IsA("Model") and item.PrimaryPart then
                                        item.PrimaryPart.CFrame = rootPart.CFrame
                                    end
                                end)
                                if not ok then
                                    Rayfield:Notify({
                                        Title = "Auto Collect Error",
                                        Content = "Failed to collect item: " .. tostring(err),
                                        Duration = 5
                                    })
                                end
                            end
                        end
                    end
                    wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Collect Disabled",
                Content = "Auto Collect has been stopped",
                Duration = 5
            })
        end
    end
})
-- Variabel untuk Auto Ascend
local AutoAscendEnabled = false
local autoAscendThread = nil
-- Toggle untuk Auto Ascend
local AutoAscendToggle = MainTab:CreateToggle({
    Name = "Auto Ascend",
    CurrentValue = false,
    Flag = "AutoAscendToggle",
    Callback = function(Value)
        AutoAscendEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Ascend Enabled",
                Content = "Started auto ascending",
                Duration = 5
            })
            autoAscendThread = spawn(function()
                while AutoAscendEnabled do
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage").Events.AscendEvent:FireServer(true)
                    end)
                    if not ok then
                        Rayfield:Notify({
                            Title = "Auto Ascend Error",
                            Content = "Failed: " .. tostring(err),
                            Duration = 5
                        })
                    end
                    wait(5)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Ascend Disabled",
                Content = "Auto Ascend stopped",
                Duration = 5
            })
        end
    end
})
-- Membuat section Other di Tab Main
local OtherSection = MainTab:CreateSection("Other Features")
-- Variabel untuk Auto Claim FreeGift
local AutoClaimFreeGiftEnabled = false
local autoClaimFreeGiftThread = nil
-- Toggle untuk Auto Claim FreeGift
local AutoClaimFreeGiftToggle = MainTab:CreateToggle({
    Name = "Auto Claim FreeGift",
    CurrentValue = false,
    Flag = "AutoClaimFreeGiftToggle",
    Callback = function(Value)
        AutoClaimFreeGiftEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Claim FreeGift Enabled",
                Content = "Started auto claiming Free Gifts",
                Duration = 5
            })
            autoClaimFreeGiftThread = spawn(function()
                local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                while AutoClaimFreeGiftEnabled do
                    -- Jalankan FreeRobloxShop
                    local ok1, err1 = pcall(function()
                        game:GetService("ReplicatedStorage").Events.FreeRobloxShop:FireServer()
                    end)
                    if not ok1 then
                        Rayfield:Notify({
                            Title = "FreeRobloxShop Error",
                            Content = "Failed: " .. tostring(err1),
                            Duration = 5
                        })
                    end
                   
                    for i = 1, 12 do
                        if not AutoClaimFreeGiftEnabled then break end
                        local giftFrame = playerGui:FindFirstChild("PlaytimeRewards") and
                                          playerGui.PlaytimeRewards:FindFirstChild("Frame") and
                                          playerGui.PlaytimeRewards.Frame:FindFirstChild("Frame") and
                                          playerGui.PlaytimeRewards.Frame.Frame:FindFirstChild("Gift" .. i)
                        if giftFrame then
                            local timerLabel = giftFrame:FindFirstChild("Timer")
                            if timerLabel and timerLabel.Text == "Claim!" then
                                local ohString1 = tostring(i)
                                local ok2, err2 = pcall(function()
                                    game:GetService("ReplicatedStorage").Events.PlaytimeRewardUpdateEvent:FireServer(ohString1)
                                end)
                                if not ok2 then
                                    Rayfield:Notify({
                                        Title = "PlaytimeRewardUpdateEvent Error",
                                        Content = "Failed for " .. ohString1 .. ": " .. tostring(err2),
                                        Duration = 5
                                    })
                                end
                            end
                        end
                        wait(1) -- Wait lebih pendek untuk check lebih sering, tapi tidak spam claim
                    end
                   
                    wait(5) -- Wait setelah full check
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Claim FreeGift Disabled",
                Content = "Auto Claim FreeGift has been stopped",
                Duration = 5
            })
        end
    end
})
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
                    local ok1, err1 = pcall(function()
                        game:GetService("ReplicatedStorage").Events.SpinWheelEvent:FireServer("Spin")
                    end)
                    if not ok1 then
                        Rayfield:Notify({
                            Title = "Auto Spin Error (Spin)",
                            Content = "Failed: " .. tostring(err1),
                            Duration = 5
                        })
                    end
                   
                    local ok2, err2 = pcall(function()
                        game:GetService("ReplicatedStorage").Events.SpinWheelEvent:FireServer("SpinComplete")
                    end)
                    if not ok2 then
                        Rayfield:Notify({
                            Title = "Auto Spin Error (SpinComplete)",
                            Content = "Failed: " .. tostring(err2),
                            Duration = 5
                        })
                    end
                   
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
-- Variabel untuk Auto Equip Best Unit
local AutoEquipBestUnitEnabled = false
local autoEquipBestUnitThread = nil
-- Toggle untuk Auto Equip Best Unit
local AutoEquipBestUnitToggle = MainTab:CreateToggle({
    Name = "Auto Equip Best Unit",
    CurrentValue = false,
    Flag = "AutoEquipBestUnitToggle",
    Callback = function(Value)
        AutoEquipBestUnitEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Equip Best Unit Enabled",
                Content = "Started auto equipping best units",
                Duration = 5
            })
            autoEquipBestUnitThread = spawn(function()
                while AutoEquipBestUnitEnabled do
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage").Events.EquipBest:InvokeServer()
                    end)
                    if not ok then
                        Rayfield:Notify({
                            Title = "Auto Equip Best Unit Error",
                            Content = "Failed: " .. tostring(err),
                            Duration = 5
                        })
                    end
                    wait(10)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Equip Best Unit Disabled",
                Content = "Auto Equip Best Unit stopped",
                Duration = 5
            })
        end
    end
})
-- Variabel untuk Auto Equip Best Weapon
local AutoEquipBestWeaponEnabled = false
local autoEquipBestWeaponThread = nil
-- Toggle untuk Auto Equip Best Weapon
local AutoEquipBestWeaponToggle = MainTab:CreateToggle({
    Name = "Auto Equip Best Weapon",
    CurrentValue = false,
    Flag = "AutoEquipBestWeaponToggle",
    Callback = function(Value)
        AutoEquipBestWeaponEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Equip Best Weapon Enabled",
                Content = "Started auto equipping best weapon",
                Duration = 5
            })
            autoEquipBestWeaponThread = spawn(function()
                while AutoEquipBestWeaponEnabled do
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage").Events.RNGGame.Weapons.EquipBestWeapon:InvokeServer()
                    end)
                    if not ok then
                        Rayfield:Notify({
                            Title = "Auto Equip Best Weapon Error",
                            Content = "Failed: " .. tostring(err),
                            Duration = 5
                        })
                    end
                    wait(10)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Equip Best Weapon Disabled",
                Content = "Auto Equip Best Weapon stopped",
                Duration = 5
            })
        end
    end
})
-- Button Auto Claim Codes
local AutoClaimCodesButton = MainTab:CreateButton({
    Name = "Auto Claim Codes",
    Callback = function()
        local codeModule = require(game:GetService("ReplicatedStorage").Modules.CodeData)
        for code, _ in pairs(codeModule) do
            local ok, result = pcall(function()
                return game:GetService("ReplicatedStorage").Events.CodeEvent:InvokeServer("Claim", code)
            end)
            if ok then
                Rayfield:Notify({
                    Title = "Code Claimed",
                    Content = "Claimed code: " .. code,
                    Duration = 5
                })
            else
                Rayfield:Notify({
                    Title = "Claim Error",
                    Content = "Failed to claim " .. code .. ": " .. tostring(result),
                    Duration = 5
                })
            end
            wait(0.5)
        end
    end
})
-- Button Tp To Hidden Chests
local hiddenChestsIndex = 1
local hiddenChestsList = {}
local function collectHiddenChests()
    hiddenChestsList = {}
    local hiddenChestsFolder = workspace:FindFirstChild("HiddenChests")
    if hiddenChestsFolder then
        for _, subfolder in ipairs(hiddenChestsFolder:GetChildren()) do
            if subfolder:IsA("Folder") then
                for _, model in ipairs(subfolder:GetChildren()) do
                    if model:IsA("Model") then
                        table.insert(hiddenChestsList, model)
                    end
                end
            end
        end
    end
end
collectHiddenChests()
local TpToHiddenChestsButton = MainTab:CreateButton({
    Name = "Tp To Hidden Chests",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
       
        if #hiddenChestsList == 0 then
            collectHiddenChests()
            if #hiddenChestsList == 0 then
                Rayfield:Notify({
                    Title = "Tp Error",
                    Content = "No hidden chests found",
                    Duration = 5
                })
                return
            end
        end
       
        if hiddenChestsIndex > #hiddenChestsList then
            hiddenChestsIndex = 1
        end
       
        local targetModel = hiddenChestsList[hiddenChestsIndex]
        if targetModel and targetModel.PrimaryPart and rootPart then
            rootPart.CFrame = targetModel.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Teleported to hidden chest " .. hiddenChestsIndex,
                Duration = 5
            })
            hiddenChestsIndex = hiddenChestsIndex + 1
        else
            collectHiddenChests()
            hiddenChestsIndex = 1
            Rayfield:Notify({
                Title = "Tp Warning",
                Content = "Chest not found, list refreshed",
                Duration = 5
            })
        end
    end
})
-- Membuat tab Summon & Re-Roll
local SummonReRollTab = Window:CreateTab("Summon & Re-Roll")
-- Section Summon Units
local SummonSection = SummonReRollTab:CreateSection("Summon Units")
-- Fungsi untuk mendapatkan list Banner
local function getBannerList()
    local bannerList = {}
    local eggVendors = workspace:FindFirstChild("EggVendors")
    if eggVendors then
        for _, vendor in ipairs(eggVendors:GetChildren()) do
            table.insert(bannerList, vendor.Name)
        end
    end
    return bannerList
end
local bannerList = getBannerList()
local selectedBanner = bannerList[1] or "Standard Banner 1"
-- Dropdown Select Banner
local BannerDropdown = SummonReRollTab:CreateDropdown({
    Name = "Select Banner",
    Options = bannerList,
    CurrentOption = selectedBanner,
    Flag = "BannerDropdown",
    Callback = function(Option)
        selectedBanner = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Banner Selected",
            Content = "Selected Banner: " .. tostring(selectedBanner),
            Duration = 5
        })
    end
})
-- Button Refresh Banner
local RefreshBannerButton = SummonReRollTab:CreateButton({
    Name = "Refresh Banner",
    Callback = function()
        bannerList = getBannerList()
        BannerDropdown:Refresh(bannerList, true)
        selectedBanner = bannerList[1] or "Standard Banner 1"
        Rayfield:Notify({
            Title = "Banner List Refreshed",
            Content = "Banner list has been updated",
            Duration = 5
        })
    end
})
-- Dropdown How Many
local howManyList = {"1", "2", "5", "10", "15", "20"}
local selectedHowMany = howManyList[1]
local HowManyDropdown = SummonReRollTab:CreateDropdown({
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
-- Variabel untuk Auto Summon
local AutoSummonEnabled = false
local autoSummonThread = nil
-- Toggle Auto Summon
local AutoSummonToggle = SummonReRollTab:CreateToggle({
    Name = "Auto Summon",
    CurrentValue = false,
    Flag = "AutoSummonToggle",
    Callback = function(Value)
        AutoSummonEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Summon Enabled",
                Content = "Started auto summoning",
                Duration = 5
            })
            autoSummonThread = spawn(function()
                while AutoSummonEnabled do
                    local ohString1 = selectedBanner
                    local ohBoolean2 = false
                    local ohNumber3 = tonumber(selectedHowMany)
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage").Events.PlayerPressedKeyOnEgg:FireServer(ohString1, ohBoolean2, ohNumber3)
                    end)
                    if not ok then
                        Rayfield:Notify({
                            Title = "Auto Summon Error",
                            Content = "Failed: " .. tostring(err),
                            Duration = 5
                        })
                    end
                    wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Summon Disabled",
                Content = "Auto Summon stopped",
                Duration = 5
            })
        end
    end
})
-- Section Buy Weapon
local BuyWeaponSection = SummonReRollTab:CreateSection("Buy Weapon")
-- Fungsi untuk mendapatkan list Weapon Crate
local function getWeaponCreateList()
    local weaponList = {}
    local weaponEggVendors = workspace:FindFirstChild("WeaponEggVendors")
    if weaponEggVendors then
        for _, vendor in ipairs(weaponEggVendors:GetChildren()) do
            table.insert(weaponList, vendor.Name)
        end
    end
    return weaponList
end
local weaponCreateList = getWeaponCreateList()
local selectedWeaponCreate = weaponCreateList[1] or "Basic Weapon Crate 1"
-- Dropdown Weapon Create
local WeaponCreateDropdown = SummonReRollTab:CreateDropdown({
    Name = "Weapon Create",
    Options = weaponCreateList,
    CurrentOption = selectedWeaponCreate,
    Flag = "WeaponCreateDropdown",
    Callback = function(Option)
        selectedWeaponCreate = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Weapon Create Selected",
            Content = "Selected: " .. tostring(selectedWeaponCreate),
            Duration = 5
        })
    end
})
-- Button Refresh Weapon
local RefreshWeaponButton = SummonReRollTab:CreateButton({
    Name = "Refresh Weapon",
    Callback = function()
        weaponCreateList = getWeaponCreateList()
        WeaponCreateDropdown:Refresh(weaponCreateList, true)
        selectedWeaponCreate = weaponCreateList[1] or "Basic Weapon Crate 1"
        Rayfield:Notify({
            Title = "Weapon List Refreshed",
            Content = "Weapon list has been updated",
            Duration = 5
        })
    end
})
-- Dropdown How Many for Buy Weapon
local buyHowManyList = {"1", "5", "10"}
local selectedBuyHowMany = buyHowManyList[1]
local BuyHowManyDropdown = SummonReRollTab:CreateDropdown({
    Name = "How Many",
    Options = buyHowManyList,
    CurrentOption = selectedBuyHowMany,
    Flag = "BuyHowManyDropdown",
    Callback = function(Option)
        selectedBuyHowMany = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "How Many Selected",
            Content = "Selected: " .. tostring(selectedBuyHowMany),
            Duration = 5
        })
    end
})
-- Variabel untuk Auto Buy Weapon
local AutoBuyWeaponEnabled = false
local autoBuyWeaponThread = nil
-- Toggle Auto Buy Weapon
local AutoBuyWeaponToggle = SummonReRollTab:CreateToggle({
    Name = "Auto Buy Weapon",
    CurrentValue = false,
    Flag = "AutoBuyWeaponToggle",
    Callback = function(Value)
        AutoBuyWeaponEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Buy Weapon Enabled",
                Content = "Started auto buying",
                Duration = 5
            })
            autoBuyWeaponThread = spawn(function()
                while AutoBuyWeaponEnabled do
                    local ohString1 = selectedWeaponCreate
                    local ohBoolean2 = false
                    local ohNumber3 = tonumber(selectedBuyHowMany)
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage").Events.RNGGame.Weapons.PlayerPressedKeyOnWeaponEgg:FireServer(ohString1, ohBoolean2, ohNumber3)
                    end)
                    if not ok then
                        Rayfield:Notify({
                            Title = "Auto Buy Weapon Error",
                            Content = "Failed: " .. tostring(err),
                            Duration = 5
                        })
                    end
                    wait(2)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Buy Weapon Disabled",
                Content = "Auto Buy Weapon stopped",
                Duration = 5
            })
        end
    end
})
-- Paragraph
local Paragraph = SummonReRollTab:CreateParagraph({
    Title = "info",
    Content = "Open the unit/pet first then press the Refresh button so that the unit/pet name appears in the Dropdown."
})
-- Section Unit Stat Re-Roll
local ReRollSection = SummonReRollTab:CreateSection("Unit Stat Re-Roll")
-- Fungsi untuk mendapatkan list Pet
local function getPetList()
    local petList = {}
    local scrollingFrame = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Pets") and
                           game:GetService("Players").LocalPlayer.PlayerGui.Pets:FindFirstChild("Frame") and
                           game:GetService("Players").LocalPlayer.PlayerGui.Pets.Frame:FindFirstChild("Pets") and
                           game:GetService("Players").LocalPlayer.PlayerGui.Pets.Frame.Pets:FindFirstChild("ScrollingFrame")
    if scrollingFrame then
        for _, petFrame in ipairs(scrollingFrame:GetChildren()) do
            if petFrame:IsA("TextButton") and petFrame:FindFirstChild("PetName") then
                local petNameText = petFrame.PetName.Text
                local petID = petFrame:GetAttribute("petID")
                if petID then
                    table.insert(petList, petNameText .. " (" .. tostring(petID) .. ")")
                end
            end
        end
    end
    return petList
end
local petList = getPetList()
local selectedPetName = ""
local selectedPetID = ""
local previousPetFrame = nil  -- Untuk menyimpan frame pet sebelumnya untuk menghapus outline
-- Dropdown untuk Pet
local PetDropdown = SummonReRollTab:CreateDropdown({
    Name = "Select Pet",
    Options = petList,
    CurrentOption = petList[1] or "",
    Flag = "PetDropdown",
    Callback = function(Option)
        local selectedDisplay = (typeof(Option) == "table") and Option[1] or Option
        local petNameText, petIDStr = string.match(selectedDisplay, "(.*) %((.*)%)")
        if not petNameText or not petIDStr then
            Rayfield:Notify({
                Title = "Pet Selection Error",
                Content = "Invalid pet format selected",
                Duration = 5
            })
            return
        end
        selectedPetName = petNameText
        selectedPetID = petIDStr  -- Asumsi petID adalah string
        -- Cari frame pet yang sesuai
        local scrollingFrame = game:GetService("Players").LocalPlayer.PlayerGui.Pets.Frame.Pets.ScrollingFrame
        local selectedPetFrame = nil
        for _, petFrame in ipairs(scrollingFrame:GetChildren()) do
            if petFrame:IsA("TextButton") and petFrame:FindFirstChild("PetName") and petFrame.PetName.Text == selectedPetName and tostring(petFrame:GetAttribute("petID")) == selectedPetID then
                selectedPetFrame = petFrame
                break
            end
        end
        if selectedPetFrame then
            -- Hapus tanda dari pet sebelumnya jika ada
            if previousPetFrame then
                if previousPetFrame:FindFirstChild("PetName") then
                    previousPetFrame.PetName.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Kembalikan ke warna asli (asumsi putih)
                end
            end
            -- Tambahkan tanda warna merah pada nama pet yang dipilih
            if selectedPetFrame:FindFirstChild("PetName") then
                selectedPetFrame.PetName.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
            previousPetFrame = selectedPetFrame
            Rayfield:Notify({
                Title = "Pet Selected",
                Content = "Selected Pet: " .. selectedPetName .. " (ID: " .. selectedPetID .. ")",
                Duration = 5
            })
        else
            Rayfield:Notify({
                Title = "Pet Selection Error",
                Content = "Could not find pet frame for " .. selectedPetName .. " (ID: " .. selectedPetID .. ")",
                Duration = 5
            })
        end
    end
})
-- Button Refresh Pet
local RefreshPetButton = SummonReRollTab:CreateButton({
    Name = "Refresh Pet List",
    Callback = function()
        petList = getPetList()
        PetDropdown:Refresh(petList, true)
        selectedPetName = ""
        selectedPetID = ""
        -- Hapus tanda jika ada
        if previousPetFrame then
            if previousPetFrame:FindFirstChild("PetName") then
                previousPetFrame.PetName.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Kembalikan ke warna asli
            end
            previousPetFrame = nil
        end
        Rayfield:Notify({
            Title = "Pet List Refreshed",
            Content = "Pet list has been updated",
            Duration = 5
        })
    end
})
-- Dropdown Stat
local statOptions = {"1", "2", "3", "4"}
local selectedStat = statOptions[1]
local statMap = {
    ["1"] = "attacksPerSecond",
    ["2"] = "damageMultiplier",
    ["3"] = "shockwaveWidth",
    ["4"] = "shockwaveDistance"
}
local StatDropdown = SummonReRollTab:CreateDropdown({
    Name = "Stat",
    Options = statOptions,
    CurrentOption = selectedStat,
    Flag = "StatDropdown",
    Callback = function(Option)
        selectedStat = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Stat Selected",
            Content = "Selected Stat: " .. statMap[selectedStat],
            Duration = 5
        })
    end
})
-- Dropdown Letter
local letterOptions = {"A", "B", "C", "D", "S"}
local selectedLetter = letterOptions[1]
local LetterDropdown = SummonReRollTab:CreateDropdown({
    Name = "Letter",
    Options = letterOptions,
    CurrentOption = selectedLetter,
    Flag = "LetterDropdown",
    Callback = function(Option)
        selectedLetter = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Letter Selected",
            Content = "Selected Letter: " .. tostring(selectedLetter),
            Duration = 5
        })
    end
})
-- Variabel untuk Auto Re-Roll
local AutoReRollEnabled = false
local autoReRollThread = nil
-- Fungsi untuk memeriksa Orb
local function hasOrb()
    local orbCounter = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("PetStatsReroll") and
                       game:GetService("Players").LocalPlayer.PlayerGui.PetStatsReroll:FindFirstChild("Frame") and
                       game:GetService("Players").LocalPlayer.PlayerGui.PetStatsReroll.Frame:FindFirstChild("OrbCounter") and
                       game:GetService("Players").LocalPlayer.PlayerGui.PetStatsReroll.Frame.OrbCounter:FindFirstChild("Cost")
    if orbCounter and orbCounter.Text and orbCounter.Text:match("x0") then
        return false
    end
    return true
end
-- Fungsi untuk memeriksa Stat Letter
local function checkStatLetter(stat)
    local path = {
        ["attacksPerSecond"] = game:GetService("Players").LocalPlayer.PlayerGui.PetStatsReroll.Frame.PetStatistics.attacksPerSecond.LetterBox.StatLetter,
        ["damageMultiplier"] = game:GetService("Players").LocalPlayer.PlayerGui.PetStatsReroll.Frame.PetStatistics.damageMultiplier.LetterBox.StatLetter,
        ["shockwaveWidth"] = game:GetService("Players").LocalPlayer.PlayerGui.PetStatsReroll.Frame.PetStatistics.shockwaveWidth.LetterBox.StatLetter,
        ["shockwaveDistance"] = game:GetService("Players").LocalPlayer.PlayerGui.PetStatsReroll.Frame.PetStatistics.shockwaveDistance.LetterBox.StatLetter
    }
    local statLabel = path[stat]
    return statLabel and statLabel.Text == selectedLetter
end
-- Toggle Auto Re-Roll
local AutoReRollToggle = SummonReRollTab:CreateToggle({
    Name = "Auto Re-Roll",
    CurrentValue = false,
    Flag = "AutoReRollToggle",
    Callback = function(Value)
        AutoReRollEnabled = Value
        if Value then
            if selectedPetID == "" then
                Rayfield:Notify({
                    Title = "Auto Re-Roll Error",
                    Content = "Please select a pet first",
                    Duration = 5
                })
                AutoReRollToggle:Set(false)
                return
            end
            Rayfield:Notify({
                Title = "Auto Re-Roll Enabled",
                Content = "Started auto re-rolling for " .. statMap[selectedStat] .. " to " .. selectedLetter,
                Duration = 5
            })
            autoReRollThread = spawn(function()
                while AutoReRollEnabled do
                    if hasOrb() then
                        if not checkStatLetter(statMap[selectedStat]) then
                            local ok, err = pcall(function()
                                game:GetService("ReplicatedStorage").Events.RNGGame.PetStatsReroll.ReRollPetStats:FireServer(selectedPetID, statMap[selectedStat])
                            end)
                            if not ok then
                                Rayfield:Notify({
                                    Title = "Auto Re-Roll Error",
                                    Content = "Failed: " .. tostring(err),
                                    Duration = 5
                                })
                            end
                        else
                            Rayfield:Notify({
                                Title = "Auto Re-Roll Success",
                                Content = "Reached desired letter " .. selectedLetter .. " for " .. statMap[selectedStat],
                                Duration = 5
                            })
                            AutoReRollEnabled = false
                            AutoReRollToggle:Set(false)
                            break
                        end
                    else
                        Rayfield:Notify({
                            Title = "Auto Re-Roll Warning",
                            Content = "No Orbs available, stopping re-roll",
                            Duration = 5
                        })
                        AutoReRollEnabled = false
                        AutoReRollToggle:Set(false)
                        break
                    end
                    wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Re-Roll Disabled",
                Content = "Auto Re-Roll stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat tab Dungeon-Craft
local DungeonCraftTab = Window:CreateTab("Dungeon-Craft")
-- Section Dungeon
local DungeonSection = DungeonCraftTab:CreateSection("Dungeon")
-- Variabel untuk Auto Dungeon
local AutoDungeonEnabled = false
local autoDungeonThread = nil
-- Toggle untuk Auto Dungeon
local AutoDungeonToggle = DungeonCraftTab:CreateToggle({
    Name = "Auto Dungeon",
    CurrentValue = false,
    Flag = "AutoDungeonToggle",
    Callback = function(Value)
        AutoDungeonEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Dungeon Enabled",
                Content = "Started auto dungeon",
                Duration = 5
            })
            autoDungeonThread = spawn(function()
                local player = game:GetService("Players").LocalPlayer
                local activePetsFolder = workspace:FindFirstChild("ActivePets")
                local playerPetFolderName = tostring(player.UserId)
                local method = "Tp To" -- Default method
                local lastEnemyTime = 0
                while AutoDungeonEnabled do
                    local character = player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if not character or not humanoid or not rootPart then
                        wait(1)
                        continue
                    end
                    local dungeonEnemies = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("DungeonEnemies")
                    if dungeonEnemies and #dungeonEnemies:GetChildren() > 0 then
                        lastEnemyTime = tick()
                        for _, targetNPC in ipairs(dungeonEnemies:GetChildren()) do
                            if targetNPC:IsA("Model") and targetNPC.PrimaryPart and AutoDungeonEnabled then
                                if method == "Tp To" then
                                    local newCFrame = targetNPC.PrimaryPart.CFrame * CFrame.new(0, 0, 5)
                                    rootPart.CFrame = newCFrame
                                    if activePetsFolder then
                                        local petFolder = activePetsFolder:FindFirstChild(playerPetFolderName)
                                        if petFolder then
                                            for _, petModel in ipairs(petFolder:GetChildren()) do
                                                if petModel:IsA("Model") and petModel.PrimaryPart then
                                                    petModel.PrimaryPart.CFrame = newCFrame
                                                end
                                            end
                                        end
                                    end
                                end
                                local direction = (targetNPC.PrimaryPart.Position - rootPart.Position).Unit
                                local ohVector31 = Vector3.new(direction.X, 0, direction.Z).Unit
                                local ohBoolean2 = true
                                pcall(function()
                                    game:GetService("ReplicatedStorage").Events.DamageIncreaseOnClickEvent:FireServer(ohVector31, ohBoolean2)
                                end)
                                wait(0.3)
                            end
                        end
                    else
                        if tick() - lastEnemyTime > 15 then
                            local ok, err = pcall(function()
                                game:GetService("ReplicatedStorage").Events.DungeonEvent:FireServer("StartGUIUpdate")
                                game:GetService("ReplicatedStorage").Events.DungeonEvent:FireServer("StartDungeon")
                            end)
                            if not ok then
                                Rayfield:Notify({
                                    Title = "Auto Dungeon Error (Join)",
                                    Content = "Failed to join dungeon: " .. tostring(err),
                                    Duration = 5
                                })
                            end
                            lastEnemyTime = tick()
                            wait(1)
                        end
                    end
                    wait(0.1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Dungeon Disabled",
                Content = "Auto Dungeon stopped",
                Duration = 5
            })
        end
    end
})

-- Dropdown Leave Wave
local leaveWaveList = {}
for i = 5, 100 do
    table.insert(leaveWaveList, tostring(i))
end
local selectedLeaveWave = leaveWaveList[1]
local LeaveWaveDropdown = DungeonCraftTab:CreateDropdown({
    Name = "Leave Wave",
    Options = leaveWaveList,
    CurrentOption = selectedLeaveWave,
    Flag = "LeaveWaveDropdown",
    Callback = function(Option)
        selectedLeaveWave = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Leave Wave Selected",
            Content = "Selected Leave Wave: " .. tostring(selectedLeaveWave),
            Duration = 5
        })
    end
})
-- Variabel untuk Auto Leave Wave
local AutoLeaveWaveEnabled = false
local autoLeaveWaveThread = nil
-- Toggle untuk Auto Leave Wave
local AutoLeaveWaveToggle = DungeonCraftTab:CreateToggle({
    Name = "Auto Leave Wave",
    CurrentValue = false,
    Flag = "AutoLeaveWaveToggle",
    Callback = function(Value)
        AutoLeaveWaveEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Leave Wave Enabled",
                Content = "Started auto leaving wave at " .. tostring(selectedLeaveWave),
                Duration = 5
            })
            autoLeaveWaveThread = spawn(function()
                while AutoLeaveWaveEnabled do
                    local waveLabel = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("DungeonMain") and
                                      game:GetService("Players").LocalPlayer.PlayerGui.DungeonMain:FindFirstChild("Frame") and
                                      game:GetService("Players").LocalPlayer.PlayerGui.DungeonMain.Frame:FindFirstChild("Wave") and
                                      game:GetService("Players").LocalPlayer.PlayerGui.DungeonMain.Frame.Wave:FindFirstChild("WaveNumber")
                    if waveLabel then
                        local currentWave = tonumber(waveLabel.Text:match("%d+"))
                        if currentWave and currentWave >= tonumber(selectedLeaveWave) and currentWave >= 5 then
                            local ok, err = pcall(function()
                                game:GetService("ReplicatedStorage").Events.DungeonEvent:FireServer("Exit")
                            end)
                            if not ok then
                                Rayfield:Notify({
                                    Title = "Auto Leave Wave Error",
                                    Content = "Failed to exit wave: " .. tostring(err),
                                    Duration = 5
                                })
                            end
                            AutoLeaveWaveEnabled = false -- Matikan toggle setelah exit
                            AutoLeaveWaveToggle:Set(false)
                        end
                    end
                    wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Leave Wave Disabled",
                Content = "Auto Leave Wave stopped",
                Duration = 5
            })
        end
    end
})

-- Variabel untuk Auto Give You Upgrades
local AutoGiveYouUpgradesEnabled = false
local autoGiveYouUpgradesThread = nil

-- Set untuk menyimpan nama upgrade unik (untuk menghindari duplikat)
local upgradeSet = {}

-- Fungsi untuk update daftar upgrade dari PlayerGui
local function updateUpgradeList()
    local player = game:GetService("Players").LocalPlayer
    local container = player.PlayerGui:FindFirstChild("DungeonUpgradeUi") and player.PlayerGui.DungeonUpgradeUi:FindFirstChild("Frame") and player.PlayerGui.DungeonUpgradeUi.Frame:FindFirstChild("Container")
    if container then
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("ImageLabel") and child.Name ~= "" then
                if not upgradeSet[child.Name] then
                    upgradeSet[child.Name] = true
                end
            end
        end
    end
end

-- Fungsi untuk mendapatkan daftar upgrade dari set
local function getUpgradeList()
    local upgradeList = {}
    for name, _ in pairs(upgradeSet) do
        table.insert(upgradeList, name)
    end
    return upgradeList
end

-- Toggle untuk Auto Give You Upgrades
local AutoGiveYouUpgradesToggle = DungeonCraftTab:CreateToggle({
    Name = "Auto Give You Upgrades",
    CurrentValue = false,
    Flag = "AutoGiveYouUpgradesToggle",
    Callback = function(Value)
        AutoGiveYouUpgradesEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Give You Upgrades Enabled",
                Content = "Started auto giving upgrades for detected types",
                Duration = 5
            })
            autoGiveYouUpgradesThread = spawn(function()
                while AutoGiveYouUpgradesEnabled do
                    -- Update daftar upgrade secara dinamis
                    updateUpgradeList()
                    local upgradeList = getUpgradeList()
                    if #upgradeList > 0 then
                        for _, upgradeName in ipairs(upgradeList) do
                            if AutoGiveYouUpgradesEnabled then
                                local ok, err = pcall(function()
                                    game:GetService("ReplicatedStorage").Events.RNGGame.Dungeons.SendRandomUpgrades:FireServer(upgradeName)
                                end)
                                if not ok then
                                    Rayfield:Notify({
                                        Title = "Auto Give You Upgrades Error",
                                        Content = "Failed for " .. upgradeName .. ": " .. tostring(err),
                                        Duration = 5
                                    })
                                end
                                wait(0.5)  -- Delay antar upgrade untuk menghindari spam
                            end
                        end
                    end
                    wait(2)  -- Delay antar siklus full
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Give You Upgrades Disabled",
                Content = "Auto Give You Upgrades stopped",
                Duration = 5
            })
        end
    end
})

-- Section Craft Weapon
local CraftWeaponSection = DungeonCraftTab:CreateSection("Craft Weapon")

-- Fungsi untuk mendapatkan Weapon List
local function getWeaponList()
    local weaponList = {}
    local scrollingFrame = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("WeaponCraft") and 
        game:GetService("Players").LocalPlayer.PlayerGui.WeaponCraft:FindFirstChild("Frame") and 
        game:GetService("Players").LocalPlayer.PlayerGui.WeaponCraft.Frame:FindFirstChild("EquipmentFrame") and 
        game:GetService("Players").LocalPlayer.PlayerGui.WeaponCraft.Frame.EquipmentFrame:FindFirstChild("ScrollingFrame")
    if scrollingFrame then
        for _, button in ipairs(scrollingFrame:GetChildren()) do
            if button:IsA("TextButton") then
                table.insert(weaponList, button.Name)
            end
        end
    end
    return weaponList
end

local weaponList = getWeaponList()
local selectedWeapon = weaponList[1] or "StoneSword"

-- Dropdown Weapon List
local WeaponDropdown = DungeonCraftTab:CreateDropdown({
    Name = "Weapon List",
    Options = weaponList,
    CurrentOption = selectedWeapon,
    Flag = "WeaponDropdown",
    Callback = function(Option)
        selectedWeapon = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Weapon Selected",
            Content = "Selected Weapon: " .. tostring(selectedWeapon),
            Duration = 5
        })
    end
})

-- Button Refresh Weapon List
local RefreshWeaponButton = DungeonCraftTab:CreateButton({
    Name = "Refresh Weapon List",
    Callback = function()
        weaponList = getWeaponList()
        WeaponDropdown:Refresh(weaponList, true)
        selectedWeapon = weaponList[1] or "StoneSword"
        Rayfield:Notify({
            Title = "Weapon List Refreshed",
            Content = "Weapon list has been updated",
            Duration = 5
        })
    end
})

-- Variabel untuk Auto Craft Weapon
local AutoCraftWeaponEnabled = false
local autoCraftWeaponThread = nil

-- Fungsi untuk check cukup material untuk Weapon
local function hasEnoughWeaponMaterials(weapon)
    local craftAmountFrame = game:GetService("Players").LocalPlayer.PlayerGui.WeaponCraft.Frame:FindFirstChild("craftamount")
    if not craftAmountFrame then return false end
    
    for _, item in ipairs(craftAmountFrame:GetChildren()) do
        if item:IsA("Frame") and item:FindFirstChild("MaterialNumber") then
            local textLabel = item.MaterialNumber
            local text = textLabel.Text
            local parts = string.split(text, "/")
            if #parts == 2 then
                local current = tonumber(string.trim(parts[1]))
                local required = tonumber(string.trim(parts[2]))
                if not current or not required or current < required then
                    return false
                end
            end
        end
    end
    return true
end

-- Toggle Auto Craft Weapon
local AutoCraftWeaponToggle = DungeonCraftTab:CreateToggle({
    Name = "Auto Craft Weapon",
    CurrentValue = false,
    Flag = "AutoCraftWeaponToggle",
    Callback = function(Value)
        AutoCraftWeaponEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Craft Weapon Enabled",
                Content = "Started auto crafting weapon if materials sufficient",
                Duration = 5
            })
            autoCraftWeaponThread = spawn(function()
                while AutoCraftWeaponEnabled do
                    if hasEnoughWeaponMaterials(selectedWeapon) then
                        local ok, err = pcall(function()
                            game:GetService("ReplicatedStorage").Events.CraftingEvent:FireServer("Weapon", selectedWeapon)
                        end)
                        if not ok then
                            Rayfield:Notify({
                                Title = "Auto Craft Weapon Error",
                                Content = "Failed: " .. tostring(err),
                                Duration = 5
                            })
                        end
                    end
                    wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Craft Weapon Disabled",
                Content = "Auto Craft Weapon stopped",
                Duration = 5
            })
        end
    end
})

-- Section Craft Equipment
local CraftEquipmentSection = DungeonCraftTab:CreateSection("Craft Equipment")
-- Fungsi untuk mendapatkan Equipment List
local function getEquipmentList()
    local equipmentList = {}
    local scrollingFrame = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("EquipmentCraft") and
        game:GetService("Players").LocalPlayer.PlayerGui.EquipmentCraft:FindFirstChild("Frame") and
        game:GetService("Players").LocalPlayer.PlayerGui.EquipmentCraft.Frame:FindFirstChild("EquipmentFrame") and
        game:GetService("Players").LocalPlayer.PlayerGui.EquipmentCraft.Frame.EquipmentFrame:FindFirstChild("ScrollingFrame")
    if scrollingFrame then
        for _, button in ipairs(scrollingFrame:GetChildren()) do
            if button:IsA("TextButton") then
                table.insert(equipmentList, button.Name)
            end
        end
    end
    return equipmentList
end
local equipmentList = getEquipmentList()
local selectedEquipment = equipmentList[1] or "BasicEquipment"
-- Dropdown Equipment List
local EquipmentDropdown = DungeonCraftTab:CreateDropdown({
    Name = "Equipment List",
    Options = equipmentList,
    CurrentOption = selectedEquipment,
    Flag = "EquipmentDropdown",
    Callback = function(Option)
        selectedEquipment = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Equipment Selected",
            Content = "Selected Equipment: " .. tostring(selectedEquipment),
            Duration = 5
        })
    end
})
-- Button Refresh Equipment List
local RefreshEquipmentButton = DungeonCraftTab:CreateButton({
    Name = "Refresh Equipment List",
    Callback = function()
        equipmentList = getEquipmentList()
        EquipmentDropdown:Refresh(equipmentList, true)
        selectedEquipment = equipmentList[1] or "BasicEquipment"
        Rayfield:Notify({
            Title = "Equipment List Refreshed",
            Content = "Equipment list has been updated",
            Duration = 5
        })
    end
})
-- Variabel untuk Auto Craft Equipment
local AutoCraftEquipmentEnabled = false
local autoCraftEquipmentThread = nil
-- Fungsi untuk check cukup material untuk Equipment
local function hasEnoughEquipmentMaterials(equipment)
    local craftAmountFrame = game:GetService("Players").LocalPlayer.PlayerGui.EquipmentCraft.Frame:FindFirstChild("craftamount")
    if not craftAmountFrame then return false end
   
    for _, item in ipairs(craftAmountFrame:GetChildren()) do
        if item:IsA("Frame") and item:FindFirstChild("MaterialNumber") then
            local textLabel = item.MaterialNumber
            local text = textLabel.Text
            local parts = string.split(text, "/")
            if #parts == 2 then
                local current = tonumber(string.trim(parts[1]))
                local required = tonumber(string.trim(parts[2]))
                if not current or not required or current < required then
                    return false
                end
            end
        end
    end
    return true
end
-- Toggle Auto Craft Equipment
local AutoCraftEquipmentToggle = DungeonCraftTab:CreateToggle({
    Name = "Auto Craft Equipment",
    CurrentValue = false,
    Flag = "AutoCraftEquipmentToggle",
    Callback = function(Value)
        AutoCraftEquipmentEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Craft Equipment Enabled",
                Content = "Started auto crafting equipment if materials sufficient",
                Duration = 5
            })
            autoCraftEquipmentThread = spawn(function()
                while AutoCraftEquipmentEnabled do
                    if hasEnoughEquipmentMaterials(selectedEquipment) then
                        local ok, err = pcall(function()
                            game:GetService("ReplicatedStorage").Events.CraftingEvent:FireServer("Equipment", selectedEquipment)
                        end)
                        if not ok then
                            Rayfield:Notify({
                                Title = "Auto Craft Equipment Error",
                                Content = "Failed: " .. tostring(err),
                                Duration = 5
                            })
                        end
                    end
                    wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Craft Equipment Disabled",
                Content = "Auto Craft Equipment stopped",
                Duration = 5
            })
        end
    end
})
-- Membuat tab UI
local UITab = Window:CreateTab("UI")
-- Section UI Buttons
local UISection = UITab:CreateSection("UI Toggles")
-- Fungsi untuk mendapatkan list ScreenGui
local function getUIs()
    local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                UITab:CreateButton({
                    Name = gui.Name,
                    Callback = function()
                        gui.Enabled = not gui.Enabled
                        Rayfield:Notify({
                            Title = gui.Name .. " Toggled",
                            Content = gui.Name .. " set to " .. (gui.Enabled and "enabled" or "disabled"),
                            Duration = 5
                        })
                    end
                })
            end
        end
    end
end
getUIs()
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