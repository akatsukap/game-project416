# 初学者向け: コピー＆ペーストで進める開発手順書（動作確認 + 相互ブランチレビュー）

この手順書は、**誰でも同じ手順で環境を作り、動作確認しながら開発し、互いのブランチをローカルでレビュー**できるようにしたものです。

---

## 0. この記事でできること

- 開発環境をそろえる
- 毎日の開発ループ（起動 → 変更 → 動作確認 → テスト）を回す
- `feature/...` ブランチで作業する
- 相手のブランチをローカルに取り込み、手元でレビューする
- PR前の最低限チェックを実施する

---

## 1. 前提ツール（最初に1回だけ）

以下が必要です。

- Git
- Docker Desktop
- Google Chrome
- （ホストでFlutterを動かすなら）Flutter SDK

> 補足: このリポジトリは Docker で作業できます。Flutter の実行はホスト側（Windows/macOS）で行うと確認しやすいです。

---

## 2. 初回セットアップ（コピー＆ペースト）

### 2-1. リポジトリ取得

```bash
git clone <このリポジトリのURL>
cd game-project416
```

### 2-2. コンテナ起動

```bash
docker compose up -d --build
```

### 2-3. コンテナへ入る

```bash
docker compose exec app bash
```

### 2-4. Firebase ログイン（初回のみ）

```bash
firebase login --no-localhost
```

### 2-5. FlutterFire 設定（初回のみ）

```bash
cd my_app
flutterfire configure
```

---

## 3. 毎日の開発ループ（動作確認込み）

### 3-1. 最新化

```bash
git checkout main
git pull origin main
```

### 3-2. 作業ブランチ作成

```bash
git checkout -b feature/<作業内容>
```

例:

```bash
git checkout -b feature/fix-login-button
```

### 3-3. 開発環境起動

```bash
docker compose up -d
docker compose exec app bash
```

必要ならエミュレータ起動:

```bash
firebase emulators:start --only firestore,auth,functions
```

### 3-4. アプリ起動（ホスト端末で実行）

```bash
cd my_app
flutter run -d chrome
```

### 3-5. 変更したら即チェック（小さく回す）

#### ルール変更時（リポジトリ直下）

```bash
npm test
```

#### Flutter変更時（`my_app/`）

```bash
flutter analyze
flutter test
```

#### Functions変更時（`functions/`）

```bash
cd functions
npm test
```

---

## 4. コミット前チェックリスト

- [ ] アプリが起動する
- [ ] 変更箇所の画面遷移・主要操作が通る
- [ ] 該当テストが通る
- [ ] 不要なログ・コメント・デバッグコードがない
- [ ] `git status` が意図した変更だけになっている

確認コマンド:

```bash
git status
git diff
```

---

## 5. 相互ブランチレビュー（ローカルで実機確認）

ここが重要です。**PR画面だけでなく、相手ブランチを手元で起動して動作確認**します。

### 5-1. 相手ブランチを取得

```bash
git fetch origin
```

### 5-2. 相手ブランチへ切り替え

```bash
git checkout -b review/<相手名>-<ブランチ名> origin/<相手のブランチ名>
```

例:

```bash
git checkout -b review/alice-feature-login origin/feature/login
```

### 5-3. 依存関係を同期

```bash
docker compose up -d
docker compose exec app bash
```

Flutter側:

```bash
cd my_app
flutter pub get
flutter run -d chrome
```

### 5-4. レビュー観点（初心者向け）

- 仕様どおりに動くか
- 画面が崩れていないか（スマホ幅/PC幅）
- エラー時に固まらないか
- 既存機能が壊れていないか（回帰）
- コードが読みやすいか（命名、重複、コメント）

---

## 6. レビュー後の戻し方

自分の作業に戻る:

```bash
git checkout feature/<自分のブランチ>
```

レビュー用ブランチを消す（不要なら）:

```bash
git branch -D review/<相手名>-<ブランチ名>
```

---

## 7. PR作成まで（定型）

### 7-1. 変更をコミット

```bash
git add .
git commit -m "feat: <変更内容>"
```

### 7-2. リモートへPush

```bash
git push -u origin feature/<作業内容>
```

### 7-3. PR本文テンプレート（そのまま使える）

```md
## 目的
- 

## 変更内容
- 

## 動作確認
- [ ] ローカルで起動確認
- [ ] 変更箇所の手動確認
- [ ] 関連テスト実行

## レビューポイント
- 
```

---

## 8. トラブル時の最短復旧コマンド

### コンテナを作り直す

```bash
docker compose down
docker compose up -d --build
```

### Flutter依存を再取得

```bash
cd my_app
flutter clean
flutter pub get
```

### Gitの作業状況を確認

```bash
git status
git branch
git log --oneline --decorate -n 10
```

---

## 9. 最低限の運用ルール（チーム共通）

- `main` に直接コミットしない
- 1機能1ブランチ
- 1PRは小さめにする（レビューしやすく）
- 必ず「手元で起動して」確認してからPR
- 必ず1回は「相手ブランチを手元で起動」してレビューする

---

必要なら次の段階として、
- 「Windows向け完全版（PowerShellのみ）」
- 「macOS向け完全版（zshのみ）」
- 「レビューコメント例集（OK/NG）」

も追加できます。
