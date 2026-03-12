# 世界引擎 API 参考

## 目录

1. [核心API](#核心api)
2. [世界构建API](#世界构建api)
3. [区域管理API](#区域管理api)
4. [Agent运行时API](#agent运行时api)
5. [事件总线API](#事件总线api)
6. [查询与分析API](#查询与分析api)

---

## 核心API

### 初始化世界引擎

```rust
/// 初始化世界引擎
pub async fn initialize(config: EngineConfig) -> Result<WorldEngine> {
    // 创建各个组件
    let world_builder = WorldBuilder::new(&config.llm_config, &config.vector_db)?;
    let region_manager = RegionManager::new(&config.region_config)?;
    let event_bus = EventBus::new(&config.event_bus_config)?;
    let agent_runtime = AgentRuntime::new(&config.runtime_config)?;

    // 组装引擎
    Ok(WorldEngine {
        world_builder,
        region_manager,
        event_bus,
        agent_runtime,
        config,
    })
}

#[derive(Debug, Clone)]
pub struct EngineConfig {
    /// LLM配置
    pub llm_config: LLMConfig,
    /// 向量数据库配置
    pub vector_db: VectorDBConfig,
    /// 区域管理配置
    pub region_config: RegionConfig,
    /// 事件总线配置
    pub event_bus_config: EventBusConfig,
    /// Agent运行时配置
    pub runtime_config: RuntimeConfig,
}
```

### 启动仿真循环

```rust
impl WorldEngine {
    /// 启动主仿真循环
    pub async fn start(&self) -> Result<Handle> {
        let mut interval = tokio::time::interval(Duration::from_millis(16)); // 60 FPS

        loop {
            interval.tick().await;

            // 更新引擎
            self.update().await?;
        }
    }

    /// 单帧更新
    pub async fn update(&self) -> Result<()> {
        let context = self._build_context();

        // 1. 更新区域
        self.region_manager.update(context.observer_position, 0.016);

        // 2. 更新所有活跃Agent
        let active_agents = self.region_manager.get_active_agents();
        for agent in active_agents {
            if self.agent_runtime.should_update(agent) {
                self.agent_runtime.update(agent, &context).await?;
            }
        }

        // 3. 处理事件
        self.event_bus.process_pending().await?;

        Ok(())
    }
}
```

---

## 世界构建API

### 从种子构建世界

```rust
impl WorldBuilder {
    /// 从种子构建世界
    pub async fn build(&self, seed: WorldSeed) -> Result<WorldModel> {
        // 1. 分析种子
        let analysis = self.analyzer.analyze(&seed).await?;

        // 2. 生成规则库
        let rules = if analysis.is_real_world() {
            self.load_real_world_rules()?
        } else {
            self.generate_virtual_rules(&analysis).await?
        };

        // 3. 构建实体
        let entities = self.entity_builder.build(&analysis, &rules).await?;

        // 4. 验证世界
        let world = WorldModel::new(seed.name, rules, entities);
        self.validator.validate(&world)?;

        Ok(world)
    }
}

/// 世界种子
#[derive(Debug, Clone)]
pub struct WorldSeed {
    /// 世界名称
    pub name: String,
    /// 种子内容（文本/描述/小说等）
    pub content: String,
    /// 种子类型
    pub source_type: SeedSourceType,
}

#[derive(Debug, Clone)]
pub enum SeedSourceType {
    /// 文本描述
    Text,
    /// 小说
    Novel,
    /// 配置文件
    Config,
    /// URL
    Url(String),
}
```

### 规则生成API

```rust
impl RuleGenerator {
    /// 生成虚拟世界规则
    pub async fn generate_virtual_rules(
        &self,
        analysis: &SeedAnalysis,
    ) -> Result<RuleLibrary> {
        let prompt = self._build_rule_prompt(analysis);

        let response = self.llm.generate(GenerateRequest {
            prompt,
            max_tokens: 2000,
            temperature: 0.7,
        }).await?;

        let rules: RuleLibrary = serde_yaml::from_str(&response.text)?;
        Ok(rules)
    }

    /// 更新现有规则
    pub async fn update_rules(
        &self,
        existing: &RuleLibrary,
        update: RuleUpdateRequest,
    ) -> Result<RuleLibrary> {
        // 合并规则
        let mut rules = existing.clone();
        rules.merge(&update.new_rules);

        // 验证
        self.validator.validate(&rules)?;

        Ok(rules)
    }
}
```

### 实体构建API

```rust
impl EntityBuilder {
    /// 创建单个实体
    pub async fn create_entity(
        &self,
        template: EntityType,
        importance: f32,
    ) -> Result<Entity> {
        let entity = EntityFactory::create(&template, importance);

        // 如果重要性高，生成详细属性
        if importance > 0.8 {
            self._generate_detailed_attributes(&mut entity).await?;
        }

        Ok(entity)
    }

    /// 批量创建实体
    pub async fn create_entities_batch(
        &self,
        templates: Vec<(EntityType, f32)>,
    ) -> Result<Vec<Entity>> {
        let mut entities = Vec::new();

        for (template, importance) in templates {
            let entity = self.create_entity(template, importance).await?;
            entities.push(entity);
        }

        Ok(entities)
    }

    /// 推断实体关系
    pub async fn infer_relations(
        &self,
        entities: &[Entity],
    ) -> Result<Vec<Relation>> {
        let relations = self.relation_builder.build(entities).await?;
        Ok(relations)
    }
}
```

---

## 区域管理API

### 区域查询API

```rust
impl RegionManager {
    /// 获取区域列表
    pub fn get_regions(&self) -> Vec<Region> {
        self.regions.values().cloned().collect()
    }

    /// 根据位置查询区域
    pub fn get_region_at(&self, position: Vec3) -> Option<&Region> {
        for region in self.regions.values() {
            if region.bounds.contains(position) {
                return Some(region);
            }
        }
        None
    }

    /// 获取聚光灯区
    pub fn get_spotlight_region(&self) -> Option<&Region> {
        self.regions.values()
            .find(|r| r.region_type == RegionType::Spotlight)
    }

    /// 获取Agent所在区域
    pub fn get_agent_region(&self, agent_id: AgentId) -> Option<&Region> {
        for region in self.regions.values() {
            if region.agents.contains(&agent_id) {
                return Some(region);
            }
        }
        None
    }
}
```

### 状态转换API

```rust
impl RegionManager {
    /// 具象化Agent
    pub async fn hydrate_agent(
        &self,
        request: HydrationRequest,
    ) -> Result<HydrationResult> {
        let result = self.hydrator.hydrate(request).await?;

        // 添加到目标区域
        if let Some(region) = self.regions.get_mut(&request.target_region) {
            region.agents.push(result.agent.id);
        }

        Ok(result)
    }

    /// 抽象化Agent
    pub async fn dehydrate_agent(
        &self,
        agent_id: AgentId,
    ) -> Result<MacroStatistics> {
        let agent = self.get_agent(agent_id)?;
        let stats = self.dehydrator.dehydrate(&agent)?;

        // 从源区域移除
        if let Some(region) = self.get_agent_region(agent_id) {
            let region_id = region.id.clone();
            if let Some(region) = self.regions.get_mut(&region_id) {
                region.agents.retain(|id| id != &agent_id);
            }
        }

        Ok(stats)
    }

    /// 移动Agent到新区域
    pub async fn move_agent_to_region(
        &self,
        agent_id: AgentId,
        target_region_id: RegionId,
    ) -> Result<()> {
        let current_region_id = self.get_agent_region(agent_id)
            .ok_or_else(|| anyhow!("Agent不在任何区域"))?
            .id.clone();

        // 处理状态转换
        let current_region = self.regions.get(&current_region_id).unwrap();
        let target_region = self.regions.get(&target_region_id).unwrap();

        if current_region.region_type != target_region.region_type {
            if target_region.region_type == RegionType.Spotlight {
                // 具象化
                self.hydrate_agent(HydrationRequest {
                    agent_id,
                    source_region: current_region_id,
                    target_region: target_region_id,
                    macro_data: self.get_macro_stats(&current_region_id)?,
                    field_snapshot: self.get_field_snapshot(&target_region_id)?,
                    context: Default::default(),
                }).await?;
            } else {
                // 抽象化
                self.dehydrate_agent(agent_id).await?;
            }
        }

        Ok(())
    }
}
```

### 场变量API

```rust
impl FieldManager {
    /// 获取场变量值
    pub fn get_field_value(&self, field_name: &str, position: Vec3) -> f64 {
        if let Some(field) = self.fields.get(field_name) {
            self.query.get_field_value(field, position)
        } else {
            0.0
        }
    }

    /// 更新场变量
    pub fn update_field(&mut self, field_name: &str, position: Vec3, delta: f64) {
        if let Some(field) = self.fields.get_mut(field_name) {
            let value = self.query.get_field_value(field, position);
            field.grid.set_at(position, value + delta);
        }
    }

    /// 传播所有场变量
    pub fn propagate_all(&mut self, dt: f64) {
        for field in self.fields.values_mut() {
            *field = self.propagator.propagate(field.clone(), dt);
        }
    }

    /// 查询所有场变量快照
    pub fn get_snapshot(&self, position: Vec3) -> HashMap<String, f64> {
        let mut snapshot = HashMap::new();
        for (name, field) in &self.fields {
            snapshot.insert(name.clone(), self.query.get_field_value(field, position));
        }
        snapshot
    }
}
```

---

## Agent运行时API

### Agent管理API

```rust
impl AgentRuntime {
    /// 创建Agent
    pub async fn create_agent(&self, profile: AgentProfile) -> Result<Agent> {
        let agent = Agent::new(
            self._generate_id(),
            profile,
            self.config.default_cognitive_config.clone(),
        );

        // 初始化记忆系统
        self.memory.initialize(&agent).await?;

        Ok(agent)
    }

    /// 获取Agent
    pub fn get_agent(&self, agent_id: AgentId) -> Option<&Agent> {
        self.agents.get(&agent_id)
    }

    /// 更新Agent
    pub async fn update_agent(&mut self, agent_id: AgentId, update: AgentUpdate) -> Result<()> {
        let agent = self.agents.get_mut(&agent_id)
            .ok_or_else(|| anyhow!("Agent不存在"))?;

        agent.apply_update(update);

        Ok(())
    }

    /// 删除Agent
    pub async fn delete_agent(&mut self, agent_id: AgentId) -> Result<()> {
        self.agents.remove(&agent_id);
        self.memory.cleanup(agent_id).await?;

        Ok(())
    }
}
```

### 感知API

```rust
impl PerceptionModule {
    /// 执行感知
    pub async fn perceive(&self, agent: &Agent, context: &Context) -> Perception {
        Perception {
            environment: self._gather_environment(agent, context),
            fields: self._perceive_fields(agent.position),
            memories: self._retrieve_memories(agent, context).await,
            timestamp: context.current_time,
        }
    }

    /// 查询附近的Agent
    pub fn query_nearby_agents(&self, position: Vec3, radius: f64) -> Vec<AgentId> {
        self.spatial_index.query_range(position, radius)
    }

    /// 查询附近的实体
    pub fn query_nearby_entities(&self, position: Vec3, radius: f64) -> Vec<EntityId> {
        self.spatial_index.query_range(position, radius)
    }
}
```

### 决策API

```rust
impl DecisionModule {
    /// 执行决策
    pub async fn decide(&self, agent: &Agent, perception: &Perception) -> Decision {
        // 评估反应类型
        let reaction_type = self._assess_reaction(agent, perception);

        // 选择推理方式
        let response = match reaction_type {
            ReactionType::Fast => {
                self._fast_think(agent, perception).await
            }
            ReactionType::Deep => {
                self._deep_think(agent, perception).await
            }
        };

        self._parse_decision(response)
    }

    /// 强制重新思考
    pub async fn force_rethink(&self, agent: &mut Agent) -> Result<Decision> {
        // 收集感知
        let perception = self.perception_module.perceive(agent, &self.current_context()).await?;

        // 执行决策
        let decision = self.decide(agent, &perception).await?;

        // 应用决策
        agent.apply_decision(&decision);

        Ok(decision)
    }

    /// 快速推理（本地模型）
    async fn _fast_think(&self, agent: &Agent, perception: &Perception) -> LLMResponse {
        let cache_key = self._build_cache_key(agent, perception);

        // 检查缓存
        if let Some(cached) = self.cache.get(&cache_key) {
            return cached;
        }

        // 构建提示词
        let prompt = self._build_fast_prompt(agent, perception);

        // 调用本地模型
        let response = self.local_llm.generate(prompt).await;

        // 缓存结果
        self.cache.set(cache_key, response.clone());

        response
    }

    /// 深度推理（云端模型）
    async fn _deep_think(&self, agent: &Agent, perception: &Perception) -> LLMResponse {
        let prompt = self._build_deep_prompt(agent, perception);
        self.cloud_llm.generate(prompt).await
    }
}
```

### 行动API

```rust
impl ActionModule {
    /// 执行行动
    pub async fn execute(&self, agent: &mut Agent, intent: ActionIntent) -> ActionResult {
        // 验证可行性
        if !self._is_feasible(agent, &intent) {
            return ActionResult::failed("行动不可行");
        }

        // 根据类型执行
        let result = match intent.action_type {
            ActionType::Move => self._execute_move(agent, intent).await,
            ActionType::Speak => self._execute_speak(agent, intent).await,
            ActionType::Attack => self._execute_attack(agent, intent).await,
            ActionType::Interact => self._execute_interact(agent, intent).await,
            _ => ActionResult::ok(),
        };

        // 更新状态
        if result.success {
            self._update_agent_state(agent, &intent, &result);
            self._store_memory(agent, &intent, &result).await;
        }

        result
    }

    /// 移动
    async fn _execute_move(&self, agent: &mut Agent, intent: ActionIntent) -> ActionResult {
        let target = intent.target.position()?;

        // 规划路径
        let path = self.engine.find_path(agent.position, target)?;

        // 开始移动
        self.engine.start_move(agent.id, path, intent.emotion);

        ActionResult::ok()
    }

    /// 说话
    async fn _execute_speak(&self, agent: &mut Agent, intent: ActionIntent) -> ActionResult {
        let content = intent.parameters.get("content")?;

        // 生成语音
        let audio = self.engine.generate_speech(content, agent.voice_profile);

        // 发送事件
        self.event_bus.publish_speak(agent.id, content, intent.emotion).await?;

        ActionResult::ok()
    }
}
```

### 记忆API

```rust
impl MemorySystem {
    /// 添加记忆
    pub async fn add(&self, agent_id: AgentId, memory: Memory) {
        self.long_term.insert(agent_id, memory.clone()).await;
        self.update_importance(agent_id, memory.importance).await;
    }

    /// 检索相关记忆
    pub async fn retrieve(
        &self,
        agent_id: AgentId,
        query: &str,
        top_k: usize,
    ) -> Vec<Memory> {
        // 向量检索
        let embedding = self.embedder.embed(query).await;
        self.vector_db
            .search(agent_id, embedding, top_k)
            .await
    }

    /// 添加短期记忆
    pub async fn add_short_term(
        &self,
        agent_id: AgentId,
        content: String,
        expires_at: DateTime<Utc>,
    ) {
        let memory = ShortTermMemory {
            content,
            expires_at,
        };
        self.short_term.insert(agent_id, memory).await;
    }

    /// 清理过期记忆
    pub async fn cleanup(&self, agent_id: AgentId) {
        self.short_term.cleanup_expired(agent_id).await;
        self.long_term.compress(agent_id).await;
    }
}
```

---

## 事件总线API

### 事件发布API

```rust
impl EventBus {
    /// 发布事件
    pub async fn publish(&self, event: Event) -> Result<EventId> {
        self.publisher.publish(event).await
    }

    /// 批量发布
    pub async fn publish_batch(&self, events: Vec<Event>) -> Result<Vec<EventId>> {
        self.publisher.publish_batch(events).await
    }

    /// 发布移动事件
    pub async fn publish_move(
        &self,
        agent_id: AgentId,
        from: Vec3,
        to: Vec3,
    ) -> Result<EventId> {
        let event = Event::new(EventType::Move {
            from,
            to,
        }, agent_id);
        self.publish(event).await
    }

    /// 发布说话事件
    pub async fn publish_speak(
        &self,
        agent_id: AgentId,
        content: String,
        emotion: Option<Emotion>,
    ) -> Result<EventId> {
        let event = Event::new(EventType::Speak {
            content,
            emotion,
        }, agent_id);
        self.publish(event).await
    }

    /// 发布攻击事件
    pub async fn publish_attack(
        &self,
        attacker_id: AgentId,
        target_id: EntityId,
    ) -> Result<EventId> {
        let event = Event::new(EventType::Attack {
            target: target_id,
        }, attacker_id);
        self.publish(event).await
    }
}
```

### 事件订阅API

```rust
impl EventBus {
    /// 订阅事件
    pub async fn subscribe(
        &self,
        topics: Vec<String>,
        handler: EventHandler,
    ) -> Result<SubscriptionId> {
        let subscription = Subscription {
            id: self._generate_id(),
            topics,
            handler,
        };
        self.subscription_manager.add(subscription).await
    }

    /// 取消订阅
    pub async fn unsubscribe(&self, subscription_id: SubscriptionId) -> Result<()> {
        self.subscription_manager.remove(subscription_id).await
    }

    /// 条件订阅
    pub async fn subscribe_conditional(
        &self,
        condition: Condition,
        handler: EventHandler,
    ) -> Result<SubscriptionId> {
        let subscription = Subscription {
            id: self._generate_id(),
            topics: vec![],
            condition: Some(condition),
            handler,
        };
        self.subscription_manager.add(subscription).await
    }

    /// 地理订阅
    pub async fn subscribe_location(
        &self,
        position: Vec3,
        radius: f64,
        handler: EventHandler,
    ) -> Result<SubscriptionId> {
        let subscription = Subscription {
            id: self._generate_id(),
            topics: vec![],
            location_based: true,
            position,
            perception_radius: radius,
            handler,
        };
        self.subscription_manager.add(subscription).await
    }
}
```

### 事件查询API

```rust
impl EventStore {
    /// 获取事件
    pub async fn get(&self, event_id: EventId) -> Result<Option<Event>> {
        self.db.get_event(event_id).await
    }

    /// 查询事件
    pub async fn query(&self, filters: EventFilters) -> Result<Vec<Event>> {
        self.db.query_events(filters).await
    }

    /// 按时间范围查询
    pub async fn query_by_time_range(
        &self,
        start: DateTime<Utc>,
        end: DateTime<Utc>,
    ) -> Result<Vec<Event>> {
        self.query(EventFilters {
            start_time: Some(start),
            end_time: Some(end),
            ..Default::default()
        }).await
    }

    /// 按类型查询
    pub async fn query_by_type(&self, event_type: EventType) -> Result<Vec<Event>> {
        self.query(EventFilters {
            event_types: Some(vec![event_type]),
            ..Default::default()
        }).await
    }

    /// 搜索相似事件
    pub async fn search_similar(
        &self,
        event: Event,
        top_k: usize,
    ) -> Result<Vec<Event>> {
        self.vector_db.search_similar(event, top_k).await
    }
}
```

---

## 查询与分析API

### 状态查询API

```rust
impl WorldEngine {
    /// 获取世界状态快照
    pub async fn get_snapshot(&self) -> WorldSnapshot {
        WorldSnapshot {
            regions: self.region_manager.get_regions(),
            agents: self.agent_runtime.get_all_agents(),
            fields: self.region_manager.get_all_fields(),
            events: self.event_bus.get_recent_events(100),
        }
    }

    /// 查询Agent状态
    pub async fn get_agent_state(&self, agent_id: AgentId) -> Result<AgentState> {
        let agent = self.agent_runtime.get_agent(agent_id)
            .ok_or_else(|| anyhow!("Agent不存在"))?;
        Ok(agent.state.clone())
    }

    /// 查询区域状态
    pub async fn get_region_state(&self, region_id: RegionId) -> Result<RegionState> {
        let region = self.region_manager.get_region(region_id)
            .ok_or_else(|| anyhow!("区域不存在"))?;
        Ok(region.state.clone())
    }

    /// 查询场变量
    pub async fn get_field_at(&self, field_name: &str, position: Vec3) -> f64 {
        self.region_manager.get_field_value(field_name, position)
    }
}
```

### 统计分析API

```rust
impl AnalyticsModule {
    /// 获取Agent统计
    pub async fn get_agent_stats(&self) -> AgentStatistics {
        let agents = self.runtime.get_all_agents();

        AgentStatistics {
            total_count: agents.len(),
            by_region: self._count_by_region(&agents),
            by_occupation: self._count_by_occupation(&agents),
            by_mood: self._count_by_mood(&agents),
            average_health: self._average_health(&agents),
        }
    }

    /// 获取事件统计
    pub async fn get_event_stats(&self, time_range: TimeRange) -> EventStatistics {
        let events = self.event_bus.query_by_time_range(time_range).await?;

        EventStatistics {
            total_count: events.len(),
            by_type: self._count_by_type(&events),
            by_priority: self._count_by_priority(&events),
            by_source: self._count_by_source(&events),
        }
    }

    /// 获取世界演化趋势
    pub async fn get_trends(&self, metrics: Vec<Metric>, time_range: TimeRange) -> TrendReport {
        let mut trend_data = HashMap::new();

        for metric in metrics {
            let data = self._collect_metric_data(metric, time_range).await;
            trend_data.insert(metric, data);
        }

        TrendReport {
            time_range,
            trend_data,
        }
    }

    /// 行为分析
    pub async fn analyze_behavior(&self, agent_id: AgentId) -> BehaviorAnalysis {
        let agent = self.runtime.get_agent(agent_id).unwrap();
        let events = self.event_bus.get_agent_events(agent_id, TimeRange::last_day()).await;

        BehaviorAnalysis {
            action_frequency: self._analyze_action_frequency(&events),
            interaction_patterns: self._analyze_interactions(&events),
            mood_changes: self._analyze_mood_changes(&agent, &events),
        }
    }
}
```

---

## 完整使用示例

### 初始化世界并启动仿真

```rust
#[tokio::main]
async fn main() -> Result<()> {
    // 1. 初始化配置
    let config = EngineConfig::default();

    // 2. 初始化引擎
    let engine = initialize(config).await?;

    // 3. 从种子构建世界
    let seed = WorldSeed {
        name: "江湖世界".to_string(),
        content: include_str!("seeds/jianghu.txt").to_string(),
        source_type: SeedSourceType::Text,
    };

    let world = engine.world_builder.build(seed).await?;
    engine.load_world(world).await?;

    // 4. 订阅事件
    engine.event_bus.subscribe(
        vec!["event.*".to_string()],
        Box::new(|event| {
            println!("事件: {:?}", event.event_type);
        })
    ).await?;

    // 5. 启动仿真
    engine.start().await?;

    Ok(())
}
```

### 创建并控制Agent

```rust
// 创建Agent
let profile = AgentProfile {
    name: "张三".to_string(),
    occupation: "铁匠".to_string(),
    personality: vec![0.5, 0.3, -0.2], // 外向、稳定、消极
    abilities: HashMap::new(),
    relationships: HashMap::new(),
};

let agent = engine.agent_runtime.create_agent(profile).await?;

// 添加到区域
let region_id = engine.region_manager.get_spotlight_region()?.id.clone();
engine.region_manager.add_agent_to_region(agent.id, region_id).await?;

// 触发Agent思考
let decision = engine.agent_runtime.force_rethink(agent.id).await?;

// 执行行动
if let Some(intent) = decision.action_intent {
    engine.agent_runtime.execute_action(agent.id, intent).await?;
}
```

### 监控世界状态

```rust
// 获取快照
let snapshot = engine.get_snapshot().await?;

// 查询统计
let stats = engine.analytics.get_agent_stats().await;
println!("Agent总数: {}", stats.total_count);

// 查询场变量
let panic_level = engine.get_field_at("economic_panic", Vec3::new(100.0, 200.0, 0.0)).await;
println!("经济恐慌指数: {}", panic_level);

// 分析Agent行为
let analysis = engine.analytics.analyze_behavior("agent_001".to_string()).await;
println!("行为模式: {:?}", analysis.interaction_patterns);
```
