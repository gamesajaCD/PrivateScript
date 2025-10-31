--=====================================================
-- Game Helper | Pet Evolution Incremental (Auto Coin Upgrade FIX)
--=====================================================

-- Safe-load Rayfield
local Rayfield
local okRF, errRF = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not okRF or not Rayfield then warn("Failed to load Rayfield:", errRF) return end

-- Services
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local NetworkClient = game:GetService("NetworkClient")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer
local gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name

-- Cleanup previous instance
if type(_G.__PEI_CLEAN) == "function" then pcall(_G.__PEI_CLEAN) end
if _G.__PEI_Window then pcall(function() _G.__PEI_Window:Destroy() end) _G.__PEI_Window = nil end

-- Trackers
local Threads, Conns = {}, {}
local function stopThread(k) if Threads[k] then pcall(task.cancel, Threads[k]) end Threads[k] = nil end
local function stopConn(k) if Conns[k] and Conns[k].Connected then pcall(function() Conns[k]:Disconnect() end) end Conns[k] = nil end

-- Internal state (loop memakai ini)
local S = {
    AutoCollect=false, AutoFeed=false, AutoEvolve=false,
    ConvertCoins=false, ConvertXP=false,
    AutoCoinUpgrade=false, AutoGoldUpgrade=false, AutoPowerUpgrade=false,
    AutoBuyGenerator=false, AntiAFK=true, AutoRejoin=true, ActivateSpeed=false
}

-- Speed state
local SpeedTarget = 50
local OriginalWalkSpeed = nil

-- Helpers
local function chain(root, names)
    local cur = root
    for _, n in ipairs(names) do
        if not cur then return nil end
        cur = cur:FindFirstChild(n)
        if not cur then return nil end
    end
    return cur
end

-- Parser angka yang mendukung banyak suffix uang simulator
local SUF = {
    k=1e3, m=1e6, b=1e9, t=1e12,
    qa=1e15, qi=1e18, sx=1e21, sp=1e24, oc=1e27, no=1e30,
    de=1e33, ud=1e36, dd=1e39, td=1e42, qd=1e45, qn=1e48, sxd=1e51, spd=1e54, ocd=1e57, nod=1e60
}
local function parseNumberLabel(txt)
    if not txt then return 0 end
    local s = tostring(txt):gsub(",", ""):lower()
    -- ambil angka dan (opsional) suffix di akhir
    local numStr, suf = s:match("([%d%.]+)%s*([%a]+)$")
    if not numStr then
        numStr = s:match("([%d%.]+)") or "0"
    end
    local n = tonumber(numStr) or 0
    if suf and SUF[suf] then
        n = n * SUF[suf]
    end
    return n
end

-- Player model resolver
local CachedModel, LastResolve = nil, 0
local function hasHumanoid(m) return m and m:FindFirstChildOfClass("Humanoid") end
local function scanWorkspaceForModel()
    for _, ch in ipairs(Workspace:GetChildren()) do
        if ch:IsA("Model") and hasHumanoid(ch) then
            if ch.Name == LocalPlayer.Name then return ch end
            local uid = ch:GetAttribute("UserId") or ch:GetAttribute("PlayerUserId")
            if tonumber(uid) == LocalPlayer.UserId then return ch end
        end
    end
end
local function getPlayerModel()
    if CachedModel and CachedModel.Parent and hasHumanoid(CachedModel) then return CachedModel end
    if os.clock() - LastResolve < 0.25 then return CachedModel end
    LastResolve = os.clock()
    local m = Workspace:FindFirstChild(LocalPlayer.Name)
    if m and hasHumanoid(m) then CachedModel = m return m end
    if LocalPlayer.Character and hasHumanoid(LocalPlayer.Character) then CachedModel = LocalPlayer.Character return CachedModel end
    CachedModel = scanWorkspaceForModel()
    return CachedModel
