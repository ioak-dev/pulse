import 'package:flutter/material.dart';
import '../model/item.dart';
import '../utils/db_helper.dart';
import '../utils/network_helper.dart';
import 'home_screen.dart';
import 'description_screen.dart';
import '../widgets/common_footer.dart';
import '../styles/colors.dart';

class CreateConnection extends StatefulWidget {
  final Item? item;

  const CreateConnection({Key? key, this.item}) : super(key: key);

  @override
  _CreateConnectionScreenState createState() => _CreateConnectionScreenState();
}

class _CreateConnectionScreenState extends State<CreateConnection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _connectionNameController =
      TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  String? _selectedAppName;
  int _selectedIndex = 0;
  final NetworkHelper _networkHelper =
      NetworkHelper('https://api.ioak.io:8100/api/portal');

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _selectedAppName = widget.item!.appName;
      _connectionNameController.text = widget.item!.connectionName;
      _apiKeyController.text = widget.item!.apiKey;
    }
  }

  Future<Map<String, dynamic>?> createConnectionService(String apiKey) async {
    try {
      final response = await _networkHelper.get('/schema', apiKey);
      print('Response: $response');
      return response;
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  void _handleCreateConnection() async {
    try {
      String appName = _selectedAppName ?? "";
      String connectionName = _connectionNameController.text;
      String apiKey = _apiKeyController.text;

      if (_formKey.currentState!.validate()) {
        final response = await createConnectionService(apiKey);
        if (response != null) {
          final item = Item(
            id: widget.item?.id,
            appName: appName,
            connectionName: connectionName,
            apiKey: apiKey,
            displayName: response['displayName'],
            description: response['description'],
            logoDark: response['logo']['dark'],
            logoLight: response['logo']['light'],
          );

          if (widget.item == null) {
            await DBHelper.instance.insertItem(item.toMap());
          } else {
            await DBHelper.instance.updateItem(item.toMap(), widget.item!.id!);
          }

          Navigator.pushNamed(
            context,
            '/description',
            arguments: {
              'appName': item.appName,
              'connectionName': item.connectionName,
              'connectionId': item.id ?? 0,
              'logoDark': item.logoDark,
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Authorization failed or no response')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter all fields')),
        );
      }
    } catch (e) {
      print("Error in _handleCreateConnection: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Connection"),
        automaticallyImplyLeading: false,
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

      ),
      body: Center(
    child: Container(
      margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child:Padding(
        padding: const EdgeInsets.fromLTRB(16, 25, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedAppName,
                decoration: const InputDecoration(
                  labelText: "App name",
                  border: OutlineInputBorder(
                      borderRadius:BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
                  ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: AppColors.primaryColor, width: 1), // Default border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.blue, width: 1), // Border when focused
                    )
                ),
                items: const [
                  DropdownMenuItem(value: "App1", child: Text("App1")),
                  DropdownMenuItem(value: "App2", child: Text("App2")),
                  DropdownMenuItem(value: "App3", child: Text("App3")),
                  DropdownMenuItem(value: "Fortuna", child: Text("Fortuna")),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAppName = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select an app" : null,
              ),
              const SizedBox(height: 50),
              TextFormField(
                controller: _connectionNameController,
                decoration: const InputDecoration(
                  labelText: "Connection name",
                  border: OutlineInputBorder(
                    borderRadius:BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
                  ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: AppColors.primaryColor, width: 1), // Default border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.blue, width: 1), // Border when focused
                    )
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter a connection name"
                    : null,
              ),
              const SizedBox(height: 50),
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: "Api key",
                  border: OutlineInputBorder(
                    borderRadius:BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: AppColors.primaryColor,
                        style:BorderStyle.solid, width: 1),
                  ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: AppColors.primaryColor, width: 1), // Default border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.blue, width: 1), // Border when focused
                    )
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter an API key"
                    : null,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      )
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreateConnection,
        backgroundColor:Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.primaryColor, width: 2), // Border color and width
        ),
        child: const Icon(Icons.check, color:AppColors.primaryColor),
      ),
      bottomNavigationBar: CommonFooter(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
