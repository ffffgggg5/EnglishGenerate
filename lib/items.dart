

// ドロップダウンの初期値を設定
String dropdownValueLength = '50';
String dropdownValueLevel = 'Lv.7 高校1年生';
String dropdownValueStyle = '小説';

List<String> itemsLength = ['50', '100', '150', '200', '250', '300'];
List<String> itemsLevel = [
  'Lv.0 幼稚園',
  'Lv.1 小学校低学年',
  'Lv.2 小学校中学年',
  'Lv.3 小学校高学年',
  'Lv.4 中学校1年生',
  'Lv.5 中学校2年生',
  'Lv.6 中学校3年生',
  'Lv.7 高校1年生',
  'Lv.8 高校2年生',
  'Lv.9 高校3年生',
  'Lv.10 日東駒専',
  'Lv.11 MARCH',
  'Lv.12 MARCH上位',
  'Lv.13 早慶',
  'Lv.14 早慶上位',
  'Lv.15 東大,京大',
  'Lv.16 東大,京大',
  'Lv.17 東大,京大上位',
  'Lv.18 東大,京大上位',
  'Lv.19 ネイティブ',
  'Lv.20 ネイティブ',
];
List<String> itemsStyle = [
  '友達',
  '公式',
  'ビジネス',
  'ニュース',
  '学術',
  '小説',
  '説明書',
  '広告',
];


String getLevelDescription(String originalLevel) {
  switch (originalLevel) {
    case 'Lv.0 幼稚園':
      return 'Pre-A1.1';
    case 'Lv.1 小学校低学年':
      return 'Pre-A1.2';
    case 'Lv.2 小学校中学年':
      return 'Pre-A1.3';
    case 'Lv.3 小学校高学年':
      return 'A1.1';
    case 'Lv.4 中学校1年生':
      return 'A1.2';
    case 'Lv.5 中学校2年生':
      return 'A1.3';
    case 'Lv.6 中学校3年生':
      return 'A2.1';
    case 'Lv.7 高校1年生':
      return 'A2.2';
    case 'Lv.8 高校2年生':
      return 'A2.3';
    case 'Lv.9 高校3年生':
      return 'B1.1';
    case 'Lv.10 日東駒専':
      return 'B1.2';
    case 'Lv.11 MARCH':
      return 'B1.3';
    case 'Lv.12 MARCH上位':
      return 'B2.1';
    case 'Lv.13 早慶':
      return 'B2.2';
    case 'Lv.14 早慶上位':
      return 'B2.3';
    case 'Lv.15 東大,京大':
      return 'C1.1';
    case 'Lv.16 東大,京大':
      return 'C1.2';
    case 'Lv.17 東大,京大上位':
      return 'C1.3';
    case 'Lv.18 東大,京大上位':
      return 'C2.1';
    case 'Lv.19 ネイティブ':
      return 'C2.2';
    case 'Lv.20 ネイティブ':
      return 'C2.3';
    default:
      return originalLevel; // 入力されたレベルがリストにない場合は元の文言を返す
  }
}


String getStyleDescription(String originalStyle) {
  switch (originalStyle) {
    case '友達':
      return 'a casual and friendly style, using simple and conversational language.';
    case '公式':
      return 'a formal and professional style, using respectful and precise language.';
    case 'ビジネス':
      return 'a semi-formal and business-like style, balancing formality and approachability.';
    case 'ニュース':
      return 'a journalistic and objective style, focusing on facts and clear reporting.';
    case '学術':
      return 'an academic and scholarly style, using complex and well-structured language.';
    case '小説':
      return 'a creative and imaginative style, using vivid and engaging language.';
    case '説明書':
      return 'a technical and precise style, using specific and detailed language.';
    case '広告':
      return 'a promotional and persuasive style, using compelling and motivational language.';
    default:
      return originalStyle; // 入力されたスタイルがリストにない場合は元の文言を返す
  }
}
