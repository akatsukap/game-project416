# オンラインマルチプレイヤー統合テストガイド

このドキュメントでは、オンラインマルチプレイヤー機能の統合テストの実行方法について説明します。

## 概要

統合テストは、Firebaseエミュレーターを使用して、ルーム作成から参加、ゲーム進行、終了までの完全なフローをテストします。実際のFirebaseサービスではなく、ローカルのエミュレーターを使用するため、安全にテストを実行できます。

## 前提条件

### 1. Firebase CLIのインストール

Firebase CLIがインストールされていない場合は、以下のコマンドでインストールしてください：

```bash
npm install -g firebase-tools
```

インストールを確認：

```bash
firebase --version
```

### 2. Firebaseプロジェクトの初期化

プロジェクトルートで以下のコマンドを実行：

```bash
firebase init
```

以下を選択：
- Firestore
- Emulators

### 3. 依存関係のインストール

```bash
cd my_app
flutter pub get
```

## テストの実行手順

### ステップ1: Firebaseエミュレーターの起動

**重要**: テストを実行する前に、必ずFirebaseエミュレーターを起動してください。

新しいターミナルウィンドウを開き、プロジェクトルートで以下のコマンドを実行：

```bash
firebase emulators:start --only auth,firestore
```

エミュレーターが起動すると、以下のような出力が表示されます：

```
┌─────────────────────────────────────────────────────────────┐
│ ✔  All emulators ready! It is now safe to connect your app. │
│ i  View Emulator UI at http://localhost:4000                │
└─────────────────────────────────────────────────────────────┘

┌────────────────┬────────────────┬─────────────────────────────────┐
│ Emulator       │ Host:Port      │ View in Emulator UI             │
├────────────────┼────────────────┼─────────────────────────────────┤
│ Authentication │ localhost:9099 │ http://localhost:4000/auth      │
├────────────────┼────────────────┼─────────────────────────────────┤
│ Firestore      │ localhost:8080 │ http://localhost:4000/firestore │
└────────────────┴────────────────┴─────────────────────────────────┘
```

エミュレーターUIは http://localhost:4000 でアクセスできます。

### ステップ2: 統合テストの実行

エミュレーターが起動している状態で、別のターミナルウィンドウで以下のコマンドを実行：

#### すべての統合テストを実行

```bash
cd my_app
flutter test integration_test
```

#### 特定のテストファイルを実行

```bash
# 完全なゲームフローのテスト
flutter test integration_test/multiplayer_flow_test.dart

# ゲームシナリオのテスト
flutter test integration_test/game_flow_scenarios_test.dart
```

#### デバイス/エミュレーターでテストを実行（オプション）

実際のデバイスやエミュレーターでテストを実行する場合：

```bash
# 利用可能なデバイスを確認
flutter devices

# 特定のデバイスでテストを実行
flutter test integration_test --device-id=<device-id>
```

### ステップ3: テスト結果の確認

テストが成功すると、以下のような出力が表示されます：

```
00:02 +1: オンラインマルチプレイヤー統合テスト ルーム作成と参加のフロー
00:03 +2: オンラインマルチプレイヤー統合テスト リアルタイム同期の検証
00:04 +3: オンラインマルチプレイヤー統合テスト プレイヤー退出とホスト移譲
...
00:10 +10: All tests passed!
```

## テストの内容

### multiplayer_flow_test.dart

このファイルには、以下のテストケースが含まれています：

1. **完全なゲームフロー**: ルーム作成 → 参加 → ゲーム進行 → 終了
2. **ルーム作成と参加のフロー**: ホストとゲストの基本的な操作
3. **リアルタイム同期の検証**: Firestoreのリアルタイム更新
4. **プレイヤー退出とホスト移譲**: 退出処理とホスト交代
5. **満員のルームへの参加拒否**: 最大プレイヤー数の制限
6. **ゲーム状態の初期化と更新**: ゲーム状態の管理
7. **エラーハンドリング**: 存在しないルームへの参加試行