end
local function getHumanoid() local m=getPlayerModel() return m and m:FindFirstChildOfClass("Humanoid") end
local function getHRP() local m=getPlayerModel() return m and m:FindFirstChild("HumanoidRootPart") end

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
        FolderName = "PetEvolutionIncrementalSaving",
        FileName = "PetEvolutionIncrementalSaving"
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
        FileName = "PetEvolutionIncrementalKey",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/nnEd5NnB"}
    }
})
_G.__PEI_Window = Window

--====================== Features (Start/Stop) ======================
local function startAutoCollect()
    stopThread("AutoCollect"); S.AutoCollect = true
    Threads.AutoCollect = task.spawn(function()
        local spawner = chain(Workspace, {"Foods","Spawner"})
        while S.AutoCollect do
            if not spawner then spawner = chain(Workspace, {"Foods","Spawner"}) task.wait(0.2)
            else
                local hum, hrp = getHumanoid(), getHRP()
                if hum and hrp then
                    local items = {}
                    for _, inst in ipairs(spawner:GetChildren()) do
                        if inst:IsA("MeshPart") then table.insert(items, inst) end
                    end
                    table.sort(items, function(a,b) return (a.Position-hrp.Position).Magnitude < (b.Position-hrp.Position).Magnitude end)
                    if #items > 0 then
                        for _, part in ipairs(items) do
                            if not S.AutoCollect then break end
                            if part and part.Parent then
                                hum:MoveTo(part.Position)
                                local reached=false
                                local c; c = hum.MoveToFinished:Connect(function(ok2) reached=ok2 end)
                                local t0=os.clock()
                                while os.clock()-t0<2 and not reached and S.AutoCollect and part.Parent do task.wait(0.05) end
                                if c then c:Disconnect() end
                                if not reached and part and part.Parent then
                                    pcall(function() getPlayerModel():PivotTo(CFrame.new(part.Position)) end)
                                    task.wait(0.1)
                                end
                            end
                        end
                    else
                        local awake=false
                        stopConn("FoodAdded")
                        Conns.FoodAdded = spawner.ChildAdded:Connect(function(ch) if ch:IsA("MeshPart") then awake=true end end)
                        local t0=os.clock()
                        while S.AutoCollect and not awake and os.clock()-t0<8 do task.wait(0.15) end
                        stopConn("FoodAdded")
                    end
                else
                    task.wait(0.15)
                end
            end
            task.wait(0.05)
        end
    end)
end
local function stopAutoCollect() S.AutoCollect=false; stopThread("AutoCollect") end

local function startAutoFeed()
    stopThread("AutoFeed"); S.AutoFeed=true
    Threads.AutoFeed = task.spawn(function()
        local r = chain(RS, {"Remotes","Feed"})
        while S.AutoFeed do if r then pcall(r.FireServer, r) end task.wait(0.25) end
    end)
end
local function stopAutoFeed() S.AutoFeed=false; stopThread("AutoFeed") end

local function startAutoEvolve()
    stopThread("AutoEvolve"); S.AutoEvolve=true
    Threads.AutoEvolve = task.spawn(function()
        local r = chain(RS, {"Remotes","Evolve"})
        while S.AutoEvolve do if r then pcall(r.InvokeServer, r) end task.wait(0.8) end
    end)
end
local function stopAutoEvolve() S.AutoEvolve=false; stopThread("AutoEvolve") end

local function startConvertCoins()
    stopThread("ConvertCoins"); S.ConvertCoins=true
    Threads.ConvertCoins = task.spawn(function()
        local r = chain(RS, {"Remotes","Convert Coins"})
        while S.ConvertCoins do if r then pcall(r.FireServer, r) end task.wait(0.4) end
    end)
end
local function stopConvertCoins() S.ConvertCoins=false; stopThread("ConvertCoins") end

local function startConvertXP()
    stopThread("ConvertXP"); S.ConvertXP=true
    Threads.ConvertXP = task.spawn(function()
        local r = chain(RS, {"Remotes","Convert XP"})
        while S.ConvertXP do if r then pcall(r.FireServer, r) end task.wait(0.4) end
    end)
end
local function stopConvertXP() S.ConvertXP=false; stopThread("ConvertXP") end

