# 知考 HarmonyOS 公考学习 App 项目开发任务书

> 版本：v1.4（冻结版）
> 更新日期：2026-08-16
> 产品名称：知考
> 英文标识：Zhikao
> 项目代号：zhikao
> 仓库规划：`zhikao-harmonyos`（客户端）/ `zhikao-server`（后端）/ `zhikao-admin`（管理后台）

---

## 修订记录

| 版本 | 日期 | 说明 |
| --- | --- | --- |
| v1.0 | 2026-08-16 | 初版：产品定位、技术架构、数据库、API、算法思路、任务拆解 |
| v1.1 | 2026-08-16 | 修复复习算法状态转换矛盾；算法更名为固定间隔状态机；增加复习积压/每日上限机制；每日任务语义统一；question 增加来源字段；真题关联改为题目反查；登录改为普通账号体系（password_hash）；认证改为 Access+Refresh Token；锁定 HarmonyOS SDK 表述与路由方案；简化状态管理与本地存储；后台技术栈定死 Vue3；管理后台提前至 P3；新增测试阶段 P10；补充错误码、搜索分页规则、数据治理、安全隐私、内容版权、开发约束与 Agent 执行规则；验收标准量化 |
| v1.2 | 2026-08-16 | 新增知识库文档导入系统：新增第十章与审核红线；新增阶段 P3.5；新增 import_document / import_record 两张表；内容表增加来源追溯字段；后端新增文档解析（PDFBox / POI）与文件存储抽象；新增错误码 4001~4004；明确扫描 PDF OCR 属 V1.5、AI 结构化属 V2.0 且 AI 产物只能作为草稿 |
| v1.3 | 2026-08-16 | 工程一致性修正（不新增功能）：解决状态管理/本地存储定义冲突（移除 LocalStorage 持久化业务数据）；修复"上传文件不得解析执行"与文档解析系统的安全规则冲突；补完整 import_document / import_record 状态机（含完成定义、重新解析规则、驳回后重新提交 submit API）；统一题目关联规则为"至少关联一个知识点或成语"；practice_session 增加 ref_type；错题本明确展示实时题目内容（不存快照）；total_study_minutes 定义为冗余缓存；增加学习时长防刷约束；新增索引设计（5.4）与枚举总定义（5.5）；新增 API 契约规范（6.13：camelCase / snake_case / ISO 8601 / 核心接口 JSON 示例）；明确游客 UUID 方案；细化账号注销逐表处理策略；接口幂等要求；批量操作部分成功机制；桌面卡片降级为增强项；新增完成定义（DoD）与契约优先变更流程 |
| v1.4 | 2026-08-16 | 冻结版，仅修 6 项工程细节（不动架构）：① 游客身份数据模型定稿（user 表增加 user_type / guest_uuid，游客复用 user_id 体系）；② 账号注销策略定死（行为数据一律物理删除，user 脱敏保留）；③ 新增 Token 安全规则（禁止日志/异常/接口/UI 泄漏）；④ 每日任务 done_count 幂等计数键规则；⑤ 推荐数量与全局去重规则（常识 3 + 成语 3）；⑥ 性能指标量化（长列表滑动、首屏与分页加载时间）；新增 16.1 文档冻结声明与开发起点 |

---

## 一、项目概述

### 1.1 产品定位

面向公务员考试、事业单位考试等备考人群的 **HarmonyOS 原生碎片化常识与成语学习 App**。

核心价值主张：

> 每天 10～20 分钟，帮助用户完成公考常识和成语的持续积累，并通过智能复习降低遗忘。
> 产品的核心不是"题库有多少题"，而是 **系统知道用户今天应该学什么、练什么、复习什么**。

### 1.2 V1.0 核心闭环

```text
常识/成语 → 学习 → 练习 → 错题 → 掌握度 → 自动复习 → 再次练习
```

### 1.3 功能边界

**V1.0 必须完成：**

| 模块 | 内容 |
| --- | --- |
| 用户系统 | 注册、登录（用户名+密码）、Access/Refresh Token、个人信息、游客模式、账号注销 |
| 首页 | 今日任务、连续学习天数、学习进度、推荐内容（明确推荐算法） |
| 常识模块 | 9 大分类、列表、详情（含相关真题反查）、搜索、收藏、已掌握 |
| 成语模块 | 5 大分类、列表、详情（含相关题目反查）、搜索、收藏 |
| 练习模块 | 每日挑战、专项训练、随机训练、单选题、即时解析 |
| 错题系统 | 自动记录、错题本、再次练习、移出 |
| 复习系统 | 掌握度模型、固定间隔复习调度、今日复习（含积压处理）、错题强化 |
| 学习统计 | 连续天数、时长、正确率、掌握率、趋势 |
| 后端 | Spring Boot + MySQL + Redis，前后端分离 |
| 管理后台 | 知识点/成语/题目/用户管理（Vue3） |
| 知识库导入中心 | 文档（PDF/Word/TXT）上传解析、结构化草稿、人工审核入库、批量导入、来源追溯 |
| 合规基础 | 隐私政策、用户协议、账号注销 |

> 说明：**桌面卡片为 V1.0 发布前增强项，不是发布的强制阻塞项**（见 T9.6）。
> V1.0 功能优先级：核心学习闭环 > 后台内容生产 > 导入系统 > 统计 > 通知 > 桌面卡片。

**游客模式（V1.0 纳入）：**

```text
游客（免注册）：每日可体验 5 个知识点/成语详情 + 5 道练习题
登录用户：完整学习记录 + 收藏 + 复习 + 统计
```

> V1.0 简化约定：游客数据挂在游客身份下，登录后不与游客数据合并。

**V1.0 明确不做：**

AI Agent、社交/社区/排行榜、会员体系、广告、商城、复杂游戏化地图、复杂跨端能力、手机号验证码登录（V1.5 再做）、离线学习（V2.0 再做）、扫描 PDF OCR（V1.5 再做）、文档 AI 结构化解析（V2.0 再做）。

---

## 二、技术架构

### 2.1 总体架构

```text
                  HarmonyOS App（ArkTS + ArkUI）
                           │ HTTPS
                  Spring Boot API 服务 ─── 文档解析服务（PDFBox / POI）
                           │
        ┌──────────────────┼──────────────────┐
      MySQL              Redis             文件存储
   （内容+学习数据） （内容缓存/任务锁/   （导入原始文件：
                     Refresh Token）       开发本地磁盘 uploads/，
                                           生产 MinIO/OSS/OBS）
                           │
            zhikao-admin（Vue3 + TS + Vite + Element Plus）
                       │ HTTPS（/admin/**）
                       └── 内容管理 + 知识库导入中心
                           （文档上传 → 解析 → 草稿 → 审核 → 入库）
```

### 2.2 客户端技术栈

| 项 | 选型与约束 |
| --- | --- |
| 平台 | HarmonyOS NEXT 稳定版；以项目创建时 DevEco Studio 自带 SDK 为准，在 `build-profile.json5` 中固定 `compatibleSdkVersion`（建议不低于 API 12），开发全程锁定该版本 |
| 语言 | ArkTS |
| UI 框架 | ArkUI（声明式） |
| 架构 | MVVM 分层：UI Layer → ViewModel → Repository → Network / Local Storage |
| 路由 | **V1.0 统一使用 ArkUI Navigation 方案**，封装 RouterManager / NavigationService / RouteConstants；**禁止业务页面直接调用底层路由 API** |
| 状态管理 | **V1.0 全局状态仅使用 AppStorage**（当前用户/登录态/全局主题）；页面内部状态使用 @State/@Prop/@Link；**不使用 LocalStorage 持久化业务数据**（页面级数据用 @State 即可）；出现复杂跨组件状态后再评估引入更多机制 |
| 本地存储 | **V1.0 仅使用 Preferences**（Token、用户信息、主题、设置、最近访问、少量缓存、游客 UUID）；不使用 LocalStorage 持久化业务数据；RelationalStore 留到 V2.0 离线学习场景再引入 |
| 网络/通知等系统能力 | 使用当前 HarmonyOS SDK 对应的 Kit/API 实现，不写死具体模块名，以锁定版本的官方文档为准 |

客户端职责：页面展示、用户交互、答题逻辑、学习状态、本地缓存、网络请求、通知、桌面卡片（增强项）。

### 2.3 后端技术栈

| 项 | 选型 |
| --- | --- |
| 框架 | Spring Boot 3.x |
| Web | Spring Web |
| ORM | MyBatis-Plus |
| 安全 | Spring Security + JWT |
| 校验 | Jakarta Validation |
| 数据库 | MySQL 8.x |
| 缓存 | Redis |
| 文档解析 | Apache PDFBox（PDF）、Apache POI（Word docx/doc）；V1.0 不含 OCR |
| 文件存储 | FileStorage 接口抽象；开发环境本地磁盘 `uploads/`，生产环境切换 MinIO / OSS / OBS |

**认证方案（V1.0 定稿）：**

```text
Access Token：有效期 30 分钟（JWT，无状态）
Refresh Token：有效期 7 天（存 Redis，可主动吊销）
登出：客户端清除本地 Token 即可，V1.0 不做 JWT 黑名单
```

**Redis 用途：** 热点内容缓存、每日任务生成锁、Refresh Token 存储。

### 2.4 管理后台技术栈（定稿）

```text
zhikao-admin：Vue 3 + TypeScript + Vite + Element Plus
后端接口：/admin/** 仍由 Spring Boot 提供
```

> 不允许执行时在其他方案之间自行摇摆；第一版优先保证录入效率，不追求复杂 UI。

---

## 三、工程目录结构设计

### 3.1 客户端 zhikao-harmonyos

```text
zhikao-harmonyos/
├── AppScope/
│   ├── app.json5                        # 应用级配置（bundleName、版本）
│   └── resources/                       # 应用级资源（图标）
├── entry/
│   └── src/main/
│       ├── ets/
│       │   ├── entryability/
│       │   │   └── EntryAbility.ets     # UIAbility 入口
│       │   ├── pages/                   # 页面层
│       │   │   ├── SplashPage.ets           # 启动页
│       │   │   ├── LoginPage.ets            # 登录
│       │   │   ├── RegisterPage.ets         # 注册
│       │   │   ├── AgreementPage.ets        # 隐私政策/用户协议展示
│       │   │   ├── MainPage.ets             # 主容器（TabBar）
│       │   │   ├── HomePage.ets             # 首页
│       │   │   ├── StudyPage.ets            # 学习入口
│       │   │   ├── KnowledgeCategoryPage.ets# 常识分类
│       │   │   ├── KnowledgeListPage.ets    # 常识列表
│       │   │   ├── KnowledgeDetailPage.ets  # 常识详情
│       │   │   ├── IdiomCategoryPage.ets    # 成语分类
│       │   │   ├── IdiomListPage.ets        # 成语列表
│       │   │   ├── IdiomDetailPage.ets      # 成语详情
│       │   │   ├── PracticePage.ets         # 练习入口
│       │   │   ├── AnswerPage.ets           # 答题页
│       │   │   ├── AnswerResultPage.ets     # 练习结果
│       │   │   ├── ReviewPage.ets           # 复习入口
│       │   │   ├── ReviewSessionPage.ets    # 复习过程页
│       │   │   ├── WrongQuestionPage.ets    # 错题本
│       │   │   ├── FavoritePage.ets         # 我的收藏
│       │   │   ├── StudyRecordPage.ets      # 学习记录
│       │   │   ├── StatsPage.ets            # 学习统计
│       │   │   ├── MinePage.ets             # 我的
│       │   │   └── SettingsPage.ets         # 设置（含账号注销、协议入口、关于）
│       │   ├── components/              # 通用组件
│       │   │   ├── QuestionCard.ets         # 题目卡片（题干+选项）
│       │   │   ├── AnswerAnalysis.ets       # 答案解析面板
│       │   │   ├── MasteryBadge.ets         # 掌握度徽标
│       │   │   ├── TaskCard.ets             # 今日任务卡片
│       │   │   ├── EmptyView.ets            # 空态页
│       │   │   ├── LoadingView.ets          # 加载态
│       │   │   ├── ErrorView.ets            # 错误页（含重试）
│       │   │   └── SearchBar.ets            # 搜索栏
│       │   ├── viewmodel/               # ViewModel 层（页面状态与交互逻辑）
│       │   │   ├── HomeViewModel.ets
│       │   │   ├── KnowledgeViewModel.ets
│       │   │   ├── IdiomViewModel.ets
│       │   │   ├── PracticeViewModel.ets
│       │   │   ├── ReviewViewModel.ets
│       │   │   └── UserViewModel.ets
│       │   ├── model/                   # 业务数据模型（与后端 VO 对应，只放数据结构）
│       │   │   ├── Knowledge.ets
│       │   │   ├── Idiom.ets
│       │   │   ├── Question.ets
│       │   │   ├── DailyTask.ets
│       │   │   ├── ReviewSummary.ets
│       │   │   └── UserStats.ets
│       │   ├── types/                   # 类型定义（接口响应结构、回调类型）
│       │   ├── enums/                   # 枚举（与 5.5 枚举总定义一一对应）
│       │   ├── mapper/                  # DTO → Model 转换层
│       │   ├── store/                   # 全局状态（AppStorage 封装：用户、登录态、主题）
│       │   ├── repository/              # 仓库层（聚合网络+本地）
│       │   │   ├── KnowledgeRepository.ets
│       │   │   ├── IdiomRepository.ets
│       │   │   ├── PracticeRepository.ets
│       │   │   ├── ReviewRepository.ets
│       │   │   └── UserRepository.ets
│       │   ├── service/                 # 服务层
│       │   │   ├── HttpClient.ets           # 网络请求封装（拦截器、Token 注入、统一错误处理）
│       │   │   ├── ApiService.ets           # 接口定义
│       │   │   ├── TokenService.ets         # Access/Refresh Token 存取与刷新
│       │   │   ├── GuestIdService.ets       # 游客 UUID 生成与 Preferences 持久化
│       │   │   ├── NavigationService.ets    # 统一路由（RouterManager + RouteConstants）
│       │   │   ├── PreferencesService.ets   # Preferences 封装
│       │   │   └── NotificationService.ets  # 学习提醒通知
│       │   ├── utils/                   # 工具（日期、格式化、防抖）
│       │   ├── constants/               # 常量（路由路径、主题色、分类枚举）
│       │   ├── assets/                  # 本地图片/图标
│       │   └── theme/                   # 主题（浅色/深色 token）
│       ├── resources/                   # 模块资源（字符串、颜色、媒体）
│       └── module.json5                 # 模块配置（abilities、权限）
├── build-profile.json5                  # 固定 compatibleSdkVersion
├── oh-package.json5
└── hvigorfile.ts
```

