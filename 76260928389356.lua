-- ========== ANTI-BYPASS (PASTE DI ATAS SEMUA KODE!) ==========
-- (COPY FULL BLOCK `validateAccess()` dari test.lua di atas)
-- ...
if not validateAccess() then
    LocalPlayer:Kick("🚫 DIRECT ACCESS BLOCKED! Use KeySystem.lua")
    return
end
-- ==============================================================

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
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GuitarSimulatorSetting",
        FileName = "GuitarSimulatorConfig"
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
        FileName = "GuitarSimulatorKey",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/rBybCAsw"}
    }
})

-- Membuat tab Main
local MainTab = Window:CreateTab("Main")

-- Membuat section Auto
local AutoSection = MainTab:CreateSection("Auto Features")

-- Variabel untuk Auto Tap
local AutoTapEnabled = false
local autoTapThread = nil

-- Toggle untuk Auto Tap
local AutoTapToggle = MainTab:CreateToggle({
    Name = "Auto Tap",
    CurrentValue = false,
    Flag = "AutoTapToggle",
    Callback = function(Value)
        AutoTapEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Tap Enabled",
                Content = "Started auto tapping every 0.001 seconds",
                Duration = 5
            })
            autoTapThread = spawn(function()
                while AutoTapEnabled do
                    local args = {"Tap"}
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("TapEvent"):FireServer(unpack(args))
                    end)
                    if not ok then
                        Rayfield:Notify({
                            Title = "Auto Tap Error",
                            Content = "Failed to trigger tap: " .. tostring(err),
                            Duration = 5
                        })
                        AutoTapEnabled = false
                        AutoTapToggle:Set(false)
                        break
                    end
                    wait()
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Tap Disabled",
                Content = "Auto Tap has been stopped",
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
                Content = "Started auto claiming gifts every 1 second",
                Duration = 5
            })
            autoClaimGiftThread = spawn(function()
                while AutoClaimGiftEnabled do
                    local args = {"ClaimAll", 1}
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("PlayTimeGiftsEvent"):FireServer(unpack(args))
                    end)
                    if not ok then
                        Rayfield:Notify({
                            Title = "Auto Claim Gift Error",
                            Content = "Failed to claim gift: " .. tostring(err),
                            Duration = 5
                        })
                        AutoClaimGiftEnabled = false
                        AutoClaimGiftToggle:Set(false)
                        break
                    end
                    wait(1)
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
                Content = "Started auto rebirth every 1 second",
                Duration = 5
            })
            autoRebirthThread = spawn(function()
                while AutoRebirthEnabled do
                    local args = {"Rebirth"}
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("RebirthsEvent"):FireServer(unpack(args))
                    end)
                    if not ok then
                        Rayfield:Notify({
                            Title = "Auto Rebirth Error",
                            Content = "Failed to trigger rebirth: " .. tostring(err),
                            Duration = 5
                        })
                        AutoRebirthEnabled = false
                        AutoRebirthToggle:Set(false)
                        break
                    end
                    wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Rebirth Disabled",
                Content = "Auto Rebirth has been stopped",
                Duration = 5
            })
        end
    end
})

-- Variabel untuk Auto Buy Guitars
local AutoBuyGuitarsEnabled = false
local autoBuyGuitarsThread = nil

-- Mendapatkan daftar area dari GuitarShopStats
local guitarShopStats = require(game:GetService("ReplicatedStorage").StatsModules.GuitarShopStats)
local guitarAreas = {}
for area, _ in pairs(guitarShopStats) do
    table.insert(guitarAreas, area)
end

-- Toggle untuk Auto Buy Guitars
local AutoBuyGuitarsToggle = MainTab:CreateToggle({
    Name = "Auto Buy Guitars",
    CurrentValue = false,
    Flag = "AutoBuyGuitarsToggle",
    Callback = function(Value)
        AutoBuyGuitarsEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Buy Guitars Enabled",
                Content = "Started auto buying guitars for all areas",
                Duration = 5
            })
            autoBuyGuitarsThread = spawn(function()
                while AutoBuyGuitarsEnabled do
                    for _, area in ipairs(guitarAreas) do
                        local args = {"BuyAll", area}
                        local ok, err = pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("GuitarShopEvent"):FireServer(unpack(args))
                        end)
                        if not ok then
                            Rayfield:Notify({
                                Title = "Auto Buy Guitars Error",
                                Content = "Failed to buy guitars for " .. area .. ": " .. tostring(err),
                                Duration = 5
                            })
                            AutoBuyGuitarsEnabled = false
                            AutoBuyGuitarsToggle:Set(false)
                            break
                        end
                        wait(0.1)
                    end
                    wait(10)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Buy Guitars Disabled",
                Content = "Auto Buy Guitars has been stopped",
                Duration = 5
            })
        end
    end
})

-- Variabel untuk Auto Collect Ruby
local AutoCollectRubyEnabled = false
local autoCollectRubyThread = nil

-- Toggle untuk Auto Collect Ruby
local AutoCollectRubyToggle = MainTab:CreateToggle({
    Name = "Auto Collect Ruby",
    CurrentValue = false,
    Flag = "AutoCollectRubyToggle",
    Callback = function(Value)
        AutoCollectRubyEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Collect Ruby Enabled",
                Content = "Started collecting rubies",
                Duration = 5
            })
            autoCollectRubyThread = spawn(function()
                local player = game:GetService("Players").LocalPlayer
                while AutoCollectRubyEnabled do
                    local collectablesFolder = workspace:FindFirstChild("Scriptable") and workspace.Scriptable:FindFirstChild("Collectables")
                    if collectablesFolder then
                        for _, collectable in ipairs(collectablesFolder:GetChildren()) do
                            if not AutoCollectRubyEnabled then break end
                            if collectable:IsA("Model") and collectable.PrimaryPart then
                                local character = player.Character
                                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                                if rootPart then
                                    collectable:SetPrimaryPartCFrame(rootPart.CFrame * CFrame.new(0, 1, 0))
                                end
                                wait(0.1) -- Delay kecil untuk mencegah overload
                            end
                        end
                    else
                        Rayfield:Notify({
                            Title = "Auto Collect Warning",
                            Content = "Collectables folder not found",
                            Duration = 5
                        })
                    end
                    wait(1) -- Delay loop utama
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Collect Ruby Disabled",
                Content = "Auto Collect Ruby has been stopped",
                Duration = 5
            })
        end
    end
})

-- Variabel untuk Auto Collect Pumpkin
local AutoCollectEnabled = false
local autoCollectThread = nil

-- Toggle untuk Auto Collect Pumpkin
local AutoCollectToggle = MainTab:CreateToggle({
    Name = "Auto Collect Pumpkin",
    CurrentValue = false,
    Flag = "AutoCollectToggle",
    Callback = function(Value)
        AutoCollectEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Collect Enabled",
                Content = "Started collecting pumpkins",
                Duration = 5
            })
            autoCollectThread = spawn(function()
                local player = game:GetService("Players").LocalPlayer
                while AutoCollectEnabled do
                    -- Cek kedua folder Coins (Bubble dan Bubble2)
                    local coinsFolders = {
                        workspace.Scriptable:FindFirstChild("CollectableCoins") and 
                        workspace.Scriptable.CollectableCoins:FindFirstChild("Bubble") and 
                        workspace.Scriptable.CollectableCoins.Bubble:FindFirstChild("Coins"),
                        workspace.Scriptable:FindFirstChild("CollectableCoins") and 
                        workspace.Scriptable.CollectableCoins:FindFirstChild("Bubble2") and 
                        workspace.Scriptable.CollectableCoins.Bubble2:FindFirstChild("Coins")
                    }
                    
                    for _, coinsFolder in ipairs(coinsFolders) do
                        if coinsFolder then
                            for _, coin in ipairs(coinsFolder:GetChildren()) do
                                if not AutoCollectEnabled then break end
                                if coin:IsA("Model") and coin.PrimaryPart then
                                    local character = player.Character
                                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                                    if rootPart then
                                        coin:SetPrimaryPartCFrame(rootPart.CFrame * CFrame.new(0, 1, 0))
                                    end
                                    wait(0.1) -- Delay kecil untuk mencegah overload
                                end
                            end
                        else
                            Rayfield:Notify({
                                Title = "Auto Collect Warning",
                                Content = "One or more coins folders not found",
                                Duration = 5
                            })
                        end
                    end
                    wait(0.1) -- Delay loop utama
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Collect Disabled",
                Content = "Auto collecting has been stopped",
                Duration = 5
            })
        end
    end
})

