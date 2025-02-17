-- FischServerFinder by Penguin!
-- https://discord.gg/fWncS2vFx

if not game:IsLoaded() then game.Loaded:Wait() end

local loadConfig, parseuptime, formattime, tp, teleport, creategui, createframe, notifygui, minimizegui, askautohop,chesttpscan, scanchest, potentialsunkenchest, loadedsunkenchest, claimsunkenchest, issunkenchest, convertEventString, sendwebhook, haschildren, scanWorld, notify, scan
local config, cacheFile
local data = loadstring(game:HttpGet("https://raw.githubusercontent.com/P3nguinMinecraft/FischScripts/main/fsf-data.lua"))()
local scriptvers = "2.1"
local checkteleporting = false
local loadedmsg = false
local chestfound = false
local desiredserver = false
local scheduledhop = false
local chesttpscancount = 0
local autofarmchestpotential = false
local autofarmchestclaimed = false
local camera = game.Workspace.CurrentCamera

if not game.PlaceId == 16732694052 then
    warn("[FSF] You are not in Fisch!")
    return
end

print("[FSF] Loading")

local cache = {
    autohop = false,
}

local loading = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("loading", 3)
if loading then
    loading.loading.Visible = false
end

loadConfig = function()
    if isfile("FischServerFinder/config.json") then
        config = game:GetService("HttpService"):JSONDecode(readfile("FischServerFinder/config.json"))
    else
        config = data.defaultConfig
    end

    if not writefile then return end

    if not isfile("FischServerFinder/config.json") and writefile then
        if not isfolder("FischServerFinder") then
            makefolder("FischServerFinder")
        end
        writefile("FischServerFinder/config.json", game:GetService("HttpService"):JSONEncode(data.defaultConfig))
        notifygui("Welcome to FSF! Change config as needed")
        task.spawn(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/P3nguinMinecraft/FischScripts/main/fsf-gui.lua"))()
        end)
    end

    if not string.match(config.versid, data.versid) then
        local function updateTable(default, previous)
            local updated = {}

            for key, value in pairs(default) do
                if type(value) == "table" and type(previous[key]) == "table" then
                    updated[key] = updateTable(value, previous[key])
                elseif previous[key] ~= nil then
                    updated[key] = previous[key]
                else
                    updated[key] = value
                end
            end

            return updated
        end
        local function mergeConfig()
            config = updateTable(data.defaultConfig, config)
            config.version = data.version
            config.versid = data.versid
            local encode = game:GetService("HttpService"):JSONEncode(config)
            writefile("FischServerFinder/config.json", encode)
        end
        notifygui("Script updated from " .. config.version .. " to " .. data.version)
        notifygui(data.updmsg)
        mergeConfig()
        if data.settingchanged then
            notifygui("Settings have changed!")
            notifygui(data.settingmsg)
            task.spawn(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/P3nguinMinecraft/FischScripts/main/fsf-gui.lua"))()
            end)
        end
    end
end

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local serversfilename = "FischServerFinder/servers.json"

parseuptime = function()
    local uptime = game:GetService("ReplicatedStorage").world.uptime.Value

    local hour = math.floor(uptime / 3600)
    local build = uptime % 3600

    local minute = math.floor(build / 60)
    local second = math.floor(build % 60)

    return hour, minute, second
end

formattime = function(h, m, s)
    return string.format("%02d:%02d:%02d", h, m, s)
end

tp = function(x, y, z)
    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(x, y, z))
end

teleport = function()
    local Server, Next = nil, nil
    scheduledhop = true

    local function ListServers(cursor)
        local ServersAPI = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local Raw = game:HttpGet(ServersAPI .. ((cursor and "&cursor=" .. cursor) or ""))
        local Decode = HttpService:JSONDecode(Raw)

        if Decode.errors then
            if isfile(serversfilename) then
                return HttpService:JSONDecode(readfile(serversfilename))
            end
            return nil
        else
            if writefile then
                writefile(serversfilename, Raw)
            end
            return HttpService:JSONDecode(Raw)
        end
    end

    local function RemoveServer(serverId)
        if not isfile(serversfilename) then return end

        local Servers = HttpService:JSONDecode(readfile(serversfilename))
        local NewData = {}
        for _, server in ipairs(Servers.data) do
            if server.id ~= serverId then
                table.insert(NewData, server)
            end
        end
        Servers.data = NewData
        writefile(serversfilename, HttpService:JSONEncode(Servers))
    end

    notifygui("Teleporting", 22, 209, 242)

    while Server == nil or Server.playing == nil or Server.PrivateServerId ~= nil do
        local Servers = ListServers(Next)

        if Servers and Servers.nextPageCursor then
            Server = Servers.data[math.random(1, #Servers.data)]
            Next = Servers.nextPageCursor
        else
            notifygui("No available servers!", 242, 44, 22)
            return
        end
    end

    if Server and Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
        if cacheFile.autohop then
            cache.autohop = true
            writefile("FischServerFinder/cache.json", game:GetService("HttpService"):JSONEncode(cache))
        end
        RemoveServer(Server.id)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id, game:GetService("Players").LocalPlayer)

        task.spawn(function()
            task.wait(10)
            notifygui("Hop failed. Retrying...", 242, 44, 22)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, game:GetService("Players").LocalPlayer)
            scheduledhop = false
        end)
    end
