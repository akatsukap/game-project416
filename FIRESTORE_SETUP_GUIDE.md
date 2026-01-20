# Firestoreセキュリティルール設定ガイド

このガイドでは、オンラインマルチプレイヤー機能のFirestoreセキュリティルールを設定する手順を説明します。

## 前提条件

- Firebaseプロジェクトが作成されていること
- Firebase CLIがインストールされていること
- Node.jsとnpmがインストールされていること

## ステップ1: Firebaseプロジェクトの設定

### 1.1 .firebasercファイルの更新

`.firebaserc`ファイルを開き、`your-project-id`を実際のFirebaseプロジェクトIDに置き換えます：

```json
{
  "projects": {
    "default": "your-actual-project-id"
  }
}
```

プロジェクトIDは、[Firebase Console](https://console.firebase.google.com/)のプロジェクト設定で確認できます。

### 1.2 Firebaseへのログイン

```bash
firebase login
```

ブラウザが開き、Googleアカウントでログインします。

## ステップ2: セキュリティルールのデプロイ

### 2.1 セキュリティルールの確認

`firestore.rules`ファイルを開き、セキュリティルールの内容を確認します。

主要なルール：
- ✅ 認証済みユーザーのみがアクセス可能
- ✅ ゲームルームの作成はホストのみ
- ✅ ゲームルームの更新は参加プレイヤーのみ
- ✅ ゲームルームの削除はホストのみ
- ✅ ゲーム状態は参加プレイヤーのみがアクセス可能

### 2.2 セキュリティルールのデプロイ

```bash
firebase deploy --only firestore:rules
```

成功すると、以下のようなメッセージが表示されます：

```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/your-project-id/overview
```

### 2.3 Firebase Consoleでの確認

1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. プロジェクトを選択
3. 「Firestore Database」→「ルール」タブを開く
4. デプロイしたルールが表示されていることを確認

## ステップ3: ローカルテスト（オプション）

セキュリティルールをローカルでテストする場合：

### 3.1 依存パッケージのインストール

```bash
npm install
```

### 3.2 Firebaseエミュレーターの起動

```bash
npm run emulator
```

または

```bash
firebase emulators:start
```

エミュレーターが起動すると、以下のURLでアクセスできます：
- Firestore Emulator: http://localhost:8080
- Emulator UI: http://localhost:4000

### 3.3 セキュリティルールのテスト実行

別のターミナルウィンドウで：

```bash
npm test
```

すべてのテストが成功すれば、セキュリティルールが正しく設定されています。

## ステップ4: セキュリティルールの検証

### 4.1 Firebase Consoleでのシミュレーター

Firebase Consoleには、セキュリティルールをテストできるシミュレーターがあります：

1. Firebase Console → Firestore Database → ルール
2. 「ルールプレイグラウンド」タブを開く
3. テストケースを入力して実行

### 4.2 実際のアプリでのテスト

アプリを実行して、以下の操作が正しく動作することを確認：

- ✅ 認証済みユーザーがルームを作成できる
- ✅ 認証済みユーザーがルームに参加できる
- ✅ 参加プレイヤーがゲーム状態を更新できる
- ✅ ホストがルームを削除できる
- ❌ 未認証ユーザーがアクセスできない
- ❌ 非参加プレイヤーがゲーム状態にアクセスできない

## トラブルシューティング

### エラー: "Permission denied"

**原因**: セキュリティルールが正しくデプロイされていない、または認証が正しく行われていない

**解決方法**:
1. セキュリティルールが正しくデプロイされているか確認
2. ユーザーが正しく認証されているか確認（`FirebaseAuth.instance.currentUser`）
3. Firebase Consoleのログを確認

### エラー: "Project not found"

**原因**: `.firebaserc`のプロジェクトIDが間違っている

**解決方法**:
1. `.firebaserc`ファイルのプロジェクトIDを確認
2. `firebase use <project-id>`でプロジェクトを設定

### エラー: "Insufficient permissions"

**原因**: Firebase CLIに必要な権限がない

**解決方法**:
1. `firebase login`で再ログイン
2. Firebase Consoleでプロジェクトの権限を確認

## セキュリティのベストプラクティス

### 1. 最小権限の原則

必要最小限のアクセス権限のみを付与します。例えば：

```javascript
// ❌ 悪い例: すべてのユーザーが書き込み可能
allow write: if true;

// ✅ 良い例: 参加プレイヤーのみが書き込み可能
allow write: if isParticipant(roomCode);
```

### 2. データ検証

クライアントから送信されるデータを検証します：

```javascript
allow create: if request.resource.data.hostId == request.auth.uid &&
                 request.resource.data.playerIds.size() >= 1;
```

### 3. 定期的なレビュー

セキュリティルールを定期的にレビューし、必要に応じて更新します。

### 4. テストの実施

本番環境にデプロイする前に、必ずローカルでテストします。

## 次のステップ

セキュリティルールの設定が完了したら：

1. ✅ アプリをテストして、セキュリティルールが正しく動作することを確認
2. ✅ 本番環境にデプロイする前に、すべてのテストケースを実行
3. ✅ Firebase Consoleでセキュリティルールを監視
4. ✅ 必要に応じてルールを更新

## 参考資料

- [Firestore セキュリティルール公式ドキュメント](https://firebase.google.com/docs/firestore/security/get-started)
- [セキュリティルールのベストプラクティス](https://firebase.google.com/docs/firestore/security/rules-structure)
- [Firebase エミュレーター](https://firebase.google.com/docs/emulator-suite)

## サポート

問題が発生した場合：

1. [Firebase サポート](https://firebase.google.com/support)
2. [Stack Overflow](https://stackoverflow.com/questions/tagged/firebase)
3. プロジェクトのIssueトラッカー
