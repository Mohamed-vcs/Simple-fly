local UserInterface = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local StartButton = Instance.new("TextButton")
local StopButton = Instance.new("TextButton")
local SpeedSlider = Instance.new("Slider")
local StatusIndicator = Instance.new("TextLabel")

local User = game.Players.LocalPlayer

UserInterface.Name = "FlyUI"
UserInterface.Parent = User:WaitForChild("PlayerGui")

Frame.Parent = UserInterface
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.Size = UDim2.new(0, 300, 0, 200)

StartButton.Parent = Frame
StartButton.Size = UDim2.new(0, 100, 0, 50)
StartButton.Position = UDim2.new(0.1, 0, 0.1, 0)
StartButton.Text = "Start"

StopButton.Parent = Frame
StopButton.Size = UDim2.new(0, 100, 0, 50)
StopButton.Position = UDim2.new(0.1, 0, 0.3, 0)
StopButton.Text = "Stop"

SpeedSlider.Parent = Frame
SpeedSlider.Size = UDim2.new(0, 200, 0, 50)
SpeedSlider.Position = UDim2.new(0.1, 0, 0.5, 0)
SpeedSlider.Text = "Speed"

StatusIndicator.Parent = Frame
StatusIndicator.Size = UDim2.new(0, 200, 0, 50)
StatusIndicator.Position = UDim2.new(0.1, 0, 0.7, 0)
StatusIndicator.Text = "Status: Stopped"

local flying = false
local speed = 50

SpeedSlider.Changed:Connect(function()
    speed = SpeedSlider.Value
end)

StartButton.MouseButton1Click:Connect(function()
    flying = true
    StatusIndicator.Text = "Status: Flying"
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, speed, 0)
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Parent = User.Character.HumanoidRootPart
end)

StopButton.MouseButton1Click:Connect(function()
    flying = false
    StatusIndicator.Text = "Status: Stopped"
    User.Character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity"):Destroy()
end)