end

creategui = function()
    local playerGui = game.Players.LocalPlayer.PlayerGui

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FischServerFinder"
    screenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.25, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    mainFrame.ZIndex = 101

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(0.95, 0, 0.18, 0)
    topBar.Position = UDim2.new(0.5, 0, 0.01, 0)
    topBar.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
    topBar.BorderSizePixel = 0
    topBar.Active = true
    topBar.AnchorPoint = Vector2.new(0.5, 0)
    topBar.Parent = mainFrame
    topBar.ZIndex = 101

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "NotificationContainer"
    scrollFrame.Size = UDim2.new(0.95, 0, 0.78, 0)
    scrollFrame.Position = UDim2.new(0.5, 0, 0.20, 0)
    scrollFrame.AnchorPoint = Vector2.new(0.5, 0)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.Parent = mainFrame
    scrollFrame.ZIndex = 101

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Name = "UIList"
    uiListLayout.Padding = UDim.new(0, 5)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = scrollFrame

    local closeGUI = Instance.new("TextButton")
    closeGUI.Name = "CloseGUI"
    closeGUI.Size = UDim2.new(0.07, 0, 0.3, 0)
    closeGUI.Position = UDim2.new(0.02, 0, 0.16, 0)
    closeGUI.BackgroundColor3 = Color3.new(1, 0, 0)
    closeGUI.Text = "X"
    closeGUI.TextColor3 = Color3.new(1, 1, 1)
    closeGUI.TextScaled = true
    closeGUI.Font = Enum.Font.SourceSans
    closeGUI.AnchorPoint = Vector2.new(0, 0.5)
    closeGUI.Parent = topBar
    closeGUI.ZIndex = 101

    local hop = Instance.new("TextButton")
    hop.Name = "ServerHop"
    hop.Size = UDim2.new(0.25, 0, 0.3, 0)
    hop.Position = UDim2.new(0.12, 0, 0.16, 0)
    hop.BackgroundColor3 = Color3.new(0, 1, 1)
    hop.Text = "Server Hop"
    hop.TextColor3 = Color3.new(0.3, 0.3, 0.3)
    hop.TextScaled = true
    hop.Font = Enum.Font.SourceSans
    hop.AnchorPoint = Vector2.new(0, 0.5)
    hop.Parent = topBar
    hop.ZIndex = 101

    local rescan = Instance.new("TextButton")
    rescan.Name = "Rescan"
    rescan.Size = UDim2.new(0.2, 0, 0.3, 0)
    rescan.Position = UDim2.new(0.39, 0, 0.16, 0)
    rescan.BackgroundColor3 = Color3.new(0.42, 0.75, 0.82)
    rescan.Text = "Rescan"
    rescan.TextColor3 = Color3.new(0, 0, 0)
    rescan.TextScaled = true
    rescan.Font = Enum.Font.SourceSans
    rescan.AnchorPoint = Vector2.new(0, 0.5)
    rescan.Parent = topBar
    rescan.ZIndex = 101

    local JobId = Instance.new("TextButton")
    JobId.Name = "JobId"
    JobId.Size = UDim2.new(0.28, 0, 0.3, 0)
    JobId.Position = UDim2.new(0.61, 0, 0.16, 0)
    JobId.BackgroundColor3 = Color3.new(0.11, 0.81, 0.15)
    JobId.Text = "Copy JobId"
    JobId.TextColor3 = Color3.new(0, 0, 0)
    JobId.TextScaled = true
    JobId.Font = Enum.Font.SourceSans
    JobId.AnchorPoint = Vector2.new(0, 0.5)
    JobId.Parent = topBar
    JobId.ZIndex = 101

    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "minimizeButton"
    minimizeButton.Size = UDim2.new(0.07, 0, 0.3, 0)
    minimizeButton.Position = UDim2.new(0.91, 0, 0.16, 0)
    minimizeButton.BackgroundColor3 = Color3.new(1, 0.93, 0)
    minimizeButton.Text = "-"
    minimizeButton.TextColor3 = Color3.new(0, 0, 0)
    minimizeButton.TextScaled = true
    minimizeButton.Font = Enum.Font.SourceSans
    minimizeButton.AnchorPoint = Vector2.new(0, 0.5)
    minimizeButton.Parent = topBar
    minimizeButton.ZIndex = 101

    local clear = Instance.new("TextButton")
    clear.Name = "clear"
    clear.Size = UDim2.new(0.23, 0, 0.3, 0)
    clear.Position = UDim2.new(0.02, 0, 0.5, 0)
    clear.BackgroundColor3 = Color3.new(0.8, 0.1, 0.1)
    clear.Text = "Clear"
    clear.TextColor3 = Color3.new(0, 0, 0)
    clear.TextScaled = true
    clear.Font = Enum.Font.SourceSans
    clear.AnchorPoint = Vector2.new(0, 0.5)
    clear.Parent = topBar
    clear.ZIndex = 101

    local JobIdBox = Instance.new("TextBox")
    JobIdBox.Name = "JobIdBox"
    JobIdBox.Size = UDim2.new(0.45, 0, 0.3, 0)
    JobIdBox.Position = UDim2.new(0.27, 0, 0.5, 0)
    JobIdBox.BackgroundColor3 = Color3.new(0.93, 0.63, 1)
    JobIdBox.TextColor3 = Color3.new(0, 0, 0)
    JobIdBox.TextScaled = true
    JobIdBox.Font = Enum.Font.SourceSans
    JobIdBox.Text = "Input JobId"
    JobIdBox.PlaceholderText = "Input JobId"
    JobIdBox.AnchorPoint = Vector2.new(0, 0.5)
    JobIdBox.Parent = topBar
    JobIdBox.ZIndex = 101

    local TPJobId = Instance.new("TextButton")
    TPJobId.Name = "TPJobId"
    TPJobId.Size = UDim2.new(0.24, 0, 0.3, 0)
    TPJobId.Position = UDim2.new(0.74, 0, 0.5, 0)
    TPJobId.BackgroundColor3 = Color3.new(0.57, 0.92, 0.63)
    TPJobId.Text = "Goto JobId"
    TPJobId.TextColor3 = Color3.new(0, 0, 0)
    TPJobId.TextScaled = true
    TPJobId.Font = Enum.Font.SourceSans
    TPJobId.AnchorPoint = Vector2.new(0, 0.5)
    TPJobId.Parent = topBar
    TPJobId.ZIndex = 101

    local OpenGUI = Instance.new("TextButton")
    OpenGUI.Name = "OpenGUI"
    OpenGUI.Size = UDim2.new(0.47, 0, 0.3, 0)
    OpenGUI.Position = UDim2.new(0.02, 0, 0.84, 0)
    OpenGUI.BackgroundColor3 = Color3.new(1, 0.22, 0.67)
    OpenGUI.Text = "Open GUI"
    OpenGUI.TextColor3 = Color3.new(0, 0, 0)
    OpenGUI.TextScaled = true
    OpenGUI.Font = Enum.Font.SourceSans
    OpenGUI.AnchorPoint = Vector2.new(0, 0.5)
    OpenGUI.Parent = topBar
    OpenGUI.ZIndex = 101

    local ReloadConfig = Instance.new("TextButton")
    ReloadConfig.Name = "ReloadConfig"
    ReloadConfig.Size = UDim2.new(0.47, 0, 0.3, 0)
    ReloadConfig.Position = UDim2.new(0.51, 0, 0.84, 0)
    ReloadConfig.BackgroundColor3 = Color3.new(0.16, 0.85, 0.48)
    ReloadConfig.Text = "Reload Config"
    ReloadConfig.TextColor3 = Color3.new(0, 0, 0)
    ReloadConfig.TextScaled = true
    ReloadConfig.Font = Enum.Font.SourceSans
    ReloadConfig.AnchorPoint = Vector2.new(0, 0.5)
    ReloadConfig.Parent = topBar
    ReloadConfig.ZIndex = 101

    closeGUI.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    hop.MouseButton1Click:Connect(function()
        teleport()
    end)

    rescan.MouseButton1Click:Connect(function()
        notifygui("Rescanning", 107, 191, 209)
        scan()
    end)

    JobId.MouseButton1Click:Connect(function()
        setclipboard(game.JobId)
        notifygui("Copied JobId", 255, 255, 255)
    end)

    minimizeButton.MouseButton1Click:Connect(function()
        minimizegui(minimizeButton)
    end)

    clear.MouseButton1Click:Connect(function()
        for _, notification in ipairs(scrollFrame:GetChildren()) do
            if notification.Name == "NotificationFrame" then
                notification:Destroy()
            end
        end
    end)

    TPJobId.MouseButton1Click:Connect(function()
        notifygui("TPing to JobId", 255, 255, 255)
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, JobIdBox.Text, game:GetService("Players").LocalPlayer)
    end)

    OpenGUI.MouseButton1Click:Connect(function()
        notifygui("Opening GUI", 255, 56, 172)
        if not writefile then
            notifygui("You cannot change configs because your executor does not support files!")
        end
        loadstring(game:HttpGet("https://raw.githubusercontent.com/P3nguinMinecraft/FischScripts/main/fsf-gui.lua"))()
    end)

    ReloadConfig.MouseButton1Click:Connect(function()
        notifygui("Reloading Config", 41, 217, 123)
        loadConfig()
    end)
