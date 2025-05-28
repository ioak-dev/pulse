import 'package:flutter/material.dart';
import '../utils/network_helper.dart';
import '../widgets/common_footer.dart';
import 'entry_form_screen.dart';
import '../styles/colors.dart';

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

        // Extract category and tagId mappings
        final categoryOptions =
            _schema['domain']?['options']?['category'] ?? [];
        final tagOptions = _schema['domain']?['options']?['tagId'] ?? [];

        _categoryMap = {
          for (var option in categoryOptions) option['id']: option['name']
        };

        _tagMap = {for (var option in tagOptions) option['id']: option['name']};
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
          widget.moduleName.toUpperCase(),
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
    for (var item in _listData) {
      final rawDate = item['billDate'] ?? 'Unknown Date';
      String date = rawDate;
      try {
        final parts = rawDate.split('-');
        if (parts.length == 3) {
          date = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      } catch (_) {
        date = rawDate;
      }
      if (!groupedData.containsKey(date)) {
        groupedData[date] = [];
      }
      groupedData[date]!.add(item);
    }
    return groupedData;
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
                  Text(
                    _formatDate(item['billDate']?.toString()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
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
