# meaning 插件设计文档

- **日期**: 2026-07-01
- **状态**: Draft（待用户 review）
- **主题**: 一个缓解「意图债」与「认知债」的 Claude Code 插件

---

## 0. TL;DR

`meaning` 是一个用户级 Claude Code 插件。它立足于 Margaret-Anne Storey 的**三重债务模型**（技术债 / 意图债 / 认知债）与 Peirce 符号三角,专门修复其中两项——**意图债(Sign 符号)**与**认知债(Interpretant 解释项)**,把对常规指标(velocity / DORA / 覆盖率)隐形的这两种债**变可见、可还**。技术债(Object)委托给既有的 superpowers / simplify / code-review。

插件由三个组件构成一个 Peirce 闭环:`capture`(趁新鲜,造符号 + 钉 theory)、`tour`(忘了时,用符号重建 theory 并审计符号)、`sweep`(持续,符号 ↔ 代码对齐)。三者共享同一批抗漂移符号,符号与理解互相喂养、互相校验——这正是它们住进一个插件、而非三个孤立工具的根本理由。

核心元原则,源自 Naur《Programming as Theory Building》:**插件必须真的建造 theory(开发者脑中的理解),而不是堆砌工件。** AI 生成的是文本,不是理论;文档替代不了理论。

---

## 1. 背景与问题

### 1.1 痛点

用户工作流:`superpowers`(brainstorming → writing-plans → executing → TDD)→ `code-review`(正确性)→ `simplify`(可维护性)。这套很顺。唯一痛点:**功能交付后,用户在代码层面看不懂了**——知道功能是啥,但读不懂自己的代码、还原不出为什么这么写。这是典型的认知债/理解债。

### 1.2 三重债务模型(Storey, ACM Queue 2026-05, arXiv 2603.22106)

Peirce 的意义三元组映射到软件健康:

| Peirce | 在软件里 | 对应的债 | 侵蚀的是什么 | 谁修 |
|---|---|---|---|---|
| **Object(客体)** | 代码本身 | **技术债** | 系统本身的质量 | superpowers / simplify / code-review |
| **Sign(符号)** | 意图工件:spec、注释、决策记录、rationale、commit msg、测试即规约 | **意图债** | 符号缺失/过时/自相矛盾 | **本插件 `sweep` + `capture`** |
| **Interpretant(解释项)** | 开发者脑中的共享 theory | **认知债** | theory 蒸发/碎片化 | **本插件 `capture` + `tour`** |

Peirce 的硬约束:**三元缺一,意义就崩。** Storey 给的两个偏角状态正好证明两债必须一起抓:"有符号但人还是懵的"(低意图债、高认知债)与"符号缺了但人还知道"(高意图债、低认知债)。修符号 ≠ 修理解;理解没有符号又很脆。

### 1.3 理论根与证据

- **Naur(1985), Programming as Theory Building**:程序不只是源码,而是活在开发者脑中的 theory(做什么 / 意图如何实现 / 如何修改)。程序有「生命/死亡/复活」:团队散了程序就死,**仅凭文档无法复活,通常要推倒重来**。→ 认知债的本质就是 theory 流失;**AI 生成的是文本,不是理论**。
- **Osmani, Comprehension Debt**:理解债 = 代码总量与人类真正理解量之间不断扩大的鸿沟;它对一切正常指标隐形,滋生虚假信心;速度不对称(AI 生成远快于人类评估)打破了审查反馈环;测试/规格无法替代理解(测不了没想到的行为)。
- **Chi 等,自我解释效应(含 Bisra 等 2018 元分析)**:让学习者向自己解释材料,可靠提升理解、减少错误,并已迁移到编程领域。**这是支撑「主动 > 被动」设计决策的主证据与最强杠杆**(元分析级别、可复现)。→ capture/tour 默认 self-explanation / Socratic / Feynman。
- **Anthropic, How AI Impacts Skill Formation(单次 RCT,n=52)**:AI 辅助组理解测验低 17%(50% vs 67%),调试差距最大;使用方式决定收获(被动外包型 ~40%、主动探究型 >65%)。方向性支持,**非定论**(单任务、单框架、样本小)。
- **MIT, Your Brain on ChatGPT(Kosmyna)**——*有争议,不作为证据引用*:样本小、EEG 子组更小、「没有认知信用卡」属戏剧化断言、可复现性受质疑。**本设计不依赖它**;「主动」原则由上面的自我解释研究独立支撑。

