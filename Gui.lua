local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local VIM               = game:GetService("VirtualInputManager")
local HttpService       = game:GetService("HttpService")

local player    = Players.LocalPlayer
local PlayerGui = player.PlayerGui
local camera    = workspace.CurrentCamera

local CONFIG_FILE = "FishSell_Config.json"

local CFG = {
    Enabled        = true,
    AutoSell       = false,
    AutoTeleport   = false,
    SelectedIsland = "",
    SellInterval   = 3.0,
    IdleClickDelay = 2.0,   
    EarlyHit       = 0.0,   
    CastDelay      = 0.15,  
    LockLine       = true,  
    QTEOpenDelay   = 0.4,   
    Debug          = false,
}

-- ══════════ THÊM ĐẢO / TỌA ĐỘ TẠI ĐÂY ══════════
local ISLANDS = {
    {Name = "Bay Island", Pos = Vector3.new(47, 27, 131)},
    {Name = "Caldera Cay", Pos = Vector3.new(1795, 26, -1334)},
    {Name = "Cresent Shore", Pos = Vector3.new(-1337, 29, 1593)},
    {Name = "Sea Stack", Pos = Vector3.new(-1337, 29, 1593)},
    {Name = "Cave Sea Stack", Pos = Vector3.new(1033, -52, 1397)},
}
-- ═══════════════════════════════════════════════

if CFG.SelectedIsland == "" and #ISLANDS > 0 then
    CFG.SelectedIsland = ISLANDS[1].Name
end

-- ══════════ LOAD & SAVE CONFIG ══════════
if isfile and readfile and isfile(CONFIG_FILE) then
    pcall(function()
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(data) == "table" then
            for k, v in pairs(data) do
                if CFG[k] ~= nil then CFG[k] = v end
            end
        end
    end)
end

local function saveConfig()
    if writefile then
        pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(CFG)) end)
    end
end

-- ══════════ RANDOM SAFE ZONE LOGIC ══════════
local function getRandomSafeZone()
    local vp = camera.ViewportSize
    local minX = math.floor(vp.X * 0.3)
    local maxX = math.floor(vp.X * 0.7)
    local minY = math.floor(vp.Y * 0.15)
    local maxY = math.floor(vp.Y * 0.35)
    return Vector2.new(math.random(minX, maxX), math.random(minY, maxY))
end

-- ══════════ ANTI-AFK ══════════
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local ByteNetQuery      = ReplicatedStorage:WaitForChild("ByteNetQuery", 10)
local ByteNetUnreliable = ReplicatedStorage:WaitForChild("ByteNetUnreliable", 10)
local ByteNetReliable   = ReplicatedStorage:WaitForChild("ByteNetReliable", 10)
local SELL_BUF = buffer.fromstring("2")
local LOCK_BUF = buffer.fromstring("\003\001\000") -- Buffer để Khóa đồ

-- ══════════ TELEPORT THREAD ══════════
task.spawn(function()
    while true do
        task.wait(1)
        if CFG.AutoTeleport and CFG.SelectedIsland ~= "" then
            local targetPos = nil
            for _, v in ipairs(ISLANDS) do
                if v.Name == CFG.SelectedIsland then targetPos = v.Pos; break end
            end
            if targetPos then
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - targetPos).Magnitude > 15 then
                    hrp.CFrame = CFrame.new(targetPos)
                end
            end
        end
    end
end)

-- ══════════ KILL ANIMATION ══════════
local function killQTEAnimations()
    pcall(function()
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end)
end

-- ══════════ CAST (RANDOM CLICK) ══════════
local isCasting = false  
local function tryOpenFishing()
    if isCasting then return end
    isCasting = true
    pcall(function()
        local char = player.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
        local safePos = getRandomSafeZone()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(safePos, camera.CFrame)
        task.wait(0.1)
        VirtualUser:Button1Up(safePos, camera.CFrame)
    end)
    task.wait(0.2)  
    isCasting = false
end

-- ══════════ LOCK LINE GLOBAL ══════════
local lineHooked = false
local lockedBar  = nil  
local currentLineObj = nil