-- Variabel untuk Auto TrickOrTreat
local AutoTrickOrTreatEnabled = false
local autoTrickOrTreatThread = nil

-- Toggle untuk Auto TrickOrTreat
local AutoTrickOrTreatToggle = MainTab:CreateToggle({
    Name = "Auto TrickOrTreat",
    CurrentValue = false,
    Flag = "AutoTrickOrTreatToggle",
    Callback = function(Value)
        AutoTrickOrTreatEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto TrickOrTreat Enabled",
                Content = "Started TrickOrTreat automation",
                Duration = 5
            })
            autoTrickOrTreatThread = spawn(function()
                local player = game:GetService("Players").LocalPlayer
                while AutoTrickOrTreatEnabled do
                    -- Daftar path yang akan diperiksa
                    local pathsToCheck = {
                        workspace:GetChildren()[102],
                        workspace:FindFirstChild("TrickOrTreat"),
                        workspace:GetChildren()[82],
                        workspace:GetChildren()[112]
                    }
                    
                    for _, path in ipairs(pathsToCheck) do
                        if not AutoTrickOrTreatEnabled then break end
                        if path then
                            -- Cari TouchInterest secara rekursif di dalam path
                            local function findTouchInterest(obj)
                                for _, child in ipairs(obj:GetDescendants()) do
                                    if child:IsA("TouchTransmitter") and child.Name == "TouchInterest" then
                                        local character = player.Character
                                        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                                        if rootPart then
                                            firetouchinterest(rootPart, child.Parent, 0)
                                            wait(0.1)
                                            firetouchinterest(rootPart, child.Parent, 1)
                                        end
                                    end
                                end
                            end
                            findTouchInterest(path)
                        end
                    end
                    
                    -- Notifikasi jika tidak ada path yang valid
                    if not pathsToCheck[1] and not pathsToCheck[2] and not pathsToCheck[3] and not pathsToCheck[4] then
                        Rayfield:Notify({
                            Title = "Auto TrickOrTreat Warning",
                            Content = "No valid TrickOrTreat paths found",
                            Duration = 5
                        })
                    end
                    wait(60) -- Tunggu 60 detik sebelum siklus berikutnya
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto TrickOrTreat Disabled",
                Content = "Auto TrickOrTreat has been stopped",
                Duration = 5
            })
        end
    end
})

-- Variabel untuk Auto TrickOrTreat v2
local AutoTrickOrTreatV2Enabled = false
local autoTrickOrTreatV2Thread = nil

-- Toggle untuk Auto TrickOrTreat v2
local AutoTrickOrTreatV2Toggle = MainTab:CreateToggle({
    Name = "Auto TrickOrTreat v2",
    CurrentValue = false,
    Flag = "AutoTrickOrTreatV2Toggle",
    Callback = function(Value)
        AutoTrickOrTreatV2Enabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto TrickOrTreat v2 Enabled",
                Content = "Started TrickOrTreat v2 automation",
                Duration = 5
            })
            autoTrickOrTreatV2Thread = spawn(function()
                local player = game:GetService("Players").LocalPlayer
                while AutoTrickOrTreatV2Enabled do
                    -- Cari semua BillboardGui di workspace
                    local foundFreePumpkins = false
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if not AutoTrickOrTreatV2Enabled then break end
                        local description = obj:IsA("BillboardGui") and 
                                           obj:FindFirstChild("Description") and 
                                           obj.Description:IsA("TextLabel") and 
                                           obj.Description.Text == "Free Pumpkins!"
                        if description then
                            foundFreePumpkins = true
                            -- Cari semua Trigger di workspace
                            local triggers = {}
                            for _, path in ipairs(workspace:GetDescendants()) do
                                if path.Name == "Trigger" and path.Parent.Name == "sellarea" then
                                    table.insert(triggers, path)
                                end
                            end
                            -- Teleport ke setiap Trigger
                            local character = player.Character
                            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                            if rootPart then
                                for _, trigger in ipairs(triggers) do
                                    if not AutoTrickOrTreatV2Enabled then break end
                                    rootPart.CFrame = trigger.CFrame * CFrame.new(0, 3, 0) -- Teleport di atas Trigger
                                    wait(0.1) -- Delay kecil untuk memastikan interaksi
                                end
                            end
                            break -- Keluar dari loop setelah menemukan "Free Pumpkins!"
                        end
                    end
                    
                    if not foundFreePumpkins then
                        Rayfield:Notify({
                            Title = "Auto TrickOrTreat v2 Warning",
                            Content = "'Free Pumpkins!' not found",
                            Duration = 5
                        })
                    end
                    wait(60) -- Tunggu 60 detik sebelum memeriksa lagi
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto TrickOrTreat v2 Disabled",
                Content = "Auto TrickOrTreat v2 has been stopped",
                Duration = 5
            })
        end
    end
})



-- Variabel untuk Auto Activate Pharaohs Curse
local AutoPharaohsCurseEnabled = false
local autoPharaohsCurseThread = nil
local notifiedCooldown = false

-- Toggle untuk Auto Activate Pharaohs Curse
local AutoPharaohsCurseToggle = MainTab:CreateToggle({
    Name = "Auto Pharaohs Curse",
    CurrentValue = false,
    Flag = "AutoPharaohsCurseToggle",
    Callback = function(Value)
        AutoPharaohsCurseEnabled = Value
        notifiedCooldown = false
        if Value then
            Rayfield:Notify({
                Title = "Auto Pharaohs Curse Enabled",
                Content = "Started auto activating Pharaohs Curse when ready",
                Duration = 5
            })
            autoPharaohsCurseThread = spawn(function()
                while AutoPharaohsCurseEnabled do
                    local cooldownGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main")
                    local pharaohFrame = cooldownGui and cooldownGui:FindFirstChild("Frames") and cooldownGui.Frames:FindFirstChild("PharaohsCurse")
                    local main = pharaohFrame and pharaohFrame:FindFirstChild("Main")
                    local cooldownText = main and main:FindFirstChild("Cooldown")
                    if cooldownText then
                        local text = cooldownText.Text
                        if text == "READY" then
                            local args = {"Activate", "Pharaohs Curse"}
                            local ok, err = pcall(function()
                                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("PharaohEvent"):FireServer(unpack(args))
                            end)
                            if ok then
                                wait(1)
                                text = cooldownText.Text
                                if text ~= "READY" and not notifiedCooldown then
                                    Rayfield:Notify({
                                        Title = "Pharaohs Curse Activated",
                                        Content = "Cooldown: " .. text,
                                        Duration = 5
                                    })
                                    notifiedCooldown = true
                                end
                            else
                                Rayfield:Notify({
                                    Title = "Pharaohs Curse Error",
                                    Content = "Failed to activate: " .. tostring(err),
                                    Duration = 5
                                })
                            end
                        elseif text ~= "READY" then
                            notifiedCooldown = false
                        end
                    end
                    wait(1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Pharaohs Curse Disabled",
                Content = "Auto Pharaohs Curse has been stopped",
                Duration = 5
            })
        end
    end
})

