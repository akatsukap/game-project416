# Firebase設定ガイド

このドキュメントでは、オンラインマルチプレイヤー機能を使用するためのFirebase設定手順を説明します。

## 前提条件

- Googleアカウント
- Node.js（Firebase CLIのインストールに必要）
- Flutter SDK

## 手順

### 1. Firebaseプロジェクトの作成

1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. 「プロジェクトを追加」をクリック
3. プロジェクト名を入力（例：babanuki-game）
4. Google Analyticsの設定（オプション）
5. プロジェクトを作成

### 2. Firebase CLIのインストール

```bash
npm install -g firebase-tools
```

### 3. FlutterFire CLIのインストール

```bash
dart pub global activate flutterfire_cli
```

### 4. Firebaseにログイン

```bash
firebase login
```

### 5. FlutterアプリをFirebaseに登録

プロジェクトのルートディレクトリ（my_app/）で以下のコマンドを実行：

```bash
flutterfire configure
```

このコマンドは以下を自動的に行います：
- Firebaseプロジェクトの選択
- Android/iOS/Web/macOSアプリの登録
- `lib/firebase_options.dart`ファイルの自動生成（既存のダミーファイルを上書き）

### 6. Firestoreの有効化

1. Firebase Consoleでプロジェクトを開く
2. 左メニューから「Firestore Database」を選択
3. 「データベースを作成」をクリック
4. 「本番環境モードで開始」を選択（後でセキュリティルールを設定）
5. ロケーションを選択（例：asia-northeast1（東京））
6. 「有効にする」をクリック

### 7. Firebase Authenticationの有効化

1. Firebase Consoleでプロジェクトを開く
2. 左メニューから「Authentication」を選択
3. 「始める」をクリック
4. 「Sign-in method」タブを選択
5. 「匿名」を有効化

### 8. Firestoreセキュリティルールの設定

Firebase Consoleで「Firestore Database」→「ルール」タブを開き、以下のルールを設定：

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ゲームルームへのアクセス制御
    match /game_rooms/{roomCode} {
      // 認証済みユーザーのみ読み取り可能
      allow read: if request.auth != null;
      
      // 認証済みユーザーのみ作成可能
      allow create: if request.auth != null;
      
      // ホストのみ削除可能
      allow delete: if request.auth.uid == resource.data.hostId;
      
      // 参加プレイヤーのみ更新可能
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
```

「公開」をクリックしてルールを適用します。

### 9. 依存関係のインストール

```bash
flutter pub get
```

### 10. アプリの実行

```bash
flutter run
```

## トラブルシューティング

### エラー: "No Firebase App '[DEFAULT]' has been created"

- `Firebase.initializeApp()`が正しく呼ばれているか確認
- `firebase_options.dart`が正しく生成されているか確認

### エラー: "FirebaseOptions cannot be null"

- `flutterfire configure`を実行して設定ファイルを生成
- または、Firebase Consoleから手動で設定情報を取得して`firebase_options.dart`を更新

### Android/iOSでビルドエラー

Android:
- `android/app/build.gradle`のminSdkVersionを21以上に設定
- `android/build.gradle`のGoogle Servicesプラグインを確認

iOS:
- `ios/Podfile`のプラットフォームバージョンを12.0以上に設定
- `pod install`を実行

## 開発用のローカルエミュレーター（オプション）

本番環境のFirebaseを使用せずにローカルでテストする場合：

```bash
# Firebase Emulator Suiteのインストール
firebase init emulators

# エミュレーターの起動
firebase emulators:start
```

アプリ側でエミュレーターに接続するには、`main.dart`に以下を追加：

```dart
// 開発環境でのみエミュレーターを使用
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

## 参考リンク

- [FlutterFire公式ドキュメント](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firestore セキュリティルール](https://firebase.google.com/docs/firestore/security/get-started)