**由此得出的元主题**:认知债/意图债隐形,所以插件的更深层使命是把它们**变可见、可还**;而 Naur 说文档替代不了 theory,所以插件的核心动作必须是**建造 theory(主动建构理解)**,而非生产更多会漂移的工件。

---

## 2. 使命与范围

### 2.1 使命

修复 Peirce 三元组中的 **Sign(意图债)** 与 **Interpretant(认知债)** 两端,把这两种隐形债变可见、可还;通过主动建构理解来对抗「外包思考」造成的 theory 流失。

### 2.2 In scope(v1)

- **`capture`**:趁上下文新鲜(在 `simplify` 之后)结构化声明意图 + 记录意图→代码决策路径 + 落抗漂移符号 + 自我解释检查点产出「理解分」。
- **`tour`**:忘了时按需,加载并审计符号 → 粗粒度 orient → 苏格拉底/费曼重建 + 挖隐含假设 + 极端场景 → 理解分。
- **`sweep`**:从 doc-sweep 泛化,符号 ↔ 代码持续对齐,A/B/C/D 分类;审计插件自产的符号。
- **理解分**:内嵌于 `capture` 与 `tour`,把「感觉懂了」量化。

### 2.3 Non-goals(明确不做)

- **不修技术债**(Object):复杂度/过度设计/根因 = `simplify` 与 `code-review` 的活。插件只**顺道 handoff**(建议/调用),不做。
- **不做向量库 / 知识图谱**:高漂移、重基建,与抗漂移原则冲突。所有符号要么长在代码里、要么可执行、要么是贴在符号旁的薄记录。
- **不做 `/decompose`(任务分解)**:属于规划,是 superpowers / writing-plans 的活。
- **不做投机性产物**:物理类比库、纳博科夫卡片库、自动生成图——无证据减债、且脱离代码会漂移。
- **不做自动触发的 hook**:不挂 `pre/post codegen`、不在每次改动上自动写代码/检查(surprising,且和 doc-sweep「不静默改」护栏冲突)。
- **不替代理解**:插件强制验证理解,但不替代理解(原则:理解不可外包)。

---

## 3. 架构:Peirce 闭环

```
                        ┌─────────────────────────────────────────────┐
   Object(代码)        │   技术债 ──→ 委托 superpowers/simplify/review │
                        └─────────────────────────────────────────────┘
                                         │
                            (代码是符号的对齐基准)
                                         │
   Sign(意图工件)  ◀─── sweep:符号↔代码对齐(意图债) ───▶  自产符号也被审计
        ▲                                                        │
        │capture 造符号(减意图债)                                │ tour 用符号重建
        │                                                        │ theory 并审计符号
        ▼                                                        ▼
   Interpretant(theory) ◀─── capture 趁新鲜钉 theory + tour 重建(认知债) ───▶ 理解分
```

- `capture` 同时减两债:既造符号(补 Sign,减意图债),又在上下文新鲜时用自我解释把 theory 钉住(建 Interpretant,减认知债)——这是最高杠杆的一步,单靠 `sweep` 做不到。
- `sweep` 保符号对齐(意图债)。
- `tour` 用符号重建 theory 并审计符号(减认知债 + 暴露意图债,断链指向 `sweep`)。
- **符号与理解互相喂养、互相校验**——这是 Sign↔Interpretant 的循环本体,也是「一个插件」而非「三个工具」的根本理由。

---

## 4. 组件设计

### 4.1 `capture` — 趁新鲜:声明意图 + 记录决策 + 落符号 + 钉 theory

**触发**:`simplify` 之后(功能完成且干净、上下文新鲜),或开发中任意「现在最懂」的时刻。手动触发(`/meaning capture`)。

**输入(此刻最丰富)**:代码、`git log`/`git diff`、brainstorming spec、writing-plans 的 plan、simplify/code-review 的发现。

**步骤**:

1. **定范围**:用户指(feature 名 / 文件 / 最近 diff / spec);插件复述确认。功能太大 → 拆子功能。
2. **结构化声明意图**(减意图债 + 用苏格拉底挑战):
   - 产出 `intent-spec`,采用**墨子「故/理/类」**三层元数据:
     - **故(Cause/Why)**:为什么做这个变更?(业务驱动 / 技术债 / 用户请求)
     - **理(Principle/How)**:遵循什么原则/方案?(架构模式 / 设计原则 / 技术选型)
     - **类(Category/Scope)**:属于哪类变更?(新功能 / 修复 / 重构 / 性能)
   - 附加:约束(constraints)、验收标准(acceptance_criteria)。
   - 对模糊处用**苏格拉底式追问**(概念澄清 / 边界探测 / 依赖检查 / 约束平衡)。
   - 用**归谬法**做极端场景风险预警(「如果这样做,最坏会发生什么」),录入 `risk_analysis`。
3. **记录意图→代码决策路径**(减意图债):对每个非显而易见的决策产出 **ADR-lite**——决策 + **≥1 个被否备选** + **≥1 个负面后果**(硬约束:不列被否项和代价的「解释」是宣传,不是理解,一律拒绝)。
4. **落抗漂移符号**(减意图债,先报告再确认):提议并落盘——
   - **why 注释释**(英文,内联在代码决策点):把 ADR-lite 浓缩成代码旁的 why。
   - **阅读顺序 tour 文件**(薄 markdown,`docs/meaning/<feature>/tour.md`):有序的 `(文件:行, 看什么, 信标)`。
   - **特征化测试**(愉快路径 / 关键不变量,正常测试目录):可执行 → 一改就红。
   - **沿用 doc-sweep 的「先报告再确认」护栏,不静默改代码。**
5. **自我解释检查点 → 理解分**(减认知债,趁便宜钉死 theory):关掉代码,用**费曼技巧**让用户用大白话解释 2–4 个关键决策/数据流;插件对比代码,指出不一致并追问,直到一致。产出**理解分**与一份通过验证的「白话解释」。用户卡住处 = 标记为日后要 revisit 的缺口。
6. **产出 understanding-record**(抗漂移存储,见 §5):理解分 + 白话解释 + 暴露的隐含假设 + 复杂度备注。**存为 `docs/meaning/<feature>/understanding.md`(见 §5.2),不进向量库。**
7. **校验 + 汇总**:符号引用真实代码、测试通过;报 N 条 why 注释释 / 1 份 tour / M 个测试 / 理解分 / K 个缺口。可选:建议跑 simplify/code-review(技术债 handoff)。

### 4.2 `tour` — 忘了时:加载符号 → 粗粒度 orient → 苏格拉底重建

**触发**:忘了功能代码细节时,按需(`/meaning tour`)。

**步骤**:

1. **定范围 + 加载并审计符号**:读 tour 文件 / why 注释释 / 特征化测试 / understanding-record;逐条校验 drift(断链 file:line、失效测试、过期记录)——**发现了就标红,绝不默默信任**;断链符号指向 `sweep` 去修(暴露意图债)。
2. **粗粒度 orient(被动、一屏)**:入口、形状、东西在哪、愉快路径数据流。快速给地图。
3. **细粒度苏格拉底重建(主动,核心)**:自适应深度——
   - **费曼技巧**:让用户解释某块 / 预测行为 / 确认或否决假设;扎实就跳过、发虚就深挖。
   - **解构主义**:标注代码中未声明但依赖的**隐含假设**(对外部 API 响应格式、输入格式、系统状态、数据量的假设),给每个假设失效时的风险等级。
   - **归谬法**:对关键逻辑分支构建「正常 / 极端 / 故障」场景,推演行为。
   - **绝不复述代码已展示的东西**,只用符号 + 代码答代码答不了的(为什么、被否了什么、不变量、隐藏耦合、故障模式)。
4. **理解分**:重建后用理解验证测验证收(同 §4.1 步骤 5 的机制)。
5. **不落盘**(纯交互)。若发现符号没覆盖的缺口,**提议**补一条 why 注释释(capture-lite,需确认)。
6. **逃生口**:用户说「直接给我看」就切被动讲解(尊重自主)。

### 4.3 `sweep` — 持续:符号 ↔ 代码对齐(泛化版 doc-sweep)

**身份**:doc-sweep 迁入并泛化(意图 ≠ doc,见 §5.1 符号集合)。A/B/C/D 分类原样保留。