end

createframe = function()
    local playerGui = game.Players.LocalPlayer.PlayerGui
    local screenGui = playerGui:FindFirstChild("FischServerFinder")

    if not screenGui then
        creategui()
        screenGui = playerGui:FindFirstChild("FischServerFinder")
    end
    local mainFrame = screenGui:FindFirstChild("MainFrame")
    local scrollFrame = mainFrame:FindFirstChild("NotificationContainer")
    local uiListLayout = scrollFrame:FindFirstChild("UIList")

    local frame = Instance.new("Frame")
    frame.Name = "NotificationFrame"
    frame.Size = UDim2.new(1, 0, 0, camera.ViewportSize.Y * 0.05)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.BorderSizePixel = 0
    frame.Parent = scrollFrame
    frame.ZIndex = 101

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)

    return frame
end

notifygui = function(text, r, g, b)
    text = tostring(text)
    if not r then r = 255 end
    if not g then g = 255 end
    if not b then b = 255 end
    print(text)

    local frame = createframe()

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.06, 0, 0.4, 0)
    closeButton.Position = UDim2.new(0.015, 0, 0.3, 0)
    closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSans
    closeButton.Parent = frame
    closeButton.ZIndex = 101

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "NotificationText"
    textLabel.Size = UDim2.new(0.9, 0, 1, 0)
    textLabel.Position = UDim2.new(0.1, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.new(r/255, g/255, b/255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSans
    textLabel.Parent = frame
    textLabel.ZIndex = 101

    if string.find(text, "Meteor:") then
        textLabel.Size = UDim2.new(1, -50, 1, 0)
        textLabel.Position = UDim2.new(0, 50, 0, 0)

        local meteorTP = Instance.new("TextButton")
        meteorTP.Name = "meteorTP"
        meteorTP.Size = UDim2.new(0.06, 0, 0.4, 0)
        meteorTP.Position = UDim2.new(0.09, 0, 0.3, 0)
        meteorTP.BackgroundColor3 = Color3.new(236/255, 103/255, 44/255)
        meteorTP.Text = "Goto"
        meteorTP.TextColor3 = Color3.new(1, 1, 1)
        meteorTP.TextScaled = true
        meteorTP.Font = Enum.Font.SourceSans
        meteorTP.Parent = frame
        meteorTP.ZIndex = 101

        meteorTP.MouseButton1Click:Connect(function()
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(5694, 174, 632))
            notifygui("Teleported to Meteor", 42, 227, 14)
        end)
    end

    closeButton.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)
