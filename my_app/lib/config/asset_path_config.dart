/// アセット設定を管理するクラス
///
/// このクラスは、アプリケーション全体で使用されるアセットパスの
/// ベースディレクトリと必須アセットのリストを定義します。
class AssetPathConfig {
  /// キャラクタースプライトのベースディレクトリ
  static const String charactersDir = 'characters/';

  /// ゲームアセットのベースディレクトリ
  static const String gameDir = 'game/';

  /// エフェクトアセットのベースディレクトリ
  static const String effectsDir = 'effects/';

  /// 必須アセットのリスト
  ///
  /// これらのアセットはアプリケーションの起動時に検証されます。
  /// パスはFlameエンジン用の相対パス形式（"assets/"プレフィックスなし）です。
  static const List<String> requiredAssets = [
    'game/field_background.png',
    'game/goal.png',
    'game/ball.png',
  ];
}
