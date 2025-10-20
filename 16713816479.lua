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

-- Tab Main
local MainTab = Window:CreateTab("Main")

-- =========================
-- Auto Claim Gift (Single, tidak duplikat)
-- =========================
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
                        giftsFolder = Players.LocalPlayer.PlayerGui.FreeGifts.Frame.Playtime.Gifts
                    end)
                    if giftsFolder then
                        for _, gift in ipairs(giftsFolder:GetChildren()) do
                            if not AutoClaimGiftEnabled then break end
                            local timerLabel = gift:FindFirstChild("Timer")
                            if timerLabel and timerLabel.Text == "Claim!" then
                                local ohString1 = gift.Name
                                pcall(function()
                                    RS.Packages.Knit.Services.DataService.RF.ClaimPlaytimeGift:InvokeServer(ohString1)
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

-- =========================
-- Tree & Stone Features
-- =========================
MainTab:CreateSection("Tree & Stone Features")

-- Services khusus section ini
local TS_RS = game:GetService("ReplicatedStorage")
local TS_Players = game:GetService("Players")
local TS_WS = game:GetService("Workspace")
local TS_LP = TS_Players.LocalPlayer

-- Ambil list Zone dari workspace
local function TS_GetZoneList()
    local zones = {}
    local zonesFolder = TS_WS.__WORLD and TS_WS.__WORLD.MAP and TS_WS.__WORLD.MAP:FindFirstChild("Zones")
    if zonesFolder then
        for _, z in ipairs(zonesFolder:GetChildren()) do
            table.insert(zones, z.Name)
        end
    end
    if #zones == 0 then zones = {"1"} end
    return zones
end

local TS_ZoneList = TS_GetZoneList()
local TS_SelectedZone = TS_ZoneList[1] or "1"

-- Dropdown untuk Zone (Tree/Stone)
local TS_ZoneDropdown = MainTab:CreateDropdown({
    Name = "Select Zone",
    Options = TS_ZoneList,
    CurrentOption = TS_SelectedZone,
    Flag = "TS_ZoneDropdown_Unique",
    Callback = function(Option)
        TS_SelectedZone = (typeof(Option) == "table") and Option[1] or Option
        Rayfield:Notify({
            Title = "Zone Selected",
            Content = "Selected Zone: " .. tostring(TS_SelectedZone),
            Duration = 4
        })
    end
})

-- Utils
local function TS_ZoneToNumber(z)
    if type(z) == "number" then return z end
    local s = tostring(z or "")
    return tonumber(s:match("%d+")) or tonumber(s) or 1
end

local function TS_FindZoneFolder(zonesFolder, zoneName)
    if not zonesFolder then return nil end
    local zoneNum = TS_ZoneToNumber(zoneName)
    -- by exact name
    local z = zonesFolder:FindFirstChild(tostring(zoneName))
    if z then return z end
    -- by numeric string
    z = zonesFolder:FindFirstChild(tostring(zoneNum))
    if z then return z end
    -- by "Zone X"
    z = zonesFolder:FindFirstChild("Zone " .. tostring(zoneNum))
    if z then return z end
    -- by attribute ZoneId
    for _, child in ipairs(zonesFolder:GetChildren()) do
        local zid = child:GetAttribute("ZoneId")
        if zid and tonumber(zid) == zoneNum then
            return child
        end
    end
    return nil
end

local function TS_TpToModel(model, yOffset)
    yOffset = yOffset or 5
    local char = TS_LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not (root and model) then return end
    local ok, pivot = pcall(function() return model:GetPivot() end)
    if ok and pivot then
        root.CFrame = pivot * CFrame.new(0, yOffset, 0)
    else
        local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
        if part then root.CFrame = part.CFrame * CFrame.new(0, yOffset, 0) end
    end
end

-- Cari model Tree/Ore by PosId string
local function TS_FindBreakableModelByPosId(zoneFolder, kindFolderName, posIdStr)
    local assets = zoneFolder and zoneFolder:FindFirstChild("Assets")
    local container = assets and assets:FindFirstChild(kindFolderName)
    if not container then return nil end
    for _, m in ipairs(container:GetChildren()) do
        if m:IsA("Model") then
            local pid = m:GetAttribute("PosId")
            if pid ~= nil and tostring(pid) == tostring(posIdStr) then
                return m
            end
            -- fallback: nama model sama dengan PosId
            if tostring(m.Name) == tostring(posIdStr) then
                return m
            end
        end
    end
    return nil
end

-- Collect loot (backup via remote dan sentuh)
local function TS_TouchCollectAround(pos, radius)
    radius = radius or 35
    local char = TS_LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local function touch(part)
        if typeof(firetouchinterest) == "function" and part and part:IsA("BasePart") then
            pcall(function()
                firetouchinterest(root, part, 0)
                firetouchinterest(root, part, 1)
            end)
        end
    end

    for _, inst in ipairs(TS_WS:GetDescendants()) do
        if inst:IsA("BasePart") then
            local d = (inst.Position - pos).Magnitude
            if d <= radius then
                touch(inst)
            end
        end
    end
end

-- Remotes (FarmingService.RF)
local function TS_GetRF()
    local Packages = TS_RS:FindFirstChild("Packages")
    local Knit = Packages and Packages:FindFirstChild("Knit")
    local Services = Knit and Knit:FindFirstChild("Services")
    local FarmingService = Services and Services:FindFirstChild("FarmingService")
    local RF = FarmingService and FarmingService:FindFirstChild("RF")
    if not RF then
        local ok
        ok, RF = pcall(function()
            local p = TS_RS:WaitForChild("Packages", 5)
            local k = p and p:WaitForChild("Knit", 5)
            local s = k and k:WaitForChild("Services", 5)
            local f = s and s:WaitForChild("FarmingService", 5)
            return f and f:WaitForChild("RF", 5)
        end)
    end
    return RF
end

local function TS_GetRemotes()
    local RF = TS_GetRF()
    if not RF then return nil end
    return {
        BreakableClicked = RF:FindFirstChild("BreakableClicked"),
        DamageTree = RF:FindChild("DamageTree") or RF:FindFirstChild("DamageTree"),
        DamageOre = RF:FindChild("DamageOre") or RF:FindFirstChild("DamageOre"),
        GetCurrentTrees = RF:FindChild("GetCurrentTrees") or RF:FindFirstChild("GetCurrentTrees"),
        GetCurrentOres = RF:FindChild("GetCurrentOres") or RF:FindFirstChild("GetCurrentOres"),
        CollectLoot = RF:FindChild("CollectLoot") or RF:FindFirstChild("CollectLoot"),
        CastPetBreakableAttack = RF:FindChild("CastPetBreakableAttack") or RF:FindFirstChild("CastPetBreakableAttack"),
        EquipHandItem = RF:FindChild("EquipHandItem") or RF:FindFirstChild("EquipHandItem"),
        GetActiveHeldItems = RF:FindChild("GetActiveHeldItems") or RF:FindFirstChild("GetActiveHeldItems"),
    }
end

-- Ambil PosId dari server list (lebih akurat daripada baca dari workspace)
local function TS_GetServerPosIds(rem, kind, zoneNameStr)
    local ids = {}
    if kind == "TREE" and rem.GetCurrentTrees then
        local ok, res = pcall(function()
            return rem.GetCurrentTrees:InvokeServer(zoneNameStr)
        end)
        if ok and res then
            -- Support list/dict bentuk apa pun
            for k, v in pairs(res) do
                if typeof(k) ~= "number" then
                    table.insert(ids, tostring(k))
                elseif typeof(v) == "table" and (v.PosId or v.posId) then
                    table.insert(ids, tostring(v.PosId or v.posId))
                else
                    table.insert(ids, tostring(v))
                end
            end
        end
    elseif kind == "ORE" and rem.GetCurrentOres then
        local ok, res = pcall(function()
            return rem.GetCurrentOres:InvokeServer(zoneNameStr)
        end)
        if ok and res then
            for k, v in pairs(res) do
                if typeof(k) ~= "number" then
                    table.insert(ids, tostring(k))
                elseif typeof(v) == "table" and (v.PosId or v.posId) then
                    table.insert(ids, tostring(v.PosId or v.posId))
                else
                    table.insert(ids, tostring(v))
                end
            end
        end
    end
    return ids
end

-- Core serang Tree/Ore sesuai signature yang kamu kirim
local function TS_AttackTree(rem, zoneFolder, posIdStr)
    local zoneNameStr = zoneFolder.Name
    local zoneNum = TS_ZoneToNumber(zoneNameStr)
    local model = TS_FindBreakableModelByPosId(zoneFolder, "BREAKABLE_TREES", posIdStr)
    if model then
        TS_TpToModel(model, 5)
    end
    -- spam kombinasi
    while (model and model.Parent) or (not model) do
        -- 1) DamageTree(zoneNameStr, posIdStr, true)
        if rem.DamageTree then
            pcall(function()
                rem.DamageTree:InvokeServer(zoneNameStr, tostring(posIdStr), true)
            end)
        end
        -- 2) BreakableClicked(zoneNum, posIdStr)
        if rem.BreakableClicked then
            pcall(function()
                rem.BreakableClicked:InvokeServer(zoneNum, tostring(posIdStr))
            end)
        end
        -- 3) Opsional: Serang pakai pet (beberapa server butuh trigger ini)
        if rem.CastPetBreakableAttack then
            pcall(function()
                rem.CastPetBreakableAttack:InvokeServer(zoneNameStr, tostring(posIdStr))
            end)
        end
        task.wait(0.08)
        -- Keluar jika model hilang
        if model and not model.Parent then break end
        -- Jika model awalnya nil, batasi durasi serang (biar nggak infinite)
        if not model then break end
    end
    -- CollectLoot (signature tidak pasti, jadi coba beberapa bentuk umum)
    if rem.CollectLoot then
        pcall(function() rem.CollectLoot:InvokeServer() end)
        pcall(function() rem.CollectLoot:InvokeServer(zoneNum, tostring(posIdStr)) end)
        pcall(function() rem.CollectLoot:InvokeServer(zoneNameStr, tostring(posIdStr)) end)
    end
    -- Sentuh loot di sekitar (backup)
    if model then
        local ok, piv = pcall(function() return model:GetPivot() end)
        if ok and piv then
            TS_TouchCollectAround(piv.Position, 35)
        end
    end
