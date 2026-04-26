local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local VIM               = game:GetService("VirtualInputManager")

local player    = Players.LocalPlayer
local PlayerGui = player.PlayerGui
local camera    = workspace.CurrentCamera

local CFG = {
    Enabled        = true,
    AutoSell       = false,
    SellInterval   = 3.0,
    IdleClickDelay = 2.0,   
    EarlyHit       = 0.0,   -- Không cần bù sớm nữa vì vạch đỏ đã bị khóa chặt
    CastDelay      = 0.15,  
    LockLine       = true,  -- Tính năng khóa vạch đỏ
    Debug          = false,
}

-- ══════════ ANTI-AFK ══════════
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    if CFG.Debug then print("🛡️ [Anti-AFK] fired") end
end)

local ByteNetQuery      = ReplicatedStorage:WaitForChild("ByteNetQuery", 10)
local ByteNetUnreliable = ReplicatedStorage:WaitForChild("ByteNetUnreliable", 10)
local ByteNetReliable   = ReplicatedStorage:WaitForChild("ByteNetReliable", 10)

local SELL_BUF = buffer.fromstring("2")

-- ══════════ CAST (UI BYPASS MODE) ══════════
local isCasting = false  

local function tryOpenFishing()
    if isCasting then return end
    isCasting = true
    pcall(function()
        local char = player.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
        
        local safeX = camera.ViewportSize.X / 2
        local safeY = 10 
        
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(safeX, safeY), camera.CFrame)
        task.wait(0.1)
        VirtualUser:Button1Up(Vector2.new(safeX, safeY), camera.CFrame)
        
        VIM:SendMouseButtonEvent(safeX, safeY, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(safeX, safeY, 0, false, game, 0)
    end)
    task.wait(0.2) 
    isCasting = false
end

-- ══════════ LOCK LINE (NEW) ══════════
local lineHooked = false
local lockedBar  = nil  

local function getMain()
    local qte = PlayerGui:FindFirstChild("QTE")
    return qte and qte:FindFirstChild("Main")
end

local function getTargetBar()
    local main = getMain()
    if not main then return nil end
    local bars = main:FindFirstChild("Bars")
    if not bars then return nil end
    for _, bar in ipairs(bars:GetChildren()) do
        if (bar:IsA("ImageLabel") or bar:IsA("Frame")) then
            local ok, vis = pcall(function() return bar.Visible end)
            if ok and vis then return bar end
        end
    end
    return nil
end

local function hookLineRotation()
    if lineHooked then return end
    local main = getMain()
    if not main then return end
    local line = main:FindFirstChild("Line")
    if not line then return end

    local ok, mt = pcall(getrawmetatable, line)
    if not ok or not mt then return end

    pcall(setreadonly, mt, false)
    local origNewindex = rawget(mt, "__newindex")

    mt.__newindex = newcclosure(function(self, key, value)
        if self == line and key == "Rotation" and CFG.LockLine then
            local bar = lockedBar or getTargetBar()
            if bar then
                local ok2, barRot = pcall(function() return bar.Rotation end)
                if ok2 then value = barRot end
            end
        end
        if origNewindex then
            return origNewindex(self, key, value)
        else
            rawset(self, key, value)
        end
    end)

    pcall(setreadonly, mt, true)
    lineHooked = true
    print("🔒 [Lock Line] Đã can thiệp thành công vào vạch đỏ!")
end

local function tryHookLine()
    if not lineHooked and CFG.LockLine then
        hookLineRotation()
    end
end

-- ══════════ FIRE HIT ══════════
local qteClickFunc  = nil
local lastHitBuffer = nil

local function findQTEClickFunction()
    local main = getMain()
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
    
    local center = qteClickFunc
        and (qteClickFunc.AbsolutePosition + qteClickFunc.AbsoluteSize / 2)
        or  Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
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
                local main = getMain()
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

-- ══════════ MAIN LOOP ══════════
local lastIdleOpen  = 0
local lastHitFire   = 0
local wasQTEActive  = false  
local justClosed    = false  

