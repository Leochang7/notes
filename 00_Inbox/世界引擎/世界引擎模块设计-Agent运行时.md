# Agent运行时 (Agent Runtime)

## 1. 模块概述

Agent运行时负责执行Agent的感知、决策、行动三大核心循环。它根据Agent所在区域的精度要求，采用不同的计算方式（LLM驱动、行为树驱动、统计驱动），实现高效且合理的Agent行为模拟。

### 1.1 核心功能

```
Agent实体
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│                     Agent运行时                              │
├─────────────────────────────────────────────────────────────┤
│  1. 感知模块 (Perception Module)                            │
│     ├─ 环境感知（场变量、附近实体、事件）                    │
│     ├─ 记忆检索（长短期记忆）                                │
│     └─ 上下文构建                                            │
│                                                             │
│  2. 决策模块 (Decision Module)                              │
│     ├─ 本地小模型（本能反应、短对话）                        │
│     ├─ 云端模型（深度决策、世界观演进）                      │
│     └─ 行为树（常规动作执行）                                │
│                                                             │
│  3. 行动模块 (Action Module)                                │
│     ├─ 行为意图生成                                          │
│     ├─ 物理交互协调                                          │
│     └─ 状态更新与记忆存储                                    │
│                                                             │
│  4. 双模型协调器 (DualModel Coordinator)                     │
│     └─ 协调小脑和大脑的分工合作                              │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
Agent行为结果
```

### 1.2 Agent认知循环

```
┌─────────────────────────────────────────────────────────┐
│                    认知时钟触发                          │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  感知 (Perceive)                                        │
│  ├─ 收集环境信息（场变量、实体、事件）                   │
│  ├─ 检索相关记忆（RAG）                                   │
│  └─ 构建上下文                                           │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  决策 (Decide)                                          │
│  ├─ 评估反应类型（快速/慢速）                            │
│  ├─ 本地小模型：快速推理                                 │
│  └─ 云端模型：深度推理                                   │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  行动 (Act)                                             │
│  ├─ 生成行为意图（JSON）                                 │
│  ├─ 交由游戏引擎执行                                     │
│  └─ 更新状态与记忆                                       │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Agent数据结构

### 2.1 基础结构

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Agent {
    /// 唯一标识
    pub id: AgentId,
    /// 基础属性
    pub profile: AgentProfile,
    /// 当前状态
    pub state: AgentState,
    /// 记忆系统
    pub memory: MemorySystem,
    /// 行为树
    pub behavior_tree: Option<BehaviorTree>,
    /// 认知配置
    pub cognitive_config: CognitiveConfig,
    /// 运行时状态
    pub runtime: RuntimeState,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentProfile {
    /// 姓名
    pub name: String,
    /// 职业
    pub occupation: String,
    /// 性格（可描述为特征向量）
    pub personality: Vec<f32>,
    /// 能力值
    pub abilities: HashMap<String, f32>,
    /// 社会关系
    pub relationships: HashMap<AgentId, f32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentState {
    /// 位置
    pub position: Vec3,
    /// 生命值
    pub health: f32,
    /// 情绪状态
    pub emotion: Emotion,
    /// 当前目标
    pub current_goal: Option<Goal>,
    /// 当前活动
    pub current_activity: Option<Activity>,
    /// 感知的场变量
    pub perceived_fields: HashMap<String, f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Emotion {
    /// 情绪维度（Valence-Arousal-Dominance模型）
    pub valence: f32,      // 正负情绪 (-1.0 ~ 1.0)
    pub arousal: f32,       // 激活度 (0.0 ~ 1.0)
    pub dominance: f32,     // 掌控感 (-1.0 ~ 1.0)
    /// 具体情绪标签
    pub labels: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CognitiveConfig {
    /// 认知时钟频率
    pub tick_rate: Duration,
    /// 最后推理时间
    pub last_think_time: Instant,
    /// 本地模型ID
    pub local_model: String,
    /// 云端模型ID
    pub cloud_model: String,
    /// 是否使用云端模型
    pub use_cloud: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RuntimeState {
    /// 当前行为意图
    pub action_intent: Option<ActionIntent>,
    /// 待处理事件队列
    pub event_queue: VecDeque<Event>,
    /// 行为树执行状态
    pub bt_state: Option<BTState>,
}
```