end

local function TS_AttackOre(rem, zoneFolder, posIdStr)
    local zoneNameStr = zoneFolder.Name
    local zoneNum = TS_ZoneToNumber(zoneNameStr)
    local model = TS_FindBreakableModelByPosId(zoneFolder, "BREAKABLE_ORES", posIdStr)
    if model then
        TS_TpToModel(model, 5)
    end
    while (model and model.Parent) or (not model) do
        -- 1) DamageOre(zoneNameStr, posIdStr, 1)
        if rem.DamageOre then
            pcall(function()
                rem.DamageOre:InvokeServer(zoneNameStr, tostring(posIdStr), 1)
            end)
        end
        -- 2) BreakableClicked(zoneNum, posIdStr)
        if rem.BreakableClicked then
            pcall(function()
                rem.BreakableClicked:InvokeServer(zoneNum, tostring(posIdStr))
            end)
        end
        -- 3) Optional pets
        if rem.CastPetBreakableAttack then
            pcall(function()
                rem.CastPetBreakableAttack:InvokeServer(zoneNameStr, tostring(posIdStr))
            end)
        end
        task.wait(0.08)
        if model and not model.Parent then break end
        if not model then break end
    end
    if rem.CollectLoot then
        pcall(function() rem.CollectLoot:InvokeServer() end)
        pcall(function() rem.CollectLoot:InvokeServer(zoneNum, tostring(posIdStr)) end)
        pcall(function() rem.CollectLoot:InvokeServer(zoneNameStr, tostring(posIdStr)) end)
    end
    if model then
        local ok, piv = pcall(function() return model:GetPivot() end)
        if ok and piv then
            TS_TouchCollectAround(piv.Position, 35)
        end
    end
