# defossilize 插件设计文档

- **日期**: 2026-07-03
- **状态**: Draft(待用户 review)
- **主题**: 一个把"化石"代码重新变活的 Claude Code 插件——缓解「意图债」与「认知债」,并把这两种隐形债变可见、可还
- **取代**: `docs/2026-07-01-meaning-plugin-design.md`(插件由 `meaning` 改名为 `defossilize`,全量重定框;改名映射见 §14)

---

## 0. TL;DR

`defossilize` 是一个用户级 Claude Code 插件。它立足于 Margaret-Anne Storey 的**三重债务模型**(技术债 / 意图债 / 认知债)与 Peirce 符号三角,专门修复其中两项——**意图债(Sign 符号)**与**认知债(Interpretant 解释项)**,把对常规指标(velocity / DORA / 覆盖率)隐形的这两种债**变可见、可还**。技术债(Object)委托给既有的 superpowers / simplify / code-review。

**核心隐喻:理解是一条石化光谱。** 代码不会只在"我完全懂"和"遗留黑箱"两极——它沿着一条连续光谱退化:

- **活的**:刚写、真懂 → `preserve` 趁它活着把 theory 钉进符号,**防止石化**
- **半石化的**:写过、忘了,符号还在 → `thaw` 用符号把褪色的理解**救活**
- **全石化的**:遗留系统 / AI 外包黑箱,无符号、无 theory → `excavate` **发掘**(triage + git 考古 + 未知地图)→ `revive` **复活**(逐热点预测→验证重建 theory)
- **贯穿保养**:`curate` 让符号↔代码持续对齐,防止符号本身石化

> **关键洞察(v1.1 新增,驱动本次重定框)**:用 AI 写到一半、我们已经不理解的代码,本质也是化石——理论从未真正在我们脑中活过(Anthropic RCT:被动外包型理解 -17%;Naur:AI 生成的是文本,不是理论)。所以"化石"不只覆盖遗留系统,也覆盖 AI 时代日常产出的"外包黑箱"。`defossilize` 命名的是插件的核心**动作**(反石化),而非 Peirce 的抽象威胁——这个动作横跨光谱所有阶段,这正是五个命令住进一个插件、而非五个孤立工具的根本理由。

核心元原则,源自 Naur《Programming as Theory Building》:**插件必须真的建造 theory(开发者脑中的理解),而不是堆砌工件。** AI 生成的是文本,不是理论;文档替代不了理论。这条原则在 `revive` 上受到最大张力——面对全化石,AI 是唯一能把整坨代码同时放进上下文的实体,因此 `revive` 的协议必须把"读代码 + 下判断"的认知劳动**硬性留在人这一侧**(见 §4.5、§8)。

---

## 1. 背景与问题

### 1.1 痛点

用户工作流:`superpowers`(brainstorming → writing-plans → executing → TDD)→ `code-review`(正确性)→ `simplify`(可维护性)。这套很顺。两个痛点:

1. **功能交付后,用户在代码层面看不懂了**——知道功能是啥,但读不懂自己的代码、还原不出为什么这么写。(半石化)
2. **接手遗留系统 / 面对 AI 外包出来的黑箱**:从一开始就没有 theory,认知债≈∞,无从下口。(全石化)

### 1.2 三重债务模型(Storey, ACM Queue 2026-05, arXiv 2603.22106)

Peirce 的意义三元组映射到软件健康:

| Peirce | 在软件里 | 对应的债 | 侵蚀的是什么 | 谁修 |
|---|---|---|---|---|
| **Object(客体)** | 代码本身 | **技术债** | 系统本身的质量 | superpowers / simplify / code-review |
| **Sign(符号)** | 意图工件:spec、注释、决策记录、rationale、commit msg、测试即规约 | **意图债** | 符号缺失/过时/自相矛盾 | **本插件 `curate` + `preserve` + `revive`** |
| **Interpretant(解释项)** | 开发者脑中的共享 theory | **认知债** | theory 蒸发/碎片化/从未建立 | **本插件 `preserve` + `thaw` + `revive`** |

Peirce 的硬约束:**三元缺一,意义就崩。** Storey 给的两个偏角状态正好证明两债必须一起抓:"有符号但人还是懵的"(低意图债、高认知债)与"符号缺了但人还知道"(高意图债、低认知债)。修符号 ≠ 修理解;理解没有符号又很脆。

**石化 = Interpretant 的死亡。** 活的代码三 元俱全;半石化是 Interpretant 蒸发(人忘了)、Sign 还在;全石化是 Interpretant 从未建立(遗留/外包)、Sign 也缺。`defossilize` 的动作就是沿光谱反向重建 Interpretant,并把 Sign 补齐/对齐。

### 1.3 理论根与证据

