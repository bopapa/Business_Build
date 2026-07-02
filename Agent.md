# Agent.md

## プロジェクト概要

有人チャットシステムの会話テキストCSVを加工し、Excelマクロツール相当の処理をWindowsネイティブアプリへ移行するプロジェクトです。

将来的には、会話ログの作成だけでなく、応答時間や件数などの数値データを出す機能も追加する想定です。

## 仕様書

- 詳細仕様は `SPEC.md` を参照してください。
- 実装時は、`SPEC.md` のスプリント単位で進めます。
- 要件を変更した場合は、コード修正だけでなく `SPEC.md` とこの `Agent.md` も更新します。
- 実装は Python + PySide6 で開始済みです。中核ロジックは `src/chat_tool/core`、画面は `src/chat_tool/ui`、テストは `tests` にあります。
- 品質確認は `scripts/check_quality.cmd` または `scripts/品質チェック.cmd` を使います。社内証明書の都合で `pip-audit` が失敗する場合は、接続可能な環境で再実行します。

## 解析対象

- `Tool/【2606】チャット自動サマリ_AI評価ツール.xlsm`
- ブックはパスワード付きで暗号化されています。
- 元ファイルは変更せず、解析用コピーを作って中身を確認しました。

## 確認できたシート

- `操作`
- `集約`
- `TransformedData`
- `csv`
- `csv抽出手順`

## 重要そうな処理

- `ImportCSV_UTF8BOM`
  - ユーザーが選んだCSVを読み込み、必要な列だけを `csv` シートへ取り込みます。
- `ImportCSV_UTF8BOM_2`
  - 共有フォルダーにある前日分の `Messages_MMDD.csv` を自動で読み込みます。
- `New_CombineGColumnContent_chat`
  - `csv` シートのデータをチャットID単位でまとめ、`集約` シートへ追加します。
- `DeleteDuplicateRowsInColumnB`
  - `集約` シートのチャットID重複行を削除します。
- `全クリア`
  - `集約` と `csv` の作業データを削除します。
- `TransferAndArrangeData`
  - `集約` の一部列を `TransformedData` 用の形式に並べ替えます。

## Windowsアプリ化するときの注意

- Excelのセル操作をそのまま再現するのではなく、CSVを読み込んで、内部データとして処理し、最後にExcelまたはCSVへ出力する形にすると保守しやすいです。
- まずは「CSV取込」「チャット単位の集約」「重複削除」「出力」の4機能を小さく作るのが安全です。
- 数値データ化は、集約後のデータから応答時間・件数・担当者別集計などを追加する発展機能として分けるのがよいです。

## 旧AI・ブラウザ自動操作マクロの扱い

- `Copilot` / `Copilot_chatsupport` / `AIchat` は、AIサービスのAPIを直接呼ぶ処理ではなく、EdgeブラウザをSeleniumで自動操作してAIのWeb画面に会話文を貼り付ける処理です。
- 内容としては、会話要約、改善要望の抽出、原因分類、応答品質の採点などをAIに依頼する実験的な処理でした。
- `Teams_テスト` はTeams画面を開いて入力を試すブラウザ操作テストに近いです。
- `google` / `CompanyTest` はGoogleや社内系Web画面の操作確認・ログイン確認に近く、チャットCSV加工の中核処理ではありません。
- Windowsアプリ初期版には移植せず、将来の「AI評価」機能として、画面自動操作ではなく安全な連携方式で作り直すのがよいです。

## 2026-06-18 から 2026-07-01 までの主な引き継ぎメモ