-- Boards + helpers
local function board_Coins() return chain(Workspace, {"Map","Boards","CoinsUpgrades","UI","SurfaceGui","Main","Main"}) end
local function board_Gold()  return chain(Workspace, {"Map","Boards","GoldUpgrades","UI","SurfaceGui","Main","Main"}) end
local function board_Power() return chain(Workspace, {"Map","Boards","PowerUpgrades","UI","SurfaceGui","Main","Scroll"}) end
local function listFramesNames(root) local t={} if root then for _,c in ipairs(root:GetChildren()) do if c:IsA("Frame") then table.insert(t,c.Name) end end end table.sort(t) return t end

local function getTotalCoins()
    local lbl = chain(LocalPlayer, {"PlayerGui","Main","UIFrames","Stats","MainScroll","Template","Total Coins","Stat","Amount"})
    return parseNumberLabel(lbl and lbl.Text)
end
local function getCost(root, name)
    if not root then return math.huge end
    local lbl = chain(root, {name, "Cost", "Stat", "Amount"})
    return parseNumberLabel(lbl and lbl.Text)
end

-- Auto Coin Upgrade (single select + Select All) [FIXED]
local SelectedCoin = nil
local CoinsHowMany = "Buy1"
local function startAutoCoinUpgrade()
    stopThread("AutoCoinUpgrade"); S.AutoCoinUpgrade=true
    Threads.AutoCoinUpgrade = task.spawn(function()
        local r = chain(RS, {"Remotes","Upgrade"})
        while S.AutoCoinUpgrade do
            local root = board_Coins()
            if not (r and root) then task.wait(0.8)
            else
                -- Bangun target list
                local names = listFramesNames(root)
                local toBuy = {}
                if SelectedCoin == "Select All" then
                    toBuy = names
                elseif SelectedCoin and table.find(names, SelectedCoin) then
                    toBuy = {SelectedCoin}
                end

                if #toBuy == 0 then
                    task.wait(0.8)
                else
                    -- Urutkan termurah -> termahal
                    table.sort(toBuy, function(a,b) return getCost(root,a) < getCost(root,b) end)

                    -- Cek coins dan beli
                    local coins = getTotalCoins()
                    local bought = false

                    for _, up in ipairs(toBuy) do
                        if not S.AutoCoinUpgrade then break end
                        local cost = getCost(root, up)
                        if coins >= cost and cost > 0 and cost < math.huge then
                            if CoinsHowMany == "Max" then
                                -- Max: tambahkan "true" (arg ke-3)
                                pcall(r.FireServer, r, "Coins", up, "true")
                            else
                                -- Buy1: hanya 2 argumen
                                pcall(r.FireServer, r, "Coins", up)
                            end
                            coins = coins - cost
                            bought = true
                            task.wait(0.25)
                        end
                    end

                    if not bought then task.wait(0.8) end
                end
            end
        end
    end)
end
local function stopAutoCoinUpgrade() S.AutoCoinUpgrade=false; stopThread("AutoCoinUpgrade") end

-- Auto Gold Upgrade (single select + Select All)
local SelectedGold = nil
local GoldHowMany = "Buy1"
local function startAutoGoldUpgrade()
    stopThread("AutoGoldUpgrade"); S.AutoGoldUpgrade=true
    Threads.AutoGoldUpgrade = task.spawn(function()
        local r = chain(RS, {"Remotes","Upgrade"})
        while S.AutoGoldUpgrade do
            local root = board_Gold()
            if not (r and root) then task.wait(0.8)
            else
                local names = listFramesNames(root)
                local toBuy = {}
                if SelectedGold == "Select All" then
                    toBuy = names
                elseif SelectedGold and table.find(names, SelectedGold) then
                    toBuy = {SelectedGold}
                end

                if #toBuy == 0 then
                    task.wait(0.8)
                else
                    table.sort(toBuy, function(a,b) return getCost(root,a) < getCost(root,b) end)
                    local bought=false
                    for _, up in ipairs(toBuy) do
                        if not S.AutoGoldUpgrade then break end
                        if GoldHowMany == "Max" then
                            pcall(r.FireServer, r, "Gold", up, "true")
                        else
                            pcall(r.FireServer, r, "Gold", up)
                        end
                        bought=true
                        task.wait(0.25)
                    end
                    if not bought then task.wait(0.8) end
                end
            end
        end
    end)
