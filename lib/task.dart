import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


//const String _baseUrl='http://192.168.1.118:8001';
const String _baseUrl = '192.168.1.118:8001';

class Task{
   int _tid;
   String _mname;
   String _content;
   String _duedate;
   String _status;

   int get taskId => _tid;

   Task(this._tid, this._mname, this._content, this._duedate,
      this._status);

   @override
  String toString() {
    return """Task ID: $_tid
    From Manager: $_mname
    Task: $_content
    Due Date: $_duedate
    Task Status: $_status""";
  }
}

List <Task> _tasks =[];


/// update tasks
void updateTasks(Function(bool success) update, String userId) async {
  try {
    //final url = Uri.https(_baseUrl, 'getTasks.php', {'username': '$username'});
    final url = Uri.parse('$_baseUrl/api/employee-tasks');
    //final response = await http.get(url).timeout(const Duration(seconds: 5));
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: convert.jsonEncode({'id': userId}),  // Send the user ID in the body
    ).timeout(const Duration(seconds: 5));

    _tasks.clear();

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);

      if (jsonResponse != null && jsonResponse is List) {
        for (var row in jsonResponse) {

          Task p = Task(
              int.parse(row['tid']),
              row['mname'],
              row['content'],
              row['duedate'],
              row['status']

          );
          _tasks.add(p);
          //update(p.toString() as bool);
        }
        update(true);
      }else{
        // Handle the case where jsonResponse is not a list or is empty
        update(false);
        print("Received non-list type or empty list from API");
      }
      }
    else {
      // Handle non-200 responses
      update(false);
      print("Error with status code: ${response.statusCode}");
    }
  }
  catch (e) {
    update(false);
    print("error: $e");
  }
}
/// //
// Future<void> doneTask(int tid) async {
//   try {

//     final response = await http.post(
//         Uri.https(_baseUrl,'doneTask.php'),
//         headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//           },
//         body: convert.jsonEncode(<String, String>{
//         'tid': '$tid'
//         })).timeout(const Duration(seconds: 5));

//         }catch(e){

//   }

// }
Future<void> doneTask(int taskId) async {
  try {
    final url = Uri.parse('$_baseUrl/api/complete-task');  // Assuming a new endpoint for marking task complete
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: convert.jsonEncode({'task_id': taskId.toString()}),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      print("Task marked as done successfully");
    } else {
      print("Failed to mark task as done, status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error while marking task as done: $e");
  }
}

/// Show tasks
class ShowTasks extends StatelessWidget {
  const ShowTasks({super.key});

  @override
  Widget build(BuildContext context) {
    double width=MediaQuery.of(context).size.width;

    return ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) => Column(children:[
          const SizedBox(height: 10,),
          Container(
            color: index % 2 ==0 ? Colors.amber: Colors.cyan,
            padding: const EdgeInsets.all(5),
            width: width *0.9, child: Row( children: [
            SizedBox(width: width*0.15),
            Flexible(child: Text(_tasks[index].toString(), style: TextStyle(fontSize: width * 0.045))),
            IconButton(
                onPressed: (){
                  doneTask(_tasks[index]._tid);

                },
                icon: Icon(Icons.zoom_in)),
          ],),
          )

        ])
    );
  }
}
