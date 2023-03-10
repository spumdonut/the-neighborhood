local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Common = ReplicatedStorage:WaitForChild("Common")
local Guis = ReplicatedStorage:WaitForChild("Guis")

local Comm = require(Common.Comm)
local modifyNumber = require(Common.modifyNumber)
local imageTypes = require(Common.imageTypes)

local clientComm = Comm.ClientComm.new(ReplicatedStorage, false, "MainComm")
local valueChangedGuiEvent = clientComm:GetSignal("ValueChangedGuiEvent")

local TWEEN_TIME = 1
local DESTROY_TIME = 1.6
local FADE_TIME = 1.2
local FADE_INCREMENT = 0.1
local TRANSPARENCY_GOAL = 1

local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Linear)

local function onValueChangedGuiEvent(args)
	local character = args.character
	local amount = args.amount
	local isIncrement = args.isIncrement
	local imageType = args.imageType

	local foundGui = character.Head:FindFirstChild(imageType)
	if foundGui then
		foundGui:Destroy()
	end

    local characterBillboardGui = Guis.CharacterBillboardGui
    local guiClone = characterBillboardGui:Clone()
	guiClone.Name = imageType
    guiClone.Parent = character.Head

	local amountModified = modifyNumber(amount)
    local sign = isIncrement and "+" or "-"
    local text = sign .. amountModified

	local textLabel = guiClone.Frame.TextLabel
	textLabel.Text = text
	textLabel.TextColor3 = imageTypes[imageType].color
	local imageLabel = guiClone.Frame.ImageLabel
	imageLabel.Image = imageTypes[imageType].image

	local guiTweenGoal = {}
	guiTweenGoal.StudsOffset = Vector3.new(0, 2.8, 0)

	local tweenUp = TweenService:Create(guiClone, tweenInfo, guiTweenGoal)
    tweenUp:Play()

	for _, element in pairs(guiClone.Frame:GetChildren()) do
		task.delay(FADE_TIME, function()
			for transparency = 0, TRANSPARENCY_GOAL, FADE_INCREMENT do
				local uiGradient = element:FindFirstChild("UIGradient")
				if not uiGradient then
					return
				end

				local transparencySequence = NumberSequence.new(transparency)
				uiGradient.Transparency = transparencySequence
				wait()
			end
		end)
	end
	
    task.delay(DESTROY_TIME, function()
        guiClone:Destroy()
	end)
end

valueChangedGuiEvent:Connect(onValueChangedGuiEvent)