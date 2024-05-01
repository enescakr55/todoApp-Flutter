import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddSubTask extends StatefulWidget {
  final String mainTaskId;
  const AddSubTask({super.key, required this.mainTaskId});

  @override
  State<AddSubTask> createState() => _AddSubTaskState();
}

class _AddSubTaskState extends State<AddSubTask> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String currentTaskId;
  @override
  void initState() {
    // TODO: implement initState
    currentTaskId = widget.mainTaskId;
    super.initState();
  }

  Future<DocumentReference<Object?>> createSubtask() async {
    String userId = _firebaseAuth.currentUser!.uid;
    CollectionReference subtaskCollection = _firestore
        .collection("todos")
        .doc(userId)
        .collection("todos")
        .doc(currentTaskId)
        .collection("subtasks");
    return subtaskCollection.add(
      {"subtaskData": subTaskData.text,
        "completed":false
      
      }
    );
  }

  TextEditingController subTaskData = TextEditingController();
  //TextEditingController subTaskDescription = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Alt Görev")),
      body: Row(children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Color.fromARGB(255, 252, 146, 116), width: 2.0))),
          width: MediaQuery.of(context).size.width * 0.95,
          child: Column(
            children: [
              Form(
                  child: Column(
                children: [
                  TextFormField(
                    controller: subTaskData,
                    decoration: const InputDecoration(
                        labelText: "Görev",
                        icon: Icon(Icons.task_alt_rounded,
                            color: Color.fromARGB(255, 255, 90, 90))),
                  ),
                  /*TextFormField(
                    controller: subTaskDescription,
                    decoration: const InputDecoration(
                        labelText: "Görev Açıklaması",
                        icon: Icon(Icons.task_alt_rounded,
                            color: Color.fromARGB(255, 255, 90, 90))),
                  ),*/
                  ElevatedButton(
                      onPressed: () {
                        createSubtask().then((value) =>
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Yeni alt görev eklendi"))));
                      },
                      child: const Text("Alt görev ekle"))
                ],
              )),
            ],
          ),
        )
      ]),
    );
  }
}
