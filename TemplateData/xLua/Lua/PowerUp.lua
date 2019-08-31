local setmetatable = setmetatable
local math = math

PowerUp = {}

local PowerUp = PowerUp

function PowerUp.CreatePowerUpBox()
	if PowerUp.prefab == nil then
		PowerUp.prefab = CS.UnityEngine.Resources.Load("Prefab/PowerUp")
	end

	local gameObject = CS.UnityEngine.GameObject.Instantiate(PowerUp.prefab)
	return CS.LuaComponent.Add(gameObject, PowerUp)
end

function PowerUp:New()
	self.__index = self
	return setmetatable(
		{
			rotMinMax = CS.UnityEngine.Vector2(15, 90),
			driftMinMax = CS.UnityEngine.Vector2(25, 200), -- lua的random要求整数，随机后再除100
			lifeTime = 6,
			fadeTime = 4
		},
		self
	)
end

function PowerUp:Awake(gameObject)
	self.gameObject = gameObject
	self.transform = gameObject.transform
	self.cube = self.transform:Find("Cube").gameObject
	self.cubeTransform = self.cube.transform
	self.cubeBounds = self.cube:GetComponent(typeof(CS.UnityEngine.Collider)).bounds
	self.cubeMaterial = self.cube:GetComponent(typeof(CS.UnityEngine.Renderer)).material
	self.letter = gameObject:GetComponent(typeof(CS.UnityEngine.TextMesh))
	self.transform.rotation = CS.UnityEngine.Quaternion.identity

	local vel = CS.UnityEngine.Random.onUnitSphere
	vel.z = 0
	vel = vel * math.random(self.driftMinMax.x, self.driftMinMax.y) / 100
	self.gameObject:GetComponent(typeof(CS.UnityEngine.Rigidbody)).velocity = vel
	self.rotPerSecond =
		CS.UnityEngine.Vector3(
		math.random(self.rotMinMax.x, self.rotMinMax.y),
		math.random(self.rotMinMax.x, self.rotMinMax.y),
		math.random(self.rotMinMax.x, self.rotMinMax.y)
	)
	self.birthTime = CS.UnityEngine.Time.time

	self.timer =
		Timer.New(
		function()
			self:CheckOffScreen()
		end,
		2,
		-1,
		true
	)
	self.timer:Start()
end

function PowerUp:Update()
	self.cubeTransform.rotation = CS.UnityEngine.Quaternion.Euler(self.rotPerSecond * CS.UnityEngine.Time.time)
	local u = (CS.UnityEngine.Time.time - self.birthTime) / self.lifeTime
	if u >= 1 then
		CS.UnityEngine.Object.Destroy(self.gameObject)
		return
	end

	if u > 0 then
		local c = self.cubeMaterial.color
		c.a = 1 - u
		self.cubeMaterial.color = c
		c = self.letter.color
		c.a = 1 - (u * 0.5)
		self.letter.color = c
	end
end

function PowerUp:SetType(type)
	self.type = type
	self.def = WeaponDefines[type]
	self.cubeMaterial.color = self.def.color
	self.letter.text = self.def.letter
end

function PowerUp:CheckOffScreen()
	if CS.Utils.ScreenBoundsCheck(self.cubeBounds, CS.BoundsTest.offScreen) ~= CS.UnityEngine.Vector3.zero then
		CS.UnityEngine.Object.Destroy(self.gameObject)
	end
end

function PowerUp:OnDestroy()
	self.timer:Release()
end