**触发**:定期 / 重构/改名/迁移后 / 发布前 / 常规卫生。手动(`/meaning sweep`)。

**步骤**(沿用 doc-sweep,符号集合扩大):

1. **Discover**:盘点两侧——符号(见 §5.1 全集)+ 源代码。`git ls-files --cached --others --exclude-standard`;memory 即便 gitignore 也纳入(report-only)。
2. **Analyze & classify**:对每条触及行为/签名/类型/副作用/错误/外部契约的符号主张,对照代码验证,分 A/B/C/D。
3. **Report**:分组报告,每条带 `file:line`;区分「will fix(A/C)」「疑似 bug,你的 call(B)」「propose only(D)」。
4. **Confirm**:默认应用所有在范围的 A 和 C;B、D 不自动应用。
5. **Apply**:批量最小、忠实编辑(保留原语气/语言)。不 commit。
6. **Verify & handoff**:复查;汇总 N fixed / M flagged / K proposed;在 main/master 提醒用户先开分支(不自行 branch/commit)。
7. **自审**:插件自产的符号(why 注释释 / tour / 特征化测试 / understanding-record)同样纳入审计——符号↔代码自洽。

**分类(沿用 doc-sweep)**:
- **A 行为漂移**:符号描述的行为代码已不匹配,且代码是刻意的工作行为 → 改符号。
- **B 不变量/契约违反**:符号陈述 must/always/never/invariant,代码违反 → **不动代码、不改符号粉饰**,标疑似 bug。
- **C 过时引用**:重命名符号 / 失效链接 / 错误路径签名 → 改符号。
- **D 出编辑范围**:符号在 agent 指令文件(CLAUDE.md 等)或 memory → 只报告、提议,不写。

---

## 5. 共享概念

### 5.1 符号集合(sweep 的审计范围;意图 ≠ doc)

意图工件远比「文档」宽,凡是承载系统 rationale 的都是符号:

- 代码注释 & docstring
- README / CHANGELOG / CONTRIBUTING / `docs/**` / 任意 `*.md`/`*.rst`/`*.adoc`
- 契约规约:OpenAPI/Swagger、`*.proto`、GraphQL、JSON Schema
- **ADR / 决策记录(新增)**
- **brainstorming spec + writing-plans 的 plan(新增,设计意图)**
- **commit message + PR/MR 描述(新增,交付时意图)**
- **测试即规约(新增,断言编码预期行为)**
- agent 指令文件(CLAUDE.md / AGENTS.md / .cursorrules …)→ report-only
- memory(`.claude/.../memory`、`.remember`)→ report-only

### 5.2 抗漂移符号:形态、位置、抗漂移机制

**落盘规则**:**所有独立记录类工件统一落在目标项目的 `docs/meaning/<feature>/` 下**(整洁、可被 `sweep` 集中审计)。**两类例外必须留在原位**,因为它们的位置本身就是抗漂移机制——挪走就失效:

- **why 注释释** → 留在代码内联(紧贴决策点,代码改它跟着移)。
- **特征化测试** → 留在项目测试目录(被测试框架发现、可执行,一改就红)。

> 注:`docs/meaning/` 是**目标项目**(插件运行 capture/tour/sweep 的那个代码库)里的目录,不是插件自身源码的 home。

| 符号 | 形态 | 位置 | 抗漂移机制 |
|---|---|---|---|
| why 注释释 | 英文,每条=决策+被否备选+负面后果 | 内联代码决策点(**例外**) | 紧贴代码,代码改注释跟着移 |
| 特征化测试 | 愉快路径 / 关键不变量 | 项目测试目录 `*_orient_test.*`(**例外**) | 可执行,一改就红 |
| intent-spec | 故/理/类 + 约束 + 验收 + 风险 | `docs/meaning/<feature>/intent.md` | 集中,被 `sweep` 审计 |
| decisions(ADR-lite) | 决策 + 被否备选 + 负面后果 | `docs/meaning/<feature>/decisions.md` | 集中;代码内 why 注释释是它的浓缩 |
| 阅读顺序 tour | `(文件:行, 看什么, 信标)` 有序列表 | `docs/meaning/<feature>/tour.md` | tour/sweep 时逐条校验 file:line;断了标红(类 sweep Type C) |
| understanding-record | 理解分 + 白话解释 + 隐含假设 + 复杂度 | `docs/meaning/<feature>/understanding.md` | 集中,与 tour 一起被 `sweep` 审计 |

