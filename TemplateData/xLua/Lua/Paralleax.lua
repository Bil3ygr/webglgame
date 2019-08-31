local setmetatable = setmetatable

Paralleax = {}

local Paralleax = Paralleax

function Paralleax.Init()
	Paralleax:GetInstance()
end

function Paralleax.Release()
	Paralleax.instance = nil
end

function Paralleax.Loop()
	if nil ~= Paralleax.instance then
		Paralleax.instance:Update()
	end
end

function Paralleax:New()
	self.__index = self
	return setmetatable(
		{
			scrollSpeed = -30,
			motionMult = 0.25
		},
		self
	)
end

function Paralleax:GetInstance()
	if self.instance == nil then
		self.instance = self:New()
		self.instance:Start()
	end

	return self.instance
end

function Paralleax:Start()
	local panels = CS.GlobalDefines.Instance:GetParalleaxPanels()
	self.panelTransforms = {}
	for i = 1, panels.Length do
		self.panelTransforms[i] = panels[i - 1].transform
	end
	self.panelHt = self.panelTransforms[1].localScale.y
	self.depth = self.panelTransforms[1].position.z
	self.panelTransforms[1].position = CS.UnityEngine.Vector3(0, 0, self.depth)
	self.panelTransforms[2].position = CS.UnityEngine.Vector3(0, self.panelHt, self.depth)
end

function Paralleax:Update()
	local tX = 0
	local tY = CS.UnityEngine.Time.time * self.scrollSpeed % self.panelHt + (self.panelHt * 0.5)
	if nil ~= Hero.GetGameObject() then
		tX = Hero.GetTransform().position.x * self.motionMult
	end

	self.panelTransforms[1].position = CS.UnityEngine.Vector3(tX, tY, self.depth)
	if tY >= 0 then
		self.panelTransforms[2].position = CS.UnityEngine.Vector3(tX, tY - self.panelHt, self.depth)
	else
		self.panelTransforms[2].position = CS.UnityEngine.Vector3(tX, tY + self.panelHt, self.depth)
	end
end