end

minimizegui = function(minimizeButton)
    local screenGui = minimizeButton.Parent.Parent.Parent

    local mainFrame = screenGui:FindFirstChild("MainFrame")
    local scrollFrame = mainFrame:FindFirstChild("NotificationContainer")
    local topBar = mainFrame:FindFirstChild("TopBar")

    if minimizeButton.Text == "-" then
        minimizeButton.Text = "+"
        mainFrame.Size = UDim2.new(0.25, 0, 0.12, 0)
        scrollFrame.Visible = false
        topBar.Size = UDim2.new(0.95, 0, 0.9, 0)
        topBar.Position = UDim2.new(0.5, 0, 0.05, 0)
    else
        minimizeButton.Text = "-"
        mainFrame.Size = UDim2.new(0.25, 0, 0.6, 0)
        scrollFrame.Visible = true
        topBar.Size = UDim2.new(0.95, 0, 0.18, 0)
        topBar.Position = UDim2.new(0.5, 0, 0.01, 0)
    end
end

askautohop = function()
    local frame = createframe()

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.06, 0, 0.4, 0)
    closeButton.Position = UDim2.new(0.015, 0, 0.3, 0)
    closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSans
    closeButton.Parent = frame
    closeButton.ZIndex = 101

    local autohopButton = Instance.new("TextButton")
    autohopButton.Name = "autohopButton"
    autohopButton.Size = UDim2.new(0.5, 0, 0.6, 0)
    autohopButton.Position = UDim2.new(0.25, 0, 0.2, 0)
    autohopButton.BackgroundColor3 = Color3.new(0.5, 0.85, 0.9)
    autohopButton.Text = "Start Autohop"
    autohopButton.TextColor3 = Color3.new(0, 0, 0)
    autohopButton.TextScaled = true
    autohopButton.Font = Enum.Font.SourceSans
    autohopButton.Parent = frame
    autohopButton.ZIndex = 101


    closeButton.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)

    autohopButton.MouseButton1Click:Connect(function()
       notifygui("Starting autohop! DC to stop")
       task.wait(2)
       cache.autohop = true
       writefile("FischServerFinder/cache.json", game:GetService("HttpService"):JSONEncode(cache))
       teleport()
    end)
