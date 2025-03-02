
_G.AutoFarm = true
_G.AutoRefill = true
_G.AutoReplay = false
_G.TitanRipper = true

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local ws = game:GetService("Workspace")
local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local vim = game:GetService("VirtualInputManager")

local NAPE_OFFSET = Vector3.new(0,300,0)
local MAX_REFILLS = 2

local c = {
    lp = plrs.LocalPlayer,
    char = nil,
    hrp = nil,
    hum = nil,
    tf = nil,
    gui = {
        itf = nil,
        hb = nil,
        btns = nil,
        retry = nil,
        blades = nil,
        spears = nil
    },
    enabled = true,
    refilling = false,
    animConn = nil,
    ripping = false
}

local function updChar()
    c.char = c.lp.Character or c.lp.CharacterAdded:Wait()
    c.hrp = c.char:WaitForChild("HumanoidRootPart", 5)
    c.hum = c.char:WaitForChild("Humanoid", 5)
end

local function updGUI()
    local pg = c.lp:WaitForChild("PlayerGui", 5)
    if not pg then return end

    c.gui.itf = pg:FindFirstChild("Interface")
    if not c.gui.itf then return end

    local hud = c.gui.itf:FindFirstChild("HUD")
    local main = hud and hud:FindFirstChild("Main")
    local top = main and main:FindFirstChild("Top")
    
    c.gui.hb = top and top:FindFirstChild("Hotbar")
    c.gui.btns = c.gui.itf:FindFirstChild("Buttons")
    
    local rw = c.gui.itf:FindFirstChild("Rewards")
    local rwMain = rw and rw:FindFirstChild("Main")
    local info = rwMain and rwMain:FindFirstChild("Info")
    local infoMain = info and info.Main
    local rwBtns = infoMain and infoMain:FindFirstChild("Buttons")
    c.gui.retry = rwBtns and rwBtns:FindFirstChild("Retry")
    
    local blades = top and top:FindFirstChild("Blades")
    local spears = top and top:FindFirstChild("Spears")
    c.gui.blades = blades and blades:FindFirstChild("Sets") and blades.Sets.Text or "0 / 3"
    c.gui.spears = spears and spears:FindFirstChild("Spears") and spears.Spears.Text or "0 / 8"
end

local function updTitans()
    c.tf = ws:FindFirstChild("Titans")
end

updChar()
updGUI()
updTitans()

local itf = plrs.LocalPlayer.PlayerGui:WaitForChild("Interface")

local function isNum(name)
    return tonumber(name) ~= nil
end

local function rmNumFrames()
    for _, child in pairs(itf:GetChildren()) do
        if child:IsA("Frame") and isNum(child.Name) then
            child:Destroy()
        end
    end
end

itf.ChildAdded:Connect(function(child)
    if child:IsA("Frame") and isNum(child.Name) then
        child:Destroy()
    end
end)

local function delAnims()
    if not c.hum then return end
    local anim = c.hum:FindFirstChildOfClass("Animator")
    if not anim then return end

    for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
        t:Stop(0)
        t:Destroy()
    end

    if not c.animConn then
        c.animConn = anim.AnimationPlayed:Connect(function(t)
            t:Stop(0)
            t:Destroy()
        end)
    end
end

local function doRefill()
    if not _G.AutoRefill or not c.char then return end
    
    local rig = c.char:FindFirstChild("Rig_" .. c.lp.Name)
    if not rig then return end

    local rh = rig:FindFirstChild("RightHand")
    local lh = rig:FindFirstChild("LeftHand")
    local blade = (rh and rh:FindFirstChild("Blade_1")) or 
                 (lh and lh:FindFirstChild("Blade_1"))

    if not blade then return end
    updGUI()
    if blade:GetAttribute("Broken") then
        if c.gui.blades == "0 / 3" or c.gui.spears == "0 / 8" then
            c.refilling = true
            
            local rl = ws:FindFirstChild("Unclimbable") and ws.Unclimbable:FindFirstChild("Reloads")
            local rf = rl and rl:GetChildren()[1]
            local rp = rf and rf:FindFirstChild("Refill")
            
            if rp and c.hrp then
                local ocf = c.hrp.CFrame
                c.hrp.CFrame = rp.CFrame
                
                vim:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                task.wait()
                vim:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                
                updGUI()
                if c.gui.blades ~= "0 / 3" or c.gui.spears ~= "0 / 8" then
                    c.refilling = false
                end
            end
        else
            vim:SendKeyEvent(true, Enum.KeyCode.R, false, game)
            task.wait()
            vim:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        end
    end
end

local function doReplay()
    if not _G.AutoReplay or not c.gui.retry or not c.gui.retry.Visible then return end
    updGUI()
    if c.gui.retry.Visible then
        c.gui.retry.Size = UDim2.new(1000, 0, 1000, 0)
        vim:SendMouseButtonEvent(957, 800, 0, true, game, 0)
        task.wait()
        vim:SendMouseButtonEvent(957, 800, 0, false, game, 0)
    end
end

