-- Inisialisasi Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Variabel Key System
local KeyValid = false
local KeyExpireTime = nil
local correctKey = "survival" -- Key yang valid
local saveFile = "KeysurvivalOdyssey.txt"

-- Fungsi untuk memeriksa apakah key masih valid
local function checkKeyValid()
    if KeyExpireTime then
        if os.time() > KeyExpireTime then
            KeyValid = false
            OrionLib:MakeNotification({
                Name = "Key Expired",
                Content = "Your key has expired. Please enter a new key.",
                Time = 5
            })
        else
            KeyValid = true
        end
    end
    return KeyValid
end

-- Fungsi untuk menyimpan key dan waktu kadaluarsa ke file
local function saveKeyData()
    if KeyValid then
        local data = {
            key = correctKey,
            expireTime = KeyExpireTime
        }
        writefile(saveFile, game:GetService("HttpService"):JSONEncode(data))
    end
end

-- Fungsi untuk memuat data key dari file
local function loadKeyData()
    if isfile(saveFile) then
        local data = game:GetService("HttpService"):JSONDecode(readfile(saveFile))
        if data.key == correctKey and os.time() <= data.expireTime then
            KeyValid = true
            KeyExpireTime = data.expireTime
            return true
        end
    end
    return false
end

-- Memuat data key saat pertama kali script dijalankan
local keyLoaded = loadKeyData()

-- Membuat Window UI
local Window = OrionLib:MakeWindow({
    Name = "Survival Odyssey",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SurvivalOdysseyConfig"
})

