local setmetatable = setmetatable
local table = table
local ipairs = ipairs

Hero = {}

local Hero = Hero

function Hero.Init()
	if nil == Hero.prefab then
		Hero.prefab = CS.UnityEngine.Resources.Load("Prefab/Hero")
	end

	local gameObject = CS.UnityEngine.GameObject.Instantiate(Hero.prefab)
	Hero.instance = CS.LuaComponent.Add(gameObject, Hero)
end

function Hero.GetInstance()
	return Hero.instance
end

function Hero.GetGameObject()
	if nil == Hero.instance then
		return nil
	else
		return Hero.instance.gameObject
	end
end

function Hero.GetTransform()
	if nil == Hero.instance then
		return nil
	else
		return Hero.instance.transform
	end
end

function Hero:New()
	self.__index = self
	return setmetatable(
		{
			speed = 30,
			rollMult = -45,
			pitchMult = 30,
			shieldLevel = 1,
			fire = {}
		},
		self
	)
end

function Hero:Awake(gameObject)
	self.gameObject = gameObject
	self.transform = gameObject.transform

	self.bounds = CS.Utils.CombineBoundsOfChildren(self.gameObject)
end

function Hero:Start()
	self:ClearWeapons()
	self.weapons[1]:SetType(CS.WeaponType.blaster)
end

function Hero:Update()
	local x = CS.UnityEngine.Input.GetAxis("Horizontal")
	local y = CS.UnityEngine.Input.GetAxis("Vertical")
	local pos = self.transform.position
	pos.x = pos.x + x * self.speed * CS.UnityEngine.Time.deltaTime
	pos.y = pos.y + y * self.speed * CS.UnityEngine.Time.deltaTime
	self.transform.position = pos

	self.bounds.center = pos

	local off = CS.Utils.ScreenBoundsCheck(self.bounds, CS.BoundsTest.onScreen)
	if off ~= CS.UnityEngine.Vector3.zero then
		pos = pos - off
		self.transform.position = pos
	end

	self.transform.rotation = CS.UnityEngine.Quaternion.Euler(y * self.pitchMult, x * self.rollMult, 0)

	if #self.fire > 0 then
		for _, func in ipairs(self.fire) do
			func()
		end
	end
end

function Hero:ChangeShieldLevel(level)
	if level ~= 1 and level ~= -1 then
		print("shield level error, level is " .. level)
		return
	end

	self.shieldLevel = self.shieldLevel + level
	self.shieldLevel = math.min(self.shieldLevel, 4)
	if self.shieldLevel < 0 then
		CS.UnityEngine.Object.Destroy(self.gameObject)
		SpaceShooting.GameOver()
	end
end

function Hero:OnTriggerEnter(_, other)
	local go = CS.Utils.FindTaggedParent(other.gameObject)
	if go ~= nil then
		if go == self.lastTriggerGo then
			return
		end

		self.lastTriggerGo = go
		if go.tag == "Enemy" then
			self:ChangeShieldLevel(-1)
			CS.UnityEngine.GameObject.Destroy(go)
		elseif go.tag == "PowerUp" then
			self:AbsorbPowerUp(go)
		end
	end
end

function Hero:OnDestroy()
	Hero.instance = nil
end

function Hero:ClearWeapons()
	if self.weapons == nil then
		self.weapons = Weapon.Init()
	end

	for _, value in ipairs(self.weapons) do
		value:SetType(CS.WeaponType.none)
	end
end

function Hero:AddFireListener(func)
	table.insert(self.fire, func)
end

function Hero:AbsorbPowerUp(go)
	local pu = CS.LuaComponent.Get(go, PowerUp)
	if pu.type == CS.WeaponType.shield then
		self:ChangeShieldLevel(1)
	elseif pu.type == self.weapons[1].type then
		local w = self:GetEmptyWeapon()
		if w ~= nil then
			w:SetType(pu.type)
		end
	else
		self:ClearWeapons()
		self.weapons[1]:SetType(pu.type)
	end

	ScoreUI.GetInstance():AddScore(pu.def.score)
	CS.UnityEngine.Object.Destroy(go)
end

function Hero:GetEmptyWeapon()
	for _, value in ipairs(self.weapons) do
		if value.type == CS.WeaponType.none then
			return value
		end
	end
	return nil
end
