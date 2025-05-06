import 'package:flutter/material.dart';
import '../utils/network_helper.dart';
import '../widgets/common_footer.dart';
import 'entry_form_screen.dart';

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
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToEntryForm(context, null),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: CommonFooter(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null)
      return Center(child: Text('Error: $_errorMessage'));
    if (_listData.isEmpty) return const Center(child: Text('No records found'));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: _buildDataColumns(),
        rows: _buildDataRows(),
      ),
    );
  }

  List<DataColumn> _buildDataColumns() {
    return [
      const DataColumn(label: Text('Name')),
      const DataColumn(label: Text('Tag')),
      const DataColumn(label: Text('Category')),
      const DataColumn(label: Text('Price')),
      const DataColumn(label: Text('Date')),
      const DataColumn(label: Text('Actions')),
    ];
  }

  List<DataRow> _buildDataRows() {
    return _listData.map<DataRow>((item) {
      final cells = [
        // Name (description field)
        DataCell(Text(item['description'] ?? '')),

        // Tag (mapped from tagId)
        DataCell(Text(
          (item['tagId'] as List<dynamic>?)
                  ?.map((tagId) => _tagMap[tagId] ?? tagId.toString())
                  .join(', ') ??
              '',
        )),

        // Category (mapped from category)
        DataCell(
            Text(_categoryMap[item['category']] ?? item['category'] ?? '')),

        // Price (amount field)
        DataCell(Text(item['amount']?.toString() ?? '')),

        // Date (billDate field)
        DataCell(Text(item['billDate'] ?? '')),

        // Actions (edit and delete)
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleAction(value, item),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
      ];

      return DataRow(cells: cells);
    }).toList();
  }

  void _handleAction(String action, dynamic item) async {
    if (action == 'edit') {
      _navigateToEntryForm(context, item); // Pass item for editing
    } else if (action == 'delete') {
      await _deleteItem(item['_id']);
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      final deleteAction = _schema['endpoints']?.firstWhere(
        (action) => action['type'] == 'DELETE',
        orElse: () => null,
      );

      if (deleteAction != null) {
        final url = deleteAction['url'].replaceAll('{{id}}', id);

        // Debugging: Log the URL to verify correctness
        debugPrint('DELETE Request URL: $url');

        await _networkHelperLng.delete(
          url,
          widget.apiKey, // Use apiKey
        );
        _loadModuleData();
      } else {
        throw Exception('DELETE action not found in schema');
      }
    } catch (e) {
      debugPrint(
          'Error during DELETE request: $e'); // Log the error for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
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
