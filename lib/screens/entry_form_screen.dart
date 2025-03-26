import 'package:flutter/material.dart';
import '../utils/network_helper.dart';
import '../widgets/common_footer.dart';

class EntryFormScreen extends StatefulWidget {
  final Map<String, dynamic> schema;
  final String apiKey;
  final String createUrl;
  final dynamic editData;

  const EntryFormScreen({
    required this.schema,
    required this.apiKey,
    required this.createUrl,
    this.editData,
    Key? key,
  }) : super(key: key);

  @override
  _EntryFormScreenState createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formValues;
  bool _isSubmitting = false;
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
    _initializeForm();
  }

  void _initializeForm() {
    final fields = Map<String, dynamic>.from(widget.schema['model']['fields'])
      ..remove('id');
    _formValues = {};
    fields.forEach((key, value) {
      _formValues[key] = widget.editData?[key] ?? null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fields = Map<String, dynamic>.from(widget.schema['model']['fields'])
      ..remove('id');
    final options = widget.schema['model']['options'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editData == null ? 'New Entry' : 'Edit Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ...fields.entries.map((entry) {
                return _buildFormField(
                  fieldName: entry.key,
                  fieldType: entry.value,
                  options: options[entry.key],
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitForm,
        child: const Icon(Icons.check),
      ),
      bottomNavigationBar: CommonFooter(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildFormField({
    required String fieldName,
    required String fieldType,
    dynamic options,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _getInputField(fieldType, fieldName, options),
        ],
      ),
    );
  }

  Widget _getInputField(String type, String fieldName, dynamic options) {
    switch (type) {
      case 'text':
        return TextFormField(
          initialValue: _formValues[fieldName]?.toString(),
          decoration: InputDecoration(
            hintText: 'Enter $fieldName',
            border: const OutlineInputBorder(),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Required field' : null,
          onSaved: (value) => _formValues[fieldName] = value,
        );
      case 'long_text':
        return TextFormField(
          initialValue: _formValues[fieldName]?.toString(),
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter $fieldName',
            border: const OutlineInputBorder(),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Required field' : null,
          onSaved: (value) => _formValues[fieldName] = value,
        );
      case 'number_decimal':
        return TextFormField(
          initialValue: _formValues[fieldName]?.toString(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter $fieldName',
            border: const OutlineInputBorder(),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Required field' : null,
          onSaved: (value) =>
              _formValues[fieldName] = double.parse(value ?? '0'),
        );
      case 'options':
        return DropdownButtonFormField(
          value: _formValues[fieldName],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Select $fieldName',
          ),
          items: (options as List<dynamic>?)?.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value.toString()),
            );
          }).toList(),
          validator: (value) =>
              value == null ? 'Please select an option' : null,
          onChanged: (value) => _formValues[fieldName] = value,
        );
      default:
        return Text('Unsupported field type: $type');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    _formKey.currentState!.save();
    try {
      if (widget.editData == null) {
        await _networkHelper.post(
          widget.createUrl,
          _formValues,
          apiKey: widget.apiKey,
        );
      } else {
        final updateAction = widget.schema['action']?.firstWhere(
          (action) => action['type'] == 'UPDATE',
          orElse: () => null,
        );
        if (updateAction != null) {
          final url =
              updateAction['url'].replaceAll('{{id}}', widget.editData['id']);
          await _networkHelper.put(url, _formValues, widget.apiKey);
        }
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