end

potentialsunkenchest = function()
    local frame = createframe()

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.06, 0, 0.4, 0)
    closeButton.Position = UDim2.new(0.015, 0, 0.3, 0)
    closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSans
    closeButton.Parent = frame
    closeButton.ZIndex = 101

    local tpButton = Instance.new("TextButton")
    tpButton.Name = "tpButton"
    tpButton.Size = UDim2.new(0.25, 0, 0.6, 0)
    tpButton.Position = UDim2.new(0.3, 0, 0.2, 0)
    tpButton.BackgroundColor3 = Color3.new(0.5, 0.9, 0.65)
    tpButton.Text = "TP"
    tpButton.TextColor3 = Color3.new(1, 1, 1)
    tpButton.TextScaled = true
    tpButton.Font = Enum.Font.SourceSans
    tpButton.Parent = frame
    tpButton.ZIndex = 101

    local rescanButton = Instance.new("TextButton")
    rescanButton.Name = "rescanButton"
    rescanButton.Size = UDim2.new(0.25, 0, 0.6, 0)
    rescanButton.Position = UDim2.new(0.6, 0, 0.2, 0)
    rescanButton.BackgroundColor3 = Color3.new(0.83, 0.5, 0.9)
    rescanButton.Text = "Rescan"
    rescanButton.TextColor3 = Color3.new(1, 1, 1)
    rescanButton.TextScaled = true
    rescanButton.Font = Enum.Font.SourceSans
    rescanButton.Parent = frame
    rescanButton.ZIndex = 101

    closeButton.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)

    tpButton.MouseButton1Click:Connect(function()
        chesttpscancount = 0
        if checkteleporting then return end
        chesttpscan(0.1)
    end)

    rescanButton.MouseButton1Click:Connect(function()
        scanchest()
    end)

    if config.sunkenchestList.autofarm and not chestfound then
        notifygui("Autofarm Sunken Chest!", 255, 210, 0)
        task.wait(3)
        if checkteleporting then return end
        chesttpscan(0.1)
    end
end

local activeChestsFolder = game:GetService("Workspace").ActiveChestsFolder

