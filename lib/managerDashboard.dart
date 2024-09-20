import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

//const String _baseUrl='http://192.168.1.118:8001';
const String _baseUrl = '192.168.1.118:8001';

EncryptedSharedPreferences _encryptedData= EncryptedSharedPreferences();

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _controllerMID = TextEditingController();
  TextEditingController _controllerEID = TextEditingController();
  TextEditingController _controllerContent = TextEditingController();
  TextEditingController _controllerDueDate = TextEditingController();
  bool _loading = false;


  @override
  void dispose() {
    _controllerMID.dispose();    /// controller.dispose();
    _controllerEID.dispose();  /// controller.dispose();
    _controllerContent.dispose();
    _controllerDueDate.dispose();

    super.dispose();
  }

  void update(String text){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    setState(() {
      _loading=false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manager"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            _encryptedData.remove('myKey').then((success)=>
                Navigator.of(context).pop());
          },
              icon: Icon(Icons.logout))
        ],


      ),
      body: Center( child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10,),
            /// P I D
            SizedBox(width: 200, child: TextFormField(controller: _controllerMID, /// ////////////controller
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Your ID'
              ),
              validator: (String? value){
                if(value==null || value.isEmpty){
                  return 'Please enter Your id';
                }
                return null;
              },
            ),),
            /// n a m e
            SizedBox(width: 200, child: TextFormField(controller: _controllerEID, /// ////////////controller
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Employee's ID"
              ),
              validator: (String? value){
                if(value==null || value.isEmpty){
                  return 'Please enter the employee id';
                }
                return null;
              },
            ),),
            /// C o n t e n t
            const SizedBox(height: 10,),
            SizedBox(width: 300, child: TextFormField(controller: _controllerContent,  /// ////////////
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Task Content',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the content';
                }
                return null;
              },
            )),
            /// P R I C E
            const SizedBox(height: 10,),
            SizedBox(width: 200, child: TextFormField(controller: _controllerDueDate,
              keyboardType: TextInputType.text,/// ////////////
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Due Date',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter due date';
                }
                return null;
              },
            )),

            ///
            ///
            ///
            const SizedBox(height: 10,),
            ElevatedButton(onPressed: _loading ? null : (){
              if(_formKey.currentState!.validate()){
                setState(() {
                  _loading= true;
                });
                saveTask(update, int.parse(_controllerMID.text.toString()),int.parse(_controllerEID.text.toString()),
                    _controllerContent.text.toString(), DateTime.parse(_controllerDueDate.text.toString())); /// ////////////////////////////////
              }
            }, child: const Text('Submit'),),
            const SizedBox(height: 10,),
            Visibility(visible: _loading, child: const CircularProgressIndicator())
          ],
        ),
      )
      ),
    );
  }
}


void saveTask(Function(String text) update, int mid, int eid, String content, DateTime DueDate)async{
  try{
    String myKey= await _encryptedData.getString('myKey');
    // send json object
    final response = await http.post(
        Uri.https(_baseUrl,'addTask.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'mid': '$mid', 'eid': '$eid', 'content': content, 'DueDate': '$DueDate', 'key': myKey
        })).timeout(const Duration(seconds: 5));
    if(response.statusCode==200){
      update(response.body);
    }
  }
  catch(e){
    update("connection error");
  }

}


