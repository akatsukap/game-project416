# 🤝 開発に参加する

このドキュメントでは、プロジェクトに貢献する方法を説明します。

## 📋 開発フロー

### 1. Issue から始める
- 新しい機能やバグ修正は、まず Issue を作成して議論する
- Issue には適切なラベルを付ける（例: `enhancement`, `bug`, `documentation`）

### 2. ブランチを作成する
```bash
# 最新の main ブランチを取得
git checkout main
git pull origin main

# 新しいブランチを作成（命名規則に従う）
git checkout -b feature/your-feature-name
```

#### ブランチ命名規則
- `feature/機能名` - 新機能追加
- `fix/バグ名` - バグ修正
- `docs/ドキュメント名` - ドキュメント更新
- `refactor/対象` - リファクタリング

### 3. コードを書く
- 小さな単位でコミットする
- コミットメッセージは明確に書く（日本語OK）

```bash
# 変更をステージング
git add .

# コミット
git commit -m "feat: ○○機能を追加"
```

#### コミットメッセージの例
- `feat: ログイン機能を追加`
- `fix: カード配布のバグを修正`
- `docs: READMEにセットアップ手順を追加`
- `refactor: ゲームロジックを整理`

### 4. プッシュして Pull Request を作成
```bash
# リモートにプッシュ
git push origin feature/your-feature-name
```

GitHub で Pull Request を作成し、以下を記載:
- 何を変更したか
- なぜ変更したか
- スクリーンショット（UI変更の場合）

### 5. レビューを受ける
- メンバーからのレビューを待つ
- フィードバックがあれば修正する
- 承認されたら `main` にマージ

## 🛠 開発環境のセットアップ

### 必要なツール
- Git
- テキストエディタ（VS Code 推奨）
- ウェブブラウザ（Chrome/Firefox 推奨）

### ローカルで実行
```bash
# リポジトリをクローン（初回のみ）
git clone https://github.com/akatsukap/game-project416.git
cd game-project416

# ブラウザで index.html を開く
# または、簡易サーバーを起動
python -m http.server 8000
# http://localhost:8000 にアクセス
```

## 📏 コーディング規約

### JavaScript
- インデント: 2スペース
- セミコロンを使用する
- 変数名: キャメルケース（例: `playerName`）
- 関数名: キャメルケース（例: `dealCards()`）
- 定数名: アッパースネークケース（例: `MAX_PLAYERS`）

### HTML/CSS
- インデント: 2スペース
- クラス名: ケバブケース（例: `game-container`）
- ID名: ケバブケース（例: `main-screen`）

### コメント
- 複雑なロジックには日本語でコメントを追加
- 関数には JSDoc 形式のコメントを推奨

```javascript
/**
 * カードをシャッフルする
 * @param {Array} cards - カードの配列
 * @returns {Array} シャッフルされたカード
 */
function shuffleCards(cards) {
  // ...
}
```

## 🧪 テスト

現在、テストフレームワークは導入していませんが、以下を確認してください:
- [ ] ブラウザでゲームが正常に動作する
- [ ] コンソールにエラーが出ていない
- [ ] モバイルでも表示が崩れていない

## 📚 ドキュメント

コードと同じくらい、ドキュメントも重要です:
- 新機能を追加したら README を更新
- 複雑な仕様は `docs/` フォルダにドキュメントを追加
- API や関数の使い方を明確に記載

## 🐛 バグを見つけたら

1. まず Issue を検索して、同じバグが報告されていないか確認
2. なければ新しい Issue を作成
3. 以下を含める:
   - バグの内容
   - 再現手順
   - 期待される動作
   - 実際の動作
   - スクリーンショット（あれば）

## 💡 アイデアがあれば

- 新機能のアイデアは Issue で提案
- 実装前にメンバーと議論して合意を取る
- `docs/GAME_DESIGN.md` も確認

## ❓ 困ったときは

- Issue でメンバーに質問
- リポジトリの Wiki を確認（作成予定）
- メンバーに直接連絡

---

## 🙏 ありがとうございます

あなたの貢献がこのプロジェクトをより良くします！
