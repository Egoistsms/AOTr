repeat task.wait() until game:IsLoaded()
    
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local REFILL_OFFSET = Vector3.new(0, 0, 3)
local NAPE_OFFSET_1 = Vector3.new(0, 145, 0)
local MAX_REFILLS = 2

local Cache = {
    LocalPlayer = Players.LocalPlayer,
    Character = nil,
    HumanoidRootPart = nil,
    Humanoid = nil,
    TitansFolder = nil,
    GUI = {
        Interface = nil,
        Hotbar = nil,
        Buttons = nil,
        RetryButton = nil,
        BladesText = nil,
        SpearsText = nil
    },
    isEnabled = true,
    isRefilling = false,
    animationConnection = nil
}

local function UpdateCharacter()
    Cache.Character = Cache.LocalPlayer.Character or Cache.LocalPlayer.CharacterAdded:Wait()
    Cache.HumanoidRootPart = Cache.Character:WaitForChild("HumanoidRootPart", 5)
    Cache.Humanoid = Cache.Character:WaitForChild("Humanoid", 5)
end

local function UpdateGUI()
    local playerGui = Cache.LocalPlayer:WaitForChild("PlayerGui", 5)
    if not playerGui then return end

    Cache.GUI.Interface = playerGui:FindFirstChild("Interface")
    if not Cache.GUI.Interface then return end

    local hud = Cache.GUI.Interface:FindFirstChild("HUD")
    local main = hud and hud:FindFirstChild("Main")
    local top = main and main:FindFirstChild("Top")
    
    Cache.GUI.Hotbar = top and top:FindFirstChild("Hotbar")
    Cache.GUI.Buttons = Cache.GUI.Interface:FindFirstChild("Buttons")
    
    local rewards = Cache.GUI.Interface:FindFirstChild("Rewards")
    local rewardsMain = rewards and rewards:FindFirstChild("Main")
    local info = rewardsMain and rewardsMain:FindFirstChild("Info")
    local infoMain = info and info.Main
    local rewardButtons = infoMain and infoMain:FindFirstChild("Buttons")
    Cache.GUI.RetryButton = rewardButtons and rewardButtons:FindFirstChild("Retry")
    
    local blades = top and top:FindFirstChild("Blades")
    local spears = top and top:FindFirstChild("Spears")
    Cache.GUI.BladesText = blades and blades:FindFirstChild("Sets") and blades.Sets.Text or "0 / 3"
    Cache.GUI.SpearsText = spears and spears:FindFirstChild("Spears") and spears.Spears.Text or "0 / 3"
end

local function UpdateTitansFolder()
    Cache.TitansFolder = Workspace:FindFirstChild("Titans")
end

UpdateCharacter()
UpdateGUI()
UpdateTitansFolder()

local function AnimationDelete()
    if not Cache.Humanoid then return end
    local animator = Cache.Humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        track:Stop(0)
        track:Destroy()
    end

    if not Cache.animationConnection then
        Cache.animationConnection = animator.AnimationPlayed:Connect(function(track)
            track:Stop(0)
            track:Destroy()
        end)
    end
end

local function AutoRefill()
    if not _G.AutoRefill or not Cache.Character or Cache.isRefilling then return end
    
    local rig = Cache.Character:FindFirstChild("Rig_" .. Cache.LocalPlayer.Name)
    if not rig then return end

    local rightHand = rig:FindFirstChild("RightHand")
    local leftHand = rig:FindFirstChild("LeftHand")
    local blade = (rightHand and rightHand:FindFirstChild("Blade_1")) or 
                 (leftHand and leftHand:FindFirstChild("Blade_1"))

    if not blade then return end

    UpdateGUI()
    if blade:GetAttribute("Broken") then
        if Cache.GUI.BladesText == "0 / 3" or Cache.GUI.SpearsText == "0 / 3" then
            Cache.isRefilling = true
            
            local reloads = Workspace:FindFirstChild("Unclimbable") and Workspace.Unclimbable:FindFirstChild("Reloads")
            local refill = reloads and reloads:GetChildren()[1]
            local refillPoint = refill and refill:FindFirstChild("Refill")
            
            if refillPoint and Cache.HumanoidRootPart then
                local originalCFrame = Cache.HumanoidRootPart.CFrame
                Cache.HumanoidRootPart.CFrame = CFrame.new(refillPoint.Position + REFILL_OFFSET)
                
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                task.wait()
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                
                UpdateGUI()
                if Cache.GUI.BladesText ~= "0 / 3" or Cache.GUI.SpearsText ~= "0 / 3" then
                    Cache.isRefilling = false
                end
            end
        else
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
            task.wait()
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        end
    end