- **Naur(1985), Programming as Theory Building**:程序不只是源码,而是活在开发者脑中的 theory(做什么 / 意图如何实现 / 如何修改)。程序有「生命/死亡/复活」:团队散了程序就死,**仅凭文档无法复活,通常要推倒重来**。→ 认知债的本质就是 theory 流失/缺失;**AI 生成的是文本,不是理论**。→ `revive` 必须诚实:死掉的 theory 无法从工件完整复活,只能逐热点重建 + 显式标不可考。
- **Osmani, Comprehension Debt**:理解债 = 代码总量与人类真正理解量之间不断扩大的鸿沟;它对一切正常指标隐形,滋生虚假信心;速度不对称(AI 生成远快于人类评估)打破了审查反馈环;测试/规格无法替代理解(测不了没想到的行为)。
- **Chi 等,自我解释效应(含 Bisra 等 2018 元分析)**:让学习者向自己解释材料,可靠提升理解、减少错误,并已迁移到编程领域。**这是支撑「主动 > 被动」设计决策的主证据与最强杠杆**(元分析级别、可复现)。→ preserve/thaw/revive 默认 self-explanation / Socratic / Feynman / prediction。
- **Anthropic, How AI Impacts Skill Formation(单次 RCT,n=52)**:AI 辅助组理解测验低 17%(50% vs 67%),调试差距最大;使用方式决定收获(被动外包型 ~40%、主动探究型 >65%)。方向性支持,**非定论**(单任务、单框架、样本小)。→ 直接驱动 `revive` 的"预测在前"协议(§4.5):阻止退化成被动外包。
- **MIT, Your Brain on ChatGPT(Kosmyna)**——*有争议,不作为证据引用*:样本小、EEG 子组更小、「没有认知信用卡」属戏剧化断言、可复现性受质疑。**本设计不依赖它**。

**由此得出的元主题**:认知债/意图债隐形,所以插件的更深层使命是把它们**变可见、可还**;而 Naur 说文档替代不了 theory,所以插件的核心动作必须是**建造 theory(主动建构理解)**,而非生产更多会漂移的工件。这条在 `revive` 上最吃紧——重建出来的符号是**假说**,不是事实,必须带溯源与置信度(§5.5)。

---

## 2. 使命与范围

### 2.1 使命

修复 Peirce 三元组中的 **Sign(意图债)** 与 **Interpretant(认知债)** 两端,把这两种隐形债变可见、可还;沿石化光谱反向重建 theory,对抗「外包思考」造成的 theory 流失与缺失。

### 2.2 In scope(v1)

五个命令构成石化光谱闭环 + 内嵌理解分:

- **`preserve`**(原 capture):趁上下文新鲜(在 `simplify` 之后)结构化声明意图 + 记录意图→代码决策路径 + 落抗漂移符号 + 自我解释检查点产出「理解分」。
- **`thaw`**(原 tour):忘了时按需,加载并审计符号 → 粗粒度 orient → 苏格拉底/费曼重建 + 挖隐含假设 + 极端场景 → 理解分。
- **`excavate`**(新):接手化石系统时,triage + git 考古 + 产出「未知/置信度地图」+ 选热点。
- **`revive`**(新):逐热点,预测→验证重建 theory + 落带溯源的抗漂移符号 + 理解分。
- **`curate`**(原 sweep,泛化自 doc-sweep):符号 ↔ 代码持续对齐,A/B/C/D 分类 + 对重建符号的「重建错了」第三档;审计插件自产的符号。

### 2.3 Non-goals(明确不做)

- **不修技术债**(Object):复杂度/过度设计/根因 = `simplify` 与 `code-review` 的活。插件只**顺道 handoff**(建议/调用),不做。
- **不做向量库 / 知识图谱**:高漂移、重基建,与抗漂移原则冲突。所有符号要么长在代码里、要么可执行、要么是贴在符号旁的薄记录。
- **不做 `/decompose`(任务分解)**:属于规划,是 superpowers / writing-plans 的活。
- **不做投机性产物**:物理类比库、纳博科夫卡片库、自动生成图——无证据减债、且脱离代码会漂移。
- **不做自动触发的 hook**:不挂 `pre/post codegen`、不在每次改动上自动写代码/检查(surprising,且和「不静默改」护栏冲突)。
- **不替代理解**:插件强制验证理解,但不替代理解(原则:理解不可外包)。`revive` 尤其如此——AI 提假说,人读代码下判断。
- **不"复活"不可考的 theory**:Naur 警告死 theory 无法从工件完整复活。`excavate`/`revive` 对不可考处显式标 unknown / 建议重写,绝不编造意图。

---

## 3. 架构:石化光谱与 Peirce 闭环

```
                        ┌─────────────────────────────────────────────┐
   Object(代码)        │   技术债 ──→ 委托 superpowers/simplify/review │
                        └─────────────────────────────────────────────┘
                                         │
                            (代码是符号的对齐基准)
                                         │
   Sign(意图工件)  ◀─── curate:符号↔代码对齐(意图债) ───▶  自产符号(含重建符号)也被审计
        ▲                                                        │
        │preserve 造权威符号 / revive 造重建符号(减意图债)       │ thaw 用符号重建
        │                                                        │ theory 并审计符号
        ▼                                                        ▼
   Interpretant(theory) ◀─── preserve 趁新鲜钉 + thaw 重建 + revive 反向重建(认知债) ───▶ 理解分
```

石化光谱(本次重定框的核心):

