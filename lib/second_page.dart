import 'package:english_generate_shun/items.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

class SecondPage extends StatefulWidget {
  final String contentToEnglish;
  final String contentToJapanese;
  final OpenAI openAI;
  final void Function(String) speak;
  final String themeText;

  const SecondPage({
    Key? key,
    required this.contentToEnglish,
    required this.contentToJapanese,
    required this.openAI,
    required this.speak,
    required this.themeText, 
    //このへん、もっときれいにできるな、、ページをまたぐ必要がない変数が結構ある
  }) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String textEnglish = '';
  String textJapanese = '';
  bool showTranslateButton3 = false;
  String contentToJapanese = '';

  @override
  void initState() {
    super.initState();
    _fetchDataEnglish();
  }

  Future<void> _fetchDataEnglish() async {
    Stream<ChatResponseSSE> stream = widget.openAI.onChatCompletionSSE(
      request: ChatCompleteText(
        model: GptTurboChatModel(),
        messages: [
          Messages(
            role: Role.system,
            content: widget.contentToEnglish,
          ),
        ],
        maxToken: 200,
      ),
    );

    await for (var event in stream) {
      print('Received content:${widget.contentToEnglish}');
      final text = event.choices?.last.message?.content ?? '';
      print('Received text: $text'); // デバッグ用ログ
      setState(() {
        textEnglish = textEnglish + text;
        print('Updated text2: $textEnglish'); // デバッグ用ログ
      });
    }
  }

  void _fetchDataJapanese() {
    Stream<ChatResponseSSE> stream = widget.openAI.onChatCompletionSSE(
      request: ChatCompleteText(
        model: GptTurboChatModel(),
        messages: [
          Messages(
            role: Role.system,
            content: contentToJapanese,
          ),
        ],
        maxToken: 200,
      ),
    );

    stream.listen((event) {
      print('Received content:${widget.contentToJapanese}');
      final text = event.choices?.last.message?.content ?? '';
      print('Received text: $text'); // デバッグ用ログ
      setState(() {
        textJapanese = textJapanese + text;
        print('Updated text3: $textJapanese'); // デバッグ用ログ
      });
    }, onError: (error) {
      print('Error occurred: $error'); // デバッグ用ログ
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Text('テーマ:' + widget.themeText),
              Text('語数：$dropdownValueLength'),
              Text('レベル：$dropdownValueLevel'),
              Text('文章スタイル：$dropdownValueStyle'),
              Text(
                textEnglish,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
              if (showTranslateButton3)
                Text(
                  textJapanese,
                  style: TextStyle(fontSize: 20),
                ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  print('日本語訳するボタンが押されました');
                  setState(() {
                    showTranslateButton3 = true;
                    contentToJapanese = '以下の英文を日本語にして「$textEnglish」';
                  });
                  _fetchDataJapanese();
                },
                child: Text('日本語にする'),
              ),
              SizedBox(
                height: 6,
              ),
              ElevatedButton(
                onPressed: () {
                  widget.speak(textEnglish);
                },
                child: Text('音声'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
