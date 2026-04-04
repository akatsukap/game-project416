import 'package:flutter/material.dart';
import 'package:my_app/models/party_game_definition.dart';

class PartyGameCatalog {
  static const List<PartyGameDefinition> games = [
    PartyGameDefinition(
      id: 'horse_dash',
      title: '競馬ダッシュ',
      description: '最優先: 2〜6人で連打して盛り上がる短時間レース。',
      category: PartyGameCategory.priority,
      icon: Icons.emoji_events,
      color: Colors.orange,
      availability: PartyGameAvailability.playable,
      routeName: '/horse-race',
      tags: ['飲み会', 'スピード決着', '2-6人'],
    ),
    PartyGameDefinition(
      id: 'babanuki',
      title: 'ババ抜き',
      description: '定番トランプ。オンラインマルチ対応。',
      category: PartyGameCategory.trump,
      icon: Icons.style,
      color: Colors.purple,
      availability: PartyGameAvailability.playable,
      routeName: '/babanuki-mode-selection',
      tags: ['トランプ', 'オンライン'],
    ),
    PartyGameDefinition(
      id: 'poker',
      title: 'ポーカー',
      description: '写真カード加工や身内ネタルール拡張を想定。',
      category: PartyGameCategory.trump,
      icon: Icons.auto_awesome,
      color: Colors.indigo,
      availability: PartyGameAvailability.planning,
      tags: ['トランプ', '写真加工', '身内ノリ'],
    ),
    PartyGameDefinition(
      id: 'memory',
      title: '神経衰弱',
      description: '通常版＋写真加工版（元画像当て）を想定。',
      category: PartyGameCategory.trump,
      icon: Icons.grid_view,
      color: Colors.deepPurple,
      availability: PartyGameAvailability.planning,
      tags: ['トランプ', '記憶', '写真アレンジ'],
    ),
    PartyGameDefinition(
      id: 'karuta',
      title: 'カルタ',
      description: '写真や身内フレーズを使う派生版まで見据える。',
      category: PartyGameCategory.trump,
      icon: Icons.collections,
      color: Colors.redAccent,
      availability: PartyGameAvailability.planning,
      tags: ['読み上げ', '写真ネタ'],
    ),
    PartyGameDefinition(
      id: 'zoom_quiz',
      title: 'ズームアウト早押しクイズ',
      description: 'ズーム画像が徐々に引き、先に当てた人が勝ち。',
      category: PartyGameCategory.quiz,
      icon: Icons.zoom_out_map,
      color: Colors.blue,
      availability: PartyGameAvailability.prototype,
      tags: ['クイズ', '早押し'],
    ),
    PartyGameDefinition(
      id: 'simple_quiz',
      title: 'シンプルクイズ',
      description: 'お題投稿型で飲み会向けに短サイクルで進行。',
      category: PartyGameCategory.quiz,
      icon: Icons.quiz,
      color: Colors.lightBlue,
      availability: PartyGameAvailability.planning,
      tags: ['クイズ', 'カスタム問題'],
    ),
    PartyGameDefinition(
      id: 'werewolf',
      title: '人狼 x ミニゲーム',
      description: 'ミニゲーム結果が人狼側に有利に働く派生ルール案。',
      category: PartyGameCategory.social,
      icon: Icons.nightlight_round,
      color: Colors.blueGrey,
      availability: PartyGameAvailability.planning,
      tags: ['正体隠匿', '派生ルール'],
    ),
    PartyGameDefinition(
      id: 'word_wolf',
      title: 'ワードウルフ',
      description: '写真テーマ差分で少数派を炙り出す遊び方を想定。',
      category: PartyGameCategory.social,
      icon: Icons.record_voice_over,
      color: Colors.teal,
      availability: PartyGameAvailability.planning,
      tags: ['会話', '写真お題'],
    ),
    PartyGameDefinition(
      id: 'head_ball',
      title: 'ヘッドボール',
      description: '2人対戦のアクション。サクッと1試合。',
      category: PartyGameCategory.casual,
      icon: Icons.sports_soccer,
      color: Colors.green,
      availability: PartyGameAvailability.playable,
      routeName: '/head-ball-menu',
      tags: ['アクション', '2人対戦'],
    ),
    PartyGameDefinition(
      id: 'marubatsu',
      title: 'まるばつ＋爆弾9マス',
      description: '爆弾3つ入り・上書きありの読み合いゲーム案。',
      category: PartyGameCategory.casual,
      icon: Icons.apps,
      color: Colors.brown,
      availability: PartyGameAvailability.planning,
      tags: ['ボード', '駆け引き'],
    ),
    PartyGameDefinition(
      id: 'chinchiro',
      title: 'サイコロ / ちんちろ',
      description: '短時間で回せる運要素ミニゲーム。',
      category: PartyGameCategory.casual,
      icon: Icons.casino,
      color: Colors.amber,
      availability: PartyGameAvailability.planning,
      tags: ['サイコロ', '短時間'],
    ),
    PartyGameDefinition(
      id: 'other_ideas',
      title: 'その他アイデア集',
      description: '食わず嫌い王 / ドボンクイズ / 人生ゲーム / 3連単 など。',
      category: PartyGameCategory.casual,
      icon: Icons.lightbulb,
      color: Colors.deepOrange,
      availability: PartyGameAvailability.planning,
      tags: ['企画ストック'],
    ),
  ];

  static String categoryLabel(PartyGameCategory category) {
    switch (category) {
      case PartyGameCategory.priority:
        return '最優先';
      case PartyGameCategory.trump:
        return 'トランプ系';
      case PartyGameCategory.quiz:
        return 'クイズ系';
      case PartyGameCategory.social:
        return '正体隠匿・会話系';
      case PartyGameCategory.casual:
        return 'その他ミニゲーム';
    }
  }

  static Color availabilityColor(PartyGameAvailability availability) {
    switch (availability) {
      case PartyGameAvailability.playable:
        return Colors.green;
      case PartyGameAvailability.prototype:
        return Colors.orange;
      case PartyGameAvailability.planning:
        return Colors.grey;
    }
  }

  static String availabilityLabel(PartyGameAvailability availability) {
    switch (availability) {
      case PartyGameAvailability.playable:
        return 'プレイ可能';
      case PartyGameAvailability.prototype:
        return '試作中';
      case PartyGameAvailability.planning:
        return '企画中';
    }
  }
}