```
   活的 ────────── 半石化 ────────── 全石化
   (刚写真懂)      (写过忘了)        (遗留/外包黑箱)
      │                │                 │
   preserve          thaw            excavate → revive
   (防石化:钉符号)  (救活:符号→理解) (发掘→复活:代码→预测→假说→对账→符号+理解)
                       │
            ┌──────────┴───────────┐
            │  curate 贯穿保养:符号↔代码对齐,防符号本身石化
            └──────────────────────┘
```

- `preserve` 同时减两债:既造**权威**符号(补 Sign,减意图债),又在上下文新鲜时用自我解释把 theory 钉住(建 Interpretant,减认知债)——这是最高杠杆的一步。
- `thaw` 用符号重建 theory 并审计符号(减认知债 + 暴露意图债,断链指向 `curate`)。
- `excavate` 面对全化石:不试图一次复活,先画出**未知地图**(认知债的面积问题),选热点。
- `revive` 逐热点反向重建:从代码 + git 化石出发,预测→验证重建 theory,产出**重建**符号(减两债,但符号带溯源/置信度)。
- `curate` 保符号对齐(意图债),并对**重建符号**多审一档「重建错了」。
- **符号与理解互相喂养、互相校验**——这是 Sign↔Interpretant 的循环本体,也是「一个插件」而非「五个工具」的根本理由。

---

## 4. 组件设计

### 4.1 `preserve` — 趁活着:声明意图 + 记录决策 + 落符号 + 钉 theory(原 capture)

**触发**:`simplify` 之后(功能完成且干净、上下文新鲜),或开发中任意「现在最懂」的时刻。手动触发(`/defossilize:preserve`)。

**输入(此刻最丰富)**:代码、`git log`/`git diff`、brainstorming spec、writing-plans 的 plan、simplify/code-review 的发现。

**步骤**:

1. **定范围**:用户指(feature 名 / 文件 / 最近 diff / spec);插件复述确认。功能太大 → 拆子功能。
2. **结构化声明意图**(减意图债 + 用苏格拉底挑战):
   - 产出 `intent-spec`,采用**墨子「故/理/类」**三层元数据(§5.3)。
   - 对模糊处用**苏格拉底式追问**(概念澄清 / 边界探测 / 依赖检查 / 约束平衡)。
   - 用**归谬法**做极端场景风险预警,录入 `risk_analysis`。
3. **记录意图→代码决策路径**(减意图债):对每个非显而易见决策产出 **ADR-lite**——决策 + **≥1 个被否备选** + **≥1 个负面后果**(硬约束:不列被否项和代价的「解释」是宣传,不是理解,一律拒绝)。
4. **落抗漂移符号**(减意图债,先报告再确认):提议并落盘——why 注释(英文,内联在代码决策点);阅读顺序 tour 文件(`docs/defossil/<unit>/tour.md`);特征化测试(愉快路径 / 关键不变量,正常测试目录)。**沿用 doc-sweep 的「先报告再确认」护栏,不静默改代码。**
5. **自我解释检查点 → 理解分**(减认知债,趁便宜钉死 theory):关掉代码,用**费曼技巧**让用户用大白话解释 2–4 个关键决策/数据流;插件对比代码,指出不一致并追问,直到一致。产出**理解分**与一份通过验证的「白话解释」。用户卡住处 = 标记为日后要 revisit 的缺口。
6. **产出 understanding-record**(§5.2):理解分 + 白话解释 + 暴露的隐含假设 + 复杂度备注。存为 `docs/defossil/<unit>/understanding.md`。**provenance = preserve(权威)**(§5.5)。
7. **校验 + 汇总**:符号引用真实代码、测试通过;报 N 条 why 注释 / 1 份 tour / M 个测试 / 理解分 / K 个缺口。可选:建议跑 simplify/code-review(技术债 handoff)。

### 4.2 `thaw` — 半石化:加载符号 → 粗粒度 orient → 苏格拉底重建(原 tour)

**触发**:忘了功能代码细节时,按需(`/defossilize:thaw`)。

**步骤**:

1. **定范围 + 加载并审计符号**:读 tour 文件 / why 注释 / 特征化测试 / understanding-record;逐条校验 drift(断链 file:line、失效测试、过期记录)——**发现了就标红,绝不默默信任**;断链符号指向 `curate` 去修(暴露意图债)。**对 provenance=revive 的重建符号额外提醒:矛盾可能是重建错了,而非漂移**。
2. **粗粒度 orient(被动、一屏)**:入口、形状、东西在哪、愉快路径数据流。快速给地图。
3. **细粒度苏格拉底重建(主动,核心)**:自适应深度——
   - **费曼技巧**:让用户解释某块 / 预测行为 / 确认或否决假设;扎实就跳过、发虚就深挖。
   - **解构主义**:标注代码中未声明但依赖的**隐含假设**(对外部 API 响应格式、输入格式、系统状态、数据量的假设),给每个假设失效时的风险等级。
   - **归谬法**:对关键逻辑分支构建「正常 / 极端 / 故障」场景,推演行为。
   - **绝不复述代码已展示的东西**,只用符号 + 代码答代码答不了的(为什么、被否了什么、不变量、隐藏耦合、故障模式)。
4. **理解分**:重建后用理解验证测验证收(同 §4.1 步骤 5 的机制)。
5. **不落盘**(纯交互)。若发现符号没覆盖的缺口,**提议**补一条 why 注释(capture-lite,需确认)。
6. **逃生口**:用户说「直接给我看」就切被动讲解(尊重自主)。

