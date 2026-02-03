import 'package:flutter/material.dart';

import '../../models/character_data.dart';
import '../../models/character_registry.dart';

/// キャラクター選択画面
///
/// プレイヤーがキャラクターを選択する画面
class CharacterSelectScreen extends StatefulWidget {
  /// プレイヤー番号（1 or 2）
  final int playerNumber;

  /// キャラクター選択完了時のコールバック
  final Function(CharacterData) onCharacterSelected;

  const CharacterSelectScreen({
    super.key,
    required this.playerNumber,
    required this.onCharacterSelected,
  });

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  /// 選択中のキャラクターインデックス
  int _selectedIndex = 0;

  /// 選択中のキャラクター
  CharacterData get _selectedCharacter =>
      CharacterRegistry.getAllCharacters()[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    final characters = CharacterRegistry.getAllCharacters();
    final MaterialColor playerColor = widget.playerNumber == 1
        ? Colors.blue
        : Colors.red;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [playerColor.shade300, playerColor.shade100],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 画面サイズに応じてレイアウトを切り替え
              // 幅が600px未満の場合はコンパクトレイアウト（縦向き）
              // 600px以上の場合はワイドレイアウト（横向き）
              if (constraints.maxWidth < 600) {
                return _buildCompactLayout(characters, playerColor);
              } else {
                return _buildWideLayout(characters, playerColor);
              }
            },
          ),
        ),
      ),
    );
  }

  /// ワイドレイアウト（横向き・大画面用）
  Widget _buildWideLayout(
    List<CharacterData> characters,
    MaterialColor playerColor,
  ) {
    return Row(
      children: [
        // 左側：ヘッダーとキャラクター詳細
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // ヘッダー
              _buildHeader(playerColor),
              const SizedBox(height: 16),
              // 選択中のキャラクター詳細
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildCharacterDetails(playerColor),
                ),
              ),
              const SizedBox(height: 16),
              // 決定ボタン
              _buildConfirmButton(playerColor),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // 右側：キャラクター一覧
        Expanded(
          flex: 3,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'キャラクターを選択',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: playerColor[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildCharacterGrid(characters, crossAxisCount: 3),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  /// コンパクトレイアウト（縦向き・小画面用）
  Widget _buildCompactLayout(
    List<CharacterData> characters,
    MaterialColor playerColor,
  ) {
    return Column(
      children: [
        // ヘッダー
        _buildHeader(playerColor),
        const SizedBox(height: 12),
        // キャラクター一覧（グリッド）
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'キャラクターを選択',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: playerColor[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildCharacterGrid(characters, crossAxisCount: 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 選択中のキャラクター詳細（コンパクト版）
        Flexible(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCharacterDetails(playerColor),
          ),
        ),
        const SizedBox(height: 12),
        // 決定ボタン
        _buildConfirmButton(playerColor),
        const SizedBox(height: 16),
      ],
    );
  }

  /// ヘッダーを構築
  Widget _buildHeader(MaterialColor playerColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 戻るボタン
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            color: playerColor[700],
            onPressed: () => Navigator.pop(context),
          ),
          // タイトル（Flexibleでラップしてオーバーフロー防止）
          Flexible(
            child: Text(
              'プレイヤー${widget.playerNumber}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: playerColor[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 48), // バランス調整用
        ],
      ),
    );
  }

  /// キャラクター一覧をグリッド表示で構築
  Widget _buildCharacterGrid(
    List<CharacterData> characters, {
    required int crossAxisCount,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // 画面サイズに応じて列数を変更
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        final isSelected = index == _selectedIndex;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.yellow : Colors.grey.shade300,
                width: isSelected ? 4 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // キャラクターアイコン
                Icon(
                  Icons.person,
                  size: isSelected ? 50 : 40,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                // キャラクター名（Flexibleでラップしてオーバーフロー防止）
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      character.name,
                      style: TextStyle(
                        fontSize: isSelected ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // 選択インジケーター
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.yellow.shade700,
                    size: 24,
                  )
                else
                  const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  /// キャラクター詳細を構築
  Widget _buildCharacterDetails(MaterialColor playerColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // キャラクター名
          Text(
            _selectedCharacter.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: playerColor[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // 説明
          Text(
            _selectedCharacter.description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // 能力値
          _buildAbilityBar(
            label: 'スピード',
            value: _selectedCharacter.speed,
            maxValue: 150.0,
            color: Colors.blue,
          ),
          const SizedBox(height: 6),
          _buildAbilityBar(
            label: 'ジャンプ力',
            value: _selectedCharacter.jumpPower,
            maxValue: 500.0,
            color: Colors.green,
          ),
          const SizedBox(height: 6),
          _buildAbilityBar(
            label: 'キック力',
            value: _selectedCharacter.kickPower,
            maxValue: 800.0,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          // 特殊能力
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.purple.shade700, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '特殊能力: ${_getSpecialAbilityName(_selectedCharacter.specialAbilityType)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 能力値バーを構築
  Widget _buildAbilityBar({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
  }) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    return Row(
      children: [
        // ラベル（Flexibleでラップしてオーバーフロー防止）
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        // バー
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              // 背景
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // 値
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // 数値
        SizedBox(
          width: 40,
          child: Text(
            value.toInt().toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 決定ボタンを構築
  Widget _buildConfirmButton(MaterialColor playerColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            widget.onCharacterSelected(_selectedCharacter);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: playerColor[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.3),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('決定'),
              SizedBox(width: 8),
              Icon(Icons.check, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// 特殊能力名を取得
  String _getSpecialAbilityName(SpecialAbilityType type) {
    switch (type) {
      case SpecialAbilityType.speedBoost:
        return 'スピードブースト';
      case SpecialAbilityType.powerKick:
        return 'パワーキック';
      case SpecialAbilityType.timeStop:
        return '時間停止';
      case SpecialAbilityType.jumpBoost:
        return 'ジャンプブースト';
      case SpecialAbilityType.shield:
        return 'シールド';
    }
  }
}
