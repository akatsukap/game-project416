# Firebaseエミュレーターのセットアップ（課金なし）

課金を有効にせずにローカルでFirebaseを使用する方法です。

## 1. Firebase CLIのインストール

```bash
npm install -g firebase-tools
```

## 2. Firebaseにログイン

```bash
firebase login
```

## 3. プロジェクトの初期化

```bash
cd my_app
firebase init
```

以下を選択：
- **Emulators: Set up local emulators for Firebase products**
- スペースキーで以下を選択：
  - ◉ Authentication Emulator
  - ◉ Firestore Emulator
- Enterキーで確認

ポート設定（デフォルトのままでOK）：
- Authentication Emulator: 9099
- Firestore Emulator: 8080

## 4. エミュレーターの起動

```bash
firebase emulators:start
```

## 5. Flutterアプリの設定

`my_app/lib/main.dart`を以下のように更新：

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
// ... 他のimport

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // エミュレーターに接続（開発環境のみ）
    if (kDebugMode) {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      debugPrint('🔥 Firebaseエミュレーターに接続しました');
    }
  } catch (e) {
    debugPrint('Firebase初期化エラー: $e');
  }

  runApp(const MyApp());
}

// ... 残りのコード
```

## 6. アプリの実行

別のターミナルでエミュレーターを起動したまま：

```bash
cd my_app
flutter run -d chrome
```

## 7. エミュレーターUI

ブラウザで以下にアクセスすると、エミュレーターのUIが表示されます：
- http://localhost:4000

ここで以下を確認できます：
- Authentication: 登録されたユーザー
- Firestore: データベースの内容

## メリット

- ✅ 課金不要
- ✅ オフラインで開発可能
- ✅ データをリセットしやすい
- ✅ 本番環境に影響しない

## デメリット

- ❌ 他のユーザーとのテストができない
- ❌ 本番環境とは別の設定が必要

## トラブルシューティング

### エラー: "Port already in use"

別のプロセスがポートを使用している場合：

```bash
# ポートを変更
firebase emulators:start --only auth,firestore --auth-port 9098 --firestore-port 8081
```

アプリ側も同じポートに変更：

```dart
await FirebaseAuth.instance.useAuthEmulator('localhost', 9098);
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8081);
```

### エラー: "Java not found"

FirestoreエミュレーターにはJavaが必要です：

```bash
# Windowsの場合
winget install Oracle.JDK.17

# macOSの場合
brew install openjdk@17
```