目标项目里的目录布局:

```
<target-project>/docs/meaning/<feature>/
  intent.md          # intent-spec(故/理/类 + 约束 + 验收 + 风险)
  decisions.md       # ADR-lite 决策记录(决策 + 被否备选 + 代价)
  tour.md            # 阅读顺序 tour
  understanding.md   # understanding-record(理解分 + 白话解释 + 隐含假设)
```

### 5.3 intent-spec schema(墨子「故/理/类」)

```json
{
  "id": "intent_<feature>_<yyyymmdd>",
  "gu":  "故 (why): 为什么做这个变更",
  "li":  "理 (how): 遵循什么原则/方案",
  "lei": "类 (scope): 属于哪类变更",
  "constraints": ["..."],
  "acceptance_criteria": ["..."],
  "risk_analysis": { "extreme_scenario": "...", "fallback": "..." }
}
```

### 5.4 理解分(understanding-score)

把「感觉懂了」量化:费曼式自我解释 + 隐含假设复述 + 关键决策复述,按一致/缺失打分。记录在 understanding-record,让认知债**可见、可追踪**。v1 内嵌于 capture/tour;v2 汇总进仪表盘。

### 5.5 语言约定(遵循项目规则)

- 本设计文档、插件的用户向文档 → 中文。
- 插件 SKILL.md / command 文件 / README / 规则类文件 → 英文。
- 代码注释(含插件产出的 why 注释释)→ 英文。
- tour 文件、intent-spec、understanding-record 内容 → 英文(代码邻接的技术参考)。

---

## 6. 流水线集成

- **位置**:`simplify` 之后,作为「功能完成且干净」后的收尾步。
- **输入协同**:消费 brainstorming spec(设计意图)、writing-plans 的 plan、git diff/log、simplify/code-review 发现——这些都是「日后会蒸发」的 why 来源,趁新鲜最完整。
- **与 doc-sweep 的关系**:doc-sweep 迁入为 `sweep`,逻辑原样保留,只重新定位 + 扩大符号集合 + 改 scope。原 `~/.claude/skills/doc-sweep/` 在实现后下线。
- **正和**:`sweep` 守护 `capture` 产的符号(防漂移);`tour` 用符号重建并审计(互相校验)。
- **技术债 handoff(顺道,非重点)**:`capture` 后可选建议跑 simplify/code-review;v2 的 `status` 可顺带显示技术债并 offer 调用。

---

## 7. 插件结构(Claude Code plugin)

- **名**:`meaning`(Peirce "threats to meaning")。
- **三个 command(v1)**:`/meaning capture`、`/meaning tour`、`/meaning sweep`。
- **v2 command**:`/meaning status`(认知债/意图债仪表盘:理解覆盖率、意图完整性、知识衰退率)。
- **manifest**:`plugin.json`(name/version/description);每个 command 一个 command 文件;可能配套 skill 描述以利触发。
- **插件 home / 发现方式**:开发目录 `G:\Workspace\F2077\meaning`(WSL: `/mnt/g/Workspace/F2077/meaning`);如何让 Claude Code 发现(本地 marketplace 或置于 `~/.claude/plugins/`)→ 交 writing-plans 定。
- **命名空间与命令调用形式**:具体 `/<plugin>:<command>` vs `/<command>` 形式 → 交 writing-plans 按 CC 约定定。

---

## 8. 护栏(非协商)

- **反释义**:绝不复述代码已展示的东西,只答代码答不了的(为什么、被否了什么、不变量、隐藏耦合、故障模式)。
- **每个决策必须列 ≥1 个被否备选 + ≥1 个负面后果**,否则拒绝生成。
- **不静默改代码**:capture/sweep 先报告再确认(沿用 doc-sweep 护栏)。
- **抗漂移**:符号只允许长在代码里 / 可执行 / 贴符号旁的薄记录;禁向量库与漂浮工件。
- **主动优先**:capture/tour 默认主动(self-explanation / Socratic / Feynman);被动是逃生口,不是默认。
- **不替代理解**:强制验证理解,但不替代理解。
- **作用域纪律**:一次一个 feature;大功能先拆。
- **不 commit/push/add remote/开 PR**:仅编辑工作树 + 报告;在 main/master 仅提醒先开分支。

