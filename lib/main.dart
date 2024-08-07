import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'second_page.dart';
import 'setting_page.dart'; // SettingsPageをインポート
import 'list_page.dart'; // ListPageをインポート
import 'custom_dropdown.dart'; // CustomDropdownをインポート
import 'items.dart'; // itemsをインポート
import 'database_helper.dart'; // DatabaseHelperをインポート
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_lib; // エイリアスを付ける

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TopPage(),
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 71, 185, 198),
          titleTextStyle:
              TextStyle(color: Color.fromARGB(255, 25, 25, 25), fontSize: 20),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}

class TopPage extends StatefulWidget {
  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  int _currentIndex = 0;
  String dropdownValueLength = itemsLength.first;
  String dropdownValueLevel = itemsLevel.first;
  String dropdownValueStyle = itemsStyle.first;

  final TextEditingController _controllerTheme = TextEditingController();
  bool isButtonEnabled = false;

  void _checkIfButtonShouldBeEnabled() {
    setState(() {
      isButtonEnabled = _controllerTheme.text.isNotEmpty;
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _controllerTheme.addListener(_checkIfButtonShouldBeEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      _buildMainContent(),
      ListPage(), // ListPageウィジェットを使用
      SettingsPage(), // SettingsPageウィジェットを使用
    ];

    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
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
              TextField(
                controller: _controllerTheme,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'お好きなテーマ',
                ),
                onChanged: (text) {
                  _checkIfButtonShouldBeEnabled();
                },
              ),
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
              ElevatedButton(
                onPressed: isButtonEnabled
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => SecondPage(
                              themeText: _controllerTheme.text,
                              dropdownValueLength: dropdownValueLength,
                              dropdownValueLevel: dropdownValueLevel,
                              dropdownValueStyle: dropdownValueStyle,
                            ),
                          ),
                        );
                      }
                    : null, // 無効なときは何もしない
                child: Text('生成する'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
