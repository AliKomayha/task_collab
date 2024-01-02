import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'task.dart';


EncryptedSharedPreferences _encryptedData= EncryptedSharedPreferences();

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  late TextEditingController _usernameController;
  // String _text='';
  bool _load=false;

  @override
  void initState(){
    super.initState();
    // This is okay to stay here as it doesn't depend on context
    _usernameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String? username = ModalRoute.of(context)?.settings.arguments as String?;
    if(username != null) {
      _usernameController.text = username ?? ''; // Handle null case
      updateTasks(update, _usernameController.text);
    }else {
      // Handle the case when username is null, maybe navigate back or show error
      print("errorrr");
    }
  }

  void update(bool success){
    setState(() {
      _load=true;
      if(!success){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('failed to load data') ,));
      }

    });
  }
  // @override
  // void initState(){
  //   final username = ModalRoute.of(context)?.settings.arguments as String;
  //   _usernameController = TextEditingController(text: username);
  //   updateTasks(update,_usernameController.text);
  //   super.initState();
  //
  //
  // }

  // void update(bool success) {
  //   setState(() {
  //     if (success) {
  //       _load = true; // Set _load to true only when data is successfully loaded
  //     } else {
  //       // Handle the case when data loading fails
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text('Failed to load data'),
  //       ));
  //     }
  //   });
  // }
  // @override
  // void dispose(){
  //   _usernameController.dispose();
  //   super.dispose();
  // }
  // void update(String text){
  //   setState(() {
  //     _text= text;
  //   });
  // }



  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //
  //   // Access the username passed from the previous page
  //   final username = ModalRoute.of(context)?.settings.arguments as String;
  //   _usernameController = TextEditingController(text: username);
  //
  //   // You can call functions that depend on inherited widgets or context here
  //   updateTasks(update, _usernameController.text);
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Tasks"),
        centerTitle: true,

        actions: [

          IconButton(
              onPressed: !_load ? null: (){
                setState(() {
                  _load= false;
                  updateTasks(update,_usernameController.text);
                });
              },
              icon: const Icon(Icons.refresh) ),

          IconButton(onPressed: (){
            _encryptedData.remove('myKey').then((success)=>
                Navigator.of(context).pop());
          },
              icon: Icon(Icons.logout))
        ],

      ),


      body: _load ? ShowTasks() : const Center(
          child: SizedBox(width:100, height:100, child:CircularProgressIndicator())
      ),
    );
  }
}