end
local function stopAutoGoldUpgrade() S.AutoGoldUpgrade=false; stopThread("AutoGoldUpgrade") end

-- Generator
local GeneratorMode = "Buy1"
local function startAutoBuyGenerator()
    stopThread("AutoBuyGenerator"); S.AutoBuyGenerator=true
    Threads.AutoBuyGenerator = task.spawn(function()
        local r = chain(RS, {"Remotes","Buy Generator"})
        while S.AutoBuyGenerator do
            if r then
                if GeneratorMode == "Buy Max" then pcall(r.FireServer, r, true) else pcall(r.FireServer, r) end
            end
            task.wait(0.5)
        end
    end)
end
local function stopAutoBuyGenerator() S.AutoBuyGenerator=false; stopThread("AutoBuyGenerator") end

-- Power Upgrade
local SelectedPower = nil
local PowerPercent = 50
local function startAutoPowerUpgrade()
    stopThread("AutoPowerUpgrade"); S.AutoPowerUpgrade=true
    Threads.AutoPowerUpgrade = task.spawn(function()
        local r = chain(RS, {"Remotes","Upgrade Power"})
        while S.AutoPowerUpgrade do
            local root = board_Power()
            if r and root then
                if SelectedPower == "Select All" then
                    for _, name in ipairs(listFramesNames(root)) do
                        if not S.AutoPowerUpgrade then break end
                        pcall(r.FireServer, r, name, PowerPercent)
                        task.wait(0.1)
                    end
                elseif SelectedPower and SelectedPower ~= "" then
                    pcall(r.FireServer, r, SelectedPower, PowerPercent)
                end
            end
            task.wait(0.3)
        end
    end)
end
local function stopAutoPowerUpgrade() S.AutoPowerUpgrade=false; stopThread("AutoPowerUpgrade") end

-- Anti AFK / Auto Rejoin / Activate Speed
local function startAntiAFK()
    stopConn("AFK"); S.AntiAFK=true
    Conns.AFK = LocalPlayer.Idled:Connect(function()
        if not S.AntiAFK then return end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
local function stopAntiAFK() S.AntiAFK=false; stopConn("AFK") end

local function startAutoRejoin()
    stopThread("AutoRejoin"); S.AutoRejoin=true
    Threads.AutoRejoin = task.spawn(function()
        while S.AutoRejoin do
            task.wait(5)
            if NetworkClient.ConnectionState == Enum.ConnectionState.Disconnected then
                pcall(TeleportService.Teleport, TeleportService, game.PlaceId, LocalPlayer)
                break
            end
        end
    end)
end
local function stopAutoRejoin() S.AutoRejoin=false; stopThread("AutoRejoin") end

local function startActivateSpeed()
    stopThread("AutoSpeed"); stopConn("SpeedLock"); S.ActivateSpeed=true
    Threads.AutoSpeed = task.spawn(function()
        local lastHum
        while S.ActivateSpeed do
            local hum = getHumanoid()
            if hum then
                if not OriginalWalkSpeed then OriginalWalkSpeed = hum.WalkSpeed end
                pcall(function() hum.WalkSpeed = SpeedTarget end)
                if hum ~= lastHum then
                    stopConn("SpeedLock")
                    Conns.SpeedLock = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                        if S.ActivateSpeed then pcall(function() hum.WalkSpeed = SpeedTarget end) end
                    end)
                    lastHum = hum
                end
            end
            RunService.Heartbeat:Wait()
        end
    end)
end
local function stopActivateSpeed()
    S.ActivateSpeed=false; stopThread("AutoSpeed"); stopConn("SpeedLock")
    local hum = getHumanoid()
    if hum and OriginalWalkSpeed then pcall(function() hum.WalkSpeed = OriginalWalkSpeed end) end
    OriginalWalkSpeed = nil