### game_flow_scenarios_test.dart

このファイルには、以下のシナリオテストが含まれています：

1. **2人プレイヤーでの完全なゲーム**: 最小構成でのゲーム
2. **3人プレイヤーでのゲーム開始**: 中間構成でのゲーム
3. **4人プレイヤー（最大）でのゲーム**: 最大構成でのゲーム
4. **プレイヤーの途中退出**: 退出処理の検証
5. **ホストの退出とホスト移譲**: ホスト交代の検証
6. **ターン進行のシミュレーション**: ターン管理の検証
7. **ゲーム終了の処理**: 終了処理の検証
8. **複数のルームの同時管理**: 複数ルームの独立性
9. **リアルタイム同期の遅延テスト**: 同期の確認
10. **エラーリカバリー**: エラー処理の検証

## トラブルシューティング

### エミュレーターに接続できない

**症状**: テストが失敗し、「Connection refused」などのエラーが表示される

**解決方法**:
1. Firebaseエミュレーターが起動していることを確認
2. ポート8080と9099が他のプロセスで使用されていないか確認
3. `firebase.json`の設定を確認

```bash
# ポートの使用状況を確認（Windows）
netstat -ano | findstr :8080
netstat -ano | findstr :9099
```

### テストがタイムアウトする

**症状**: テストが長時間実行され、タイムアウトする

**解決方法**:
1. エミュレーターのログを確認
2. ネットワーク接続を確認
3. テストのタイムアウト設定を調整

### データが残っている

**症状**: 前回のテストデータが残っている

**解決方法**:

各テストの前にデータは自動的にクリアされますが、手動でクリアする場合：

1. Emulator UIを開く: http://localhost:4000
2. Firestoreタブを開く
3. データを削除

または、エミュレーターを再起動：

```bash
# エミュレーターを停止（Ctrl+C）
# 再起動
firebase emulators:start --only auth,firestore
```

### 依存関係のエラー

**症状**: パッケージが見つからないエラー

**解決方法**:

```bash
cd my_app
flutter pub get
flutter clean
flutter pub get
```

## ベストプラクティス

### 1. エミュレーターの起動確認

テストを実行する前に、必ずエミュレーターが起動していることを確認してください。

### 2. テストの独立性

各テストは独立して実行できるように設計されています。特定のテストのみを実行する場合は、ファイル名を指定してください。

### 3. デバッグ

テストが失敗した場合は、Emulator UI（http://localhost:4000）でFirestoreのデータを確認できます。

### 4. CI/CDでの実行

CI/CD環境でテストを実行する場合は、以下のようなスクリプトを使用できます：

```bash
#!/bin/bash

# エミュレーターをバックグラウンドで起動
firebase emulators:start --only auth,firestore &
EMULATOR_PID=$!

# エミュレーターの起動を待機
sleep 10

# テストを実行
cd my_app
flutter test integration_test

# テスト結果を保存
TEST_RESULT=$?

# エミュレーターを停止
kill $EMULATOR_PID

# テスト結果を返す
exit $TEST_RESULT
```

## 注意事項

1. **エミュレーターの使用**: 統合テストは実際のFirebaseサービスではなく、エミュレーターを使用します
2. **データの永続化**: エミュレーターのデータは永続化されません（エミュレーター停止時に削除されます）
3. **ネットワーク**: エミュレーターはローカルで実行されるため、インターネット接続は不要です
4. **パフォーマンス**: エミュレーターは実際のFirebaseサービスよりも高速に動作します

## 参考リンク

- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Cloud Firestore Emulator](https://firebase.google.com/docs/emulator-suite/connect_firestore)
- [Firebase Auth Emulator](https://firebase.google.com/docs/emulator-suite/connect_auth)

## サポート

問題が発生した場合は、以下を確認してください：

1. Firebaseエミュレーターのログ
2. Flutterのテスト出力
3. Emulator UIのデータ状態

それでも解決しない場合は、プロジェクトのIssueトラッカーに報告してください。