end

-- =========================
-- Auto Tree
-- =========================
local TS_AutoTreeEnabled = false
local TS_AutoTreeThread

MainTab:CreateToggle({
    Name = "Auto Tree",
    CurrentValue = false,
    Flag = "TS_AutoTreeToggle_Unique",
    Callback = function(v)
        TS_AutoTreeEnabled = v
        if v then
            Rayfield:Notify({ Title = "Auto Tree Enabled", Content = "DamageTree + BreakableClicked + (optional) Pets + CollectLoot", Duration = 5 })
            TS_AutoTreeThread = task.spawn(function()
                local zonesFolder = TS_WS.__WORLD and TS_WS.__WORLD.MAP and TS_WS.__WORLD.MAP:WaitForChild("Zones", 5)
                if not zonesFolder then
                    Rayfield:Notify({ Title = "Auto Tree Error", Content = "Zones folder tidak ditemukan", Duration = 5 })
                    return
                end
                local rem = TS_GetRemotes()
                if not rem or not rem.DamageTree then
                    Rayfield:Notify({ Title = "Auto Tree Error", Content = "Remote DamageTree tidak ditemukan", Duration = 5 })
                    return
                end
                while TS_AutoTreeEnabled do
                    local zf = TS_FindZoneFolder(zonesFolder, TS_SelectedZone)
                    if not zf then task.wait(0.5) goto CONTINUE end
                    -- Ambil PosId dari server (lebih akurat)
                    local ids = TS_GetServerPosIds(rem, "TREE", zf.Name)
                    if #ids == 0 then
                        -- fallback: scan workspace bila perlu
                        local assets = zf:FindFirstChild("Assets")
                        local trees = assets and assets:FindFirstChild("BREAKABLE_TREES")
                        if trees then
                            for _, m in ipairs(trees:GetChildren()) do
                                local pid = m:GetAttribute("PosId")
                                if pid ~= nil then table.insert(ids, tostring(pid)) end
                            end
                        end
                    end
                    for _, posId in ipairs(ids) do
                        if not TS_AutoTreeEnabled then break end
                        TS_AttackTree(rem, zf, posId)
                        task.wait(0.05)
                    end
                    ::CONTINUE::
                    task.wait(0.25)
                end
            end)
        else
            Rayfield:Notify({ Title = "Auto Tree Disabled", Content = "Dimatikan", Duration = 4 })
        end
    end
})