local function hookLineRotation()
    if lineHooked then return end
    local dummy = Instance.new("Folder")
    local ok, mt = pcall(getrawmetatable, dummy)
    dummy:Destroy()
    if not ok or not mt then return end

    pcall(setreadonly, mt, false)
    local origNewindex = rawget(mt, "__newindex")

    mt.__newindex = newcclosure(function(self, key, value)
        if CFG.LockLine and key == "Rotation" and currentLineObj and self == currentLineObj then
            if lockedBar then
                local ok2, barRot = pcall(function() return lockedBar.Rotation end)
                if ok2 then value = barRot end
            end
        end
        if origNewindex then return origNewindex(self, key, value) else rawset(self, key, value) end
    end)

    pcall(setreadonly, mt, true)
    lineHooked = true
end
task.spawn(hookLineRotation)

-- ══════════ FIRE HIT ══════════
local qteClickFunc  = nil
local lastHitBuffer = nil

local function findQTEClickFunction()
    local qte  = PlayerGui:FindFirstChild("QTE")
    local main = qte and qte:FindFirstChild("Main")
    if not main then return nil end
    for _, c in ipairs(main:GetDescendants()) do
        if c:IsA("TextButton") or c:IsA("ImageButton") then return c end
    end
end

local function fireQTEHit()
    if lastHitBuffer and ByteNetUnreliable then
        local ok = false
        pcall(function() ByteNetUnreliable:FireServer(lastHitBuffer); ok = true end)
        if ok then return end
    end
    if not qteClickFunc then qteClickFunc = findQTEClickFunction() end
    if qteClickFunc and getconnections then
        local fired = false
        pcall(function()
            for _, c in pairs(getconnections(qteClickFunc.MouseButton1Click)) do c:Fire(); fired = true end
            for _, c in pairs(getconnections(qteClickFunc.Activated))        do c:Fire(); fired = true end
        end)
        if fired then return end
    end
    local safePos = getRandomSafeZone()
    local center = qteClickFunc and (qteClickFunc.AbsolutePosition + qteClickFunc.AbsoluteSize / 2) or safePos
    pcall(function()
        VIM:SendMouseButtonEvent(center.X, center.Y, 0, true,  game, 0)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
    end)
end

if hookfunction and ByteNetUnreliable then
    local orig
    orig = hookfunction(ByteNetUnreliable.FireServer, newcclosure(function(self, ...)
        if self == ByteNetUnreliable then
            local a = {...}
            if a[1] and typeof(a[1]) == "buffer" then
                local qte  = PlayerGui:FindFirstChild("QTE")
                local main = qte and qte:FindFirstChild("Main")
                if main and main.Visible then lastHitBuffer = a[1] end
            end
        end
        return orig(self, ...)
    end))
end

-- ══════════ ANGLE ══════════
local function normAngle(a) return a % 360 end
local function angleDiff(a, b)
    local d = math.abs(normAngle(a) - normAngle(b))
    return d > 180 and 360 - d or d
end

local QTE, MainFrame, LineObj, BarsFolder
local function initRefs()
    QTE        = PlayerGui:FindFirstChild("QTE")
    if not QTE then return false end
    MainFrame  = QTE:FindFirstChild("Main")
    if not MainFrame then return false end
    LineObj    = MainFrame:FindFirstChild("Line")
    BarsFolder = MainFrame:FindFirstChild("Bars")
    return LineObj ~= nil and BarsFolder ~= nil
end

-- ══════════ MAIN LOOP ══════════
local lastIdleOpen  = 0
local lastHitFire   = 0
local wasQTEActive  = false  
local justClosed    = false  
local qteOpenedTime = 0     

