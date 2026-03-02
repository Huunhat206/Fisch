local player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(1)

game:GetService("ReplicatedStorage"):WaitForChild("requests"):WaitForChild("character"):WaitForChild("spawn"):FireServer()

task.wait(3)

local function getArrowCFrame(arrow)
    if arrow:IsA("Model") then
        return arrow:GetPivot()
    elseif arrow:IsA("BasePart") then
        return arrow.CFrame
    elseif arrow:IsA("Tool") and arrow:FindFirstChild("Handle") then
        return arrow.Handle.CFrame
    end
    return nil
end

local function interactWithArrow(arrow)
    local prompt = arrow:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        if fireproximityprompt then
            fireproximityprompt(prompt, 1, true)
        else
            prompt:InputHoldBegin()
            task.wait(5.2)
            prompt:InputHoldEnd()
        end
    end
end

local arrows = {}
for _, descendant in pairs(workspace:GetDescendants()) do
    if descendant.Name == "Stand Arrow" then
        table.insert(arrows, descendant)
    end
end

for _, arrow in ipairs(arrows) do
    if arrow and arrow.Parent then
        local targetCFrame = getArrowCFrame(arrow)
        if targetCFrame then
            local character = player.Character or player.CharacterAdded:Wait()
            local rootPart = character:WaitForChild("HumanoidRootPart")
            
            rootPart.CFrame = targetCFrame
            task.wait(0.5)
            interactWithArrow(arrow)
            task.wait(1)
        end
    end
end

local placeId = game.PlaceId
local jobId = game.JobId
local url = "https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=Asc&limit=100"

local success, result = pcall(function()
    return game:HttpGet(url)
end)

if success and result then
    local data = HttpService:JSONDecode(result)
    if data and data.data then
        for _, server in ipairs(data.data) do
            if server.playing > 0 and server.id ~= jobId then
                TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                task.wait(5)
                break
            end
        end
    end
end
