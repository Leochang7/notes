# 快速开始示例

这个示例展示如何快速启动一个简单的世界仿真。

## 1. 初始化引擎

```rust
use world_engine::{Engine, EngineConfig, WorldSeed};

#[tokio::main]
async fn main() -> Result<()> {
    // 加载配置
    let config = EngineConfig::from_file("config/development.yaml")?;

    // 初始化引擎
    let engine = Engine::initialize(config).await?;

    println!("世界引擎初始化完成！");

    Ok(())
}
```

## 2. 从种子构建世界

```rust
use world_engine::{Engine, WorldSeed, SeedSourceType};

#[tokio::main]
async fn main() -> Result<()> {
    let engine = Engine::initialize_default().await?;

    // 从文本种子构建世界
    let seed = WorldSeed {
        name: "江湖世界".to_string(),
        content: r#"
        这是一个武侠世界，拥有各大门派和武林高手。
        主要门派包括：少林寺、武当派、峨眉派、丐帮。
        世界中有正邪两道，正道门派维护江湖正义，
        邪派则追求力量不择手段。
        "#.to_string(),
        source_type: SeedSourceType::Text,
    };

    println!("正在构建世界...");
    let world = engine.world_builder().build(seed).await?;

    println!("世界构建完成！");
    println!("  - 实体数量: {}", world.entity_count());
    println!("  - 规则数量: {}", world.rule_count());

    Ok(())
}
```

## 3. 创建并控制Agent

```rust
use world_engine::{AgentProfile, Agent, ActionIntent, ActionType};

#[tokio::main]
async fn main() -> Result<()> {
    let engine = Engine::initialize_default().await?;

    // 创建Agent档案
    let profile = AgentProfile {
        name: "张三".to_string(),
        occupation: "铁匠".to_string(),
        personality: vec![0.5, 0.3, -0.2], // 外向、稳定、消极
        abilities: vec![
            ("铁匠技能".to_string(), 0.8),
            ("力量".to_string(), 0.7),
        ].into_iter().collect(),
        relationships: HashMap::new(),
    };

    // 创建Agent
    println!("正在创建Agent...");
    let agent = engine.agent_runtime().create_agent(profile).await?;

    // 添加到聚光灯区
    let spotlight_region = engine.region_manager().get_spotlight_region()?;
    engine.region_manager().add_agent_to_region(agent.id, spotlight_region.id).await?;

    println!("Agent创建成功: {}", agent.profile.name);

    // 触发Agent思考
    println!("正在触发Agent思考...");
    let decision = engine.agent_runtime().force_rethink(agent.id).await?;

    println!("Agent决策:");
    println!("  - 想法: {}", decision.thought);
    println!("  - 情绪: {:?}", decision.emotion);
    println!("  - 目标: {}", decision.goal.description);

    // 执行行动
    if let Some(intent) = decision.action_intent {
        println!("执行行动: {:?}", intent.action_type);
        engine.agent_runtime().execute_action(agent.id, intent).await?;
    }

    Ok(())
}
```

## 4. 订阅和处理事件

```rust
use world_engine::{Event, EventType, EventHandler};

async fn handle_player_interact(event: Event) {
    if let EventType::Dialogue(dialogue) = event.event_type {
        match dialogue {
            DialogueEventType::Speak { content, .. } => {
                println!("Agent说话: {}", content);
            }
            DialogueEventType::DialogueStart { with } => {
                println!("开始对话: {:?}", with);
            }
            _ => {}
        }
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let engine = Engine::initialize_default().await?;

    // 订听所有事件
    engine.event_bus().subscribe(
        vec!["event.*".to_string()],
        Box::new(|event| {
            println!("事件: {:?}", event.event_type);
            handle_player_interact(event);
        })
    ).await?;

    // 订听紧急事件
    engine.event_bus().subscribe(
        vec!["event.emergency.*".to_string()],
        Box::new(|event| {
            println!("⚠️  紧急事件: {:?}", event.event_type);
            // 触发所有Agent重新思考
            // engine.agent_runtime().force_rethink_all();
        })
    ).await?;

    println!("事件订阅完成，等待事件...");

    // 启动仿真循环
    engine.start().await?;

    Ok(())
}
```

## 5. 查询世界状态