local function doFarm()
    if not _G.AutoFarm or c.ripping or c.refilling or not c.hum or c.hum.Health <= 0 or not c.tf then return end

    local tt = c.tf:GetChildren()

    for _, t in ipairs(tt) do
        local th = t:FindFirstChildOfClass("Humanoid")
        local hb = t:FindFirstChild("Hitboxes")
        local thrp = t:FindFirstChild("HumanoidRootPart")
        local hit = hb and hb:FindFirstChild("Hit")
        local nape = hit and hit:FindFirstChild("Nape")
        local weld = nape and (nape:FindFirstChildOfClass("Weld") or nape:FindFirstChildOfClass("WeldConstraint") or nape:FindFirstChildOfClass("Motor6D"))
        
        if weld then weld:Destroy() end

        if #tt == 0 then return end
        updGUI()
        if th and thrp and nape and th.Health > 0 and c.hrp then
            local hpos = thrp.Position
            local hcf = thrp.CFrame
            
            c.hrp.CFrame = CFrame.new(hpos + NAPE_OFFSET)
            nape.CFrame = c.hrp.CFrame
            task.wait()
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait()
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait()
            nape.CFrame = hcf
            break
        end
    end
end

local function ripTitans()
    if not _G.TitanRipper or c.refilling or not c.hum or c.hum.Health <= 0 or not c.tf or not c.gui.itf then return end
    updGUI()
    local s1cd, s2cd
    local hbpath = c.gui.itf:FindFirstChild("HUD") and 
                  c.gui.itf.HUD:FindFirstChild("Main") and 
                  c.gui.itf.HUD.Main:FindFirstChild("Top") and 
                  c.gui.itf.HUD.Main.Top:FindFirstChild("Hotbar")
    
    if hbpath then
        if hbpath:FindFirstChild("Skill_1") and 
           hbpath.Skill_1:FindFirstChild("Cooldown") and 
           hbpath.Skill_1.Cooldown:FindFirstChild("Label") then
            s1cd = hbpath.Skill_1.Cooldown.Label.Text
        end
        
        if hbpath:FindFirstChild("Skill_2") and 
           hbpath.Skill_2:FindFirstChild("Cooldown") and 
           hbpath.Skill_2.Cooldown.Label then
            s2cd = hbpath.Skill_2.Cooldown.Label.Text
        end
    end

    local napes = {}

    for _, d in ipairs(c.tf:GetDescendants()) do
        if d:IsA("BasePart") and d.Name == "Nape" then
            pcall(function()
                local w = d:FindFirstChildOfClass("Weld") or 
                          d:FindFirstChildOfClass("WeldConstraint") or 
                          d:FindFirstChildOfClass("Motor6D")
                if w then w:Destroy() end
            end)
            table.insert(napes, d)
        end
    end

    if s1cd == "1s" or s1cd == "90s" or s2cd == "1s" or s2cd == "90s" then
        for _, n in ipairs(napes) do
            if n and n.Parent and c.hrp then
                n.CFrame = c.hrp.CFrame
            end
        end
        c.ripping = true
        vim:SendKeyEvent(true, Enum.KeyCode.One, false, game)
        task.wait()
        vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
        vim:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
        task.wait()
        vim:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
        c.ripping = false
    else
        pcall(doFarm)
    end
end

rs.Stepped:Connect(function()
    if not c.enabled then return end
    
    task.spawn(function()
        pcall(function()
            if not c.char or not c.hrp or not c.hum then updChar() end
            if not c.tf then updTitans() end

            c.lp:SetAttribute("Max_Refills", MAX_REFILLS)
            c.lp:SetAttribute("Refills", MAX_REFILLS)
            
            rmNumFrames()
            delAnims()
            doReplay()
            doRefill()
            if not c.refilling then
                ripTitans()
                doFarm()
            end
        end)
    end)
end)

c.lp.CharacterAdded:Connect(function(nc)
    c.char = nc
    updChar()
end)

if c.hum then
    c.hum.Died:Connect(function()
        c.refilling = false
        task.wait()
        updChar()
        updGUI()
    end)
end

if c.tf then
    c.tf.ChildAdded:Connect(updTitans)
    c.tf.ChildRemoved:Connect(updTitans)
end

c.lp.PlayerGui.ChildAdded:Connect(function(ch)
    if ch.Name == "Interface" then updGUI() end
end)

task.spawn(function()
    while c.enabled do
        task.wait()
        if not c.char or not c.hrp or not c.hum then updChar() end
        if not c.tf then updTitans() end
        updGUI()
    end
end)

_G.Ignore = {}
_G.Settings = {
	Players = {
		["Ignore Me"] = false,
		["Ignore Others"] = false,
		["Ignore Tools"] = false
	},
	Meshes = {
		NoMesh = true,
		NoTexture = false,
		Destroy = false
	},
	Images = {
		Invisible = false,
		Destroy = false
	},
	Explosions = {
		Smaller = false,
		Invisible = true,
		Destroy = false
	},
	Particles = {
		Invisible = true,
		Destroy = false
	},
	TextLabels = {
		LowerQuality = false,
		Invisible = true,
		Destroy = false
	},
	MeshParts = {
		LowerQuality = true,
		Invisible = false,
		NoTexture = false,
		NoMesh = false,
		Destroy = false
	},
	Other = {
		["FPS Cap"] = 30,
		["No Camera Effects"] = true,
		["No Clothes"] = true,
		["Low Water Graphics"] = true,
		["No Shadows"] = true,
		["Low Rendering"] = true,
		["Low Quality Parts"] = true,
		["Low Quality Models"] = true,
		["Reset Materials"] = true,
	}
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/Egoistsms/AOTr/refs/heads/main/BOOSTFPS.lua"))()
