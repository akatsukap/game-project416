/// ヘッドボールサッカーゲームの状態を表す列挙型
enum GameState {
  /// メニュー画面
  menu,

  /// キャラクター選択画面
  characterSelect,

  /// ゲームプレイ中
  playing,

  /// 一時停止中
  paused,

  /// 試合終了
  finished,
}
