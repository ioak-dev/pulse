import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/db_helper.dart';
import '../widgets/common_footer.dart';
import '../styles/colors.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDarkerColor), // Change icon and color
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Connections"),
        titleTextStyle: const TextStyle(
            color: AppColors.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: "Roboto"
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(15),
          child: Container(
            color: Colors.grey,
            height: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.primaryDarkerColor),
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
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keeps content centered
          children: [
            const Text(
              'No connections found.',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color:  AppColors.primaryColor,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Colors.white, // Icon color
                ),
                onPressed: () => Navigator.pushNamed(context, '/createConnection')
                    .then((_) => refreshItems()
                ),
              ),
            ),
          ],
        ),
      )
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

                return
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor, width: 0.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          // First Row - Top Right Menu Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,

                            children: [
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: AppColors.primaryDarkerColor,
                                ),
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
                                    child: Text('Edit',style: TextStyle(color: AppColors.primaryColor)),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete',style: TextStyle(color: AppColors.primaryColor)),
                                  ),
                                ],
                              ),
                            ],
                          ),


                          Row(
                            children: [
                              // First Column (SVG Image - 30% Width)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: AppColors.borderColor,
                                ),
                                child: SvgPicture.network(
                                  logoDark,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                  placeholderBuilder: (context) => Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.red[50],
                                    child: const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16), // Space between columns

                              // Second Column - Title, Description, and Open Button
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // First row - Title
                                    Text(
                                      connectionName,
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),

                                    // Second row - App Name & Description
                                    Text(
                                      appName,
                                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      description,
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 10), // Space before Open button

                                    // Third row - Open Button aligned to right
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => _openConnection(
                                          context,
                                          connectionName,
                                          appName,
                                          connectionId,
                                          logoDark,
                                        ),
                                        style: TextButton.styleFrom(
                                          side: const BorderSide(
                                              color: AppColors.primaryColor, width: 1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                        ),
                                        child: const Text(
                                          "Open",
                                          style:
                                          TextStyle(fontSize: 16, color: AppColors.primaryColor),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
