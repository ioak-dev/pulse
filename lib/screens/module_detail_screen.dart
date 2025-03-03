import 'package:flutter/material.dart';
import '../network_helper.dart';
import '../widgets/common_footer.dart';

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
    _loadModuleData();
  }

  Future<void> _loadModuleData() async {
    try {
      final schemaResponse = await _networkHelper.get(
        '/schema/module/${widget.moduleName}',
        widget.apiKey,
      );

      if (schemaResponse == null) throw Exception('Failed to load schema');

      setState(() {
        _schema = schemaResponse;
      });

      final listAction = _schema['action']?.firstWhere(
        (action) => action['type'] == 'LIST',
        orElse: () => null,
      );

      if (listAction != null) {
        final listResponse = await _networkHelper.get(
          listAction['url'],
          widget.apiKey,
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
    final fields = Map<String, dynamic>.from(_schema['model']['fields'])
      ..remove('id');
    return fields.keys.map<DataColumn>((fieldName) {
      return DataColumn(label: Text(fieldName));
    }).toList()
      ..add(const DataColumn(label: Text('Actions')));
  }

  List<DataRow> _buildDataRows() {
    return _listData.map<DataRow>((item) {
      final fields = Map<String, dynamic>.from(_schema['model']['fields'])
        ..remove('id');

      final cells = fields.keys.map<DataCell>((fieldName) {
        return DataCell(Text(item[fieldName]?.toString() ?? ''));
      }).toList();

      cells.add(DataCell(
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleAction(value, item),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ));

      return DataRow(cells: cells);
    }).toList();
  }

  void _handleAction(String action, dynamic item) async {
    if (action == 'edit') {
      _navigateToEntryForm(context, item);
    } else if (action == 'delete') {
      await _deleteItem(item['id']);
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      final deleteAction = _schema['action']?.firstWhere(
        (action) => action['type'] == 'DELETE',
        orElse: () => null,
      );

      if (deleteAction != null) {
        final url = deleteAction['url'].replaceAll('{{id}}', id);
        await _networkHelper.delete(url, {'apiKey': widget.apiKey});
        _loadModuleData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  void _navigateToEntryForm(BuildContext context, dynamic item) {
    final createAction = _schema['action']?.firstWhere(
      (action) => action['type'] == 'CREATE',
      orElse: () => null,
    );

    if (createAction != null) {
      Navigator.pushNamed(
        context,
        '/entryForm',
        arguments: {
          'schema': _schema,
          'apiKey': widget.apiKey,
          'createUrl': createAction['url'],
          'editData': item,
        },
      ).then((_) => _loadModuleData());
    }
  }
}
