local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local danhSachAnh = {
	["1.png"] = "https://i.ibb.co/wrYL62jF/1.png",
	["2.png"] = "https://i.ibb.co/6Jt1YVqY/2.png",
	["3.png"] = "https://i.ibb.co/xSTWkzxz/3.png",
	["4.png"] = "https://i.ibb.co/JwGgHXv7/4.png"
}

if isfile and writefile and game.HttpGet then
	for fileName, url in pairs(danhSachAnh) do
		if not isfile(fileName) then
			local success, imageData = pcall(function()
				return game:HttpGet(url)
			end)
			if success and imageData then
				writefile(fileName, imageData)
			end
		end
	end
end

local getAsset = getcustomasset or getsynasset

local function safeGetAsset(fileName)
	if not getAsset then return "" end
	local success, result = pcall(function() return getAsset(fileName) end)
	if success and result then return result else return "" end
end

local Bongo_Both  = safeGetAsset("1.png")
local Bongo_Key   = safeGetAsset("2.png")
local Bongo_Mouse = safeGetAsset("3.png")
local Bongo_Idle  = safeGetAsset("4.png")

local guiParent
pcall(function() guiParent = (gethui and gethui()) or game:GetService("CoreGui") end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JustBongoCat"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true 
screenGui.Parent = guiParent or player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 160, 0, 100) 
mainFrame.Position = UDim2.new(1, -170, 1, -110)
mainFrame.BackgroundTransparency = 1
mainFrame.Active = true
mainFrame.Parent = screenGui

local bongoCat = Instance.new("ImageLabel")
bongoCat.Name = "BongoCat"
bongoCat.Size = UDim2.new(1, 0, 1, 0)
bongoCat.Position = UDim2.new(0, 0, 0, 0)
bongoCat.BackgroundTransparency = 1
bongoCat.ScaleType = Enum.ScaleType.Fit
bongoCat.Image = Bongo_Idle
bongoCat.Parent = mainFrame

local pressedInputs = {}
local activeKeyCount = 0
local activeMouseCount = 0

local function updateBongoCat()
	if Bongo_Idle == "" then return end 
	local isKey = activeKeyCount > 0
	local isMouse = activeMouseCount > 0
	
	if isKey and isMouse then bongoCat.Image = Bongo_Both
	elseif isKey then bongoCat.Image = Bongo_Key
	elseif isMouse then bongoCat.Image = Bongo_Mouse
	else bongoCat.Image = Bongo_Idle end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end 
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if not pressedInputs[input.KeyCode] then
			pressedInputs[input.KeyCode] = true
			activeKeyCount += 1
			updateBongoCat()
		end
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
		if not pressedInputs[input.UserInputType] then
			pressedInputs[input.UserInputType] = true
			activeMouseCount += 1
			updateBongoCat()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if pressedInputs[input.KeyCode] then
			pressedInputs[input.KeyCode] = nil
			activeKeyCount -= 1
			updateBongoCat()
		end
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
		if pressedInputs[input.UserInputType] then
			pressedInputs[input.UserInputType] = nil
			activeMouseCount -= 1
			updateBongoCat()
		end
	end
end)

local dragging, dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
		dragInput = input 
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
		dragging = false 
	end
end)
