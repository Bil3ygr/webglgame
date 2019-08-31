require "MainUI"
require "SpaceShooting"
require "Timer"
require "Paralleax"

function Awake()
    Main()
end

function Start()
end

function Update()
    TimerMgr.Loop()
    Paralleax.Loop()
end

function OnDestroy()
end

function CmpMetaTable(t1, t2)
    local t = getmetatable(t1)
    return t == t2
end

--主入口函数。从这里开始lua逻辑
function Main()
    print("logic start")
    MainUI.Init()
end

--场景切换通知
function OnLevelWasLoaded(level)
    collectgarbage("collect")
    if level == 1 then
        SpaceShooting.GameStart()
    end
end