end

--====================== UI ======================
local UI = {}

-- Main Tab
local MainTab = Window:CreateTab("Main")
MainTab:CreateSection("Food")
UI.AutoCollect = MainTab:CreateToggle({ Name="Auto Collect Food (Walk)", Flag="AutoCollectFood", CurrentValue=false, Callback=function(v) if v then startAutoCollect() else stopAutoCollect() end end })
UI.AutoFeed    = MainTab:CreateToggle({ Name="Auto Feed", Flag="AutoFeed", CurrentValue=false, Callback=function(v) if v then startAutoFeed() else stopAutoFeed() end end })
UI.AutoEvolve  = MainTab:CreateToggle({ Name="Auto Evolve", Flag="AutoEvolve", CurrentValue=false, Callback=function(v) if v then startAutoEvolve() else stopAutoEvolve() end end })
UI.ConvertCoins= MainTab:CreateToggle({ Name="Convert Food to Coins", Flag="ConvertCoins", CurrentValue=false, Callback=function(v) if v then startConvertCoins() else stopConvertCoins() end end })
UI.ConvertXP   = MainTab:CreateToggle({ Name="Convert XP", Flag="ConvertXP", CurrentValue=false, Callback=function(v) if v then startConvertXP() else stopConvertXP() end end })

-- Upgrade Tab
local UpgradeTab = Window:CreateTab("Upgrade")

-- Coin Upgrade
UpgradeTab:CreateSection("Coin Upgrade")
local function coinOptions() local t={"Select All"} for _,n in ipairs(listFramesNames(board_Coins())) do table.insert(t,n) end return t end
UI.CoinDrop = UpgradeTab:CreateDropdown({
    Name="Coin Upgrade Type", Options=coinOptions(), CurrentOption="", Flag="CoinUpgradeType", MultipleOptions=false,
    Callback=function(sel) SelectedCoin = (typeof(sel)=="table" and sel[1]) or sel or nil end
})
UpgradeTab:CreateButton({ Name="Refresh Upgrade List", Callback=function() UI.CoinDrop:Refresh(coinOptions(), true) end })
UI.CoinHowMany = UpgradeTab:CreateDropdown({
    Name="How Many (Coins)", Options={"Buy1","Max"}, CurrentOption="Buy1", Flag="CoinHowMany", MultipleOptions=false,
    Callback=function(opt) CoinsHowMany = (typeof(opt)=="table" and opt[1]) or opt or "Buy1" end
})
UI.AutoCoinUpgrade = UpgradeTab:CreateToggle({
    Name="Auto Coin Upgrade", Flag="AutoCoinUpgrade", CurrentValue=false,
    Callback=function(v) if v then startAutoCoinUpgrade() else stopAutoCoinUpgrade() end end
})

-- Gold Upgrade
UpgradeTab:CreateSection("Gold Upgrade")
local function goldOptions() local t={"Select All"} for _,n in ipairs(listFramesNames(board_Gold())) do table.insert(t,n) end return t end
UI.GoldDrop = UpgradeTab:CreateDropdown({
    Name="Gold Upgrade Type", Options=goldOptions(), CurrentOption="", Flag="GoldUpgradeType", MultipleOptions=false,
    Callback=function(sel) SelectedGold = (typeof(sel)=="table" and sel[1]) or sel or nil end
})
UpgradeTab:CreateButton({ Name="Refresh Gold List", Callback=function() UI.GoldDrop:Refresh(goldOptions(), true) end })
UI.GoldHowMany = UpgradeTab:CreateDropdown({
    Name="How Many (Gold)", Options={"Buy1","Max"}, CurrentOption="Buy1", Flag="GoldHowMany", MultipleOptions=false,
    Callback=function(opt) GoldHowMany = (typeof(opt)=="table" and opt[1]) or opt or "Buy1" end
})
UI.AutoGoldUpgrade = UpgradeTab:CreateToggle({
    Name="Auto Gold Upgrade", Flag="AutoGoldUpgrade", CurrentValue=false,
    Callback=function(v) if v then startAutoGoldUpgrade() else stopAutoGoldUpgrade() end end
})

