local math = math
local setmetatable = setmetatable

Manager = {}

local Manager = Manager

function Manager.Init()
	Manager:GetInstance():Start()
end

function Manager:Release()
	if self.manager ~= nil then
		self.manager.timer:Release()
		self.manager = nil
	end
end

function Manager.EnemyDestroy(enemy)
	local r = math.random()
	if r < enemy.powerUpDropChange then
		local frequency = CS.GlobalDefines.Instance:GetPowerUpFrequency()
		local idx = CS.UnityEngine.Random.Range(0, frequency.Length)
		local wpt = frequency[math.floor(idx)]

		local pu = PowerUp.CreatePowerUpBox()
		pu:SetType(wpt)
		pu.transform.position = enemy.transform.position
	end

	ScoreUI.GetInstance():AddScore(enemy.score)
end

function Manager:New(o)
	self.__index = self
	return setmetatable({}, self)
end

function Manager:GetInstance()
	if self.manager == nil then
		self.manager = self:New()
	end

	return self.manager
end

function Manager:Start()
	self.timer =
		Timer.New(
		function()
			self:SpawnEnemy()
		end,
		2,
		-1
	)
	self.timer:Start()
end

function Manager:SpawnEnemy()
	Enemy.CreateEnemy()
end
