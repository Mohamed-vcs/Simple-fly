local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, 0, 0, 40)
toggleBtn.Text = "Fly: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)

local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Position = UDim2.new(0, 0, 0, 45)
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.Text = "Speed: 50"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1,1,1)

-- Slider Bar
local sliderBar = Instance.new("Frame", frame)
sliderBar.Position = UDim2.new(0.1, 0, 0, 80)
sliderBar.Size = UDim2.new(0.8, 0, 0, 10)
sliderBar.BackgroundColor3 = Color3.fromRGB(80,80,80)

-- Slider Knob
local sliderKnob = Instance.new("Frame", sliderBar)
sliderKnob.Size = UDim2.new(0, 10, 0, 20)
sliderKnob.Position = UDim2.new(0.5, -5, -0.5, 0)
sliderKnob.BackgroundColor3 = Color3.fromRGB(200,200,200)

-- Variables
local flying = false
local speed = 50
local maxSpeed = 100
local dragging = false

local bodyVelocity
local bodyGyro

local moveDir = Vector3.zero

-- Movement keys
UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then moveDir += Vector3.new(0,0,-1) end
	if input.KeyCode == Enum.KeyCode.S then moveDir += Vector3.new(0,0,1) end
	if input.KeyCode == Enum.KeyCode.A then moveDir += Vector3.new(-1,0,0) end
	if input.KeyCode == Enum.KeyCode.D then moveDir += Vector3.new(1,0,0) end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then moveDir -= Vector3.new(0,0,-1) end
	if input.KeyCode == Enum.KeyCode.S then moveDir -= Vector3.new(0,0,1) end
	if input.KeyCode == Enum.KeyCode.A then moveDir -= Vector3.new(-1,0,0) end
	if input.KeyCode == Enum.KeyCode.D then moveDir -= Vector3.new(1,0,0) end
end)

-- Toggle Fly
toggleBtn.MouseButton1Click:Connect(function()
	flying = not flying
	toggleBtn.Text = flying and "Fly: ON" or "Fly: OFF"
	
	if flying then
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
		bodyVelocity.Parent = humanoidRootPart
		
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
		bodyGyro.P = 1e4
		bodyGyro.Parent = humanoidRootPart
	else
		if bodyVelocity then bodyVelocity:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
	end
end)

-- Slider logic
local function updateSlider(inputX)
	local barX = sliderBar.AbsolutePosition.X
	local barWidth = sliderBar.AbsoluteSize.X
	
	local alpha = math.clamp((inputX - barX) / barWidth, 0, 1)
	sliderKnob.Position = UDim2.new(alpha, -5, -0.5, 0)
	
	speed = math.floor(alpha * maxSpeed)
	speedLabel.Text = "Speed: " .. speed
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

-- Fly loop
RunService.RenderStepped:Connect(function()
	if flying and bodyVelocity and bodyGyro then
		local cam = workspace.CurrentCamera
		local direction = (cam.CFrame:VectorToWorldSpace(moveDir))
		
		if moveDir.Magnitude > 0 then
			direction = direction.Unit
		else
			direction = Vector3.zero
		end
		
		bodyVelocity.Velocity = direction * speed
		bodyGyro.CFrame = cam.CFrame
	end
end)