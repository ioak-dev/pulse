import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/db_helper.dart';
import '../widgets/common_footer.dart';
import '../styles/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> items = [];
  var _selectedIndex = 0;
  String _searchText = "";

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
    String logoLight,
  ) {
    Navigator.pushNamed(
      context,
      '/description',
      arguments: {
        'appName': appName,
        'connectionName': connectionName,
        'connectionId': connectionId,
        'logoDark': logoDark,
        'logoLight': logoLight,
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
      arguments: item,
    ).then((_) => refreshItems());
  }

  void _createConnection() {
    Navigator.pushNamed(context, '/createConnection')
        .then((_) => refreshItems());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Connections",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        // actions: <Widget>[
        //   IconButton(
        //     icon: const Icon(FontAwesomeIcons.plus),
        //     tooltip: 'Create Connection',
        //     onPressed: () =>
        //         Navigator.pushNamed(context, '/createConnection')
        //             .then((_) => refreshItems()),
        //   ),
        // ],
        // actions: [
        //   PopupMenuButton<String>(
        //     icon: const Icon(FontAwesomeIcons.ellipsisVertical, color: Colors.black87, size: 18),
        //     onSelected: (value) {
        //       if (value == 'createConnection') {
        //         Navigator.pushNamed(context, '/createConnection').then((_) => refreshItems());
        //       }
        //     },
        //     itemBuilder: (BuildContext context) => const [
        //       PopupMenuItem<String>(
        //         value: 'createConnection',
        //         child: Text('Create connection'),
        //       ),
        //     ],
        //   ),
        // ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FontAwesomeIcons.circleExclamation,
                      size: 40, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No connections found.',
                    style: GoogleFonts.poppins(
                        fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(FontAwesomeIcons.plus),
                    label: const Text("Create Connection"),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/createConnection')
                            .then((_) => refreshItems()),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search connections...",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.black45),
                      // prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass,
                      //     size: 16),
                      // suffixIcon: const Icon(FontAwesomeIcons.plus, size: 16),
                      suffixIcon: Icon(
                        _searchText.isNotEmpty
                            ? FontAwesomeIcons.magnifyingGlass
                            : FontAwesomeIcons.plus,
                        size: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                  // child: Row(
                  //   children: [
                  //     Expanded(
                  //       child: TextField(
                  //         onChanged: (value) {},
                  //         decoration: InputDecoration(
                  //           hintText: "Search connections...",
                  //           hintStyle: GoogleFonts.poppins(
                  //               fontSize: 14, color: Colors.black45),
                  //           prefixIcon: const Icon(
                  //               FontAwesomeIcons.magnifyingGlass,
                  //               size: 16),
                  //           suffixIcon: const Icon(
                  //               FontAwesomeIcons.plus,
                  //               size: 16),
                  //           filled: true,
                  //           fillColor: Colors.white,
                  //           contentPadding: const EdgeInsets.symmetric(
                  //               horizontal: 20, vertical: 12),
                  //           border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(30),
                  //             borderSide:
                  //                 const BorderSide(color: Colors.transparent),
                  //           ),
                  //           enabledBorder: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(30),
                  //             borderSide:
                  //                 const BorderSide(color: Colors.transparent),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     IconButton(
                  //       icon: Icon(Icons.add_link),
                  //       onPressed: _createConnection,
                  //     ),
                  //   ],
                  // )
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () => _openConnection(
                          context,
                          item['connectionName'],
                          item['appName'],
                          item['id'],
                          item['logoDark'],
                          item['logoLight'],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 16, 1, 16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade100,
                                  child: SvgPicture.network(
                                    item['logoLight'],
                                    fit: BoxFit.contain,
                                    placeholderBuilder: (context) =>
                                        const Icon(Icons.image),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['connectionName'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['appName'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['description'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20),
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _createConnection,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   shape: const CircleBorder(
      //     side: BorderSide(color: Colors.grey, width: 2),
      //   ),
      //   child: const Icon(FontAwesomeIcons.plus, color: AppColors.primaryColor),
      // ),
      bottomNavigationBar: CommonFooter(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
