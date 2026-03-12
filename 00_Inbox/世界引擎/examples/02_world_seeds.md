# 世界种子示例

世界种子是构建世界的起点，可以是文本描述、小说、配置文件等。本示例展示如何编写各种类型的世界种子。

## 1. 文本描述种子

### 简单描述

```yaml
# seeds/simple_world.yaml
name: "简单的武侠世界"
type: "text"
content: |
  这是一个武侠世界，拥有各大门派和武林高手。
  主要门派包括：少林寺、武当派、峨眉派、丐帮。
  世界中有正邪两道，正道门派维护江湖正义，
  邪派则追求力量不择手段。
  武林中流传着绝世武功秘籍，人人争夺。
```

### 详细描述

```yaml
# seeds/detailed_world.yaml
name: "大唐江湖"
type: "text"
content: |
  背景设定：大唐开元盛世，武道昌盛，门派林立。

  地理分布：
  - 北方：少林寺（嵩山）、武当派（武当山）
  - 南方：峨眉派（峨眉山）、唐门（四川）
  - 东方：丐帮（洛阳）、逍遥派（东海）
  - 西方：昆仑派（昆仑山）

  门派介绍：
  1. 少林寺：以少林七十二绝技闻名，天下武功出少林
  2. 武当派：以太极、剑法见长，道家内功深厚
  3. 峨眉派：女侠云集，剑法轻灵
  4. 丐帮：天下第一大帮，降龙十八掌威震江湖
  5. 唐门：暗器机关冠绝天下
  6. 昆仑派：昆仑秘境，神秘莫测
  7. 逍遥派：逍遥自在，武功奇诡

  武功体系：
  - 外功：拳脚、兵器、轻功、暗器
  - 内功：真气运行、经脉修炼
  - 修炼境界：外门 -> 内门 -> 长老 -> 掌门 -> 宗师

  社会结构：
  - 朝廷：负责天下治理
  - 门派：武林势力，相对独立
  - 世家：地方豪强，与门派关系复杂
  - 丐帮：民间组织，遍布天下

  矛盾冲突：
  - 正邪对立：正道门派 vs 邪派（如明教、日月神教）
  - 门派争斗：资源争夺、秘籍争夺
  - 家族恩怨：世代仇杀
  - 江湖传闻：各种传说和谜团

  物品体系：
  - 武器：剑、刀、枪、棍、鞭等
  - 暗器：飞刀、毒针、弹指等
  - 丹药：疗伤、内功提升
  - 秘籍：武功心法、招式
  - 宝物：神兵利器、奇珍异宝
```

## 2. 小说种子

### 从小说片段提取

```yaml
# seeds/novel_world.yaml
name: "射雕英雄传世界"
type: "novel"
source: "射雕英雄传"
chapters: [1, 2, 3, 4, 5]  # 提取前5章
settings:
  extract_dialogue: true   # 提取对话，构建对话模式
  extract_relationships: true  # 提取人物关系
  extract_locations: true  # 提取地点信息
```

### 结构化小说输入

```yaml
# seeds/novel_structured.yaml
name: "修仙世界"
type: "novel"
content: |
  第一章：少年遇仙
  --------
  少年林风，自幼父母双亡，在山村长大。
  一日上山砍柴，遇一白发老翁。

  老翁问："你可想长生？"
  林风答："我想让父母复活。"
  老翁叹道："生死有命，但修道可延寿。"
  于是收林风为徒，传授入门功法。

  第二章：灵根测试
  --------
  青云宗招收弟子，林风前往测试。
  测试灵根为：火、木双灵根，中上资质。

  宗门介绍：
  - 青云宗：正道大宗，传承千年
  - 血煞宗：邪派，血祭功法
  - 神秘组织：暗中活动，目的不明

  修炼体系：
  炼气 -> 筑基 -> 金丹 -> 元婴 -> 化神 -> 大乘 -> 渡劫
  每个大境界分为初期、中期、后期、圆满
```

## 3. 配置文件种子

### JSON格式

