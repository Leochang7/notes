# 世界引擎 (World Engine)

一个支持百万级智能Agent并行运行的分布式仿真系统。系统采用分层架构，通过视界划分、状态降级、动态具象化等技术，在保证仿真实时性和一致性的同时，极大降低计算成本。

## 📚 文档目录

### 架构文档

| 文档 | 说明 |
|------|------|
| [世界引擎架构-总览](世界引擎架构-总览.md) | 系统整体架构、核心概念、技术选型 |
| [世界引擎模块设计-世界构建器](世界引擎模块设计-世界构建器.md) | 从种子自动生成世界模型的模块设计 |
| [世界引擎模块设计-区域管理器](世界引擎模块设计-区域管理器.md) | 三层区域划分与状态转换管理 |
| [世界引擎模块设计-Agent运行时](世界引擎模块设计-Agent运行时.md) | Agent的感知、决策、行动循环实现 |
| [世界引擎模块设计-事件总线](世界引擎模块设计-事件总线.md) | 全局事件发布、订阅、路由机制 |

### 参考文档

| 文档 | 说明 |
|------|------|
| [世界引擎API参考](世界引擎API参考.md) | 完整的API接口文档 |
| [世界引擎部署指南](世界引擎部署指南.md) | 本地开发与生产环境部署指南 |

---

## 🚀 快速开始

### 系统要求

- Docker 24.0+
- Docker Compose 2.20+
- NVIDIA GPU（可选，用于本地推理）

### 本地开发环境

```bash
# 1. 启动基础设施服务
docker-compose up -d

# 2. 等待服务就绪
docker-compose ps

# 3. 构建世界
cargo run --bin world_builder -- --seed seeds/jianghu.txt

# 4. 启动仿真
cargo run --bin engine -- --config config/development.yaml
```

### 生产环境部署

```bash
# 1. 创建命名空间
kubectl apply -f k8s/namespace.yaml

# 2. 部署基础设施
kubectl apply -f k8s/infra/

# 3. 部署应用
kubectl apply -f k8s/apps/

# 4. 检查状态
kubectl get pods -n world-engine
```

---

## 🏗️ 系统架构

### 核心设计理念

| 原则 | 说明 |
|------|------|
| **按需精度** | 根据观察者注意力分配计算资源 |
| **无缝坍缩** | 不同精度区域之间平滑转换 |
| **事件驱动** | 由事件触发而非时钟驱动 |
| **语义缓存** | 对相似查询进行语义级缓存 |
| **蜂群思维** | 相近Agent共享部分认知上下文 |

### 系统能力

- 最大Agent数量：100万+
- 实时互动Agent：100-1000个
- 区域转换延迟：<100ms
- Agent响应延迟：<50ms（本地模型）
- 语义缓存命中率：>80%

---

## 📦 核心模块

### 1. 世界构建器 (World Builder)

从"世界种子"（小说、描述文档、配置等）自动推导并生成完整的世界模型。

**功能：**
- 种子分析与类型识别
- 物理/非物理规则库生成
- 实体网络构建
- 世界验证

### 2. 区域管理器 (Region Manager)

管理虚拟世界的三层区域划分，处理区域之间的状态转换。

**三层区域：**
- 🟢 **聚光灯区**：玩家视野/观察焦点，LLM全精度驱动
- 🟡 **边缘区**：视距外但可能接触的区域，行为树+马尔可夫链
- 🔴 **黑盒区**：远程区域，统计方程+场变量

### 3. Agent运行时 (Agent Runtime)

执行Agent的感知、决策、行动三大核心循环。

**双模型架构：**
- **小脑（本地）**：0.5B-3B模型，本能反应，<50ms延迟
- **大脑（云端）**：7B-14B模型，深度决策，100-500ms延迟

### 4. 事件总线 (Event Bus)

全球范围内传递事件、协调各模块通信、处理异步事件流。

**功能：**
- 事件发布与订阅
- 主题/条件/地理路由
- 优先级/重复/速率过滤
- 事件持久化与回放

---

## 🔑 核心技术