-- Tab
local ConcertTab = Window:CreateTab("Concert")
local ConcertSection = ConcertTab:CreateSection("Concert Features")

-- Dropdown Concert Type
local concertChooseList = {"1", "2", "5"}
local selectedConcertChoose = concertChooseList[1]
local ConcertChooseDropdown = ConcertTab:CreateDropdown({
    Name = "Choose Concert Type",
    Options = concertChooseList,
    CurrentOption = selectedConcertChoose,
    Flag = "ConcertChooseDropdown",
    Callback = function(Option)
        local opt = (typeof(Option) == "table") and Option[1] or Option
        selectedConcertChoose = tostring(opt)
        Rayfield:Notify({
            Title = "Concert Type Selected",
            Content = "Selected concert type: " .. tostring(selectedConcertChoose),
            Duration = 5
        })
    end
})

----------------------------------------------------------------
-- AUTO CONCERT (PC)
----------------------------------------------------------------
local AutoConcertEnabled = false
local isWaitingConcertRestart = false
local autoConcertThread = nil

local function getConcertArgs()
    if selectedConcertChoose == "1" then
        return {"Start"}
    elseif selectedConcertChoose == "2" then
        return {"Start", nil, 2}
    elseif selectedConcertChoose == "5" then
        return {"Start", nil, 5}
    end
end

local AutoConcertToggle = ConcertTab:CreateToggle({
    Name = "Auto Concert",
    CurrentValue = false,
    Flag = "AutoConcertToggle",
    Callback = function(Value)
        AutoConcertEnabled = Value
        if Value then
            Rayfield:Notify({Title="Auto Concert Enabled", Content="Starting auto concert and monitoring falling circles", Duration=5})

            -- Start concert
            local ok, err = pcall(function()
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Events")
                    :WaitForChild("RemoteEvents")
                    :WaitForChild("ConcertEvent"):FireServer(unpack(getConcertArgs()))
            end)
            if not ok then
                Rayfield:Notify({Title="Auto Concert Start Error", Content=tostring(err), Duration=5})
                AutoConcertEnabled = false
                Rayfield.Flags["AutoConcertToggle"]:Set(false)
                return
            end

            -- Monitoring loop
            autoConcertThread = spawn(function()
                while AutoConcertEnabled do
                    local gui = game:GetService("Players").LocalPlayer.PlayerGui
                    local main = gui:FindFirstChild("Main")
                    local concerts = main and main:FindFirstChild("Concerts")
                    local leftFrame = concerts and concerts:FindFirstChild("Left")
                    local frame = concerts and concerts:FindFirstChild("Main")
                    local fallingCircles = frame and frame:FindFirstChild("FallingCircles")
                    
                    -- Monitoring Circles
                    if AutoConcertEnabled and not isWaitingConcertRestart and fallingCircles and #fallingCircles:GetChildren() > 0 then
                        for _, circle in ipairs(fallingCircles:GetChildren()) do
                            if circle:IsA("ImageLabel") then
                                local xScale = circle.Position.X.Scale
                                local key = (xScale < 0.25 and "C") or (xScale < 0.5 and "V") or (xScale < 0.75 and "B") or "N"
                                if circle.Position.Y.Scale > 0.8 then
                                    local args = {"Judgement",{CircleID = circle.Name,Key = key,Judgement="Perfect"}}
                                    pcall(function()
                                        game:GetService("ReplicatedStorage")
                                            :WaitForChild("Events"):WaitForChild("RemoteEvents")
                                            :WaitForChild("ConcertEvent"):FireServer(unpack(args))
                                    end)
                                end
                            end
                        end
                    end

                    -- Restart Logic
                    if AutoConcertEnabled and not isWaitingConcertRestart and leftFrame and leftFrame.Text == "Time Left: 0" and (not fallingCircles or #fallingCircles:GetChildren() == 0) then
                        isWaitingConcertRestart = true
                        Rayfield:Notify({Title="Auto Concert", Content="Waiting for next concert, 10 seconds remaining", Duration=10})

                        -- Countdown (stop if toggle off)
                        for i=1,100 do
                            if not AutoConcertEnabled then isWaitingConcertRestart=false return end
                            wait(0.1)
                        end
                        if not AutoConcertEnabled then isWaitingConcertRestart=false return end

                        -- Fire restart
                        local restartOk, restartErr = pcall(function()
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events"):WaitForChild("RemoteEvents")
                                :WaitForChild("ConcertEvent"):FireServer(unpack(getConcertArgs()))
                        end)
                        if not restartOk then
                            Rayfield:Notify({Title="Restart Error", Content=tostring(restartErr), Duration=5})
                            AutoConcertEnabled=false
                            Rayfield.Flags["AutoConcertToggle"]:Set(false)
                            return
                        end

                        -- Tunggu UI baru muncul sebelum reset flag
                        local foundNew=false
                        local startTick=tick()
                        repeat
                            if not AutoConcertEnabled then return end
                            local g=game:GetService("Players").LocalPlayer.PlayerGui
                            local m=g:FindFirstChild("Main")
                            local c=m and m:FindFirstChild("Concerts")
                            local f=c and c:FindFirstChild("Main")
                            local newCir=f and f:FindFirstChild("FallingCircles")
                            if newCir and #newCir:GetChildren()>0 then foundNew=true break end
                            wait(0.1)
                        until tick()-startTick>10
                        
                        if foundNew then
                            Rayfield:Notify({Title="Auto Concert Restarted", Content="Concert resumed successfully", Duration=5})
                            isWaitingConcertRestart=false
                        else
                            Rayfield:Notify({Title="Restart Error", Content="No new UI detected, stopping", Duration=5})
                            AutoConcertEnabled=false
                            Rayfield.Flags["AutoConcertToggle"]:Set(false)
                        end
                    end
                    wait(0.01)
                end
            end)
        else
            Rayfield:Notify({Title="Auto Concert Disabled",Content="Stopped",Duration=5})
            isWaitingConcertRestart = false
        end
    end
})

local AutoConcertMobileEnabled = false
local isWaitingConcertMobileRestart = false

local AutoConcertMobileToggle = ConcertTab:CreateToggle({
    Name = "Auto Concert (Mobile)",
    CurrentValue = false,
    Flag = "AutoConcertMobileToggle",
    Callback = function(Value)
        AutoConcertMobileEnabled = Value
        if Value then
            Rayfield:Notify({Title = "Auto Concert Mobile Enabled", Content = "Starting auto concert Mobile and monitoring falling circles", Duration = 5})

            -- Start concert
            local ok, err = pcall(function()
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Events")
                    :WaitForChild("RemoteEvents")
                    :WaitForChild("ConcertEvent"):FireServer(unpack(getConcertArgs()))
            end)
            if not ok then
                Rayfield:Notify({Title = "Auto Concert Mobile Start Error", Content = tostring(err), Duration = 5})
                AutoConcertMobileEnabled = false
                Rayfield.Flags["AutoConcertMobileToggle"]:Set(false)
                return
            end

            -- Monitoring loop
            autoConcertMobileThread = spawn(function()
                while AutoConcertMobileEnabled do
                    local gui = game:GetService("Players").LocalPlayer.PlayerGui
                    local main = gui:FindFirstChild("Main")
                    local concertsMobile = main and main:FindFirstChild("ConcertsMobile")
                    local leftFrame = concertsMobile and concertsMobile:FindFirstChild("Left")
                    local frame = concertsMobile and concertsMobile:FindFirstChild("Main")
                    local fallingCircles = frame and frame:FindFirstChild("FallingCircles")

                    -- Monitoring Circles
                    if AutoConcertMobileEnabled and not isWaitingConcertMobileRestart and fallingCircles and #fallingCircles:GetChildren() > 0 then
                        for _, circle in ipairs(fallingCircles:GetChildren()) do
                            if circle:IsA("ImageLabel") then
                                local xScale = circle.Position.X.Scale
                                local key = (xScale < 0.25 and "C") or (xScale < 0.5 and "V") or (xScale < 0.75 and "B") or "N"
                                if circle.Position.Y.Scale > 0.8 then
                                    local args = {"Judgement", {CircleID = circle.Name, Key = key, Judgement = "Perfect"}}
                                    pcall(function()
                                        game:GetService("ReplicatedStorage")
                                            :WaitForChild("Events"):WaitForChild("RemoteEvents")
                                            :WaitForChild("ConcertEvent"):FireServer(unpack(args))
                                    end)
                                end
                            end
                        end
                    end

                    -- Restart Logic
                    if AutoConcertMobileEnabled and not isWaitingConcertMobileRestart and leftFrame and leftFrame.Text == "Time Left: 0" and (not fallingCircles or #fallingCircles:GetChildren() == 0) then
                        isWaitingConcertMobileRestart = true
                        Rayfield:Notify({Title = "Auto Concert Mobile", Content = "Waiting for next concert, 10 seconds remaining", Duration = 10})

                        -- Countdown (stop if toggle off)
                        for i = 1, 100 do
                            if not AutoConcertMobileEnabled then
                                isWaitingConcertMobileRestart = false
                                return
                            end
                            wait(0.1)
                        end

                        -- Fire restart
                        local restartOk, restartErr = pcall(function()
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Events"):WaitForChild("RemoteEvents")
                                :WaitForChild("ConcertEvent"):FireServer(unpack(getConcertArgs()))
                        end)
                        if not restartOk then
                            Rayfield:Notify({Title = "Restart Error", Content = tostring(restartErr), Duration = 5})
                            AutoConcertMobileEnabled = false
                            Rayfield.Flags["AutoConcertMobileToggle"]:Set(false)
                            return
                        end

                        -- Wait for new UI to appear
                        local foundNew = false
                        local startTick = tick()
                        repeat
                            if not AutoConcertMobileEnabled then
                                isWaitingConcertMobileRestart = false
                                return
                            end
                            local g = game:GetService("Players").LocalPlayer.PlayerGui
                            local m = g:FindFirstChild("Main")
                            local c = m and m:FindFirstChild("ConcertsMobile")
                            local f = c and c:FindFirstChild("Main")
                            local newCir = f and f:FindFirstChild("FallingCircles")
                            if newCir and #newCir:GetChildren() > 0 then
                                foundNew = true
                                break
                            end
                            wait(0.1)
                        until tick() - startTick > 10

                        if foundNew then
                            Rayfield:Notify({Title = "Auto Concert Restarted", Content = "Concert resumed successfully, monitoring circles", Duration = 5})
                            isWaitingConcertMobileRestart = false
                        else
                            Rayfield:Notify({Title = "Restart Error", Content = "No new UI detected, stopping", Duration = 5})
                            AutoConcertMobileEnabled = false
                            Rayfield.Flags["AutoConcertMobileToggle"]:Set(false)
                            return
                        end
                    end
                    wait(0.01)
                end
            end)
        else
            Rayfield:Notify({Title = "Auto Concert Mobile Disabled", Content = "Stopped", Duration = 5})
            isWaitingConcertMobileRestart = false
        end
    end
})

-- Variabel untuk Auto Buy All Market
local AutoBuyAllMarketEnabled = false
local autoBuyAllMarketThread = nil

-- Toggle untuk Auto Buy All Market
local AutoBuyAllMarketToggle = MainTab:CreateToggle({
    Name = "Auto Buy All Market",
    CurrentValue = false,
    Flag = "AutoBuyAllMarketToggle",
    Callback = function(Value)
        AutoBuyAllMarketEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Buy All Market Enabled",
                Content = "Started auto buying all market items every 5 minutes",
                Duration = 5
            })
            autoBuyAllMarketThread = spawn(function()
                while AutoBuyAllMarketEnabled do
                    for i = 1, 3 do
                        local args = {"BuyAll", {"Rubies", i}}
                        local ok, err = pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("MarketEvent"):FireServer(unpack(args))
                        end)
                        if not ok then
                            Rayfield:Notify({
                                Title = "Auto Buy All Market Error",
                                Content = "Failed to buy all market items: " .. tostring(err),
                                Duration = 5
                            })
                        end
                    end
                    wait(300)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Buy All Market Disabled",
                Content = "Auto Buy All Market has been stopped",
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
                Content = "Started auto spinning every 0.1 seconds",
                Duration = 5
            })
            autoSpinThread = spawn(function()
                while AutoSpinEnabled do
                    local args = {"Spin", "Normal"}
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteFunctions"):WaitForChild("SpinTheWheelFunction"):InvokeServer(unpack(args))
                    end)
                    if not ok then
                        Rayfield:Notify({
                            Title = "Auto Spin Error",
                            Content = "Failed to spin: " .. tostring(err),
                            Duration = 5
                        })
                        AutoSpinEnabled = false
                        AutoSpinToggle:Set(false)
                        break
                    end
                    wait(0.1)
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