```json
{
  "name": "赛博朋克城市",
  "type": "config",
  "format": "json",
  "world_settings": {
    "era": "2077",
    "technology_level": "high",
    "society_type": "corporation-controlled"
  },
  "factions": [
    {
      "name": "荒坂公司",
      "type": "corporation",
      "influence": 0.9,
      "specialization": ["military", "AI", "cybernetics"]
    },
    {
      "name": "军用科技",
      "type": "corporation",
      "influence": 0.85,
      "specialization": ["weapons", "vehicles", "security"]
    },
    {
      "name": "漩涡帮",
      "type": "gang",
      "influence": 0.3,
      "specialization": ["street_racing", "weapons"]
    }
  ],
  "districts": [
    {
      "name": "来生酒吧",
      "type": "entertainment",
      "danger_level": 0.6,
      "population": 50000
    },
    {
      "name": "恶土",
      "type": "slum",
      "danger_level": 0.9,
      "population": 100000
    }
  ],
  "technologies": [
    {
      "name": "脑机接口",
      "impact": "high",
      "availability": "common"
    },
    {
      "name": "义体改造",
      "impact": "medium",
      "availability": "widespread"
    },
    {
      "name": "人工智能",
      "impact": "critical",
      "availability": "corporation_only"
    }
  ]
}
```

### TOML格式

```toml
# seeds/fantasy_world.toml
name = "魔法大陆"
type = "config"
format = "toml"

[world_settings]
magic_level = "high"
technology_level = "low"
primary_conflict = "light_vs_dark"

[realms]
[realms.elden]
name = "艾尔登"
type = "kingdom"
ruler = "艾尔登法环"
population = 1000000

[realms.caelid]
name = "盖利德"
type = "wasteland"
description = "被猩红腐败侵蚀的土地"
danger_level = 0.95

[realms.altus]
name = "亚坛高原"
type = "plains"
population = 200000
trade_centers = ["圆桌厅堂", "王城"]

[factions]
[factions.golden_order]
type = "order"
influence = 0.8
beliefs = ["黄金律法", "信仰"]

[factions.moon_witches]
type = "covenant"
influence = 0.5
location = "卡利亚王室"
specialization = ["moon_magic", "intelligence"]

[realms.elden]
location = "亚坛高原"
population = 100000
trade = ["矿石", "武器", "食物"]
danger_level = 0.3
```

## 4. 混合种子

```yaml
# seeds/hybrid_world.yaml
name: "现代都市修仙"
type: "hybrid"

# 基础描述
base_description: |
  这是一个现代都市背景下的修仙世界。
  现代科技与传统修仙术结合。

# 配置文件
config_file: "configs/urban_cultivation.toml"

# 小说片段
novel_excerpts:
  - path: "novels/chapter1.txt"
    sections: ["世界观", "修仙体系"]
  - path: "novels/chapter3.txt"
    sections: ["主角觉醒"]

# 覆盖设置
overrides:
  technology_level: "modern"
  magic_system: "cultivation"
  fusion:
    - "手机APP修仙"
    - "AI辅助炼丹"
    - "卫星定位法宝"
```

## 5. 场景种子

### 地下城种子

```yaml
# seeds/dungeon.yaml
name: "黑暗地牢"
type: "scenario"

dungeon_structure:
  floors: 10
  rooms_per_floor: 20
  boss_floors: [5, 10]

entities:
  monsters:
    - name: "骷髅战士"
      level_range: [1, 10]
      abilities: ["物理攻击", "再生"]
      drop: ["骨剑", "骨盾"]

    - name: "腐尸"
      level_range: [2, 15]
      abilities: ["毒攻击", "腐烂"]
      drop: ["毒药", "腐肉"]

    - name: "地牢守卫"
      level: 20
      abilities: ["重击", "防御姿态"]
      boss: true

  items:
    - name: "火把"
      type: "tool"
      effect: "照明"

    - name: "治疗药水"
      type: "consumable"
      effect: "恢复50生命值"

    - name: "地牢钥匙"
      type: "key"
      required_for: "boss_door"

environment:
  lighting: "dark"
  traps:
    - type: "spike_trap"
      trigger: "pressure_plate"
      damage: 20

    - type: "poison_gas"
      trigger: "timer"
      damage: 5
      duration: 10

objectives:
  - type: "clear"
    description: "清除所有怪物"
  - type: "boss"
    description: "击败地牢守卫"
  - type: "collect"
    description: "收集5把地牢钥匙"
```

### 城市种子

