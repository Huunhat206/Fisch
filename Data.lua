while task.wait() do
    local player = game.Players.LocalPlayer
    repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local hrp = player.Character.HumanoidRootPart

    task.wait(5)

    local function getAllBasaltCores()
        local cores = {}
        local rocks = workspace:FindFirstChild("Rocks")

        if not rocks then
            warn("workspace.Rocks not found")
            return cores
        end

        for _, obj in ipairs(rocks:GetDescendants()) do
            if obj.Name:lower():match("basalt core") and (obj:IsA("Model") or obj:IsA("BasePart")) then
                table.insert(cores, obj)
            end
        end

        return cores
    end

    local function teleportTo(core)
        local target = nil

        if core:IsA("Model") then
            target = core.PrimaryPart or core:FindFirstChildWhichIsA("BasePart", true)
        elseif core:IsA("BasePart") then
            target = core
        end

        if target then
            hrp.CFrame = target.CFrame + Vector3.new(0, 5, 0)
        else
            warn("No valid part to teleport to for", core:GetFullName())
        end
    end

    local function isGone(core)
        return not core or not core:IsDescendantOf(workspace)
    end

    local function run()
        local cores = getAllBasaltCores()

        if #cores == 0 then
            warn("No Basalt Cores found")
            return
        end

        print("Found", #cores, "Basalt Core(s)")

        for i, core in ipairs(cores) do
            print("Teleporting to core #" .. i)
            teleportTo(core)

            while not isGone(core) do
                task.wait(0.5)
            end

            print("Core #" .. i .. " gone. Moving to next.")
            task.wait(0.5)
        end

        print("All cores completed!")
    end

    run()
end