chesttpscan = function(delay)
    if not issunkenchest() then
        checkteleporting = false
        notifygui("Chest Despawned!")
        return
    end
    checkteleporting = true
    for _, coords in ipairs(data.sunkenchestcoords) do
        tp(coords.x, coords.y - 20, coords.z)
        task.wait(delay)
        if not checkteleporting then
            checkteleporting = false
            break
        end
    end
    if checkteleporting then
        scanchest()
        if chesttpscancount < 3 then
            chesttpscancount = chesttpscancount + 1
            chesttpscan(chesttpscancount / 5)
        else
            notifygui("Failed to find sunken chests!", 199, 29, 10)
            checkteleporting = false
            if config.sunkenchestList.hopafterclaim then
                notifygui("Hop After Claim - Hopping", 247, 94, 229)
                teleport()
            end
        end
    end
end

scanchest = function()
    for _, object in pairs(activeChestsFolder:GetChildren()) do
        checkteleporting = false
        if config.sunkenchestList.alertonload then
            task.spawn(function()
                loadedsunkenchest(object)
            end)
        end
    end
end

loadedsunkenchest = function(object)
    if not chestfound then
        task.spawn(function()
            notifygui("Sunken Chest Found!", 255, 255, 0)
            chestfound = true
            task.wait(600)
            chestfound = false
        end)
    end
    if loadedmsg then return end
    loadedmsg = true
    checkteleporting = false

    local position
    for _, descendant in ipairs(object:GetDescendants()) do
        if descendant:IsA("BasePart") then
            position = descendant.Position
            break
        end
    end

    if not position then return end

    local frame = createframe()

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.06, 0, 0.4, 0)
    closeButton.Position = UDim2.new(0.015, 0, 0.3, 0)
    closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSans
    closeButton.Parent = frame
    closeButton.ZIndex = 101

    local tpButton = Instance.new("TextButton")
    tpButton.Name = "tpButton"
    tpButton.Size = UDim2.new(0.38, 0, 0.6, 0)
    tpButton.Position = UDim2.new(0.15, 0, 0.2, 0)
    tpButton.BackgroundColor3 = Color3.new(0.4, 0.6, 1)
    tpButton.Text = "TP to Chests"
    tpButton.TextColor3 = Color3.new(1, 1, 1)
    tpButton.TextScaled = true
    tpButton.Font = Enum.Font.SourceSans
    tpButton.Parent = frame
    tpButton.ZIndex = 101

    local claimButton = Instance.new("TextButton")
    claimButton.Name = "claimButton"
    claimButton.Size = UDim2.new(0.38, 0, 0.6, 0)
    claimButton.Position = UDim2.new(0.55, 0, 0.2, 0)
    claimButton.BackgroundColor3 = Color3.new(0.2, 1, 0.2)
    claimButton.Text = "Claim Chests"
    claimButton.TextColor3 = Color3.new(1, 1, 1)
    claimButton.TextScaled = true
    claimButton.Font = Enum.Font.SourceSans
    claimButton.Parent = frame
    claimButton.ZIndex = 101

    closeButton.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)

    tpButton.MouseButton1Click:Connect(function()
        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 10, 0))
    end)

    claimButton.MouseButton1Click:Connect(function()
        claimsunkenchest()
    end)

    task.wait(0.5)

    if config.sunkenchestList.autofarm and not autofarmchestclaimed then
        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 10, 0))
        task.wait(2)
        claimsunkenchest()
        autofarmchestclaimed = true
        task.spawn(function()
            task.wait(600)
            autofarmchestclaimed = false
        end)
    end
end

claimsunkenchest = function()
    if not haschildren(activeChestsFolder) then return end
    local chests = activeChestsFolder:FindFirstChild("Pad").Chests
    for _, chest in ipairs(chests:GetChildren()) do
        local root
        if chest.Name == "Mythical" then
            root = chest:FindFirstChild("Chest")
        else
            root = chest:FindFirstChild("RootPart")
        end

        if root then
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(root.Position + Vector3.new(0, 6.6, 0))
            task.wait(0.3)
            local highlight = root:FindFirstChild("Main"):FindFirstChild("Highlight")
            if highlight then
                local prompt = root:FindFirstChild("Main"):FindFirstChild("Prompt")
                prompt:InputHoldBegin()
                task.wait(0.2)
            end
        end
    end

    if config.sunkenchestList.hopafterclaim then
        task.wait(4)
        notifygui("Claimed, autohoppping", 247, 94, 229)
        teleport()
    end
end

issunkenchest = function()
    local hours, minutes = parseuptime()

    local totalMinutes = (hours * 60) + minutes

    local modValue = (totalMinutes - 60 + config.sunkenchestList.bufferbefore) % 70

    if modValue >= 0 and modValue < (10 + config.sunkenchestList.bufferbefore) then
        return true, (modValue - config.sunkenchestList.bufferbefore)
    else
        return false, -1
    end