- 設定画面、数値ダッシュボード、ルール評価、CSVプレビュー、Excel出力、原因分類候補、AI-Chatログ分析、キーワード集計、xlsx取込、配布版整備を段階的に追加しました。
- `ChatLogAnalyzer.exe` は有人チャットだけでなくAI-Chatログも扱います。正式な配布元は `dist/chat-log-analyzer-release`、起動用cmdは `start_chat_log_analyzer.cmd` です。
- 設定保存先は `%APPDATA%\chat-log-analyzer\settings.json` です。QA候補状態は `%APPDATA%\chat-log-analyzer\qa_statuses.json` に保存します。
- AI-Chatログは `created_at`、`user_id`、`agency_code`、`person_id`、`user_email`、`chat_id`、`request`、`response`、`reaction`、`feedback`、`feedback_at`、`is_clarification_requested` の12列構成です。
- AI-Chatでは `is_clarification_requested=true` の場合だけ `未解決・有人エスカレ` および `有人エスカレ=あり` とします。
- 有人チャット、AI-Chat、受付PIPELINEの表は原則として全件表示します。ランキング表の上位表示は順位確認のための表示です。
- Excel出力では、有人チャットは `有人チャット集約_YYYYMMDD_HHMMSS.xlsx`、AI-Chatは `AI-Chat集約_YYYYMMDD_HHMMSS.xlsx`、受付PIPELINEは `受付PIPELINE分析_YYYYMMDD_HHMMSS.xlsx` を使います。同名がある場合は連番を付けます。
- 受付PIPELINEでは、GYOMA-AI、ChatSupport、電話CRMのCSVを読み込み、`ReceptionRecord` と `DataQualitySummary` を入口にして集計します。
- 電話CRMの `受付窓口区分名称=チャットサポート` は、ChatSupport経由の電話対応フラグではありません。将来は電話CRM側の `電話引継番号` を正規エスカレの基本フラグにします。
- 電話CRM実データに `電話引継番号` が無い場合は、電話連携を確定扱いせず、候補または情報不足として表示します。
- PIPELINE集計では、GYOMA-AI受付、AI完結候補、AIからChatSupportへのエスカレ候補、ChatSupport直受付候補、ChatSupport受付、ChatSupport完結候補、ChatSupport未解決、電話引継番号あり、電話窓口受付、電話CRM正規エスカレ突合などを出します。
- `SAPOSEN Reception Analyzer` の画面は、左サイドバー型UIを基本にします。`QTabWidget` は内部ページ管理と既存テストのため残し、利用者には左サイドバーで切り替える設計を維持してください。
- 左メニューは `ファイル入力/レポート出力`、`全体ビュー`、`エスカレ分析`、`店舗・担当者`、`QA候補管理`、`改善ログ`、`キーワード検索`、`設定` などを中心に整理しています。
- `改善ログ` 内には `会話ログ`、`類似問い合わせ`、`品質・企画FB`、`キーワード集計` を統合しました。ただし利用者が直接使う必要があるため、左メニューに `キーワード検索` も復元しています。
- 上部バーの `期間`、`カテゴリ` プルダウンは表示フィルターです。Excel出力は画面の一時フィルターではなく、読み込み済み全件を対象にします。
- カテゴリ候補は読み込んだ全件から自動生成し、`すべて` を先頭に、件数が多い順で表示します。
- `キーワード検索` は単体ワード最大5件、AND/OR組み合わせ検索最大5セットに対応します。ANDはORより優先して判定します。
- 受付PIPELINE Excelには、`全体サマリ`、`PIPELINE集計`、`PIPELINE流量`、`カテゴリ別PIPELINE`、`PipelineCase`、`InquiryThread`、`EscalationLink`、`TopicCluster`、`QaCandidate`、`QA候補管理`、`品質・企画FB`、`品質・企画FB明細`、`類似問い合わせ`、`受付ログ`、`処理ログ`、`設定スナップショット` などを出力します。
- 設定画面の `列マッピング` タブでは、CSV列名が変わった場合にGYOMA-AI、ChatSupport、電話CRMの各項目へ追加列名を最大3件まで登録できます。通常は空欄のままで問題ありません。
- 配布版には `ChatLogAnalyzer.exe`、`start_chat_log_analyzer.cmd`、`_internal`、PySide6/Qt、Pythonランタイム、`logo/kddi_2026_logo_transparent.png` など必要部品を同梱します。
- 配布前検査は `scripts/dist_startup_check.py` を使います。旧名 `human-chat-talk-merge.exe` や `start_human_chat_tool.cmd` が混ざっている場合はエラーにします。
- 品質確認では `ruff` と `pytest` は成功している履歴があります。`pip-audit` は社内証明書やネットワーク都合で失敗する場合があり、その場合は接続可能な環境で再実行します。

## User-provided custom instructions

ユーザーは非エンジニアであり、プログラミング未経験者です。コードの解説やアドバイス、提案は専門用語を避けるか、わかりやすく解説して下さい。コード内のメモも日本語で初心者であることを考慮して記載してください。
