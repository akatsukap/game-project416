# 🃏 Table Game Project (仮)

トランプや人狼ゲームをブラウザで遊べるようにするプロジェクトです。

## 🚀 このゲームについて
- **ジャンル**: テーブルゲーム（トランプ・人狼）
- **プラットフォーム**: ウェブブラウザ（PC/スマホ）
- **開発状況**: 開発初期フェーズ

## 🛠 使用技術
- **言語**: HTML / CSS / JavaScript / dart
- **公開環境**: GitHub Pages

## 📂 フォルダ構成
- `index.html`: ゲームのメイン画面
- `assets/`: 画像や音声ファイル
- `js/`: ゲームのロジック（プログラム）
- `css/`: デザイン設定

## 👥 メンバーと役割
- **@あなたのID**: リードエンジニア / プロジェクト管理
- **@友人のID**: グラフィックデザイン / サブプログラミング

## 📝 開発の進め方
1. `main` ブランチから機能ごとにブランチを作成して作業する
2. 作業が終わったら Pull Request を作成する
3. メンバーの確認後、`main` にマージする

## 📜 ライセンス
[MIT License](LICENSE)

## 💻 ローカル環境構築（Flutter / Dart・詳細版）

このプロジェクトは Flutter（Web） を使ってローカル環境で動作確認できます。
ここでは Flutter を PC に入れるところから、PATH（環境変数）設定までを説明します。

🧰 前提環境

OS：Windows / macOS

ブラウザ：Google Chrome（必須）

Git（必須）
https://git-scm.com/install/windows

エディタ：VS Code（推奨）
https://code.visualstudio.com/docs/setup/setup-overview

✅ 1. Flutter SDK のダウンロード
🔹 Flutter SDK とは
https://docs.flutter.dev/install/manual
ここのInstall and set up Flutterでダウンロード

Flutter の実行に必要な 開発キット一式です。
これを PC に配置し、環境変数 PATH に登録します。

🔹 ダウンロード先（共通）

Flutter SDK（zip形式）を取得
（公式サイトから最新版をダウンロードする想定）


※ zip を 任意の場所に展開します
（例：C:\src\flutter / /Users/username/flutter）

✅ 2. Flutter SDK の配置（重要）
📁 推奨配置場所
Windows（例）
C:\src\flutter
c直下にsrcファイルを配置し、そこで展開する

macOS（例）
/Users/ユーザー名/flutter

※ Program Files 配下は非推奨
（権限エラーが出やすいため）

✅ 3. 環境変数 PATH の設定（最重要）

Flutter コマンド（flutter）をどこからでも使えるようにします。

🪟 Windows の場合
① Flutter の bin フォルダを確認
C:\src\flutter\bin

② 環境変数を開く

Windows 検索で「環境変数」と入力

「システム環境変数の編集」を開く

「環境変数(N)...」をクリック

③ Path に追加

ユーザー環境変数 → Path → 編集

以下を追加：

C:\src\flutter\bin

④ 反映確認

PowerShell を再起動してから実行：

flutter --version


バージョンが表示されれば成功です。

🍎 macOS の場合
① Flutter の bin パスを確認

例：

/Users/username/flutter/bin

② shell 設定ファイルを編集

使用している shell により異なります。

zsh（最近の macOS）
nano ~/.zshrc

bash
nano ~/.bashrc

③ PATH を追加

ファイル末尾に以下を追加：

export PATH="$PATH:/Users/username/flutter/bin"

④ 反映
source ~/.zshrc

⑤ 確認
flutter --version

✅ 4. Flutter の初期診断（必須）

Flutter が正しく動くかチェックします。

flutter doctor

チェックポイント

Flutter：OK

Chrome：OK

Web toolchain：OK

❌ が出た場合
→ 表示される 指示通りに対応すればOK（例：Chrome未インストールなど）

✅ 5. Flutter Web を有効化（初回のみ）
flutter config --enable-web


有効確認：

flutter devices


以下が表示されれば成功です：

Chrome • chrome • web-javascript • Google Chrome

✅ 6. プロジェクトの起動
① リポジトリを取得
git clone <このリポジトリのURL>
cd <リポジトリ名>

② Flutter プロジェクトに移動

（例：flutter_app/ 配下にある場合）

cd flutter_app

③ 依存関係を取得
flutter pub get

④ ローカル起動（ブラウザ）
flutter run -d chrome


Chrome が起動し、ゲーム画面が表示されます。

🧯 よくあるエラーと原因（環境構築編）
症状	原因
flutter: command not found	PATH が通っていない
Chrome not found	Chrome 未インストール
flutter doctor に ❌	必要ツール不足
Web が出ない	--enable-web 未実行
✅ まとめ（ここだけ読めばOK）

Flutter SDK をダウンロード

flutter/bin を PATH に追加

flutter doctor を全て OK にする

flutter run -d chrome で起動

途中で詰まったらAIに聞こう！