RunService.Heartbeat:Connect(function()
    if not CFG.Enabled then return end
    local now = tick()
    
    -- ── AUTO EQUIP CHỈ LẤY CẦN CÂU ──
    pcall(function()
        local char = player.Character
        if char and not char:FindFirstChildOfClass("Tool") then
            local bp = player:FindFirstChild("Backpack")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if bp and hum then
                local targetTool = nil
                for _, tool in ipairs(bp:GetChildren()) do
                    if tool:IsA("Tool") then
                        local n = string.lower(tool.Name)
                        -- Lọc bỏ các tool rác
                        if not n:match("equipment") and not n:match("archive") then
                            targetTool = tool
                            break
                        end
                    end
                end
                if targetTool then hum:EquipTool(targetTool) end
            end
        end
    end)
    -- ────────────────────────────────

    local qteActive = false
    local qteGui = PlayerGui:FindFirstChild("QTE")
    if qteGui and qteGui.Enabled then
        local main = qteGui:FindFirstChild("Main")
        if main and main.Visible then qteActive = true end
    end

    if qteActive then
        killQTEAnimations()
    end

    if not wasQTEActive and qteActive then qteOpenedTime = now end

    if wasQTEActive and not qteActive then
        lockedBar  = nil
        justClosed = true
        task.spawn(function()
            task.wait(CFG.CastDelay)
            if CFG.Enabled and not qteActive then tryOpenFishing(); lastIdleOpen = tick() end
            justClosed = false
        end)
    end
    wasQTEActive = qteActive

    if not qteActive and not justClosed then
        if now - lastIdleOpen >= math.max(2.0, CFG.IdleClickDelay) then tryOpenFishing(); lastIdleOpen = now end
        return
    end

    if not qteActive then return end
    if not LineObj or not LineObj.Parent or not BarsFolder or not BarsFolder.Parent then initRefs() end
    
    currentLineObj = LineObj
    if not LineObj or not BarsFolder then return end

    if CFG.LockLine then
        local targetBar = nil
        for _, bar in ipairs(BarsFolder:GetChildren()) do
            if (bar:IsA("ImageLabel") or bar:IsA("Frame")) then
                local ok, vis = pcall(function() return bar.Visible end)
                if ok and vis then targetBar = bar; break end
            end
        end
        lockedBar = targetBar
        if lockedBar then pcall(function() LineObj.Rotation = lockedBar.Rotation end) end
    end

    local lineRot = 0
    if not pcall(function() lineRot = LineObj.Rotation end) then return end
    lineRot = normAngle(lineRot + CFG.EarlyHit)

    local bars = BarsFolder:GetChildren()
    for i = 1, #bars do
        local bar = bars[i]
        if bar:IsA("ImageLabel") or bar:IsA("Frame") then
            local visible = false
            pcall(function() visible = bar.Visible end)
            if visible then
                local barRot = 0
                pcall(function() barRot = bar.Rotation end)
                local arcDeg = 15
                local n = bar.Name:match("_(%d+)$")
                if n then arcDeg = tonumber(n) or 15 end

                if angleDiff(lineRot, normAngle(barRot)) <= arcDeg / 2 then
                    if now - qteOpenedTime >= CFG.QTEOpenDelay then
                        if now - lastHitFire >= 0.05 then
                            lastHitFire = now 
                            task.spawn(fireQTEHit)
                        end
                    end
                end
            end
        end
    end
end)

-- ══════════ GUI ══════════
pcall(function() if PlayerGui:FindFirstChild("_MacroGUI") then PlayerGui:FindFirstChild("_MacroGUI"):Destroy() end end)

local sg = Instance.new("ScreenGui"); sg.Name = "_MacroGUI"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true; sg.Parent = PlayerGui
local panel = Instance.new("Frame"); panel.Size = UDim2.new(0, 200, 0, 275); panel.Position = UDim2.new(0, 12, 0.5, -137); panel.BackgroundColor3 = Color3.fromRGB(14,14,18); panel.BorderSizePixel = 0; panel.Parent = sg; Instance.new("UICorner", panel).CornerRadius = UDim.new(0,10)
local topBar = Instance.new("Frame"); topBar.Size = UDim2.new(1,0,0,26); topBar.BackgroundColor3 = Color3.fromRGB(26,26,34); topBar.BorderSizePixel = 0; topBar.Parent = panel; Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,10)
local titleLbl = Instance.new("TextLabel"); titleLbl.Size = UDim2.new(1,-10,1,0); titleLbl.Position = UDim2.new(0,10,0,0); titleLbl.BackgroundTransparency = 1; titleLbl.Text = "🎣 Fish + Lock SunShard v7.0"
titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextSize = 11; titleLbl.TextColor3 = Color3.fromRGB(200,200,225); titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.Parent = topBar