-- Membuat section Claim
local ClaimSection = MainTab:CreateSection("Claim Features")

-- Variabel untuk Auto Claim Autumn-Candy-Ticket Rewards
local AutoClaimAutumnCandyTicketRewardsEnabled = false
local autoClaimAutumnCandyTicketRewardsThread = nil

-- Toggle untuk Auto Claim Autumn-Candy-Ticket Rewards
local AutoClaimAutumnCandyTicketRewardsToggle = MainTab:CreateToggle({
    Name = "Auto Claim Autumn-Candy-Ticket Rewards",
    CurrentValue = false,
    Flag = "AutoClaimAutumnCandyTicketRewardsToggle",
    Callback = function(Value)
        AutoClaimAutumnCandyTicketRewardsEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Claim Autumn-Candy-Ticket Rewards Enabled",
                Content = "Started auto claiming Autumn-Candy-Ticket Rewards",
                Duration = 5
            })
            autoClaimAutumnCandyTicketRewardsThread = spawn(function()
                while AutoClaimAutumnCandyTicketRewardsEnabled do
                    local argsAutumn = {"Claim", "Autumn Rewards"}
                    local okAutumn, errAutumn = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("ChestEvent"):FireServer(unpack(argsAutumn))
                    end)
                    if not okAutumn then
                        Rayfield:Notify({
                            Title = "Auto Claim Autumn Rewards Error",
                            Content = "Failed to claim Autumn Rewards: " .. tostring(errAutumn),
                            Duration = 5
                        })
                    end

                    local argsCandy = {"Claim", "Candy Rewards"}
                    local okCandy, errCandy = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("ChestEvent"):FireServer(unpack(argsCandy))
                    end)
                    if not okCandy then
                        Rayfield:Notify({
                            Title = "Auto Claim Candy Rewards Error",
                            Content = "Failed to claim Candy Rewards: " .. tostring(errCandy),
                            Duration = 5
                        })
                    end

                    local argsTicket = {"Claim", "Ticket Chest"}
                    local okTicket, errTicket = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("ChestEvent"):FireServer(unpack(argsTicket))
                    end)
                    if not okTicket then
                        Rayfield:Notify({
                            Title = "Auto Claim Ticket Rewards Error",
                            Content = "Failed to claim Ticket Rewards: " .. tostring(errTicket),
                            Duration = 5
                        })
                    end

                    wait(900)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Claim Autumn-Candy-Ticket Rewards Disabled",
                Content = "Auto Claim Autumn-Candy-Ticket Rewards has been stopped",
                Duration = 5
            })
        end
    end
})