end

local function AutoReplay()
    if not _G.AutoReplay or not Cache.GUI.RetryButton or not Cache.GUI.RetryButton.Visible then return end
    if Cache.GUI.RetryButton.Visible then
        Cache.GUI.RetryButton.Size = UDim2.new(1000, 0, 1000, 0)
        VirtualInputManager:SendMouseButtonEvent(957, 800, 0, true, game, 0)
        task.wait()
        VirtualInputManager:SendMouseButtonEvent(957, 800, 0, false, game, 0)
    end
end

local function AutoFarm()
    if not _G.AutoFarm or Cache.isRefilling or not Cache.Humanoid or Cache.Humanoid.Health <= 0 or not Cache.TitansFolder then return end

    for _, titan in ipairs(Cache.TitansFolder:GetChildren()) do
        local titanHumanoid = titan:FindFirstChildOfClass("Humanoid")
        local hitbox = titan:FindFirstChild("Hitboxes")
        local titanHumanoidRootPart = titan:FindFirstChild("HumanoidRootPart")
        local hit = hitbox and hitbox:FindFirstChild("Hit")
        local nape = hit and hit:FindFirstChild("Nape")
        local weld = nape:FindFirstChildOfClass("Weld") or nape:FindFirstChildOfClass("WeldConstraint") or nape:FindFirstChildOfClass("Motor6D")
        if weld then
            weld:Destroy()
        end
        local humanoidPos = titanHumanoidRootPart.Position
        local napePos = nape.Position
        local humanoidCF = titanHumanoidRootPart.CFrame
        
        if titanHumanoid and titanHumanoid.Health > 0 and nape and Cache.HumanoidRootPart then
            Cache.HumanoidRootPart.CFrame = CFrame.new(humanoidPos + NAPE_OFFSET_1)
            nape.CFrame = Cache.HumanoidRootPart.CFrame
            task.wait()
            nape.CFrame = humanoidCF
            task.wait()
            break
        end
        VirtualInputManager:SendMouseButtonEvent(957, 800, 0, true, game, 0)
        task.wait()
        VirtualInputManager:SendMouseButtonEvent(957, 800, 0, false, game, 0)
    end
end

