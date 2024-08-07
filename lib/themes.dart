import 'dart:math';

// テーマのリストを定義
//足すのは簡単そうだな〜
List<String> themesList = [
  '睡眠の科学',
  '印刷の歴史',
  '動物の視界',
  'ダークマター',
  '言語の進化',
  'ワクチン',
  'ローラー物理',
  'サンゴ礁',
  '音楽の数',
  '星の寿命',
  'ネットの仕組み',
  '気候変動',
  'ケーキ科学',
  '宇宙探査',
  '夢の理由',
  'ニュートン法',
  'DNAの構造',
  'エベレスト',
  '免疫システム',
  '古代エジプト'
];

// ランダムにテーマを取得する関数
String getRandomTheme() {
  final random = Random();
  return themesList[random.nextInt(themesList.length)];
}
