import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/network_helper.dart';
import '../screens/module_detail_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/common_footer.dart';

class DescriptionScreen extends StatefulWidget {
  final String appName;
  final String connectionName;
  final int connectionId;
  final String logoDark;
  final String apiKey;

  const DescriptionScreen({
    super.key,
    required this.appName,
    required this.connectionName,
    required this.connectionId,
    required this.logoDark,
    required this.apiKey,
  });

  @override
  _DescriptionScreenState createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  List<Map<String, dynamic>> modules = [];
  var _selectedIndex = 0;
  final NetworkHelper _networkHelper =
      NetworkHelper('https://api.ioak.io:8100/api/portal');
  final TextEditingController _apiKeyController = TextEditingController();
  String apiKey = '';

  @override
  void initState() {
    super.initState();
    apiKey = _apiKeyController.text;
    fetchModules(widget.apiKey);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  Future<void> fetchModules(String apiKey) async {
    try {
      final response = await _networkHelper.get('/schema/module', apiKey);
      if (response.isNotEmpty) {
        setState(() {
          modules = List<Map<String, dynamic>>.from(response);
        });
      } else {
        print('Failed to fetch modules');
      }
    } catch (e) {
      print('Error fetching modules: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modules List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: modules.isEmpty
            ? const Center(child: Text("No modules found"))
            : ListView.builder(
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  final displayName =
                      module['displayName'] ?? 'No Display Name';
                  final description = module['description'] ?? 'No Description';
                  final logoDark = module['icon']?['dark'] ??
                      'https://via.placeholder.com/150';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModuleDetailScreen(
                            moduleName: module['name'],
                            apiKey: widget.apiKey,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.red,
                                  child: ClipOval(
                                    child: SvgPicture.network(
                                      logoDark,
                                      width: 114,
                                      height: 114,
                                      placeholderBuilder: (context) =>
                                          Container(
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
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        description,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: CommonFooter(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