**层职责约定（防止数据乱放）：**

| 层 | 职责 | 禁止 |
| --- | --- | --- |
| model | 纯数据结构定义 | 不放业务逻辑、不放全局状态 |
| store | AppStorage 全局状态读写（用户/登录态/主题） | 不放页面级临时状态 |
| viewmodel | 页面状态编排、调用 repository | 不直接发网络请求 |
| repository | 聚合网络与本地缓存 | 不感知 UI |
| mapper | 后端 DTO 与 model 互转 | 不含业务判断 |

### 3.2 后端 zhikao-server

```text
zhikao-server/
├── src/main/java/com/zhikao/server/
│   ├── ZhikaoApplication.java
│   ├── config/                  # 配置类
│   │   ├── SecurityConfig.java      # Spring Security + JWT 过滤器
│   │   ├── RedisConfig.java
│   │   ├── MybatisPlusConfig.java
│   │   ├── CorsConfig.java
│   │   ├── FileStorageConfig.java   # 文件存储（本地磁盘 / MinIO 切换）
│   │   └── SwaggerConfig.java       # 接口文档（knife4j/springdoc）
│   ├── controller/              # 接口层
│   │   ├── AuthController.java      # 注册/登录/游客/刷新/注销账号
│   │   ├── HomeController.java
│   │   ├── KnowledgeController.java
│   │   ├── IdiomController.java
│   │   ├── PracticeController.java
│   │   ├── WrongQuestionController.java
│   │   ├── ReviewController.java
│   │   ├── FavoriteController.java
│   │   ├── StatsController.java
│   │   └── admin/                 # 管理后台接口
│   │       ├── AdminAuthController.java
│   │       ├── AdminKnowledgeController.java
│   │       ├── AdminIdiomController.java
│   │       ├── AdminQuestionController.java
│   │       ├── AdminUserController.java
│   │       └── AdminImportController.java   # 知识库导入（上传/解析/审核/批量）
│   ├── service/                 # 业务层
│   │   ├── AuthService.java
│   │   ├── GuestService.java        # 游客额度控制
│   │   ├── KnowledgeService.java
│   │   ├── IdiomService.java
│   │   ├── PracticeService.java
│   │   ├── MasteryService.java      # 掌握度核心逻辑
│   │   ├── ReviewScheduleService.java # 复习调度核心逻辑
│   │   ├── RecommendService.java    # 首页推荐算法
│   │   ├── DailyTaskService.java
│   │   ├── StatsService.java
│   │   ├── ImportReviewService.java # 草稿审核、入库与来源回写
│   │   └── impl/
│   ├── document/                # 知识库导入中心
│   │   ├── parser/
│   │   │   ├── DocumentParser.java      # 解析器接口 + 类型路由（受控解析唯一入口）
│   │   │   ├── PdfParser.java           # PDFBox：普通 PDF 文本与结构提取
│   │   │   ├── WordParser.java          # POI：docx/doc 标题/段落/表格/列表
│   │   │   └── TxtParser.java
│   │   ├── service/
│   │   │   ├── DocumentImportService.java   # 上传/存储/异步解析编排/状态流转
│   │   │   └── ContentExtractService.java   # 结构化识别（规则切分 → 草稿）
│   │   └── model/
│   │       ├── ParsedDocument.java
│   │       └── ParsedSection.java
│   ├── storage/                 # FileStorage 抽象 + LocalDiskStorage / MinIOStorage 实现
│   ├── mapper/                  # MyBatis-Plus Mapper
│   ├── entity/                  # 数据库实体（与表一一对应，含 ImportDocument / ImportRecord）
│   ├── dto/                     # 请求参数对象（字段 camelCase，见 6.13）
│   ├── vo/                      # 响应视图对象（字段 camelCase，见 6.13）
│   ├── security/                # JWT 工具、认证入口、权限处理
│   ├── common/                  # 统一响应 Result、错误码、异常处理、常量、枚举
│   └── task/                    # 定时任务（每日任务生成、复习提醒）
├── src/main/resources/
│   ├── application.yml
│   ├── application-dev.yml
│   ├── application-prod.yml
│   ├── mapper/                  # XML（复杂 SQL）
│   └── db/
│       ├── schema.sql           # 建表语句（含 5.4 全部索引）
│       └── init-data.sql        # 初始分类、种子数据
└── pom.xml
```

### 3.3 管理后台 zhikao-admin

```text
zhikao-admin/
├── src/
│   ├── api/                     # 接口封装（axios）
│   ├── views/
│   │   ├── login/               # 管理员登录
│   │   ├── knowledge/           # 知识点管理
│   │   ├── idiom/               # 成语管理
│   │   ├── question/            # 题目管理
│   │   ├── import/              # 知识库导入中心（上传/解析状态/审核）
│   │   ├── user/                # 用户管理
│   │   └── dashboard/           # 学习数据概览
│   ├── components/              # 通用组件（富文本、选项编辑器、审核编辑器）
│   ├── router/                  # 路由与权限守卫
│   ├── stores/                  # Pinia 状态
│   └── utils/                   # 请求封装、工具
├── vite.config.ts
└── package.json
```

后台导航结构：

```text
内容中心
├── 知识点管理
├── 成语管理
├── 题目管理
└── 知识库导入（上传 → 解析状态 → 待审核 → 批量审核）
```

---

## 四、信息架构与页面清单

### 4.1 底部导航（TabBar）

```text
首页 | 学习 | 练习 | 复习 | 我的
```

### 4.2 页面清单与归属阶段

| 页面 | 功能要点 | 阶段 |
| --- | --- | --- |
| 启动页 SplashPage | Token 校验、首次启动隐私协议弹窗、路由分发 | P1/P4 |
| 登录/注册 | 用户名+密码、Access/Refresh Token | P4 |
| 协议页 AgreementPage | 隐私政策、用户协议展示 | P4 |
| 主容器 MainPage | TabBar、页面切换、登录态守卫 | P1 |
| 首页 HomePage | 用户信息、连续天数、今日完成度、今日任务（建议复习+积压提示）、快捷入口、今日推荐 | P4 |
| 学习入口 StudyPage | 常识/成语双入口 | P5 |
| 常识分类/列表 | 9 大分类、分页、搜索、掌握度标记 | P5 |
| 常识详情 KnowledgeDetailPage | 一句话记忆、核心知识、重点、易错点、相关真题（题目反查）、收藏、已掌握 | P5 |
| 成语分类/列表 | 5 大分类、分页、搜索 | P5 |
| 成语详情 IdiomDetailPage | 拼音、释义、出处、例句、近反义词、易混、常见误用、相关题目（反查） | P5 |
| 练习入口 PracticePage | 每日挑战、专项训练、随机训练 | P6 |
| 答题页 AnswerPage | 题号/总数、题干、选项、提交、即时判分、解析、关联知识点/成语跳转 | P6 |
| 练习结果 AnswerResultPage | 正确率、用时、错题清单 | P6 |
| 错题本 WrongQuestionPage | 错题列表、错误次数、最近错误时间、再练、移出 | P6 |
| 复习入口 ReviewPage | 待复习总数、建议复习数、积压提示、即将遗忘/普通/错题强化分组 | P7 |
| 复习过程 ReviewSessionPage | 回忆式复习（先看题→自答→揭示）、提交复习结果 | P7 |
| 收藏 FavoritePage | 知识点/成语收藏列表 | P5 |
| 学习记录 StudyRecordPage | 时间线记录 | P8 |
| 学习统计 StatsPage | 天数、时长、答题量、正确率、掌握率、趋势图 | P8 |
| 我的 MinePage | 个人信息、统计摘要、功能入口 | P8 |
| 设置 SettingsPage | 深色模式、提醒时间、账号注销、隐私政策、用户协议、关于 App | P9 |

> 管理后台页面（含知识库导入中心）见 3.3，归属 P3 / P3.5。

---

## 五、数据库设计

### 5.1 表清单总览

| 表 | 说明 |
| --- | --- |
| user | 用户 |
| knowledge_category | 常识分类 |
| knowledge | 常识知识点 |
| idiom_category | 成语分类 |
| idiom_category_rel | 成语-分类关联 |
| idiom | 成语 |
| question | 题目（含来源信息） |
| question_option | 题目选项 |
| user_knowledge | 用户-知识点学习状态（掌握度核心表） |
| user_idiom | 用户-成语学习状态 |
| practice_session | 练习场次 |
| user_answer | 答题明细 |
| wrong_question | 错题本 |
| favorite | 收藏 |
| study_record | 学习记录（时长、行为） |
| review_record | 复习记录 |
| daily_task | 每日任务 |
| import_document | 知识库导入：上传文件任务与解析状态 |
| import_record | 知识库导入：解析草稿与审核记录 |

### 5.2 核心表结构

#### user

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键（**游客与正式用户共用同一 user_id 体系**） |
| user_type | TINYINT | 1 正式用户 2 游客 |
| username | VARCHAR(50) UNIQUE | 登录账号名（游客为系统生成占位名，如 `guest_<uuid前8位>`，不用于登录） |
| guest_uuid | VARCHAR(36) UNIQUE NULL | 游客身份 UUID（user_type=2 时必填，正式用户为 NULL；见 6.1 游客约定） |
| password_hash | VARCHAR(255) NULL | BCrypt 加密后的密码哈希，**严禁存明文**（游客为 NULL） |
| nickname | VARCHAR(50) | 昵称 |
| avatar | VARCHAR(255) | 头像 URL |
| status | TINYINT | 0 正常 1 禁用 2 已注销 |
| streak_days | INT | 连续学习天数 |
| last_study_date | DATE | 最近学习日期（用于连续天数计算） |
| total_study_minutes | INT | 累计学习时长（分钟）。**冗余缓存字段，仅用于快速展示，不作为统计事实来源；事实来源 = study_record.duration_seconds 聚合**（见 7.7） |
| created_at / updated_at | DATETIME | 时间戳 |

> V1.5 预留：增加 `phone` 字段支持手机号验证码登录，V1.0 不建该字段。

**游客身份数据模型（v1.4 定稿，方案 A）：**

```text
游客 UUID（客户端生成，Preferences 持久化）
    ↓ POST /auth/guest
服务端按 guest_uuid 查 user 表：
    不存在 → 创建 user 记录（user_type=2，status=0），发放游客 Token
    已存在 → 直接发放该 user 的 Token
游客 Token 中的 user_id 即该 user.id；
practice_session / user_answer / study_record / wrong_question / review_record
等全部用户行为表复用同一 user_id，无需单独的 guest_identity 表。
游客升级为注册用户属于 V1.5 范围，V1.0 不做数据迁移合并。
```

#### knowledge_category

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| name | VARCHAR(20) | 政治/法律/经济/历史/地理/科技/文化/生态/生活 |
| icon | VARCHAR(100) | 图标标识 |
| sort | INT | 排序 |