### 4.3 `curate` — 保养:符号 ↔ 代码对齐 + 重建符号复验(原 sweep,泛化自 doc-sweep)

**身份**:doc-sweep 迁入并泛化(意图 ≠ doc,见 §5.1 符号集合)。A/B/C/D 分类原样保留;**新增对重建符号的「重建错了」处理**(§5.5 驱动)。

**触发**:定期 / 重构/改名/迁移后 / 发布前 / 常规卫生。手动(`/defossilize:curate`)。

**步骤**(沿用 doc-sweep,符号集合扩大 + provenance 感知):

1. **Discover**:盘点两侧——符号(§5.1 全集)+ 源代码。`git ls-files --cached --others --exclude-standard`;memory 即便 gitignore 也纳入(report-only)。
2. **Analyze & classify**:对每条触及行为/签名/类型/副作用/错误/外部契约的符号主张,对照代码验证,分 A/B/C/D(下)。**读 provenance**:对 `revive` 产的重建符号,矛盾时多考虑「重建错了」(E)。
3. **Report**:分组报告,每条带 `file:line` + **provenance/confidence**;区分「will fix(A/C)」「疑似 bug(B)」「propose only(D)」「重建错了,建议重验(E)」。
4. **Confirm**:默认应用所有在范围的 A 和 C;B、D、E 不自动应用。
5. **Apply**:批量最小、忠实编辑(保留原语气/语言)。不 commit。
6. **Verify & handoff**:复查;汇总 N fixed / M flagged / K proposed / L to-reverify;在 main/master 提醒用户先开分支。
7. **自审**:插件自产的符号(含 preserve 的权威符号、revive 的重建符号、excavate 的 map)同样纳入审计。**低置信重建符号优先排入复验队列**(代码一改,它们的信任最先掉)。

**分类(沿用 doc-sweep + 新增 E)**:

- **A 行为漂移**:符号描述的行为代码已不匹配,且代码是刻意的工作行为 → 改符号。
- **B 不变量/契约违反**:符号陈述 must/always/never/invariant,代码违反 → **不动代码、不改符号粉饰**,标疑似 bug。
- **C 过时引用**:重命名符号 / 失效链接 / 错误路径签名 → 改符号。
- **D 出编辑范围**:符号在 agent 指令文件(CLAUDE.md 等)或 memory → 只报告、提议,不写。
- **E 重建错了(新,仅对 provenance=revive 的重建符号)**:重建符号与代码矛盾,且代码是刻意的工作行为,但矛盾不是符号过时、而是**当初重建就误读了** → **既不照代码改符号粉饰(那会把误读固化)、也不怪代码**;标「重建错了」,建议对该点重跑 `revive`。这一档是 §5.5 溯源带来的认识论诚实:重建件本就可能错。

### 4.4 `excavate` — 全化石·发掘:triage + git 考古 + 未知地图 + 选热点(新)

**触发**:接手遗留系统、或发现某块是 AI 外包黑箱时。手动(`/defossilize:excavate`)。**不试图一次复活**——先解决认知债的**面积问题**:画地图、选热点。

**输入**:代码;**git 考古**(commits / PR/MR 描述 / blame / 改名历史)——当作**降解的意图化石**(离场作者留下的意图残骸);既有符号(通常没有,若有则一并审计)。

**步骤**:

1. **定范围**:用户指(系统名 / 顶层目录 / 模块边界);插件复述确认。太大 → 按模块/包切,逐个 excavate。
2. **挖 git 化石**:把提交信息、PR/MR 描述、blame、改名/移动历史当作**降解符号**挖掘——它们是意图的残骸,不是权威。**自适应(硬约束)**:无 git / 被 squash / 从别处迁移而历史断绝 → 降级到只靠代码结构 + 用户指认,并在地图上显式标「无化石可考」。**绝不盲目背书 git 化石**——只标红引用,验证后才采信。
3. **画未知地图**:逐区域估理解薄度,产出 `map.md`。每区域记:
   - `area`(模块/路径)
   - `understanding`(低/中/高;无符号默认低)
   - `basis`(信号集,见下)
   - `recoverability`(能从 git 化石 / 注释 / 结构恢复 → 候选 `revive`;还是已不可考 → 候选重写,而非硬理解)
   - `risk_if_wrong`(理解错了会炸什么:爆炸半径、数据安全、外部契约)
4. **选热点**:按 (understanding 低 × risk_if_wrong 高 × recoverability 可) 排序,提 top-N 给 `revive`;用户确认/调整。
5. **产出**:`docs/defossil/<system>/map.md`(持久——它是后续多次 revive 的索引,也要被 curate 审计)。

**热点信号(默认集,可在 plan 细化)**:变更频率(churn)、爆炸半径(dependents 数)、复杂度、**有无符号**、git-blame 年龄(越久越可能意图蒸发)、用户主观「这块吓人」。

**护栏**:反释义(地图答「哪里薄/险/不可考」,不答「代码在干嘛」);诚实标 unknown/不可考(Naur);git 化石是降解符号,只标红引用、绝不背书;不静默改码;一次一个系统。

