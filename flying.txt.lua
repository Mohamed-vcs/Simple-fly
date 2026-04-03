local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FlyUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 160)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local gradient = Instance.new("UIGradient", frame)

-- Minimize Button
local minimize = Instance.new("TextButton", frame)
minimize.Size = UDim2.new(0, 25, 0, 25)
minimize.Position = UDim2.new(1, -30, 0, 5)
minimize.Text = "-"
minimize.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", minimize)

-- Toggle Fly
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -20, 0, 40)
toggle.Position = UDim2.new(0, 10, 0, 30)
toggle.Text = "Fly: OFF"
toggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", toggle)

-- Speed Label
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Position = UDim2.new(0, 10, 0, 80)
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Text = "Speed: 50"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1

-- Slider
local sliderBar = Instance.new("Frame", frame)
sliderBar.Position = UDim2.new(0, 10, 0, 110)
sliderBar.Size = UDim2.new(1, -20, 0, 12)
sliderBar.BackgroundColor3 = Color3.fromRGB(50,50,70)
Instance.new("UICorner", sliderBar)

local fill = Instance.new("Frame", sliderBar)
fill.Size = UDim2.new(0.5, 0, 1, 0)
Instance.new("UICorner", fill)

local knob = Instance.new("Frame", sliderBar)
knob.Size = UDim2.new(0, 16, 0, 16)
knob.Position = UDim2.new(0.5, -8, 0.5, -8)
knob.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", knob)

-- Variables
local flying = false
local targetSpeed = 50
local currentSpeed = 0
local maxSpeed = 100
local accel = 2

local dragging = false
local minimized = false

local moveDir = Vector3.zero
local bodyVelocity
local bodyGyro

-- Movement
UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then moveDir += Vector3.new(0,0,-1) end
	if input.KeyCode == Enum.KeyCode.S then moveDir += Vector3.new(0,0,1) end
	if input.KeyCode == Enum.KeyCode.A then moveDir += Vector3.new(-1,0,0) end
	if input.KeyCode == Enum.KeyCode.D then moveDir += Vector3.new(1,0,0) end
	
	-- Toggle UI with F
	if input.KeyCode == Enum.KeyCode.F then
		gui.Enabled = not gui.Enabled
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then moveDir -= Vector3.new(0,0,-1) end
	if input.KeyCode == Enum.KeyCode.S then moveDir -= Vector3.new(0,0,1) end
	if input.KeyCode == Enum.KeyCode.A then moveDir -= Vector3.new(-1,0,0) end
	if input.KeyCode == Enum.KeyCode.D then moveDir -= Vector3.new(1,0,0) end
end)

-- Minimize logic
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	
	if minimized then
		frame.Size = UDim2.new(0, 60, 0, 60)
		toggle.Visible = false
		speedLabel.Visible = false
		sliderBar.Visible = false
		minimize.Text = "+"
	else
		frame.Size = UDim2.new(0, 240, 0, 160)
		toggle.Visible = true
		speedLabel.Visible = true
		sliderBar.Visible = true
		minimize.Text = "-"
	end
end)

-- Fly Toggle
toggle.MouseButton1Click:Connect(function()
	flying = not flying
	
	if flying then
		toggle.Text = "Fly: ON"
		
		-- HARD FREEZE
		humanoid.PlatformStand = true
		
		for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
			track:Stop()
		end
		
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
		bodyVelocity.Parent = humanoidRootPart
		
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
		bodyGyro.P = 1e4
		bodyGyro.Parent = humanoidRootPart
		
	else
		toggle.Text = "Fly: OFF"
		
		humanoid.PlatformStand = false
		
		if bodyVelocity then bodyVelocity:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
		
		currentSpeed = 0
	end
end)

-- Slider
local function updateSlider(x)
	local barX = sliderBar.AbsolutePosition.X
	local width = sliderBar.AbsoluteSize.X
	
	local alpha = math.clamp((x - barX)/width, 0, 1)
	
	fill.Size = UDim2.new(alpha, 0, 1, 0)
	knob.Position = UDim2.new(alpha, -8, 0.5, -8)
	
	targetSpeed = math.floor(alpha * maxSpeed)
	speedLabel.Text = "Speed: " .. targetSpeed
end

sliderBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		updateSlider(input.Position.X)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		updateSlider(input.Position.X)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- RGB + Smooth Fly
local hue = 0

RunService.RenderStepped:Connect(function(dt)
	hue = (hue + dt * 0.2) % 1
	
	local c1 = Color3.fromHSV(hue,1,1)
	local c2 = Color3.fromHSV((hue+0.2)%1,1,1)
	
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0,c1),
		ColorSequenceKeypoint.new(1,c2)
	}
	
	toggle.BackgroundColor3 = c1
	fill.BackgroundColor3 = c2
	
	if flying and bodyVelocity and bodyGyro then
		local cam = workspace.CurrentCamera
		
		currentSpeed = currentSpeed + (targetSpeed - currentSpeed) * math.clamp(accel * dt, 0, 1)
		
		local direction = Vector3.zero
		if moveDir.Magnitude > 0 then
			direction = cam.CFrame:VectorToWorldSpace(moveDir).Unit
		end
		
		bodyVelocity.Velocity = direction * currentSpeed
		bodyGyro.CFrame = cam.CFrame
	end
end)
