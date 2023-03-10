local countdown = {}
countdown.__index = countdown

function countdown.new()
	local self = setmetatable({}, countdown)

	self._finishedEvent = Instance.new("BindableEvent")
	self.finished = self._finishedEvent.Event

	self._tickEvent = Instance.new("BindableEvent")
	self.tick = self._tickEvent.Event

	self._running = false
	self._startTime = nil
	self._duration = nil

	return self
end

function countdown:start(duration)
	if not self._running then
		local timerThread = coroutine.wrap(function()
			self._running = true
			self._duration = duration
			self._startTime = tick()
			self._previousTick = 0
			while self._running and tick() - self._startTime < duration do
				wait()
				if math.floor(tick() - self._startTime) > self._previousTick then
					self._previousTick = math.floor(tick() - self._startTime)
					self._tickEvent:Fire(self._previousTick)
				end
			end
			local completed = self._running
			self._running = false
			self._startTime = nil
			self._duration = nil
			self._finishedEvent:Fire(completed)
		end)
		timerThread()
	else
		warn("Warning: timer could not start again as it is already running.")
	end
end

function countdown:getTimeLeft()
	if self._running then
		local now = tick()
		local timeLeft = self._startTime + self._duration - now
		if timeLeft < 0 then
			timeLeft = 0
		end
		return timeLeft
	else
		warn("Warning: could not get remaining time, timer is not running.")
	end
end

function countdown:isRunning()
	return self._running
end

function countdown:stop()
	self._running = false
end

return countdown