local toggleBtn = Instance.new("TextButton"); toggleBtn.Size = UDim2.new(1,-16,0,30); toggleBtn.Position = UDim2.new(0,8,0,30); toggleBtn.BackgroundColor3 = Color3.fromRGB(35,175,95); toggleBtn.BorderSizePixel = 0; toggleBtn.Font = Enum.Font.GothamBold; toggleBtn.TextSize = 12; toggleBtn.TextColor3 = Color3.new(1,1,1); toggleBtn.Text = "AUTO FISH: ON"; toggleBtn.Parent = panel; Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,7)
local sellBtn = Instance.new("TextButton"); sellBtn.Size = UDim2.new(1,-16,0,30); sellBtn.Position = UDim2.new(0,8,0,64); sellBtn.BackgroundColor3 = Color3.fromRGB(175,45,45); sellBtn.BorderSizePixel = 0; sellBtn.Font = Enum.Font.GothamBold; sellBtn.TextSize = 12; sellBtn.TextColor3 = Color3.new(1,1,1); sellBtn.Text = "AUTO SELL: OFF"; sellBtn.Parent = panel; Instance.new("UICorner", sellBtn).CornerRadius = UDim.new(0,7)
local teleBtn = Instance.new("TextButton"); teleBtn.Size = UDim2.new(1,-16,0,30); teleBtn.Position = UDim2.new(0,8,0,98); teleBtn.BackgroundColor3 = Color3.fromRGB(175,45,45); teleBtn.BorderSizePixel = 0; teleBtn.Font = Enum.Font.GothamBold; teleBtn.TextSize = 12; teleBtn.TextColor3 = Color3.new(1,1,1); teleBtn.Text = "AUTO TELEPORT: OFF"; teleBtn.Parent = panel; Instance.new("UICorner", teleBtn).CornerRadius = UDim.new(0,7)

-- Dropdown
local dropBtn = Instance.new("TextButton"); dropBtn.Size = UDim2.new(1,-16,0,24); dropBtn.Position = UDim2.new(0,8,0,132); dropBtn.BackgroundColor3 = Color3.fromRGB(40,40,55); dropBtn.BorderSizePixel = 0; dropBtn.Font = Enum.Font.GothamBold; dropBtn.TextSize = 11; dropBtn.TextColor3 = Color3.new(1,1,1); dropBtn.Text = "📍 " .. (CFG.SelectedIsland ~= "" and CFG.SelectedIsland or "Chọn Đảo..."); dropBtn.Parent = panel; Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0,6)
local dropScroll = Instance.new("ScrollingFrame"); dropScroll.Size = UDim2.new(1,-16,0,100); dropScroll.Position = UDim2.new(0,8,0,158); dropScroll.BackgroundColor3 = Color3.fromRGB(30,30,40); dropScroll.BorderSizePixel = 0; dropScroll.Visible = false; dropScroll.ZIndex = 10; dropScroll.ScrollBarThickness = 4; dropScroll.Parent = panel; Instance.new("UICorner", dropScroll).CornerRadius = UDim.new(0,6)
local dropLayout = Instance.new("UIListLayout"); dropLayout.Parent = dropScroll; dropLayout.Padding = UDim.new(0,2)

for _, isl in ipairs(ISLANDS) do
    local b = Instance.new("TextButton"); b.Size = UDim2.new(1,0,0,24); b.BackgroundColor3 = Color3.fromRGB(50,50,70); b.BorderSizePixel = 0; b.Font = Enum.Font.Gotham; b.TextSize = 11; b.TextColor3 = Color3.new(1,1,1); b.Text = isl.Name; b.ZIndex = 11; b.Parent = dropScroll
    b.MouseButton1Click:Connect(function()
        CFG.SelectedIsland = isl.Name; dropBtn.Text = "📍 " .. isl.Name; dropScroll.Visible = false
        saveConfig()
    end)
