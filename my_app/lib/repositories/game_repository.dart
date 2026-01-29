import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/match_result.dart';
import '../models/player_stats.dart';

/// ゲームデータの永続化を管理するリポジトリクラス
///
/// SharedPreferencesを使用して、試合結果やプレイヤー統計などの
/// ゲームデータをローカルストレージに保存・読み込みします。
class GameRepository {
  /// SharedPreferencesのインスタンス
  final SharedPreferences _prefs;

  /// ストレージキー: 試合結果リスト
  static const String _matchResultsKey = 'match_results';

  /// ストレージキー: プレイヤー統計
  static const String _playerStatsKey = 'player_stats';

  /// ストレージキー: 選択されたキャラクター
  static const String _selectedCharacterKey = 'selected_character';

  /// コンストラクタ
  ///
  /// [prefs] SharedPreferencesのインスタンス
  GameRepository({required SharedPreferences prefs}) : _prefs = prefs;

  /// GameRepositoryのインスタンスを作成する
  ///
  /// SharedPreferencesを初期化してGameRepositoryを返します。
  /// 戻り値: 初期化されたGameRepositoryインスタンス
  static Future<GameRepository> create() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return GameRepository(prefs: prefs);
    } catch (e) {
      // SharedPreferencesの初期化に失敗した場合はログに記録
      print('SharedPreferencesの初期化に失敗しました: $e');
      rethrow; // 上位レイヤーでエラーを処理できるように再スロー
    }
  }

  /// 試合結果を保存する
  ///
  /// [matchResult] 保存する試合結果
  /// 戻り値: 保存が成功した場合はtrue、失敗した場合はfalse
  ///
  /// 要件: 9.1 - プレイヤーが試合を完了したときに試合結果をローカルストレージに保存する
  Future<bool> saveMatchResult(MatchResult matchResult) async {
    try {
      // 既存の試合結果リストを読み込む
      final results = await loadAllMatchResults();

      // 新しい試合結果を追加
      results.add(matchResult);

      // JSON形式に変換
      final jsonList = results.map((result) => result.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      // SharedPreferencesに保存
      return await _prefs.setString(_matchResultsKey, jsonString);
    } catch (e) {
      // エラーが発生した場合はログに記録してfalseを返す
      print('試合結果の保存に失敗しました: $e');
      return false;
    }
  }

  /// 最新の試合結果を読み込む
  ///
  /// 戻り値: 最新の試合結果、データがない場合はnull
  ///
  /// 要件: 9.3 - アプリが起動されたときに保存されたデータを読み込む
  Future<MatchResult?> loadMatchResult() async {
    try {
      final results = await loadAllMatchResults();
      if (results.isEmpty) {
        return null;
      }
      // 最新の試合結果を返す（リストの最後の要素）
      return results.last;
    } catch (e) {
      // エラーが発生した場合はログに記録してnullを返す
      print('試合結果の読み込みに失敗しました: $e');
      return null;
    }
  }

  /// すべての試合結果を読み込む
  ///
  /// 戻り値: 試合結果のリスト、データがない場合は空のリスト
  Future<List<MatchResult>> loadAllMatchResults() async {
    try {
      final jsonString = _prefs.getString(_matchResultsKey);
      if (jsonString == null) {
        return [];
      }

      // JSON文字列をデコード
      final jsonList = jsonDecode(jsonString) as List<dynamic>;

      // MatchResultオブジェクトのリストに変換
      return jsonList
          .map((json) => MatchResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // エラーが発生した場合はログに記録して空のリストを返す
      print('試合結果リストの読み込みに失敗しました: $e');
      return [];
    }
  }

  /// プレイヤー統計を保存する
  ///
  /// [stats] 保存するプレイヤー統計
  /// 戻り値: 保存が成功した場合はtrue、失敗した場合はfalse
  ///
  /// 要件: 9.4 - 勝敗数、総得点、プレイ時間を記録する
  Future<bool> savePlayerStats(PlayerStats stats) async {
    try {
      final jsonString = jsonEncode(stats.toJson());
      return await _prefs.setString(_playerStatsKey, jsonString);
    } catch (e) {
      // エラーが発生した場合はログに記録してfalseを返す
      print('プレイヤー統計の保存に失敗しました: $e');
      return false;
    }
  }

  /// プレイヤー統計を読み込む
  ///
  /// 戻り値: プレイヤー統計、データがない場合は空の統計
  ///
  /// 要件: 9.3 - アプリが起動されたときに保存されたデータを読み込む
  Future<PlayerStats> loadPlayerStats() async {
    try {
      final jsonString = _prefs.getString(_playerStatsKey);
      if (jsonString == null) {
        return PlayerStats.empty();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlayerStats.fromJson(json);
    } catch (e) {
      // エラーが発生した場合はログに記録して空の統計を返す
      print('プレイヤー統計の読み込みに失敗しました: $e');
      return PlayerStats.empty();
    }
  }

  /// 選択されたキャラクターIDを保存する
  ///
  /// [characterId] 保存するキャラクターID
  /// 戻り値: 保存が成功した場合はtrue、失敗した場合はfalse
  ///
  /// 要件: 9.2 - プレイヤーがキャラクターを選択したときにその選択を記憶する
  Future<bool> saveSelectedCharacter(String characterId) async {
    try {
      return await _prefs.setString(_selectedCharacterKey, characterId);
    } catch (e) {
      // エラーが発生した場合はログに記録してfalseを返す
      print('選択されたキャラクターの保存に失敗しました: $e');
      return false;
    }
  }

  /// 選択されたキャラクターIDを読み込む
  ///
  /// 戻り値: 選択されたキャラクターID、データがない場合はnull
  ///
  /// 要件: 9.3 - アプリが起動されたときに保存されたデータを読み込む
  Future<String?> loadSelectedCharacter() async {
    try {
      return _prefs.getString(_selectedCharacterKey);
    } catch (e) {
      // エラーが発生した場合はログに記録してnullを返す
      print('選択されたキャラクターの読み込みに失敗しました: $e');
      return null;
    }
  }

  /// すべてのデータをクリアする（テスト用）
  ///
  /// 戻り値: クリアが成功した場合はtrue、失敗した場合はfalse
  Future<bool> clearAll() async {
    try {
      await _prefs.remove(_matchResultsKey);
      await _prefs.remove(_playerStatsKey);
      await _prefs.remove(_selectedCharacterKey);
      return true;
    } catch (e) {
      // エラーが発生した場合はログに記録してfalseを返す
      print('データのクリアに失敗しました: $e');
      return false;
    }
  }
}
