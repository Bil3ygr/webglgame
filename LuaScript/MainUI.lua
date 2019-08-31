local setmetatable = setmetatable

MainUI = {}

local MainUI = MainUI

function MainUI.Init()
	MainUI.UIPrefab = CS.UnityEngine.Resources.Load("Prefab/MainUI")
	local go = CS.UnityEngine.GameObject.Instantiate(MainUI.UIPrefab)
	local ui = MainUI:GetInstance()
	ui:SetGameObject(go)
	ui:SetTransform(go.transform)
	ui:InitUI()
end

function MainUI:New()
	self.__index = self
	return setmetatable({}, self)
end

function MainUI:SetInstance(instance)
	self.mainUI = instance
end

function MainUI:GetInstance()
	if nil == self.mainUI then
		self.mainUI = self:New()
	end

	return self.mainUI
end

function MainUI:SetGameObject(go)
	self.gameObject = go
end

function MainUI:SetTransform(transform)
	self.transform = transform
end

function MainUI:InitUI()
	local canvas = CS.UnityEngine.GameObject.Find("Canvas")
	self.transform:SetParent(canvas.transform)
	self.transform.anchoredPosition = CS.UnityEngine.Vector2.zero

	local button = CS.UnityEngine.GameObject.Find("Button")
	local bt = button:GetComponent(typeof(CS.UnityEngine.UI.Button))
	bt.onClick:AddListener(
		function()
			CS.UnityEngine.SceneManagement.SceneManager.LoadScene("SpaceShooting")
		end
	)
end
