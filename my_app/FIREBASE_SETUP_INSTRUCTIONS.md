# Firebase設定手順

## 1. Firebaseプロジェクトの作成

1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. 「プロジェクトを追加」をクリック
3. プロジェクト名を入力（例：babanuki-game）
4. Google Analyticsの設定（オプション）
5. プロジェクトを作成

## 2. Webアプリの登録

1. Firebase Consoleでプロジェクトを開く
2. 左側のメニューから「プロジェクトの設定」（歯車アイコン）をクリック
3. 「全般」タブで下にスクロール
4. 「アプリを追加」→「Web」を選択
5. アプリのニックネームを入力（例：Babanuki Web）
6. 「Firebase Hosting」のチェックは不要
7. 「アプリを登録」をクリック
8. 表示される設定情報をコピー

## 3. Firebase Authenticationの有効化

1. Firebase Consoleで「Authentication」をクリック
2. 「始める」をクリック
3. 「Sign-in method」タブを選択
4. 「匿名」を有効にする
   - 「匿名」をクリック
   - 「有効にする」をオンにする
   - 「保存」をクリック

## 4. Cloud Firestoreの有効化

1. Firebase Consoleで「Firestore Database」をクリック
2. 「データベースを作成」をクリック
3. 「本番環境モード」を選択（後でルールを設定）
4. ロケーションを選択（例：asia-northeast1（東京））
5. 「有効にする」をクリック

## 5. Firestoreセキュリティルールの設定

1. Firestore Databaseの「ルール」タブを選択
2. 以下のルールを貼り付け：

\`\`\`javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ゲームルームへのアクセス制御
    match /game_rooms/{roomCode} {
      // 認証済みユーザーは読み取り可能
      allow read: if request.auth != null;
      
      // 認証済みユーザーは作成可能
      allow create: if request.auth != null;
      
      // ホストのみが削除可能
      allow delete: if request.auth != null && 
                       request.auth.uid == resource.data.hostId;
      
      // 参加プレイヤーのみが更新可能
      allow update: if request.auth != null && 
                       request.auth.uid in resource.data.playerIds;
      
      // ゲーム状態へのアクセス
      match /game_state/{document} {
        allow read: if request.auth != null;
        allow write: if request.auth != null && 
                        request.auth.uid in get(/databases/$(database)/documents/game_rooms/$(roomCode)).data.playerIds;
      }
    }
  }
}
\`\`\`

3. 「公開」をクリック

## 6. Flutter設定ファイルの更新

### 方法A: FlutterFire CLIを使用（推奨）

\`\`\`bash
# Firebase CLIをインストール
npm install -g firebase-tools

# FlutterFire CLIをインストール
dart pub global activate flutterfire_cli

# Firebaseにログイン
firebase login

# プロジェクトディレクトリで実行
cd my_app
flutterfire configure
\`\`\`

### 方法B: 手動で設定

1. Firebase Consoleの「プロジェクトの設定」→「全般」タブ
2. 「マイアプリ」セクションでWebアプリを選択
3. 「SDK の設定と構成」で「構成」を選択
4. 表示される設定情報を`lib/firebase_options.dart`に貼り付け

例：
\`\`\`dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  appId: '1:123456789:web:abcdef123456',
  messagingSenderId: '123456789',
  projectId: 'your-project-id',
  authDomain: 'your-project-id.firebaseapp.com',
  storageBucket: 'your-project-id.appspot.com',
);
\`\`\`

## 7. アプリの実行

\`\`\`bash
cd my_app
flutter run -d chrome
\`\`\`

## トラブルシューティング

### エラー: "Firebase: Error (auth/api-key-not-valid)"

- `firebase_options.dart`のAPIキーが正しいか確認
- Firebase Consoleで新しいAPIキーを生成

### エラー: "Firebase: Error (auth/unauthorized-domain)"

1. Firebase Console → Authentication → Settings → Authorized domains
2. `localhost`を追加

### エラー: "Permission denied"

- Firestoreセキュリティルールが正しく設定されているか確認
- 匿名認証が有効になっているか確認

## 開発用エミュレーターの使用（オプション）

ローカル開発用にFirebaseエミュレーターを使用できます：

\`\`\`bash
# Firebase CLIをインストール
npm install -g firebase-tools

# プロジェクトディレクトリで初期化
firebase init emulators

# エミュレーターを起動
firebase emulators:start
\`\`\`

アプリでエミュレーターを使用するには、`main.dart`に以下を追加：

\`\`\`dart
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
\`\`\`
