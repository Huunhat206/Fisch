local CoreGui = game:GetService("CoreGui")
local ContentProvider = game:GetService("ContentProvider")

if CoreGui:FindFirstChild("MyRadioGUI") then
    CoreGui.MyRadioGUI:Destroy()
end

local rawIdList = {
    "1195040760586053", "9043206066", "5232182821", "117409737658405",
    "9046863253", "89105363914372", "87437544236708", "7109752018",
    "105599775370376", "107986037170404", "119354387183704", "7163763387",
    "18202483174", "111174530730534", "137256690956022", "4612384231",
    "137426393727807", "8997512318", "6091973938", "15675032796",
    "8304443672", "3779045779", "929615155", "131845870598154",
    "1655262564", "116399794334864", "5417004822", "87523965330187",
    "140474887945891", "1843026667", "124567288309185", "9048464297",
    "86247184974274", "100001805913571", "9064263922", "129710845038263",
    "100362458464678", "136427339932574", "109090958199961", "10066921516",
    "995908246", "912580678"
}

local validIdList = {}
local selectedID = ""
local isDropdownOpen = false

local soundPlayer = Instance.new("Sound", workspace)
soundPlayer.Name = "RadioSoundPlayer"
soundPlayer.Volume = 1

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyRadioGUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "🎵 Radio Player"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.Text = "Đang khởi tạo..."
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local DropdownBtn = Instance.new("TextButton", MainFrame)
DropdownBtn.Size = UDim2.new(1, -20, 0, 30)
DropdownBtn.Position = UDim2.new(0, 10, 0, 60)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DropdownBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
DropdownBtn.Text = "Đang quét dữ liệu..."
DropdownBtn.Font = Enum.Font.Gotham
DropdownBtn.TextSize = 14

local ScrollList = Instance.new("ScrollingFrame", MainFrame)
ScrollList.Size = UDim2.new(1, -20, 0, 120)
ScrollList.Position = UDim2.new(0, 10, 0, 95)
ScrollList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ScrollList.ScrollBarThickness = 5
ScrollList.Visible = false
ScrollList.ZIndex = 5

local UIListLayout = Instance.new("UIListLayout", ScrollList)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local PlayBtn = Instance.new("TextButton", MainFrame)
PlayBtn.Size = UDim2.new(0.45, 0, 0, 35)
PlayBtn.Position = UDim2.new(0, 10, 0, 105)
PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
PlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayBtn.Text = "▶ Phát"
PlayBtn.Font = Enum.Font.GothamBold
PlayBtn.TextSize = 14

local StopBtn = Instance.new("TextButton", MainFrame)
StopBtn.Size = UDim2.new(0.45, 0, 0, 35)
StopBtn.Position = UDim2.new(0.55, -10, 0, 105)
StopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Text = "⏹ Dừng"
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 14

DropdownBtn.MouseButton1Click:Connect(function()
    if #validIdList > 0 then
        isDropdownOpen = not isDropdownOpen
        ScrollList.Visible = isDropdownOpen
    end
end)

PlayBtn.MouseButton1Click:Connect(function()
    if selectedID ~= "" then
        soundPlayer:Stop()
        soundPlayer.SoundId = "rbxassetid://" .. selectedID
        soundPlayer:Play()
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        StatusLabel.Text = "Trạng thái: Đang phát 🟢"
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    soundPlayer:Stop()
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.Text = "Trạng thái: Đã dừng."
end)

task.spawn(function()
    for i, id in ipairs(rawIdList) do
        StatusLabel.Text = "Đang quét ID: " .. i .. "/" .. #rawIdList
        
        local tempSound = Instance.new("Sound")
        tempSound.SoundId = "rbxassetid://" .. id
        
        pcall(function()
            ContentProvider:PreloadAsync({tempSound})
        end)
        
        task.wait(0.05)
        
        if tempSound.TimeLength > 0 then
            table.insert(validIdList, id)
            
            local ItemBtn = Instance.new("TextButton", ScrollList)
            ItemBtn.Size = UDim2.new(1, 0, 0, 25)
            ItemBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            ItemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ItemBtn.Text = id
            ItemBtn.Font = Enum.Font.Gotham
            ItemBtn.TextSize = 12
            ItemBtn.ZIndex = 6
            
            ItemBtn.MouseButton1Click:Connect(function()
                selectedID = id
                DropdownBtn.Text = "Chọn ID: " .. selectedID
                ScrollList.Visible = false
                isDropdownOpen = false
            end)
        end
        tempSound:Destroy()
    end
    
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, #validIdList * 25)
    
    if #validIdList > 0 then
        selectedID = validIdList[1]
        DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownBtn.Text = "Chọn ID: " .. selectedID
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        StatusLabel.Text = "Hoàn tất! Tìm thấy " .. #validIdList .. " ID sống."
    else
        DropdownBtn.Text = "Menu trống"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        StatusLabel.Text = "Lỗi: Không có ID nào sống 🔴"
    end
end)