#### knowledge

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| title | VARCHAR(100) | 标题 |
| category_id | BIGINT FK | 分类 |
| summary | VARCHAR(255) | 一句话记忆 |
| content | TEXT | 核心知识 |
| key_points | TEXT | 重点内容（JSON 数组） |
| common_mistakes | TEXT | 易错点 |
| difficulty | TINYINT | 1-5 难度 |
| status | TINYINT | 0 下架 1 上架 |
| source_type | TINYINT | 内容来源：1 自建 2 公共领域资料 3 合法授权 4 文档导入（对应 9.2 来源规则） |
| source_document_id | BIGINT NULL | 来源 import_document.id（source_type=4 时必填） |
| source_title | VARCHAR(200) NULL | 来源文件名/原始资料标题（如"公务员常识知识汇总.pdf"） |
| created_at / updated_at | DATETIME | 时间戳 |

> **不再设置 exam_link 字段**。知识详情页的"相关真题"通过 `SELECT ... FROM question WHERE knowledge_id = ?` 反查获得（见 6.4）。

#### idiom

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| word | VARCHAR(20) UNIQUE | 成语 |
| pinyin | VARCHAR(100) | 拼音 |
| explanation | TEXT | 释义 |
| origin | TEXT | 出处 |
| example | TEXT | 例句 |
| synonyms | VARCHAR(500) | 近义词（JSON 数组） |
| antonyms | VARCHAR(500) | 反义词（JSON 数组） |
| confusing | TEXT | 易混成语及辨析（JSON） |
| common_error | TEXT | 常见误用 |
| difficulty | TINYINT | 难度 |
| source_type | TINYINT | 内容来源：1 自建 2 公共领域资料 3 合法授权 4 文档导入 |
| source_document_id | BIGINT NULL | 来源 import_document.id（source_type=4 时必填） |
| source_title | VARCHAR(200) NULL | 来源文件名/原始资料标题 |
| created_at | DATETIME | 时间戳 |

> **不再设置 exam_context 字段**。成语详情页的"真题语境/相关题目"通过 `question.idiom_id` 反查获得。

#### idiom_category / idiom_category_rel

成语分类：高频成语、易错成语、近义辨析、常见误用、真题语境。一个成语可属于多个分类，用关联表 `idiom_category_rel(idiom_id, category_id)`。

#### question

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| type | TINYINT | 1 单选（V1.0 只做单选，预留 2 多选 3 判断 4 辨析） |
| content | TEXT | 题干 |
| analysis | TEXT | 解析 |
| difficulty | TINYINT | 难度 |
| knowledge_id | BIGINT NULL | 关联常识知识点 |
| idiom_id | BIGINT NULL | 关联成语 |
| source_type | TINYINT | 1 真题 2 模拟题 3 自编题 4 AI 生成题（V2.0 使用） |
| source_name | VARCHAR(100) | 来源名称（如"2024 年国考行测"） |
| exam_year | SMALLINT NULL | 考试年份 |
| province | VARCHAR(20) NULL | 省份（省考用） |
| question_no | VARCHAR(20) NULL | 原题题号 |
| source_document_id | BIGINT NULL | 文档导入来源的 import_document.id（导入题目必填） |
| status | TINYINT | 0 下架 1 上架 |
| created_at | DATETIME | 时间戳 |

> **关联规则（数据库、后台、API、算法全链路统一的唯一表述）：**
> `knowledge_id` 与 `idiom_id` **至少一个非空**，即 **题目必须至少关联一个知识点或成语**。
> 允许：A. 仅 knowledge_id 非空；B. 仅 idiom_id 非空；C. 两者均非空。不允许：D. 两者均为空（拒绝保存，错误码 1003）。

#### question_option

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| question_id | BIGINT FK | 题目 |
| label | CHAR(1) | A/B/C/D... |
| content | VARCHAR(500) | 选项内容 |
| is_correct | TINYINT | 是否正确答案 |

**硬约束（后端与管理后台同时校验）：**

```text
V1.0 单选题：
  选项数量 2～6 个
  必须且只能存在 1 个 is_correct = 1 的选项
违反则拒绝保存（错误码 1003）
```

#### user_knowledge（掌握度核心表）

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| user_id | BIGINT FK | 用户 |
| knowledge_id | BIGINT FK | 知识点 |
| mastery | TINYINT | 0 未学习 1 学习中 2 已学习 3 掌握 4 熟练 |
| review_stage | INT | 当前复习阶段（对应间隔梯度索引 0~5） |
| study_count | INT | 学习次数 |
| correct_count | INT | 答对次数 |
| wrong_count | INT | 答错次数 |
| last_study_time | DATETIME | 最近学习时间 |
| next_review_time | DATETIME | 下次复习时间（调度核心字段） |
| created_at / updated_at | DATETIME | 时间戳 |

> `user_idiom` 结构相同，外键换为 `idiom_id`。

#### practice_session

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| user_id | BIGINT FK | 用户（游客为 user_type=2 的 user.id） |
| type | TINYINT | 1 每日挑战 2 专项训练 3 随机训练 4 复习 5 错题重练 |
| ref_type | TINYINT | ref_id 指向的对象类型：1 常识分类 2 成语分类 3 知识点 4 成语 5 错题 6 无 |
| ref_id | BIGINT NULL | ref_type 对应目标对象的 id（ref_type=6 时为 NULL） |
| total_count | INT | 题目总数 |
| correct_count | INT | 答对数 |
| start_time / end_time | DATETIME | 起止时间 |

> 禁止出现"ref_id 含义随场景漂移"：ref_id 的语义由 ref_type 唯一确定（如 ref_type=1 时 ref_id 必为常识分类 id）。

#### user_answer

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| user_id | BIGINT FK | 用户 |
| session_id | BIGINT FK | 练习场次 |
| question_id | BIGINT FK | 题目 |
| selected_option_id | BIGINT | 所选选项 |
| is_correct | TINYINT | 是否正确 |
| answer_time | DATETIME | 作答时间 |

#### wrong_question

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| user_id | BIGINT FK | 用户 |
| question_id | BIGINT FK | 题目 |
| wrong_count | INT | 累计错误次数 |
| last_wrong_time | DATETIME | 最近错误时间 |
| is_removed | TINYINT | 是否移出错题本 |
| created_at | DATETIME | 首次加入时间 |

> 唯一索引 `(user_id, question_id)`，重复答错累加 `wrong_count`。
> **错题本不存题目快照**：只保存 question_id，错题本展示实时 question 内容；题目被管理员修改后，错题本同步展示最新内容。

#### favorite

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| user_id | BIGINT FK | 用户 |
| target_type | TINYINT | 1 知识点 2 成语 |
| target_id | BIGINT | 目标 id |
| created_at | DATETIME | 收藏时间 |

> 唯一索引 `(user_id, target_type, target_id)`。

#### study_record

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| user_id | BIGINT FK | 用户 |
| record_type | TINYINT | 1 学知识点 2 学成语 3 练习 4 复习 |
| target_id | BIGINT | 目标 id |
| duration_seconds | INT | 本次时长（防刷约束见下） |
| created_at | DATETIME | 时间 |

> **时长防刷（V1.0）**：服务端校验 `0 ≤ duration_seconds ≤ 1800`，超限裁剪到 1800 并告警计数；客户端连续无操作超过 300 秒自动结束本次学习会话并停止计时。

#### review_record

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| user_id | BIGINT FK | 用户 |
| target_type | TINYINT | 1 知识点 2 成语 |
| target_id | BIGINT | 目标 id |
| review_type | TINYINT | 1 即将遗忘 2 普通 3 错题强化 |
| is_correct | TINYINT | 复习自测结果 |
| created_at | DATETIME | 时间 |

#### daily_task

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| user_id | BIGINT FK | 用户 |
| task_date | DATE | 任务日期 |
| task_type | TINYINT | 1 常识积累 2 成语训练 3 今日复习 |
| target_count | INT | 目标数量（复习类任务 = min(到期数量, 20)） |
| done_count | INT | 已完成数量 |
| status | TINYINT | 0 未完成 1 已完成 |

> 唯一索引 `(user_id, task_date, task_type)`；由每日首次访问懒加载生成（Redis 锁防重）。

#### import_document（知识库导入：文件任务）

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| file_name | VARCHAR(255) | 原始文件名 |
| file_path | VARCHAR(500) | 存储路径（FileStorage 相对 key） |
| file_type | VARCHAR(20) | TEXT_PDF / SCANNED_PDF / DOCX / DOC / TXT |
| file_size | BIGINT | 文件大小（字节） |
| import_type | TINYINT | 1 常识知识库 2 成语知识库 3 题库 4 自动识别 |
| status | TINYINT | 状态机见 10.3：0 上传成功 1 解析中 2 解析完成 3 审核中 4 已完成 5 解析失败 |
| total_sections | INT | 识别出的内容块总数 |
| success_count | INT | 审核通过入库条数 |
| failed_count | INT | 驳回/解析失败条数 |
| created_by | BIGINT | 管理员 id |
| created_at / updated_at | DATETIME | 时间戳 |

#### import_record（知识库导入：解析草稿）

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | BIGINT PK | 主键 |
| document_id | BIGINT FK | 所属 import_document |
| content_type | TINYINT | 1 知识点 2 成语 3 题目 |
| source_title | VARCHAR(200) | 解析出的块标题 |
| parsed_content | TEXT | 结构化解结果（JSON：title/summary/keyPoints/commonMistakes/category 等） |
| raw_excerpt | TEXT | 对应原文摘录（审核对照用） |
| status | TINYINT | 状态机见 10.3：0 待审核 1 已通过入库 2 已驳回 3 已失效 |
| error_message | VARCHAR(500) | 驳回原因/解析错误信息 |
| target_id | BIGINT NULL | 入库后对应的 knowledge/idiom/question id |
| reviewed_by | BIGINT NULL | 审核人 id |
| created_at / updated_at | DATETIME | 时间戳 |

### 5.3 数据治理与删除策略（全项目统一）

```text
内容数据（knowledge / idiom / question / 各分类表）：
  只做逻辑下架（status = 0），不做物理删除。
  管理后台不提供物理删除按钮；确需清理走 DBA 流程。
  原因：user_answer / wrong_question / study_record 等均引用内容 id。

用户行为数据（user_answer / wrong_question / study_record / review_record 等）：
  原则上不允许删除。
  唯一例外：账号注销时按下表处理。

导入数据（import_document / import_record）：
  解析失败的文档、被驳回/失效的草稿一律保留（含 error_message），不做物理删除，
  供复核、重新解析与版权溯源；原始文件永久保留（见第十章）。
```

**账号注销逐表处理策略（v1.4 定死，T9.5 的唯一执行依据）：**

| 数据表 | 注销后处理 |
| --- | --- |
| user | username 改为 `anonymous_<id>`、nickname 改为"已注销用户"、avatar 置 NULL、password_hash 置 NULL、guest_uuid 置 NULL，status=2（已注销）；账号记录脱敏保留 |
| user_knowledge | 删除（DELETE） |
| user_idiom | 删除（DELETE） |
| favorite | 删除（DELETE） |
| daily_task | 删除（DELETE） |
| practice_session | 删除（DELETE） |
| user_answer | 删除（DELETE） |
| wrong_question | 删除（DELETE） |
| study_record | 删除（DELETE） |
| review_record | 删除（DELETE） |

> V1.0 定稿：行为数据**一律物理删除，不做匿名化保留**（V1.0 用户量不需要匿名统计，实现最简单且最符合注销目标）；仅 user 表脱敏保留以阻止重复注销与登录。
> 注销操作在单个事务内完成；注销后该账号登录返回 2003。
> 游客账号（user_type=2）的注销按同一策略执行，游客 UUID 清除后即无法再关联。

### 5.4 索引设计（schema.sql 必须包含，T2.3 验收项）

