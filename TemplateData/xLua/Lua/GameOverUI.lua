local setmetatable = setmetatable
local tostring = tostring

GameOverUI = {}

local GameOverUI = GameOverUI

function GameOverUI.Init()
	if nil == GameOverUI.prefab then
		GameOverUI.prefab = CS.UnityEngine.Resources.Load("Prefab/GameOver")
	end
	local go = CS.UnityEngine.GameObject.Instantiate(GameOverUI.prefab)
	GameOverUI.instance = CS.LuaComponent.Add(go, GameOverUI)
end

function GameOverUI.GetInstance()
	return GameOverUI.instance
end

function GameOverUI.Release()
	if nil ~= GameOverUI.instance then
		CS.UnityEngine.Object.Destroy(GameOverUI.instance.gameObject)
		GameOverUI.instance = nil
	end
end

GameOverUI = {}

function GameOverUI:New()
	self.__index = self
	return setmetatable({}, self)
end

function GameOverUI:Awake(gameObject)
	self.gameObject = gameObject
	self.transform = gameObject.transform

	local canvas = CS.UnityEngine.GameObject.Find("Canvas")
	self.transform:SetParent(canvas.transform)
	self.transform.anchoredPosition = CS.UnityEngine.Vector2.zero

	local button = CS.UnityEngine.GameObject.Find("Button")
	local bt = button:GetComponent(typeof(CS.UnityEngine.UI.Button))
	bt.onClick:AddListener(
		function()
			SpaceShooting.Restart()
		end
	)
end

function GameOverUI:SetScore(score)
	local go = CS.UnityEngine.GameObject.Find("Text_Score")
	local text = go:GetComponent(typeof(CS.UnityEngine.UI.Text))
	text.text = tostring(score)
end
