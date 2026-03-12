# Agent行为树示例

行为树是控制Agent行为的有效方式。本示例展示如何设计和实现Agent行为树。

## 1. 基础行为树结构

### 节点类型

```rust
use world_engine::behavior_tree::*;

/// 行为树节点
pub enum BehaviorNode {
    /// 序列节点：依次执行所有子节点，全部成功才算成功
    Sequence(Vec<BehaviorNode>),

    /// 选择节点：依次尝试子节点，直到有一个成功
    Selector(Vec<BehaviorNode>),

    /// 并行节点：并行执行子节点
    Parallel {
        children: Vec<BehaviorNode>,
        success_threshold: usize,  // 至少多少个子节点成功
    },

    /// 条件节点：检查条件
    Condition(ConditionFn),

    /// 动作节点：执行具体动作
    Action(ActionFn),

    /// 装饰器：修改子节点行为
    Decorator {
        decorator: Box<dyn Decorator>,
        child: Box<BehaviorNode>,
    },

    /// LLM决策节点：关键决策点，调用LLM
    LLMDecision(LLMDecisionConfig),
}

/// 装饰器类型
pub trait Decorator {
    fn execute(&self, child: &BehaviorNode, agent: &Agent) -> BTResult;
}
```

### 内置装饰器

```rust
/// 重试装饰器：失败时重试
pub struct Retry {
    max_attempts: usize,
}

impl Decorator for Retry {
    fn execute(&self, child: &BehaviorNode, agent: &Agent) -> BTResult {
        for _ in 0..self.max_attempts {
            let result = child.execute(agent);
            if result.success {
                return result;
            }
        }
        BTResult::failed("重试次数用尽")
    }
}

/// 超时装饰器：限制执行时间
pub struct Timeout {
    timeout: Duration,
}

impl Decorator for Timeout {
    fn execute(&self, child: &BehaviorNode, agent: &Agent) -> BTResult {
        let start = Instant::now();
        let result = child.execute(agent);

        if start.elapsed() > self.timeout {
            return BTResult::failed("执行超时");
        }

        result
    }
}

/// 反转装饰器：反转成功/失败状态
pub struct Inverter;

impl Decorator for Inverter {
    fn execute(&self, child: &BehaviorNode, agent: &Agent) -> BTResult {
        let result = child.execute(agent);
        BTResult {
            success: !result.success,
            ..result
        }
    }
}

/// 重复装饰器：重复执行
pub struct Repeat {
    count: usize,
}

impl Decorator for Repeat {
    fn execute(&self, child: &BehaviorNode, agent: &Agent) -> BTResult {
        let mut success_count = 0;
        for _ in 0..self.count {
            let result = child.execute(agent);
            if result.success {
                success_count += 1;
            }
        }
        BTResult::ok()
    }
}
```

## 2. NPC日常行为树

### 基础行为树