### 4.5 `revive` — 全化石·复活:逐热点预测→验证重建 theory(新)

**触发**:`excavate` 选出热点后逐个 `/defossilize:revive`;或用户直接指一个热点(跳过 excavate,退化模式)。**面对全化石,AI 是唯一能整坨读代码的实体,所以协议必须把认知劳动留在人这一侧。**

**输入**:`excavate` 的 map(若有)+ 该热点的代码 + git 化石 + 既有符号(若有)。

**核心协议(每个非显而易见决策点,三阶段)**:

| 阶段 | 谁 | 做什么 |
|---|---|---|
| **① 预测** | **用户** | AI 指一处代码 + 提问(「你觉得这为啥存在 / X 输入时发生什么?」);**用户读代码并下一个判断**(连「我没头绪」也是合法低置信预测)。**预测在前是命门**——逼用户先形成 theory。 |
| **② 揭示** | AI | 给假说:意图 + **≥1 被否备选 + ≥1 负面后果**(沿用 ADR-lite 纪律)+ 置信度 + 它所立的代码证据。**只答 WHY,不复述 WHAT**(守反释义)。无法从代码+化石支持的意图 → 明确标 unknown,不编造。 |
| **③ 对账** | **用户** | 拿代码证据证实/证伪/修正 AI 假说。用户预测对了 → 高学习、符号记用户洞见;AI 假说更贴代码 → 用户更新 theory(主动学习);都对不上 → **标 unknown,留待后续或建议重写**。 |

**为何是这套协议(证据)**:spec §1.3 引的自我解释研究,核心是「先逼学习者表态,再给反馈」——表态那一刻才是 theory 被建造的瞬间。若 AI 先给假说、用户只点头,就退化成 Anthropic RCT 警告的被动外包(-17%)。所以顺序硬性:**用户先读先判,AI 假说只当对账反馈**。

**完整步骤**:

1. **定范围 + 载入热点**:从 map 取热点,或用户指;复述确认。太大 → 拆子热点。
2. **逐决策点跑「预测→揭示→对账」**(上表)。bounded:只对热点内**非显而易见**决策跑,不迫全覆盖(沿用 preserve 的「非显而易见」门槛)。
3. **解构隐含假设**(沿用 thaw):标注代码未声明但依赖的假设(外部 API 形状 / 输入格式 / 系统状态 / 数据量),给每个失效风险等级。
4. **落抗漂移符号(先报告再确认)**:why 注释(英文,内联)、tour 条目、特征化测试——**位置同 preserve**(§5.2 抗漂移规则不变)。**但所有符号 provenance=revive + 带置信度**(§5.5)。
5. **理解分**:同机制,但语义 = 「**已重建多少 theory**」,起点≈0;revive 后仍低是诚实的——它量的是「还剩多少化石」,不是失败。记录在 `understanding.md`。
6. **产出**:`docs/defossil/<system>/<hotspot>/{intent,decisions,tour,understanding}.md`,全部 provenance=revive。intent-spec 仍用故/理/类,但 `gu`(故)可能只能写「重建推测」或标 unknown。
7. **校验 + 汇总 + handoff**:符号引用真实代码、特征化测试通过;报 N 决策点 / K unknown / 理解分 / 还剩多少。对 `recoverability=不可考` 的子区域,**建议重写而非继续硬理解**(技术债 handoff)。

**护栏(非协商)**:预测在前(防橡皮图章);反释义;每个假说需被否备选+代价,或显式标 unknown;不静默改码(先报告再确认);**不编造意图**——代码+化石支持不了的就标 unknown;一次一个热点。

---

## 5. 共享概念

### 5.1 符号集合(curate 的审计范围;意图 ≠ doc)

意图工件远比「文档」宽,凡是承载系统 rationale 的都是符号:

- 代码注释 & docstring
- README / CHANGELOG / CONTRIBUTING / `docs/**` / 任意 `*.md`/`*.rst`/`*.adoc`
- 契约规约:OpenAPI/Swagger、`*.proto`、GraphQL、JSON Schema
- **ADR / 决策记录**(含本插件产的 `decisions.md`)
- **brainstorming spec + writing-plans 的 plan**
- **commit message + PR/MR 描述**(也是 `excavate` 的 git 化石来源)
- **测试即规约**(断言编码预期行为)
- **`excavate` 产的 `map.md`**(新,系统级意图地图)
- agent 指令文件(CLAUDE.md / AGENTS.md / .cursorrules …)→ report-only
- memory(`.claude/.../memory`、`.remember`)→ report-only

### 5.2 抗漂移符号:形态、位置、抗漂移机制

**落盘规则**:**所有独立记录类工件统一落在目标项目的 `docs/defossil/<unit>/` 下**(`<unit>` = feature,或遗留场景的 system/hotspot)。整洁、可被 `curate` 集中审计。**两类例外必须留在原位**,因为它们的位置本身就是抗漂移机制——挪走就失效:

- **why 注释** → 留在代码内联(紧贴决策点,代码改它跟着移)。
- **特征化测试** → 留在项目测试目录(被测试框架发现、可执行,一改就红)。