local function TitanRipper()
    if not _G.TitanRipper or Cache.isRefilling or not Cache.Humanoid or Cache.Humanoid.Health <= 0 or not Cache.TitansFolder or not Cache.GUI.Interface then return end

    local skill1Cooldown = Cache.GUI.Interface:FindFirstChild("HUD") and 
                          Cache.GUI.Interface.HUD:FindFirstChild("Main") and 
                          Cache.GUI.Interface.HUD.Main:FindFirstChild("Top") and 
                          Cache.GUI.Interface.HUD.Main.Top:FindFirstChild("Hotbar") and 
                          Cache.GUI.Interface.HUD.Main.Top.Hotbar:FindFirstChild("Skill_1") and 
                          Cache.GUI.Interface.HUD.Main.Top.Hotbar.Skill_1:FindFirstChild("Cooldown") and 
                          Cache.GUI.Interface.HUD.Main.Top.Hotbar.Skill_1.Cooldown:FindFirstChild("Label") and 
                          Cache.GUI.Interface.HUD.Main.Top.Hotbar.Skill_1.Cooldown.Label.Text or "0s"

    local skill2Cooldown = Cache.GUI.Interface:FindFirstChild("HUD") and 
                          Cache.GUI.Interface.HUD:FindFirstChild("Main") and 
                          Cache.GUI.Interface.HUD.Main:FindFirstChild("Top") and 
                          Cache.GUI.Interface.HUD.Main.Top:FindFirstChild("Hotbar") and 
                          Cache.GUI.Interface.HUD.Main.Top.Hotbar:FindFirstChild("Skill_2") and 
                          Cache.GUI.Interface.HUD.Main.Top.Hotbar.Skill_2:FindFirstChild("Cooldown") and 
                          Cache.GUI.Interface.HUD.Main.Top.Hotbar.Skill_2.Cooldown:FindFirstChild("Label") and 
                          Cache.GUI.Interface.HUD.Main.Top.Hotbar.Skill_2.Cooldown.Label.Text or "0s"

    local targetNapes = {}

    for _, descendant in ipairs(Cache.TitansFolder:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name == "Nape" then

            local weld = descendant:FindFirstChildOfClass("Weld") or descendant:FindFirstChildOfClass("WeldConstraint") or descendant:FindFirstChildOfClass("Motor6D")
            if weld then
                weld:Destroy()
            end

            table.insert(targetNapes, descendant)
        end
    end
    if skill1Cooldown == "1s" or skill1Cooldown == "90s" or skill2Cooldown == "1s" or skill2Cooldown == "90s" then
        task.spawn(function()
            for _, nape in ipairs(targetNapes) do
                nape.CFrame = Cache.HumanoidRootPart.CFrame
            end
        end)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
        task.wait()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
        task.wait()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
    else
        AutoFarm()
    end
end

RunService.Stepped:Connect(function()
    if not Cache.isEnabled then return end
    
    task.spawn(function()
        local success, errorMsg = pcall(function()
            if not Cache.Character or not Cache.HumanoidRootPart or not Cache.Humanoid then
                UpdateCharacter()
            end
            if not Cache.TitansFolder then
                UpdateTitansFolder()
            end

            Cache.LocalPlayer:SetAttribute("Max_Refills", MAX_REFILLS)
            Cache.LocalPlayer:SetAttribute("Refills", MAX_REFILLS)

            AnimationDelete()
            AutoReplay()
            AutoRefill()
            AutoFarm()
            TitanRipper()
        end)

        if not success then
            warn("Error in main loop: " .. tostring(errorMsg))
            task.wait()
            UpdateCharacter()
            UpdateGUI()
            UpdateTitansFolder()
        end
    end)
end)

Cache.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Cache.Character = newCharacter
    UpdateCharacter()
end)

if Cache.Humanoid then
    Cache.Humanoid.Died:Connect(function()
        Cache.isRefilling = false
        task.wait()
        UpdateCharacter()
        UpdateGUI()
    end)
end

if Cache.TitansFolder then
    Cache.TitansFolder.ChildAdded:Connect(UpdateTitansFolder)
    Cache.TitansFolder.ChildRemoved:Connect(UpdateTitansFolder)
end

Cache.LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "Interface" then
        UpdateGUI()
    end
end)

task.spawn(function()
    while Cache.isEnabled do
        task.wait()
        if not Cache.Character or not Cache.HumanoidRootPart or not Cache.Humanoid then
            UpdateCharacter()
        end
        if not Cache.TitansFolder then
            UpdateTitansFolder()
        end
        UpdateGUI()
    end
end)

local unclimbable = Workspace:FindFirstChild("Unclimbable")
local keepNames = {"Unclimbable", "Terrain", "Characters", "Titans"}

Workspace.Terrain.Clouds:Destroy()

for _, obj in ipairs(Workspace:GetChildren()) do
    if not table.find(keepNames, obj.Name) then
        obj:Destroy()
    end
end

if unclimbable then
    for _, obj in ipairs(unclimbable:GetChildren()) do
        if obj.Name ~= "Reloads" then
            obj:Destroy()
        end
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy()
    end
end

local TeleportCheck = false
LocalPlayer.OnTeleport:Connect(function(State)
	if not TeleportCheck and queueteleport then
		TeleportCheck = true
		queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/Egoistsms/AOTr/refs/heads/main/README.md'))()")
	end
end)