### 视界划分 (Horizon Partitioning)

```
聚光灯区 (100m)  边缘区 (1km)  黑盒区 (>1km)
    ██████         ██████      ████████████
   ████████       ████████    ████████████████
  ████████████    ████████████  █████████████████
 ███████████████  ████████████ ████████████████████
```

### 状态具象化 (State Hydration)

当注意力从低精度区域转移到高精度区域时：

```
宏观统计数据 ──▶ 实例化Agent ──▶ 注入记忆 ──▶ LLM推理 ──▶ 生成行为
```

### 场变量传播 (Field Propagation)

宏观影响力像波纹一样在不同区域间传播：

```
黑盒区经济崩溃 ──▶ Economic_Panic_Index ↑ ──▶ 传播到聚光灯区
```

---

## 📊 性能优化

### 黑魔法技术

| 技术 | 说明 |
|------|------|
| **行为树集成** | LLM只负责关键决策，物理移动由传统代码控制 |
| **认知时钟降频** | Agent只在事件触发时思考，而非每帧 |
| **语义缓存** | 1000个相同问题只推理一次 |
| **共享记忆** | 区域内Agent共享环境上下文 |

### 关键指标

```
┌─────────────────────────────────────────────────────────┐
│                    性能监控面板                          │
├─────────────────────────────────────────────────────────┤
│  Agent总数: 1,000,000                                    │
│  聚光灯区: 500 | 边缘区: 5,000 | 黑盒区: 994,500       │
│                                                          │
│  推理延迟 (P95):                                          │
│    本地模型: 45ms                                         │
│    云端模型: 320ms                                       │
│                                                          │
│  缓存命中率: 87%                                         │
│  事件吞吐: 12,000 events/s                               │
│  CPU使用率: 65%                                          │
│  内存使用: 45GB / 128GB                                  │
└─────────────────────────────────────────────────────────┘
```

---

## 🛠️ API 使用示例

### 初始化世界

```rust
let config = EngineConfig::default();
let engine = initialize(config).await?;

let seed = WorldSeed {
    name: "江湖世界".to_string(),
    content: include_str!("seeds/jianghu.txt").to_string(),
    source_type: SeedSourceType::Text,
};

let world = engine.world_builder.build(seed).await?;
engine.load_world(world).await?;
```

### 创建Agent

```rust
let profile = AgentProfile {
    name: "张三".to_string(),
    occupation: "铁匠".to_string(),
    personality: vec![0.5, 0.3, -0.2],
    // ...
};

let agent = engine.agent_runtime.create_agent(profile).await?;
```

### 发布事件

```rust
// Agent说话
event_bus.publish_speak(
    agent_id,
    "你好，有什么可以帮你的吗？",
    Some(Emotion::friendly())
).await?;

// 紧急事件
event_bus.publish_attack(attacker_id, target_id).await?;
```

---

## 📈 监控与运维

### Prometheus 指标

```bash
# 请求速率
rate(http_requests_total[1m])

# Agent数量
world_engine_agents{type="spotlight"}

# LLM推理延迟
histogram_quantile(0.95, llm_inference_duration_seconds)

# 事件吞吐
rate(event_bus_published_total[1m])
```

### 告警规则

- HighErrorRate: 错误率 > 10%
- HighLatency: P95延迟 > 1s
- HighMemoryUsage: 内存使用 > 90%
- PodNotReady: Pod非就绪状态

---

## 🤝 贡献指南

欢迎贡献代码、文档和想法！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 LICENSE 文件

---

## 📮 联系方式

- 项目主页: [GitHub](https://github.com/your-org/world-engine)
- 问题反馈: [Issues](https://github.com/your-org/world-engine/issues)
- 邮件: contact@world-engine.io

---

## 📖 相关阅读

- [Oasis: A Virtual World Built by LLMs](https://example.com/oasis)
- [SocialAction: Behavior Framework](https://example.com/socialaction)
- [Behavior Trees for AI](https://example.com/behavior-trees)

---

**世界引擎** - 让虚拟世界真正"活"起来
