local setmetatable = setmetatable
local table = table
local ipairs = ipairs

Timer = {}

local Timer = Timer
local mt = {__index = Timer}

function Timer.New(func, duration, loop)
	loop = loop or 1
	local timer = setmetatable({func = func, duration = duration, time = duration, loop = loop, running = false}, mt)
	TimerMgr.AddTimer(timer)
	return timer
end

function Timer:Start()
	self.running = true
end

function Timer:Stop()
	self.running = false
end

function Timer:Update()
	if not self.running then
		return
	end

	self.time = self.time - CS.UnityEngine.Time.unscaledDeltaTime

	if self.time <= 0 then
		self.func()

		if self.loop > 0 then
			self.loop = self.loop - 1
			self.time = self.time + self.duration
		elseif self.loop == 0 then
			self:Stop()
		elseif self.loop < 0 then
			self.time = self.time + self.duration
		end
	end
end

function Timer:Release()
	self:Stop()
	TimerMgr.RemoveTimer(self)
end

TimerMgr = {}

local TimerMgr = TimerMgr

function TimerMgr.Loop()
	local mgr = TimerMgr:GetInstance()
	for _, value in ipairs(mgr.timerList) do
		if value.running then
			value:Update()
		end
	end
end

function TimerMgr.AddTimer(timer)
	local mgr = TimerMgr:GetInstance()
	table.insert(mgr.timerList, timer)
end

function TimerMgr.RemoveTimer(timer)
	local mgr = TimerMgr:GetInstance()
	for key, value in ipairs(mgr.timerList) do
		if value == timer then
			table.remove(mgr.timerList, key)
			break
		end
	end
end

function TimerMgr:New()
	self.__index = self
	return setmetatable({timerList = {}}, self)
end

function TimerMgr:GetInstance()
	if nil == self.mgr then
		self.mgr = self:New()
	end

	return self.mgr
end

function TimerMgr:Release()
	if nil ~= self.mgr then
		self.mgr:StopAllTimer()
		self.mgr = nil
	end
end

function TimerMgr:StopAllTimer()
	for _, timer in ipairs(self.timerList) do
		timer:Stop()
	end
end