| 表 | 索引 | 类型 | 用途 |
| --- | --- | --- | --- |
| user | uk_username (username) | 唯一 | 登录查询 |
| user | uk_guest_uuid (guest_uuid) | 唯一 | 游客 UUID 换 Token 查询（NULL 值不参与唯一约束冲突） |
| knowledge | idx_category (category_id, status) | 普通 | 分类列表 |
| knowledge | idx_source_doc (source_document_id) | 普通 | 来源追溯 |
| idiom | idx_source_doc (source_document_id) | 普通 | 来源追溯 |
| idiom_category_rel | uk_rel (idiom_id, category_id) | 唯一 | 防重复关联 |
| question | idx_knowledge (knowledge_id) | 普通 | 相关真题反查、专项组卷 |
| question | idx_idiom (idiom_id) | 普通 | 相关题目反查、成语训练组卷 |
| question | idx_source_doc (source_document_id) | 普通 | 来源追溯 |
| question_option | idx_question (question_id) | 普通 | 选项查询 |
| user_knowledge | uk_user_knowledge (user_id, knowledge_id) | 唯一 | 防重复记录 |
| user_knowledge | idx_review (user_id, next_review_time) | 普通 | **今日复习到期查询（核心查询）** |
| user_idiom | uk_user_idiom (user_id, idiom_id) | 唯一 | 防重复记录 |
| user_idiom | idx_review (user_id, next_review_time) | 普通 | 今日复习到期查询 |
| practice_session | idx_user_time (user_id, start_time) | 普通 | 练习历史 |
| user_answer | idx_session (session_id, question_id) | 普通 | 场次答题明细 |
| user_answer | idx_user_time (user_id, answer_time) | 普通 | 统计与近 7 天错误聚合 |
| wrong_question | uk_user_question (user_id, question_id) | 唯一 | 错题唯一 |
| wrong_question | idx_list (user_id, is_removed, last_wrong_time) | 普通 | 错题本列表与错题强化筛选 |
| favorite | uk_favorite (user_id, target_type, target_id) | 唯一 | 防重复收藏 |
| study_record | idx_user_time (user_id, created_at) | 普通 | 学习记录与时长聚合 |
| review_record | idx_user_time (user_id, created_at) | 普通 | 错题强化"近 3 天未重练"判断 |
| daily_task | uk_daily_task (user_id, task_date, task_type) | 唯一 | 每日任务唯一 |
| import_document | idx_status (status) | 普通 | 导入任务列表 |
| import_record | idx_doc_status (document_id, status) | 普通 | 按文档查草稿及状态统计 |

### 5.5 枚举总定义（唯一事实来源）

> 以下为本项目全部枚举的唯一权威定义；API 中一律使用 camelCase 字段承载这些数值；新增或修改枚举必须走契约优先流程（14.4 规则 2）。

**mastery（user_knowledge.mastery / user_idiom.mastery）：**

| 值 | 名称 | 含义 | 允许转换 |
| --- | --- | --- | --- |
| 0 | 未学习 | 从未开始学习 | 0→1 |
| 1 | 学习中 | 已开始未完成学习上报 | 1→2 |
| 2 | 已学习 | 完成学习，进入复习调度 | 2→3 |
| 3 | 掌握 | review_stage ≥ 4 | 3→4 |
| 4 | 熟练 | review_stage ≥ 5 通过，不再主动调度 | 终态 |

> V1.0 mastery 只升不降；复习答错仅回退 review_stage，不降级 mastery。

**review_stage（user_knowledge / user_idiom）：**

| 值 | 对应间隔 | 允许转换 |
| --- | --- | --- |
| 0 | 10 分钟 | 答对→1；答错→max(stage-2, 0) |
| 1 | 1 天 | 同上规则 |
| 2 | 3 天 | 同上规则 |
| 3 | 7 天 | 同上规则 |
| 4 | 15 天 | 同上规则；达到即 mastery 置"掌握" |
| 5 | 30 天 | 通过后 mastery 置"熟练"，不再调度 |

**question.type：**

| 值 | 名称 | 含义 | V1.0 状态 |
| --- | --- | --- | --- |
| 1 | 单选 | 单选题 | 启用 |
| 2 | 多选 | 多选题 | 预留 |
| 3 | 判断 | 判断题 | 预留 |
| 4 | 辨析 | 成语辨析题 | 预留 |

**question.source_type：**

| 值 | 名称 | 含义 |
| --- | --- | --- |
| 1 | 真题 | 合法公开的国考/省考等真题 |
| 2 | 模拟题 | 合法授权模拟题 |
| 3 | 自编题 | 原创题 |
| 4 | AI 生成题 | V2.0 使用 |

**knowledge.source_type / idiom.source_type（内容来源）：**

| 值 | 名称 | 含义 |
| --- | --- | --- |
| 1 | 自建 | 人工原创 |
| 2 | 公共领域资料 | 无版权或已过保护期资料 |
| 3 | 合法授权 | 取得授权的内容 |
| 4 | 文档导入 | 经知识库导入系统审核入库（source_document_id 必填） |

**daily_task.task_type：**

| 值 | 名称 | 目标定义 |
| --- | --- | --- |
| 1 | 常识积累 | 学习 3 个常识知识点 |
| 2 | 成语训练 | 完成 5 道成语练习题 |
| 3 | 今日复习 | 完成建议复习量 min(到期数, 20) |

**practice_session.type：**

| 值 | 名称 | ref_type 取值 |
| --- | --- | --- |
| 1 | 每日挑战 | 6（无） |
| 2 | 专项训练 | 1/2/3/4 |
| 3 | 随机训练 | 6（无） |
| 4 | 复习 | 6（无） |
| 5 | 错题重练 | 5 或 6 |

**practice_session.ref_type：**

| 值 | 名称 | 含义 |
| --- | --- | --- |
| 1 | knowledge_category | ref_id 为常识分类 id |
| 2 | idiom_category | ref_id 为成语分类 id |
| 3 | knowledge | ref_id 为知识点 id |
| 4 | idiom | ref_id 为成语 id |
| 5 | wrong_question | ref_id 为错题 id |
| 6 | none | 无目标对象，ref_id 为 NULL |

**import_document.status：** 状态机见 10.3（0 UPLOADED / 1 PARSING / 2 PARSED / 3 REVIEWING / 4 COMPLETED / 5 FAILED）。

**import_record.status：** 状态机见 10.3（0 PENDING_REVIEW / 1 APPROVED / 2 REJECTED / 3 INVALIDATED）。

**user.user_type：**

| 值 | 名称 | 含义 | 允许转换 |
| --- | --- | --- | --- |
| 1 | 正式用户 | 注册账号 | 终态 |
| 2 | 游客 | 游客 UUID 换取的身份 | 终态（游客升级注册用户为 V1.5 范围） |

**其他状态类字段：**

| 字段 | 取值 |
| --- | --- |
| user.status | 0 正常 1 禁用 2 已注销 |
| knowledge/idiom/question.status | 0 下架 1 上架 |
| daily_task.status / 各完成标记 | 0 未完成 1 已完成 |
| wrong_question.is_removed | 0 在错题本 1 已移出 |
| favorite.target_type / review_record.target_type | 1 知识点 2 成语 |
| study_record.record_type | 1 学知识点 2 学成语 3 练习 4 复习 |
| review_record.review_type | 1 即将遗忘 2 普通 3 错题强化 |
| import_document.import_type | 1 常识知识库 2 成语知识库 3 题库 4 自动识别 |
| import_document.file_type | TEXT_PDF / SCANNED_PDF / DOCX / DOC / TXT（字符串枚举） |

---

## 六、API 设计

### 6.1 统一约定

- 前缀 `/api/v1`；除 auth 外全部需要 Access Token（Header `Authorization: Bearer <token>`）
- Access Token 过期返回 `2001`，客户端用 Refresh Token 调 `/auth/refresh` 静默续期一次；Refresh 失败（`2002`）跳登录页
- 统一响应：`{ "code": 0, "message": "success", "data": {...} }`
- 字段命名与格式契约见 **6.13 API 契约规范**

**统一错误码：**

| code | 含义 |
| --- | --- |
| 0 | 成功 |
| 1001 | 参数校验失败 |
| 1002 | 资源不存在 |
| 1003 | 业务约束冲突（如单选题正确选项不唯一、题目未关联知识点或成语） |
| 2001 | 未登录或 Access Token 过期 |
| 2002 | Refresh Token 过期，需重新登录 |
| 2003 | 账号已被禁用或已注销 |
| 3001 | 无权限（非管理员访问 /admin） |
| 4001 | 文件类型不支持（仅限 .pdf / .docx / .doc / .txt） |
| 4002 | 文件大小超限（单文件 ≤ 20MB） |
| 4003 | 扫描版 PDF 无文本层，需 OCR（V1.0 不支持，V1.5 提供） |
| 4004 | 导入记录/文档当前状态不允许该操作（如已入库草稿不可再编辑、非驳回草稿不可重新提交） |
| 9001 | 游客当日额度用尽，引导登录 |
| 5000 | 服务器内部错误 |

**分页与搜索统一规则：**

```text
page >= 1；1 <= size <= 50（超出按边界值处理）
默认返回字段：{ list, total, page, size }

常识搜索：keyword 匹配 title + summary + content（LIKE 模糊）
成语搜索：keyword 匹配 word + pinyin + explanation（LIKE 模糊）
默认排序：列表按 updated_at 倒序；带 keyword 时相关命中优先，其次 updated_at 倒序
```

**幂等约定：**

```text
写操作接口（提交答案、提交复习结果、草稿审核 approve/reject/submit、
收藏 toggle、每日任务生成、批量审核）必须幂等或防重：
通过唯一索引、Redis 锁或状态机前置校验实现；
重复请求不得导致重复计数、重复入库或状态被重复推进。
每日任务完成计数的幂等键规则见 7.4。
```

**Token 安全规则（v1.4 新增，强制）：**

```text
Token（Access / Refresh）不得输出到任何日志；
Token 不得出现在异常信息、Crash 报告或调试输出中；
Token 不得通过普通业务接口返回（仅 /auth/login、/auth/refresh 的约定字段除外）；
Refresh Token 不得出现在 UI 层（仅允许 TokenService 内部读写）；
HTTP 拦截器打印请求日志时必须对 Authorization 头整体脱敏。
```

**学习时长上报约束：**

```text
学习行为上报可携带 durationSeconds：服务端校验 0 ≤ durationSeconds ≤ 1800，
超限裁剪到 1800；客户端连续无操作超过 300 秒自动结束本次学习会话。
```

**文件上传约定（multipart/form-data）：**

```text
单文件 ≤ 20MB；类型白名单 .pdf / .docx / .doc / .txt；单批次 ≤ 10 个文件
上传只落 import_document（status=0）与文件存储，不直接写任何正式内容表
```

**游客约定（v1.4 定稿）：**

```text
游客身份 = App 首次启动时生成的随机 UUID：
  UUID 由客户端生成并持久化在 Preferences；
  POST /auth/guest 携带该 UUID 换取游客 Token；
  服务端按 guest_uuid 在 user 表创建/复用 user_type=2 的游客记录（见 5.2 游客身份数据模型），
  Token 中的 user_id 即该记录 id，不采集任何硬件指纹（序列号、IMEI 等）；
  卸载 App 后游客身份自然失效，不做跨设备找回。
游客每日限额：知识点/成语详情浏览各 5 次、答题 5 道
超限返回 9001，客户端展示登录引导
```

### 6.2 认证模块 /auth

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | /auth/register | 注册（username、password、nickname） |
| POST | /auth/login | 登录，返回 Access Token + Refresh Token + 用户信息 |
| POST | /auth/guest | 携带游客 UUID 获取游客 Token |
| POST | /auth/refresh | 用 Refresh Token 换新 Access Token（Refresh Token 7 天） |
| GET | /auth/profile | 获取当前用户信息 |
| PUT | /auth/profile | 修改昵称/头像 |
| POST | /auth/logout | 登出（客户端清除本地 Token；删除 Redis 中 Refresh Token） |
| POST | /auth/delete-account | 账号注销（按 5.3 逐表策略处理数据，需二次确认凭证） |

### 6.3 首页 /home

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | /home/overview | 首页聚合：连续天数、今日完成度、今日学习时长、今日任务列表及进度、复习积压数（响应示例见 6.13） |
| GET | /home/recommend | 今日推荐：按 7.6 推荐算法返回推荐知识点 N 条 + 推荐成语 N 条 |

### 6.4 常识模块 /knowledge

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | /knowledge/categories | 分类列表（含各分类知识点数、已掌握数） |
| GET | /knowledge/list | 列表，参数 categoryId、keyword、mastery、page、size |
| GET | /knowledge/{id} | 详情（含用户掌握状态、收藏状态、相关真题列表——由 question 按 knowledge_id 反查，返回题干、年份、来源） |
| POST | /knowledge/{id}/study | 上报"学习了"（可携带 durationSeconds），初始化/更新 user_knowledge |
| POST | /knowledge/{id}/mastered | 标记已掌握 |
| POST | /knowledge/{id}/favorite | 收藏/取消收藏（toggle） |

### 6.5 成语模块 /idiom

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | /idiom/categories | 分类列表 |
| GET | /idiom/list | 列表，参数 categoryId、keyword、page、size |
| GET | /idiom/{id} | 详情（含相关题目反查列表） |
| POST | /idiom/{id}/study | 上报学习（可携带 durationSeconds） |
| POST | /idiom/{id}/favorite | 收藏/取消 |

### 6.6 练习模块 /practice

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | /practice/sessions | 创建练习场次，body：`{ type, refType?, refId?, count? }`（语义见 5.5）；返回 sessionId + 题目列表（不含答案）；游客限额在此校验 |
| POST | /practice/sessions/{id}/answers | 提交单题答案 `{ questionId, optionId }`，返回判定、正确答案、解析、关联知识点/成语 |
| GET | /practice/sessions/{id}/result | 场次结果：正确率、用时、错题列表 |

