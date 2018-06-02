# eiya
本仓库为[「弹幕游戏」东方永夜抄 Stage III.Rebuilt](https://www.bilibili.com/video/av393926)（以下简称`eiya`）的代码源文件，而相关图片素材由于是好友从《东方永夜抄》中抠出来的图，不便进行公开。

由于播放器更新，在2015年的时候已经无法正常进行游戏。本仓库的内容权当是怀旧向的存档，不会进行任何更新。发出来一方面是怀念一下当年（2012年）通宵与好友在“螺蛳壳里做道场”的日子，另一方面也希望B站能够在HTML5播放器中也能搞出这样的代码弹幕环境。

`eiya`包含两部分内容：
1. 游戏引擎`eiyaEngine`，位于`main_frame.as`中。任务是在B站的播放器中进行游戏图形渲染（而非使用播放器的弹幕元素，效率太低了）。
2. 资源转换工具`ResourceHelper`，可以进行图片素材，`eiyaScript`以及注入代码的转换，转换后的Base64串存放于`load_frame.as`，供游戏引擎调用。

## eiyaScript

`eiyaScript`是为`eiyaEngine`所使用的一个脚本，它定义了游戏中弹幕和发射器的运作方式。具体可参考“doc/eiyaScript 使用手册.txt”。转换工具会将`eiyaScript`转换成`eiyaEngine`可执行的指令串。

## 注入代码

当年的播放器存在可以从一个ByteArray中加载并执行任意SWF字节码的漏洞（当时普遍认为是特性，然而后来就封锁了，说明是漏洞）。因此理论上说，可以直接注入一个Flash游戏。不过从参与活动的角度出发，这样做并不合适，因此就用了这个漏洞注入了一些播放器并未实现的特性，比如`Vector`支持（位于src/CORE.as）和任意键位响应（位于src/KeyboardHelper.as)。

> 注入代码转换使用了`As3Eval`库(<http://eval.hurlant.com/>)，基于MPL发布。

> 任意键位响应部分代码是基于nekofs的代码修改，其源代码现已无法访问。
