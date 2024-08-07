import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'detail_page.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final items = await DatabaseHelper().fetchItems();
    print('Fetched items: $items'); // デバッグメッセージ

    if (items.isNotEmpty) {
      // 新しいリストを作成してソート
      List<Map<String, dynamic>> sortedItems = List.from(items);
      sortedItems.sort((a, b) {
        return b['id'].compareTo(a['id']); // IDを基準に降順にソート
      });

      if (mounted) {
        setState(() {
          _items = sortedItems;
        });
      }
    } else {
      print('No items fetched from database.'); // デバッグメッセージ
    }
  }

  Future<void> _deleteItem(BuildContext context, int id) async {
    await DatabaseHelper().deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Item deleted'),
    ));
    // リストの更新を反映するために再ビルド
    _fetchItems();
  }

  Future<void> _resetDatabase(BuildContext context) async {
    await DatabaseHelper().deleteAllItems();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('All items deleted'),
    ));
    // リストの更新を反映するために再ビルド
    _fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Texts'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _resetDatabase(context),
          ),
        ],
      ),
      body: _items.isEmpty
          ? Center(child: Text('No saved texts.'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Dismissible(
                  key: Key(item['id'].toString()),
                  onDismissed: (direction) {
                    _deleteItem(context, item['id']);
                    setState(() {
                      _items.removeAt(index);
                    });
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(item['theme'] ?? 'N/A'),
                    subtitle: Text(
                        'Date: ${item['date'] ?? 'N/A'}\nLevel: ${item['level'] ?? 'N/A'}\nLength: ${item['length'] ?? 'N/A'}\nStyle: ${item['style'] ?? 'N/A'}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(item: item),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