-- Generator
UpgradeTab:CreateSection("Generator")
UI.GeneratorMode = UpgradeTab:CreateDropdown({
    Name="Buy Generator", Options={"Buy1","Buy Max"}, CurrentOption="Buy1", Flag="GeneratorMode", MultipleOptions=false,
    Callback=function(opt) GeneratorMode = (typeof(opt)=="table" and opt[1]) or opt or "Buy1" end
})
UI.AutoBuyGenerator = UpgradeTab:CreateToggle({
    Name="Auto Buy Generator", Flag="AutoBuyGenerator", CurrentValue=false,
    Callback=function(v) if v then startAutoBuyGenerator() else stopAutoBuyGenerator() end end
})

-- Power Upgrade
UpgradeTab:CreateSection("Power Upgrade")
local function powerOptions() local t={"Select All"} for _,n in ipairs(listFramesNames(board_Power())) do table.insert(t,n) end return t end
UI.PowerDrop = UpgradeTab:CreateDropdown({
    Name="Power Upgrade", Options=powerOptions(), CurrentOption="", Flag="PowerUpgradeName", MultipleOptions=false,
    Callback=function(name) SelectedPower = (typeof(name)=="table" and name[1]) or name or "" end
})
UpgradeTab:CreateButton({ Name="Refresh Power List", Callback=function() UI.PowerDrop:Refresh(powerOptions(), true) end })
UI.PowerPercent = UpgradeTab:CreateDropdown({
    Name="Percentage Upgrade", Options={"10%","50%","100%"}, CurrentOption="50%", Flag="PowerUpgradePercent", MultipleOptions=false,
    Callback=function(opt) local s=(typeof(opt)=="table" and opt[1]) or opt or "50%"; PowerPercent = tonumber((tostring(s):gsub("%%",""))) or 50 end
})
UI.AutoPowerUpgrade = UpgradeTab:CreateToggle({
    Name="Auto Power Upgrade", Flag="AutoPowerUpgrade", CurrentValue=false,
    Callback=function(v) if v then startAutoPowerUpgrade() else stopAutoPowerUpgrade() end end
})

-- Setting Tab
local SettingTab = Window:CreateTab("Setting")
SettingTab:CreateSection("General")
UI.AntiAFK = SettingTab:CreateToggle({
    Name="Anti AFK", Flag="AntiAFK", CurrentValue=true,
    Callback=function(v) if v then startAntiAFK() else stopAntiAFK() end end
})
UI.AutoRejoin = SettingTab:CreateToggle({
    Name="Auto Rejoin", Flag="AutoRejoin", CurrentValue=true,
    Callback=function(v) if v then startAutoRejoin() else stopAutoRejoin() end end
})
SettingTab:CreateSection("Player Speed")
UI.SpeedInput = SettingTab:CreateInput({
    Name="Custom Speed", PlaceholderText="e.g. 10 / 50 / 120", CurrentValue="50", Flag="CustomSpeed",
    Callback=function(val)
        local v = safeNumber(val, 50); if v<1 then v=1 elseif v>1000 then v=1000 end
        SpeedTarget = v
        if S.ActivateSpeed then local hum=getHumanoid() if hum then pcall(function() hum.WalkSpeed=SpeedTarget end) end end
    end
})
UI.ActivateSpeed = SettingTab:CreateToggle({
    Name="Activate Speed (Auto detect model)", Flag="ActivateSpeed", CurrentValue=false,
    Callback=function(v) if v then startActivateSpeed() else stopActivateSpeed() end end
})

-- Always force AntiAFK & AutoRejoin ON
local function forceAlwaysOnAFKRejoin()
    S.AntiAFK = true; S.AutoRejoin = true
    startAntiAFK(); startAutoRejoin()
    task.defer(function()
        if UI.AntiAFK and UI.AntiAFK.Set then UI.AntiAFK:Set(true) end
        if UI.AutoRejoin and UI.AutoRejoin.Set then UI.AutoRejoin:Set(true) end
    end)