```rust
use world_engine::{WorldSnapshot, AgentStatistics};

#[tokio::main]
async fn main() -> Result<()> {
    let engine = Engine::initialize_default().await?;

    // 获取世界快照
    println!("获取世界快照...");
    let snapshot = engine.get_snapshot().await?;

    println!("=== 世界状态 ===");
    println!("区域数量: {}", snapshot.regions.len());
    println!("Agent总数: {}", snapshot.agents.len());
    println!("待处理事件: {}", snapshot.events.len());

    // 查询Agent统计
    let stats = engine.analytics().get_agent_stats().await?;

    println!("\n=== Agent统计 ===");
    println!("总数: {}", stats.total_count);
    println!("按区域:");
    for (region, count) in stats.by_region {
        println!("  - {}: {}", region, count);
    }
    println!("按职业:");
    for (occupation, count) in stats.by_occupation {
        println!("  - {}: {}", occupation, count);
    }

    // 查询场变量
    let panic_level = engine.get_field_at(
        "economic_panic",
        Vec3::new(100.0, 200.0, 0.0)
    ).await;

    println!("\n经济恐慌指数: {:.2}", panic_level);

    Ok(())
}
```

## 6. 运行完整示例

```rust
use world_engine::*;

#[tokio::main]
async fn main() -> Result<()> {
    println!("🌍 世界引擎 - 快速开始示例");
    println!("================================");

    // 1. 初始化引擎
    println!("\n[1/6] 初始化引擎...");
    let config = EngineConfig::default();
    let engine = Engine::initialize(config).await?;

    // 2. 构建世界
    println!("[2/6] 构建世界...");
    let seed = WorldSeed {
        name: "小镇".to_string(),
        content: include_str!("../seeds/small_town.txt").to_string(),
        source_type: SeedSourceType::Text,
    };
    let world = engine.world_builder().build(seed).await?;
    engine.load_world(world).await?;

    // 3. 创建主角Agent
    println!("[3/6] 创建主角Agent...");
    let hero_profile = AgentProfile {
        name: "玩家".to_string(),
        occupation: "冒险者".to_string(),
        personality: vec![0.7, 0.5, 0.3],
        abilities: vec![
            ("剑术".to_string(), 0.9),
            ("冒险".to_string(), 0.8),
        ].into_iter().collect(),
        relationships: HashMap::new(),
    };
    let hero = engine.agent_runtime().create_agent(hero_profile).await?;

    // 4. 创建NPC Agent
    println!("[4/6] 创建NPC Agent...");
    let npc_profiles = vec![
        ("铁匠", vec![0.3, 0.2, -0.1]),
        ("商人", vec![0.6, 0.4, 0.0]),
        ("卫兵", vec![-0.2, 0.3, 0.5]),
    ];

    let mut npc_ids = Vec::new();
    for (name, personality) in npc_profiles {
        let profile = AgentProfile {
            name: name.to_string(),
            occupation: name.to_string(),
            personality,
            abilities: HashMap::new(),
            relationships: HashMap::new(),
        };
        let npc = engine.agent_runtime().create_agent(profile).await?;
        npc_ids.push(npc.id);
    }

    // 5. 添加所有Agent到聚光灯区
    println!("[5/6] 添加Agent到世界...");
    let spotlight = engine.region_manager().get_spotlight_region()?;
    engine.region_manager().add_agent_to_region(hero.id, spotlight.id).await?;
    for npc_id in npc_ids {
        engine.region_manager().add_agent_to_region(npc_id, spotlight.id).await?;
    }

    // 6. 启动仿真
    println!("[6/6] 启动仿真...");
    println!("\n✅ 世界启动完成！");
    println!("📍 玩家位置: {:?}", hero.state.position);
    println!("👥 Agent总数: {}", spotlight.agents.len());
    println!("\n按 Ctrl+C 停止仿真...\n");

    engine.start().await?;

    Ok(())
}
```

## 运行示例

```bash
# 编译示例
cargo build --example 01_quick_start

# 运行示例
cargo run --example 01_quick_start

# 或使用 make
make quick_start
```

## 输出示例

```
🌍 世界引擎 - 快速开始示例
================================

[1/6] 初始化引擎...
✅ 引擎初始化完成

[2/6] 构建世界...
✅ 世界构建完成
  - 实体数量: 150
  - 规则数量: 45

[3/6] 创建主角Agent...
✅ 主角创建成功: 玩家

[4/6] 创建NPC Agent...
✅ 创建3个NPC Agent

[5/6] 添加Agent到世界...
✅ 4个Agent已添加到聚光灯区

[6/6] 启动仿真...

✅ 世界启动完成！
📍 玩家位置: Vec3 { x: 0.0, y: 0.0, z: 0.0 }
👥 Agent总数: 4

按 Ctrl+C 停止仿真...

事件: Dialogue(Speak { content: "欢迎来到小镇！", emotion: Some(Emotion { valence: 0.8, arousal: 0.5, labels: ["友好"] }) })
Agent说话: 欢迎来到小镇！
```