end
dropScroll.CanvasSize = UDim2.new(0,0,0, #ISLANDS * 26)
dropBtn.MouseButton1Click:Connect(function() dropScroll.Visible = not dropScroll.Visible end)

local bufLbl = Instance.new("TextLabel"); bufLbl.Size = UDim2.new(1,-16,0,13); bufLbl.Position = UDim2.new(0,8,0,162); bufLbl.BackgroundTransparency = 1; bufLbl.Font = Enum.Font.Gotham; bufLbl.TextSize = 10; bufLbl.TextColor3 = Color3.fromRGB(200,140,50); bufLbl.Text = "Click 1 lần để capture buffer"; bufLbl.TextXAlignment = Enum.TextXAlignment.Left; bufLbl.Parent = panel
local statusLbl = Instance.new("TextLabel"); statusLbl.Size = UDim2.new(1,-16,0,13); statusLbl.Position = UDim2.new(0,8,0,177); statusLbl.BackgroundTransparency = 1; statusLbl.Font = Enum.Font.Gotham; statusLbl.TextSize = 10; statusLbl.TextColor3 = Color3.fromRGB(100,100,130); statusLbl.Text = "○ Đợi câu..."; statusLbl.TextXAlignment = Enum.TextXAlignment.Left; statusLbl.Parent = panel
local castLbl = Instance.new("TextLabel"); castLbl.Size = UDim2.new(1,-16,0,13); castLbl.Position = UDim2.new(0,8,0,192); castLbl.BackgroundTransparency = 1; castLbl.Font = Enum.Font.Gotham; castLbl.TextSize = 10; castLbl.TextColor3 = Color3.fromRGB(100,180,255); castLbl.Text = string.format("Cast delay: %.2fs", CFG.CastDelay); castLbl.TextXAlignment = Enum.TextXAlignment.Left; castLbl.Parent = panel
local lockBtn = Instance.new("TextButton"); lockBtn.Size = UDim2.new(1,-16,0,22); lockBtn.Position = UDim2.new(0,8,0,211); lockBtn.BackgroundColor3 = Color3.fromRGB(40,100,175); lockBtn.BorderSizePixel = 0; lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 11; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Text = "🔒 Lock Line: ON"; lockBtn.Parent = panel; Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0,6)
local btnRow = Instance.new("Frame"); btnRow.Size = UDim2.new(1,-16,0,24); btnRow.Position = UDim2.new(0,8,0,240); btnRow.BackgroundTransparency = 1; btnRow.Parent = panel
local function makeBtn(text, xoff) local b = Instance.new("TextButton"); b.Size = UDim2.new(0,88,1,0); b.Position = UDim2.new(0,xoff,0,0); b.BackgroundColor3 = Color3.fromRGB(50,50,70); b.BorderSizePixel = 0; b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.TextColor3 = Color3.new(1,1,1); b.Text = text; b.Parent = btnRow; Instance.new("UICorner", b).CornerRadius = UDim.new(0,6); return b end
local bcM = makeBtn("- Cast", 0); local bcP = makeBtn("+ Cast", 96)

local function updateGUI()
    toggleBtn.BackgroundColor3 = CFG.Enabled and Color3.fromRGB(35,175,95) or Color3.fromRGB(175,45,45)
    toggleBtn.Text = CFG.Enabled and "AUTO FISH: ON" or "AUTO FISH: OFF"
    sellBtn.BackgroundColor3 = CFG.AutoSell and Color3.fromRGB(35,175,95) or Color3.fromRGB(175,45,45)
    sellBtn.Text = CFG.AutoSell and "AUTO SELL: ON" or "AUTO SELL: OFF"
    teleBtn.BackgroundColor3 = CFG.AutoTeleport and Color3.fromRGB(35,175,95) or Color3.fromRGB(175,45,45)
    teleBtn.Text = CFG.AutoTeleport and "AUTO TELEPORT: ON" or "AUTO TELEPORT: OFF"
    lockBtn.BackgroundColor3 = CFG.LockLine and Color3.fromRGB(40,100,175) or Color3.fromRGB(60,60,80)
    lockBtn.Text = CFG.LockLine and "🔒 Lock Line: ON" or "🔒 Lock Line: OFF"
    castLbl.Text = string.format("Cast delay: %.2fs", CFG.CastDelay)
    if CFG.SelectedIsland ~= "" then dropBtn.Text = "📍 " .. CFG.SelectedIsland end
end
updateGUI()

