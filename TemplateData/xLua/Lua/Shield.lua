Shield = {}

local Shield = Shield

function Shield.Init()
	CS.LuaComponent.Add(CS.HeroDefines.Instance:GetShield(), Shield)
end

function Shield:New()
	self.__index = self
	return setmetatable(
		{
			rotate = 0.1,
			currentLevel = 0
		},
		self
	)
end

function Shield:Awake(gameObject)
	self.gameObject = gameObject
	self.transform = gameObject.transform
end

function Shield:Start()
end

function Shield:Update()
	local lv = Hero.GetInstance().shieldLevel
	if self.currentLevel ~= lv then
		self.currentLevel = lv
		local renderer = self.gameObject:GetComponent(typeof(CS.UnityEngine.Renderer))
		renderer.material.mainTextureOffset = CS.UnityEngine.Vector2(0.2 * self.currentLevel, 0)
	end
	local rz = (self.rotate * CS.UnityEngine.Time.time * 360) % 360
	self.transform.rotation = CS.UnityEngine.Quaternion.Euler(0, 0, rz)
end

function Shield:OnDestroy()
end