-- Variabel untuk Auto Claim Vip Chest
local AutoClaimVipChestEnabled = false
local autoClaimVipChestThread = nil

-- Toggle untuk Auto Claim Vip Chest
local AutoClaimVipChestToggle = MainTab:CreateToggle({
    Name = "Auto Claim Vip Chest",
    CurrentValue = false,
    Flag = "AutoClaimVipChestToggle",
    Callback = function(Value)
        AutoClaimVipChestEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Claim Vip Chest Enabled",
                Content = "Started auto claiming Vip Chest every 30 minutes",
                Duration = 5
            })
            autoClaimVipChestThread = spawn(function()
                while AutoClaimVipChestEnabled do
                    local args = {"Claim", "Vip Chest"}
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("ChestEvent"):FireServer(unpack(args))
                    end)
                    if not ok then
                        Rayfield:Notify({
                            Title = "Auto Claim Vip Chest Error",
                            Content = "Failed to claim Vip Chest: " .. tostring(err),
                            Duration = 5
                        })
                        AutoClaimVipChestEnabled = false
                        AutoClaimVipChestToggle:Set(false)
                        break
                    end
                    wait(1800)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Claim Vip Chest Disabled",
                Content = "Auto Claim Vip Chest has been stopped",
                Duration = 5
            })
        end
    end
})

-- Variabel untuk Auto Claim Group Chest
local AutoClaimGroupChestEnabled = false
local autoClaimGroupChestThread = nil

-- Toggle untuk Auto Claim Group Chest
local AutoClaimGroupChestToggle = MainTab:CreateToggle({
    Name = "Auto Claim Group Chest",
    CurrentValue = false,
    Flag = "AutoClaimGroupChestToggle",
    Callback = function(Value)
        AutoClaimGroupChestEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Claim Group Chest Enabled",
                Content = "Started auto claiming Group Chest every 30 minutes",
                Duration = 5
            })
            autoClaimGroupChestThread = spawn(function()
                while AutoClaimGroupChestEnabled do
                    local args = {"Claim", "Group Chest"}
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("ChestEvent"):FireServer(unpack(args))
                    end)
                    if not ok then
                        Rayfield:Notify({
                            Title = "Auto Claim Group Chest Error",
                            Content = "Failed to claim Group Chest: " .. tostring(err),
                            Duration = 5
                        })
                        AutoClaimGroupChestEnabled = false
                        AutoClaimGroupChestToggle:Set(false)
                        break
                    end
                    wait(1800)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Claim Group Chest Disabled",
                Content = "Auto Claim Group Chest has been stopped",
                Duration = 5
            })
        end
    end
})

-- Mendapatkan daftar kode dari CodesStats
local codesStats = require(game:GetService("ReplicatedStorage").StatsModules.CodesStats)
local codeList = {}
for code, _ in pairs(codesStats) do
    table.insert(codeList, code)
end

-- Button untuk Auto Redeem Code
local AutoRedeemCodeButton = MainTab:CreateButton({
    Name = "Auto Redeem Code",
    Callback = function()
        for _, code in ipairs(codeList) do
            local args = {"Redeem", code}
            local ok, err = pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("CodesEvent"):FireServer(unpack(args))
            end)
            if ok then
                Rayfield:Notify({
                    Title = "Code Redeemed",
                    Content = "Successfully redeemed code: " .. code,
                    Duration = 5
                })
            else
                Rayfield:Notify({
                    Title = "Auto Redeem Code Error",
                    Content = "Failed to redeem code " .. code .. ": " .. tostring(err),
                    Duration = 5
                })
            end
            wait(0.1)
        end
    end
})

-- Button untuk Claim Day 7 Pet
local ClaimDay7PetButton = MainTab:CreateButton({
    Name = "Claim Day 7 Pet",
    Callback = function()
        local args = {"Claim", "7"}
        local ok, err = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("DaysPetEvent"):FireServer(unpack(args))
        end)
        if ok then
            Rayfield:Notify({
                Title = "Day 7 Pet Claimed",
                Content = "Successfully claimed Day 7 Pet",
                Duration = 5
            })
        else
            Rayfield:Notify({
                Title = "Claim Day 7 Pet Error",
                Content = "Failed to claim Day 7 Pet: " .. tostring(err),
                Duration = 5
            })
        end
    end
})

-- Membuat tab Egg
local EggTab = Window:CreateTab("Egg")

-- Membuat section Hatch
local HatchSection = EggTab:CreateSection("Hatch Features")

-- Mendapatkan daftar egg dari workspace
local eggList = {}
do
    local eggsFolder = workspace:FindFirstChild("Scriptable") and workspace.Scriptable:FindFirstChild("Eggs")
    if eggsFolder then
        for _, egg in pairs(eggsFolder:GetChildren()) do
            table.insert(eggList, egg.Name)
        end
    end
end

-- Fungsi untuk mendapatkan CFrame dari egg model berdasarkan Gui atau fallback
local function resolveEggTeleportCFrame(eggModel)
    if not eggModel then return nil end

    -- Mencari Gui secara rekursif (misalnya, di dalam Builds)
    local function findGui(model)
        for _, child in pairs(model:GetDescendants()) do
            if child.Name == "Gui" and child:IsA("BasePart") then
                return child.CFrame
            end
        end
        return nil
    end

    local targetCF = findGui(eggModel)
    if targetCF then
        Rayfield:Notify({
            Title = "Debug: Success",
            Content = "Found Gui Part in " .. tostring(selectedEgg),
            Duration = 5
        })
        return targetCF
    end

    -- Fallback jika Gui tidak ditemukan: Gunakan PrimaryPart atau BasePart pertama
    local primaryPart = eggModel.PrimaryPart
    if primaryPart and primaryPart:IsA("BasePart") then
        Rayfield:Notify({
            Title = "Debug: Fallback",
            Content = "Using PrimaryPart in " .. tostring(selectedEgg),
            Duration = 5
        })
        return primaryPart.CFrame
    end

    for _, part in pairs(eggModel:GetDescendants()) do
        if part:IsA("BasePart") then
            Rayfield:Notify({
                Title = "Debug: Fallback",
                Content = "Using first BasePart in " .. tostring(selectedEgg),
                Duration = 5
            })
            return part.CFrame
        end
    end

    Rayfield:Notify({
        Title = "Debug: Failure",
        Content = "No valid Part found in " .. tostring(selectedEgg),
        Duration = 5
    })
    return nil
end