> 注:`docs/defossil/` 是**目标项目**(插件运行命令的那个代码库)里的目录,不是插件自身源码的 home。

| 符号 | 形态 | 位置 | 抗漂移机制 |
|---|---|---|---|
| why 注释 | 英文,每条=决策+被否备选+负面后果(+provenance 标记) | 内联代码决策点(**例外**) | 紧贴代码,代码改注释跟着移 |
| 特征化测试 | 愉快路径 / 关键不变量 | 项目测试目录 `*_orient_test.*`(**例外**) | 可执行,一改就红 |
| intent-spec | 故/理/类 + 约束 + 验收 + 风险 | `docs/defossil/<unit>/intent.md` | 集中,被 curate 审计 |
| decisions(ADR-lite) | 决策 + 被否备选 + 负面后果 | `docs/defossil/<unit>/decisions.md` | 集中;代码内 why 注释是它的浓缩 |
| 阅读顺序 tour | `(文件:行, 看什么, 信标)` 有序列表 | `docs/defossil/<unit>/tour.md` | curate 时逐条校验 file:line;断了标红(类 C) |
| understanding-record | 理解分 + 白话解释 + 隐含假设 + 复杂度 | `docs/defossil/<unit>/understanding.md` | 集中,与 tour 一起被 curate 审计 |
| **未知地图(新)** | 区域 × understanding × recoverability × risk | `docs/defossil/<system>/map.md` | 集中,被 curate 审计;excavate/revive 的索引 |

目标项目里的目录布局:

```
<target-project>/docs/defossil/
  <feature>/                 # preserve / thaw 的单元
    intent.md  decisions.md  tour.md  understanding.md
  <system>/                  # excavate / revive 的单元(遗留)
    map.md                   # excavate 产:未知/置信度地图 + 热点列表
    <hotspot>/               # revive 逐热点产(全部 provenance=revive)
      intent.md  decisions.md  tour.md  understanding.md
```

### 5.3 intent-spec schema(墨子「故/理/类」)

```json
{
  "id": "intent_<unit>_<yyyymmdd>",
  "provenance": "preserve | revive",
  "gu":  "故 (why): 为什么做这个变更(preserve=已知;revive=重建推测或 unknown)",
  "li":  "理 (how): 遵循什么原则/方案",
  "lei": "类 (scope): 属于哪类变更",
  "constraints": ["..."],
  "acceptance_criteria": ["..."],
  "risk_analysis": { "extreme_scenario": "...", "fallback": "..." }
}
```

> revive 产的 intent-spec,`gu` 常只能写「重建推测」或显式标 unknown——这是认识论诚实,不是缺陷。

### 5.4 understanding-score(理解分)

把「感觉懂了」量化:费曼式自我解释 + 隐含假设复述 + 关键决策复述,按一致/缺失打分。记录在 understanding-record,让认知债**可见、可追踪**。

- **preserve / thaw**:分语义 = 「现在掌握多少」。
- **revive(新)**:分语义 = 「**已重建多少 theory**」,起点≈0;低分是诚实映射「还剩多少化石」,不是失败。
- v1 内嵌于 preserve/thaw/revive;v2 汇总进仪表盘。

### 5.5 符号溯源 provenance(新,revive 驱动)

**问题**:`preserve` 产的符号是**权威**(作者知道意图);`revive` 产的符号是**重建假说**(可能误读)。若不区分,`curate` 会把「重建错了」误判成「漂移」(照代码改符号,把误读固化)或「bug」(怪代码)。

**方案**:

- 所有 revive 产的记录类工件(intent / decisions / tour / understanding + why 注释)带 **`provenance=revive`** + **`confidence`**(high/med/low,默认起 med/low);preserve 产的对应工件 `provenance=preserve`(权威)。
- **`map.md` 是元索引**(区域的薄/厚估计),非对代码的意图主张 → **豁免 provenance**,但仍被 curate 审计其引用是否失效(类 C:区域路径失效、热点 file:line 断链)。
- `curate` 读 provenance:对 `revive` 符号矛盾时,新增分类 **E「重建错了」**(§4.3)——建议重跑 revive,既不粉饰也不怪代码。
- `curate` 把低置信重建符号**优先排入复验队列**;代码改动后,重建符号信任衰减最快。
- `thaw` 载入重建符号时,显式提醒「这是重建件,矛盾可能是重建错了」。

化石隐喻自洽:**复活出来的标本是重建件,不是活体本身**;溯源就是贴在标本上的「重建,非原作」标签。

### 5.6 语言约定(遵循项目规则)

- 本设计文档、插件的用户向文档 → 中文。
- 插件 command 文件 / `plugin.json` / README / 规则类文件 → 英文。
- 代码注释(含插件产的 why 注释)→ 英文。
- tour 文件、intent-spec、understanding-record、map 内容 → 英文(代码邻接的技术参考)。

---

## 6. 流水线集成

