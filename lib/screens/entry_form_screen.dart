import 'package:flutter/material.dart';
import '../utils/network_helper.dart';
import '../widgets/common_footer.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

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
      NetworkHelper('https://api.ioak.io:8100');

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
    final fields = Map<String, dynamic>.from(widget.schema['domain']['fields'])
      ..remove('id');
    _formValues = {};
    fields.forEach((key, value) {
      _formValues[key] = widget.editData?[key] ?? null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fields = Map<String, dynamic>.from(widget.schema['domain']['fields'])
      ..remove('id');
    final options = widget.schema['domain']['options'] as Map<String, dynamic>;

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
          items: (options as List<dynamic>?)?.map((option) {
            return DropdownMenuItem(
              value: option['id'],
              child: Text(option['name']),
            );
          }).toList(),
          validator: (value) =>
              value == null ? 'Please select an option' : null,
          onChanged: (value) => _formValues[fieldName] = value,
        );
      case 'options_multi':
        return MultiSelectChipField(
          items: (options as List<dynamic>?)
              ?.map((option) => MultiSelectItem(option['id'], option['name']))
              .toList() ?? [],
          initialValue: _formValues[fieldName] ?? [],
          title: Text('Select $fieldName'),
          headerColor: Colors.blue.withOpacity(0.5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
          ),
          onTap: (values) => _formValues[fieldName] = values,
        );
      case 'date':
        return TextFormField(
          controller: TextEditingController(
            text: _formValues[fieldName]?.toString(),
          ),
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Select $fieldName',
            border: const OutlineInputBorder(),
          ),
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              setState(() {
                _formValues[fieldName] =
                    "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
              });
            }
          },
        );
      case 'null':
        return const SizedBox.shrink(); // No input field for null type
      default:
        return const SizedBox.shrink(); // Ignore unsupported types
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    _formKey.currentState!.save();

    // Ensure null type fields are explicitly set to "null" as a string
    final fields = Map<String, dynamic>.from(widget.schema['domain']['fields']);
    fields.forEach((key, value) {
      if (value == 'null') {
        _formValues[key] = "null"; // Ensure "null" is sent as a string
      }
    });

    // Convert tagId to an array of strings if it exists
    if (_formValues.containsKey('tagId') && _formValues['tagId'] is List) {
      _formValues['tagId'] = (_formValues['tagId'] as List)
          .map((tag) => tag.toString())
          .toList();
    }

    // Debugging: Log the final payload
    debugPrint('Final Payload: $_formValues');

    try {
      if (widget.editData == null) {
        debugPrint('POST Request Payload: $_formValues');
        try {
          final response = await _networkHelper.post(
            widget.createUrl,
            _formValues,
            apiKey: widget.apiKey, // Use apiKey
          );
          debugPrint('POST Response: ${response.toString()}');
        } catch (e) {
          debugPrint('POST Error: $e');
        }
      } else {
        final updateAction = widget.schema['endpoints']?.firstWhere(
          (action) => action['type'] == 'UPDATE',
          orElse: () => null,
        );
        if (updateAction != null) {
          final id = widget.editData?['_id'] ?? 'default-id'; // Use a default placeholder if id is null
          if (id == 'default-id') {
            debugPrint('Warning: editData["id"] is null. Using default placeholder ID.');
          }

          final url = updateAction['url'].replaceAll('{{id}}', id);
          debugPrint('PUT Request URL: $url');
          debugPrint('PUT Request Payload: $_formValues');
          debugPrint('PUT API Key: ${widget.apiKey}'); // Log API key for debugging
          try {
            final response = await _networkHelper.put(
              url,
              _formValues,
              widget.apiKey, // Use apiKey
            );
            debugPrint('PUT Response: $response');
          } catch (e) {
            debugPrint('PUT Error: $e');
          }
        }
      }
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('General Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