-- Dropdown untuk Egg
local selectedEgg = eggList[1] or "Common Egg"
local EggDropdown = EggTab:CreateDropdown({
    Name = "Select Egg",
    Options = eggList,
    CurrentOption = selectedEgg,
    Flag = "EggDropdown",
    Callback = function(Option)
        local opt = (typeof(Option) == "table") and Option[1] or Option
        selectedEgg = tostring(opt)

        local eggsFolder = workspace:FindFirstChild("Scriptable") and workspace.Scriptable:FindFirstChild("Eggs")
        local eggModel = eggsFolder and eggsFolder:FindFirstChild(selectedEgg)

        local playerModel = workspace:FindFirstChild(game:GetService("Players").LocalPlayer.Name)
        local root = playerModel and (playerModel:FindFirstChild("HumanoidRootPart") or playerModel:FindFirstChildWhichIsA("BasePart"))

        if not eggModel or not root then
            Rayfield:Notify({
                Title = "Teleport Error",
                Content = (not eggModel and "Egg not found: " .. tostring(selectedEgg) or "Character/RootPart not found in workspace"),
                Duration = 5
            })
            return
        end

        local targetCF = resolveEggTeleportCFrame(eggModel)
        if not targetCF then
            Rayfield:Notify({
                Title = "Teleport Error",
                Content = "No valid Part found in egg: " .. tostring(selectedEgg),
                Duration = 5
            })
            return
        end

        local ok, err = pcall(function()
            root.CFrame = targetCF + Vector3.new(0, 5, 0)
        end)

        if ok then
            Rayfield:Notify({
                Title = "Teleported to Egg",
                Content = "Successfully teleported to: " .. tostring(selectedEgg),
                Duration = 5
            })
        else
            Rayfield:Notify({
                Title = "Teleport Error",
                Content = tostring(err),
                Duration = 5
            })
        end
    end
})

-- Dropdown untuk Choose
local chooseList = {"HatchOne", "HatchMax"}
local selectedChoose = chooseList[1]
local ChooseDropdown = EggTab:CreateDropdown({
    Name = "Choose Hatch Type",
    Options = chooseList,
    CurrentOption = selectedChoose,
    Flag = "ChooseDropdown",
    Callback = function(Option)
        local opt = (typeof(Option) == "table") and Option[1] or Option
        selectedChoose = tostring(opt)
        Rayfield:Notify({
            Title = "Hatch Type Selected",
            Content = "Selected hatch type: " .. tostring(selectedChoose),
            Duration = 5
        })
    end
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Variables
local LocalPlayer = Players.LocalPlayer
local RemoveEggAnimationEnabled = false
local removeEggAnimationThread = nil

-- Wait for Scriptable and EggAnimation to exist
local Scriptable = Workspace:WaitForChild("Scriptable")
local EggAnimation = Scriptable:WaitForChild("EggAnimation")

-- Toggle for Remove Egg Animation
local RemoveEggAnimationToggle = EggTab:CreateToggle({
    Name = "Remove Egg Animation (made by Pyrex)",
    CurrentValue = false,
    Flag = "RemoveEggAnimationToggle",
    Callback = function(Value)
        RemoveEggAnimationEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Remove Egg Animation Enabled",
                Content = "Started removing egg animations",
                Duration = 5
            })
            if EggAnimation then
                EggAnimation:ClearAllChildren()
            end
            removeEggAnimationThread = RunService.RenderStepped:Connect(function()
                if RemoveEggAnimationEnabled and EggAnimation and #EggAnimation:GetChildren() > 0 then
                    EggAnimation:ClearAllChildren()
                end
            end)
        else
            Rayfield:Notify({
                Title = "Remove Egg Animation Disabled",
                Content = "Egg animation removal stopped",
                Duration = 5
            })
            if removeEggAnimationThread then
                removeEggAnimationThread:Disconnect()
                removeEggAnimationThread = nil
            end
        end
    end
})

-- Variabel untuk Auto Buy Egg
local AutoBuyEggEnabled = false
local autoBuyEggThread = nil

-- Toggle untuk Auto Buy Egg
local AutoBuyEggToggle = EggTab:CreateToggle({
    Name = "Auto Buy Egg",
    CurrentValue = false,
    Flag = "AutoBuyEggToggle",
    Callback = function(Value)
        AutoBuyEggEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Buy Egg Enabled",
                Content = "Started auto buying egg: " .. tostring(selectedEgg) .. " with " .. tostring(selectedChoose),
                Duration = 5
            })
            autoBuyEggThread = spawn(function()
                while AutoBuyEggEnabled do
                    local args = {selectedChoose, selectedEgg}
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("EggEvent"):FireServer(unpack(args))
                    end)
                    if not ok then
                        Rayfield:Notify({
                            Title = "Auto Buy Egg Error",
                            Content = "Failed to buy egg: " .. tostring(err),
                            Duration = 5
                        })
                        AutoBuyEggEnabled = false
                        AutoBuyEggToggle:Set(false)
                        break
                    end
                    wait(0.1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Buy Egg Disabled",
                Content = "Auto Buy Egg has been stopped",
                Duration = 5
            })
        end
    end
})

-- Create Craft section in Egg Tab
local CraftSection = EggTab:CreateSection("Craft Features")

-- Paragraph
local Paragraph = EggTab:CreateParagraph({
    Title = "Crafting Info",
    Content = "Secret, Mystical, and Exclusive pets will not be crafted."
})

-- ===== Helpers for Egg Teleport & Craft Pets =====

-- Helper: find teleport CFrame for Egg
local function resolveEggTeleportCFrame(eggModel)
    if not eggModel then return nil end

    local eggNamePart = eggModel:FindFirstChild("EggNamePart", true)
    if eggNamePart and eggNamePart:IsA("BasePart") then
        return eggNamePart.CFrame
    end

    if eggModel:IsA("BasePart") then
        return eggModel.CFrame
    end

    if eggModel:IsA("Model") then
        if eggModel.PrimaryPart then
            return eggModel.PrimaryPart.CFrame
        end
        local anyPart = eggModel:FindFirstChildWhichIsA("BasePart", true)
        if anyPart then
            return anyPart.CFrame
        end
        local ok, cf = pcall(eggModel.GetPivot, eggModel)
        if ok and typeof(cf) == "CFrame" then
            return cf
        end
    end

    return nil
end

-- Helpers: read pets from UI + craft 5
local function getPetScrolling()
    local plr = game:GetService("Players").LocalPlayer
    local mainGui = plr.PlayerGui and plr.PlayerGui:FindFirstChild("Main")
    if not mainGui then return nil end
    local frames = mainGui:FindFirstChild("Frames")
    if not frames then return nil end
    local inv = frames:FindFirstChild("PetsInventory")
    if not inv then return nil end
    local main = inv:FindFirstChild("Main")
    if not main then return nil end
    return main.Main and main.Main:FindFirstChild("PetScrolling")
end