- **preserve 的位置**:`simplify` 之后,作为「功能完成且干净」后的收尾步。
- **preserve 输入协同**:消费 brainstorming spec(设计意图)、writing-plans 的 plan、git diff/log、simplify/code-review 发现——这些都是「日后会蒸发」的 why 来源,趁新鲜最完整。
- **遗留流水线(新)**:`excavate`(画地图、选热点)→ 逐个 `revive`(预测→验证重建)→ 必要时 `thaw`(日后忘了再救活)→ `curate` 贯穿保养(含重建符号复验)。可从 `revive` 直入(跳过 excavate,退化)。
- **与 doc-sweep 的关系**:doc-sweep 迁入为 `curate`,逻辑原样保留 + 泛化符号集合 + provenance 感知 + scope 到 `docs/defossil/`。原 `~/.claude/skills/doc-sweep/` 在实现后下线。
- **正和**:`curate` 守护 preserve/revive 产的符号(防漂移 + 重建符号复验);`thaw` 用符号重建并审计;`excavate` 的 map 是 revive 的索引。
- **技术债 handoff(顺道,非重点)**:`preserve`/`revive` 后可选建议跑 simplify/code-review;`excavate` 对不可考处建议重写。

---

## 7. 插件结构(Claude Code plugin)

- **名**:`defossilize`(反石化;原 `meaning`)。
- **五个 command(v1)**:`/defossilize:preserve`、`/defossilize:thaw`、`/defossilize:excavate`、`/defossilize:revive`、`/defossilize:curate`。
- **v2 command**:`/defossilize:status`(认知债/意图债仪表盘:理解覆盖率、意图完整性、知识衰退率、重建符号置信度分布)。
- **manifest**:`plugin.json`(name/version/description);每个 command 一个 command 文件;可能配套 skill 描述以利触发。
- **插件 home / 发现方式**:开发目录 `G:\Workspace\F2077\defossilize`(WSL: `/mnt/g/Workspace/F2077/defossilize`)——**目录随插件改名**(§14);如何让 Claude Code 发现(本地 marketplace 或置于 `~/.claude/plugins/`)→ 交 writing-plans 定。
- **命名空间与命令调用形式**:具体 `/defossilize:<command>` vs `/<command>` 形式 → 交 writing-plans 按 CC 约定定。

---

## 8. 护栏(非协商)

- **反释义**:绝不复述代码已展示的东西,只答代码答不了的(为什么、被否了什么、不变量、隐藏耦合、故障模式)。
- **每个决策必须列 ≥1 个被否备选 + ≥1 个负面后果**,否则拒绝生成(revive 下,列不出就标 unknown,不编造)。
- **不静默改代码**:preserve/revive/curate 先报告再确认(沿用 doc-sweep 护栏)。
- **抗漂移**:符号只允许长在代码里 / 可执行 / 贴符号旁的薄记录;禁向量库与漂浮工件。
- **主动优先**:preserve/thaw/revive 默认主动(self-explanation / Socratic / Feynman / **prediction**);被动是逃生口,不是默认。
- **不替代理解**:强制验证理解,但不替代理解。**revive 尤其:预测在前,AI 假说只当对账反馈,认知劳动留在人这一侧。**
- **不编造意图(revive/excavate 专属)**:代码+化石支持不了的意图 → 标 unknown / 建议重写,绝不编造。Naur:死 theory 无法完整复活。
- **作用域纪律**:一次一个 unit(feature / system / hotspot);大单元先拆。
- **不 commit/push/add remote/开 PR**:仅编辑工作树 + 报告;在 main/master 仅提醒先开分支。

---

## 9. 边界与错误处理

- **无 spec/plan**:preserve 仅靠代码 + git 降级工作。
- **非 git 项目**:curate/preserve 跳过 git 范围划定,靠用户指文件;**excavate 降级——无 git 化石可挖,只靠代码结构 + 用户指认,并在 map 显式标「无化石可考」**。
- **无测试框架**:curate/preserve/revive 跳过特征化测试,只留 why 注释 + tour。
- **单元太大**:preserve 拆子 feature;excavate 拆模块;revive 拆子热点。
- **忘了 preserve 直接 thaw**:退化成冷重建(纯主动、不落盘),并提议现在补 preserve。
- **直接 revive 跳过 excavate**:允许(退化模式),用户自指热点;但建议先 excavate 画地图。
- **revive 遇不可考意图**:标 unknown,建议重写而非硬理解;不编造。
- **主动模式用户烦躁**:提供逃生口切被动。
- **符号漂移被 thaw/curate 发现**:标红、指向 curate,不默默信任。
- **重建符号被 curate 判矛盾**:走 E 档(重建错了),建议重跑 revive。

---

## 10. v1 / v2 范围

- **v1(五件套 + 理解分 + provenance)**:`preserve` / `thaw` / `excavate` / `revive` / `curate` + 内嵌理解分 + 符号溯源。石化光谱闭环跑通,最小可用——既覆盖"趁新鲜防石化",也覆盖"全化石复活"。
- **v2(可见性层)**:① `status` 仪表盘(理解覆盖率 / 意图完整性 / 知识衰退率 / 重建符号置信度);② 代码变更自动标符号/theory 过期的 hook。

---

## 11. 验证与测试计划