---

## 9. 边界与错误处理

- **无 spec/plan**:capture 仅靠代码 + git 降级工作。
- **非 git 项目**:跳过 git 范围划定,靠用户指文件。
- **无测试框架**:sweep/capture 跳过特征化测试,只留 why 注释释 + tour。
- **功能太大**:拆子功能,逐个 capture。
- **忘了 capture 直接 tour**:退化成冷重建(纯主动、不落盘),并提议现在补 capture。
- **主动模式用户烦躁**:提供逃生口切被动。
- **符号漂移被 tour 发现**:标红、指向 sweep,不默默信任。

---

## 10. v1 / v2 范围

- **v1(紧凑三件套 + 理解分)**:`capture` / `tour` / `sweep` + 内嵌理解分。Peirce 闭环跑通,最小可用。
- **v2(可见性层)**:① `status` 仪表盘(理解覆盖率 / 意图完整性 / 知识衰退率);② 代码变更自动标符号/theory 过期的 hook。

---

## 11. 验证与测试计划

- **真实功能 dry-run**:在一个刚交付的真实 feature 上跑 `capture` → 检查产出的符号是否抗漂移、是否答的是「代码答不了的」;隔一段时间跑 `tour` → 检验是否真的重建了理解(用户自报 + 理解分)。
- **sweep 自洽**:对 capture 产的符号制造漂移(改名/改行为),验证 sweep 能按 A/B/C/D 正确分类、且对 B 不粉饰。
- **护栏合规**:检查 capture 产出的每条 why 注释释都带被否备选 + 代价;检查 tour 不复述代码。
- **skill-reviewer**:用 plugin-dev 的 skill-reviewer / plugin-validator 审查插件结构与 skill 质量。
- **回归基线**:与原 doc-sweep 在等价输入上对比,确认 `sweep` 行为不退化。

---

## 12. 待定问题(交 writing-plans)

1. 插件 home 与发现方式(本地 marketplace vs `~/.claude/plugins/`)。
2. 命令调用形式与命名空间(`/meaning:capture` 等)。
3. `docs/meaning/` 布局是否可配(默认 `docs/meaning/<feature>/`,相对目标项目根)。
4. intent-spec / understanding-record 的确切文件格式与命名约定。
5. 理解分的打分细则(维度与权重)。
6. capture 的「先报告再确认」交互在 command 里的具体实现(AskUserQuestion / 文本确认)。
7. doc-sweep 迁移的切换路径(原 `~/.claude/skills/doc-sweep/` 何时下线)。

---

## 13. 参考资料

1. Margaret-Anne Storey — *From Technical Debt to Cognitive and Intent Debt*, ACM Queue 2026-05 / arXiv 2603.22106. https://arxiv.org/abs/2603.22106
2. Margaret-Anne Storey — *Three Debts, Three Threats to Meaning*(2026-06-23). https://margaretstorey.com/blog/2026/06/23/three-threats-to-meaning/
3. Margaret-Anne Storey — *How Generative and Agentic AI Shift Concern from Technical Debt to Cognitive Debt*(2026-02-09). https://margaretstorey.com/blog/2026/02/09/cognitive-debt/
4. Addy Osmani — *Comprehension Debt*. https://addyosmani.com/blog/comprehension-debt/
5. MIT Media Lab — *Your Brain on ChatGPT*(Kosmyna). **注:该研究有争议(样本小、可复现性受质疑),仅列作背景,不作为本设计的证据依据。** https://www.media.mit.edu/publications/your-brain-on-chatgpt/
6. Anthropic — *How AI Impacts Skill Formation*. https://www.anthropic.com/research/AI-assistance-coding-skills
7. Peter Naur — *Programming as Theory Building*(1985). https://gwern.net/doc/cs/algorithm/1985-naur.pdf
8. Chi 等 — *Eliciting Self-Explanations Improves Understanding*(1994);及自我解释效应相关迁移研究。
9. 既有 skill:`doc-sweep`(`~/.claude/skills/doc-sweep/SKILL.md`)——`sweep` 组件的直接前身。

---

*文档版本:0.1 (Draft)*
