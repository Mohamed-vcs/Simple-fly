local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local flying = false
local speed = 50

local function fly()
    if flying then return end
    flying = true
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, speed, 0)
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Parent = character.HumanoidRootPart

    while flying do
        bodyVelocity.Velocity = Vector3.new(0, speed, 0)
        wait(0.1)
    end
    bodyVelocity:Destroy()
end

local function stopFlying()
    flying = false
end

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Space then
            fly()
        elseif input.KeyCode == Enum.KeyCode.B then
            stopFlying()
        end
    end
end)