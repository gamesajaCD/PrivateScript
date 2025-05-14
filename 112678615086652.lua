-- Memuat library Rayfield dengan error handling
local Rayfield
local success, errorMsg = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn("Gagal memuat Rayfield library: " .. tostring(errorMsg))
    return
end

-- Membuat jendela utama
local Window = Rayfield:CreateWindow({
    Name = "[🥚EVENT!] Ride Race",
    Icon = 0,
    LoadingTitle = "[🥚EVENT!] Ride Race",
    LoadingSubtitle = "by ENZO-YT",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "RideRaceConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "Ride Race Key System",
        Subtitle = "Enter Your Key",
        Note = "Key In Description or Join discord.gg/WFjWKwBv8p",
        FileName = "RideRaceKey",
        SaveKey = false,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/pE93ryjf"}
    }
})

-- Membuat tab Main
local MainTab = Window:CreateTab("Main")

-- Membuat section untuk Auto Win
local AutoWinSection = MainTab:CreateSection("Auto Win")

-- Variabel untuk Auto Win
local AutoWinEnabled = false
local autoWinThread = nil
local hasJoinedRace = false

-- Toggle untuk Auto Win
local AutoWinToggle = MainTab:CreateToggle({
    Name = "Auto Win",
    CurrentValue = false,
    Flag = "AutoWinToggle",
    Callback = function(Value)
        AutoWinEnabled = Value
        if Value then
            -- Jalankan sekali saat toggle diaktifkan
            if not hasJoinedRace then
                game:GetService("ReplicatedStorage").Remotes.Event.GameRun["[C-S]PlayerTryRace"]:FireServer()
                hasJoinedRace = true
            end
            Rayfield:Notify({
                Title = "Auto Win Enabled",
                Content = "Auto Win started for race rewards",
                Duration = 5
            })
            autoWinThread = spawn(function()
                while AutoWinEnabled do
                    local ohString1 = "351"
                    game:GetService("ReplicatedStorage").Remotes.Event.GameRun["[C-S]PlayerTryGetRaceReward"]:FireServer(ohString1)
                    wait(0.1)
                end
            end)
        else
            -- Jalankan sekali saat toggle dimatikan
            game:GetService("ReplicatedStorage").Remotes.Event.GameRun["[C-S]PlayerTryLeaveRace"]:FireServer()
            hasJoinedRace = false
            if autoWinThread then
                coroutine.close(autoWinThread)
                autoWinThread = nil
            end
            Rayfield:Notify({
                Title = "Auto Win Disabled",
                Content = "Auto Win has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat section untuk Auto Train
local AutoTrainSection = MainTab:CreateSection("Auto Train")

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
                Content = "Started auto training every 0.001 seconds",
                Duration = 5
            })
            autoTrainThread = spawn(function()
                while AutoTrainEnabled do
                    game:GetService("ReplicatedStorage").Remotes.Event.GameRun["[C-S]PlayerTryTrain"]:FireServer()
                    wait(0.001)
                end
            end)
        else
            if autoTrainThread then
                coroutine.close(autoTrainThread)
                autoTrainThread = nil
            end
            Rayfield:Notify({
                Title = "Auto Train Disabled",
                Content = "Auto Train has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat section untuk Auto Rebirth
local AutoRebirthSection = MainTab:CreateSection("Auto Rebirth")

-- Variabel untuk Auto Rebirth
local AutoRebirthEnabled = false
local autoRebirthThread = nil

-- Toggle untuk Auto Rebirth
local AutoRebirthToggle = MainTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirthToggle",
    Callback = function(Value)
        AutoRebirthEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Rebirth Enabled",
                Content = "Started auto rebirth every 0.1 seconds",
                Duration = 5
            })
            autoRebirthThread = spawn(function()
                while AutoRebirthEnabled do
                    game:GetService("ReplicatedStorage").Remotes.Event.Eco["[C-S]PlayerTryRebirth"]:FireServer()
                    wait(0.1)
                end
            end)
        else
            if autoRebirthThread then
                coroutine.close(autoRebirthThread)
                autoRebirthThread = nil
            end
            Rayfield:Notify({
                Title = "Auto Rebirth Disabled",
                Content = "Auto Rebirth has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat section untuk Claim Free Reward
local ClaimFreeRewardSection = MainTab:CreateSection("Claim Free Reward")

-- Variabel untuk Claim Free Reward
local AutoClaimFreeRewardEnabled = false
local autoClaimFreeRewardThread = nil

-- Toggle untuk Claim Free Reward
local AutoClaimFreeRewardToggle = MainTab:CreateToggle({
    Name = "Claim Free Reward",
    CurrentValue = false,
    Flag = "AutoClaimFreeRewardToggle",
    Callback = function(Value)
        AutoClaimFreeRewardEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Claim Free Reward Enabled",
                Content = "Started claiming rewards 1-12 every 10 seconds",
                Duration = 5
            })
            autoClaimFreeRewardThread = spawn(function()
                while AutoClaimFreeRewardEnabled do
                    for i = 1, 12 do
                        local ohString1 = tostring(i)
                        game:GetService("ReplicatedStorage").Remotes.Function.GameRun["[C-S]TryGetOnlineReward"]:InvokeServer(ohString1)
                    end
                    wait(10)
                end
            end)
        else
            ifSquish
            if autoClaimFreeRewardThread then
                coroutine.close(autoClaimFreeRewardThread)
                autoClaimFreeRewardThread = nil
            end
            Rayfield:Notify({
                Title = "Claim Free Reward Disabled",
                Content = "Claim Free Reward has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat section untuk Auto Spin Relics
local AutoSpinRelicsSection = MainTab:CreateSection("Auto Spin Relics")

-- Variabel untuk Auto Spin Relics
local AutoSpinRelicsEnabled = false
local autoSpinRelicsThread = nil

-- Toggle untuk Auto Spin Relics
local AutoSpinRelicsToggle = MainTab:CreateToggle({
    Name = "Auto Spin Relics",
    CurrentValue = false,
    Flag = "AutoSpinRelicsToggle",
    Callback = function(Value)
        AutoSpinRelicsEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Spin Relics Enabled",
                Content = "Started spinning relics every 0.1 seconds",
                Duration = 5
            })
            autoSpinRelicsThread = spawn(function()
                while AutoSpinRelicsEnabled do
                    local ohString1 = "1"
                    local ohNumber2 = 1
                    game:GetService("ReplicatedStorage").Remotes.Function.Artifacts["[C-S]PlayerTryDoArtifactsPool"]:InvokeServer(ohString1, ohNumber2)
                    wait(0.1)
                end
            end)
        else
            if autoSpinRelicsThread then
                coroutine.close(autoSpinRelicsThread)
                autoSpinRelicsThread = nil
            end
            Rayfield:Notify({
                Title = "Auto Spin Relics Disabled",
                Content = "Auto Spin Relics has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat section untuk Auto Spin
local AutoSpinSection = MainTab:CreateSection("Auto Spin")

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
                Content = "Started spinning every 0.1 seconds",
                Duration = 5
            })
            autoSpinThread = spawn(function()
                while AutoSpinEnabled do
                    local ohNumber1 = 1
                    game:GetService("ReplicatedStorage").Remotes.Function.Spin["[C-S]PlayerTryUserSpin"]:InvokeServer(ohNumber1)
                    wait(0.1)
                end
            end)
        else
            if autoSpinThread then
                coroutine.close(autoSpinThread)
                autoSpinThread = nil
            end
            Rayfield:Notify({
                Title = "Auto Spin Disabled",
                Content = "Auto Spin has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat section untuk Auto Spin Event Tung Tung Sahur
local AutoSpinEventSection = MainTab:CreateSection("Auto Spin Event Tung Tung Sahur")

-- Variabel untuk Auto Spin Event
local AutoSpinEventEnabled = false
local autoSpinEventThread = nil

-- Toggle untuk Auto Spin Event Tung Tung Sahur
local AutoSpinEventToggle = MainTab:CreateToggle({
    Name = "Auto Spin Event Tung Tung Sahur",
    CurrentValue = false,
    Flag = "AutoSpinEventToggle",
    Callback = function(Value)
        AutoSpinEventEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Spin Event Enabled",
                Content = "Started spinning event every 0.1 seconds",
                Duration = 5
            })
            autoSpinEventThread = spawn(function()
                while AutoSpinEventEnabled do
                    local ohString1 = "Event2"
                    local ohNumber2 = 1
                    game:GetService("ReplicatedStorage").Remotes.Event.Events["[C-S]PlayerTryUseEvents"]:FireServer(ohString1, ohNumber2)
                    wait(0.1)
                end
            end)
        else
            if autoSpinEventThread then
                coroutine.close(autoSpinEventThread)
                autoSpinEventThread = nil
            end
            Rayfield:Notify({
                Title = "Auto Spin Event Disabled",
                Content = "Auto Spin Event has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat tab Egg
local EggTab = Window:CreateTab("Egg")

-- Membuat section untuk Auto Hatch Egg
local AutoHatchEggSection = EggTab:CreateSection("Auto Hatch Egg")

-- Fungsi untuk mendapatkan daftar Egg dari ReplicatedStorage.ScenesAssets.Egg dan workspace
local function getEggList()
    local eggList = {}
    local success, eggsFolder = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("ScenesAssets", 15):WaitForChild("Egg", 15)
    end)
    
    if not success or not eggsFolder then
        Rayfield:Notify({
            Title = "Error",
            Content = "Could not find ScenesAssets.Egg folder!",
            Duration = 5
        })
    else
        for _, world in pairs(eggsFolder:GetChildren()) do
            for _, egg in pairs(world:GetChildren()) do
                table.insert(eggList, world.Name .. ":" .. egg.Name)
            end
        end
    end

    -- Tambahkan 4MEgg dari workspace
    local successWorkspace, fourMEgg = pcall(function()
        return game:GetService("Workspace"):FindFirstChild("4MEgg")
    end)
    
    if successWorkspace and fourMEgg then
        table.insert(eggList, "Workspace:4MEgg")
    else
        Rayfield:Notify({
            Title = "Warning",
            Content = "Could not find 4MEgg in Workspace!",
            Duration = 5
        })
    end

    if #eggList == 0 then
        Rayfield:Notify({
            Title = "Warning",
            Content = "No eggs found! Check folder structure or egg types.",
            Duration = 5
        })
    end

    return eggList
end

-- Dropdown untuk memilih Egg
local SelectedEgg = nil
local EggDropdown = EggTab:CreateDropdown({
    Name = "Select Egg",
    Options = getEggList(),
    CurrentOption = getEggList()[1] or "No Eggs Found",
    Flag = "EggDropdown",
    Callback = function(Option)
        SelectedEgg = Option[1]
    end
})

-- Dropdown untuk memilih How Many
local SelectedHowMany = 1
local HowManyDropdown = EggTab:CreateDropdown({
    Name = "How Many",
    Options = {"1", "5", "10"},
    CurrentOption = "1",
    Flag = "HowManyDropdown",
    Callback = function(Option)
        SelectedHowMany = tonumber(Option[1])
    end
})

-- Variabel untuk Auto Hatch Egg
local AutoHatchEggEnabled = false
local autoHatchEggThread = nil

-- Toggle untuk Auto Hatch Egg
local AutoHatchEggToggle = EggTab:CreateToggle({
    Name = "Auto Hatch Egg",
    CurrentValue = false,
    Flag = "AutoHatchEggToggle",
    Callback = function(Value)
        AutoHatchEggEnabled = Value
        if Value then
            if not SelectedEgg or SelectedEgg == "No Eggs Found" then
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Please select a valid Egg first!",
                    Duration = 5
                })
                AutoHatchEggToggle:Set(false)
                return
            end
            local eggName = SelectedEgg:match(":(.+)") -- Ambil nama egg setelah tanda ":"
            Rayfield:Notify({
                Title = "Auto Hatch Egg Enabled",
                Content = "Started auto hatching " .. SelectedHowMany .. " of " .. SelectedEgg,
                Duration = 5
            })
            autoHatchEggThread = spawn(function()
                while AutoHatchEggEnabled do
                    local ohNumber1 = SelectedHowMany
                    local ohString2 = eggName
                    game:GetService("ReplicatedStorage").Remotes.Event.Luck["[C-S]PlayerTryOpenEgg"]:FireServer(ohNumber1, ohString2, {})
                    wait(0.1)
                end
            end)
        else
            if autoHatchEggThread then
                coroutine.close(autoHatchEggThread)
                autoHatchEggThread = nil
            end
            Rayfield:Notify({
                Title = "Auto Hatch Egg Disabled",
                Content = "Auto Hatch Egg has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat section untuk Auto Hatch Mysterious Egg
local AutoHatchMysteriousEggSection = EggTab:CreateSection("Auto Hatch Mysterious Egg")

-- Variabel untuk Auto Hatch Mysterious Egg
local AutoHatchMysteriousEggEnabled = false
local autoHatchMysteriousEggThread = nil

-- Toggle untuk Auto Hatch Mysterious Egg
local AutoHatchMysteriousEggToggle = EggTab:CreateToggle({
    Name = "Auto Hatch Mysterious Egg",
    CurrentValue = false,
    Flag = "AutoHatchMysteriousEggToggle",
    Callback = function(Value)
        AutoHatchMysteriousEggEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Hatch Mysterious Egg Enabled",
                Content = "Started auto hatching mysterious egg every 0.1 seconds",
                Duration = 5
            })
            autoHatchMysteriousEggThread = spawn(function()
                while AutoHatchMysteriousEggEnabled do
                    local ohString1 = "Event1"
                    local ohNumber2 = 1
                    game:GetService("ReplicatedStorage").Remotes.Event.Events["[C-S]PlayerTryUseEvents"]:FireServer(ohString1, ohNumber2)
                    wait(0.1)
                end
            end)
        else
            if autoHatchMysteriousEggThread then
                coroutine.close(autoHatchMysteriousEggThread)
                autoHatchMysteriousEggThread = nil
            end
            Rayfield:Notify({
                Title = "Auto Hatch Mysterious Egg Disabled",
                Content = "Auto Hatch Mysterious Egg has been stopped",
                Duration = 5
            })
        end
    end
})

-- Membuat section untuk Auto Craft All
local AutoCraftAllSection = EggTab:CreateSection("Auto Craft All")

-- Variabel untuk Auto Craft All
local AutoCraftAllEnabled = false
local autoCraftAllThread = nil

-- Toggle untuk Auto Craft All
local AutoCraftAllToggle = EggTab:CreateToggle({
    Name = "Auto Craft All",
    CurrentValue = false,
    Flag = "AutoCraftAllToggle",
    Callback = function(Value)
        AutoCraftAllEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Craft All Enabled",
                Content = "Started auto crafting all pets every 1 second",
                Duration = 5
            })
            autoCraftAllThread = spawn(function()
                while AutoCraftAllEnabled do
                    game:GetService("ReplicatedStorage").Remotes.Event.Pet["[C-S]PlayerTryCraftAllPet"]:FireServer()
                    wait(1)
                end
            end)
        else
            if autoCraftAllThread then
                coroutine.close(autoCraftAllThread)
                autoCraftAllThread = nil
            end
            Rayfield:Notify({
                Title = "Auto Craft All Disabled",
                Content = "Auto Craft All has been stopped",
                Duration = 5
            })
        end
    end
})

-- Notifikasi saat script selesai dimuat
Rayfield:Notify({
    Title = "Script Loaded",
    Content = "[🥚EVENT!] Ride Race script has been loaded successfully!",
    Duration = 5
})