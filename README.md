# zhikao-harmonyos

知考公考学习 App 客户端（HarmonyOS NEXT，ArkTS + ArkUI）。

详见《公考常识与成语学习App项目开发任务书》v1.4 与《任务清单》。

## 环境要求

- DevEco Studio 6.1.1（`D:\DevEcoStudio\DevEco Studio`）
- SDK：compatibleSdkVersion 6.1.1(24)（见 `build-profile.json5`）
- 后端服务已启动（默认 `http://127.0.0.1:8080`，见 zhikao-server README）

## 构建

```powershell
# Windows 命令行构建（无需打开 IDE）
$env:DEVECO_SDK_HOME = "D:\DevEcoStudio\DevEco Studio\sdk"
& "D:\DevEcoStudio\DevEco Studio\tools\node\node.exe" `
  "D:\DevEcoStudio\DevEco Studio\tools\hvigor\bin\hvigorw.js" `
  --mode module -p product=default assembleHap --no-daemon
# 成功标志：BUILD SUCCESSFUL（仅签名警告属正常，真机签名见下）
```

真机运行/签名：在 DevEco Studio 中通过 File → Project Structure → Signing Configs 配置自动签名（需华为账号与真机），再 Run 到设备。

## 功能模块

- 认证：注册 / 登录 / 游客 / Token 自动刷新 / 登出 / 注销（用户协议弹窗）
- 首页：学习概览、推荐（常识 3 + 成语 3）、每日任务
- 常识与成语：分类浏览、列表、详情（含相关真题）、收藏、标记已掌握
- 练习：按类型组卷、答题判分、结果页、错题本（实时题目内容）
- 复习：今日待复习、复习会话（艾宾浩斯状态机）、掌握度
- 统计：学习时长/进度、学习记录
- 我的：设置（主题、字体、通知、关于）

## 目录结构

```
entry/src/main/ets/
├── pages/          # @Entry 页面（Index 导航容器 + 各业务页）
├── components/     # 通用组件（EmptyView / LoadingView / ErrorView）
├── service/        # HttpClient / TokenService / RouterManager / 各业务 Service
├── repository/     # 数据仓库（知识/成语/练习/复习/统计）
├── store/          # AppStore
├── constants/      # 路由、HTTP、主题常量
└── types/          # ArkTS 显式参数类型
entry/src/main/resources/base/profile/main_pages.json  # 页面注册
```

## 接口约定

- 前缀 `/api/v1`（用户端）、`/admin`（管理端）
- 请求响应统一 `{code, message, data}`；错误码见任务书 6.1 与 zhikao-server README
- 网络异常统一映射 5000 并提示；401/过期自动刷新 Token 后重放