bcM.MouseButton1Click:Connect(function() CFG.CastDelay = math.max(0, CFG.CastDelay - 0.05); castLbl.Text = string.format("Cast delay: %.2fs", CFG.CastDelay); saveConfig() end)
bcP.MouseButton1Click:Connect(function() CFG.CastDelay = math.min(2, CFG.CastDelay + 0.05); castLbl.Text = string.format("Cast delay: %.2fs", CFG.CastDelay); saveConfig() end)

lockBtn.MouseButton1Click:Connect(function() CFG.LockLine = not CFG.LockLine; updateGUI(); saveConfig() end)
toggleBtn.MouseButton1Click:Connect(function() CFG.Enabled = not CFG.Enabled; updateGUI(); saveConfig() end)
sellBtn.MouseButton1Click:Connect(function() CFG.AutoSell = not CFG.AutoSell; updateGUI(); saveConfig() end)
teleBtn.MouseButton1Click:Connect(function() CFG.AutoTeleport = not CFG.AutoTeleport; updateGUI(); saveConfig() end)

RunService.Heartbeat:Connect(function()
    if lastHitBuffer then bufLbl.Text = "✓ Buffer captured!"; bufLbl.TextColor3 = Color3.fromRGB(80,200,120) end
    local qte = PlayerGui:FindFirstChild("QTE")
    local main = qte and qte:FindFirstChild("Main")
    if main then
        local active = false; pcall(function() active = main.Visible end)
        if active then statusLbl.Text = "● QTE đang chạy"; statusLbl.TextColor3 = Color3.fromRGB(80,200,120)
        elseif justClosed then statusLbl.Text = "⚡ Casting..."; statusLbl.TextColor3 = Color3.fromRGB(255,200,50)
        else statusLbl.Text = "○ Đợi câu..."; statusLbl.TextColor3 = Color3.fromRGB(100,100,130) end
    end
end)

local drag, dStart, dPos = false, nil, nil
topBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag=true; dStart=i.Position; dPos=panel.Position end end)
topBar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag=false end end)
UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dStart; panel.Position = UDim2.new(dPos.X.Scale, dPos.X.Offset+d.X, dPos.Y.Scale, dPos.Y.Offset+d.Y) end end)

-- ══════════ AUTO SELL & AUTO LOCK ══════════
local lockedItemsCache = setmetatable({}, {__mode = "k"}) -- Tránh rò rỉ bộ nhớ (memory leak)

task.spawn(function()
    while true do
        if CFG.AutoSell and ByteNetReliable then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                local items = backpack:GetChildren()
                local sellableCount = 0
                local toolsToLock = {}
                
                for _, item in ipairs(items) do
                    if item:IsA("Tool") then
                        local n = string.lower(item.Name)
                        local cleanName = string.gsub(n, "%s+", "")
                        
                        -- Lọc bỏ các tool cố định của game
                        if not n:match("equipment") and not n:match("archive") then
                            -- Nếu là Sun Shard
                            if string.match(cleanName, "sunshard") then
                                -- Khóa những cục chưa được gửi lệnh khóa
                                if not lockedItemsCache[item] then
                                    table.insert(toolsToLock, item)
                                    lockedItemsCache[item] = true
                                end
                            else
                                -- Nếu là cá rác (không phải equipment/archive/sunshard) -> Đếm để bán
                                sellableCount = sellableCount + 1
                            end
                        end
                    end
                end
                
                -- Bắn lệnh Khóa (Lock) lên Server nếu có Sun Shard mới
                if #toolsToLock > 0 then
                    pcall(function()
                        local args = { LOCK_BUF, toolsToLock }
                        ByteNetReliable:FireServer(unpack(args))
                        print("🔒 [Auto Lock] Đã tự động khóa " .. #toolsToLock .. " Sun Shard mới!")
                    end)
                    task.wait(0.5) -- Nghỉ nửa nhịp cho server cập nhật trạng thái khóa xong mới bán rác
                end
                
                -- Nếu rác dồn đủ 30 món -> Bắn lệnh Bán
                if sellableCount >= 30 then
                    pcall(function() 
                        ByteNetReliable:FireServer(SELL_BUF)
                        print("💰 [Auto Sell] Đã thanh lý " .. sellableCount .. " rác!")
                    end)
                end
            end
        end
        task.wait(CFG.SellInterval)
    end
end)
