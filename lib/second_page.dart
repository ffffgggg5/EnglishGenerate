import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'database_helper.dart'; // DatabaseHelperをインポート
import 'audio_play.dart'; // AudioPlayをインポート
import 'items.dart';

class SecondPage extends StatefulWidget {
  final String themeText;
  final String dropdownValueLength;
  final String dropdownValueLevel;
  final String dropdownValueStyle;

  const SecondPage({
    Key? key,
    required this.themeText,
    required this.dropdownValueLength,
    required this.dropdownValueLevel,
    required this.dropdownValueStyle,
  }) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late OpenAI openAI;
  String textEnglish = '';
  String textJapanese = '';
  bool showTranslateButton3 = false;
  bool isSavingEnabled = false; // 追加
  String contentToJapanese = '';
  String audioFilePath = '';
  late String formattedDate;
  String modifiedDropdownValueLevel = '';
  String modifiedDropdownValueStyle = '';

  @override
  void initState() {
    super.initState();
    formattedDate =
        "${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}";
    _initializeServices();

    modifiedDropdownValueLevel = getLevelDescription(widget.dropdownValueLevel);
    modifiedDropdownValueStyle = getStyleDescription(widget.dropdownValueStyle);

    _fetchDataEnglish();
  }

  Future<void> _initializeServices() async {
    final openAiToken = dotenv.env['YOUR_OPENAI_API_KEY'] ?? '';

    if (openAiToken.isEmpty) {
      print('OpenAI APIキーが設定されていません');
      return;
    }

    // OpenAIの初期化
    openAI = OpenAI.instance.build(
      token: openAiToken,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
  }

  Future<void> _fetchDataEnglish() async {
    Stream<ChatResponseSSE> stream = openAI.onChatCompletionSSE(
      request: ChatCompleteText(
        model: GptTurboChatModel(),
        messages: [
          Messages(
            role: Role.system,
            content:
                'Please write a ${widget.dropdownValueLength}-word text in English about “${widget.themeText}” in $modifiedDropdownValueStyle. The text should be suitable for a CEFR-J $modifiedDropdownValueLevel level learner.',
          ),
        ],
        maxToken: 200,
      ),
    );

    await for (var event in stream) {
      final text = event.choices?.last.message?.content ?? '';
      if (mounted) {
        setState(() {
          textEnglish = textEnglish + text;
        });
      }
    }

    if (textEnglish.isNotEmpty) {
      await _synthesizeAudio(textEnglish);
      contentToJapanese = '以下の英文を日本語にして「$textEnglish」';
      await _fetchDataJapanese();
      if (mounted) {
        setState(() {
          isSavingEnabled = true; // 日本語訳の生成が完了したらボタンを有効化
        });
      }
    }
  }

  Future<void> _saveGeneratedText(String englishText) async {
    final newItem = {
      'englishText': englishText,
      'japaneseText': textJapanese.isEmpty ? 'N/A' : textJapanese,
      'date': formattedDate,
      'theme': widget.themeText.isEmpty ? 'N/A' : widget.themeText,
      'level':
          widget.dropdownValueLevel.isEmpty ? 'N/A' : widget.dropdownValueLevel,
      'length': widget.dropdownValueLength.isEmpty
          ? 'N/A'
          : widget.dropdownValueLength,
      'style':
          widget.dropdownValueStyle.isEmpty ? 'N/A' : widget.dropdownValueStyle,
      'audioPath': audioFilePath, // 音声ファイルのパスを保存
    };

    await DatabaseHelper().insertItem(newItem);
    print('Saved item: $newItem'); // デバッグメッセージ
  }

  Future<void> _synthesizeAudio(String text) async {
    final azureTtsKey = dotenv.env['AZURE_TTS_KEY'] ?? '';
    final azureTtsRegion = dotenv.env['AZURE_TTS_REGION'] ?? '';

    if (azureTtsKey.isNotEmpty && azureTtsRegion.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(
              'https://$azureTtsRegion.tts.speech.microsoft.com/cognitiveservices/v1'),
          headers: {
            'Ocp-Apim-Subscription-Key': azureTtsKey,
            'Content-Type': 'application/ssml+xml',
            'X-Microsoft-OutputFormat': 'audio-16khz-32kbitrate-mono-mp3',
          },
          body:
              '''<speak version='1.0' xml:lang='en-US'><voice xml:lang='en-US' xml:gender='Male' name='en-US-ChristopherNeural'>$text</voice></speak>''',
        );

        if (response.statusCode == 200) {
          final audioBytes = response.bodyBytes;
          final tempDir = await getTemporaryDirectory();
          final file = await File('${tempDir.path}/tts.mp3').create();
          await file.writeAsBytes(audioBytes);

          if (mounted) {
            setState(() {
              audioFilePath = file.path;
            });
          }
        } else {
          print('Error: ${response.statusCode} ${response.reasonPhrase}');
        }
      } catch (e) {
        print("Error synthesizing or playing audio: $e");
      }
    }
  }

  Future<void> _fetchDataJapanese() async {
    Stream<ChatResponseSSE> stream = openAI.onChatCompletionSSE(
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

    await for (var event in stream) {
      final text = event.choices?.last.message?.content ?? '';
      if (mounted) {
        setState(() {
          textJapanese = textJapanese + text;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text('テーマ: ' + widget.themeText),
                  Text('語数: ${widget.dropdownValueLength}'),
                  Text('レベル: ${widget.dropdownValueLevel}'),
                  Text('文章スタイル: ${widget.dropdownValueStyle}'),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText(
                    textEnglish,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  if (showTranslateButton3)
                    SelectableText(
                      textJapanese,
                      style: TextStyle(fontSize: 20),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: isSavingEnabled
                      ? () {
                          _saveGeneratedText(textEnglish);
                        }
                      : null, // 無効なときは何もしない
                  child: Text('文章を保存する'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showTranslateButton3 = true;
                    });
                    print(textJapanese);
                  },
                  child: Text('訳を表示'),
                ),
                AudioPlayerWidget(audioFilePath: audioFilePath),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