end


convertEventString = function(events)
    local string = ""
    for _, event in ipairs(events) do
        if event.text == "## Events: " then
            string = string .. event.text .. "\n"
        else
            string = string .. "- " .. event.text .. "\n"
        end
    end
    return string
end

sendwebhook = function()
    local count = #game:GetService("Players"):GetPlayers()
    local serverversion = game:GetService("ReplicatedStorage").world.version.Value
    local placeversion = game.PlaceVersion
    local uptimestr = "**Server Uptime: **" .. formattime(parseuptime())
    local jobId = game.JobId
    local timestamp = os.time()
    local timestampfooter = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    local events = convertEventString(scanWorld())

    local embedData = {
        content = "",
        tts = false,
        embeds = {
            {
                description = "**Players:** " .. count .. " / 15\n**Game Version:** " .. serverversion .. 
                    "\n**Place Version:** " .. placeversion .. "\n".. uptimestr .. "\n\n## Info:\n" .. events,
                fields = {
                    {
                        name = "JobId",
                        value = "```" .. jobId .. "```"
                    },
                    {
                        name = "Code",
                        value = "```game:GetService(\"TeleportService\"):TeleportToPlaceInstance(16732694052, \"" .. 
                            jobId .. "\", game:GetService(\"Players\").LocalPlayer)```"
                    }
                },
                footer = {
                    text = "windows1267"
                },
                timestamp = timestampfooter,
                title = "Server Found <t:" .. timestamp ..":R>",
                color = 53759,
            }
        }
    }

    local jsonData = HttpService:JSONEncode(embedData)
    request({
        Url = config.webhookUrl,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = jsonData
    })
end

haschildren = function(object)
    return #object:GetChildren() > 0;
end

scanWorld = function()
    local events = {}
    local weather = game:GetService("ReplicatedStorage").world.weather
    local cycle = game:GetService("ReplicatedStorage").world.cycle
    local season = game:GetService("ReplicatedStorage").world.season
    local event = game:GetService("ReplicatedStorage").world.event
    local luckServer = game:GetService("ReplicatedStorage").world.luck_Server
    local luckServerside = game:GetService("ReplicatedStorage").world.luck_ServerSide
    local luck = luckServer.Value + luckServerside.Value
    if luckServer.Value == 1 then
        luck = luck - 1
    end
    local meteor = game:GetService("Workspace"):WaitForChild("MeteorItems")
    local zones = game:GetService("Workspace"):WaitForChild("zones"):WaitForChild("fishing")

    for name, enabled in pairs(config.weatherList) do
        if name == weather.Value then
            table.insert(events, {text = "Weather: " .. name, r = 255, g = 255, b = 255, enabled = enabled})
        end
        if weather.Value == "Aurora_Borealis" and name == "Aurora Borealis" then
            table.insert(events, {text = "Weather: Aurora Borealis", r = 160, g = 252, b = 180, enabled = enabled})
        end
    end

    for name, enabled in pairs(config.cycleList) do
        if name == cycle.Value then
            table.insert(events, {text = "Cycle: " .. name, r = 255, g = 255, b = 255, enabled = enabled})
        end
    end

    for name, enabled in pairs(config.seasonList) do
        if name == season.Value then
            table.insert(events, {text = "Season: " .. name, r = 255, g = 255, b = 255, enabled = enabled})
        end
    end

    table.insert(events, {text = "## Events: ", r = 255, g = 255, b = 255, enabled = false})

    for name, enabled in pairs(config.eventList) do
        if name == event.Value then
            table.insert(events, {text = name, r = 255, g = 255, b = 255, enabled = enabled})
        end
    end

    if luck > 1 then
        local send = luck >= config.luckList.min and config.luckList.enabled
        table.insert(events, {text = "Luck: x" .. luck, r = 88, g = 162, b = 91, enabled = send})
    end

    local meteoritems = meteor:GetChildren()
    if #meteoritems > 0 then
        local item = meteoritems[1]
        for name, enabled in pairs(config.meteorList) do
            if name == item.Name then
                table.insert(events, {text = "Meteor: " .. name, r = 236, g = 103, b = 44, enabled = enabled})
            end
        end
    end

    for name, enabled in pairs(config.zoneList) do
        if zones:FindFirstChild(name) then
            local count = 0
            for _, zone in pairs(zones:GetChildren()) do
                if zone.Name == name then
                    count = count + 1
                end
            end

            if count > 0 then
                local str = name
                if count > 1 then
                    str = tostring(count) .. "X " .. str
                end
                local r, g, b = 236, 104, 142
                if string.find(str, "Megalodon") then
                    r, g, b = 234, 51, 35
                end
                table.insert(events, {text = str, r = r, g = g, b = b, enabled = enabled})
            end
        end
    end
    local sc, time = issunkenchest()
    if sc then
        autofarmchestpotential = true
        table.insert(events, {text = "Sunken Chest " .. time .. " min", r = 255, g = 255, b = 102, enabled = config.sunkenchestList.enabled})
    end

    return events
