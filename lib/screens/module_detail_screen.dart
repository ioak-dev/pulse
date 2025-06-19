import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../utils/network_helper.dart';
import '../widgets/common_footer.dart';
import 'entry_form_screen.dart';
import '../styles/colors.dart';

// Extension to add 'capitalize' method to String
extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class ModuleDetailScreen extends StatefulWidget {
  final String moduleName;
  final String apiKey;

  const ModuleDetailScreen({
    required this.moduleName,
    required this.apiKey,
    Key? key,
  }) : super(key: key);

  @override
  _ModuleDetailScreenState createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  // Static color array with 10 values
  static const List<Map<String, dynamic>> categoryColorArray = [
    {'labelColor': Color(0xFFE1F5FE), 'bgColor': Color(0xFF0288D1)},
    {'labelColor': Color(0xFFE3F2FD), 'bgColor': Color(0xFFD32F2F)},
    {'labelColor': Color(0xFFFFEBEE), 'bgColor': Color(0xFF1976D2)},
    {'labelColor': Color(0xFFF3E5F5), 'bgColor': Color(0xFF8E24AA)},
    {'labelColor': Color(0xFFFFF8E1), 'bgColor': Color(0xFFFFA000)},
    {'labelColor': Color(0xFFFFF3E0), 'bgColor': Color(0xFFF57C00)},
    {'labelColor': Color(0xFFE8F5E9), 'bgColor': Color(0xFF388E3C)},
    {'labelColor': Color(0xFFFFFDE7), 'bgColor': Color(0xFFFBC02D)},
    {'labelColor': Color(0xFFF5F5F5), 'bgColor': Color(0xFF757575)},
    {'labelColor': Color(0xFFE0F2F1), 'bgColor': Color(0xFF00897B)},
  ];

  late Map<String, dynamic> _schema;
  List<dynamic> _listData = [];
  bool _isLoading = true;
  String? _errorMessage;
  var _selectedIndex = 0;
  final NetworkHelper _networkHelper =
      NetworkHelper('https://api.ioak.io:8100/api/portal');
  final NetworkHelper _networkHelperLng =
      NetworkHelper('https://api.ioak.io:8100');

  Map<String, String> _categoryMap = {};
  Map<String, String> _tagMap = {};
  Map<String, Map<String, dynamic>> _categoryColorMap = {};

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamed(context, '/');
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    _loadModuleData();
  }

  Future<void> _loadModuleData() async {
    setState(() => _isLoading = true);
    try {
      final schemaResponse = await _networkHelper.get(
        '/schema/module/${widget.moduleName}',
        widget.apiKey, // Use apiKey
      );

      if (schemaResponse == null) throw Exception('Failed to load schema');

      setState(() {
        _schema = schemaResponse;

        // Extract and sort category names alphabetically
        final categoryOptions =
            List.from(_schema['domain']?['options']?['category'] ?? [])
              ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
        final tagOptions = _schema['domain']?['options']?['tagId'] ?? [];

        _categoryMap = {
          for (var option in categoryOptions) option['id']: option['name']
        };

        // Map sorted category names to color array by index
        final sortedCategoryNames = categoryOptions.map((c) => c['name'] as String).toList();
        _categoryColorMap = {
          for (int i = 0; i < sortedCategoryNames.length; i++)
            sortedCategoryNames[i]: categoryColorArray[i % categoryColorArray.length]
        };
      });

      final listAction = _schema['endpoints']?.firstWhere(
        (action) => action['type'] == 'LIST',
        orElse: () => null,
      );

      if (listAction != null) {
        final listResponse = await _networkHelperLng.get(
          listAction['url'],
          widget.apiKey, // Use apiKey
        );

        setState(() {
          _listData = List<dynamic>.from(listResponse ?? []);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  String _ordinalDay(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.moduleName.capitalize(),
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: "Roboto"
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2), // Semi-transparent overlay
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEntryForm(context, null),
        backgroundColor:Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.primaryColor, width: 2), // Border color and width
        ),
        child: const Icon(Icons.add, color:AppColors.primaryColor),
      ),
      bottomNavigationBar: CommonFooter(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text('Error: $_errorMessage'));
    if (_listData.isEmpty) return const Center(child: Text('No records found'));

    final groupedData = _groupDataByDate();

    return ListView.builder(
      itemCount: groupedData.length,
      itemBuilder: (context, index) {
        final date = groupedData.keys.elementAt(index);
        final items = groupedData[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                date,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            ...items.map((item) => _buildListItem(item)).toList(),
          ],
        );
      },
    );
  }

  Map<String, List<dynamic>> _groupDataByDate() {
    final Map<String, List<dynamic>> groupedData = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    for (var item in _listData) {
      final rawDate = item['billDate'] ?? 'Unknown Date';
      String groupLabel = rawDate;
      try {
        final parts = rawDate.split('-');
        if (parts.length == 3) {
          final year = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final day = int.tryParse(parts[2]);
          if (year != null && month != null && day != null) {
            final itemDate = DateTime(year, month, day);
            if (itemDate == today) {
              groupLabel = 'Today';
            } else if (itemDate == yesterday) {
              groupLabel = 'Yesterday';
            } else {
              final label = timeago.format(itemDate, locale: 'en');
              String dateStr = '${_ordinalDay(itemDate.day)} ${_monthName(itemDate.month)}';
              String dateStrWithYear = '$dateStr ${itemDate.year}';
              if (itemDate.year == today.year) {
                groupLabel = '${_capitalize(label)} - $dateStr';
              } else {
                groupLabel = '${_capitalize(label)} - $dateStrWithYear';
              }
            }
          }
        }
      } catch (_) {
        groupLabel = rawDate;
      }
      if (!groupedData.containsKey(groupLabel)) {
        groupedData[groupLabel] = [];
      }
      groupedData[groupLabel]!.add(item);
    }
    return groupedData;
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Widget _buildListItem(dynamic item) {
    return GestureDetector(
      onTap: () => _navigateToEntryForm(context, item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['description'] ?? 'No Description',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (item['category'] != null && _categoryMap[item['category']] != null)
                    _buildCategoryPill(_categoryMap[item['category']]),
                ],
              ),
            ),
            Text(
              '₹${item['amount']?.toString() ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String? catName) {
    if (catName == null) return const SizedBox.shrink();
    final catColor = _categoryColorMap[catName];
    if (catColor == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: catColor['bgColor'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: catColor['labelColor'], width: 1),
      ),
      child: Text(
        catName,
        style: TextStyle(
          color: catColor['labelColor'],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _navigateToEntryForm(BuildContext context, dynamic item) {
    if (_schema == null || _schema['endpoints'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schema not loaded yet!')),
      );
      return;
    }

    final createAction = _schema['endpoints']?.firstWhere(
      (action) => action['type'] == 'CREATE',
      orElse: () => null,
    );

    if (createAction != null) {
      try {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => EntryFormScreen(
              schema: _schema,
              apiKey: widget.apiKey, // Use apiKey
              createUrl: createAction['url'],
              editData: item,
            ),
          ),
        )
            .then((_) {
          debugPrint("Returned from EntryFormScreen, reloading data...");
          _loadModuleData();
        }).catchError((error, stackTrace) {
          debugPrint("Error navigating to EntryFormScreen: $error");
          debugPrint("StackTrace: $stackTrace");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigation Error: $error')),
          );
        });
      } catch (error, stackTrace) {
        debugPrint("Caught error during navigation: $error");
        debugPrint("StackTrace: $stackTrace");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected Error: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create action not found!')),
      );
    }
  }
}
