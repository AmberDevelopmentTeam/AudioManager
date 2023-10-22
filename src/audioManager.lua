local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local MarketplaceService = game:GetService("MarketplaceService")

local properties = {}
local audios = {}

if script:FindFirstChild("audioManager") then
	script.audioManager.Parent = SoundService
end

local folder = SoundService:FindFirstChild("audioManager")
local function create(soundId: number)
	local soundName = MarketplaceService:GetProductInfo(tostring(soundId):match("%d+")).Name
	assert(typeof(soundName) == "string", "This audio does not exist")

	local audio = folder:FindFirstChild(soundName) or Instance.new("Sound")
	audios[soundId] = audio
	audio.Name = soundName
	audio.Parent = folder
	
	return audio
end

function properties:Update()
	local audio: Sound = create(self.soundId)
	audio.SoundId = "rbxassetid://" .. tostring(self.soundId)
	audio.Volume = self.volume
	audio.SoundGroup = self.soundGroup
	
	ContentProvider:PreloadAsync({audio})
end

function properties:GetAudio()
	local audio: Sound = audios[self.soundId]
	assert(audios[self.soundId], 'Please use "your_variable:Update() before getting the audio')
	return audio
end

function properties:Play()
	task.spawn(function()
		local audio: Sound = audios[self.soundId]
		assert(audios[self.soundId], 'Please use "your_variable:Update() before playing the audio')
		audio.TimePosition = self.startPosition
		audio:Play()
		
		if self.finishPosition < audio.TimeLength then
			task.wait(self.finishPosition)
			audio:Stop()
		end
	end)
end

function properties:Stop()
	task.spawn(function()
		local audio: Sound = audios[self.soundId]
		assert(audios[self.soundId], 'Please use "your_variable:Update() before stopping the audio')
		audio:Stop()
	end)
end

function properties:Pause()
	task.spawn(function()
		local audio: Sound = audios[self.soundId]
		assert(audios[self.soundId], 'Please use "your_variable:Update() before pausing the audio')
		local audioPosition = audio.TimePosition

		audio:Stop()
		audio.TimePosition = audioPosition
	end)
end

function properties:Continue()
	task.spawn(function()
		local audio: Sound = audios[self.soundId]
		assert(audios[self.soundId], 'Please use "your_variable:Update() before pausing the audio')
		audio:Play()
		
		if self.finishPosition < audio.TimeLength then
			task.wait(self.finishPosition - audio.TimePosition)
			audio:Stop()
		end
	end)
end

function properties:Destroy()
	task.spawn(function()
		local audio: Sound = audios[self.soundId]
		assert(audios[self.soundId], 'Please use "your_variable:Update() before destroying the audio')
		audios[self.soundId] = nil
		audio:Destroy()
		
	end)
end

return{
	new = function()
		local self = {}
		setmetatable(self, {__index = properties})

		self.soundId = 0
		self.volume = 1
		self.startPosition = 0
		self.finishPosition = math.huge
		self.soundGroup = nil

		return self
	end
}