-- =========================
-- Auto Mining
-- =========================
local TS_AutoMiningEnabled = false
local TS_AutoMiningThread

MainTab:CreateToggle({
    Name = "Auto Mining",
    CurrentValue = false,
    Flag = "TS_AutoMiningToggle_Unique",
    Callback = function(v)
        TS_AutoMiningEnabled = v
        if v then
            Rayfield:Notify({ Title = "Auto Mining Enabled", Content = "DamageOre + BreakableClicked + (optional) Pets + CollectLoot", Duration = 5 })
            TS_AutoMiningThread = task.spawn(function()
                local zonesFolder = TS_WS.__WORLD and TS_WS.__WORLD.MAP and TS_WS.__WORLD.MAP:WaitForChild("Zones", 5)
                if not zonesFolder then
                    Rayfield:Notify({ Title = "Auto Mining Error", Content = "Zones folder tidak ditemukan", Duration = 5 })
                    return
                end
                local rem = TS_GetRemotes()
                if not rem or not rem.DamageOre then
                    Rayfield:Notify({ Title = "Auto Mining Error", Content = "Remote DamageOre tidak ditemukan", Duration = 5 })
                    return
                end
                while TS_AutoMiningEnabled do
                    local zf = TS_FindZoneFolder(zonesFolder, TS_SelectedZone)
                    if not zf then task.wait(0.5) goto CONTINUE end
                    local ids = TS_GetServerPosIds(rem, "ORE", zf.Name)
                    if #ids == 0 then
                        local assets = zf:FindFirstChild("Assets")
                        local ores = assets and assets:FindFirstChild("BREAKABLE_ORES")
                        if ores then
                            for _, m in ipairs(ores:GetChildren()) do
                                local pid = m:GetAttribute("PosId")
                                if pid ~= nil then table.insert(ids, tostring(pid)) end
                            end
                        end
                    end
                    for _, posId in ipairs(ids) do
                        if not TS_AutoMiningEnabled then break end
                        TS_AttackOre(rem, zf, posId)
                        task.wait(0.05)
                    end
                    ::CONTINUE::
                    task.wait(0.25)
                end
            end)
        else
            Rayfield:Notify({ Title = "Auto Mining Disabled", Content = "Dimatikan", Duration = 4 })
        end
    end
})

