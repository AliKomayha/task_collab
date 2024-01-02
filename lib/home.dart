import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'employeeDashboard.dart';
import 'managerDashboard.dart';

const String _baseUrl='taskcollab.000webhostapp.com';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controllerUsername =TextEditingController();
  final TextEditingController _controllerPassword= TextEditingController();
  final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

  void update({required bool success, String role=''}) {
    if (success) {
      // Check the user's role and navigate accordingly
      //final String role = _encryptedData.getString('userRole').toString() ?? '';

      if (role == 'manager') {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ManagerDashboard()),
        );
      } else if (role == 'employee') {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const EmployeeDashboard(),
            settings: RouteSettings(arguments: _controllerUsername.text)
          ),

        );
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('role')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect username or password')),
      );
    }
  }


  Future<void> checkLogin() async {
    final username = _controllerUsername.text.trim();
    final password = _controllerPassword.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and password are required')),
      );
    } else {
      // Assume your authentication API endpoint is "/login"
      //final url = Uri.parse("https://your-api-url.com/login");

      final url = Uri.https(_baseUrl, 'login.php');
      print('Request Body: ${json.encode({'username': username, 'password': password})}');
      final response = await http.post(
        url,
        body: {'username': username, 'password': password},

      );
      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success']) {
          //_encryptedData.setString('myKey', username);
          // _encryptedData.setString('userRole', responseData['role']);
          String role = responseData['data'][0]['role'];
          update(success: true, role: role);
          //update(true);
        } else {
          update(success: false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to the server')),
        );
      }
    }
  }

  void checkSavedData() async {
    final myKey = await _encryptedData.getString('myKey');
    if (myKey.isNotEmpty) {
      // Check the user's role and navigate accordingly
      final String role = _encryptedData.getString('userRole').toString() ?? '';

      if (role == 'manager') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ManagerDashboard()),
        );
      } else if (role == 'employee') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const EmployeeDashboard(),
              settings: RouteSettings(arguments: _controllerUsername.text)),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkSavedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log In"),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          children: [
            /// u s e r n a m e
            const SizedBox(height: 10,),
            SizedBox(width: 200,
            child: TextFormField(
              controller: _controllerUsername,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Username',
              ),
            ),),
            /// p a s s w o r d
            const SizedBox(height: 10,),
            SizedBox(width: 200,
              child: TextFormField(
                controller: _controllerPassword,

                decoration: const InputDecoration(

                  border: OutlineInputBorder(),
                  hintText: 'Enter Password',
                ),
              ),),


            const SizedBox(height: 10,),
            ElevatedButton(
              onPressed: checkLogin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