```rust
/// 创建NPC日常行为树
pub fn create_daily_behavior_tree() -> BehaviorTree {
    BehaviorTree {
        root: BehaviorNode::Selector(vec![
            // 优先级1: 处理紧急情况
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| is_emergency(agent)),
                ActionNode::new(handle_emergency),
            ]),

            // 优先级2: 与玩家互动
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| player_nearby(agent)),
                LLMDecisionNode::new(LLMDecisionConfig {
                    prompt_type: "player_interaction",
                    options: vec!["greet", "ignore", "attack", "help"],
                }),
            ]),

            // 优先级3: 执行日程活动
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| has_scheduled_activity(agent)),
                ActionNode::new(execute_schedule),
            ]),

            // 优先级4: 响应环境事件
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| has_nearby_event(agent)),
                ActionNode::new(respond_to_event),
            ]),

            // 优先级5: 随机活动（LLM决策）
            BehaviorNode::Sequence(vec![
                DecoratorNode::new(
                    Inverter,
                    Box::new(ConditionNode::new(|agent| is_busy(agent)))
                ),
                LLMDecisionNode::new(LLMDecisionConfig {
                    prompt_type: "random_activity",
                    context_fields: vec!["time", "weather", "mood", "location"],
                }),
            ]),

            // 默认: 发呆/巡逻
            ActionNode::new(idle_or_patrol),
        ]),
    }
}

/// 判断是否有紧急情况
fn is_emergency(agent: &Agent) -> bool {
    // 检查攻击
    if agent.is_under_attack() {
        return true;
    }

    // 检查危险场变量
    for (field_name, value) in &agent.state.perceived_fields {
        if field_name.contains("danger") && *value > 0.7 {
            return true;
        }
    }

    false
}

/// 处理紧急情况
fn handle_emergency(agent: &mut Agent) -> BTResult {
    if agent.is_under_attack() {
        // 逃跑或反击
        if agent.profile.abilities.get("战斗").unwrap_or(&0.0) > &0.7 {
            return fight_back(agent);
        } else {
            return flee(agent);
        }
    }

    BTResult::ok()
}

/// 玩家是否在附近
fn player_nearby(agent: &Agent) -> bool {
    let player_pos = get_player_position();
    let distance = agent.state.position.distance_to(player_pos);
    distance < 50.0
}

/// 检查是否有预定活动
fn has_scheduled_activity(agent: &Agent) -> bool {
    agent.state.current_activity.is_some()
        && agent.state.current_activity.as_ref().unwrap().scheduled
}

/// 执行日程活动
fn execute_schedule(agent: &mut Agent) -> BTResult {
    let activity = agent.state.current_activity.as_ref().unwrap();

    match activity.activity_type {
        ActivityType::Work => work(agent),
        ActivityType::Eat => eat(agent),
        ActivityType::Sleep => sleep(agent),
        ActivityType::Shop => shop(agent),
        ActivityType::Socialize => socialize(agent),
    }
}
```

### 铁匠行为树

```rust
/// 铁匠专属行为树
pub fn create_blacksmith_behavior_tree() -> BehaviorTree {
    BehaviorTree {
        root: BehaviorNode::Selector(vec![
            // 紧急情况
            handle_emergency_subtree(),

            // 顾客互动
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| has_customer(agent)),
                LLMDecisionNode::new(LLMDecisionConfig {
                    prompt_type: "blacksmith_customer",
                    options: vec![
                        "greet_customer",
                        "show_weapons",
                        "offer_repair",
                        "reject",
                    ],
                }),
            ]),

            // 锻造工作
            BehaviorNode::Sequence(vec![
                DecoratorNode::new(
                    Timeout { timeout: Duration::from_hours(8) },
                    Box::new(ConditionNode::new(|agent| is_work_hours(agent)))
                ),
                ActionNode::new(forge),
            ]),

            // 工具维护
            ActionNode::new(maintain_tools),

            // 休息
            ActionNode::new(rest),
        ]),
    }
}

fn forge(agent: &mut Agent) -> BTResult {
    // 使用传统动画控制锻造动作
    agent.set_animation("forge");

    // 设置锻造状态
    agent.state.current_activity = Some(Activity {
        activity_type: ActivityType::Work,
        description: "正在锻造".to_string(),
        progress: 0.0,
        scheduled: true,
    });

    // 锻造完成后触发LLM生成下一个目标
    BTResult::ok()
}

fn has_customer(agent: &Agent) -> bool {
    // 查找附近的潜在顾客
    let nearby_agents = agent.query_nearby_agents(10.0);
    nearby_agents.iter().any(|a| {
        a.profile.occupation != "铁匠"
            && !a.inventory.is_empty()
    })
}
```

## 3. 战斗行为树

### 基础战斗树

