local setmetatable = setmetatable

Weapon = {}
WeaponDefines = {}

local Weapon = Weapon
local WeaponDefines = WeaponDefines

function Weapon.Init()
	local wpds = CS.GlobalDefines.Instance:GetWeaponDefinitions()
	for i = 1, wpds.Length do
		local wpd = wpds[i - 1]
		WeaponDefines[wpds[i - 1].type] = wpds[i - 1]
	end

	local weaponObjects = CS.HeroDefines.Instance:GetWeapons()
	local weapons = {}
	for i = 1, weaponObjects.Length do
		weapons[i] = CS.LuaComponent.Add(weaponObjects[i - 1], Weapon)
	end
	return weapons
end

function Weapon:New()
	self.__index = self
	return setmetatable(
		{
			type = CS.WeaponType.none,
			lastShot = 0
		},
		self
	)
end

function Weapon:Awake(gameObject)
	self.gameObject = gameObject
	self.transform = gameObject.transform
	local collar = self.transform:Find("Collar").gameObject
	self.collarMaterial = collar:GetComponent(typeof(CS.UnityEngine.Renderer)).material
	self.collarTransform = collar.transform
end

function Weapon:Start()
	self:SetType(self.type)

	if self.projectile_anchor == nil then
		local go = CS.UnityEngine.GameObject("_Projectile_Anchor")
		self.projectile_anchor = go.transform
	end

	local parentGO = self.transform.parent.gameObject
	if parentGO.tag == "Hero" then
		Hero.GetInstance():AddFireListener(
			function()
				self:Fire()
			end
		)
	end
end

function Weapon:SetType(type)
	self.type = type
	if type == CS.WeaponType.none then
		self.gameObject:SetActive(false)
		return
	else
		self.gameObject:SetActive(true)
	end

	self.def = WeaponDefines[type]
	self.collarMaterial.color = self.def.color
	self.lastShot = 0
end

function Weapon:Fire()
	if not self.gameObject.activeInHierarchy then
		return
	end

	if CS.UnityEngine.Time.time - self.lastShot < self.def.delayBetweenShots then
		return
	end

	if self.type == CS.WeaponType.blaster then
		local p = self:MakeProjectile()
		p.gameObject:GetComponent(typeof(CS.UnityEngine.Rigidbody)).velocity = CS.UnityEngine.Vector3.up * self.def.velocity
		p.material.color = self.def.projectileColor
	elseif self.type == CS.WeaponType.spread then
		local p = self:MakeProjectile()
		p.gameObject:GetComponent(typeof(CS.UnityEngine.Rigidbody)).velocity = CS.UnityEngine.Vector3.up * self.def.velocity
		p.material.color = self.def.projectileColor
		p = self:MakeProjectile()
		p.gameObject:GetComponent(typeof(CS.UnityEngine.Rigidbody)).velocity =
			CS.UnityEngine.Vector3(0.2, 0.9, 0) * self.def.velocity
		p.material.color = self.def.projectileColor
		p = self:MakeProjectile()
		p.gameObject:GetComponent(typeof(CS.UnityEngine.Rigidbody)).velocity =
			CS.UnityEngine.Vector3(-0.2, 0.9, 0) * self.def.velocity
		p.material.color = self.def.projectileColor
	end
end

function Weapon:MakeProjectile()
	local p = Projectile.GetFreeProjectile()
	p.transform.position = self.collarTransform.position
	p.transform.parent = self.projectile_anchor

	self.lastShot = CS.UnityEngine.Time.time
	return p
end