- **preserve 真实功能 dry-run**:在一个刚交付的真实 feature 上跑 `preserve` → 检查产出的符号是否抗漂移、是否答的是「代码答不了的」;隔一段时间跑 `thaw` → 检验是否真的重建了理解(用户自报 + 理解分)。
- **excavate + revive 遗留 dry-run(新)**:在一个故意 obscure 的小 fixture(无符号、有 git 历史)上跑 `excavate` → 检查 map 是否标出薄区/不可考处;选一个热点跑 `revive` → 检查是否走「预测→揭示→对账」、产出的重建符号是否带 provenance/置信度、不可考处是否标 unknown 而非编造。
- **curate 自洽 + provenance**:对 preserve/revive 产的符号制造漂移(改名/改行为),验证 curate 能按 A/B/C/D 正确分类;**对 revive 符号制造「重建错了」情景,验证走 E 档、不粉饰、不怪代码**。
- **护栏合规**:检查每条 why 注释都带被否备选 + 代价;检查 thaw/revive 不复述代码;**检查 revive 预测在前、AI 不先给答案**。
- **skill-reviewer / plugin-validator**:用 plugin-dev 的工具审查插件结构与 skill 质量。
- **回归基线**:与原 doc-sweep 在等价输入上对比,确认 `curate` 行为不退化。

---

## 12. 待定问题(交 writing-plans)

1. 插件 home 与发现方式(本地 marketplace vs `~/.claude/plugins/`);**目录改名 `meaning`→`defossilize` 的具体切换步骤**(用户管 git)。
2. 命令调用形式与命名空间(`/defossilize:preserve` 等)。
3. `docs/defossil/` 布局是否可配(默认 `docs/defossil/<unit>/`,相对目标项目根)。
4. intent-spec / understanding-record / **map** 的确切文件格式与命名约定。
5. 理解分的打分细则(维度与权重;revive 的「已重建多少」语义校准)。
6. preserve/revive 的「先报告再确认」交互在 command 里的具体实现(AskUserQuestion / 文本确认)。
7. **revive 的「预测→揭示→对账」在 command 里的交互实现**(如何强制预测在前、防橡皮图章)。
8. **provenance/confidence 在 why 注释里的具体标注格式**(既不啰嗦又可被 curate 解析)。
9. **excavate 热点信号的确切计算与排序**(churn/爆炸半径/复杂度如何量化)。
10. doc-sweep 迁移的切换路径(原 `~/.claude/skills/doc-sweep/` 何时下线)。

---

## 13. 参考资料

1. Margaret-Anne Storey — *From Technical Debt to Cognitive and Intent Debt*, ACM Queue 2026-05 / arXiv 2603.22106. https://arxiv.org/abs/2603.22106
2. Margaret-Anne Storey — *Three Debts, Three Threats to Meaning*(2026-06-23). https://margaretstorey.com/blog/2026/06/23/three-threats-to-meaning/
3. Margaret-Anne Storey — *How Generative and Agentic AI Shift Concern from Technical Debt to Cognitive Debt*(2026-02-09). https://margaretstorey.com/blog/2026/02/09/cognitive-debt/
4. Addy Osmani — *Comprehension Debt*. https://addyosmani.com/blog/comprehension-debt/
5. MIT Media Lab — *Your Brain on ChatGPT*(Kosmyna)。**注:该研究有争议(样本小、可复现性受质疑),仅列作背景,不作为本设计的证据依据。** https://www.media.mit.edu/publications/your-brain-on-chatgpt/
6. Anthropic — *How AI Impacts Skill Formation*. https://www.anthropic.com/research/AI-assistance-coding-skills
7. Peter Naur — *Programming as Theory Building*(1985). https://gwern.net/doc/cs/algorithm/1985-naur.pdf
8. Chi 等 — *Eliciting Self-Explanations Improves Understanding*(1994);及自我解释效应相关迁移研究。
9. 既有 skill:`doc-sweep`(`~/.claude/skills/doc-sweep/SKILL.md`)——`curate` 组件的直接前身。

---

## 14. 改名映射(meaning → defossilize)

本次相对 `2026-07-01-meaning-plugin-design.md` 的全量改名与重定框:

| 旧 | 新 | 说明 |
|---|---|---|
| 插件 `meaning` | `defossilize` | 命名核心动作(反石化)而非抽象威胁 |
| 目录 `meaning/` | `defossilize/` | 随插件改名;实际 `git mv` 由用户管 git |
| `capture` | `preserve` | 趁活着钉符号,防石化 |
| `tour` | `thaw` | 用符号救活褪色理解 |
| `sweep` | `curate` | 保养符号↔代码对齐;+provenance 感知、+E 档 |
| `docs/meaning/<feature>/` | `docs/defossil/<unit>/` | `<unit>` 含 feature 与 system/hotspot |
| —(新) | `excavate` | 全化石·发掘:triage + git 考古 + 未知地图 + 选热点 |
| —(新) | `revive` | 全化石·复活:逐热点预测→验证重建 theory |
| —(新) | provenance / confidence / E 档 | 符号溯源:区分权威符号 vs 重建假说 |

理论根(Peirce 三元组、Storey 三债、Naur、自我解释、Anthropic RCT)**全部保留**;石化光谱是加在理论之上的重新定框层,不是替换。`revive` 的「预测→验证」与 provenance/E 档是本次新增的认识论脊梁。

---

*文档版本:0.2 (Draft,含遗留支持与全量改名)*
