if not game:IsLoaded() then
    local notLoaded = Instance.new("Message")
    notLoaded.Parent = game:GetService("CoreGui")
    notLoaded.Text = "MAD_GYATT is waiting for the game to load"
    game.Loaded:Wait()
    notLoaded:Destroy()
end

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
if not player then error("LocalPlayer not found!") end

local function waitForChildSafe(parent, childName, timeout)
    local child = parent:FindFirstChild(childName)
    if child then return child end
    local success, result = pcall(function()
        return parent:WaitForChild(childName, timeout or 5)
    end)
    return (success and result) or nil
end

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = waitForChildSafe(character, "Humanoid", 5)
local rootPart = waitForChildSafe(character, "HumanoidRootPart", 5)
local mobFolder = Workspace:FindFirstChild("Titans")
if not mobFolder then
    warn("Titans folder not found in Workspace!")
end

local playerGui = waitForChildSafe(player, "PlayerGui", 5)
local interface = waitForChildSafe(playerGui, "Interface", 5)
local hotbar = (((interface:FindFirstChild("HUD") or {}):FindFirstChild("Main") or {}):FindFirstChild("Top") or {}):FindFirstChild("Hotbar")
local buttons = waitForChildSafe(interface, "Buttons", 5)
local bladescount = (((interface:FindFirstChild("HUD") or {}):FindFirstChild("Main") or {}):FindFirstChild("Top") or {}):FindFirstChild("Blades")
bladescount = bladescount and bladescount:FindFirstChild("Sets")
local retryButton = ((((interface:FindFirstChild("Rewards") or {}):FindFirstChild("Main") or {}):FindFirstChild("Info") or {}):FindFirstChild("Main") or {}):FindFirstChild("Buttons")
retryButton = retryButton and retryButton:FindFirstChild("Retry")

local isEnabled = true
local refilling = false
local firstdoing = true

local skillcd = {
    [hotbar and hotbar:FindFirstChild("Skill_3") and hotbar.Skill_3:FindFirstChild("Cooldown") and hotbar.Skill_3.Cooldown:FindFirstChild("Label")] = Enum.KeyCode.Three,
    [hotbar and hotbar:FindFirstChild("Skill_4") and hotbar.Skill_4:FindFirstChild("Cooldown") and hotbar.Skill_4.Cooldown:FindFirstChild("Label")] = Enum.KeyCode.Four
}

local function checkCooldown()
    for skillLabel, key in pairs(skillcd) do
        if skillLabel and skillLabel.Text then
            local cooldownText = skillLabel.Text
            if cooldownText ~= "1s" or firstdoing == true then
                return key
            end
        end
    end
    return nil
end

local function expandHitbox(size)
    if not mobFolder then return end
    for _, titan in ipairs(mobFolder:GetChildren()) do
        local hitbox = titan:FindFirstChild("Hitboxes")
        if hitbox then
            local hit = hitbox:FindFirstChild("Hit")
            if hit then
                local nape = hit:FindFirstChild("Nape")
                if nape then
                    for _, partName in ipairs({"Eyes", "LeftArm", "LeftLeg", "RightArm", "RightLeg"}) do
                        local part = hit:FindFirstChild(partName)
                        if part then
                            pcall(function() part:Destroy() end)
                        end
                    end
                    nape.Size = size
                    nape.Transparency = 0.96
                    nape.Color = Color3.new(1, 1, 1)
                    nape.Material = Enum.Material.Neon
                    nape.CanCollide = false
                    nape.Anchored = false
                end
            end
        end
    end
end

local function autoEscape()
    if not buttons then return end
    for _, button in ipairs(buttons:GetChildren()) do
        local keyName = tostring(button):sub(1, 1)
        VirtualInputManager:SendKeyEvent(true, keyName, false, game)
        task.wait(0.01)
        VirtualInputManager:SendKeyEvent(false, keyName, false, game)
    end
end