> 答案不下发到客户端，判定在服务端完成。答错自动写入 wrong_question 并联动掌握度。

### 6.7 错题模块 /wrong

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | /wrong/list | 错题列表（含**关联题目完整信息**——实时 question 内容，非快照）、错误次数、最近错误时间，支持分页 |
| POST | /wrong/practice | 从错题本组卷重练，返回 sessionId |
| POST | /wrong/{id}/remove | 移出错题本（逻辑标记 is_removed=1） |

> 题目被管理员修改后，错题本展示最新题目内容（不保留历史快照）。

### 6.8 复习模块 /review

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | /review/today | 今日复习概览：pendingTotal（积压总数）、suggestedCount = min(pendingTotal, 20)（建议复习数）、即将遗忘/普通/错题强化分组数量（响应示例见 6.13） |
| POST | /review/sessions | 开始复习（默认取建议量），返回按调度排序的复习项列表（targetType + 内容） |
| POST | /review/sessions/{id}/items | 提交单项复习结果 `{ targetType, targetId, isCorrect }`，触发掌握度与 next_review_time 更新 |

### 6.9 收藏与记录 /favorite /record

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | /favorite/list | 收藏列表，参数 targetType |
| GET | /record/list | 学习记录时间线，支持按日期过滤 |

### 6.10 统计模块 /stats

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | /stats/overview | 学习天数、累计时长、知识点/成语掌握数、答题量、总正确率（时长由 study_record 聚合计算，见 7.7） |
| GET | /stats/trend | 近 N 天学习趋势（每日时长、答题数、正确率），参数 days |
| GET | /stats/daily-report | 当日学习报告 |

### 6.11 管理后台 /admin

| 模块 | 接口 |
| --- | --- |
| 登录 | POST /admin/login（管理员账号，独立 token 体系） |
| 知识点 | CRUD + 分类管理 + 搜索：/admin/knowledge、/admin/knowledge/categories（删除仅下架；录入必填来源字段） |
| 成语 | CRUD + 分类：/admin/idiom |
| 题目 | CRUD（含选项、答案、解析、关联知识点/成语、来源信息；保存时强制 5.2 选项约束与关联校验：**必须至少关联一个知识点或成语**，否则 1003）：/admin/question |
| 用户 | 列表、禁用/启用：/admin/user |
| 数据 | 学习数据概览：/admin/dashboard |
| 知识库导入 | 见 6.12 |

### 6.12 知识库导入模块 /admin/import

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | /admin/import/upload | multipart 上传（≤10 个文件），body 含 importType（1 常识 2 成语 3 题库 4 自动识别）；创建 import_document（status=0），文件落 FileStorage |
| POST | /admin/import/documents/{id}/parse | 开始/重新解析（异步执行；允许的源状态与草稿失效规则见 10.3） |
| GET | /admin/import/documents | 导入任务列表（分页，含状态与统计数据） |
| GET | /admin/import/documents/{id} | 任务详情（totalSections / successCount / failedCount、文件元数据） |
| GET | /admin/import/records | 草稿列表，参数 documentId、contentType、status、page、size |
| GET | /admin/import/records/{id} | 草稿详情（parsedContent + rawExcerpt 原文摘录对照） |
| PUT | /admin/import/records/{id} | 编辑草稿内容（仅待审核/已驳回状态可编辑，否则 4004；**编辑只改内容，不改变状态**） |
| POST | /admin/import/records/{id}/submit | **重新提交审核**：已驳回草稿编辑后重新进入待审核（REJECTED → PENDING_REVIEW；仅已驳回状态可调用，否则 4004） |
| POST | /admin/import/records/{id}/approve | 审核通过 → 写入正式表（knowledge/idiom/question），回写 target_id 与来源字段（source_type=4 / source_document_id / source_title） |
| POST | /admin/import/records/{id}/reject | 驳回（必须填 errorMessage） |
| POST | /admin/import/batch-approve | 批量审核通过，body：`{ recordIds: [] }`；**逐条处理，返回逐条结果，部分失败不影响已成功条目** |

### 6.13 API 契约规范（v1.3 新增）

**全局约定：**

```text
JSON 字段名统一 camelCase（如 streakDays、nextReviewTime）
数据库字段名统一 snake_case（如 streak_days、next_review_time）
DTO/VO 与数据库实体之间经 mapper/ORM 映射层转换，禁止把 snake_case 直接透出到 JSON
时间统一 ISO 8601 字符串，如 "2026-08-16T10:30:00+08:00"
ID 统一数值类型（Long/number）
分页响应统一：{ "list": [], "total": 0, "page": 1, "size": 20 }
以下示例为核心接口的唯一契约，其余接口照此风格实现，DTO 字段必须与示例一致
```

**示例 1：GET /home/overview 响应**

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "streakDays": 3,
    "todayCompleted": 5,
    "todayTarget": 10,
    "todayStudyMinutes": 12,
    "reviewPendingTotal": 47,
    "reviewSuggestedCount": 20,
    "tasks": [
      { "taskType": 1, "taskName": "常识积累", "targetCount": 3, "doneCount": 1, "status": 0 },
      { "taskType": 2, "taskName": "成语训练", "targetCount": 5, "doneCount": 5, "status": 1 },
      { "taskType": 3, "taskName": "今日复习", "targetCount": 20, "doneCount": 0, "status": 0 }
    ]
  }
}
```

**示例 2：POST /practice/sessions 请求与响应**

```json
// 请求
{ "type": 2, "refType": 1, "refId": 3, "count": 10 }

// 响应 data（题目列表不含正确答案）
{
  "sessionId": 1001,
  "totalCount": 10,
  "questions": [
    {
      "questionId": 501,
      "content": "下列关于科举制度的说法，正确的是？",
      "options": [
        { "optionId": 2001, "label": "A", "content": "起源于唐朝" },
        { "optionId": 2002, "label": "B", "content": "起源于隋朝" }
      ],
      "knowledgeId": 12,
      "idiomId": null
    }
  ]
}
```

**示例 3：POST /practice/sessions/{id}/answers 请求与响应**

```json
// 请求
{ "questionId": 501, "optionId": 2001 }

// 响应 data
{
  "correct": false,
  "correctOptionLabel": "B",
  "analysis": "科举制度起源于隋朝……",
  "knowledgeId": 12,
  "idiomId": null
}
```

**示例 4：GET /review/today 响应**

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "pendingTotal": 47,
    "suggestedCount": 20,
    "groups": { "forgetting": 8, "normal": 9, "wrongReinforce": 3 }
  }
}
```

---

## 七、核心算法设计

### 7.1 掌握度状态机

五档状态（枚举定义见 5.5）：

```text
未学习(0) → 学习中(1) → 已学习(2) → 掌握(3) → 熟练(4)
```

状态转换规则（与 7.2 间隔梯度严格对应）：

```text
首次学习（打开详情页并上报）：
    未学习 → 学习中

完成学习上报 / 标记已掌握：
    学习中 → 已学习，进入复习调度（review_stage = 0）

复习答对：
    review_stage 逐级 +1（上限 5）
    review_stage >= 4（对应 15 天档）：已学习 → 掌握
    review_stage >= 5（对应 30 天档通过）：掌握 → 熟练，不再主动调度

复习答错：
    review_stage = max(review_stage - 2, 0)   # 容错回退，不直接归零
    wrong_count += 1
    重新进入短周期复习
```

> 说明：阶段 4 对应 15 天、阶段 5 对应 30 天，v1.0 稿中"阶段 4 = 7 天档"的表述有误，已在 v1.1 修正。

### 7.2 间隔重复复习算法 V1.0（固定间隔状态机）

> 命名规范：本算法为 **固定间隔 + 阶段状态机**，不含记忆质量评分、Easiness Factor 与动态间隔计算，**不得称为 SM-2 或 SM-2 简化版**。V2.0 再评估引入 FSRS / SM-2 类算法。

复习间隔梯度（`REVIEW_INTERVALS`，服务端常量，可调）：

```text
阶段0: 10 分钟   （首次学习后）
阶段1: 1 天
阶段2: 3 天
阶段3: 7 天
阶段4: 15 天
阶段5: 30 天     （通过后进入"熟练"）
```

调度逻辑：

```text
复习答对:
    review_stage = min(review_stage + 1, 5)
    next_review_time = now + INTERVALS[review_stage]

复习答错:
    review_stage = max(review_stage - 2, 0)
    next_review_time = now + INTERVALS[review_stage]   # stage=0 时为 10 分钟后
```

### 7.3 今日复习生成逻辑（含积压处理）

**两个必须区分的概念：**

```text
复习积压量 pending_total：全部 next_review_time <= now 的条目数
今日任务量 suggested_count：min(pending_total, 20)
```

客户端展示示例：

```text
今日复习
建议复习：20 个
还有 47 个待复习
```

> 禁止把全部积压量作为"今日必须完成"展示，避免"积压→劝退→更积压"循环。

```text
查询 user_knowledge / user_idiom 中 next_review_time <= now 的条目
分组：
  - 即将遗忘: next_review_time 已超期 > 2 天
  - 普通复习: 其余到期项
  - 错题强化: wrong_question 中 is_removed=0 且近 3 天未重练的题
排序：超期时长降序 → 错误次数降序
单次复习会话上限 20 项；完成建议量即视为完成今日复习任务
```

### 7.4 每日任务生成

```text
每日首次请求 /home/overview 时懒加载生成（Redis 分布式锁防重）：

  - 常识积累: 学习 3 个常识知识点（学习上报计数）
  - 成语训练: 完成 5 道成语练习题（按 idiom_id 非空题目的 user_answer 计数）
  - 今日复习: target_count = min(到期数量, 20)，完成建议量即置为完成

完成判定：对应行为上报时 done_count += 1，达标置 status=1
```

> 语义约定："积累/学习"对应知识浏览，"训练"对应做题。任务文案与本定义保持一致。

**done_count 幂等计数规则（v1.4 新增，防止重复点击虚增）：**

```text
计数去重键（同一天同一目标只计一次）：
  常识积累: userId + taskDate + taskType=1 + knowledge_id
  成语训练: userId + taskDate + taskType=2 + user_answer_id
  今日复习: userId + taskDate + taskType=3 + review_record_id

实现方式：服务端按去重键判断（唯一索引或 Redis SET 判重），
重复上报同一目标不再增加 done_count。
生成任务防并发（Redis 锁）与完成任务防重（去重键）是两件事，必须同时满足。
```

### 7.5 连续学习天数

```text
用户当天产生任意有效学习行为（学习/练习/复习上报）时：
  if last_study_date == today: 不变
  elif last_study_date == today - 1: streak_days += 1
  else: streak_days = 1
  last_study_date = today
```

### 7.6 首页推荐算法（V1.0）

**推荐数量与去重规则（v1.4 定稿）：**

```text
推荐目标：常识 3 条 + 成语 3 条（GET /home/recommend 返回 knowledgeList 3 条、idiomList 3 条）
推荐结果全局去重：同一 targetId（知识点/成语）在一次推荐中只出现一次
填充规则：按优先级逐层填充；不足目标数时由下一优先级补足；
        优先级 5（随机）仍不足时，返回实际数量，不重复填充、不报错
```

推荐位按以下优先级顺序填充，前一优先级不足再用后一优先级补足：

```text
1. 今日待复习内容（到期项，最高优先）
2. 最近高频错误知识点（近 7 天 wrong_question 按 knowledge_id/idiom_id 聚合，错误次数降序）
3. 未学习内容（无 user_knowledge/user_idiom 记录）
4. 用户薄弱分类（按分类统计正确率，取正确率最低的分类中的未掌握内容）
5. 随机内容（兜底）
```

### 7.7 统计数据事实来源约定（v1.3 新增）

```text
唯一事实来源 = 明细表聚合：
  学习时长 = SUM(study_record.duration_seconds)
  答题量/正确率 = user_answer 聚合
  掌握数 = user_knowledge / user_idiom 按 mastery 聚合
  连续天数 = user.streak_days（由 7.5 规则在服务端事务内维护）

user.total_study_minutes 等汇总字段 = 冗余缓存：
  仅用于首页/我的页快速展示；
  由学习行为上报在同一事务内增量更新；
  统计接口（/stats/**）一律从明细表聚合计算，不读缓存字段；
  当缓存与聚合不一致时，以聚合结果为准并异步修复缓存。
```

---

## 八、安全与隐私（V1.0 必须项）

