local setmetatable = setmetatable
local math = math

Enemy = {}
EnemyPrefab = {}

local Enemy = Enemy
local EnemyPrefab = EnemyPrefab

function Enemy.CreateEnemy()
	-- load prefab
	if #EnemyPrefab == 0 then
		-- for i = 1, 5 do
		-- 	EnemyPrefab[i] = CS.UnityEngine.Resources.Load("Prefab/Enemy_" .. i)
		EnemyPrefab[1] = CS.UnityEngine.Resources.Load("Prefab/Enemy_1")
	end

	local enemyObject = CS.UnityEngine.GameObject.Instantiate(EnemyPrefab[1])
	CS.LuaComponent.Add(enemyObject, Enemy)
end

function Enemy:New()
	self.__index = self
	return setmetatable(
		{
			originalColors = {},
			speed = 10,
			remainingDamageFrames = 0,
			showDamageForFrames = 2,
			enemySpawnPadding = 1.5,
			health = 10,
			powerUpDropChange = 0.5,
			score = 10
		},
		self
	)
end

function Enemy:Awake(gameObject)
	self.gameObject = gameObject
	self.transform = gameObject.transform
	-- set pos
	local pos = CS.UnityEngine.Vector3.zero
	local xMin = math.floor(CS.Utils.camBounds.min.x + self.enemySpawnPadding + 0.5)
	local xMax = math.floor(CS.Utils.camBounds.max.x - self.enemySpawnPadding + 1)
	pos.x = math.random(xMin, xMax)
	pos.y = CS.Utils.camBounds.max.y + self.enemySpawnPadding
	self.transform.position = pos

	self.materials = CS.Utils.GetAllMaterials(gameObject)
	for i = 1, self.materials.Length do
		self.originalColors[i] = self.materials[i - 1].color
	end

	self:CheckOffScreen()
	self.timer =
		Timer.New(
		function()
			self:CheckOffScreen()
		end,
		1,
		-1,
		true
	)

	self.timer:Start()
end

function Enemy:Update()
	self:Move()
	if self.remainingDamageFrames > 0 then
		self.remainingDamageFrames = self.remainingDamageFrames - 1
		if self.remainingDamageFrames == 0 then
			self:HideDamage()
		end
	end
end

function Enemy:Move()
	local tempPos = self.transform.position
	tempPos.y = tempPos.y - self.speed * CS.UnityEngine.Time.deltaTime
	self.transform.position = tempPos
end

function Enemy:OnCollisionEnter(_, collision)
	local go = collision.gameObject
	if go.tag == "ProjectileHero" then
		self.bounds.center = self.transform.position + self.boundsCenterOffset
		if
			self.bounds.extents == CS.UnityEngine.Vector3.zero or
				CS.Utils.ScreenBoundsCheck(self.bounds, CS.BoundsTest.offScreen) ~= CS.UnityEngine.Vector3.zero
		 then
			Projectile.CycleProjectileGameObject(go)
		else
			self:ShowDamage()
			self.health = self.health - 2
			if self.health <= 0 then
				Manager.EnemyDestroy(self)
				CS.UnityEngine.Object.Destroy(self.gameObject)
			end

			Projectile.CycleProjectileGameObject(go)
		end
	end
end

function Enemy:ShowDamage()
	for i = 1, self.materials.Length do
		self.materials[i - 1].color = CS.UnityEngine.Color.red
	end

	self.remainingDamageFrames = self.showDamageForFrames
end

function Enemy:HideDamage()
	for i = 1, self.materials.Length do
		self.materials[i - 1].color = self.originalColors[i]
	end
end

function Enemy:CheckOffScreen()
	if self.bounds == nil then
		self.bounds = CS.Utils.CombineBoundsOfChildren(self.gameObject)
		self.boundsCenterOffset = self.bounds.center - self.transform.position
	end

	self.bounds.center = self.transform.position + self.boundsCenterOffset
	local off = CS.Utils.ScreenBoundsCheck(self.bounds, CS.BoundsTest.offScreen)
	if off ~= CS.UnityEngine.Vector3.zero then
		if off.y < 0 then
			CS.UnityEngine.Object.Destroy(self.gameObject)
		end
	end
end

function Enemy:OnDestroy()
	self.timer:Release()
end