end
forceAlwaysOnAFKRejoin()

-- Robust flag readers
local function flagOn(flag)
    local f = Rayfield.Flags and Rayfield.Flags[flag]
    if f == nil then return false end
    if typeof(f) == "boolean" then return f end
    if typeof(f) == "table" then
        local v = (f.CurrentValue ~= nil and f.CurrentValue) or f.Value or f.Enabled
        return v == true
    end
    return false
end
local function flagStr(flag)
    local f = Rayfield.Flags and Rayfield.Flags[flag]
    if typeof(f) == "string" then return f end
    if typeof(f) == "table" then
        return tostring(f.CurrentOption or f.CurrentValue or f.Value or "")
    end
    return ""
end

-- Load config & re-apply (UI + start functions)
task.spawn(function()
    pcall(function() Rayfield:LoadConfiguration() end)

    -- Restore single selects & values
    local cs = safeNumber(flagStr("CustomSpeed"), 50); if cs<1 then cs=1 elseif cs>1000 then cs=1000 end
    SpeedTarget = cs

    local coinSel = flagStr("CoinUpgradeType"); if coinSel ~= "" then SelectedCoin = coinSel end
    local coinHM  = flagStr("CoinHowMany"); if coinHM ~= "" then CoinsHowMany = coinHM end

    local goldSel = flagStr("GoldUpgradeType"); if goldSel ~= "" then SelectedGold = goldSel end
    local goldHM  = flagStr("GoldHowMany"); if goldHM ~= "" then GoldHowMany = goldHM end

    local genMode = flagStr("GeneratorMode"); if genMode ~= "" then GeneratorMode = genMode end

    local pwSel = flagStr("PowerUpgradeName"); if pwSel ~= "" then SelectedPower = pwSel end
    local pwPct = flagStr("PowerUpgradePercent"); if pwPct ~= "" then PowerPercent = tonumber((pwPct:gsub("%%",""))) or PowerPercent end

    -- Force always-on
    forceAlwaysOnAFKRejoin()

    -- Start fitur yang ON sesuai config
    local function ensure(flag, uiObj, startFn)
        if flagOn(flag) then
            if uiObj and uiObj.Set then pcall(function() uiObj:Set(true) end) end
            pcall(startFn)
        end
    end

    ensure("ActivateSpeed", UI.ActivateSpeed, startActivateSpeed)
    ensure("AutoCollectFood", UI.AutoCollect, startAutoCollect)
    ensure("AutoFeed", UI.AutoFeed, startAutoFeed)
    ensure("AutoEvolve", UI.AutoEvolve, startAutoEvolve)
    ensure("ConvertCoins", UI.ConvertCoins, startConvertCoins)
    ensure("ConvertXP", UI.ConvertXP, startConvertXP)
    ensure("AutoCoinUpgrade", UI.AutoCoinUpgrade, startAutoCoinUpgrade)
    ensure("AutoGoldUpgrade", UI.AutoGoldUpgrade, startAutoGoldUpgrade)
    ensure("AutoBuyGenerator", UI.AutoBuyGenerator, startAutoBuyGenerator)
    ensure("AutoPowerUpgrade", UI.AutoPowerUpgrade, startAutoPowerUpgrade)

    Rayfield:Notify({Title="Loaded", Content="Settings restored & features running.", Duration=3})
end)

-- Global cleanup for next runs
_G.__PEI_CLEAN = function()
    for k in pairs(Threads) do stopThread(k) end
    for k in pairs(Conns) do stopConn(k) end
    if OriginalWalkSpeed ~= nil then
        local hum = (Workspace:FindFirstChild(LocalPlayer.Name) or LocalPlayer.Character)
        hum = hum and hum:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.WalkSpeed = OriginalWalkSpeed end) end
        OriginalWalkSpeed = nil
    end
end

Rayfield:Notify({Title="Script Loaded", Content="Script Ready to Use.", Duration=4})