| 项 | 要求 |
| --- | --- |
| 首次启动 | 展示隐私政策 + 用户协议弹窗，用户同意后才可初始化网络与数据采集能力 |
| 设置页 | 提供：账号注销、隐私政策、用户协议、关于 App |
| 账号注销 | 提供注销入口；注销按 5.3 逐表策略处理数据；注销前二次确认 |
| 密码 | BCrypt 哈希存储，接口与日志全程不出现明文密码 |
| Token | 遵守 6.1 Token 安全规则：不输出到日志/异常/调试输出，不经普通业务接口返回，Refresh Token 不出 UI 层 |
| 传输 | 全链路 HTTPS |
| 权限 | module.json5 仅申请实际使用的权限（如通知），并在隐私政策中说明用途 |
| 日志 | 禁止打印 Token、密码、完整用户隐私字段 |
| 游客身份 | 仅使用客户端生成的随机 UUID，不采集硬件指纹（见 6.1 游客约定） |
| 上传文件 | 文件类型白名单校验 + 大小限制；存储目录不可被 App 端直接访问；文件内容不进入任何日志；解析只经受控 DocumentParser（见 14.4 规则 8） |

---

## 九、内容生产与版权规范

### 9.1 内容量目标

| 内容 | 数量 |
| --- | --- |
| 常识知识点 | ≥ 200 条（每分类 ≥ 20） |
| 成语 | ≥ 300 条（含易混、误用字段） |
| 单选题 | ≥ 500 道，全部至少关联一个知识点或成语 |

### 9.2 内容来源规则（强制）

```text
常识：自建内容 / 公共领域资料 / 合法授权内容
成语：自建解释 / 合法词典资料 / 授权内容
题目：原创题 / 合法授权题 / 合法公开真题
```

> **禁止直接抓取或复制商业题库、培训机构题库、未经授权的真题解析。**"真题解析"不得默认可以直接复制；录入时必须记录来源信息（source_type 与 source_name 或 source_document_id / source_title）以便溯源。

### 9.3 内容录入通道（两条，均须可追溯）

```text
通道一：管理后台人工录入（P3）
  知识点/成语必填 source_type；题目必填 source_type + source_name

通道二：知识库文档导入（P3.5，详见第十章）
  文档上传 → 解析 → 待审核草稿 → 人工审核 → 入库
  入库时自动回写 source_type=4 / source_document_id / source_title

禁止绕过审核直接写库（初始分类等种子数据除外）。
```

---

## 十、知识库导入系统设计

### 10.1 定位与总体流程

> **文件是"知识库原材料"，MySQL 才是最终可供 App 使用的结构化知识库。**
> App 不直接读取 Word/PDF；所有文档内容必须经过"解析 → 草稿 → 人工审核"才能进入正式表，形成 **内容生产 → 解析 → 审核 → 发布 → 使用** 的完整 CMS 流程。

```text
Word / PDF / TXT
    ↓
管理后台上传（zhikao-admin 知识库导入中心）
    ↓
Spring Boot 文件接收（FileStorage，原始文件永久保留）
    ↓
文档解析服务（PDFBox / POI，受控解析唯一入口）
    ↓
文本提取 + 结构化识别（规则切分）
    ↓
生成"待审核内容"（import_record，草稿）
    ↓
管理员审核（编辑 / 通过 / 驳回 / 重新提交）
    ↓
正式入库 MySQL（knowledge / idiom / question，回写来源字段）
```

### 10.2 支持格式与版本计划

| 版本 | 能力 |
| --- | --- |
| V1.0 | 普通 PDF / DOCX / DOC / TXT 上传 → 文本解析 → 规则结构化草稿 → 人工审核 → 入库；**不做 OCR、不做 AI 结构化** |
| V1.5 | 扫描版 PDF 的 OCR 识别 |
| V2.0 | AI 结构化：自动分类、自动提取知识点、自动生成摘要与易错点，管理员审核 |

文档类型枚举 `file_type`：

```text
TEXT_PDF     普通 PDF（有文本层，PDFBox 直接解析）
SCANNED_PDF  扫描版 PDF（图片型、无文本层；V1.0 识别后拒绝解析并提示 4003）
DOCX / DOC   Word（POI 解析，保留标题/段落/表格/列表结构）
TXT          纯文本
```

### 10.3 状态机与审核红线（v1.3 补完整）

**import_document.status 状态机：**

```text
状态转换：
0 UPLOADED  → 1 PARSING      （触发解析）
1 PARSING   → 2 PARSED       （解析成功，产生可审核草稿）
1 PARSING   → 5 FAILED       （解析失败，记录 error_message）
5 FAILED    → 1 PARSING      （重新解析）
2 PARSED    → 3 REVIEWING    （存在待审核草稿，进入审核）
3 REVIEWING → 4 COMPLETED    （全部草稿均已处理，见完成定义）
3 REVIEWING → 3 REVIEWING    （仍存在待审核草稿，维持审核中）
2/3/5       → 1 PARSING      （重新解析，见重新解析规则）

已完成（4 COMPLETED）的定义：
  该文档下不存在待审核（0）草稿，且满足以下之一：
  a) 至少一条草稿已审核通过入库（success_count ≥ 1）
  b) 全部草稿均被驳回（success_count = 0 且无待审核项）

重新解析规则：
  仅允许从状态 2/3/5 触发；状态 4 不允许重新解析（如需再导入按新文档上传）
  重新解析只把待审核（0）与已驳回（2）草稿置为已失效（3 INVALIDATED）
  已通过入库（1）的草稿及其对应正式内容不受影响
```

**import_record.status 状态机：**

```text
0 PENDING_REVIEW → 1 APPROVED      （approve：写正式表，回写 target_id 与来源字段，终态）
0 PENDING_REVIEW → 2 REJECTED      （reject：必填 error_message）
2 REJECTED       → 0 PENDING_REVIEW（编辑后调用 submit API 重新提交审核）
0/2              → 3 INVALIDATED   （文档重新解析时旧草稿批量失效）
1 APPROVED 为终态，不可变更；后续内容修正走正式内容管理流程（编辑/下架）
```

**审核红线（V1.0 与 V2.0 均强制）：**

> 机器解析或 AI 生成的任何内容（含 V2.0 AI 结构化输出）只能成为草稿（import_record），**禁止直接写入 knowledge / idiom / question 正式表**；draft → published 必须经过人工审核。

### 10.4 结构化识别规则（V1.0 基于规则）

```text
1. 切分：按章节标题（"第X章"、"一、"、数字编号标题）把文档切分为多个知识点块
2. 字段映射（标记词识别）：
   "一句话记忆 / 核心知识 / 重点 / 易错点" → summary / content / key_points / common_mistakes
3. 成语条目识别："成语 + 拼音 + 释义 + 出处 + 例句"结构 → 成语草稿
4. 题目识别："题干 + A~D 选项 + 答案 + 解析"结构 → 题目草稿
   （题目与知识点/成语的关联在审核环节人工指定）
5. 兜底：无法识别的段落完整保留在 parsed_content 与 raw_excerpt，由审核人工处理
6. 分类：规则猜测 + 审核页下拉框人工确认
```

> 不追求 100% 自动识别率：**识别失败不得导致导入任务整体失败；所有无法结构化的原文必须进入待审核草稿；人工可以手工转换为正式内容。**

### 10.5 来源追溯

入库时回写来源字段（表结构见 5.2）：

```text
knowledge / idiom：
  source_type = 4（文档导入）
  source_document_id = import_document.id
  source_title = 原始文件名（如"公务员常识知识汇总.pdf"）

question：
  source_document_id = import_document.id
  （真题来源信息仍用 source_type / source_name / exam_year / province / question_no）
```

追溯场景：

```text
发现知识点有误 → 查看来源 → 公务员常识知识汇总.pdf
→ 定位 import_record 与原文摘录 → 修正后重新发布
```

### 10.6 文件存储规范

```text
数据库（import_document）只存元数据；原始文件走 FileStorage：
  开发阶段：本地磁盘 uploads/{knowledge, idiom, question}/
  生产阶段：MinIO / OSS / OBS（FileStorage 接口抽象，业务代码不感知切换）
原始文件解析完成后不删除，永久保留，供复核与版权溯源。
```

### 10.7 批量导入

```text
支持一次上传多个文件（≤10 个/批），每个文件对应一条 import_document
任务面板汇总：总文件数 / 解析成功数 / 识别知识点数 / 成语数 / 题目数 / 待审核条数
支持批量审核（勾选多条草稿一键通过/驳回）
部分成功机制：批量操作（多文件上传、批量审核）逐条处理、逐条返回结果，
单条失败不中断、不影响已成功条目；失败条目保留 error_message 供重试
```

### 10.8 V2.0 AI 结构化预留流程

```text
PDF / Word → 文本解析 → 规则分段 → AI 结构化（输出 JSON 草稿）→ import_record → 人工审核 → 正式入库
```

> AI 输出示例字段：title / category / summary / keyPoints / commonMistakes。
> 再次强调：**AI 只能生成草稿，不能直接成为正式知识。**

---

## 十一、开发任务拆解（可直接交付 Agent 执行）

> 任务按依赖顺序编号；每个任务给出目标、产出物与量化验收标准；每个任务的完成以 14.2 完成定义（DoD）为准。
> 阶段顺序：管理后台提前至 P3（内容录入是 P5/P6 验证的前置依赖）；P3 与 P4 之间为 **P3.5 知识库文档导入系统**。

### P1 基础工程（客户端骨架）

| # | 任务 | 产出 | 验收标准（量化） |
| --- | --- | --- | --- |
| T1.1 | 创建 HarmonyOS 项目，配置 AppScope/module.json5、bundleName、版本，固定 compatibleSdkVersion | 可运行的空工程 | DevEco Studio 编译通过并安装到模拟器；build-profile.json5 中可读到固定 SDK 版本 |
| T1.2 | 建立目录骨架（含 types/enums/mapper/store/assets），落实 3.1 层职责约定 | 目录与占位文件 | 目录结构与本任务书 3.1 一致 |
| T1.3 | 统一路由封装：NavigationService + RouterManager + RouteConstants，全部页面经 Navigation 跳转 | 路由基建 | 业务代码中不出现底层路由 API 直接调用（代码检索为零）；未登录访问受保护页面跳转登录页 |
| T1.4 | 主容器 MainPage + TabBar（首页/学习/练习/复习/我的） | 5 Tab 切换 | Tab 切换 10 次无异常，选中态样式正确 |
| T1.5 | HttpClient 封装：baseURL、超时、Token 注入、2001 触发 refresh、refresh 失败跳登录、统一错误码映射 | HttpClient.ets | 断网、5000、2001+刷新成功、2002 跳登录 4 种场景均有正确兜底 |
| T1.6 | TokenService（Preferences 存取 Access/Refresh Token 与用户信息）+ GuestIdService（游客 UUID 生成与持久化） | TokenService.ets / GuestIdService.ets | 冷启动可读取登录态；登出后本地 Token 清空；游客 UUID 首次启动生成且重启后不变 |
| T1.7 | 全局状态 store（AppStorage：用户信息、登录态、主题）+ 主题色常量 | store 与主题基建 | 修改 store 后相关页面 1 帧内响应刷新；代码中不出现 LocalStorage 持久化业务数据 |
| T1.8 | 通用组件 EmptyView/LoadingView/ErrorView（含重试按钮） | 三态组件 | 三种状态可演示切换；ErrorView 点击重试触发重新请求 |

### P2 后端基础

| # | 任务 | 产出 | 验收标准（量化） |
| --- | --- | --- | --- |
| T2.1 | 创建 Spring Boot 工程，引入 Web/MyBatis-Plus/Security/JWT/Validation/Redis/knife4j/PDFBox/POI | 可启动工程 | `mvn spring-boot:run` 启动成功 |
| T2.2 | 统一响应 Result、6.1 错误码表落地、全局异常处理、参数校验 | common 包 | 构造非法参数返回 1001 且格式统一 |
| T2.3 | 数据库建表 schema.sql（含 question 来源字段、password_hash、user_type/guest_uuid、import_document / import_record、**5.4 全部索引**）+ 初始分类 init-data.sql | 建表脚本 | 全部 19 张表与 5.4 所列索引创建成功；9+5 个分类入库；无任何明文密码字段 |
| T2.4 | 认证闭环：注册/登录/游客（UUID → user 表 user_type=2 记录）/refresh/登出/注销账号；Access 30 分钟 + Refresh 7 天（Redis 存储） | AuthController | 测试脚本走通：注册→登录→Access 过期→refresh 续期→登出→refresh 失效（2002）；游客 UUID 首次换取 Token 时创建 user_type=2 记录，二次换取复用同一 user_id；注销按 5.3 定死策略执行（user_answer 等行为数据为 DELETE） |
| T2.5 | Redis 配置与缓存工具封装（内容缓存 + 任务锁） | RedisConfig | 缓存读写可用；任务锁并发测试不重复生成 |
| T2.6 | 接口文档（knife4j） | /doc.html | 所有已实现接口可在文档中调试 |

