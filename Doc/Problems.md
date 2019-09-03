# 使用xLua开发WebGL时遇到的问题

## Editor下使用AssetBundle时shader不能正常显示，为粉色

这里可能是在PC平台下使用了非PC平台的AB包所致。

可尝试在Editor模式下使用PC平台的AB包，即使用 `BuildTarget.Standalonexxx` 参数打AB包，
在真正构建时再尝试使用对应平台的参数进行打包。

----

## Build构建报错

构建时失败，报错提示 `Failed running python ...` 等，尝试以下两步检查

1. 检查是否拷贝 `WebGLPlugins` 目录到项目
2. 检查 `Plugins\WebGL\xlua_webgl.cpp` 文件，文件配置的相对路径是否正确指向 `WebGLPlugins` 目录

确认无误后再尝试进行构建。

> 建议：尽量直接按官方路径复制到项目中，否则需要配置很多路径。

----

## 运行时控制台提示 `LuaException: invalid arguments to ...`

**`il2cpp`** 会对代码进行裁剪，如果 **`C#`** 没有访问则不会编译到发布包，
建议在lua层使用到的 ``CS.xxx`` 先在 **`C#``** 进行引用。

----

## 运行时控制台提示 `WARNING: Shader Unsupported: 'Standard' - Pass 'META' has no vertex shader`

```
暂未解决
```