RunService.Heartbeat:Connect(function()
    if not CFG.Enabled then return end
    local now = tick()

    local main = getMain()
    local qteActive = (main and main.Visible)

    -- Detect QTE đóng -> Mở mẻ mới
    if wasQTEActive and not qteActive then
        lineHooked = false 
        lockedBar  = nil
        justClosed = true
        task.spawn(function()
            task.wait(CFG.CastDelay)
            if CFG.Enabled and not qteActive then
                tryOpenFishing()
                lastIdleOpen = tick()
            end
            justClosed = false
        end)
    end
    wasQTEActive = qteActive

    if not qteActive and not justClosed then
        local delay = math.max(2.0, CFG.IdleClickDelay)
        if now - lastIdleOpen >= delay then
            tryOpenFishing()
            lastIdleOpen = now
        end
        return
    end

    if not qteActive then return end

    -- Hook Lock Line khi QTE đang mở
    tryHookLine()

    if CFG.LockLine then
        lockedBar = getTargetBar()
        -- Backup Force Rotation
        if lockedBar and main then
            local line = main:FindFirstChild("Line")
            if line then
                local ok, barRot = pcall(function() return lockedBar.Rotation end)
                if ok then pcall(function() line.Rotation = barRot end) end
            end
        end
    end

    local line = main and main:FindFirstChild("Line")
    local bars = main and main:FindFirstChild("Bars")
    if not line or not bars then return end

    local lineRot = 0
    if not pcall(function() lineRot = line.Rotation end) then return end
    lineRot = normAngle(lineRot + CFG.EarlyHit)

    for _, bar in ipairs(bars:GetChildren()) do
        if bar:IsA("ImageLabel") or bar:IsA("Frame") then
            local ok, vis = pcall(function() return bar.Visible end)
            if ok and vis then
                local ok2, barRot = pcall(function() return bar.Rotation end)
                if ok2 then
                    local arcDeg = 15
                    local n = bar.Name:match("_(%d+)$")
                    if n then arcDeg = tonumber(n) or 15 end

                    -- Do Line đã bị lock trùng vị trí Bar nên góc lệch = 0, auto Perfect
                    if angleDiff(lineRot, normAngle(barRot)) <= arcDeg / 2 then
                        if now - lastHitFire >= 0.05 then
                            fireQTEHit()
                            lastHitFire = now
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
local panel = Instance.new("Frame"); panel.Size = UDim2.new(0, 200, 0, 215); panel.Position = UDim2.new(0, 12, 0.5, -107); panel.BackgroundColor3 = Color3.fromRGB(14,14,18); panel.BorderSizePixel = 0; panel.Parent = sg; Instance.new("UICorner", panel).CornerRadius = UDim.new(0,10)
local topBar = Instance.new("Frame"); topBar.Size = UDim2.new(1,0,0,26); topBar.BackgroundColor3 = Color3.fromRGB(26,26,34); topBar.BorderSizePixel = 0; topBar.Parent = panel; Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,10)
local titleLbl = Instance.new("TextLabel"); titleLbl.Size = UDim2.new(1,-10,1,0); titleLbl.Position = UDim2.new(0,10,0,0); titleLbl.BackgroundTransparency = 1; titleLbl.Text = "🎣 Fish & Sell v5.0 Ultimate"; titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextSize = 11; titleLbl.TextColor3 = Color3.fromRGB(200,200,225); titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.Parent = topBar
local toggleBtn = Instance.new("TextButton"); toggleBtn.Size = UDim2.new(1,-16,0,32); toggleBtn.Position = UDim2.new(0,8,0,30); toggleBtn.BackgroundColor3 = Color3.fromRGB(35,175,95); toggleBtn.BorderSizePixel = 0; toggleBtn.Font = Enum.Font.GothamBold; toggleBtn.TextSize = 13; toggleBtn.TextColor3 = Color3.new(1,1,1); toggleBtn.Text = "AUTO FISH: ON"; toggleBtn.Parent = panel; Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,7)
local sellBtn = Instance.new("TextButton"); sellBtn.Size = UDim2.new(1,-16,0,30); sellBtn.Position = UDim2.new(0,8,0,67); sellBtn.BackgroundColor3 = Color3.fromRGB(175,45,45); sellBtn.BorderSizePixel = 0; sellBtn.Font = Enum.Font.GothamBold; sellBtn.TextSize = 12; sellBtn.TextColor3 = Color3.new(1,1,1); sellBtn.Text = "AUTO SELL: OFF"; sellBtn.Parent = panel; Instance.new("UICorner", sellBtn).CornerRadius = UDim.new(0,7)
local bufLbl = Instance.new("TextLabel"); bufLbl.Size = UDim2.new(1,-16,0,13); bufLbl.Position = UDim2.new(0,8,0,103); bufLbl.BackgroundTransparency = 1; bufLbl.Font = Enum.Font.Gotham; bufLbl.TextSize = 10; bufLbl.TextColor3 = Color3.fromRGB(200,140,50); bufLbl.Text = "Click 1 lần để capture buffer"; bufLbl.TextXAlignment = Enum.TextXAlignment.Left; bufLbl.Parent = panel
local statusLbl = Instance.new("TextLabel"); statusLbl.Size = UDim2.new(1,-16,0,13); statusLbl.Position = UDim2.new(0,8,0,118); statusLbl.BackgroundTransparency = 1; statusLbl.Font = Enum.Font.Gotham; statusLbl.TextSize = 10; statusLbl.TextColor3 = Color3.fromRGB(100,100,130); statusLbl.Text = "○ Đợi câu..."; statusLbl.TextXAlignment = Enum.TextXAlignment.Left; statusLbl.Parent = panel
local castLbl = Instance.new("TextLabel"); castLbl.Size = UDim2.new(1,-16,0,13); castLbl.Position = UDim2.new(0,8,0,133); castLbl.BackgroundTransparency = 1; castLbl.Font = Enum.Font.Gotham; castLbl.TextSize = 10; castLbl.TextColor3 = Color3.fromRGB(100,180,255); castLbl.Text = string.format("Cast delay: %.2fs", CFG.CastDelay); castLbl.TextXAlignment = Enum.TextXAlignment.Left; castLbl.Parent = panel

