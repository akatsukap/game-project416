#!/usr/bin/env python3
"""
キャラクタープレースホルダー画像生成スクリプト

各キャラクターの特徴を反映したシンプルな画像を生成します。
PIL (Pillow) ライブラリが必要です: pip install pillow
"""

import os

from PIL import Image, ImageDraw, ImageFont

# キャラクター定義
CHARACTERS = [
    {
        'filename': 'hero1.png',
        'name': '地元のヒーロー',
        'color': (52, 152, 219),  # 青
        'ability': 'スピード',
        'icon': '⚡'
    },
    {
        'filename': 'shop_owner.png',
        'name': '商店のおやじ',
        'color': (231, 76, 60),  # 赤
        'ability': 'パワー',
        'icon': '💪'
    },
    {
        'filename': 'student.png',
        'name': '地元の学生',
        'color': (46, 204, 113),  # 緑
        'ability': 'テクニック',
        'icon': '⏱️'
    },
    {
        'filename': 'firefighter.png',
        'name': '地元の消防士',
        'color': (241, 196, 15),  # 黄
        'ability': 'ジャンプ',
        'icon': '🚀'
    },
    {
        'filename': 'security_guard.png',
        'name': '地元の警備員',
        'color': (155, 89, 182),  # 紫
        'ability': '防御',
        'icon': '🛡️'
    }
]

def create_character_placeholder(char_data, size=(128, 128)):
    """
    キャラクタープレースホルダー画像を生成
    
    Args:
        char_data: キャラクターデータ辞書
        size: 画像サイズ (width, height)
    
    Returns:
        PIL Image オブジェクト
    """
    # 画像を作成
    img = Image.new('RGBA', size, (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)
    
    # 背景円を描画
    margin = 10
    circle_bbox = [margin, margin, size[0] - margin, size[1] - margin]
    draw.ellipse(circle_bbox, fill=char_data['color'] + (255,), outline=(0, 0, 0, 255), width=3)
    
    # 頭部（上部の円）
    head_size = size[0] // 3
    head_x = size[0] // 2
    head_y = size[1] // 3
    head_bbox = [
        head_x - head_size // 2,
        head_y - head_size // 2,
        head_x + head_size // 2,
        head_y + head_size // 2
    ]
    draw.ellipse(head_bbox, fill=(255, 224, 189, 255), outline=(0, 0, 0, 255), width=2)
    
    # 体部（長方形）
    body_width = size[0] // 2.5
    body_height = size[1] // 2.5
    body_x = size[0] // 2
    body_y = size[1] // 1.7
    body_bbox = [
        body_x - body_width // 2,
        body_y - body_height // 2,
        body_x + body_width // 2,
        body_y + body_height // 2
    ]
    # 体の色を少し暗くする
    body_color = tuple(max(0, c - 30) for c in char_data['color']) + (255,)
    draw.rectangle(body_bbox, fill=body_color, outline=(0, 0, 0, 255), width=2)
    
    # 目を描画
    eye_size = 4
    left_eye_x = head_x - head_size // 4
    right_eye_x = head_x + head_size // 4
    eye_y = head_y - head_size // 6
    
    draw.ellipse([left_eye_x - eye_size, eye_y - eye_size, 
                  left_eye_x + eye_size, eye_y + eye_size], 
                 fill=(0, 0, 0, 255))
    draw.ellipse([right_eye_x - eye_size, eye_y - eye_size, 
                  right_eye_x + eye_size, eye_y + eye_size], 
                 fill=(0, 0, 0, 255))
    
    # 口を描画
    mouth_y = head_y + head_size // 4
    draw.arc([head_x - head_size // 3, mouth_y - 5, 
              head_x + head_size // 3, mouth_y + 5], 
             0, 180, fill=(0, 0, 0, 255), width=2)
    
    # テキストを追加（能力名）
    try:
        # フォントサイズを調整
        font_size = 14
        # デフォルトフォントを使用
        text = char_data['ability']
        text_bbox = draw.textbbox((0, 0), text)
        text_width = text_bbox[2] - text_bbox[0]
        text_height = text_bbox[3] - text_bbox[1]
        text_x = (size[0] - text_width) // 2
        text_y = size[1] - 25
        
        # テキスト背景
        padding = 3
        draw.rectangle([text_x - padding, text_y - padding, 
                       text_x + text_width + padding, text_y + text_height + padding],
                      fill=(255, 255, 255, 200))
        
        # テキスト描画
        draw.text((text_x, text_y), text, fill=(0, 0, 0, 255))
    except Exception as e:
        print(f"テキスト描画エラー: {e}")
    
    return img

def main():
    """メイン処理"""
    print("キャラクタープレースホルダー画像を生成中...")
    
    # 出力ディレクトリを確認
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    for char_data in CHARACTERS:
        try:
            # 画像を生成
            img = create_character_placeholder(char_data)
            
            # 保存
            output_path = os.path.join(script_dir, char_data['filename'])
            img.save(output_path, 'PNG')
            print(f"✓ {char_data['filename']} を生成しました ({char_data['name']})")
        except Exception as e:
            print(f"✗ {char_data['filename']} の生成に失敗: {e}")
    
    print("\n完了！")
    print("生成された画像:")
    for char_data in CHARACTERS:
        print(f"  - {char_data['filename']}: {char_data['name']} ({char_data['ability']})")

if __name__ == '__main__':
    main()