local function readPetBuckets(tier)
    local scroller = getPetScrolling()
    local buckets = {}
    if not scroller then return buckets end

    for _, child in ipairs(scroller:GetChildren()) do
        if not child:IsA("Frame") then continue end
        local click = child:FindFirstChild("Click")
        local viewport = click and click.Main and click.Main:FindFirstChild("ViewportFrame")
        local multiplier = click and click.Main and click.Main:FindFirstChild("Multiplier")
        local uiStroke = click and click:FindFirstChild("UIStroke")
        local secret = click and click.Main and click.Main:FindFirstChild("Secret")
        local mystical = click and click.Main and click.Main:FindFirstChild("Mystical")
        local exclusive = click and click.Main and click.Main:FindFirstChild("Exclusive")
        
        if not (viewport and multiplier) then continue end

        if secret or mystical or exclusive then
            continue
        end

        local modelName
        for _, obj in ipairs(viewport:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("BasePart") then
                modelName = obj.Name
                break
            end
        end

        if modelName and multiplier.Text then
            local isGolden = uiStroke and uiStroke.Color == Color3.fromRGB(255, 170, 0)
            local isDiamond = uiStroke and uiStroke.Color == Color3.fromRGB(0, 255, 255)
            
            if (tier == "Golden" and not isGolden and not isDiamond) or (tier == "Diamond" and not isDiamond) then
                local multiplierValue = multiplier.Text
                buckets[modelName] = buckets[modelName] or {}
                buckets[modelName][multiplierValue] = buckets[modelName][multiplierValue] or {}
                table.insert(buckets[modelName][multiplierValue], child.Name)
            end
        end
    end

    return buckets
end

local function craftFive(petName, idList, tier)
    if #idList < 5 then return false, "Less than 5" end

    local chosen = {}
    for i = 1, 5 do
        chosen[idList[i]] = true
    end

    local args = {"CraftPet", {petName, chosen, tier}}
    local ok, err = pcall(function()
        game:GetService("ReplicatedStorage").Events.RemoteEvents.PetEvent:FireServer(unpack(args))
    end)
    return ok, err
end

--[[
-- ===== Lock/Unlock Button for Secret/Mystical/Exclusive Pets =====
local lockState = {} -- Track lock state for each pet
local LockToggle = EggTab:CreateButton({
    Name = "1x Lock/2x Unlock Secret, Mystical, Exclusive Pets",
    Callback = function()
        local scroller = getPetScrolling()
        if not scroller then
            Rayfield:Notify({
                Title = "Lock Error",
                Content = "Pet inventory not found",
                Duration = 2
            })
            return
        end

        for _, child in ipairs(scroller:GetChildren()) do
            if not child:IsA("Frame") then continue end
            local click = child:FindFirstChild("Click")
            local secret = click and click.Main and click.Main:FindFirstChild("Secret")
            local mystical = click and click.Main and click.Main:FindFirstChild("Mystical")
            local exclusive = click and click.Main and click.Main:FindFirstChild("Exclusive")
            
            if secret or mystical or exclusive then
                local petId = child.Name
                local isLocked = lockState[petId] or false
                local action = isLocked and "Unlock" or "Lock"
                
                task.defer(function()
                    local args = {action, petId}
                    local ok, err = pcall(function()
                        game:GetService("ReplicatedStorage").Events.RemoteEvents.PetEvent:FireServer(unpack(args))
                    end)
                    if ok then
                        lockState[petId] = not isLocked
                        Rayfield:Notify({
                            Title = action .. " Successful",
                            Content = (secret and "Secret" or mystical and "Mystical" or "Exclusive") .. " pet " .. (isLocked and "unlocked" or "locked"),
                            Duration = 1.5
                        })
                    else
                        Rayfield:Notify({
                            Title = action .. " Error",
                            Content = tostring(err),
                            Duration = 2
                        })
                    end
                end)
            end
        end
    end
})

-- ===== Auto Golden (revised) =====
local AutoGoldenEnabled = false
local AutoGoldenToggle = EggTab:CreateToggle({
    Name = "Auto Golden Pet",
    CurrentValue = false,
    Flag = "AutoGoldenToggle",
    Callback = function(Value)
        AutoGoldenEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Golden Enabled",
                Content = "Checking inventory every 1 second",
                Duration = 2
            })

            coroutine.wrap(function()
                while AutoGoldenEnabled do
                    local buckets = readPetBuckets("Golden")
                    for petName, multiplierBuckets in pairs(buckets) do
                        for multiplier, ids in pairs(multiplierBuckets) do
                            if #ids >= 5 then
                                local ok, err = craftFive(petName, ids, "Golden")
                                if ok then
                                    Rayfield:Notify({
                                        Title = "Golden Crafted",
                                        Content = "Golden " .. petName .. " (Multiplier: " .. multiplier .. ") crafted successfully",
                                        Duration = 1.5
                                    })
                                    task.wait(1)
                                elseif err ~= "Less than 5" then
                                    Rayfield:Notify({
                                        Title = "Auto Golden Error",
                                        Content = tostring(err),
                                        Duration = 2
                                    })
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)()
        else
            Rayfield:Notify({
                Title = "Auto Golden Disabled",
                Content = "Stopped checking",
                Duration = 2
            })
        end
    end
})
]]

-- ===== Auto Diamond (revised) =====
local AutoDiamondEnabled = false
local AutoDiamondToggle = EggTab:CreateToggle({
    Name = "Auto Instant Diamond Pet",
    CurrentValue = false,
    Flag = "AutoDiamondToggle",
    Callback = function(Value)
        AutoDiamondEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Diamond Enabled",
                Content = "Checking inventory every 1 second",
                Duration = 2
            })

            coroutine.wrap(function()
                while AutoDiamondEnabled do
                    local buckets = readPetBuckets("Diamond")
                    for petName, multiplierBuckets in pairs(buckets) do
                        for multiplier, ids in pairs(multiplierBuckets) do
                            if #ids >= 5 then
                                local ok, err = craftFive(petName, ids, "Diamond")
                                if ok then
                                    Rayfield:Notify({
                                        Title = "Diamond Crafted",
                                        Content = "Diamond " .. petName .. " (Multiplier: " .. multiplier .. ") crafted successfully",
                                        Duration = 1.5
                                    })
                                    task.wait(1)
                                elseif err ~= "Less than 5" then
                                    Rayfield:Notify({
                                        Title = "Auto Diamond Error",
                                        Content = tostring(err),
                                        Duration = 2
                                    })
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)()
        else
            Rayfield:Notify({
                Title = "Auto Diamond Disabled",
                Content = "Stopped checking",
                Duration = 2
            })
        end
    end
})

-- Membuat tab UI
local UITab = Window:CreateTab("UI")

-- Membuat section UI Toggles
local UISection = UITab:CreateSection("UI Toggles")

-- Mendapatkan daftar frame dari PlayerGui.Main.Frames
local framesFolder = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main") and game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("Frames")
local frameList = {}
if framesFolder then
    for _, frame in pairs(framesFolder:GetChildren()) do
        if frame:IsA("Frame") then
            table.insert(frameList, frame.Name)
        end
    end
end

-- Membuat button untuk setiap frame
for _, frameName in ipairs(frameList) do
    UITab:CreateButton({
        Name = frameName,
        Callback = function()
            local frame = framesFolder:FindFirstChild(frameName)
            if frame then
                frame.Visible = not frame.Visible
                Rayfield:Notify({
                    Title = frameName .. " Toggled",
                    Content = frameName .. " visibility set to " .. (frame.Visible and "visible" or "hidden"),
                    Duration = 5
                })
            else
                Rayfield:Notify({
                    Title = frameName .. " Error",
                    Content = "Frame " .. frameName .. " not found",
                    Duration = 5
                })
            end
        end
    })
end

-- Membuat tab Setting
local SettingTab = Window:CreateTab("Setting")

-- Membuat section General Settings
local GeneralSettingsSection = SettingTab:CreateSection("General Settings")

-- Anti AFK
local AutoAntiAFKEnabled = true
local AutoAntiAFKToggle = SettingTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = true,
    Flag = "AutoAntiAFKToggle",
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

-- Aktifkan Anti AFK saat script dijalankan
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
                    -- Pengecekan koneksi menggunakan Players service
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
                        wait(60) -- Tunggu 60 detik sebelum mencoba lagi untuk menghindari loop cepat
                    end
                    wait(10) -- Cek setiap 10 detik
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

-- Membuat section Config Hook
local ConfigHookSection = SettingTab:CreateSection("Config Hook")

-- Variabel untuk Webhook Config
local WEBHOOK_URL = ""
local DISCORD_USER_ID = ""
local selectedRarities = {"Exclusive", "Mystical", "Secret"}
local HttpService = game:GetService("HttpService")

