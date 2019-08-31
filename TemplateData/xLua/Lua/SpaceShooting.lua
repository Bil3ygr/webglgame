require "Manager"
require "Enemy"
require "Hero"
require "Weapon"
require "Projectile"
require "PowerUp"
require "Shield"
require "GameOverUI"
require "ScoreUI"

SpaceShooting = {}

local SpaceShooting = SpaceShooting

function SpaceShooting.GameStart()
	print("start spaceshooting")
	Manager.Init()
	Hero.Init()
	Paralleax.Init()
	ScoreUI.Init()
	Shield.Init()
end

function SpaceShooting.GameOver()
	local score = ScoreUI.GetInstance().score
	ScoreUI.Release()
	Manager:Release()
	Paralleax.Release()
	GameOverUI.Init()
	GameOverUI.GetInstance():SetScore(score)
end

function SpaceShooting.Restart()
	GameOverUI.Release()
	SpaceShooting.GameStart()
end