-- Nút Tắt Bật Lock Line Mới
local lockBtn = Instance.new("TextButton"); lockBtn.Size = UDim2.new(1,-16,0,22); lockBtn.Position = UDim2.new(0,8,0,152); lockBtn.BackgroundColor3 = Color3.fromRGB(40,100,175); lockBtn.BorderSizePixel = 0; lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 11; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Text = "🔒 Lock Line: ON"; lockBtn.Parent = panel; Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0,6)

local btnRow = Instance.new("Frame"); btnRow.Size = UDim2.new(1,-16,0,24); btnRow.Position = UDim2.new(0,8,0,182); btnRow.BackgroundTransparency = 1; btnRow.Parent = panel
local function makeBtn(text, xoff) local b = Instance.new("TextButton"); b.Size = UDim2.new(0,88,1,0); b.Position = UDim2.new(0,xoff,0,0); b.BackgroundColor3 = Color3.fromRGB(50,50,70); b.BorderSizePixel = 0; b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.TextColor3 = Color3.new(1,1,1); b.Text = text; b.Parent = btnRow; Instance.new("UICorner", b).CornerRadius = UDim.new(0,6); return b end

local bcM = makeBtn("- Cast", 0); local bcP = makeBtn("+ Cast", 96)

bcM.MouseButton1Click:Connect(function() CFG.CastDelay = math.max(0, CFG.CastDelay - 0.05); castLbl.Text = string.format("Cast delay: %.2fs", CFG.CastDelay) end)
bcP.MouseButton1Click:Connect(function() CFG.CastDelay = math.min(2, CFG.CastDelay + 0.05); castLbl.Text = string.format("Cast delay: %.2fs", CFG.CastDelay) end)

lockBtn.MouseButton1Click:Connect(function()
    CFG.LockLine = not CFG.LockLine
    lockBtn.BackgroundColor3 = CFG.LockLine and Color3.fromRGB(40,100,175) or Color3.fromRGB(60,60,80)
    lockBtn.Text = CFG.LockLine and "🔒 Lock Line: ON" or "🔒 Lock Line: OFF"
end)

RunService.Heartbeat:Connect(function()
    if lastHitBuffer then bufLbl.Text = "✓ Buffer captured!"; bufLbl.TextColor3 = Color3.fromRGB(80,200,120) end
    if getMain() then
        local active = false; pcall(function() active = getMain().Visible end)
        if active then statusLbl.Text = "● QTE đang chạy"; statusLbl.TextColor3 = Color3.fromRGB(80,200,120)
        elseif justClosed then statusLbl.Text = "⚡ Casting..."; statusLbl.TextColor3 = Color3.fromRGB(255,200,50)
        else statusLbl.Text = "○ Đợi câu..."; statusLbl.TextColor3 = Color3.fromRGB(100,100,130) end
    end
end)

local function setFishing(s) CFG.Enabled = s; toggleBtn.BackgroundColor3 = s and Color3.fromRGB(35,175,95) or Color3.fromRGB(175,45,45); toggleBtn.Text = s and "AUTO FISH: ON" or "AUTO FISH: OFF" end
local function setSelling(s) CFG.AutoSell = s; sellBtn.BackgroundColor3 = s and Color3.fromRGB(35,175,95) or Color3.fromRGB(175,45,45); sellBtn.Text = s and "AUTO SELL: ON" or "AUTO SELL: OFF" end
toggleBtn.MouseButton1Click:Connect(function() setFishing(not CFG.Enabled) end)
sellBtn.MouseButton1Click:Connect(function() setSelling(not CFG.AutoSell) end)
local drag, dStart, dPos = false, nil, nil
topBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag=true; dStart=i.Position; dPos=panel.Position end end)
topBar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag=false end end)
UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dStart; panel.Position = UDim2.new(dPos.X.Scale, dPos.X.Offset+d.X, dPos.Y.Scale, dPos.Y.Offset+d.Y) end end)

-- ══════════ SMART AUTO SELL LOGIC ══════════
task.spawn(function()
    while true do
        if CFG.AutoSell and ByteNetReliable then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                local items = backpack:GetChildren()
                local itemCount = 0
                local foundSunshard = false
                
                for _, item in ipairs(items) do
                    if item:IsA("Tool") then
                        itemCount = itemCount + 1
                        local cleanName = string.gsub(string.lower(item.Name), "%s+", "")
                        if string.match(cleanName, "sunshard") then
                            foundSunshard = true
                            break
                        end
                    end
                end
                
                if foundSunshard then
                    setSelling(false)
                    pcall(function() sellBtn.Text = "OFF (CÓ SUNSHARD)" end)
                elseif itemCount >= 10 then
                    pcall(function() ByteNetReliable:FireServer(SELL_BUF) end)
                end
            end
        end
        task.wait(CFG.SellInterval)
    end
end)

print("[Fish & Sell v5.0 Ultimate] Loaded ✓")
