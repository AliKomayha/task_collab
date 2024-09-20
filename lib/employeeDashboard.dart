import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'task.dart';

EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  late TextEditingController _userIdController;
  bool _load = false;

  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int? userId = ModalRoute.of(context)?.settings.arguments as int?;
    
    if (userId != null) {
      _userIdController.text = userId.toString();
      updateTasks(update, _userIdController.text.toString());
    } else {
      print("Error: User ID not found");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user ID')),
      );
    }
  }

  void update(bool success) {
    setState(() {
      _load = true;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load tasks')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _load
                ? null
                : () {
                    setState(() {
                      _load = true; //editted
                      updateTasks(update, _userIdController.text);
                    });
                  },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              _encryptedData.remove('myKey').then((success) {
                if (success) {
                  Navigator.of(context).pop();
                }
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _load
          ? const ShowTasks()
          : const Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
