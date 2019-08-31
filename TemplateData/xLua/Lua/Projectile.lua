local setmetatable = setmetatable

Projectile = {}
ProjectilePool = {}

local Projectile = Projectile
local ProjectilePool = ProjectilePool

function Projectile.GetFreeProjectile()
	if Projectile.prefab == nil then
		Projectile.prefab = CS.UnityEngine.Resources.Load("Prefab/ProjectileHero")
	end

	if #ProjectilePool ~= 0 then
		local p = ProjectilePool[#ProjectilePool]
		ProjectilePool[#ProjectilePool] = nil
		if p == nil then
			return Projectile.CreateProjectile()
		end
		p:Reset()
		return p
	else
		return Projectile.CreateProjectile()
	end
end

function Projectile.CreateProjectile()
	local go = CS.UnityEngine.GameObject.Instantiate(Projectile.prefab)
	return CS.LuaComponent.Add(go, Projectile)
end

function Projectile.CycleProjectile(p)
	p:Cycle()
	ProjectilePool[#ProjectilePool + 1] = p
end

function Projectile.CycleProjectileGameObject(go)
	local p = CS.LuaComponent.Get(go, Projectile)
	if p ~= nil then
		Projectile.CycleProjectile(p)
	else
		CS.UnityEngine.Object.Destroy(go)
	end
end

function Projectile:New()
	self.__index = self
	return setmetatable({}, self)
end

function Projectile:Awake(gameObject)
	self.gameObject = gameObject
	self.transform = gameObject.transform
	self.collider = gameObject:GetComponent(typeof(CS.UnityEngine.Collider))
	self.material = gameObject:GetComponent(typeof(CS.UnityEngine.Renderer)).material
	self.timer =
		Timer.New(
		function()
			self:CheckOffScreen()
		end,
		2,
		-1
	)
	self.timer:Start()
end

function Projectile:Update()
end

function Projectile:OnDestroy()
	self.timer:Release()
end

function Projectile:SetType(type)
end

function Projectile:CheckOffScreen()
	if CS.Utils.ScreenBoundsCheck(self.collider.bounds, CS.BoundsTest.offScreen) ~= CS.UnityEngine.Vector3.zero then
		Projectile.CycleProjectile(self)
	end
end

function Projectile:Reset()
	self.gameObject:SetActive(true)
	self.timer:Start()
end

function Projectile:Cycle()
	self.gameObject:SetActive(false)
	self.transform.parent = nil
	self.timer:Stop()
end
