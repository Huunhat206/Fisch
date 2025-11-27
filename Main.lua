local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gui = Instance.new("ScreenGui")
gui.Name = "ForgeUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 150, 0, 200)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.BorderSizePixel = 0
title.Text = "Forge Panel"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

local buttonsFrame = Instance.new("Frame")
buttonsFrame.Size = UDim2.new(1, -20, 1, -40)
buttonsFrame.Position = UDim2.new(0, 10, 0, 35)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = mainFrame

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 5)
list.FillDirection = Enum.FillDirection.Vertical
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.VerticalAlignment = Enum.VerticalAlignment.Top
buttonsFrame.ChildAdded:Connect(function(child)
    if child:IsA("TextButton") then
        child.Size = UDim2.new(1, 0, 0, 30)
    end
end)
list.Parent = buttonsFrame

local function createButton(text)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = buttonsFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    return btn
end

local dupeButton = createButton("Dupe")
dupeButton.MouseButton1Click:Connect(function()
    local args = {
        "Showcase",
        {}
    }

    ReplicatedStorage
        :WaitForChild("Shared")
        :WaitForChild("Packages")
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("ForgeService")
        :WaitForChild("RF")
        :WaitForChild("ChangeSequence")
        :InvokeServer(unpack(args))
end)

local sellButton = createButton("Sell")
sellButton.MouseButton1Click:Connect(function()
    local args = {
        workspace:WaitForChild("Proximity"):WaitForChild("Marbles")
    }

    ReplicatedStorage
        :WaitForChild("Shared")
        :WaitForChild("Packages")
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("ProximityService")
        :WaitForChild("RF")
        :WaitForChild("Dialogue")
        :InvokeServer(unpack(args))
end)

local slotButton = createButton("Slot")
slotButton.MouseButton1Click:Connect(function()
    ReplicatedStorage
        :WaitForChild("Shared")
        :WaitForChild("Packages")
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("StatusService")
        :WaitForChild("RF")
        :WaitForChild("UpgradeEquipmentBag")
        :InvokeServer()
end)

local iyButton = createButton("IY")
iyButton.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)