```rust
/// 通用战斗行为树
pub fn create_combat_behavior_tree() -> BehaviorTree {
    BehaviorTree {
        root: BehaviorNode::Sequence(vec![
            // 初始化战斗
            ActionNode::new(initiate_combat),

            // 战斗循环
            BehaviorNode::Repeat {
                count: usize::MAX,  // 持续循环
                child: Box::new(BehaviorNode::Selector(vec![
                    // 检查是否应该撤退
                    BehaviorNode::Sequence(vec![
                        ConditionNode::new(should_retreat),
                        ActionNode::new(retreat),
                    ]),

                    // 检查是否可以使用技能
                    BehaviorNode::Sequence(vec![
                        ConditionNode::new(can_use_skill),
                        ActionNode::new(use_skill),
                    ]),

                    // 普通攻击
                    ActionNode::new(basic_attack),

                    // LLM决策战斗策略
                    LLMDecisionNode::new(LLMDecisionConfig {
                        prompt_type: "combat_strategy",
                        context_fields: vec![
                            "health",
                            "enemy_health",
                            "enemy_type",
                            "position",
                            "available_skills",
                        ],
                    }),
                ])),
            },
        ]),
    }
}

/// 判断是否应该撤退
fn should_retreat(agent: &Agent) -> bool {
    // 生命值过低
    if agent.state.health < 0.3 {
        return true;
    }

    // 敌人强大
    let enemy = agent.get_current_enemy();
    if let Some(enemy) = enemy {
        let power_gap = enemy.power - agent.power;
        if power_gap > 0.5 {
            return true;
        }
    }

    false
}

/// 撤退
fn retreat(agent: &mut Agent) -> BTResult {
    // 寻找安全位置
    let safe_pos = find_safe_position(agent);

    // 移动到安全位置
    let move_intent = ActionIntent {
        action_type: ActionType::Move,
        target: ActionTarget::Position(safe_pos),
        emotion: Some(Emotion {
            valence: -0.5,
            arousal: 0.8,
            labels: vec!["恐惧".to_string()],
        }),
        ..Default::default()
    };

    agent.execute_action(move_intent);

    BTResult::ok()
}
```

### Boss战斗树

```rust
/// Boss战斗行为树（更复杂）
pub fn create_boss_combat_behavior_tree() -> BehaviorTree {
    BehaviorTree {
        root: BehaviorNode::Selector(vec![
            // 阶段切换
            BehaviorNode::Sequence(vec![
                ConditionNode::new(should_change_phase),
                ActionNode::new(change_phase),
            ]),

            // 必杀技能（血量低于50%）
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| agent.state.health < 0.5),
                DecoratorNode::new(
                    Cooldown { cooldown: Duration::from_secs(30) },
                    Box::new(ActionNode::new(ultimate_skill))
                ),
            ]),

            // 群体技能
            BehaviorNode::Sequence(vec![
                ConditionNode::new(has_multiple_targets),
                DecoratorNode::new(
                    Cooldown { cooldown: Duration::from_secs(20) },
                    Box::new(ActionNode::new(aoe_skill))
                ),
            ]),

            // 精英怪召唤
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| agent.state.health < 0.7),
                DecoratorNode::new(
                    Cooldown { cooldown: Duration::from_secs(60) },
                    Box::new(ActionNode::new(summon_minions))
                ),
            ]),

            // 普通攻击
            ActionNode::new(boss_attack),

            // LLM决策（Boss有智慧）
            LLMDecisionNode::new(LLMDecisionConfig {
                prompt_type: "boss_strategy",
                context_fields: vec![
                    "phase",
                    "player_patterns",
                    "available_skills",
                    "minion_status",
                ],
            }),
        ]),
    }
}
```

## 4. 社交行为树

### 商家行为树

```rust
/// 商家行为树
pub fn create_merchant_behavior_tree() -> BehaviorTree {
    BehaviorTree {
        root: BehaviorNode::Selector(vec![
            // 与玩家交易
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| player_nearby(agent)),
                LLMDecisionNode::new(LLMDecisionConfig {
                    prompt_type: "merchant_interaction",
                    context_fields: vec![
                        "player_reputation",
                        "player_wealth",
                        "shop_inventory",
                        "economy_status",
                    ],
                }),
            ]),

            // 补货
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| needs_restock(agent)),
                ActionNode::new(restock),
            ]),

            // 与其他商人交流
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| time_to_chat(agent)),
                ActionNode::new(chat_with_merchants),
            ]),

            // 调整价格（根据经济情况）
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| check_price_adjustment(agent)),
                LLMDecisionNode::new(LLMDecisionConfig {
                    prompt_type: "price_adjustment",
                    context_fields: vec![
                        "economic_panic",
                        "supply_demand",
                        "player_wealth_trend",
                    ],
                }),
            ]),

            // 日常开店
            ActionNode::new(open_shop),
        ]),
    }
}
```

### 守卫行为树

