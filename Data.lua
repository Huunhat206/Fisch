local on = true
----------------

if not game:IsLoaded() then game.Loaded:Wait() end

local givequest, completequest, getfish, getitem, equipfish, findfishreq, toggleautoquest

local taskCoroutine
local isRunning = false

local gui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("QuestGui")
if gui then
    gui:Destroy()
    isRunning = false
    taskCoroutine = nil
end

if not on then return end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuestGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "DraggableFrame"
frame.Size = UDim2.new(0.15, 0, 0.3, 0)
frame.Position = UDim2.new(0.435, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(0.95, 0, 0.2, 0)
titleLabel.Position = UDim2.new(0.5, 0, 0, 0)
titleLabel.Text = "Welcome to AnglerQuest!"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSans
titleLabel.TextScaled = true
titleLabel.BackgroundTransparency = 1
titleLabel.AnchorPoint = Vector2.new(0.5, 0)
titleLabel.Parent = frame

local button1 = Instance.new("TextButton")
button1.Name = "QuestButton"
button1.Size = UDim2.new(0.95, 0, 0.18, 0)
button1.Position = UDim2.new(0.5, 0, 0.2, 0)
button1.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button1.Text = "Depths Angler Quest"
button1.TextColor3 = Color3.fromRGB(255, 255, 255)
button1.Font = Enum.Font.SourceSans
button1.TextSize = 24
button1.AnchorPoint = Vector2.new(0.5, 0)
button1.Parent = frame

button1.MouseButton1Click:Connect(function()
    titleLabel.Text = "Quest Given!"
    givequest()
end)

local button2 = Instance.new("TextButton")
button2.Name = "CompleteQuestButton"
button2.Size = UDim2.new(0.95, 0, 0.18, 0)
button2.Position = UDim2.new(0.5, 0, 0.39, 0)
button2.BackgroundColor3 = Color3.fromRGB(200, 200, 100)
button2.Text = "Complete Quest"
button2.TextColor3 = Color3.fromRGB(255, 255, 255)
button2.Font = Enum.Font.SourceSans
button2.TextSize = 24
button2.AnchorPoint = Vector2.new(0.5, 0)
button2.Parent = frame

button2.MouseButton1Click:Connect(function()
    titleLabel.Text = "Attempted Complete Quest!"
    completequest()
end)

local button3 = Instance.new("TextButton")
button3.Name = "AutoQuestButton"
button3.Size = UDim2.new(0.95, 0, 0.19, 0)
button3.Position = UDim2.new(0.5, 0, 0.58, 0)
button3.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
button3.Text = "Auto Quest"
button3.TextColor3 = Color3.fromRGB(255, 255, 255)
button3.Font = Enum.Font.SourceSans
button3.TextSize = 24
button3.AnchorPoint = Vector2.new(0.5, 0)
button3.Parent = frame

button3.MouseButton1Click:Connect(function()
    toggleautoquest()
end)

local button4 = Instance.new("TextButton")
button4.Name = "TPButton"
button4.Size = UDim2.new(0.95, 0, 0.19, 0)
button4.Position = UDim2.new(0.5, 0, 0.77, 0)
button4.BackgroundColor3 = Color3.fromRGB(69, 252, 255)
button4.Text = "TP To Angler"
button4.TextColor3 = Color3.fromRGB(255, 255, 255)
button4.Font = Enum.Font.SourceSans
button4.TextSize = 24
button4.AnchorPoint = Vector2.new(0.5, 0)
button4.Parent = frame

button4.MouseButton1Click:Connect(function()
    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(981, -703, 1232))
end)

givequest = function()
    local angler = game:GetService("Workspace"):WaitForChild("world"):WaitForChild("npcs"):FindFirstChild("The Depths Angler")
    if angler then
       angler.angler.giveQuest:InvokeServer()
    else
       titleLabel.Text = "Angler NPC not found!"
    end
end

completequest = function()
    local angler = game:GetService("Workspace"):WaitForChild("world"):WaitForChild("npcs"):FindFirstChild("The Depths Angler")
    if angler then
        angler.angler.questCompleted:InvokeServer()
    else
        titleLabel.Text = "Angler NPC not found!"
    end
end

getfish = function(fishname)
    local plrname = game:GetService("Players").LocalPlayer.Name
    local inventory = game:GetService("ReplicatedStorage").playerstats:WaitForChild(plrname).Inventory:GetChildren()

    for _, item in ipairs(inventory) do
        local itemname = item.Name
        if string.find(string.gsub(itemname, "-", ""), string.gsub(fishname, "-", "")) then
            local favorited = item:FindFirstChild("Favourited")
            if not favorited or favorited.Value == false then
                return itemname
            end
        end
    end
    print("None found in inventory")
    return nil
end

getitem = function(fishname)
    local id = getfish(fishname)
    if id then
        local backpack = game:GetService("Players").LocalPlayer.Backpack:GetChildren()
        for _, item in ipairs(backpack) do
            if item.Name == fishname and item:FindFirstChild("link") then
                local linkid = tostring(item.link.Value)
                if string.match(string.gsub(linkid, "-", ""), string.gsub(id, "-", "")) then
                    return item
                end
            end
        end
    end
    print("None found in backpack")
    return nil
end

equipfish = function(fishname)
    local item = getitem(fishname)
    if item then
        game:GetService("ReplicatedStorage"):WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RE/Backpack/Equip"):FireServer(item)
        completequest()
        game:GetService("ReplicatedStorage"):WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RE/Backpack/Equip"):FireServer(item)
        titleLabel.Text = "Completed " .. fishname
    else
        if isRunning then
            toggleautoquest()
        end
        print("Could not find ".. fishname)
        titleLabel.Text = "Could not find " .. fishname
        print()
    end
end

local quests = game:GetService("Players").LocalPlayer.PlayerGui.hud.deviceinset.quests

findfishreq = function()
    for _, quest in ipairs(quests:GetChildren()) do
        if quest:FindFirstChild("title") and quest:FindFirstChild("title").Text == "Angler Quest" then
            return tostring(quest.line1.Text)
        end
    end
    return nil
end

toggleautoquest = function()
    if isRunning then
        button3.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        
        isRunning = false
        taskCoroutine = nil
    else
        button3.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        
        isRunning = true

        if not taskCoroutine then
            taskCoroutine = coroutine.create(function()
                while task.wait(1) do
                    local fish = findfishreq()
                    if fish then
                        equipfish(fish)
                        givequest()
                        task.wait(1)
                    end
                    givequest()
                    if isRunning == false then coroutine.yield() end
                end
            end)
        end

        coroutine.resume(taskCoroutine)
    end
end