```yaml
# seeds/city.yaml
name: "未来都市"
type: "scenario"

city_layout:
  districts:
    - name: "商业区"
      type: "commercial"
      businesses: ["商店", "银行", "写字楼"]

    - name: "居住区"
      type: "residential"
      housing: ["公寓", "别墅", "社区"]

    - name: "工业区"
      type: "industrial"
      factories: ["科技工厂", "能源厂"]

    - name: "娱乐区"
      type: "entertainment"
      venues: ["酒吧", "游戏厅", "VR中心"]

npc_types:
  - name: "上班族"
      behavior: "daily_routine"
      schedule:
        - "08:00": "通勤"
        - "09:00": "工作"
        - "18:00": "下班"
        - "19:00": "娱乐"

  - name: "商贩"
      behavior: "sell_goods"
      shop_hours: ["09:00", "21:00"]

  - name: "警察"
      behavior: "patrol"
      patrol_areas: ["商业区", "居住区"]

events:
  - type: "traffic_jam"
      frequency: "low"
      effect: "移动速度 -50%"

  - type: "festival"
      frequency: "weekly"
      effect: "NPC情绪 +0.3"

economy:
  currency: "信用点"
  average_income: 5000
  price_index: 100
```

## 6. 使用种子

```rust
use world_engine::{WorldSeed, SeedSourceType, Engine};

#[tokio::main]
async fn main() -> Result<()> {
    let engine = Engine::initialize_default().await?;

    // 方式1: 直接字符串
    let seed1 = WorldSeed {
        name: "测试世界".to_string(),
        content: "这是一个简单的测试世界。".to_string(),
        source_type: SeedSourceType::Text,
    };

    // 方式2: 从文件读取
    let seed2 = WorldSeed {
        name: "江湖世界".to_string(),
        content: std::fs::read_to_string("seeds/jianghu.txt")?,
        source_type: SeedSourceType::Text,
    };

    // 方式3: 从配置文件
    let seed3 = WorldSeed {
        name: "赛博朋克".to_string(),
        content: std::fs::read_to_string("seeds/cyberpunk.json")?,
        source_type: SeedSourceType::Config,
    };

    // 方式4: 从URL（需要网络）
    let seed4 = WorldSeed {
        name: "在线小说世界".to_string(),
        content: String::new(),
        source_type: SeedSourceType::Url("https://example.com/novel.txt".to_string()),
    };

    // 构建世界
    let world = engine.world_builder().build(seed1).await?;

    Ok(())
}
```

## 7. 种子最佳实践

### ✅ 好的种子

```yaml
# 清晰的层次结构
world:
  background: "大唐开元盛世"
  geography:
    north: ["少林", "武当"]
    south: ["峨眉", "唐门"]
  factions:
    - name: "正道"
      values: ["正义", "秩序"]
    - name: "邪派"
      values: ["力量", "自由"]
  conflicts:
    - type: "ideological"
      parties: ["正道", "邪派"]
    - type: "resource"
      resource: "武林秘籍"
```

### ❌ 不好的种子

```yaml
# 太模糊
content: "这是一个很有趣的世界，有很多很厉害的人。"

# 矛盾
factions:
  - name: "正道"
    alignment: "evil"
  - name: "邪派"
    alignment: "good"

# 不完整
world:
  # 缺少关键信息
```

## 8. 种子模板

```yaml
# seed_template.yaml
name: "{{世界名称}}"
type: "{{类型：text/novel/config/hybrid}}"

# 世界背景
background: |
  {{描述世界的基本设定}}

# 地理环境
geography:
  regions:
    - name: "{{区域名称}}"
      description: "{{区域描述}}"
      danger_level: 0-1

# 势力
factions:
  - name: "{{势力名称}}"
    type: "{{类型：organization/government/gang}}"
    values: ["{{核心价值观}}"]
    abilities: ["{{特殊能力}}"]

# 实体类型
entity_types:
  - name: "{{人物类型}}"
    category: "person"
    attributes:
      name: string
      age: number
      occupation: string

# 规则体系
rules:
  physical:
    gravity: 9.8
  magical: # 或 tech/scifi
    power_system: "{{魔法/科技系统}}"

# 主要矛盾
conflicts:
  - type: "{{类型：ideological/resource/territorial}}"
    parties: ["{{参与方}}"]
    stakes: "{{冲突赌注}}"
```