local function autoRefill()
    local rig = character:FindFirstChild("Rig_" .. player.Name)
    if not rig then return end

    local unclimbable = Workspace:FindFirstChild("Unclimbable")
    local reloadsFolder = unclimbable and unclimbable:FindFirstChild("Reloads")
    local refillPoint = reloadsFolder and reloadsFolder:GetChildren()[1] and reloadsFolder:GetChildren()[1]:FindFirstChild("Refill")
    if not refillPoint then return end

    for _, hand in ipairs(rig:GetChildren()) do
        if hand.Name == "RightHand" or hand.Name == "LeftHand" then
            for _, blade in ipairs(hand:GetChildren()) do
                if blade.Name == "Blade_1" then
                    local isBroken = blade:GetAttribute("Broken")
                    if isBroken and bladescount and bladescount.Text == "0 / 3" then
                        refilling = true
                        pcall(function()
                            rootPart.CFrame = CFrame.new(refillPoint.Position + Vector3.new(0, 0, 3))
                        end)
                        task.wait(0.5)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                        if bladescount.Text ~= "0 / 3" then
                            refilling = false
                        end
                        return
                    elseif isBroken then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                        return
                    end
                end
            end
        end
    end
end

local function autoReplay()
    if not retryButton or not retryButton.Visible then return end
    retryButton.Size = UDim2.new(1000, 0, 1000, 0)
    VirtualInputManager:SendMouseButtonEvent(957, 800, 0, true, game, 0)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(957, 800, 0, false, game, 0)
end

local function autoFarm()
    if not mobFolder or not rootPart or not humanoid or humanoid.Health <= 0 or refilling == true then 
        return 
    end
    
    for _, titan in ipairs(mobFolder:GetChildren()) do
        local titanHumanoid = titan:FindFirstChildOfClass("Humanoid")
        local hitbox = titan:FindFirstChild("Hitboxes")
        if titanHumanoid and titanHumanoid.Health > 0 and hitbox then
            local nape = hitbox:FindFirstChild("Hit") and hitbox.Hit:FindFirstChild("Nape")
            if nape then
                local key = checkCooldown()
                if key or firstdoing == true then
                    expandHitbox(Vector3.new(9999999, 9999999, 9999999))
                    rootPart.CFrame = nape.CFrame * CFrame.new(0, 350, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                    task.wait(3)
                    rootPart.CFrame = nape.CFrame + CFrame.new(0, 700, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    firstdoing = false
                else
                    expandHitbox(Vector3.new(700, 700, 700))
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    rootPart.CFrame = CFrame.new(nape.Position + Vector3.new(0, 350, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
                    task.wait(3)
                    rootPart.CFrame = CFrame.new(nape.Position + Vector3.new(0, 700, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
                end
                break
            end
        end
    end
end

local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoid = waitForChildSafe(character, "Humanoid", 5)
    rootPart = waitForChildSafe(character, "HumanoidRootPart", 5)
end
player.CharacterAdded:Connect(onCharacterAdded)

RunService.Stepped:Connect(function(_, deltaTime)
    if not isEnabled then return end

    pcall(function()
        checkCooldown()
        autoFarm()
        autoEscape()
        autoRefill()
        autoReplay()

        local maxRefills = player:GetAttribute("Max_Refills")
        local refills = player:GetAttribute("Refills")
        if maxRefills ~= 2 then player:SetAttribute("Max_Refills", 2) end
        if refills ~= 2 then player:SetAttribute("Refills", 2) end
    end)
end)

_G.Enable = true
isEnabled = _G.Enable

spawn(function()
    while true do
        if _G.Enable ~= isEnabled then
            isEnabled = _G.Enable
        end
        task.wait(0.1)
    end
end)

local tpcheck = false
player.OnTeleport:Connect(function(State)
    if not tpcheck and queue_on_teleport then
        tpcheck = true
        queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/Egoistsms/AOTr/refs/heads/main/README.md'))()")
    end
end)
