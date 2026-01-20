# Firebase クイックセットアップガイド

## ステップ1: プロジェクトの作成

1. **プロジェクト名を入力**
   - 例: `babanuki-game` または `card-game-collection`
   - 「続行」をクリック

2. **Google Analyticsの設定（オプション）**
   - オフのままでOK（後で有効化可能）
   - 「プロジェクトを作成」をクリック
   - 作成完了まで待機（約30秒）

## ステップ2: Webアプリの追加

1. プロジェクトのホーム画面で **「</>」（Webアイコン）** をクリック

2. **アプリのニックネームを入力**
   - 例: `Babanuki Web App`
   - 「Firebase Hostingを設定」はチェック不要
   - 「アプリを登録」をクリック

3. **Firebase SDKの追加**
   - 表示される設定コードをコピー（後で使用）
   - 「コンソールに進む」をクリック

## ステップ3: Authenticationの設定

1. 左メニューから **「Authentication」** をクリック

2. **「始める」** をクリック

3. **Sign-in methodタブ**を選択

4. **「匿名」** をクリック
   - 「有効にする」をオンにする
   - 「保存」をクリック

## ステップ4: Firestoreの設定

1. 左メニューから **「Firestore Database」** をクリック

2. **「データベースを作成」** をクリック

3. **セキュリティルールの選択**
   - 「本番環境モード」を選択
   - 「次へ」をクリック

4. **ロケーションの選択**
   - `asia-northeast1 (Tokyo)` を選択（日本の場合）
   - 「有効にする」をクリック
   - 作成完了まで待機（約1分）

5. **セキュリティルールの更新**
   - 「ルール」タブをクリック
   - 以下のルールを貼り付け：

\`\`\`javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /game_rooms/{roomCode} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow delete: if request.auth != null && request.auth.uid == resource.data.hostId;
      allow update: if request.auth != null && request.auth.uid in resource.data.playerIds;
      
      match /game_state/{document} {
        allow read: if request.auth != null;
        allow write: if request.auth != null && request.auth.uid in get(/databases/$(database)/documents/game_rooms/$(roomCode)).data.playerIds;
      }
    }
  }
}
\`\`\`

   - 「公開」をクリック

## ステップ5: Flutter設定の更新

### 方法A: FlutterFire CLI（推奨）

ターミナルで以下を実行：

\`\`\`bash
# Firebase CLIをインストール（初回のみ）
npm install -g firebase-tools

# FlutterFire CLIをインストール（初回のみ）
dart pub global activate flutterfire_cli

# Firebaseにログイン
firebase login

# プロジェクトディレクトリに移動
cd my_app

# 設定を自動生成
flutterfire configure
\`\`\`

プロジェクトを選択すると、`lib/firebase_options.dart`が自動的に更新されます。

### 方法B: 手動設定

1. Firebase Console → プロジェクト設定（歯車アイコン）
2. 「全般」タブ → 「マイアプリ」セクション
3. Webアプリを選択 → 「SDK の設定と構成」
4. 「構成」を選択
5. 表示される設定をコピー

`my_app/lib/firebase_options.dart`を開いて、以下の部分を更新：

\`\`\`dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'あなたのAPIキー',
  appId: 'あなたのアプリID',
  messagingSenderId: 'あなたのメッセージングID',
  projectId: 'あなたのプロジェクトID',
  authDomain: 'あなたのプロジェクトID.firebaseapp.com',
  storageBucket: 'あなたのプロジェクトID.appspot.com',
);
\`\`\`

## ステップ6: アプリの実行

\`\`\`bash
cd my_app
flutter run -d chrome
\`\`\`

または

\`\`\`bash
flutter run -d web-server --web-port 8085
\`\`\`

## トラブルシューティング

### エラー: "unauthorized-domain"

1. Firebase Console → Authentication → Settings
2. 「Authorized domains」タブ
3. 「ドメインを追加」をクリック
4. `localhost` を追加

### エラー: "api-key-not-valid"

- Firebase Consoleで正しいAPIキーをコピーしたか確認
- `firebase_options.dart`を再度確認

### エラー: "Permission denied"

- Firestoreセキュリティルールが正しく設定されているか確認
- 匿名認証が有効になっているか確認

## 完了！

これでアプリが動作するはずです。ニックネームを入力して「開始」ボタンをクリックしてください。