-- Load config dari file jika ada
local configFileName = "GuitarSimulatorWebhookConfig.json"
local function loadWebhookConfig()
    if isfile(configFileName) then
        local success, config = pcall(function()
            return HttpService:JSONDecode(readfile(configFileName))
        end)
        if success then
            WEBHOOK_URL = config.webhookUrl or ""
            DISCORD_USER_ID = config.discordUserId or ""
            selectedRarities = config.rarities or {"Exclusive", "Mystical", "Secret"}
        end
    end
end

-- Simpan config ke file
local function saveWebhookConfig()
    local config = {
        webhookUrl = WEBHOOK_URL,
        discordUserId = DISCORD_USER_ID,
        rarities = selectedRarities
    }
    local success, err = pcall(function()
        writefile(configFileName, HttpService:JSONEncode(config))
    end)
    if success then
        Rayfield:Notify({
            Title = "Config Saved",
            Content = "Webhook configuration saved successfully",
            Duration = 5
        })
    else
        Rayfield:Notify({
            Title = "Config Save Error",
            Content = "Failed to save webhook config: " .. tostring(err),
            Duration = 5
        })
    end
end

-- Hapus config file dan Rejoin
local function deleteWebhookConfig()
    local success, err = pcall(function()
        if isfile(configFileName) then
            delfile(configFileName)
        end
        -- Reset variables
        WEBHOOK_URL = ""
        DISCORD_USER_ID = ""
        selectedRarities = {"Exclusive", "Mystical", "Secret"}
        
        -- Update UI elements only if they exist
        if WebhookInput and WebhookInput.Set then
            WebhookInput:Set("")
        end
        if DiscordUserIdInput and DiscordUserIdInput.Set then
            DiscordUserIdInput:Set("")
        end
        if RarityDropdown and RarityDropdown.Set then
            RarityDropdown:Set({"Exclusive", "Mystical", "Secret"})
        end
    end)
    
    if success then
        Rayfield:Notify({
            Title = "Config Deleted",
            Content = "Webhook configuration deleted successfully",
            Duration = 5
        })
        -- Rejoin game
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    else
        Rayfield:Notify({
            Title = "Config Delete Error",
            Content = "Failed to delete webhook config: " .. tostring(err),
            Duration = 5
        })
    end
end

-- Load config saat script dijalankan
loadWebhookConfig()

-- Input untuk WEBHOOK_URL
local WebhookInput = SettingTab:CreateInput({
    Name = "Webhook URL",
    Info = "Enter your Discord webhook URL",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    CurrentValue = WEBHOOK_URL,
    Flag = "WebhookInput",
    Callback = function(Value)
        WEBHOOK_URL = Value
        Rayfield:Notify({
            Title = "Webhook URL Updated",
            Content = "Webhook URL set to: " .. tostring(Value),
            Duration = 5
        })
    end
})

-- Input untuk Discord User ID
local DiscordUserIdInput = SettingTab:CreateInput({
    Name = "Discord User ID",
    Info = "Enter your Discord User ID for pinging",
    PlaceholderText = "123456789012345678",
    CurrentValue = DISCORD_USER_ID,
    Flag = "DiscordUserIdInput",
    Callback = function(Value)
        DISCORD_USER_ID = Value
        Rayfield:Notify({
            Title = "Discord User ID Updated",
            Content = "Discord User ID set to: " .. tostring(Value),
            Duration = 5
        })
    end
})

-- Dropdown untuk Rarity
local rarityNames = {"Exclusive", "Mystical", "Secret"}
local RarityDropdown = SettingTab:CreateDropdown({
    Name = "Select Rarity",
    Options = rarityNames,
    CurrentOption = selectedRarities,
    MultipleOptions = true,
    Flag = "RarityDropdown",
    Callback = function(Option)
        selectedRarities = (typeof(Option) == "table") and Option or {Option}
        Rayfield:Notify({
            Title = "Rarity Selected",
            Content = "Selected rarities: " .. table.concat(selectedRarities, ", "),
            Duration = 5
        })
    end
})

-- Button untuk Save Config Hook
local SaveConfigHookButton = SettingTab:CreateButton({
    Name = "Save Config Hook",
    Callback = function()
        saveWebhookConfig()
    end
})

-- Button untuk Delete Config Hook dengan Rejoin
local DeleteConfigHookButton = SettingTab:CreateButton({
    Name = "Delete Config Hook",
    Callback = function()
        deleteWebhookConfig()
    end
})

-- Webhook Hatch Notification
local pendingHatches = {}
local sending = false

local function sendHatchNotification()
    if #pendingHatches == 0 then return end

    sending = true

    local fields = {}
    local firstRarity = pendingHatches[1].rarity  -- Use first for color; can adjust to pick rarest if needed

    for i, hatch in ipairs(pendingHatches) do
        table.insert(fields, {name = "Rarity " .. i, value = hatch.rarity, inline = true})
        table.insert(fields, {name = "Pet Name " .. i, value = hatch.petName, inline = true})
    end

    local rarityColors = {
        ["Exclusive"] = 0x00FF7F,
        ["Mystical"] = 0xFF007F,
        ["Secret"] = 0xFF0000
    }

    local embeds = {{
        title = "🥚 New Hatches! (" .. #pendingHatches .. ")",
        color = rarityColors[firstRarity] or 0x65280,
        fields = fields,
        footer = {text = "Player: Anonymous"}
    }}

    local payload = {
        username = "Hatch Logger",
        embeds = embeds,
        allowed_mentions = { parse = {"users"} }  -- To ensure user mentions are parsed
    }

    if DISCORD_USER_ID and DISCORD_USER_ID ~= "" then
        payload.content = "<@" .. DISCORD_USER_ID .. ">"
    end

    local requestFunc = request or (syn and syn.request) or http_request
    if not requestFunc then
        Rayfield:Notify({
            Title = "Webhook Error",
            Content = "Your executor does not support request()!",
            Duration = 5
        })
        sending = false
        return
    end

    local success, response = pcall(function()
        return requestFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if not success then
        Rayfield:Notify({
            Title = "Webhook Send Error",
            Content = "Failed to send webhook: " .. tostring(response),
            Duration = 5
        })
    elseif response.StatusCode ~= 204 then
        Rayfield:Notify({
            Title = "Webhook Response",
            Content = "Webhook returned status: " .. response.StatusCode,
            Duration = 5
        })
    end

    pendingHatches = {}
    sending = false
end

-- Monitor for hatched pets
local player = game.Players.LocalPlayer
local petScrolling = player:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Frames"):WaitForChild("PetsInventory"):WaitForChild("Main"):WaitForChild("Main"):WaitForChild("PetScrolling")

petScrolling.ChildAdded:Connect(function(child)
    if child:IsA("Frame") then
        local click = child:FindFirstChild("Click")
        local viewportFrame = child:FindFirstChildWhichIsA("ViewportFrame", true)
        
        if click and viewportFrame then
            local main = click:FindFirstChild("Main")
            if main then
                local uiGradient = main:FindFirstChildWhichIsA("UIGradient", true)
                if uiGradient then
                    local rarity = uiGradient.Name
                    if table.find(selectedRarities, rarity) then
                        local model = viewportFrame:FindFirstChildWhichIsA("Model", true)
                        if model then
                            local petName = model.Name
                            table.insert(pendingHatches, {rarity = rarity, petName = petName})
                            if not sending then
                                sending = true
                                task.delay(0.2, sendHatchNotification)  -- Short delay to batch multiple hatches, reduced to minimize lag
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Aktifkan Anti AFK dan Auto Rejoin saat script dijalankan
AutoAntiAFKToggle:Set(true)
AutoRejoinToggle:Set(true)

Rayfield:Notify({
    Title = "Script Loaded",
    Content = gameName .. " script has been loaded successfully!",
    Duration = 5
})