-- Membuat Tab Key
local KeyTab = Window:MakeTab({
    Name = "Key",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Fungsi untuk membuat tab lainnya hanya jika key valid
local function createTabs()
    createGodTab()
    createFarmTab()
    createFruitFarmTab()
    createPickupTab()
	createAutoFeaturesTab()
end

-- Membuat Section Key System
local KeySystemSection = KeyTab:AddSection({
    Name = "Key System"
})

KeySystemSection:AddButton({
    Name = "Get Key",
    Callback = function()
        setclipboard('https://pastebin.com/raw/survival') -- Link untuk mendapatkan key
        OrionLib:MakeNotification({
            Name = "Link Copied",
            Content = "The link has been copied to clipboard.",
            Time = 5
        })
    end
})

local EnteredKey = nil
KeySystemSection:AddTextbox({
    Name = "Enter Key",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        EnteredKey = Value
    end
})

KeySystemSection:AddButton({
    Name = "Submit",
    Callback = function()
        if EnteredKey == correctKey then
            KeyValid = true
            KeyExpireTime = os.time() + (999 * 60) -- Key berlaku selama 60 menit
            saveKeyData()
            OrionLib:MakeNotification({
                Name = "Key Accepted",
                Content = "Your key is valid for the next 60 minutes.",
                Time = 5
            })
			createTabs() -- Membuat semua tab setelah key valid
        else
            OrionLib:MakeNotification({
                Name = "Key Invalid",
                Content = "The key you entered is invalid. Please try again.",
                Time = 5
            })
        end
    end
})

-- Fungsi untuk membuat tab God setelah key valid
function createGodTab()
    local GodTab = Window:MakeTab({
        Name = "God",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    local GodOptions = {}
    local SelectedGod = nil
    local TpGodsDropdown

    local function refreshGodOptions()
        GodOptions = {}
        local resourcesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Resources")
        
        if resourcesFolder then
            if resourcesFolder:FindFirstChild("Gods") then
                for _, god in pairs(resourcesFolder.Gods:GetChildren()) do
                    if god:IsA("Model") then
                        table.insert(GodOptions, god.Name)
                    end
                end
            end

            if resourcesFolder:FindFirstChild("God") then
                for _, god in pairs(resourcesFolder.God:GetChildren()) do
                    if god:IsA("Model") then
                        table.insert(GodOptions, god.Name)
                    end
                end
            end
        end

        table.sort(GodOptions)
        
        if TpGodsDropdown then
            TpGodsDropdown:Refresh(GodOptions, true)
        end
    end

    TpGodsDropdown = GodTab:AddDropdown({
        Name = "Tp Gods",
        Default = "Select God",
        Options = GodOptions,
        Callback = function(Value)
            SelectedGod = Value
        end
    })

    refreshGodOptions()

    spawn(function()
        while true do
            wait(5)
            refreshGodOptions()
        end
    end)

    local AutoTeleportGodEnabled = false
    local stopTeleportGod = false

    GodTab:AddToggle({
        Name = "Teleport To Gods",
        Default = false,
        Callback = function(Value)
            AutoTeleportGodEnabled = Value
            stopTeleportGod = not Value
            if AutoTeleportGodEnabled and SelectedGod then
                teleportToGods()
            end
        end
    })

    function teleportToGods()
        local godModel = workspace.Map.Resources:FindFirstChild("Gods") and workspace.Map.Resources.Gods:FindFirstChild(SelectedGod)
                        or workspace.Map.Resources:FindFirstChild("God") and workspace.Map.Resources.God:FindFirstChild(SelectedGod)
                        
        if godModel then
            local targetPosition
            if godModel.PrimaryPart then
                targetPosition = godModel.PrimaryPart.Position + Vector3.new(0, 10, 0)
            else
                targetPosition = godModel:GetModelCFrame().Position + Vector3.new(0, 10, 0)
            end
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        end
    end

    local AutoPickupEssenceEnabled = false
    local pickupEssenceRadius = 200

    GodTab:AddToggle({
        Name = "Pickup Essence",
        Default = false,
        Callback = function(Value)
            AutoPickupEssenceEnabled = Value
            if AutoPickupEssenceEnabled then
                spawn(pickupEssences)
            end
        end
    })

    function pickupEssences()
        while AutoPickupEssenceEnabled do
            local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            local nearbyItems = workspace.Important.Items:GetChildren()

            for _, item in pairs(nearbyItems) do
                if not AutoPickupEssenceEnabled then break end
                local itemPosition = item.Position
                local distance = (playerPosition - itemPosition).Magnitude
                
                if (item.Name == "Essence" or item.Name == "Big Essence") and distance <= pickupEssenceRadius then
                    spawn(function()
                        pcall(function()
                            game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(item)
                        end)
                    end)
                end
            end
            wait(0.01)
        end
    end

    local TeleportWorldSection = GodTab:AddSection({
        Name = "Teleport World"
    })

    TeleportWorldSection:AddButton({
        Name = "Tp Normal",
        Callback = function()
            game:GetService("TeleportService"):Teleport(18629053284, game.Players.LocalPlayer)
        end
    })

    TeleportWorldSection:AddButton({
        Name = "Tp to Void",
        Callback = function()
            game:GetService("TeleportService"):Teleport(18629058177, game.Players.LocalPlayer)
        end
    })

    TeleportWorldSection:AddButton({
        Name = "Tp To UnderWorld",
        Callback = function()
            game:GetService("TeleportService"):Teleport(92039548740735, game.Players.LocalPlayer)
        end
    })
end

-- Fungsi untuk membuat Tab Farm setelah key valid
function createFarmTab()
    local FarmTab = Window:MakeTab({
        Name = "Farm",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Mengambil daftar folder di dalam workspace.Map.Resources, tanpa Misc dan God
    local ResourceFolders = {}
    local resourcesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Resources")
    local TpResourceDropdown
    local SelectedResource = nil

-- Fungsi untuk memperbarui opsi Resource secara dinamis berdasarkan kehadiran objek
local function refreshResourceOptions()
    ResourceFolders = {}
    if resourcesFolder then
        for _, folder in pairs(resourcesFolder:GetChildren()) do
            if folder:IsA("Folder") and folder.Name ~= "Misc" and folder.Name ~= "God" and folder.Name ~= "Gods" then
                -- Periksa apakah folder memiliki setidaknya satu objek aktif
                local hasActiveObject = false
                for _, object in pairs(folder:GetChildren()) do
                    if object:IsA("Model") or object:IsA("Part") then
                        hasActiveObject = true
                        break
                    end
                end
                
                -- Tambahkan ke dropdown jika ada objek aktif dalam folder
                if hasActiveObject then
                    table.insert(ResourceFolders, folder.Name)
                end
            end
        end
    end

    -- Tambahkan opsi King Ant jika folder Misc ditemukan dan memiliki objek King Spawner
    if resourcesFolder and resourcesFolder:FindFirstChild("Misc") and resourcesFolder.Misc:FindFirstChild("King Spawner") then
        table.insert(ResourceFolders, "King Ant")
    end

    table.sort(ResourceFolders)  -- Mengurutkan daftar ResourceFolders secara alfabetis

    if TpResourceDropdown then
        TpResourceDropdown:Refresh(ResourceFolders, true)  -- Refresh dropdown dengan daftar yang diperbarui
    end
end

    -- Dropdown untuk Tp To di Tab Farm dengan fungsi Refresh
    TpResourceDropdown = FarmTab:AddDropdown({
        Name = "Tp To",
        Default = "Select Resource",
        Options = ResourceFolders,
        Callback = function(Value)
            SelectedResource = Value
        end
    })

    -- Refresh daftar pertama kali saat Tab Farm dibuat
    refreshResourceOptions()

    -- Refresh ResourceFolders setiap beberapa detik
    spawn(function()
        while true do
            wait(5)
            refreshResourceOptions()
        end
    end)

    -- Membuat Toggle Teleport Player
    local AutoTeleportEnabled = false
    local stopTeleport = false

    FarmTab:AddToggle({
        Name = "Teleport Resource",
        Default = false,
        Callback = function(Value)
            AutoTeleportEnabled = Value
            stopTeleport = not Value
            if AutoTeleportEnabled and SelectedResource then
                teleportToResources()
            end
        end
    })

    -- Fungsi untuk teleport ke setiap Reference dalam folder yang dipilih atau ke King Ant jika dipilih
    function teleportToResources()
        if SelectedResource == "King Ant" then
            -- Teleport ke King Spawner jika King Ant dipilih
            local kingSpawner = workspace.Map.Resources.Misc:FindFirstChild("King Spawner")
            if kingSpawner then
                local targetPosition
                if kingSpawner.PrimaryPart then
                    targetPosition = kingSpawner.PrimaryPart.Position + Vector3.new(0, 5, 0)
                else
                    targetPosition = kingSpawner:GetModelCFrame().Position + Vector3.new(0, 5, 0)
                end
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            end
        else
            -- Teleport ke folder yang dipilih jika bukan King Ant
            local resourceFolder = workspace.Map.Resources:FindFirstChild(SelectedResource)
            if resourceFolder then
                for _, resource in pairs(resourceFolder:GetChildren()) do
                    if stopTeleport then break end
                    if resource:FindFirstChild("Reference") then
                        local targetPosition = resource.Reference.Position + Vector3.new(0, 3, 0)
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                        wait(7)
                    end
                end
            end
        end
    end

    -- Mengambil daftar Critters di dalam workspace.Important.Critters dan mengurutkannya
    local CritterOptions = {}
    local CritterDropdown
    local SelectedCritter = nil

    -- Fungsi untuk memperbarui opsi Critter secara dinamis
    local function refreshCritterOptions()
        CritterOptions = {}
        for _, critter in pairs(workspace.Important.Critters:GetChildren()) do
            if critter:IsA("Model") then
                if not table.find(CritterOptions, critter.Name) then
                    table.insert(CritterOptions, critter.Name)
                end
            end
        end

        table.sort(CritterOptions)

        if CritterDropdown then
            CritterDropdown:Refresh(CritterOptions, true)
        end
    end

    -- Dropdown untuk Tp Critters di Tab Farm dengan fungsi Refresh
    CritterDropdown = FarmTab:AddDropdown({
        Name = "Tp Critters",
        Default = "Select Critter",
        Options = CritterOptions,
        Callback = function(Value)
            SelectedCritter = Value
        end
    })

    -- Refresh daftar pertama kali saat Tab Farm dibuat
    refreshCritterOptions()

    -- Refresh CritterOptions setiap beberapa detik
    spawn(function()
        while true do
            wait(5)
            refreshCritterOptions()
        end
    end)

    -- Membuat Toggle Teleport To Critters
    local AutoTeleportCritterEnabled = false
    local stopTeleportCritter = false

    FarmTab:AddToggle({
        Name = "Teleport To Critters",
        Default = false,
        Callback = function(Value)
            AutoTeleportCritterEnabled = Value
            stopTeleportCritter = not Value
            if AutoTeleportCritterEnabled and SelectedCritter then
                teleportToCritters()
            end
        end
    })

    -- Fungsi untuk teleport ke semua objek dengan nama yang dipilih dalam Critters
    function teleportToCritters()
        while AutoTeleportCritterEnabled do
            for _, critter in pairs(workspace.Important.Critters:GetChildren()) do
                if not AutoTeleportCritterEnabled then break end
                if critter.Name == SelectedCritter and critter:FindFirstChild("HumanoidRootPart") then
                    local targetPosition = critter.HumanoidRootPart.Position + Vector3.new(5, 0, 0)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                    wait(5)
                end
            end
            wait(1) -- Tunggu sebentar sebelum mengulangi loop
        end
    end

    -- Menambahkan Toggle Pickup Everything
    local AutoPickupEnabled = false
    local pickupRadius = 300 -- Radius pengambilan item dalam satuan unit
    FarmTab:AddToggle({
        Name = "Pickup Everything",
        Default = false,
        Callback = function(Value)
            AutoPickupEnabled = Value
            if AutoPickupEnabled then
                spawn(pickupItems) -- Menjalankan fungsi pickupItems dalam thread terpisah
            end
        end
    })

    -- Fungsi untuk pickup item di sekitar pemain dengan jarak tertentu
    function pickupItems()
        while AutoPickupEnabled do
            local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            local nearbyItems = workspace.Important.Items:GetChildren()
            
            for _, item in pairs(nearbyItems) do
                if not AutoPickupEnabled then break end

                local itemPosition = item.Position
                local distance = (playerPosition - itemPosition).Magnitude
                
                if distance <= pickupRadius then
                    spawn(function()
                        pcall(function()
                            game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(item)
                        end)
                    end)
                end
            end
            wait(0.01)
        end
    end

    -- Menambahkan Toggle Pickup Special Items (Undead Stick, Serpent Tail, Zombie Flesh, Skeleton Bone) di Tab Farm
    local AutoPickupSpecialItemsEnabled = false
    local pickupSpecialItemRadius = 200

    FarmTab:AddToggle({
        Name = "Pickup Special Items",
        Default = false,
        Callback = function(Value)
            AutoPickupSpecialItemsEnabled = Value
            if AutoPickupSpecialItemsEnabled then
                spawn(pickupSpecialItems)
            end
        end
    })

    -- Fungsi untuk mengambil hanya item spesial di sekitar pemain dengan jarak tertentu
    function pickupSpecialItems()
        while AutoPickupSpecialItemsEnabled do
            local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            local nearbyItems = workspace.Important.Items:GetChildren()
            
            for _, item in pairs(nearbyItems) do
                if not AutoPickupSpecialItemsEnabled then break end
                
                local itemPosition = item.Position
                local distance = (playerPosition - itemPosition).Magnitude
                
                if (item.Name == "Undead Stick" or item.Name == "Serpent Tail" or item.Name == "Zombie Flesh" or item.Name == "Skeleton Bone") and distance <= pickupSpecialItemRadius then
                    spawn(function()
                        pcall(function()
                            game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(item)
                        end)
                    end)
                end
            end
            wait(0.01)
        end
    end

    -- Menambahkan Toggle Coin Press
    local AutoCoinPressEnabled = false

    FarmTab:AddToggle({
        Name = "Coin Press",
        Default = false,
        Callback = function(Value)
            AutoCoinPressEnabled = Value
            if AutoCoinPressEnabled then
                spawn(runCoinPress)
            end
        end
    })

    -- Fungsi untuk menjalankan Coin Press setiap 0.0001 detik
    function runCoinPress()
        while AutoCoinPressEnabled do
            local args = {
                [1] = workspace.Important.Deployables:FindFirstChild("Coin Press"),
                [2] = "Gold Bar"
            }
            game:GetService("ReplicatedStorage").Events.InteractStructure:FireServer(unpack(args))
            wait(0.00000001) -- Interval 0.0001 detik
        end
    end

	-- Menambahkan Toggle Coin Press 2
	local AutoCoinPress2Enabled = false

	FarmTab:AddToggle({
		Name = "Coin Press 2",
		Default = false,
		Callback = function(Value)
			AutoCoinPress2Enabled = Value
			if AutoCoinPress2Enabled then
				spawn(runCoinPress2) -- Menjalankan fungsi runCoinPress2 dalam thread terpisah
			end
		end
	})

	-- Fungsi untuk menjalankan Coin Press 2 setiap 0.0001 detik
	function runCoinPress2()
		while AutoCoinPress2Enabled do
			local args = {
				[1] = workspace:WaitForChild("Important"):WaitForChild("Deployables"):WaitForChild("Coin Press"),
				[2] = "Gold Bar"
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("InteractStructure"):FireServer(unpack(args))
			wait(0.0001) -- Interval 0.0001 detik
		end
	end
end

-- Fungsi untuk membuat Tab Fruit Farm setelah key valid
function createFruitFarmTab()
    local FruitFarmTab = Window:MakeTab({
        Name = "Fruit Farm",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Section untuk Place Plant Box
    local PlantSection = FruitFarmTab:AddSection({
        Name = "Place Plant Box"
    })

    -- Slider untuk menentukan jumlah Plant Box
    local PlantBoxAmount = 1
    PlantSection:AddSlider({
        Name = "Amount of Plant Box",
        Min = 1,
        Max = 100,
        Default = 1,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 1,
        ValueName = "Boxes",
        Callback = function(Value)
            PlantBoxAmount = Value
        end
    })

    -- Button untuk Place Plant Box
    PlantSection:AddButton({
        Name = "Place Plant Box",
        Callback = function()
            placePlantBoxes("Plant Box")
        end
    })

    -- Button untuk Place Golden Plant Box
    PlantSection:AddButton({
        Name = "Place Golden Plant Box",
        Callback = function()
            placePlantBoxes("Golden Plant Box")
        end
    })

    -- Fungsi untuk menempatkan Plant Box berjejer dengan jarak kecil di sumbu Z
    function placePlantBoxes(boxType)
        local player = game.Players.LocalPlayer
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Player or HumanoidRootPart not found.",
                Time = 5
            })
            return
        end

        -- Posisi awal di bawah pemain
        local playerCFrame = player.Character.HumanoidRootPart.CFrame
        local basePosition = playerCFrame.Position + Vector3.new(0, -3, 0) -- Di bawah pemain pada sumbu Y

        -- Offset kecil pada sumbu Z untuk memberikan jarak kecil antar Plant Box ke belakang
        local offset = Vector3.new(0, 0, 1) -- Jarak kecil ke belakang pada sumbu Z

        for i = 0, PlantBoxAmount - 1 do
            local positionOffset = offset * i
            local newCFrame = CFrame.new(basePosition + positionOffset)
            
            local args = {
                [1] = boxType,
                [2] = newCFrame,
                [3] = 0
            }

            -- Cek apakah event ada sebelum dipanggil
            if game:GetService("ReplicatedStorage").Events:FindFirstChild("PlaceStructure") then
                game:GetService("ReplicatedStorage").Events.PlaceStructure:FireServer(unpack(args))
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Event PlaceStructure not found.",
                    Time = 5
                })
                break
            end

            wait(0.1) -- Penundaan untuk menghindari masalah performa
        end
    end

    -- Section untuk Plant/Harvest Fruit
    local FruitSection = FruitFarmTab:AddSection({
        Name = "Plant/Harvest Fruit"
    })

    -- Dropdown untuk memilih jenis buah
    local selectedFruit = "Bloodfruit"  -- Default selection
    FruitSection:AddDropdown({
        Name = "Select Fruit",
        Default = "Bloodfruit",
        Options = {"Bloodfruit", "Heartfruit", "Jelly", "Sunfruit", "Bluefruit", "Cloudberry", "Pumpkin", "Blight Fruit"},
        Callback = function(Value)
            selectedFruit = Value
        end
    })

    -- Fungsi untuk menanam buah hanya di Plant Box di sekitar pemain
    local function plantFruit()
        local player = game.Players.LocalPlayer
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Player or HumanoidRootPart not found.",
                Time = 5
            })
            return
        end

        local playerPosition = player.Character.HumanoidRootPart.Position
        local maxDistance = 10  -- Batas jarak maksimum untuk menanam di Plant Box terdekat

        for _, plantBox in pairs(workspace.Important.Deployables:GetChildren()) do
            if plantBox.Name == "Plant Box" or plantBox.Name == "Golden Plant Box" then
                local plantBoxPosition = plantBox:GetModelCFrame().Position
                local distance = (plantBoxPosition - playerPosition).Magnitude
                if distance <= maxDistance then
                    local args = {
                        [1] = plantBox,
                        [2] = selectedFruit
                    }
                    game:GetService("ReplicatedStorage").Events.InteractStructure:FireServer(unpack(args))
                end
            end
        end
    end

    -- Toggle untuk menanam buah secara berulang selama toggle aktif
    local plantFruitToggle = false
    FruitSection:AddToggle({
        Name = "Plant Fruit",
        Default = false,
        Callback = function(Value)
            plantFruitToggle = Value
            if plantFruitToggle then
                spawn(function()  -- Menjalankan loop di thread terpisah
                    while plantFruitToggle do
                        plantFruit()  -- Jalankan fungsi tanam buah hanya pada Plant Box terdekat
                        wait(1)  -- Jeda 1 detik sebelum memeriksa kembali
                    end
                end)
            end
        end
    })

    -- Fungsi untuk memanen buah dari setiap model tanaman yang ditemukan di dalam Plant Box secara paralel
    local function harvestFruit()
        for _, plantBox in pairs(workspace.Important.Deployables:GetChildren()) do
            if plantBox.Name == "Plant Box" or plantBox.Name == "Golden Plant Box" then
                -- Menjalankan panen untuk setiap model di dalam Plant Box secara paralel
                for _, crop in pairs(plantBox:GetChildren()) do
                    if crop:IsA("Model") then
                        spawn(function()  -- Memanen setiap tanaman secara paralel
                            local args = { [1] = crop }
                            game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(unpack(args))
                        end)
                    end
                end
            end
        end
    end

    -- Toggle untuk memanen buah tanpa delay, menggunakan parallel processing untuk menghindari lag
    local harvestFruitToggle = false
    local harvestingInProgress = false  -- Flag untuk mencegah pemanggilan berulang

    FruitSection:AddToggle({
        Name = "Harvest Fruit",
        Default = false,
        Callback = function(Value)
            harvestFruitToggle = Value
            if harvestFruitToggle and not harvestingInProgress then
                harvestingInProgress = true
                spawn(function()
                    while harvestFruitToggle do
                        harvestFruit()  -- Jalankan fungsi panen buah dari semua Plant Box secara paralel
                        wait(1)  -- Delay kecil untuk mencegah lag
                    end
                    harvestingInProgress = false
                end)
            end
        end
    })
end

-- Fungsi untuk membuat tab Pickup
function createPickupTab()
    local PickupTab = Window:MakeTab({
        Name = "Pickup",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Definisikan item pickup dan atur radius pickup
    local pickupRadius = 200
    local pickupFunctions = {}
    
    -- Tabel pickup dengan pengelompokan dan urutan alfabetis
    local pickupToggles = {
        Adurite = {"Big Raw Adurite", "Raw Adurite"},
	AduriteBar = {"Adurite Bar", "Big Adurite Bar"},
        Bloodfruit = {"Bloodfruit"},
        Coal = {"Coal", "Big Coal"},
        Coin = {"Coin"},
        CrystalChunk = {"Crystal Chunk"},
        Emerald = {"Emerald", "Big Emerald"},
        Essence = {"Essence", "Big Essence"},
        Gold = {"Raw Gold", "Big Raw Gold"},
	GoldBar = {"Gold Bar", "Big Gold Bar"},
        Heartfruit = {"Heartfruit"},
        Hellstone = {"Big Raw Hellstone", "Raw Hellstone"},
	HellstoneBar = {"Big Hellstone Bar", "Hellstone Bar"},
	Hide = {"Hide", "Fire Hide"},
        IceCube = {"Ice Cube"},
        Iron = {"Big Raw Iron", "Raw Iron", "Big Iron Bar", "Iron Bar"},
        KingHeart = {"King Heart"},
        Leaves = {"Leaves", "Big Leaves"},
        Log = {"Log"},
        Magnetite = {"Raw Magnetite", "Big Raw Magnetite"},
		MagnetiteBar = {"Magnetite Bar", "Big Magnetite Bar"},
        Meat = {"Raw Meat","Raw Morsel"},
		MeatCooked = {"Cooked Meat","Cooked Morsel"},
        Phantomite = {"Big Raw Phantomite", "Raw Phantomite"},
	PhantomiteBar = {"Big Phantomite Bar", "Phantomite Bar"},
        PinkDiamond = {"Pink Diamond"},
        QueenHeart = {"Queen Heart"},
        SerpentTail = {"Serpent Tail"},
        SkeletonBone = {"Skeleton Bone"},
        Soulite = {"Big Raw Soulite", "Raw Soulite"},
	SouliteBar = {"Big Soulite Bar", "Soulite Bar"},
        SpiritKey = {"Spirit Key"},
        Steel = {"Steel Mix", "Steel Bar", "Big Steel Mix"},
        Stick = {"Stick", "Big Stick"},
        Stone = {"Big Stone", "Stone"},
        Undead = {"Undead Stick", "Undead Meat", "Undead Heart"},
	UnderworldMeat = {"Raw Underworld Meat"},
	UnderworldMeatCooked = {"Cooked Underworld Meat"},
	Void = {"Void Shard"},
        ZombieFlesh = {"Zombie Flesh"}
    }

    -- Sortir nama toggle secara alfabetis
    local sortedKeys = {}
    for key in pairs(pickupToggles) do
        table.insert(sortedKeys, key)
    end
    table.sort(sortedKeys)

    -- Fungsi untuk memulai pickup berdasarkan nama item
    local function pickupItems(itemNames)
        while pickupFunctions[itemNames] do
            local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            local nearbyItems = workspace.Important.Items:GetChildren()

            for _, item in pairs(nearbyItems) do
                if not pickupFunctions[itemNames] then break end
                if table.find(itemNames, item.Name) then
                    local itemPosition = item.Position
                    local distance = (playerPosition - itemPosition).Magnitude
                    
                    if distance <= pickupRadius then
                        spawn(function()
                            pcall(function()
                                game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(item)
                            end)
                        end)
                    end
                end
            end
            wait(0.1)
        end
    end

    -- Buat toggle pickup untuk setiap jenis item di pickupToggles, diurutkan secara alfabetis
    for _, name in ipairs(sortedKeys) do
        local items = pickupToggles[name]
        PickupTab:AddToggle({
            Name = "Pickup " .. name,
            Default = false,
            Callback = function(Value)
                pickupFunctions[items] = Value
                if Value then
                    spawn(function()
                        pickupItems(items)
                    end)
                end
            end
        })
    end
end

-- Fungsi untuk membuat tab Auto Features
function createAutoFeaturesTab()
    -- Membuat tab Auto Features
    local AutoFeaturesTab = Window:MakeTab({
        Name = "Auto Features",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Debug jika tab gagal dibuat
    if not AutoFeaturesTab then
        error("Failed to create Auto Features tab. Ensure the Window is initialized.")
        return
    end

    -- Variabel untuk status Auto Features
    local autoHealthEnabled = false
    local autoFoodEnabled = false
    local autoVoodooEnabled = false
    local autoGodsEnabled = false
    local autoRebirthEnabled = false

    -- Fungsi Auto Health
    local function runAutoHealth()
        while autoHealthEnabled do
            local healthText = game.Players.LocalPlayer.PlayerGui.MainGui.Panels.Stats.List.Health.NumberLabel.Text
            local currentHealth = tonumber(healthText)
            if currentHealth and currentHealth <= 90 then
                -- Gunakan item kesehatan di bag slot 1
                local args = { [1] = 1 }
                game:GetService("ReplicatedStorage").Events.UseBagItem:FireServer(unpack(args))
            end
            wait(0.1)
        end
    end

    -- Fungsi Auto Food
    local function runAutoFood()
        while autoFoodEnabled do
            local foodText = game.Players.LocalPlayer.PlayerGui.MainGui.Panels.Stats.List.Food.NumberLabel.Text
            local currentFood = tonumber(foodText)
            if currentFood and currentFood <= 90 then
                -- Gunakan item makanan di bag slot 2
                local args = { [1] = 2 }
                game:GetService("ReplicatedStorage").Events.UseBagItem:FireServer(unpack(args))
            end
            wait(0.1)
        end
    end

    -- Fungsi Auto Voodoo
    local function runAutoVoodoo()
        while autoVoodooEnabled do
            local healthText = game.Players.LocalPlayer.PlayerGui.MainGui.Panels.Stats.List.Health.NumberLabel.Text
            local voodooText = game.Players.LocalPlayer.PlayerGui.MainGui.Panels.Stats.List.Voodoo.NumberLabel.Text
            local currentHealth = tonumber(healthText)
            local currentVoodoo = tonumber(voodooText)

            if currentHealth and currentVoodoo and currentHealth <= 50 and currentVoodoo == 100 then
                -- Gunakan Voodoo Spell
                local args = {
                    [1] = Vector3.new(628.7835083007812, -146.5078887939453, 44.465423583984375)
                }
                game:GetService("ReplicatedStorage").Events.VoodooSpell:FireServer(unpack(args))
            end
            wait(0.1)
        end
    end

-- Status global
local autoGodsAndGoldEnabled = false
local autoGoldEnabled = false
local autoGodsEnabled = false

-- AutoGodsAndGold
local function isNearTarget(targetPosition, threshold)
    -- Menghitung jarak antara pemain dan target dengan toleransi lebih luas
    local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    local distance = (playerPosition - targetPosition).Magnitude


    -- Menambahkan toleransi jarak lebih besar untuk pengecekan (misalnya 15 studs)
    return distance < threshold
end

local function teleportToTarget(targetPosition, targetName)
    -- Teleport pemain ke posisi target
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
    -- Notifikasi teleportasi
    OrionLib:MakeNotification({
        Name = "Teleporting to " .. targetName,
        Content = "Player is teleporting to " .. targetName .. ".",
        Time = 3
    })
end

local function waitForTargetToDisappear(targetModel, targetFolder)
    -- Menunggu target hilang dari folder
    while targetModel.Parent == targetFolder do
        wait(1)
    end
end

local function runAutoGodsAndGold()
    local godsFolder = workspace:FindFirstChild("Map") and workspace.Map.Resources:FindFirstChild("Gods")
    local goldNodeFolder = workspace.Map.Resources:FindFirstChild("Gold Node")
    local goldStoneFolder = workspace.Map.Resources:FindFirstChild("Gold Stone")

    if not godsFolder then
        OrionLib:MakeNotification({
            Name = "Auto Gods + Auto Gold",
            Content = "No Gods folder found in the workspace.",
            Time = 3
        })
        return
    end

    -- Loop utama untuk Auto Gods + Auto Gold
    while autoGodsAndGoldEnabled do
        local godsModels = godsFolder:GetChildren()

        -- Filter gods untuk mengecualikan "Frozen Giant"
        local validGods = {}
        for _, godModel in ipairs(godsModels) do
            if godModel:IsA("Model") and godModel.Name ~= "Frozen Giant" then
                table.insert(validGods, godModel)
            end
        end

        if #validGods == 0 then
            -- Jika tidak ada God yang valid, jalankan Auto Gold
            if goldNodeFolder or goldStoneFolder then
                local goldPaths = {goldNodeFolder, goldStoneFolder}
                for _, goldFolder in ipairs(goldPaths) do
                    if not autoGodsAndGoldEnabled then break end

                    if goldFolder then
                        local goldModels = goldFolder:GetChildren()
                        for _, goldModel in ipairs(goldModels) do
                            if not autoGodsAndGoldEnabled then break end
                            if goldModel:IsA("Model") and goldModel:FindFirstChild("Reference") then
                                local targetPosition = goldModel.Reference.Position + Vector3.new(0, 10, 0)
                                
                                -- Cek apakah pemain sudah dekat dengan target
                                local tries = 0
                                local teleportAttempted = false
                                local maxTries = 3
                                local targetThreshold = 15  -- Toleransi jarak (misalnya 15 studs)

                                -- Cek apakah teleportasi berhasil
                                while tries < maxTries and not isNearTarget(targetPosition, targetThreshold) and autoGodsAndGoldEnabled do
                                    -- Jika teleport gagal, tunggu beberapa detik
                                    if not teleportAttempted then
                                        teleportToTarget(targetPosition, goldModel.Name)
                                        teleportAttempted = true
                                    end
                                    
                                    -- Tunggu 5 detik sebelum mencoba teleportasi lagi
                                    wait(5)  -- Menunggu 5 detik
                                    tries = tries + 1
                                end

                                -- Jika gagal lebih dari 3 kali, beri waktu lebih lama sebelum mencoba lagi
                                if tries >= maxTries then
                                    wait(10)  -- Tunggu 10 detik sebelum mencoba lagi
                                    tries = 0  -- Reset percobaan teleportasi
                                    teleportAttempted = false  -- Reset flag percobaan teleportasi
                                    continue  -- Kembali ke loop untuk mencoba teleportasi lagi
                                end

                                -- Tunggu sampai target hilang setelah teleportasi berhasil
                                while not isNearTarget(targetPosition, targetThreshold) and autoGodsAndGoldEnabled do
                                    -- Jika pemain belum cukup dekat dengan target, tunggu dan periksa lagi
                                    wait(1)
                                end

                                -- Setelah pemain dekat dengan target, tunggu target hilang
                                waitForTargetToDisappear(goldModel, goldFolder)
                                
                                -- Jeda sebelum berpindah ke resource berikutnya
                                wait(3)
                            end
                        end
                    end
                end
            end

            -- Tunggu sebentar sebelum memeriksa ulang kehadiran God
            wait(5)
        else
            -- Jika ada God yang valid, jalankan Auto Gods
            for _, godModel in ipairs(validGods) do
                if not autoGodsAndGoldEnabled then break end
                local targetPosition = godModel:GetPivot().Position + Vector3.new(0, 10, 0)

                -- Cek apakah pemain sudah dekat dengan target
                local tries = 0
                local teleportAttempted = false
                local maxTries = 3
                local targetThreshold = 15  -- Toleransi jarak (misalnya 15 studs)

                -- Ulangi mencoba teleportasi hingga pemain berada di dekat target
                while tries < maxTries and not isNearTarget(targetPosition, targetThreshold) and autoGodsAndGoldEnabled do
                    -- Jika teleport gagal, tunggu beberapa detik
                    if not teleportAttempted then
                        teleportToTarget(targetPosition, godModel.Name)
                        teleportAttempted = true
                    end

                    -- Tunggu 5 detik sebelum mencoba teleportasi lagi
                    wait(5)  -- Tunggu beberapa detik
                    tries = tries + 1
                end

                -- Jika gagal lebih dari 3 kali, beri waktu lebih lama sebelum mencoba lagi
                if tries >= maxTries then
                    wait(10)  -- Tunggu 10 detik sebelum mencoba lagi
                    
                    -- Setelah 10 detik tunggu, reset percobaan teleportasi dan coba lagi
                    tries = 0
                    teleportAttempted = false  -- Reset flag percobaan teleportasi
                    continue  -- Kembali ke loop untuk mencoba teleportasi lagi
                end

                -- Tunggu hingga God dihapus setelah teleportasi
                waitForTargetToDisappear(godModel, godsFolder)
                
                -- Jeda sebelum berpindah ke God berikutnya
                wait(3)
            end
        end

        -- Tunggu sebentar sebelum melanjutkan ke loop berikutnya
        wait(1)
    end

    OrionLib:MakeNotification({
        Name = "Auto Gods + Auto Gold",
        Content = "Stopped.",
        Time = 3
    })
end


-- Auto Gods
local function isNearTarget(targetPosition, threshold)
    -- Menghitung jarak antara pemain dan target dengan toleransi lebih luas
    local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    local distance = (playerPosition - targetPosition).Magnitude

    -- Menambahkan toleransi jarak lebih besar untuk pengecekan (misalnya 15 studs)
    return distance < threshold
end

local function teleportToTarget(targetPosition, targetName)
    -- Teleport pemain ke posisi target
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
    -- Notifikasi teleportasi
    OrionLib:MakeNotification({
        Name = "Teleporting to " .. targetName,
        Content = "Player is teleporting to " .. targetName .. ".",
        Time = 3
    })
end

local function waitForTargetToDisappear(targetModel, targetFolder)
    -- Menunggu target hilang dari folder
    while targetModel.Parent == targetFolder do
        wait(1)
    end
end

local function runAutoGods()
    local godsFolder = workspace:FindFirstChild("Map") and workspace.Map.Resources:FindFirstChild("Gods")

    if not godsFolder then
        OrionLib:MakeNotification({
            Name = "Auto Gods",
            Content = "No Gods folder found in the workspace.",
            Time = 3
        })
        return
    end

    -- Loop utama untuk Auto Gods
    while autoGodsEnabled do
        local godsModels = godsFolder:GetChildren()

        -- Filter gods untuk mengecualikan "Frozen Giant"
        local validGods = {}
        for _, godModel in ipairs(godsModels) do
            if godModel:IsA("Model") and godModel.Name ~= "Frozen Giant" then
                table.insert(validGods, godModel)
            end
        end

        if #validGods == 0 then
            OrionLib:MakeNotification({
                Name = "Auto Gods",
                Content = "No valid gods available. Waiting...",
                Time = 3
            })
            wait(5)
            continue
        end

        -- Teleport ke setiap valid god
        for _, godModel in ipairs(validGods) do
            if not autoGodsEnabled then break end

            -- Cek apakah pemain sudah dekat dengan target (God)
            local targetPosition = godModel:GetPivot().Position + Vector3.new(0, 10, 0)
            local tries = 0
            local teleportAttempted = false
            local maxTries = 3
            local targetThreshold = 15  -- Toleransi jarak (misalnya 15 studs)

            -- Ulangi mencoba teleportasi hingga pemain berada di dekat target
            while tries < maxTries and not isNearTarget(targetPosition, targetThreshold) and autoGodsEnabled do
                -- Jika teleport gagal, tunggu beberapa detik
                if not teleportAttempted then
                    teleportToTarget(targetPosition, godModel.Name)
                    teleportAttempted = true
                end

                -- Tunggu 5 detik sebelum mencoba teleportasi lagi
                wait(5)  -- Tunggu beberapa detik
                tries = tries + 1
            end

            -- Jika gagal lebih dari 3 kali, beri waktu lebih lama sebelum mencoba lagi
            if tries >= maxTries then
                wait(10)  -- Tunggu 10 detik sebelum mencoba lagi
                tries = 0  -- Reset percobaan teleportasi
                teleportAttempted = false  -- Reset flag percobaan teleportasi
                continue  -- Kembali ke loop untuk mencoba teleportasi lagi
            end

            -- Tunggu hingga target hilang setelah teleportasi berhasil
            while godModel.Parent == godsFolder and autoGodsEnabled do
                wait(0.1)
            end

            -- Jeda sebelum berpindah ke god berikutnya
            wait(3)
        end

        wait(1)
    end

    -- Notifikasi jika Auto Gods dihentikan
    OrionLib:MakeNotification({
        Name = "Auto Gods",
        Content = "Auto Gods stopped.",
        Time = 3
    })
end

-- Auto Gold
local function isNearTarget(targetPosition, threshold)
    -- Menghitung jarak antara pemain dan target dengan toleransi lebih luas
    local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    local distance = (playerPosition - targetPosition).Magnitude

    -- Menambahkan toleransi jarak lebih besar untuk pengecekan (misalnya 15 studs)
    return distance < threshold
end

local function teleportToTarget(targetPosition, targetName)
    -- Teleport pemain ke posisi target
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
    -- Notifikasi teleportasi
    OrionLib:MakeNotification({
        Name = "Teleporting to " .. targetName,
        Content = "Player is teleporting to " .. targetName .. ".",
        Time = 3
    })
end

local function waitForTargetToDisappear(targetModel, targetFolder)
    -- Menunggu target hilang dari folder
    while targetModel.Parent == targetFolder do
        wait(1)
    end
end

local function runAutoGold()
    local goldNodeFolder = workspace.Map.Resources:FindFirstChild("Gold Node")
    local goldStoneFolder = workspace.Map.Resources:FindFirstChild("Gold Stone")

    if not goldNodeFolder and not goldStoneFolder then
        OrionLib:MakeNotification({
            Name = "Auto Gold",
            Content = "No Gold folder found in the workspace.",
            Time = 3
        })
        return
    end

    -- Gabungkan kedua folder Gold Node dan Gold Stone
    local goldPaths = {goldNodeFolder, goldStoneFolder}

    -- Loop utama Auto Gold
    while autoGoldEnabled do
        for _, goldFolder in ipairs(goldPaths) do
            if not autoGoldEnabled then break end

            if goldFolder then
                local goldModels = goldFolder:GetChildren()
                for _, goldModel in ipairs(goldModels) do
                    if not autoGoldEnabled then break end
                    if goldModel:IsA("Model") and goldModel:FindFirstChild("Reference") then
                        local targetPosition = goldModel.Reference.Position + Vector3.new(0, 10, 0)

                        -- Cek apakah pemain sudah dekat dengan target
                        local tries = 0
                        local teleportAttempted = false
                        local maxTries = 3
                        local targetThreshold = 15  -- Toleransi jarak (misalnya 15 studs)

                        -- Ulangi mencoba teleportasi hingga pemain berada di dekat target
                        while tries < maxTries and not isNearTarget(targetPosition, targetThreshold) and autoGoldEnabled do
                            -- Jika teleport gagal, tunggu beberapa detik
                            if not teleportAttempted then
                                teleportToTarget(targetPosition, goldModel.Name)
                                teleportAttempted = true
                            end

                            -- Tunggu 5 detik sebelum mencoba teleportasi lagi
                            wait(5)  -- Tunggu beberapa detik
                            tries = tries + 1
                        end

                        -- Jika gagal lebih dari 3 kali, beri waktu lebih lama sebelum mencoba lagi
                        if tries >= maxTries then
                            wait(10)  -- Tunggu 10 detik sebelum mencoba lagi
                            tries = 0  -- Reset percobaan teleportasi
                            teleportAttempted = false  -- Reset flag percobaan teleportasi
                            continue  -- Kembali ke loop untuk mencoba teleportasi lagi
                        end

                        -- Tunggu hingga target hilang setelah teleportasi berhasil
                        while not isNearTarget(targetPosition, targetThreshold) and autoGoldEnabled do
                            -- Jika pemain belum cukup dekat dengan target, tunggu dan periksa lagi
                            wait(1)
                        end

                        -- Setelah pemain dekat dengan target, tunggu target hilang
                        waitForTargetToDisappear(goldModel, goldFolder)
                        
                        -- Jeda sebelum berpindah ke resource berikutnya
                        wait(3)
                    end
                end
            end
        end

        -- Tunggu sebentar sebelum melanjutkan ke loop berikutnya
        wait(1)
    end

    OrionLib:MakeNotification({
        Name = "Auto Gold",
        Content = "Stopped.",
        Time = 3
    })
end

-- Fungsi Auto Rebirth
local function runAutoRebirth()
    while autoRebirthEnabled do
        -- Coba mendapatkan referensi ke TextLabel
        local essenceLabel = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("MainGui")
            and game.Players.LocalPlayer.PlayerGui.MainGui.Panels.Topbar:FindFirstChild("EssenceBar")
            and game.Players.LocalPlayer.PlayerGui.MainGui.Panels.Topbar.EssenceBar:FindFirstChild("TextLabel")

        if essenceLabel then
            -- Ambil nilai teks dan hapus kata "Level" untuk mendapatkan angka
            local textContent = essenceLabel.Text
            local currentLevel = tonumber(textContent:match("%d+")) -- Menemukan angka dalam teks

            -- Jalankan fungsi rebirth jika level mencapai 100 atau lebih
            if currentLevel and currentLevel >= 100 then
                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Rebirth"):FireServer()

                -- Notifikasi
                OrionLib:MakeNotification({
                    Name = "Auto Rebirth",
                    Content = "Rebirth executed at Level " .. currentLevel .. ".",
                    Time = 5
                })

                -- Tunggu beberapa detik sebelum memeriksa kembali untuk menghindari spam
                wait(5)
            end
        else
            -- Notifikasi jika TextLabel tidak ditemukan
            OrionLib:MakeNotification({
                Name = "Auto Rebirth",
                Content = "EssenceBar TextLabel not found. Check your UI structure.",
                Time = 3
            })
            break
        end

        wait(1) -- Jeda kecil sebelum memeriksa ulang level
    end

    OrionLib:MakeNotification({
        Name = "Auto Rebirth",
        Content = "Auto Rebirth stopped.",
        Time = 3
    })
end

    -- Tambahkan Toggle untuk Auto Health
    AutoFeaturesTab:AddToggle({
        Name = "Auto Health",
        Default = false,
        Callback = function(state)
            autoHealthEnabled = state
            if state then
                OrionLib:MakeNotification({
                    Name = "Auto Health",
                    Content = "Place your health item in bag slot 1.",
                    Time = 3
                })
                spawn(runAutoHealth)
            end
        end
    })

    -- Tambahkan Toggle untuk Auto Food
    AutoFeaturesTab:AddToggle({
        Name = "Auto Food",
        Default = false,
        Callback = function(state)
            autoFoodEnabled = state
            if state then
                OrionLib:MakeNotification({
                    Name = "Auto Food",
                    Content = "Place your food item in bag slot 2.",
                    Time = 3
                })
                spawn(runAutoFood)
            end
        end
    })

    -- Tambahkan Toggle untuk Auto Voodoo
    AutoFeaturesTab:AddToggle({
        Name = "Auto VoodooSpell",
        Default = false,
        Callback = function(state)
            autoVoodooEnabled = state
            if state then
                spawn(runAutoVoodoo)
            end
        end
    })

	AutoFeaturesTab:AddToggle({
		Name = "Auto Gods + Auto Gold",
		Default = false,
		Callback = function(state)
			autoGodsAndGoldEnabled = state
			if state then
				spawn(runAutoGodsAndGold)
			end
		end
	})

	AutoFeaturesTab:AddToggle({
		Name = "Auto Gods",
		Default = false,
		Callback = function(state)
			autoGodsEnabled = state
			if state then
				spawn(runAutoGods)
			end
		end
	})

	AutoFeaturesTab:AddToggle({
		Name = "Auto Gold",
		Default = false,
		Callback = function(state)
			autoGoldEnabled = state
			if state then
				spawn(runAutoGold)
			end
		end
	})

    -- Tambahkan Toggle untuk Auto Rebirth
    AutoFeaturesTab:AddToggle({
        Name = "Auto Rebirth",
        Default = false,
        Callback = function(state)
            autoRebirthEnabled = state
            if state then
                spawn(runAutoRebirth)
            end
        end
    })

-- Variabel untuk toggle Auto Blighted
local autoBlightedEnabled = false
local lastCheckedTime = 0
local checkInterval = 3 -- Interval waktu dalam detik untuk memeriksa objek Blighted
local initialWaitTime = 2 -- Waktu tunggu untuk memberikan waktu bagi objek untuk muncul saat pertama kali toggle diaktifkan

-- Fungsi untuk menjalankan Auto Blighted
local function runAutoBlighted()
    local initialWaitStarted = false

    while autoBlightedEnabled do
        local currentTime = tick() -- Mendapatkan waktu saat ini

        -- Memberikan waktu tunggu saat pertama kali toggle diaktifkan
        if not initialWaitStarted then
            wait(initialWaitTime)  -- Tunggu beberapa detik sebelum memulai pencarian pertama
            initialWaitStarted = true
        end

        -- Pengecekan interval waktu untuk mengurangi frekuensi pencarian objek
        if currentTime - lastCheckedTime > checkInterval then
            -- Mencari folder Resources di dalam workspace.Map
            local resourcesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Resources")

            if not resourcesFolder then
                -- Jika tidak ditemukan folder Resources, tampilkan notifikasi dan berhenti
                OrionLib:MakeNotification({
                    Name = "Auto Blighted",
                    Content = "No Resources folder found in the workspace.",
                    Time = 3
                })
                break
            end

            -- Cari semua objek dengan nama mengandung "Blighted" di dalam folder Resources (termasuk subfolder)
            local blightedObjects = {}
            for _, obj in pairs(resourcesFolder:GetDescendants()) do
                -- Menggunakan string.lower untuk pencocokan nama yang tidak case-sensitive
                if obj:IsA("Model") and string.lower(obj.Name):find("blighted") then
                    -- Memastikan objek tersebut aktif dan ada di workspace
                    if obj and obj:IsDescendantOf(workspace) then
                        table.insert(blightedObjects, obj)
                    end
                end
            end

            -- Menyimpan waktu terakhir pengecekan
            lastCheckedTime = currentTime

            if #blightedObjects == 0 then
                -- Jika tidak ada objek Blighted ditemukan, kirim notifikasi dan tunggu sebentar sebelum mencoba lagi
                OrionLib:MakeNotification({
                    Name = "Auto Blighted",
                    Content = "No Blighted objects found. Waiting for respawn.",
                    Time = 5
                })
                wait(5)
                continue -- Coba lagi
            end

            -- Sortir objek Blighted berdasarkan jarak ke player
            table.sort(blightedObjects, function(a, b)
                local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                return (a:GetModelCFrame().Position - playerPos).Magnitude < (b:GetModelCFrame().Position - playerPos).Magnitude
            end)

            -- Pilih objek Blighted terdekat dan teleport ke sana
            for _, blightedObj in ipairs(blightedObjects) do
                if not autoBlightedEnabled then
                    break
                end

                if blightedObj and blightedObj:IsDescendantOf(workspace) then
                    -- Pastikan objek Blighted masih ada dan aktif di dunia
                    local targetPosition = nil

                    -- Jika objek Blighted memiliki PrimaryPart, gunakan itu
                    if blightedObj.PrimaryPart then
                        targetPosition = blightedObj.PrimaryPart.Position
                    else
                        -- Jika tidak ada PrimaryPart, gunakan posisi model secara keseluruhan
                        targetPosition = blightedObj:GetModelCFrame().Position
                    end

                    -- Mengecek jarak sebelum teleportasi
                    if (targetPosition - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 5 then
                        -- Teleport player ke posisi dalam objek
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                    end

                    -- Tunggu sebentar untuk memastikan teleportasi
                    wait(1)

                    -- Tunggu hingga objek Blighted hilang (jika ada)
                    while blightedObj and blightedObj:IsDescendantOf(workspace) and autoBlightedEnabled do
                        -- Mengecek kembali jarak jika objek belum hilang
                        if (blightedObj:GetModelCFrame().Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10 then
                            -- Teleport kembali ke objek jika pemain terlalu jauh
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(blightedObj:GetModelCFrame().Position)
                        end
                        wait(0.1)
                    end
                end

                -- Jeda sebelum pindah ke objek Blighted berikutnya
                wait(1)
            end

            -- Jeda kecil sebelum mencoba lagi
            wait(1)
        end
    end

    -- Notifikasi jika Auto Blighted dihentikan
    OrionLib:MakeNotification({
        Name = "Auto Blighted",
        Content = "Auto Blighted stopped.",
        Time = 3
    })
end

-- Menambahkan Toggle untuk Auto Blighted
AutoFeaturesTab:AddToggle({
    Name = "Auto All Blighted",
    Default = false,
    Callback = function(state)
        autoBlightedEnabled = state
        if state then
            spawn(runAutoBlighted)
        end
    end
})

-- Variabel untuk toggle Auto Penguin + Snowman
local autoPenguinSnowmanEnabled = false

-- Fungsi untuk menjalankan Auto Penguin + Snowman (bergantian)
local function runAutoPenguinSnowman()
    local critterOrder = {"Penguin", "Snowman"} -- Urutan pengambilan critter (Penguin -> Snowman)
    local currentIndex = 1

    while autoPenguinSnowmanEnabled do
        local currentCritter = critterOrder[currentIndex]

        -- Ambil folder Critters
        local crittersFolder = workspace:FindFirstChild("Important") and workspace.Important:FindFirstChild("Critters")
        if not crittersFolder then
            OrionLib:MakeNotification({
                Name = "Auto Penguin/Snowman",
                Content = "No Critters folder found in the workspace.",
                Time = 3
            })
            break
        end

        -- Cari critters berdasarkan tipe saat ini (Penguin atau Snowman)
        local critters = {}
        for _, critter in pairs(crittersFolder:GetChildren()) do
            if critter:IsA("Model") and string.find(critter.Name, currentCritter) then
                table.insert(critters, critter)
            end
        end

        if #critters == 0 then
            -- Tidak ada critter tipe saat ini, lanjut ke tipe berikutnya
            OrionLib:MakeNotification({
                Name = "Auto Penguin/Snowman",
                Content = currentCritter .. " not found. Moving to the next critter.",
                Time = 3
            })
            currentIndex = currentIndex % #critterOrder + 1 -- Pindah ke tipe berikutnya (Penguin <-> Snowman)
            wait(1)
            continue
        end

        -- Teleport ke satu critter terdekat dari tipe saat ini
        table.sort(critters, function(a, b)
            local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            return (a:GetPivot().Position - playerPos).Magnitude < (b:GetPivot().Position - playerPos).Magnitude
        end)

        local targetCritter = critters[1]
        if targetCritter and targetCritter:IsDescendantOf(workspace) then
            -- Loop untuk memantau posisi terbaru Critter
            while targetCritter and targetCritter:IsDescendantOf(workspace) and autoPenguinSnowmanEnabled do
                -- Ambil posisi terbaru dari PrimaryPart atau Pivot
                local currentPosition
                if targetCritter:FindFirstChild("PrimaryPart") then
                    currentPosition = targetCritter.PrimaryPart.Position + Vector3.new(0, 3, 0)
                else
                    currentPosition = targetCritter:GetPivot().Position + Vector3.new(0, 3, 0)
                end

                -- Validasi apakah posisi Critter valid sebelum teleportasi
                if currentPosition and (currentPosition - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 15 then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(currentPosition)
                end

                -- Tunggu sebentar sebelum memeriksa ulang posisi
                wait(0.2)
            end

            -- Setelah Critter hilang, lanjut ke tipe berikutnya
            currentIndex = currentIndex % #critterOrder + 1
        else
            -- Jika Critter tidak valid, lanjutkan ke tipe berikutnya
            currentIndex = currentIndex % #critterOrder + 1
        end

        -- Jeda kecil sebelum memulai tipe berikutnya
        wait(1)
    end

    -- Notifikasi jika Auto Penguin/Snowman dihentikan
    OrionLib:MakeNotification({
        Name = "Auto Penguin/Snowman",
        Content = "Auto Penguin/Snowman stopped.",
        Time = 3
    })
end

-- Menambahkan Toggle untuk Auto Penguin + Snowman
AutoFeaturesTab:AddToggle({
    Name = "Auto Penguin + Snowman",
    Default = false,
    Callback = function(state)
        autoPenguinSnowmanEnabled = state
        if state then
            spawn(runAutoPenguinSnowman)
        end
    end
})

-- Variabel untuk toggle Auto Ores
local autoHellstoneEnabled = false
local autoPhantomiteEnabled = false
local autoSouliteEnabled = false
local autoAllOresEnabled = false

-- Fungsi untuk memeriksa apakah pemain cukup dekat dengan ore
local function isNearTarget(targetPosition)
    local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    local distance = (targetPosition - playerPosition).Magnitude
    print("Player distance to target: " .. distance)  -- Debugging untuk melihat jaraknya

    -- Kembali true jika pemain sudah cukup dekat dengan ore
    return distance < 10  -- Tentukan jarak minimum untuk teleportasi (misalnya 10 studs)
end

local function teleportToTarget(targetPosition, oreName)
    -- Teleport pemain ke posisi ore
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
    -- Notifikasi teleportasi
    OrionLib:MakeNotification({
        Name = "Teleporting to " .. oreName,
        Content = "Player is teleporting to " .. oreName .. ".",
        Time = 3
    })
end

local function waitForOreToDisappear(oreModel, oreFolder)
    -- Menunggu hingga ore hilang dari folder
    while oreModel.Parent == oreFolder do
        wait(1)
    end
end

-- Fungsi untuk menjalankan Auto Ore
local function runAutoOre(oreName)
    while (oreName == "Hellstone" and autoHellstoneEnabled) or
          (oreName == "Phantomite" and autoPhantomiteEnabled) or
          (oreName == "Soulite" and autoSouliteEnabled) or
          autoAllOresEnabled do

        local resourcesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Resources")

        if resourcesFolder then
            -- Cari ore sesuai dengan nama yang diberikan
            local ores = {}
            for _, resource in pairs(resourcesFolder:GetChildren()) do
                if resource:IsA("Folder") then
                    for _, ore in pairs(resource:GetChildren()) do
                        if ore:IsA("Model") and string.find(ore.Name, oreName) then
                            table.insert(ores, ore)
                        end
                    end
                end
            end

            if #ores == 0 then
                -- Tidak ada ore ditemukan, kirim notifikasi
                OrionLib:MakeNotification({
                    Name = "Ore Not Found",
                    Content = "Ore " .. oreName .. " has disappeared, wait for it to respawn.",
                    Time = 5
                })

                -- Tunggu sebelum mencoba lagi
                wait(5)
                continue -- Kembali ke awal loop untuk memeriksa lagi
            end

            -- Sortir ore berdasarkan jarak dari player
            table.sort(ores, function(a, b)
                local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                return (a:GetModelCFrame().Position - playerPos).Magnitude < (b:GetModelCFrame().Position - playerPos).Magnitude
            end)

            -- Teleport ke ores satu per satu
            for _, ore in ipairs(ores) do
                if not autoAllOresEnabled and 
                   ((oreName == "Hellstone" and not autoHellstoneEnabled) or 
                    (oreName == "Phantomite" and not autoPhantomiteEnabled) or 
                    (oreName == "Soulite" and not autoSouliteEnabled)) then
                    break
                end

                -- Validasi sebelum teleport: pastikan ore masih ada
                if ore and ore:IsDescendantOf(workspace) then
                    -- Teleport ke ore jika pemain cukup dekat
                    local targetPosition = ore:GetModelCFrame().Position + Vector3.new(0, 3, 0) -- Posisi di atas ore
                    
                    -- Cek apakah pemain sudah dekat dengan target, jika tidak teleport ulang
                    if not isNearTarget(targetPosition) then
                        teleportToTarget(targetPosition, oreName)
                        wait(0.5)
                    end

                    -- Tunggu sampai ore benar-benar hilang
                    while ore and ore:IsDescendantOf(workspace) and 
                          ((oreName == "Hellstone" and autoHellstoneEnabled) or 
                           (oreName == "Phantomite" and autoPhantomiteEnabled) or 
                           (oreName == "Soulite" and autoSouliteEnabled) or 
                           autoAllOresEnabled) do
                        wait(0.1)
                    end
                end

                -- Jeda sebelum pindah ke ore berikutnya
                wait(1)
            end
        else
            -- Jika Resources folder tidak ditemukan
            OrionLib:MakeNotification({
                Name = "Auto " .. oreName,
                Content = "No Resources folder found in the workspace.",
                Time = 3
            })
            break
        end

        -- Jeda kecil sebelum loop berikutnya
        wait(1)
    end

    -- Notifikasi jika Auto Ore dihentikan
    OrionLib:MakeNotification({
        Name = "Auto " .. oreName,
        Content = "Auto " .. oreName .. " stopped.",
        Time = 3
    })
end

-- Fungsi untuk menjalankan Auto Hellstone
local function runAutoHellstone()
    runAutoOre("Hellstone")
end

-- Fungsi untuk menjalankan Auto Phantomite
local function runAutoPhantomite()
    runAutoOre("Phantomite")
end

-- Fungsi untuk menjalankan Auto Soulite
local function runAutoSoulite()
    runAutoOre("Soulite")
end

-- Fungsi untuk menjalankan Auto All Ores
local function runAutoAllOres()
    -- Menjalankan Auto Ore untuk Hellstone, Phantomite, dan Soulite secara bersamaan
    spawn(function()
        runAutoOre("Hellstone")
    end)
    spawn(function()
        runAutoOre("Phantomite")
    end)
    spawn(function()
        runAutoOre("Soulite")
    end)
end

-- Tambahkan Toggle untuk Auto Hellstone
AutoFeaturesTab:AddToggle({
    Name = "Auto Hellstone",
    Default = false,
    Callback = function(state)
        autoHellstoneEnabled = state
        if state then
            spawn(runAutoHellstone)
        end
    end
})

-- Tambahkan Toggle untuk Auto Phantomite
AutoFeaturesTab:AddToggle({
    Name = "Auto Phantomite",
    Default = false,
    Callback = function(state)
        autoPhantomiteEnabled = state
        if state then
            spawn(runAutoPhantomite)
        end
    end
})

-- Tambahkan Toggle untuk Auto Soulite
AutoFeaturesTab:AddToggle({
    Name = "Auto Soulite",
    Default = false,
    Callback = function(state)
        autoSouliteEnabled = state
        if state then
            spawn(runAutoSoulite)
        end
    end
})

-- Tambahkan Toggle untuk Auto All Ores (Hellstone, Phantomite, Soulite)
AutoFeaturesTab:AddToggle({
    Name = "Auto All Ores (Hellstone, Phantomite, Soulite)",
    Default = false,
    Callback = function(state)
        autoAllOresEnabled = state
        if state then
            spawn(runAutoAllOres)
        end
    end
})

-- Variabel untuk toggle Auto Critters
local autoZombieEnabled = false
local autoSkeletonEnabled = false
local autoSerpentEnabled = false
local autoAllCrittersEnabled = false

-- Fungsi untuk mengecek jarak antara pemain dan target
local function isNearTarget(targetPosition, threshold)
    local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    local distance = (playerPosition - targetPosition).Magnitude
    return distance < threshold
end

-- Fungsi untuk teleport ke target dan memberi notifikasi
local function teleportToTarget(targetPosition, targetName)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
    OrionLib:MakeNotification({
        Name = "Teleporting to " .. targetName,
        Content = "Teleporting to " .. targetName,
        Time = 3
    })
end

-- Fungsi untuk menunggu hingga target hilang dari workspace
local function waitForTargetToDisappear(targetModel, targetFolder)
    while targetModel.Parent == targetFolder do
        wait(1)
    end
end

-- Fungsi untuk menjalankan Auto Zombie
local function runAutoZombie()
    local crittersFolder = workspace:FindFirstChild("Important") and workspace.Important:FindFirstChild("Critters")
    if not crittersFolder then
        OrionLib:MakeNotification({
            Name = "Auto Zombie",
            Content = "No Critters folder found in the workspace.",
            Time = 3
        })
        return
    end

    -- Menemukan critter Zombie
    local critters = {}
    for _, critter in pairs(crittersFolder:GetChildren()) do
        if critter:IsA("Model") and string.find(critter.Name, "Zombie") then
            table.insert(critters, critter)
        end
    end

    if #critters == 0 then
        OrionLib:MakeNotification({
            Name = "Auto Zombie",
            Content = "Zombie not found in the workspace.",
            Time = 3
        })
        return
    end

    -- Menjalankan logika teleportasi ke critter Zombie terdekat
    while autoZombieEnabled do
        table.sort(critters, function(a, b)
            local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            return (a:GetPivot().Position - playerPos).Magnitude < (b:GetPivot().Position - playerPos).Magnitude
        end)

        local targetCritter = critters[1]
        if targetCritter and targetCritter:IsDescendantOf(workspace) then
            local currentPosition
            if targetCritter:FindFirstChild("PrimaryPart") then
                currentPosition = targetCritter.PrimaryPart.Position + Vector3.new(0, 3, 0)
            else
                currentPosition = targetCritter:GetPivot().Position + Vector3.new(0, 3, 0)
            end

            -- Mengecek jarak sebelum teleportasi
            local tries = 0
            local maxTries = 3
            local teleportAttempted = false
            local targetThreshold = 15  -- Toleransi jarak (misalnya 15 studs)

            -- Ulangi mencoba teleportasi hingga pemain berada di dekat target
            while tries < maxTries and not isNearTarget(currentPosition, targetThreshold) and autoZombieEnabled do
                if not teleportAttempted then
                    teleportToTarget(currentPosition, "Zombie")
                    teleportAttempted = true
                end
                wait(5)  -- Tunggu beberapa detik
                tries = tries + 1
            end

            -- Jika gagal lebih dari 3 kali, beri waktu lebih lama sebelum mencoba lagi
            if tries >= maxTries then
                wait(10)  -- Tunggu 10 detik sebelum mencoba lagi
                tries = 0
                teleportAttempted = false
                continue
            end

            -- Tunggu hingga critter hilang setelah teleportasi berhasil
            waitForTargetToDisappear(targetCritter, crittersFolder)

            -- Jeda sebelum berpindah ke critter berikutnya
            wait(3)
        end

        wait(0.2) -- Tunggu sebelum memeriksa kembali
    end
end

-- Fungsi untuk menjalankan Auto Skeleton
local function runAutoSkeleton()
    local crittersFolder = workspace:FindFirstChild("Important") and workspace.Important:FindFirstChild("Critters")
    if not crittersFolder then
        OrionLib:MakeNotification({
            Name = "Auto Skeleton",
            Content = "No Critters folder found in the workspace.",
            Time = 3
        })
        return
    end

    -- Menemukan critter Skeleton
    local critters = {}
    for _, critter in pairs(crittersFolder:GetChildren()) do
        if critter:IsA("Model") and string.find(critter.Name, "Skeleton") then
            table.insert(critters, critter)
        end
    end

    if #critters == 0 then
        OrionLib:MakeNotification({
            Name = "Auto Skeleton",
            Content = "Skeleton not found in the workspace.",
            Time = 3
        })
        return
    end

    -- Menjalankan logika teleportasi ke critter Skeleton terdekat
    while autoSkeletonEnabled do
        table.sort(critters, function(a, b)
            local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            return (a:GetPivot().Position - playerPos).Magnitude < (b:GetPivot().Position - playerPos).Magnitude
        end)

        local targetCritter = critters[1]
        if targetCritter and targetCritter:IsDescendantOf(workspace) then
            local currentPosition
            if targetCritter:FindFirstChild("PrimaryPart") then
                currentPosition = targetCritter.PrimaryPart.Position + Vector3.new(0, 3, 0)
            else
                currentPosition = targetCritter:GetPivot().Position + Vector3.new(0, 3, 0)
            end

            -- Mengecek jarak sebelum teleportasi
            local tries = 0
            local maxTries = 3
            local teleportAttempted = false
            local targetThreshold = 15  -- Toleransi jarak (misalnya 15 studs)

            while tries < maxTries and not isNearTarget(currentPosition, targetThreshold) and autoSkeletonEnabled do
                if not teleportAttempted then
                    teleportToTarget(currentPosition, "Skeleton")
                    teleportAttempted = true
                end
                wait(5)  -- Tunggu beberapa detik
                tries = tries + 1
            end

            if tries >= maxTries then
                wait(10)  -- Tunggu 10 detik sebelum mencoba lagi
                tries = 0
                teleportAttempted = false
                continue
            end

            -- Tunggu hingga critter hilang setelah teleportasi berhasil
            waitForTargetToDisappear(targetCritter, crittersFolder)

            -- Jeda sebelum berpindah ke critter berikutnya
            wait(3)
        end

        wait(0.2) -- Tunggu sebelum memeriksa kembali
    end
end

-- Fungsi untuk menjalankan Auto Serpent
local function runAutoSerpent()
    local crittersFolder = workspace:FindFirstChild("Important") and workspace.Important:FindFirstChild("Critters")
    if not crittersFolder then
        OrionLib:MakeNotification({
            Name = "Auto Serpent",
            Content = "No Critters folder found in the workspace.",
            Time = 3
        })
        return
    end

    -- Menemukan critter Serpent
    local critters = {}
    for _, critter in pairs(crittersFolder:GetChildren()) do
        if critter:IsA("Model") and string.find(critter.Name, "Serpent") then
            table.insert(critters, critter)
        end
    end

    if #critters == 0 then
        OrionLib:MakeNotification({
            Name = "Auto Serpent",
            Content = "Serpent not found in the workspace.",
            Time = 3
        })
        return
    end

    -- Menjalankan logika teleportasi ke critter Serpent terdekat
    while autoSerpentEnabled do
        table.sort(critters, function(a, b)
            local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            return (a:GetPivot().Position - playerPos).Magnitude < (b:GetPivot().Position - playerPos).Magnitude
        end)

        local targetCritter = critters[1]
        if targetCritter and targetCritter:IsDescendantOf(workspace) then
            local currentPosition
            if targetCritter:FindFirstChild("PrimaryPart") then
                currentPosition = targetCritter.PrimaryPart.Position + Vector3.new(0, 3, 0)
            else
                currentPosition = targetCritter:GetPivot().Position + Vector3.new(0, 3, 0)
            end

            -- Mengecek jarak sebelum teleportasi
            local tries = 0
            local maxTries = 3
            local teleportAttempted = false
            local targetThreshold = 15

            while tries < maxTries and not isNearTarget(currentPosition, targetThreshold) and autoSerpentEnabled do
                if not teleportAttempted then
                    teleportToTarget(currentPosition, "Serpent")
                    teleportAttempted = true
                end
                wait(5)
                tries = tries + 1
            end

            if tries >= maxTries then
                wait(10)
                tries = 0
                teleportAttempted = false
                continue
            end

            -- Tunggu hingga critter hilang setelah teleportasi berhasil
            waitForTargetToDisappear(targetCritter, crittersFolder)

            -- Jeda sebelum berpindah ke critter berikutnya
            wait(3)
        end

        wait(0.2) -- Tunggu sebelum memeriksa kembali
    end
end

-- Fungsi untuk menjalankan Auto All Critters
local function runAutoAllCritters()
    local critterOrder = {"Zombie", "Skeleton", "Serpent"}
    local currentIndex = 1

    while autoAllCrittersEnabled do
        local currentCritter = critterOrder[currentIndex]

        -- Ambil folder Critters
        local crittersFolder = workspace:FindFirstChild("Important") and workspace.Important:FindFirstChild("Critters")
        if not crittersFolder then
            OrionLib:MakeNotification({
                Name = "Auto All Critters",
                Content = "No Critters folder found in the workspace.",
                Time = 3
            })
            break
        end

        -- Cari critters berdasarkan tipe saat ini
        local critters = {}
        for _, critter in pairs(crittersFolder:GetChildren()) do
            if critter:IsA("Model") and string.find(critter.Name, currentCritter) then
                table.insert(critters, critter)
            end
        end

        if #critters == 0 then
            -- Tidak ada critter tipe saat ini, lanjut ke tipe berikutnya
            OrionLib:MakeNotification({
                Name = "Auto All Critters",
                Content = currentCritter .. " not found. Moving to the next critter.",
                Time = 3
            })
            currentIndex = currentIndex % #critterOrder + 1
            wait(1)
            continue
        end

        -- Teleport ke satu critter terdekat dari tipe saat ini
        table.sort(critters, function(a, b)
            local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            return (a:GetPivot().Position - playerPos).Magnitude < (b:GetPivot().Position - playerPos).Magnitude
        end)

        local targetCritter = critters[1]
        if targetCritter and targetCritter:IsDescendantOf(workspace) then
            -- Loop untuk memantau posisi terbaru Critter
            while targetCritter and targetCritter:IsDescendantOf(workspace) and autoAllCrittersEnabled do
                -- Ambil posisi terbaru dari PrimaryPart atau Pivot
                local currentPosition
                if targetCritter:FindFirstChild("PrimaryPart") then
                    currentPosition = targetCritter.PrimaryPart.Position + Vector3.new(0, 3, 0)
                else
                    currentPosition = targetCritter:GetPivot().Position + Vector3.new(0, 3, 0)
                end

                -- Validasi apakah posisi Critter valid sebelum teleportasi
                if currentPosition and (currentPosition - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 15 then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(currentPosition)
                end

                -- Tunggu sebentar sebelum memeriksa ulang posisi
                wait(0.2)
            end

            -- Setelah Critter hilang, lanjut ke tipe berikutnya
            currentIndex = currentIndex % #critterOrder + 1
        else
            -- Jika Critter tidak valid, lanjutkan ke tipe berikutnya
            currentIndex = currentIndex % #critterOrder + 1
        end

        -- Jeda kecil sebelum memulai tipe berikutnya
        wait(1)
    end

    -- Notifikasi jika Auto All Critters dihentikan
    OrionLib:MakeNotification({
        Name = "Auto All Critters",
        Content = "Auto All Critters stopped.",
        Time = 3
    })
end

-- Menambahkan Toggle untuk Auto Zombie, Auto Skeleton, Auto Serpent dan Auto All Critters
AutoFeaturesTab:AddToggle({
    Name = "Auto Zombie",
    Default = false,
    Callback = function(state)
        autoZombieEnabled = state
        if state then
            spawn(runAutoZombie)
        end
    end
})

AutoFeaturesTab:AddToggle({
    Name = "Auto Skeleton",
    Default = false,
    Callback = function(state)
        autoSkeletonEnabled = state
        if state then
            spawn(runAutoSkeleton)
        end
    end
})

AutoFeaturesTab:AddToggle({
    Name = "Auto Serpent",
    Default = false,
    Callback = function(state)
        autoSerpentEnabled = state
        if state then
            spawn(runAutoSerpent)
        end
    end
})

AutoFeaturesTab:AddToggle({
    Name = "Auto All Critters (Zombie, Skeleton, Serpent)",
    Default = false,
    Callback = function(state)
        autoAllCrittersEnabled = state
        if state then
            spawn(runAutoAllCritters)
        end
    end
})

-- Fungsi untuk membuat Tab Auto Drop
function createAutoDropTab()
    local AutoDropTab = Window:MakeTab({
        Name = "Auto Drop",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Variabel untuk Dropdown dan Auto Drop
    local selectedItem = nil
    local inventoryItems = {}
    local inventoryDropdown

    -- Fungsi untuk menyegarkan daftar inventaris
    local function refreshInventory()
        inventoryItems = {}
        local inventoryList = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.RightPanel.Inventory.List

        for _, itemSlot in pairs(inventoryList:GetChildren()) do
            if itemSlot:IsA("ImageButton") then
                local title = itemSlot:FindFirstChild("title")
                if title and title:IsA("TextLabel") and title.Text ~= "" then
                    table.insert(inventoryItems, {slot = tonumber(itemSlot.Name), name = title.Text})
                end
            end
        end

        -- Urutkan item berdasarkan nomor slot
        table.sort(inventoryItems, function(a, b) return a.slot < b.slot end)

        -- Refresh dropdown dengan nama-nama item
        local itemNames = {}
        for _, item in ipairs(inventoryItems) do
            table.insert(itemNames, item.name)
        end

        if inventoryDropdown then
            inventoryDropdown:Refresh(itemNames, true)
        end
    end

    -- Tambahkan Dropdown untuk Inventaris
    inventoryDropdown = AutoDropTab:AddDropdown({
        Name = "Select Item to Drop",
        Default = nil,
        Options = {}, -- Akan diperbarui oleh `refreshInventory`
        Callback = function(Value)
            selectedItem = Value
        end
    })

    -- Tombol untuk menyegarkan dropdown inventaris
    AutoDropTab:AddButton({
        Name = "Refresh Inventory",
        Callback = function()
            refreshInventory()
        end
    })

    -- Fungsi Auto Drop dengan siklus 7 detik berjalan dan 3 detik berhenti
    local autoDropEnabled = false
    local function runAutoDrop()
        while autoDropEnabled do
            local startTime = tick()
            -- Berjalan selama 7 detik
            while tick() - startTime < 4 and autoDropEnabled do
                if selectedItem then
                    local itemSlot = nil
                    for _, item in ipairs(inventoryItems) do
                        if item.name == selectedItem then
                            itemSlot = item.slot
                            break
                        end
                    end

                    if itemSlot then
                        local args = {
                            [1] = itemSlot, -- Slot yang sesuai
                            [2] = selectedItem -- Nama item
                        }
                        game:GetService("ReplicatedStorage").Events.DropBagItem:FireServer(unpack(args))
                    end
                end
                wait(0.1) -- Interval antar pengiriman
            end

            -- Berhenti selama 3 detik
            if autoDropEnabled then
                wait(6)
            end
        end
    end

    -- Tambahkan Toggle untuk Auto Drop
    AutoDropTab:AddToggle({
        Name = "Auto Drop",
        Default = false,
        Callback = function(state)
            autoDropEnabled = state
            if state then
                spawn(runAutoDrop)
            end
        end
    })

    -- Muat inventaris saat pertama kali tab dibuat
    refreshInventory()
end

-- Panggil fungsi ini di tempat yang sesuai untuk menambahkan tab ke UI
createAutoDropTab()


end

-- Pastikan untuk memanggil fungsi createPickupTab setelah key valid
if keyLoaded or checkKeyValid() then
	createTabs()
end

-- Memulai UI
OrionLib:Init()