import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'custom_dropdown.dart';
import 'items.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'second_page.dart';
import 'setting_page.dart';


Future<void> main() async {
  //.envから環境変数を読み込む
  await dotenv.load(fileName: '.env');
  //.envから読み込んだOpenAIのAPIキーを設定
  final token = dotenv.env['YOUR_OPENAI_API_KEY'] ?? '';

  if (token.isEmpty) {
    print('APIキーが設定されていません');
    return;
  }

  //OpenAI APIを利用するための準備をする（APIキーとタイムアウトの設定を含む）
  final openAI = OpenAI.instance.build(
    token: token, // APIキーを渡す
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 20), // HTTPリクエストの受信タイムアウトを20秒に設定
    ),
  );

  // Flutterアプリケーションを起動し、OpenAI APIを利用するための情報を渡す
  runApp(MyApp(openAI: openAI));
}

class MyApp extends StatelessWidget {
  final OpenAI openAI;
  const MyApp({Key? key, required this.openAI}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TopPage(openAI: openAI),
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 71, 185, 198), // AppBarの背景色を設定
          titleTextStyle: TextStyle(color: Color.fromARGB(255, 25, 25, 25), fontSize: 20), // タイトルのテキストスタイルを設定
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 15),
        ),),);
  }
}

class TopPage extends StatefulWidget {
  final OpenAI openAI;

  const TopPage({Key? key, required this.openAI}) : super(key: key);

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentIndex = 0; // 追加
  String contentToEnglish = '';
  String contentToJapanese = '';

  final TextEditingController _controllerTheme = TextEditingController();

  String displayedText = 'ここに入力されたテキストが表示されます';

  bool showTranslateButton3 = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    List voices = await _flutterTts.getVoices;
    for (var item in voices) {
      var map = item as Map<Object?, Object?>;
      if (map["locale"].toString().toLowerCase().contains("en")) {
        print(map["name"]);
      }
    }
    await _flutterTts.setVoice({'name': 'en-US', 'locale': 'en-US'});
  }

  Future<void> _speak(String text) async {
    print('Speaking: $text'); // ログ出力を追加
    var result = await _flutterTts.speak(text);
    print('Speak result: $result'); // 結果をログ出力
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      _buildMainContent(),
      SettingsPage(), // SettingsPageウィジェットを用意する
    ];

    return Scaffold(
      body: _children[_currentIndex], // インデックスに応じて表示を切り替え
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.cyan, title: Text('英文を生成する')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 入力フォーム
              TextField(
                controller: _controllerTheme,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'お好きなテーマ',
                ),
              ),

              // ドロップダウンリスト
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '語数',
                    style: TextStyle(fontSize: 15),
                  ),
                  CustomDropdown(
                    value: dropdownValueLength,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValueLength = newValue!;
                      });
                    },
                    items: itemsLength,
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'レベル',
                    style: TextStyle(fontSize: 15),
                  ),
                  CustomDropdown(
                    value: dropdownValueLevel,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValueLevel = newValue!;
                      });
                    },
                    items: itemsLevel,
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '文章スタイル',
                    style: TextStyle(fontSize: 15),
                  ),
                  CustomDropdown(
                    value: dropdownValueStyle,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValueStyle = newValue!;
                      });
                    },
                    items: itemsStyle,
                  ),
                ],
              ),

              SizedBox(
                height: 20,
              ),

              // 送信ボタン
              ElevatedButton(
                onPressed: () {
                  //switch文でChatGPTに放り込む用の文言に入れ替える
                  String levelDescription =
                      getLevelDescription(dropdownValueLevel);
                  String styleDescription =
                      getStyleDescription(dropdownValueStyle);

                  String contentToEnglish =
                      'Please write a $dropdownValueLength-word text about “' +
                          _controllerTheme.text +
                          '” in $styleDescription. The text should be suitable for a CEFR-J $levelDescription level learner.'; //質問（content2）に入力フォームの回答（_controller.text）を代入

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecondPage(
                        contentToEnglish: contentToEnglish,
                        contentToJapanese: '',
                        openAI: widget.openAI,
                        speak: _speak,
                        themeText: _controllerTheme.text, // 追加
                      ),
                    ),
                  );
                },
                child: Text('生成する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