end

notify = function(events)
    local count = 0
    for _, event in ipairs(events) do
        if event.enabled == true then
            notifygui(event.text, event.r, event.g, event.b)
            count = count + 1
            if string.find(event.text, "Sunken Chest") then
                potentialsunkenchest()
            end
        end
    end
    if count > 0 then desiredserver = true end
    if not desiredserver then
        notifygui("Nothing", 255, 153, 0)
        if cacheFile.autohop and config.autohop then
            notifygui("Autohopping", 247, 94, 229)
            teleport()
        end
    end
end

scan = function()
    if config.infoList.autouptime then
        notifygui("Uptime: " .. formattime(parseuptime()), 0, 81, 255)
    end

    if config.infoList.autoversion then
        notifygui("Version: " .. game:GetService("ReplicatedStorage").world.version.Value, 18, 180, 201)
    end

    if config.infoList.autoplaceversion then
        notifygui("PlaceVersion: " .. game.PlaceVersion, 224, 64, 245)
    end

    desiredserver = false
    local hour, minute = parseuptime()
    local time = hour * 60 + minute
    local before = config.uptimeList.beforeTime.enabled and time < (config.uptimeList.beforeTime.hour * 60 + config.uptimeList.beforeTime.minute)
    local after = config.uptimeList.afterTime.enabled and time > (config.uptimeList.afterTime.hour * 60 + config.uptimeList.afterTime.minute)

    if before and after then
        desiredserver = true
        notifygui("Before/after: " .. formattime(parseuptime()), 46, 232, 21)
    elseif before and config.uptimeList.orLogic then
        desiredserver = true
        notifygui("Before: " .. formattime(parseuptime()), 52, 168, 255)
    elseif after and config.uptimeList.orLogic then
        desiredserver = true
        notifygui("After: " .. formattime(parseuptime()), 193, 48, 255)
    end

    local serverversion = game:GetService("ReplicatedStorage").world.version.Value
    if config.versionList.enabled and string.match(config.versionList.version, serverversion) then
        desiredserver = true
        notifygui("Version: " .. serverversion, 151, 36, 227)
    end

    if config.placeVersionList.enabled and config.placeVersionList.version == game.PlaceVersion then
        desiredserver = true
        notifygui("Place Version: " .. game.PlaceVersion, 151, 36, 227)
    end

    local events = scanWorld()
    notify(events)
end

activeChestsFolder.ChildAdded:Connect(function(object)
    if config.sunkenchestList.alertonload then
        checkteleporting = false
        notifygui("Sunken Chest Loaded!", 255, 255, 0)
        task.spawn(function()
            loadedsunkenchest(object)
        end)
    end
end)

--task.wait(2)

notifygui("FischServerFinder by Penguin - " .. scriptvers, 0, 247, 255)

loadConfig()

if isfile("FischServerFinder/cache.json") then
    cacheFile = game:GetService("HttpService"):JSONDecode(readfile("FischServerFinder/cache.json"))
else
    cacheFile = {
        autohop = config.autohop,
    }
end

if config.autowebhook then
    sendwebhook()
end

if config.autoscan then
    scan()
end

print("[FSF] Loaded!")

if writefile and not cache.autohop then
    writefile("FischServerFinder/cache.json", game:GetService("HttpService"):JSONEncode(cache))
    if config.autohop then
        askautohop()
    end
end

if cacheFile.autohop and config.autohop and config.sunkenchestList.autofarm and config.sunkenchestList.forcehop and not autofarmchestpotential and not scheduledhop then
    notifygui("Force hopping", 247, 94, 229)
    teleport()
end

task.wait(20)
if loading then 
    loading.loading.Visible = true
end
