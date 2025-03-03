import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/db_helper.dart';
import '../widgets/common_footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> items = [];
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    refreshItems();
  }

  Future<void> refreshItems() async {
    final data = await DBHelper.instance.fetchAllItems();
    setState(() {
      items = data;
    });
  }

  void _openConnection(
    BuildContext context,
    String connectionName,
    String appName,
    int connectionId,
    String logoDark,
  ) {
    Navigator.pushNamed(
      context,
      '/description',
      arguments: {
        'appName': appName,
        'connectionName': connectionName,
        'connectionId': connectionId,
        'logoDark': logoDark,
      },
    );
  }

  void _deleteConnection(int id) async {
    await DBHelper.instance.deleteItem(id);
    refreshItems();
  }

  void _editConnection(Map<String, dynamic> item) {
    Navigator.pushNamed(
      context,
      '/createConnection',
      arguments: {
        'id': item['id'],
        'appName': item['appName'],
        'connectionName': item['connectionName'],
        'apiKey': item['apiKey'],
        'displayName': item['displayName'],
        'description': item['description'],
        'logoDark': item['logoDark'],
        'logoLight': item['logoLight'],
      },
    ).then((_) => refreshItems());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamed(context, '/');
    }
    // else if (index == 1) { ... }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connections"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'createConnection') {
                Navigator.pushNamed(context, '/createConnection')
                    .then((_) => refreshItems());
              }
            },
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem<String>(
                value: 'createConnection',
                child: Text('Create connection'),
              ),
            ],
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('No connections found.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 25.0),
              itemBuilder: (context, index) {
                final item = items[index];
                final connectionName = item['connectionName'] ?? '';
                final appName = item['appName'] ?? '';
                final connectionId = item['id'] ?? 0;
                final displayName = item['displayName'] ?? '';
                final description = item['description'] ?? '';
                final logoDark = item['logoDark'] ?? '';

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              connectionName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(appName, style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(displayName,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(description,
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -20,
                        left: 20,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.red,
                          child: ClipOval(
                            child: SvgPicture.network(
                              logoDark,
                              width: 114,
                              height: 114,
                              placeholderBuilder: (context) => Container(
                                width: 114,
                                height: 114,
                                color: Colors.red[50],
                                child: const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 0,
                        child: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editConnection(item);
                            } else if (value == 'delete') {
                              _deleteConnection(item['id']);
                            }
                          },
                          itemBuilder: (BuildContext context) => const [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton(
                          style: Theme.of(context)
                              .elevatedButtonTheme
                              .style
                              ?.copyWith(
                                shape: const WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                              ),
                          onPressed: () => _openConnection(
                            context,
                            connectionName,
                            appName,
                            connectionId,
                            logoDark,
                          ),
                          child: const Text('Open'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: CommonFooter(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
