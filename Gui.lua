--// Auto find & sell all "Gladius Dagger"
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Lấy Character an toàn
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Remote bán đồ (dựa trên đoạn bạn gửi)
local RunCommand = ReplicatedStorage
    :WaitForChild("Shared")
    :WaitForChild("Packages")
    :WaitForChild("Knit")
    :WaitForChild("Services")
    :WaitForChild("DialogueService")
    :WaitForChild("RF")
    :WaitForChild("RunCommand")

-- Thử lấy ID từ 1 instance item
local function getItemIdFromInstance(item)
    -- Id = StringValue
    if item:FindFirstChild("Id") and item.Id:IsA("StringValue") then
        return item.Id.Value
    end

    -- ItemId = StringValue
    if item:FindFirstChild("ItemId") and item.ItemId:IsA("StringValue") then
        return item.ItemId.Value
    end

    -- Attribute "Id"
    if item:GetAttribute("Id") then
        return item:GetAttribute("Id")
    end

    -- Fallback: nếu Name giống UUID thì dùng luôn
    if string.match(item.Name, "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x") then
        return item.Name
    end

    return nil
end

-- Tự tìm các "kho" khả nghi quanh player
local function findContainers()
    local containers = {}
    local seen = {}

    local patterns = {
        "inventory",
        "bag",
        "items",
        "warehouse",
        "storage",
        "character",
        "weapons",
        "backpack"
    }

    local function addContainer(inst)
        if not inst then return end
        if seen[inst] then return end
        seen[inst] = true
        table.insert(containers, inst)
    end

    -- Thêm Character & Backpack
    addContainer(Character)
    addContainer(LocalPlayer:FindFirstChild("Backpack"))

    -- Quét các folder/model tên giống kho
    for _, inst in ipairs(LocalPlayer:GetDescendants()) do
        if inst:IsA("Folder") or inst:IsA("Model") then
            local lowerName = inst.Name:lower()
            for _, pat in ipairs(patterns) do
                if lowerName:find(pat) then
                    addContainer(inst)
                    break
                end
            end
        end
    end

    print("[AutoSell] Containers found:", #containers)
    for _, c in ipairs(containers) do
        print("  ->", c:GetFullName())
    end

    return containers
end

-- Gom hết ID của Gladius Dagger
local function collectGladiusIds()
    local basket = {}
    local count = 0

    local containers = findContainers()

    for _, container in ipairs(containers) do
        for _, inst in ipairs(container:GetDescendants()) do
            if inst.Name == "Gladius Dagger" then
                local id = getItemIdFromInstance(inst)
                if id and not basket[id] then
                    basket[id] = true
                    count += 1
                    print("[AutoSell] Found Gladius Dagger ID:", id, "at", inst:GetFullName())
                else
                    if not id then
                        warn("[AutoSell] Gladius Dagger nhưng không lấy được ID tại:", inst:GetFullName())
                    end
                end
            end
        end
    end

    return basket, count
end

local function sellAllGladius()
    local basket, count = collectGladiusIds()

    if count == 0 then
        warn("[AutoSell] Không tìm thấy Gladius Dagger nào để bán.")
        return
    end

    local args = {
        "SellConfirm",
        {
            Basket = basket
        }
    }

    print("[AutoSell] Đang gửi SellConfirm cho", count, "Gladius Dagger...")
    RunCommand:InvokeServer(unpack(args))
end

-- Chạy luôn
sellAllGladius()