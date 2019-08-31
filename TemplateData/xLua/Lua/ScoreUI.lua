local setmetatable = setmetatable
local tostring = tostring

ScoreUI = {}

local ScoreUI = ScoreUI

function ScoreUI.Init()
	if nil == ScoreUI.prefab then
		ScoreUI.prefab = CS.UnityEngine.Resources.Load("Prefab/UI")
	end

	local go = CS.UnityEngine.GameObject.Instantiate(ScoreUI.prefab)
	ScoreUI.instance = CS.LuaComponent.Add(go, ScoreUI)
end

function ScoreUI.GetInstance()
	return ScoreUI.instance
end

function ScoreUI.Release()
	if nil ~= ScoreUI.instance then
		CS.UnityEngine.Object.Destroy(ScoreUI.instance.gameObject)
		ScoreUI.instance = nil
	end
end

function ScoreUI:New()
	self.__index = self
	return setmetatable({score = 0}, self)
end

function ScoreUI:Awake(gameObject)
	self.gameObject = gameObject
	self.transform = gameObject.transform

	local canvas = CS.UnityEngine.GameObject.Find("Canvas")
	self.transform:SetParent(canvas.transform)
	self.transform.anchoredPosition = CS.UnityEngine.Vector2.zero

	local go = CS.UnityEngine.GameObject.Find("Text_Score")
	self.text = go:GetComponent(typeof(CS.UnityEngine.UI.Text))
end

function ScoreUI:AddScore(score)
	self.score = self.score + score
	self.text.text = tostring(self.score)
end
