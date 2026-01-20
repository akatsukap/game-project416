# Firestoreセキュリティルール

このドキュメントでは、オンラインマルチプレイヤー機能のFirestoreセキュリティルールの設定、テスト、デプロイ方法について説明します。

## 概要

Firestoreセキュリティルールは、データベースへのアクセスを制御し、不正なアクセスからデータを保護します。このプロジェクトでは、以下のルールを実装しています：

- **認証**: すべての操作で認証が必要
- **ゲームルームの作成**: 認証済みユーザーのみが作成可能
- **ゲームルームの読み取り**: 認証済みユーザーのみが読み取り可能
- **ゲームルームの更新**: 参加プレイヤーのみが更新可能
- **ゲームルームの削除**: ホストのみが削除可能
- **ゲーム状態**: 参加プレイヤーのみがアクセス可能

## ファイル構成

- `firestore.rules`: セキュリティルールの定義
- `firestore.rules.test.js`: セキュリティルールのテスト
- `firebase.json`: Firebase設定ファイル
- `firestore.indexes.json`: Firestoreインデックス設定

## セットアップ

### 1. Firebase CLIのインストール

```bash
npm install -g firebase-tools
```

### 2. Firebaseプロジェクトへのログイン

```bash
firebase login
```

### 3. Firebaseプロジェクトの初期化（既に完了している場合はスキップ）

```bash
firebase init firestore
```

プロンプトに従って、以下を選択：
- 既存のプロジェクトを選択
- `firestore.rules`をルールファイルとして使用
- `firestore.indexes.json`をインデックスファイルとして使用

## ローカルテスト

### 1. Firebaseエミュレーターの起動

```bash
firebase emulators:start
```

エミュレーターが起動すると、以下のURLでアクセスできます：
- Firestore Emulator: http://localhost:8080
- Emulator UI: http://localhost:4000

### 2. セキュリティルールのテスト実行

テストを実行する前に、必要なパッケージをインストールします：

```bash
npm install --save-dev @firebase/rules-unit-testing firebase
```

テストを実行：

```bash
npm test firestore.rules.test.js
```

または、Jestを使用している場合：

```bash
npx jest firestore.rules.test.js
```

## セキュリティルールの詳細

### ゲームルームの作成

```javascript
allow create: if isAuthenticated() &&
                 request.resource.data.hostId == request.auth.uid &&
                 request.resource.data.playerIds.size() >= 1 &&
                 request.auth.uid in request.resource.data.playerIds;
```

- 認証済みユーザーのみが作成可能
- ホストIDは自分のUIDである必要がある
- プレイヤーリストに少なくとも1人（自分）が含まれている必要がある

### ゲームルームの更新

```javascript
allow update: if isParticipant(roomCode) &&
                 (request.resource.data.hostId == resource.data.hostId ||
                  (request.resource.data.hostId in resource.data.playerIds)) &&
                 request.resource.data.maxPlayers == resource.data.maxPlayers &&
                 request.resource.data.roomCode == resource.data.roomCode;
```

- 参加プレイヤーのみが更新可能
- ホストIDは変更不可（ホスト移譲の場合を除く）
- maxPlayersは変更不可
- roomCodeは変更不可

### ゲームルームの削除

```javascript
allow delete: if isHost(roomCode);
```

- ホストのみが削除可能

### ゲーム状態サブコレクション

```javascript
allow read: if isAuthenticated() && isParticipant(roomCode);
allow write: if isAuthenticated() && isParticipant(roomCode);
```

- 参加プレイヤーのみが読み書き可能

## 本番環境へのデプロイ

### 1. セキュリティルールのデプロイ

```bash
firebase deploy --only firestore:rules
```

### 2. インデックスのデプロイ

```bash
firebase deploy --only firestore:indexes
```

### 3. すべてをデプロイ

```bash
firebase deploy
```

## セキュリティルールの検証

Firebase Consoleでセキュリティルールを検証できます：

1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. プロジェクトを選択
3. 「Firestore Database」→「ルール」タブを開く
4. ルールが正しく適用されていることを確認

## トラブルシューティング

### エミュレーターが起動しない

- ポート8080が既に使用されている場合、`firebase.json`でポートを変更してください
- Firebaseプロジェクトが正しく初期化されているか確認してください

### テストが失敗する

- エミュレーターが起動しているか確認してください
- `firestore.rules`ファイルが正しい場所にあるか確認してください
- テストファイルのパスが正しいか確認してください

### デプロイが失敗する

- Firebase CLIにログインしているか確認してください
- 正しいプロジェクトが選択されているか確認してください（`firebase use <project-id>`）
- 必要な権限があるか確認してください

## ベストプラクティス

1. **常にローカルでテスト**: 本番環境にデプロイする前に、必ずエミュレーターでテストしてください
2. **最小権限の原則**: 必要最小限のアクセス権限のみを付与してください
3. **定期的なレビュー**: セキュリティルールを定期的にレビューし、更新してください
4. **バージョン管理**: セキュリティルールの変更履歴をGitで管理してください

## 参考資料

- [Firestore セキュリティルール公式ドキュメント](https://firebase.google.com/docs/firestore/security/get-started)
- [セキュリティルールのテスト](https://firebase.google.com/docs/rules/unit-tests)
- [Firebase エミュレーター](https://firebase.google.com/docs/emulator-suite)