-- =========================
-- Fish Features
-- =========================
MainTab:CreateSection("Fish Features")

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

-- Hitung parameter lempar kail di depan player
local function computeCastParamsAheadOfPlayer()
    local char = LocalPlayer and LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local cf = hrp.CFrame
    local forward = cf.LookVector
    local up = cf.UpVector

    local castDistance = 20
    local origin = hrp.Position + up * 1.5 + forward * 2
    local p2 = origin + forward * 6 + up * 2.5
    local p3 = origin + forward * 12 + up * 4
    local target = origin + forward * castDistance

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
                    end
                    task.wait(3)
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

-- Instant Catch Fish (SINGLE, tidak duplikat)
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
-- Other Features
-- =========================
MainTab:CreateSection("Other Features")

-- Auto Spin
local AutoSpinEnabled = false
local autoSpinThread = nil

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
                        RS.Packages.Knit.Services.DataService.RF.StartWheelSpin:InvokeServer()
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

-- =========================
-- Tab Hatch
-- =========================
local HatchTab = Window:CreateTab("Hatch")

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

local AutoHatchEnabled = false
local autoHatchThread = nil

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
            local player = Players.LocalPlayer
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
            autoHatchThread = task.spawn(function()
                while AutoHatchEnabled do
                    local eggsFolderNow = workspace.Scripted and workspace.Scripted:FindFirstChild("Eggs")
                    if eggsFolderNow and eggsFolderNow:FindFirstChild(selectedEgg) then
                        local ohString1 = selectedEgg
                        local ohString2 = selectedHowMany
                        pcall(function()
                            RS.Packages.Knit.Services.InventoryService.RF.HatchEgg:InvokeServer(ohString1, ohString2)
                        end)
                        pcall(function()
                            RS.Packages.Knit.Services.InventoryService.RF.OnHatchFinish:InvokeServer()
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

-- =========================
-- Tab Setting
-- =========================
local SettingTab = Window:CreateTab("Setting")
SettingTab:CreateSection("General Settings")

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

local vu = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
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
                    local player = Players.LocalPlayer
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

-- Player section
SettingTab:CreateSection("Player")

local customSpeed = 50
local defaultPlayerSpeed = 16
local defaultPetSpeed = 16
local AutoSpeedEnabled = false
local autoSpeedThread = nil

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

local ActivateSpeedToggle = SettingTab:CreateToggle({
    Name = "Activate Speed",
    CurrentValue = false,
    Flag = "ActivateSpeedToggle",
    Callback = function(Value)
        AutoSpeedEnabled = Value
        local player = Players.LocalPlayer
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