### 2.2 记忆系统

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MemorySystem {
    /// 短期记忆（最近1小时）
    pub short_term: Vec<ShortTermMemory>,
    /// 长期记忆向量索引
    pub long_term_index: VectorIndex,
    /// 重要性记忆（高影响事件）
    pub important_memories: Vec<Memory>,
    /// 记忆压缩策略
    pub compression_strategy: CompressionStrategy,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Memory {
    /// 记忆内容
    pub content: String,
    /// 时间戳
    pub timestamp: DateTime<Utc>,
    /// 重要性 (0.0-1.0)
    pub importance: f32,
    /// 访问次数
    pub access_count: u32,
    /// 标签
    pub tags: Vec<String>,
    /// 关联的向量表示
    pub embedding: Option<Vec<f32>>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ShortTermMemory {
    /// 记忆内容
    pub content: String,
    /// 时间戳
    pub timestamp: DateTime<Utc>,
    /// 过期时间
    pub expires_at: DateTime<Utc>,
}
```

---

## 3. 感知模块 (Perception Module)

### 3.1 感知流程

```python
class PerceptionModule:
    def __init__(self, spatial_index, field_manager, memory_store):
        self.spatial = spatial_index
        self.fields = field_manager
        self.memory = memory_store
        self.perception_range = 100.0  # 感知范围（米）

    def perceive(self, agent: Agent, context: Context) -> Perception:
        """执行感知，构建上下文"""
        # 1. 收集环境信息
        environment = self._gather_environment(agent, context)

        # 2. 感知场变量
        fields = self._perceive_fields(agent.position)

        # 3. 检索相关记忆
        memories = self._retrieve_memories(environment, agent)

        # 4. 构建感知结果
        return Perception(
            environment=environment,
            fields=fields,
            memories=memories,
            timestamp=context.current_time
        )

    def _gather_environment(self, agent: Agent, context: Context) -> Environment:
        """收集周围环境信息"""
        # 1. 查询附近的实体
        nearby_entities = self.spatial.query_range(
            center=agent.state.position,
            radius=self.perception_range
        )

        # 2. 查询附近的Agent
        nearby_agents = [
            e for e in nearby_entities
            if e.type == "agent" and e.id != agent.id
        ]

        # 3. 查询附近的物品
        nearby_items = [
            e for e in nearby_entities
            if e.type == "item"
        ]

        # 4. 查询附近的事件
        nearby_events = self._query_nearby_events(agent.position, context)

        # 5. 环境属性
        weather = self._get_weather(agent.position, context)
        time_of_day = context.current_time.time()

        return Environment(
            nearby_agents=nearby_agents,
            nearby_items=nearby_items,
            nearby_events=nearby_events,
            weather=weather,
            time_of_day=time_of_day,
            agent_position=agent.state.position
        )

    def _perceive_fields(self, position: Vec3) -> Dict[str, f64]:
        """感知场变量"""
        return self.fields.query_all_fields(position)

    def _retrieve_memories(self, environment: Environment, agent: Agent) -> List[Memory]:
        """检索相关记忆（RAG）"""
        # 构建查询
        query = self._build_memory_query(environment, agent)

        # 向量检索
        memories = self.memory.vector_search(
            agent_id=agent.id,
            query=query,
            top_k=5
        )

        # 添加短期记忆
        short_term = self.memory.get_short_term(agent.id)

        return memories + short_term

    def _build_memory_query(self, environment: Environment, agent: Agent) -> str:
        """构建记忆查询"""
        # 提取关键信息
        key_elements = []

        # 附近实体
        for other_agent in environment.nearby_agents[:3]:
            key_elements.append(f"附近有{other_agent.name}")

        # 场变量
        for field_name, value in agent.state.perceived_fields.items():
            if abs(value) > 0.5:  # 只关注显著的场变量
                key_elements.append(f"{field_name}={value:.2f}")

        # 当前目标
        if agent.state.current_goal:
            key_elements.append(f"目标: {agent.state.current_goal.description}")

        return " ".join(key_elements)
```

### 3.2 注意力机制

```python
class AttentionMechanism:
    def filter_perception(self, perception: Perception, agent: Agent) -> FilteredPerception:
        """过滤感知，只关注重要信息"""
        # 1. 计算每个感知的重要性
        scores = {}

        # 附近Agent的重要性
        for other_agent in perception.environment.nearby_agents:
            distance = self._calculate_distance(agent, other_agent)
            relationship = agent.profile.relationships.get(other_agent.id, 0.0)
            score = self._calculate_attention_score(distance, relationship)
            scores[other_agent.id] = score

        # 事件的重要性
        for event in perception.environment.nearby_events:
            score = self._calculate_event_importance(event, agent)
            scores[event.id] = score

        # 2. 过滤低重要性信息
        threshold = self._get_attention_threshold(agent)
        filtered = self._apply_threshold(perception, scores, threshold)

        # 3. 按重要性排序
        sorted_filtered = self._sort_by_importance(filtered, scores)

        return sorted_filtered

    def _calculate_attention_score(self, distance: float, relationship: f32) -> f32:
        """计算注意力分数"""
        # 距离越近越重要
        distance_score = 1.0 / (1.0 + distance / 50.0)

        # 关系越好越重要
        relationship_score = (relationship + 1.0) / 2.0  # 归一化到[0,1]

        # 综合评分
        return distance_score * 0.7 + relationship_score * 0.3
```

---

## 4. 决策模块 (Decision Module)

### 4.1 决策流程

```python
class DecisionModule:
    def __init__(self, local_llm, cloud_llm, cache):
        self.local_llm = local_llm
        self.cloud_llm = cloud_llm
        self.cache = cache
        self.model_coordinator = DualModelCoordinator(local_llm, cloud_llm)

    def decide(self, agent: Agent, perception: Perception) -> Decision:
        """执行决策"""
        # 1. 评估反应类型
        reaction_type = self._assess_reaction(agent, perception)

        # 2. 选择推理方式
        if reaction_type == ReactionType.Fast:
            # 快速反应 - 使用本地小模型
            result = self._fast_think(agent, perception)
        else:
            # 深度思考 - 可能使用云端模型
            result = self._deep_think(agent, perception)

        # 3. 转换为决策
        decision = self._parse_decision(result)

        return decision

    def _assess_reaction(self, agent: Agent, perception: Perception) -> ReactionType:
        """评估反应类型"""
        # 1. 检查是否有紧急情况
        if self._is_emergency(perception):
            return ReactionType.Fast

        # 2. 检查是否是简单互动
        if self._is_simple_interaction(perception):
            return ReactionType.Fast

        # 3. 检查是否需要深度思考
        if self._needs_deep_thinking(agent, perception):
            return ReactionType.Deep

        # 默认使用快速反应
        return ReactionType.Fast

    def _is_emergency(self, perception: Perception) -> bool:
        """判断是否是紧急情况"""
        # 检查危险事件
        for event in perception.environment.nearby_events:
            if event.type in ["explosion", "attack", "fire"]:
                return True

        # 检查场变量
        for field_name, value in perception.fields.items():
            if "danger" in field_name and value > 0.7:
                return True

        return False
```

### 4.2 本地小模型推理（快速反应）

```python
def _fast_think(self, agent: Agent, perception: Perception) -> LLMResponse:
    """使用本地小模型快速推理"""
    # 1. 检查缓存
    cache_key = self._build_cache_key(agent, perception)
    cached = self.cache.get(cache_key)
    if cached:
        return cached

    # 2. 构建精简的提示词
    prompt = self._build_fast_prompt(agent, perception)

    # 3. 调用本地模型
    response = self.local_llm.generate(
        prompt=prompt,
        max_tokens=200,
        temperature=0.7
    )

    # 4. 缓存结果
    self.cache.set(cache_key, response, ttl=300)  # 5分钟过期

    return response

def _build_fast_prompt(self, agent: Agent, perception: Perception) -> str:
    """构建快速提示词"""
    return f"""
    你是{agent.profile.name}，一个{agent.profile.occupation}。
    性格：{agent.profile.personality}

    当前情绪：
    - 正负面：{agent.state.emotion.valence:.2f}
    - 激活度：{agent.state.emotion.arousal:.2f}

    周围环境：
    {self._format_perception_brief(perception)}

    请生成JSON格式的反应，包含：
    - thought: 一句话的想法
    - emotion: 当前情绪标签（从以下选择：开心、愤怒、悲伤、恐惧、焦虑、平静）
    - action_type: 动作类型（从以下选择：move、speak、attack、flee、wait）
    - action_target: 动作目标（位置、对象或agent_id）
    """
```

### 4.3 云端模型推理（深度决策）

```python
def _deep_think(self, agent: Agent, perception: Perception) -> LLMResponse:
    """使用云端模型深度思考"""
    # 1. 构建详细的提示词
    prompt = self._build_deep_prompt(agent, perception)

    # 2. 调用云端模型
    response = self.cloud_llm.generate(
        prompt=prompt,
        max_tokens=1000,
        temperature=0.8
    )

    return response

def _build_deep_prompt(self, agent: Agent, perception: Perception) -> str:
    """构建深度提示词"""
    return f"""
    你是{agent.profile.name}，一个{agent.profile.occupation}。

    【个人档案】
    性格：{self._format_personality(agent.profile.personality)}
    能力：{self._format_abilities(agent.profile.abilities)}
    关键特征：{agent.profile.traits}

    【当前状态】
    位置：{agent.state.position}
    生命值：{agent.state.health:.0f}%
    情绪：
      - 正负面：{agent.state.emotion.valence:.2f}
      - 激活度：{agent.state.emotion.arousal:.2f}
      - 掌控感：{agent.state.emotion.dominance:.2f}
    当前目标：{agent.state.current_goal.description if agent.state.current_goal else "无"}

    【环境感知】
    {self._format_perception_detail(perception)}

    【相关记忆】
    {self._format_memories(perception.memories)}

    【场变量影响】
    {self._format_fields(perception.fields)}

    【任务】
    根据以上信息，生成详细的决策。请返回JSON格式：

    {{
      "thought_process": "详细的思考过程",
      "immediate_thought": "此刻的想法",
      "emotion": {{
        "valence": -0.5,
        "arousal": 0.8,
        "labels": ["愤怒", "焦虑"]
      }},
      "goal": {{
        "description": "更新的目标描述",
        "priority": 0.8
      }},
      "action_sequence": [
        {{
          "action": "speak",
          "target": "player",
          "content": "说的话"
        }},
        {{
          "action": "move",
          "target": {{ "x": 10, "y": 20, "z": 0 }},
          "emotion": "angry"
        }}
      ]
    }}
    """
```

### 4.4 双模型协调器

```python
class DualModelCoordinator:
    def __init__(self, local_llm, cloud_llm):
        self.local = local_llm
        self.cloud = cloud_llm
        self.local_cache = LRUCache(maxsize=1000)
        self.cloud_cache = LRUCache(maxsize=100)

    def think(self, agent: Agent, perception: Perception) -> Decision:
        """协调使用小脑和大脑"""
        # 1. 尝试用本地模型
        try:
            local_decision = self._local_think(agent, perception)

            # 2. 评估是否需要云端模型
            if self._needs_cloud_validation(local_decision, agent):
                # 异步调用云端模型进行验证
                self._async_cloud_validate(agent, perception, local_decision)

            return local_decision

        except Exception as e:
            # 本地模型失败，降级到云端
            return self._cloud_think(agent, perception)

    def _needs_cloud_validation(self, decision: Decision, agent: Agent) -> bool:
        """判断是否需要云端验证"""
        # 高重要性事件需要验证
        if decision.importance > 0.8:
            return True

        # 影响他人的决策需要验证
        if decision.affects_others():
            return True

        return False

    def _async_cloud_validate(self, agent: Agent, perception: Perception, local_decision: Decision):
        """异步云端验证"""
        def validate():
            cloud_decision = self._cloud_think(agent, perception)
            if self._is_cloud_better(cloud_decision, local_decision):
                # 用云端决策覆盖
                agent.update_decision(cloud_decision)

        # 异步执行
        threading.Thread(target=validate).start()
```

---

## 5. 行动模块 (Action Module)

### 5.1 行动意图

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ActionIntent {
    /// 行动类型
    pub action_type: ActionType,
    /// 行动目标
    pub target: ActionTarget,
    /// 行动参数
    pub parameters: HashMap<String, Value>,
    /// 情绪表达
    pub emotion: Option<Emotion>,
    /// 预计持续时间
    pub estimated_duration: Option<Duration>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ActionType {
    /// 移动
    Move,
    /// 说话
    Speak,
    /// 攻击
    Attack,
    /// 逃跑
    Flee,
    /// 交互
    Interact,
    /// 等待
    Wait,
    /// 使用物品
    UseItem,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ActionTarget {
    /// 位置目标
    Position(Vec3),
    /// 实体目标
    Entity(EntityId),
    /// 无目标
    None,
}
```

### 5.2 行动执行

```python
class ActionModule:
    def __init__(self, game_engine, memory_store):
        self.engine = game_engine
        self.memory = memory_store

    def execute(self, agent: Agent, intent: ActionIntent) -> ActionResult:
        """执行行动意图"""
        # 1. 验证意图可行性
        if not self._is_feasible(agent, intent):
            return ActionResult(
                success=False,
                error="行动不可行"
            )

        # 2. 根据行动类型执行
        result = self._execute_by_type(agent, intent)

        # 3. 更新Agent状态
        if result.success:
            self._update_agent_state(agent, intent, result)

            # 4. 存储记忆
            self._store_memory(agent, intent, result)

        return result

    def _execute_by_type(self, agent: Agent, intent: ActionIntent) -> ActionResult:
        """根据类型执行行动"""
        match intent.action_type:
            case ActionType.Move:
                return self._execute_move(agent, intent)
            case ActionType.Speak:
                return self._execute_speak(agent, intent)
            case ActionType.Attack:
                return self._execute_attack(agent, intent)
            case ActionType.Interact:
                return self._execute_interact(agent, intent)
            case _:
                return self._execute_default(agent, intent)

    def _execute_move(self, agent: Agent, intent: ActionIntent) -> ActionResult:
        """执行移动行动"""
        # 1. 规划路径（使用传统寻路算法）
        path = self.engine.find_path(
            start=agent.state.position,
            goal=intent.target.position
        )

        # 2. 设置动画
        animation = self._choose_move_animation(agent, intent.emotion)
        agent.set_animation(animation)

        # 3. 开始移动（交由游戏引擎控制）
        move_request = MoveRequest(
            agent_id=agent.id,
            path=path,
            speed=self._calculate_move_speed(agent),
            emotion=intent.emotion
        )

        success = self.engine.execute_move(move_request)

        return ActionResult(
            success=success,
            duration=path.estimated_duration,
            new_position=intent.target.position if success else None
        )

    def _execute_speak(self, agent: Agent, intent: ActionIntent) -> ActionResult:
        """执行说话行动"""
        content = intent.parameters.get("content")

        # 1. 生成语音
        audio = self.engine.generate_speech(content, agent.voice_profile)

        # 2. 播放动画
        agent.set_animation("speak")

        # 3. 发送事件
        speak_event = Event(
            type="agent_speak",
            source=agent.id,
            target=intent.target,
            data={"content": content, "audio": audio}
        )
        self.engine.emit_event(speak_event)

        return ActionResult(
            success=True,
            duration=Duration(seconds=len(content) * 0.1)  # 估算时长
        )

    def _store_memory(self, agent: Agent, intent: ActionIntent, result: ActionResult):
        """存储行动记忆"""
        memory = Memory(
            content=self._generate_memory_content(agent, intent, result),
            timestamp=datetime.now(),
            importance=self._calculate_importance(intent, result),
            tags=[intent.action_type.value, "action"]
        )

        self.memory.add(agent.id, memory)

        # 更新短期记忆
        self.memory.add_short_term(
            agent_id=agent.id,
            content=memory.content,
            expires_at=datetime.now() + timedelta(hours=1)
        )
```

---

## 6. 行为树集成

### 6.1 行为树节点

```rust
#[derive(Debug, Clone)]
pub enum BehaviorNode {
    /// 序列节点（顺序执行子节点）
    Sequence(Vec<BehaviorNode>),
    /// 选择节点（依次尝试子节点，直到成功）
    Selector(Vec<BehaviorNode>),
    /// 条件节点
    Condition(ConditionFn),
    /// 动作节点
    Action(ActionFn),
    /// LLM决策节点（关键决策点）
    LLMDecision(LLMDecisionConfig),
}
```

### 6.2 行为树执行

```python
class BehaviorTreeExecutor:
    def __init__(self, llm_client):
        self.llm = llm_client

    def execute(self, agent: Agent, tree: BehaviorTree) -> BTResult:
        """执行行为树"""
        return self._execute_node(agent, tree.root)

    def _execute_node(self, agent: Agent, node: BehaviorNode) -> BTResult:
        match node:
            case BehaviorNode.Sequence(children):
                # 序列节点：依次执行所有子节点
                for child in children:
                    result = self._execute_node(agent, child)
                    if not result.success:
                        return BTResult(success=False)

                return BTResult(success=True)

            case BehaviorNode.Selector(children):
                # 选择节点：依次尝试，直到成功
                for child in children:
                    result = self._execute_node(agent, child)
                    if result.success:
                        return result

                return BTResult(success=False)

            case BehaviorNode.Condition(condition_fn):
                # 条件节点
                return BTResult(success=condition_fn(agent))

            case BehaviorNode.Action(action_fn):
                # 动作节点
                return action_fn(agent)

            case BehaviorNode.LLMDecision(config):
                # LLM决策节点 - 关键点
                return self._llm_decision(agent, config)

    def _llm_decision(self, agent: Agent, config: LLMDecisionConfig) -> BTResult:
        """LLM决策节点"""
        # 1. 收集上下文
        context = self._collect_context(agent, config)

        # 2. 调用LLM
        prompt = self._build_llm_prompt(context, config)
        response = self.llm.generate(prompt)

        # 3. 解析决策
        decision = self._parse_llm_decision(response, config)

        # 4. 执行决策
        return self._execute_decision(agent, decision)
```

### 6.3 示例行为树

```python
# NPC日常行为树示例
daily_behavior_tree = BehaviorTree(
    root=BehaviorNode.Selector([
        # 1. 紧急情况优先
        BehaviorNode.Sequence([
            BehaviorNode.Condition(lambda agent: self._is_emergency(agent)),
            BehaviorNode.Action(lambda agent: self._handle_emergency(agent))
        ]),

        # 2. 与玩家互动
        BehaviorNode.Sequence([
            BehaviorNode.Condition(lambda agent: self._player_nearby(agent)),
            BehaviorNode.LLMDecision(LLMDecisionConfig(
                prompt_type="player_interaction",
                options=["greet", "ignore", "attack", "help"]
            ))
        ]),

        # 3. 日常活动（LLM决策）
        BehaviorNode.Sequence([
            BehaviorNode.Condition(lambda agent: self._is_time_for_activity(agent)),
            BehaviorNode.LLMDecision(LLMDecisionConfig(
                prompt_type="daily_activity",
                context_fields=["time", "weather", "mood", "goals"]
            ))
        ]),

        # 4. 默认：发呆/巡逻
        BehaviorNode.Action(lambda agent: self._idle(agent))
    ])
)
```

---

## 7. 认知时钟

### 7.1 认知时钟管理

```python
class CognitiveClock:
    def __init__(self):
        self.last_tick = {}

    def should_tick(self, agent: Agent, current_time: Instant) -> bool:
        """判断是否应该触发认知更新"""
        last_tick = self.last_tick.get(agent.id, None)
        if last_tick is None:
            return True

        elapsed = current_time - last_tick
        return elapsed >= agent.cognitive_config.tick_rate

    def tick(self, agent: Agent, current_time: Instant):
        """更新认知时钟"""
        self.last_tick[agent.id] = current_time

    def adjust_tick_rate(self, agent: Agent, factor: float):
        """调整认知时钟频率"""
        current_rate = agent.cognitive_config.tick_rate
        agent.cognitive_config.tick_rate = Duration(
            seconds=current_rate.seconds() * factor
        )
```

### 7.2 智能降频

```python
class AdaptiveTickRate:
    def adjust(self, agent: Agent, context: Context) -> Duration:
        """根据上下文调整认知时钟"""
        base_rate = agent.cognitive_config.tick_rate

        # 1. 附近玩家越多，频率越高
        player_count = context.nearby_player_count
        if player_count > 3:
            return base_rate * 0.5  # 加速
        elif player_count == 0:
            return base_rate * 2.0  # 减速

        # 2. 正在进行重要活动时加速
        if agent.state.current_activity and agent.state.current_activity.importance > 0.8:
            return base_rate * 0.5

        # 3. 空闲时减速
        if self._is_idle(agent):
            return base_rate * 3.0

        return base_rate
```

---

## 8. 性能优化

### 8.1 语义缓存

```python
class SemanticCache:
    def __init__(self, vector_db, threshold=0.9):
        self.db = vector_db
        self.similarity_threshold = threshold

    def get(self, agent: Agent, perception: Perception) -> Optional[Decision]:
        """从缓存获取决策"""
        # 1. 构建查询向量
        query_vector = self._build_query_vector(agent, perception)

        # 2. 向量搜索
        results = self.db.search(
            collection="agent_decisions",
            query_vector=query_vector,
            top_k=1,
            filter={"agent_type": agent.profile.occupation}
        )

        if results and results[0].score > self.similarity_threshold:
            # 3. 返回缓存的决策
            return results[0].payload["decision"]

        return None

    def put(self, agent: Agent, perception: Perception, decision: Decision):
        """存储决策到缓存"""
        query_vector = self._build_query_vector(agent, perception)

        self.db.insert(
            collection="agent_decisions",
            vector=query_vector,
            payload={
                "decision": decision,
                "agent_type": agent.profile.occupation,
                "timestamp": datetime.now()
            }
        )

    def _build_query_vector(self, agent: Agent, perception: Perception) -> List[float]:
        """构建查询向量"""
        # 组合各种特征
        features = []

        # Agent特征
        features.extend(agent.profile.personality)
        features.append(agent.state.emotion.valence)
        features.append(agent.state.emotion.arousal)

        # 环境特征
        features.append(len(perception.environment.nearby_agents))
        features.append(len(perception.environment.nearby_events))

        # 场变量特征
        for field_value in perception.fields.values():
            features.append(field_value)

        return features
```

### 8.2 批量推理

```python
class BatchInference:
    def __init__(self, batch_size=32, timeout_ms=50):
        self.batch_size = batch_size
        self.timeout = timeout_ms
        self.queue = []
        self.timer = None

    def submit(self, agent: Agent, prompt: str, callback):
        """提交推理请求"""
        request = InferenceRequest(
            agent_id=agent.id,
            prompt=prompt,
            callback=callback
        )
        self.queue.append(request)

        # 启动计时器
        if self.timer is None:
            self.timer = threading.Timer(
                self.timeout / 1000.0,
                self._process_batch
            )
            self.timer.start()

        # 达到批量大小立即处理
        if len(self.queue) >= self.batch_size:
            self._process_batch()

    def _process_batch(self):
        """处理批量推理"""
        if not self.queue:
            return

        # 取消计时器
        if self.timer:
            self.timer.cancel()
            self.timer = None

        # 提取请求
        requests = self.queue[:self.batch_size]
        self.queue = self.queue[self.batch_size:]

        # 批量推理
        prompts = [r.prompt for r in requests]
        responses = self._batch_llm_inference(prompts)

        # 回调
        for request, response in zip(requests, responses):
            request.callback(response)
```

---

## 9. 完整运行流程

```python
class AgentRuntime:
    def __init__(self, config: RuntimeConfig):
        self.perception = PerceptionModule(...)
        self.decision = DecisionModule(...)
        self.action = ActionModule(...)
        self.clock = CognitiveClock()

    def update(self, agent: Agent, context: Context):
        """更新Agent"""
        # 1. 检查认知时钟
        if not self.clock.should_tick(agent, context.current_time):
            return

        # 2. 感知
        perception = self.perception.perceive(agent, context)

        # 3. 决策
        decision = self.decision.decide(agent, perception)

        # 4. 行动
        result = self.action.execute(agent, decision.intent)

        # 5. 更新时钟
        self.clock.tick(agent, context.current_time)

        # 6. 记录（用于调试/分析）
        self._log_update(agent, perception, decision, result)
```