```rust
/// 守卫行为树
pub fn create_guard_behavior_tree() -> BehaviorTree {
    BehaviorTree {
        root: BehaviorNode::Selector(vec![
            // 侦查入侵
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| detect_intruder(agent)),
                LLMDecisionNode::new(LLMDecisionConfig {
                    prompt_type: "guard_intruder",
                    options: vec![
                        "confront",
                        "call_backup",
                        "attack",
                        "warn",
                    ],
                }),
            ]),

            // 响应警报
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| alarm_active(agent)),
                ActionNode::new(response_to_alarm),
            ]),

            // 交接班
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| time_for_shift_change(agent)),
                ActionNode::new(shift_change),
            ]),

            // 巡逻路线
            BehaviorNode::Sequence(vec![
                ConditionNode::new(|agent| on_patrol(agent)),
                ActionNode::new(follow_patrol_route),
            ]),

            // 站岗
            ActionNode::new(stand_guard),
        ])
    }
}
```

## 5. 动态行为树更新

### 根据经验学习

```rust
/// 行为树学习器
pub struct BehaviorTreeLearner {
    success_rates: HashMap<String, f32>,
}

impl BehaviorTreeLearner {
    /// 记录决策结果
    pub fn record_outcome(&mut self, decision: &str, success: bool) {
        let key = decision.to_string();
        let rate = self.success_rates.entry(key).or_insert(0.5);

        // 更新成功率
        *rate = *rate * 0.9 + if success { 1.0 } else { 0.0 } * 0.1;
    }

    /// 根据成功率调整行为树优先级
    pub fn adjust_tree(&self, tree: &mut BehaviorTree) {
        // 将成功率低的决策后移
        if let BehaviorNode::Selector(children) = &mut tree.root {
            children.sort_by(|a, b| {
                let a_score = self.get_success_rate(a);
                let b_score = self.get_success_rate(b);
                b_score.partial_cmp(&a_score).unwrap_or(std::cmp::Ordering::Equal)
            });
        }
    }

    fn get_success_rate(&self, node: &BehaviorNode) -> f32 {
        match node {
            BehaviorNode::Action(action) => {
                self.success_rates.get(action.name()).copied().unwrap_or(0.5)
            }
            BehaviorNode::LLMDecision(config) => {
                self.success_rates
                    .get(&config.prompt_type)
                    .copied()
                    .unwrap_or(0.5)
            }
            _ => 0.5,
        }
    }
}
```

### 情感影响行为

```rust
/// 根据情感调整行为
pub fn adjust_behavior_by_emotion(agent: &Agent, tree: &mut BehaviorTree) {
    let valence = agent.state.emotion.valence;  // 正负面
    let arousal = agent.state.emotion.arousal;  // 激活度

    // 负面情绪：更倾向于攻击、防御
    if valence < -0.3 {
        if let BehaviorNode::Selector(children) = &mut tree.root {
            // 将防御行为前移
            for (i, child) in children.iter().enumerate() {
                if is_defensive_behavior(child) {
                    children.swap(0, i);
                    break;
                }
            }
        }
    }

    // 高激活度：更倾向于快速行动
    if arousal > 0.7 {
        // 增加超时装饰器
        tree.root = BehaviorNode::Decorator(Box::new(Timeout {
            timeout: Duration::from_secs(2),
        }), Box::new(tree.root.clone()));
    }
}
```

## 6. 完整使用示例

```rust
use world_engine::*;

#[tokio::main]
async fn main() -> Result<()> {
    let engine = Engine::initialize_default().await?;

    // 创建铁匠Agent
    let blacksmith = Agent::new(
        "blacksmith_001",
        AgentProfile {
            name: "老张".to_string(),
            occupation: "铁匠".to_string(),
            personality: vec![0.3, 0.2, 0.1],
            abilities: vec![("锻造", 0.9), ("力量", 0.8)].into_iter().collect(),
            relationships: HashMap::new(),
        },
    );

    // 创建并设置行为树
    let behavior_tree = create_blacksmith_behavior_tree();
    blacksmith.set_behavior_tree(behavior_tree);

    // 添加到世界
    engine.add_agent(blacksmith).await?;

    // 主循环：每帧执行行为树
    loop {
        let context = engine.get_current_context();

        for agent in engine.get_active_agents() {
            if let Some(tree) = agent.behavior_tree.as_ref() {
                let result = tree.execute(agent, &context);

                if !result.success {
                    // 记录失败，用于学习
                    agent.learner.record_failure(&result.error);
                }
            }
        }

        tokio::time::sleep(Duration::from_millis(16)).await;  // 60 FPS
    }
}
```