### P3 管理后台最小版（提前，支撑内容录入）

| # | 任务 | 产出 | 验收标准（量化） |
| --- | --- | --- | --- |
| T3.1 | Vue3+TS+Vite+Element Plus 工程 + 管理员登录 + /admin/** 独立鉴权 | 后台骨架 | 普通用户 Token 访问 /admin 返回 3001 |
| T3.2 | 知识点管理页（新增/编辑/搜索/上下架/分类管理，无物理删除；录入必填来源字段） | 管理页面 | 完整录入一条知识点并在 App 接口可查到；下架后 App 列表不返回 |
| T3.3 | 成语管理页（新增/编辑/搜索/多分类/上下架） | 管理页面 | 同上；一个成语可挂多个分类 |
| T3.4 | 题目管理页（题干+动态选项 2~6 个+唯一正确答案+解析+关联知识点/成语+来源信息） | 管理页面 | 提交 2 个正确选项被拒（1003）；**知识点与成语均未关联被拒（1003）**；仅关联成语或仅关联知识点可保存；录入后 App 可练到 |
| T3.5 | 结构化数据导入兜底（Excel/SQL 脚本导入知识点、成语、题目；与 P3.5 文档导入互补） | 导入脚本 | 一次性导入 100 条无重复无报错 |

### P3.5 知识库文档导入系统

| # | 任务 | 产出 | 验收标准（量化） |
| --- | --- | --- | --- |
| T3.6 | 文件上传与存储基础：multipart 上传接口（类型白名单 .pdf/.docx/.doc/.txt、单文件 ≤20MB、批量 ≤10 个）、FileStorage 抽象接口 + 本地磁盘实现 uploads/{knowledge,idiom,question}/、import_document 落库（status=0） | 上传接口 + 存储层 | 上传成功生成 import_document 记录且文件落盘；非法类型返回 4001；超 20MB 返回 4002；正式内容表零写入 |
| T3.7 | 文档解析服务：DocumentParser 接口 + PdfParser（PDFBox）/WordParser（POI，保留标题/段落/表格/列表）/TxtParser；异步解析与状态流转（0→1→2/5）；扫描 PDF 识别（无文本层 → SCANNED_PDF，返回 4003） | document/parser + DocumentImportService | 普通 PDF 与 DOCX 能提取文本与结构块；扫描版 PDF 标记 SCANNED_PDF 并提示 4003，不阻塞其他文件；解析异常 status=5 且有 error_message；重复触发解析不产生重复草稿（幂等） |
| T3.8 | 结构化识别 ContentExtractService：按标题/编号切分多个草稿；标记词字段映射（一句话记忆/核心知识/重点/易错点）；成语与题目条目结构识别；写入 import_record（status=0 待审核），无法识别段落保留原文 | ContentExtractService | 给定结构化样本文档能正确切分为 N 条知识点草稿且字段映射正确；每条草稿可回溯 document_id 与 raw_excerpt；**任一段落识别失败不得导致导入任务整体失败；所有无法结构化的原文必须进入待审核草稿，人工可手工转换为正式内容** |
| T3.9 | 审核流程：待审核列表/详情（草稿+原文对照）/编辑/通过/驳回/**重新提交（submit）** API 与后台页面；通过时写入正式表并回写 target_id 与来源字段（source_type=4 / source_document_id / source_title）；驳回必填 error_message；import_document 状态机按 10.3 流转（含完成定义与重新解析规则） | 审核页面 + ImportReviewService | 草稿通过后出现在 App 列表且来源可查；驳回草稿不入库；**已驳回草稿编辑后调用 submit 回到待审核（status 2→0），非驳回状态调用 submit 返回 4004**；全部草稿处理完后文档置为已完成（4）；已入库草稿再编辑返回 4004；total_sections/success_count/failed_count 统计正确 |
| T3.10 | 批量导入与任务统计：多文件一次上传，任务面板展示（总文件/解析成功/识别知识点数/成语数/题目数/待审核数）；批量审核（逐条处理、逐条返回结果） | 批量导入页面 | 4 个文件批量上传后统计数字正确；勾选 50 条草稿一键通过全部入库且状态流转正确；**构造 1 条非法草稿时其余 49 条正常入库，失败条目返回 error_message** |
| T3.11 | 来源追溯闭环：后台知识点/成语/题目详情展示来源文件信息，支持从正式内容跳转 import_record 与原文摘录 | 追溯入口 | 任一条导入内容可端到端追溯到源文档；手工录入内容正确显示对应 source_type |

### P4 用户系统与首页

| # | 任务 | 产出 | 验收标准（量化） |
| --- | --- | --- | --- |
| T4.1 | 客户端启动页：Token 校验→主页/登录页分流 | SplashPage | 有有效 Token 进主页；无 Token 进登录页；2002 清除本地态进登录页 |
| T4.2 | 首次启动隐私政策+用户协议弹窗、协议展示页、注册/登录页（用户名+密码、表单校验） | AgreementPage/LoginPage/RegisterPage | 未同意协议不初始化网络请求；完整走通注册→登录→主页 |
| T4.3 | 游客模式：游客 UUID（Preferences 持久化）换取游客 Token、每日限额（详情各 5 次、答题 5 道）、9001 登录引导 | GuestService + 客户端引导 | 游客第 6 次打开详情返回 9001 并弹出登录引导；同一设备重启后游客身份与限额延续（同一 user_id）；服务端不采集硬件指纹（代码审查确认） |
| T4.4 | 后端 /home/overview（含复习积压数，响应符合 6.13 示例）、/home/recommend（7.6 算法，含数量与去重规则）+ 每日任务懒加载（7.4，含 done_count 幂等计数键） | 首页接口 | 新用户返回默认任务；构造 87 个到期项时复习任务 targetCount=20 且 overview 返回 reviewPendingTotal=87；推荐返回常识 3 条 + 成语 3 条且无重复 targetId；同一知识点连续两次上报学习，常识积累任务 done_count 只增加 1 |
| T4.5 | 客户端首页：用户信息、连续天数、今日完成度、任务卡片（复习卡展示"建议复习 X 个，还有 Y 个待复习"）、快捷入口、推荐区 | HomePage | 服务端返回 todayCompleted=5/todayTarget=10 时客户端显示 5/10；各入口可跳转 |
| T4.6 | 学习行为上报与连续天数更新逻辑（服务端公共逻辑，含时长防刷约束） | StudyService | 模拟连续 3 天上报 streak_days=3；间隔 1 天再上报重置为 1；上报 durationSeconds=3600 被裁剪为 1800 |

### P5 常识与成语模块

| # | 任务 | 产出 | 验收标准（量化） |
| --- | --- | --- | --- |
| T5.1 | 后端常识接口：分类/列表/详情（含相关真题反查）/学习上报/收藏/已掌握 | KnowledgeController | 接口文档全部可调通；size=51 被限制为 50；keyword 命中 title/summary/content |
| T5.2 | 后端成语接口：分类/列表/详情（含相关题目反查）/学习上报/收藏 | IdiomController | 同上；keyword 命中 word/pinyin/explanation |
| T5.3 | 客户端常识分类页 + 列表页（分页加载、搜索、掌握度徽标） | 2 个页面 | 连续加载 5 页无崩溃；分页无重复数据无遗漏；加载失败可重试；首屏有 Loading 状态 |
| T5.4 | 客户端常识详情页（一句话记忆/核心知识/重点/易错点/相关真题列表/收藏/已掌握按钮） | KnowledgeDetailPage | 全部字段渲染；相关真题来自 question 反查且可跳转练习；收藏与已掌握状态即时更新 |
| T5.5 | 客户端成语分类/列表/详情页 | 3 个页面 | 同 T5.3/T5.4；易混成语与常见误用区块正确展示 |
| T5.6 | 收藏列表页（知识点/成语两个 Tab） | FavoritePage | 收藏项可取消、可跳转详情；取消后刷新不再出现 |

### P6 练习与错题模块

| # | 任务 | 产出 | 验收标准（量化） |
| --- | --- | --- | --- |
| T6.1 | 后端组卷逻辑：每日挑战（混合）、专项（按 ref_type/ref_id）、随机；答案服务端判定；答题写入 user_answer；错题自动入 wrong_question；联动 user_knowledge/user_idiom 掌握度；practice_session 正确记录 type/ref_type/ref_id | PracticeService | 三种组卷各抽题正确；构造答错用例后 wrong_question 出现该题且 wrong_count=1；返回体不含正确答案字段；专项训练（ref_type=1, refId=某分类）抽题全部属于该分类 |
| T6.2 | 客户端练习入口页（三种模式选择） | PracticePage | 三种模式可发起 |
| T6.3 | 客户端答题页：题号进度、选项单选、提交、即时判分、答案解析面板、关联知识点/成语跳转、下一题 | AnswerPage | 完整答完一组题；判分与服务端一致；**每道错题都能跳转到其关联的知识点或成语**；重复提交同一题答案不重复计数（幂等） |
| T6.4 | 客户端练习结果页 | AnswerResultPage | 正确率 = 服务端 correct_count/total_count，精确一致 |
| T6.5 | 后端错题接口：列表（关联题目完整信息）/重练组卷/移出 | WrongQuestionController | 错题重练可生成场次；移出后列表不再返回（is_removed=1）；**管理员修改题目后，错题列表返回最新题目内容** |
| T6.6 | 客户端错题本页 | WrongQuestionPage | 列表展示错误次数与最近错误时间；再练、移出可用 |

### P7 复习系统（核心）

| # | 任务 | 产出 | 验收标准（量化） |
| --- | --- | --- | --- |
| T7.1 | 后端掌握度与调度核心：MasteryService、ReviewScheduleService（7.1/7.2 规则） | 核心服务 + 单元测试 | 单测覆盖：答对 stage+1、stage>=4 置掌握、stage>=5 置熟练且不再调度；答错 stage=max(stage-2,0)；超期判定正确 |
| T7.2 | 后端 /review/today 与 /review/sessions、复习结果提交、review_record 落库（响应符合 6.13 示例） | ReviewController | 构造 25 个到期项：pendingTotal=25、suggestedCount=20；提交答对后 next_review_time 前移对应档位；提交答错后回退两档；重复提交同一复习项不重复推进（幂等） |
| T7.3 | 客户端复习入口页：待复习总数、建议复习数、积压提示、三组分组卡片、开始复习 | ReviewPage | 数量与接口一致；无到期项显示空态文案 |
| T7.4 | 客户端复习过程页：回忆式交互（先展示题干→自答→揭示结果）、提交 | ReviewSessionPage | 完整复习流程可走通；20 项上限生效 |

### P8 学习统计

| # | 任务 | 产出 | 验收标准（量化） |
| --- | --- | --- | --- |
| T8.1 | 后端统计接口：overview/trend/daily-report（事实来源 = 明细表聚合，见 7.7） | StatsController | 每项统计值可由 study_record/user_answer 原始数据手工推导核对一致；故意篡改 user.total_study_minutes 后 /stats/overview 结果不受影响 |
| T8.2 | 客户端统计页：数据卡片 + 趋势图（ArkUI/Canvas 绘制） | StatsPage | 图表数据点与接口逐点一致 |
| T8.3 | 客户端我的页、学习记录页 | MinePage/StudyRecordPage | 入口齐全，记录时间线按时间倒序正确 |
| T8.4 | 后台用户管理 + 学习数据概览 | admin 页面 | 用户列表可搜索、禁用生效（被禁用用户登录返回 2003） |

### P9 鸿蒙特性与体验优化

| # | 任务 | 产出 | 验收标准（量化） |
| --- | --- | --- | --- |
| T9.1 | 深色模式（主题 token 切换 + 跟随系统） | 主题适配 | 两种模式全部页面无样式异常（逐页截图核对） |
| T9.2 | 页面转场与答题反馈动画 | 动效 | 动画期间操作无卡顿、无崩溃 |
| T9.3 | 学习提醒通知（用户设定时间提醒学习） | NotificationService | 到点弹出通知，点击拉起 App 到首页 |
| T9.4 | 网络异常/加载/空态全面覆盖、骨架屏 | 体验兜底 | 断网场景各页面不白屏，均有 ErrorView 或 EmptyView |
| T9.5 | 设置页完善：账号注销流程（按 5.3 定死策略：行为数据全部 DELETE、user 脱敏保留）、隐私政策/用户协议入口、关于 App | SettingsPage | 注销需二次确认；注销按 5.3 逐表策略执行（用测试账号逐表核验：9 张行为表记录为 0，user 表脱敏且 status=2）；注销后该账号登录返回 2003 |
| T9.6 | 桌面卡片（今日任务/待复习数）**（增强项）** | FormAbility | **增强项，非发布强制阻塞项**：若完成，卡片展示正确并可点击拉起对应页面；发布前未完成可顺延至 V1.0.x |
| T9.7 | 性能优化：列表懒加载、图片资源、冷启动优化 | 优化记录 | 冷启动 ≤ 3 秒（中端真机）；列表首屏加载 ≤ 2 秒（正常网络）；分页请求 ≤ 1.5 秒（正常网络）；连续滑动 1000 条数据的列表：无明显白屏、不出现连续卡顿、页面不崩溃 |

### P10 测试与发布（V1.0 发布前置）

| # | 任务 | 产出 | 验收标准（量化） |
| --- | --- | --- | --- |
| T10.1 | API 自动化测试（核心接口脚本化回归，含 6.12 导入接口与 6.13 契约比对） | 测试脚本 | 核心接口用例通过率 100%；响应字段命名与 6.13 契约一致 |
| T10.2 | 登录流程测试（注册/登录/refresh/游客/注销/禁用） | 测试记录 | 全部用例通过；游客用例覆盖：UUID 首次创建 user_type=2 记录、重启复用、限额、注销删除 |
| T10.3 | 学习流程测试（浏览/上报/收藏/已掌握） | 测试记录 | 全部用例通过 |
| T10.4 | 练习流程测试（三种组卷/判分/错题入库） | 测试记录 | 全部用例通过 |
| T10.5 | 复习算法测试（状态机全路径 + 边界：stage=0 答错、stage=5 答对、超期 2 天分组） | 测试报告 | 状态机全路径用例通过 |
| T10.6 | 数据一致性测试（答题→错题→掌握度→复习时间联动；文档导入→草稿→审核→入库→来源字段联动；import_document/import_record 状态机全路径） | 测试报告 | 全部联动链路与状态机用例数据无一处不一致 |
| T10.7 | HarmonyOS 真机测试（至少 2 款机型） | 测试记录 | 主流程真机无崩溃 |
| T10.8 | 弱网/断网测试 | 测试记录 | 弱网有加载提示不卡死；断网可恢复 |
| T10.9 | 冷启动与性能测试 | 测试报告 | 达到 T9.7 指标 |
| T10.10 | 发布包测试（签名、权限声明、隐私政策合规自查） | 发布清单 | 符合应用市场提交要求 |

### 内容准备（贯穿进行，遵守第九章版权规范，优先使用 P3.5 导入系统）

| # | 任务 | 说明 |
| --- | --- | --- |
| C.1 | 常识知识点 ≥ 200 条（每分类 ≥ 20） | 优先经知识库导入系统（上传资料→解析→审核→入库），辅以人工录入；每条记录来源 |
| C.2 | 成语 ≥ 300 条（含易混、误用字段） | 同上 |
| C.3 | 题目 ≥ 500 道单选题，全部至少关联一个知识点或成语，填写来源信息 | 同上；禁止抓取商业题库；导入题目在审核环节指定关联 |

---

## 十二、里程碑与验收

| 里程碑 | 包含任务 | 验收标准 |
| --- | --- | --- |
| M1 骨架跑通 | P1 + P2 | App 五 Tab 可切换；后端认证闭环（含 refresh）可用 |
| M2 内容录入能力 | P3 + P3.5 | 后台可完整录入知识点/成语/题目并入库；文档导入→解析→草稿→审核（含驳回重提）→入库与来源追溯全链路走通 |
| M3 用户与首页 | P4 | 用户可注册登录/游客体验，首页任务与推荐数据正确 |
| M4 内容闭环 | P5 | 可浏览学习常识与成语、收藏、相关真题反查正确 |
| M5 练习闭环 | P6 | 三种模式练习、判分、解析、错题自动记录全部走通 |
| M6 核心闭环 | P7 | 学习→练习→错题→掌握度→自动复习全链路走通（**V1.0 核心验收点**） |
| M7 数据闭环 | P8 | 统计数据可由原始记录推导验证，我的页完整 |
| M8 体验完整 | P9 | 深色模式、通知、设置与注销全部可用；桌面卡片（增强项）可选完成 |
| M9 V1.0 发布 | P10 + 内容准备 | 全部测试通过，内容量达标，提交应用市场 |

---

## 十三、建议执行顺序（总路线图）

```text
第 1 步  产品原型（本文档即基线）
第 2 步  MySQL 数据库设计落地（T2.3，含导入相关表与全部索引）
第 3 步  Spring Boot 后端骨架（P2）
第 4 步  HarmonyOS App 骨架（P1）
第 5 步  管理后台最小版（P3，支撑内容录入）
第 6 步  知识库文档导入系统（P3.5）
第 7 步  用户系统与游客模式（P4 前半）
第 8 步  首页与每日任务（P4 后半）
第 9 步  常识模块（P5 前半）
第 10 步 成语模块（P5 后半）
第 11 步 练习模块（P6 前半）
第 12 步 错题模块（P6 后半）
第 13 步 复习算法（P7）
第 14 步 学习统计（P8）
第 15 步 鸿蒙特性优化（P9，桌面卡片为增强项）
第 16 步 测试与发布（P10）
→ V1.0 发布
→ V1.5：手机号验证码登录；扫描版 PDF OCR
→ V2.0：AI 讲题 / AI 成语辨析 / AI 生成题目 / AI 学习计划 / AI 学习报告；
        知识库 AI 结构化解析；FSRS/SM-2 类复习算法评估；离线学习（RelationalStore）
```

---

## 十四、开发约束与工程规范

### 14.1 代码规范

```text
客户端（ArkTS）：
  页面以 Page 结尾，视图模型以 ViewModel 结尾，仓库以 Repository 结尾
  一个页面一个文件；组件复用抽取到 components/
  禁止在页面中直接调用网络请求，一律经 ViewModel → Repository

后端（Java）：
  遵循阿里巴巴 Java 开发手册（嵩山版）
  Controller 只做参数校验与转发；业务逻辑在 Service
  统一 Result 返回；禁止在接口中返回实体类裸对象
  DTO/VO 字段 camelCase，实体字段 snake_case，经映射层转换（见 6.13）
  内容数据接口禁止提供物理删除能力
```

### 14.2 完成定义（Definition of Done，v1.3 新增）

```text
每个任务 T*.* 必须同时交付以下全部材料，缺一视为未完成：
1. 可编译、可运行的代码
2. 对应的单元测试 / 接口测试（至少覆盖该任务的验收标准）
3. 数据库变更脚本（如涉及）同步进入 schema.sql / init-data.sql
4. 接口文档（knife4j 注解完整，/doc.html 可查看、可调试）
5. 自测记录（对照验收标准逐条勾选的结果）
6. 带任务号的 Git 提交与 PR（见 14.3）
"功能完成、测试没补"或"代码完成、文档没更新"一律视为未完成。
```

### 14.3 Git 提交规范

```text
分支模型：main（发布）+ develop（集成）+ feature/T<任务号>（任务分支）
提交信息：Conventional Commits，且必须带任务号
  示例：feat(T6.1): 实现每日挑战组卷与答题判定
  示例：fix(T7.1): 修正复习答错 stage 回退逻辑
合并：一个任务一个 PR，合入 develop 前需通过对应验收标准
```

### 14.4 Agent 执行规则（交付 Codex/Cursor 等编码 Agent 时强制）

```text
1. 严格按任务编号（T*.*）逐个执行，一次只做一个任务，完成后对照验收标准自测，
   并按 14.2 完成定义补齐测试、文档与提交材料。
2. 契约优先：API、数据库、枚举、错误码是唯一契约。确需变更时按固定顺序执行——
   先修改本任务书 → 再修改 DTO/VO → 再修改 Service → 最后修改客户端；
   禁止跳过任务书直接改代码；契约与代码一致性是 DoD 检查项。
3. HarmonyOS API 一律以锁定 SDK 版本的官方文档为准，不凭记忆使用已废弃 API；
   路由只用 Navigation 封装，状态管理只用本文档列出的机制（AppStorage + @State/@Prop/@Link）。
4. 内容数据不足时使用明确的 mock 数据（标注 mock），不得编造"真题"内容。
5. 不得引入本文档未列出的框架、数据库或第三方服务。
6. 每个任务产出的代码必须可编译、可运行，不提交半成品。
7. 知识库导入的解析产物与任何自动生成内容（含 V2.0 AI 输出）必须走
   import_record 人工审核流程，禁止直接写入 knowledge / idiom / question 正式表。
8. 上传文件必须先经过类型、大小、文件名和存储安全校验。
   文件只能作为数据文件处理，不得作为可执行文件执行；
   文件解析必须通过受控的 DocumentParser 完成（PDFBox/POI）；
   禁止动态加载、执行或调用上传文件中的任何代码；
   文件内容不得写入日志或返回给 App 端。
9. 写操作接口必须满足 6.1 幂等约定，重复请求不得造成重复计数或重复入库。
```

---

## 十五、风险与约束

| 风险 | 应对 |
| --- | --- |
| 内容录入量大（≥1000 条） | 管理后台已提前至 P3；P3.5 知识库导入系统为主力通道，T3.5 结构化导入兜底 |
| 内容版权风险 | 严格执行 9.2 来源规则；录入与导入均必填来源字段以便溯源 |
| 复习算法冷启动无数据 | 首页推荐按 7.6 优先级降级到"未学习/随机"规则 |
| 题目与知识点关联质量 | 录入时强制关联校验（至少关联一个知识点或成语，否则 1003）；导入题目在审核环节人工指定关联；后台提供"未关联题目"检查视图 |
| HarmonyOS API 持续演进 | 锁定 compatibleSdkVersion 与 DevEco Studio 版本；API 表述不写死模块名，以锁定版本文档为准 |
| 范围蔓延 | 严格执行 1.3 功能边界，新需求一律进 V1.5/V2.0 候选池 |
| 复习积压劝退 | 建议复习量上限 20 + 积压量分开展示（7.3） |
| 文档解析质量不稳定 | 解析产物一律进待审核草稿（10.3 审核红线）；识别失败不中断任务、原文全部保留可人工处理（10.4） |
| 扫描版 PDF 无法提取文本 | V1.0 识别后拒绝解析并提示（4003）；OCR 能力排入 V1.5 |
| 本地磁盘存储不满足生产 | FileStorage 接口抽象，生产切换 MinIO/OSS/OBS 不改业务代码 |
| 学习时长被客户端伪造 | durationSeconds 上限 1800 秒 + 客户端 300 秒无操作结束会话（6.1/5.2） |
| 汇总字段与明细数据不一致 | total_study_minutes 定位为冗余缓存，统计一律走明细聚合（7.7） |
| V1.0 范围过大 | 功能优先级排序（1.3），桌面卡片降为增强项，确保核心闭环优先交付 |

---

## 十六、V2.0 预留设计

V1.0 编码时为后续能力预留扩展点：

- `question.source_type = 4` 已为 AI 生成题预留；练习结果页预留"AI 讲题"入口位
- 统计模块数据结构支持生成学习报告（AI 学习报告的数据源）
- 服务端预留独立 AI Service 调用层接口定义
- 复习算法接口化设计（ReviewScheduleService 独立），V2.0 可替换为 FSRS/SM-2 实现
- user 表预留手机号验证码登录扩展；客户端本地存储预留 RelationalStore 离线方案
- 知识库导入演进路线：V1.5 扫描版 PDF OCR；V2.0 AI 结构化（自动分类/自动提取/摘要/易错点生成），**AI 产物仅作为草稿，必须人工审核后入库**（10.8）
- 文件存储 FileStorage 接口已抽象，生产环境可平滑切换 MinIO / OSS / OBS

> AI 是产品的增强功能，而不是产品本身。V1.0 的价值锚点始终是：常识/成语 → 学习 → 练习 → 错题 → 掌握度 → 自动复习 → 再次练习 这条闭环。

---

## 十七、文档冻结声明与开发起点（v1.4 新增）

### 17.1 冻结声明

```text
本任务书自 v1.4 起冻结为开发基线：
  开发过程中不再修改产品范围、阶段划分与验收标准；
  API、数据库、枚举、错误码等契约的变更仍按 14.4 契约优先流程走
  （先改任务书、走 PR 评审），但仅允许纠错性修订，不允许扩张需求；
  任何新想法一律记入 V1.5 / V2.0 候选池，不插入 V1.0 开发序列。
```

### 17.2 开发起点（冻结后的执行顺序）

```text
1. 创建三个 Git 仓库：zhikao-server / zhikao-harmonyos / zhikao-admin
   （按 14.3 分支模型初始化 main + develop）
2. 并行启动两个空工程：T2.1（Spring Boot 工程）与 T1.1（HarmonyOS 工程）
   先把后端与客户端空工程跑起来
3. 此后严格按任务编号逐个执行：T1.1 → T1.8、T2.1 → T2.6 ……
   一次只做一个任务，每个任务按 14.2 完成定义交付
4. 不提前设计页面细节，不让 Agent 一次性生成整个项目
```
