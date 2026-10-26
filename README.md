# claude-skills

新規事業アイディアの初期検証と、医療ITを含むシステム連携の設計レビューのための [Claude Skills](https://support.claude.com/en/articles/12512180-use-skills-in-claude) 集です。

どのスキルにも共通する設計方針は1つです。**分からないことを、分かったように書かせない。** 未検証の事実は「未検証」として残し、埋めるべき穴として次のアクションに変換します。

| スキル | 何をするか | 出力 |
|---|---|---|
| [idea-validation-flow-html](skills/idea-validation-flow-html/) | アイディアや困りごとを、需要の実在性と既存解の2軸で初期スクリーニングする | 単一HTMLレポート（判定・根拠・出典を折りたたみで全保存） |
| [proposal-skeleton-builder](skills/proposal-skeleton-builder/) | 断片的な提案内容から、上司・出資者向け提案資料の骨組みを作る | Markdownのスケルトン＋不足情報リスト |
| [responsibility-boundary-design](skills/responsibility-boundary-design/) | 複数の当事者をまたぐシステム連携で、障害が起きる前に決めておくべき責任境界を洗い出す | 責任分界表（CSV）＋全体図（PlantUML/SVG）＋HTMLレポート |

## 使い方の流れ

```
アイディア / 困りごと
   │
   ▼
idea-validation-flow-html ── 需要は実在するか × 既に解かれていないか → 判定
   │（前進 / 条件付き前進）
   ▼
proposal-skeleton-builder ── 検証結果を提案資料の骨組みに配置し、足りない情報を洗い出す
```

`responsibility-boundary-design` は独立して使います。新しいシステム連携の設計・契約・仕様調整に入るときに使います。

---

## idea-validation-flow-html

新規事業・新製品のアイディアを、本格的な市場検証の前に「筋が良いか」ふるい分けるフローです。Stanford Biodesign の need-finding の考え方を土台にしています。

**フロー**: 課題の言語化 → 実在性の検証 → 既存解の検証 → 判定ゲート → ブラッシュアップ

**特徴**

- **アイディアは検証しない。検証するのは課題（need）だけ。** アイディアを入力すると、まずそれが解こうとしている課題へ逆算します
- **「実在性」と「既存解」を独立した2軸で評価**し、中止／ピボット／条件付き前進／前進を判定します
- **「誰もやっていない」をチャンスと即断しない。** 技術・規制が難しいのか、需要が小さいのか、本当に見落とされているのかを切り分けます
- **kill criteria（撤退基準）を検証前に数値で宣言**させ、後付けの都合のよい解釈を防ぎます
- **判定を最も左右する1変数（支配的パラメータ）を特定**し、次に潰すべき最大リスク仮説として引き継ぎます
- **不明事実ログ**：前提として使ってしまっている未確認の事実を1か所に集め、定量／定性／机上のどの調査で埋めるかまで落とします
- **特許調査の必須化**：コア機能・原理・出願人の3軸で調べた記録がなければ「前進」は出せません（上限は条件付き前進）

**出力**: 単一HTMLファイル。結論は本文に、根拠・数値・出典・却下した選択肢は各欄の折りたたみに保存します。外部依存はなく、オフラインやメール添付でも開けます。印刷時は折りたたみが全て展開されます。

**呼び出し例**: 「一人暮らしの高齢者の服薬忘れを防ぐ仕組みのアイディアを検証して」

## proposal-skeleton-builder

新規開発の提案内容（アイディア、検証メモ、事業概要など。断片的でも構いません）から、提案資料の**スケルトン**を生成します。完成した提案書ではなく、埋めるべき箇所を明示した骨組みを出すのが役割です。

**特徴**

- 提案先が**上司（社内承認）か出資者（外部資金）か**を最初に確定し、章の重み付けを変えます
- 入力情報を **[検証済] / [要検証] / [要調査]** に仕分けます。裏付けのない主張を検証済みに格上げしません
- 標準10章構成。事実のない章は文章で埋めず、章ごと [要調査] として残します
- Ask（承認依頼）は事業全体ではなく**次のゲートまで**に限定します
- 提出前の反証レビュー（「なぜ大手がやらないのか」「何人に聞いたのか」など）を付けます

**呼び出し例**: 「この検証結果をもとに、上司向けの提案資料の骨子を作って」

## responsibility-boundary-design

2システム間、システム×医療機関、自社×クラウド事業者などの連携について、**障害が起きる前に**「どちらが何を担うか」を決めておくべき事項を洗い出します。

**入力**: 関係性（当事者、連携方式、データフロー、業務上の意味）

**手順**

1. 関係性を構造化する
2. データが当事者の境界を越える地点を**引き渡し点（H1, H2, …）**として採番する。中間基盤（SFTP、MQ、API GWなど）は必ず2つの引き渡し点に分解する
3. **引き渡し点 × 13の障害モード**（未達、遅延、重複、計画停止、資格情報の失効、監視・通知の不達など）を全件走査する。該当しない組み合わせも理由付きで残す
4. 決めるべき事項を**完了定義／検知／通知／ユーザ説明／復旧・費用**の5観点で整理し、それぞれに2案以上の選択肢と、実装コスト・残るリスクを付ける

**特徴**

- **責任者を断定しない。** 「Bの責任」ではなく「AかBか共同かを定める。案1〜案2」と書くため、相手方との協議のたたき台にそのまま使えます
- **人手の随時連絡だけに頼る案を単独で出さない。** 「メンテ予定をメールで連絡する」は必ず抜けるので、機械的な検知手段とセットにします
- **エンドユーザが最初に異常に気づく構成は、検知設計が存在しないものとして指摘**します

**出力**: `responsibility-boundary.html`（図と表を1ファイルに統合）、`boundary-definitions.csv`（決めるべき責任境界）、`failure-cases.csv`（障害事例の全走査結果）、`responsibility-boundary.puml`（全体図）。CSVはExcelで開ける UTF-8 BOM付きです。

**必要環境**: 全体図のSVG変換に Java と PlantUML を使います（`scripts/render_puml.sh` が初回に plantuml.jar を取得します）。使えない環境では、HTMLに .puml のソースを載せる形に切り替わります。

**呼び出し例**: 「自社の在庫管理システムから、取引先の受発注システムへ日次でSFTP連携する。責任分界を整理したい」

---

## インストール

### Claude（claude.ai／デスクトップアプリ）

1. [Releases](../../releases) から使いたいスキルのZIPをダウンロードします（または、`skills/` 配下のフォルダをそのままZIPにします）
2. **Customize > Skills** を開き、**+** から **Upload a skill** を選んでZIPをアップロードします

詳しくは公式ヘルプ [Use skills in Claude](https://support.claude.com/en/articles/12512180-use-skills-in-claude) を参照してください。

### Claude Code

使いたいスキルのフォルダを `~/.claude/skills/` にコピーします。

```bash
git clone https://github.com/morawysouhiin/claude-skills.git
cp -r claude-skills/skills/idea-validation-flow-html ~/.claude/skills/
```

プロジェクト単位で使う場合は、リポジトリの `.claude/skills/` に置きます。詳しくは [Claude Code のドキュメント](https://code.claude.com/docs/en/skills) を参照してください。

### ZIPの作り直し

```bash
bash scripts/package.sh   # dist/ に各スキルのZIPを出力
```

## 注意

- これらのスキルは**考えるための構造**を与えるものです。市場・特許・契約の中身は個別の調査でしか埋まりません
- 一次調査（当事者インタビューなど）はスキルの利用者自身が行う必要があります
- 出力は意思決定の補助です。法的・契約上の判断や医療上の判断を代替するものではありません

## ライセンス

[MIT License](LICENSE)

## 作者

Yasuo F（[@morawysouhiin](https://github.com/morawysouhiin)）

---

## English summary

A set of [Claude Skills](https://support.claude.com/en/articles/12512180-use-skills-in-claude) (written in Japanese) for early-stage idea validation and for designing responsibility boundaries in multi-party system integrations, including healthcare IT. The shared principle: **never let unknowns be written as if they were known.**

- **idea-validation-flow-html**: Screens an idea on two independent axes (does the need really exist / is it already solved), declares kill criteria up front, identifies the dominant sensitivity parameter, and outputs a self-contained HTML report that preserves all evidence and sources in collapsible sections.
- **proposal-skeleton-builder**: Turns fragmentary proposal notes into a 10-chapter skeleton for a manager or investor, separating verified facts from claims and gaps, with a prioritized list of missing information.
- **responsibility-boundary-design**: Takes a system relationship as input, scans every handoff point against 13 failure modes, and derives the responsibility boundaries to agree on *before* an incident. It presents options with trade-offs instead of assigning blame, and outputs CSV tables, a PlantUML diagram and an HTML report.

Install on Claude by uploading the skill folder as a ZIP under **Customize > Skills**, or on Claude Code by copying the folder into `~/.claude/skills/`. Licensed under MIT.
