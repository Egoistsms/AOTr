if not game:IsLoaded() then
    local notLoaded = Instance.new("Message", game:GetService("CoreGui"))
    notLoaded.Text = "MAD_GYATT is waiting for the game to load"
    game.Loaded:Wait()
    notLoaded:Destroy()
end

local Workspace, RunService, VirtualInputManager, Players, ReplicatedStorage =
    game:GetService("Workspace"), game:GetService("RunService"), game:GetService("VirtualInputManager"), game:GetService("Players"), game:GetService("ReplicatedStorage")

local player, character = Players.LocalPlayer, nil
local humanoid, rootPart, mobFolder = nil, nil, Workspace:FindFirstChild("Titans")

local playerGui, interface, hotbar, buttons, bladescount, retryButton =
    player:WaitForChild("PlayerGui", 5), nil, nil, nil, nil, nil

local function updateUIReferences()
    interface = playerGui:FindFirstChild("Interface")
    if not interface then return end

    local hudMain = interface:FindFirstChild("HUD") and interface.HUD:FindFirstChild("Main")
    if hudMain then
        hotbar = hudMain:FindFirstChild("Top") and hudMain.Top:FindFirstChild("Hotbar")
        bladescount = hudMain.Top:FindFirstChild("Blades") and hudMain.Top.Blades:FindFirstChild("Sets")
    end

    buttons = interface:FindFirstChild("Buttons")
    retryButton = interface:FindFirstChild("Rewards") and interface.Rewards.Main.Info.Main.Buttons:FindFirstChild("Retry")
end

updateUIReferences()

local skillcd = hotbar and {
    [hotbar.Skill_3.Cooldown.Label] = Enum.KeyCode.Three,
    [hotbar.Skill_4.Cooldown.Label] = Enum.KeyCode.Four
} or {}

local function checkcd()
    for skillLabel, key in pairs(skillcd) do
        if skillLabel and skillLabel:IsA("TextLabel") and (skillLabel.Text == "1s" or skillLabel.Text == "90s") then
            return key
        end
    end
    return nil
end

local function expandHitbox(size)
    if not mobFolder then return end
    for _, titan in ipairs(mobFolder:GetChildren()) do
        local hitbox = titan:FindFirstChild("Hitboxes")
        if hitbox then
            local nape = hitbox:FindFirstChild("Hit") and hitbox.Hit:FindFirstChild("Nape")
            if nape then
                for _, partName in ipairs({"Eyes", "LeftArm", "LeftLeg", "RightArm", "RightLeg"}) do
                    local part = hitbox:FindFirstChild(partName)
                    if part then part:Destroy() end
                end
                nape.Size, nape.Transparency, nape.Color, nape.Material, nape.CanCollide, nape.Anchored =
                    size, 0.96, Color3.new(1, 1, 1), Enum.Material.Neon, false, false
            end
        end
    end
end

local function autoEscape()
    if not buttons then return end
    for _, button in ipairs(buttons:GetChildren()) do
        local key = string.sub(tostring(button), 1, 1)
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.01)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end
end

local function autoRefill()
    if not (character and rootPart and bladescount and bladescount.Text == "0 / 3") then return end
    local rig = character:FindFirstChild("Rig_" .. player.Name)
    if not rig then return end

    local reloadsFolder = Workspace:FindFirstChild("Unclimbable") and Workspace.Unclimbable:FindFirstChild("Reloads")
    local refillPoint = reloadsFolder and reloadsFolder:GetChildren()[1] and reloadsFolder:GetChildren()[1]:FindFirstChild("Refill")

    for _, hand in ipairs(rig:GetChildren()) do
        if hand.Name == "RightHand" or hand.Name == "LeftHand" then
            for _, blade in ipairs(hand:GetChildren()) do
                if blade.Name == "Blade_1" and blade:GetAttribute("Broken") and refillPoint then
                    rootPart.CFrame = CFrame.new(refillPoint.Position + Vector3.new(0, 0, 3))
                    task.wait(0.5)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                    return
                end
            end
        end
    end
end

local function autoReplay()
    if retryButton and retryButton.Visible then
        retryButton.Size = UDim2.new(1000, 0, 1000, 0)
        VirtualInputManager:SendMouseButtonEvent(957, 800, 0, true, game, 0)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(957, 800, 0, false, game, 0)
    end
end

local function autoFarm()
    if not (mobFolder and rootPart and humanoid and humanoid.Health > 0) then return end

    for _, titan in ipairs(mobFolder:GetChildren()) do
        local titanHumanoid, hitbox = titan:FindFirstChildOfClass("Humanoid"), titan:FindFirstChild("Hitboxes")
        if titanHumanoid and titanHumanoid.Health > 0 and hitbox then
            local nape = hitbox:FindFirstChild("Hit") and hitbox.Hit:FindFirstChild("Nape")
            if nape then
                --[[local key = checkcd()
                if key then
                    expandHitbox(Vector3.new(99999, 99999, 99999))
                    rootPart.CFrame = nape.CFrame * CFrame.new(0, 350, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                else]]
                expandHitbox(Vector3.new(700, 700, 700))
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                rootPart.CFrame = CFrame.new(nape.Position + Vector3.new(0, 350, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
                task.wait(3)
                rootPart.CFrame = CFrame.new(nape.Position + Vector3.new(0, 700, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
                --end
                break
            end
        end
    end
end

local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid", 5)
    rootPart = character:WaitForChild("HumanoidRootPart", 5)
end

player.CharacterAdded:Connect(onCharacterAdded)

RunService.Heartbeat:Connect(function()
    if not _G.Enable then return end
    autoFarm()
    autoEscape()
    autoRefill()
    autoReplay()
end)

_G.Enable = true
sethiddenproperty(player, "SimulationRadius", math.huge)

local tpcheck = false
player.OnTeleport:Connect(function(State)
    if not tpcheck and queue_on_teleport then
        tpcheck = true
        queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/Egoistsms/AOTr/refs/heads/main/README.md'))()")
    end
end)
--humanoid.Health = 0
