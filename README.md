if not game:IsLoaded() then
    local notLoaded = Instance.new("Message")
    notLoaded.Parent = COREGUI
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
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid", 5)
local rootPart = character:WaitForChild("HumanoidRootPart", 5)
local mobFolder = Workspace:FindFirstChild("Titans")

local playerGui = player:WaitForChild("PlayerGui", 5)
local interface = playerGui:WaitForChild("Interface", 5)
local hotbar = interface:FindFirstChild("HUD") and interface.HUD:FindFirstChild("Main") and interface.HUD.Main:FindFirstChild("Top") and interface.HUD.Main.Top:FindFirstChild("Hotbar")
local buttons = interface:WaitForChild("Buttons", 5)
local bladescount = interface:FindFirstChild("HUD") and interface.HUD:FindFirstChild("Main") and interface.HUD.Main:FindFirstChild("Top") and interface.HUD.Main.Top:FindFirstChild("Blades") and interface.HUD.Main.Top.Blades:FindFirstChild("Sets")
local retryButton = interface:FindFirstChild("Rewards") and interface.Rewards:FindFirstChild("Main") and interface.Rewards.Main:FindFirstChild("Info") and interface.Rewards.Main.Info.Main:FindFirstChild("Buttons") and interface.Rewards.Main.Info.Main.Buttons:FindFirstChild("Retry")

local isEnabled = true
local refilling = false

local skillcd = {
    [hotbar.Skill_3.Cooldown.Label] = Enum.KeyCode.Three,
    [hotbar.Skill_4.Cooldown.Label] = Enum.KeyCode.Four
}

local function checkcd()
    for skillLabel, key in pairs(skillcd) do
        if skillLabel and skillLabel:IsA("TextLabel") then
            local cooldownText = skillLabel.Text
            if cooldownText == "1s" or cooldownText == "90s" then
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
                        if part then part:Destroy() end
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
        VirtualInputManager:SendKeyEvent(true, string.sub(tostring(button), 1, 1), false, game)
        task.wait(0.01)
        VirtualInputManager:SendKeyEvent(false, string.sub(tostring(button), 1, 1), false, game)
    end
end

local function autoRefill()
    local rig = character:FindFirstChild("Rig_" .. player.Name)
    if not rig then return end

    local unclimbable = Workspace:FindFirstChild("Unclimbable")
    local reloadsFolder = unclimbable and unclimbable:FindFirstChild("Reloads")
    local refillPoint = reloadsFolder and reloadsFolder:GetChildren()[1] and reloadsFolder:GetChildren()[1]:FindFirstChild("Refill")
    for _, hand in ipairs(rig:GetChildren()) do
        if hand.Name == "RightHand" or hand.Name == "LeftHand" then
            for _, blade in ipairs(hand:GetChildren()) do
                if blade.Name == "Blade_1" then
                    if blade:GetAttribute("Broken") and bladescount.Text == "0 / 3" and refillPoint then
                        refilling = true
                        rootPart.CFrame = CFrame.new(refillPoint.Position + Vector3.new(0, 0, 3))
                        task.wait(0.5)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                        if bladescount.Text ~= "0 / 3" then
                            refilling = false
                        end
                        return
                    elseif blade:GetAttribute("Broken") then
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
    if not mobFolder or not rootPart or not humanoid or humanoid.Health <= 0  or refilling == true then return end
    for _, titan in ipairs(mobFolder:GetChildren()) do
        local titanHumanoid = titan:FindFirstChildOfClass("Humanoid")
        local hitbox = titan:FindFirstChild("Hitboxes")
        if titanHumanoid and titanHumanoid.Health > 0 and hitbox then
            local nape = hitbox:FindFirstChild("Hit") and hitbox.Hit:FindFirstChild("Nape")
            if nape then
                local key = checkcd()
                if checkcd() then
                    expandHitbox(Vector3.new(99999, 99999, 99999))
                    rootPart.CFrame = nape.CFrame * CFrame.new(0, 350, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                    task.wait(3)
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
    humanoid = character:WaitForChild("Humanoid", 5)
    rootPart = character:WaitForChild("HumanoidRootPart", 5)
end

--[[local function bypass()
    player.PlayerScripts.Baka.Disable = true
    ReplicatedStorage.Assets.Remotes:Destroy()
end]]
    
player.CharacterAdded:Connect(onCharacterAdded)

RunService.Stepped:Connect(function(_, deltaTime)
    if not isEnabled then return end

    pcall(function()
        checkcd()
        autoFarm()
        autoEscape()
        autoRefill()
        autoReplay()
        
        local maxRefills = player:GetAttribute("Max_Refills")
        local refills = player:GetAttribute("Refills")
        player:SetAttribute("Max_Refills", 2)
        player:SetAttribute("Refills", 2)
    end)
end)

_G.Enable = true -- false / true
isEnabled = _G.Enable

spawn(function()
    while true do
        if _G.Enable ~= isEnabled then
            isEnabled = _G.Enable
        end
        task.wait(0.1)
    end
end)

sethiddenproperty(player, "SimulationRadius", math.huge)

local tpcheck = false
player.OnTeleport:Connect(function(State)
	if not tpcheck and queue_on_teleport then
		tpcheck = true
		queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/Egoistsms/AOTr/refs/heads/main/README.md'))()")
	end
end)
--humanoid.Health = 0
