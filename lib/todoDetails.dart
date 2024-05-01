import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/addSubTask.dart';

class TodoDetailsWidget extends StatefulWidget {
  final DocumentSnapshot<Object?> data;
  const TodoDetailsWidget({super.key, required this.data});

  @override
  State<TodoDetailsWidget> createState() => _TodoDetailsWidgetState();
}

class _TodoDetailsWidgetState extends State<TodoDetailsWidget> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late CollectionReference todos;
  late DocumentSnapshot<Object?> queryDocument;
  late bool isCompleted;
  late Stream<QuerySnapshot<Map<String, dynamic>>> subtasksStream;
  late CollectionReference subTaskList;

  @override
  void initState() {
    queryDocument = widget.data;
    isCompleted = queryDocument.get("completed");

    super.initState();
  }

  void changeCompleteState() {
    setState(() {
      isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (firebaseAuth.currentUser != null) {
      todos = FirebaseFirestore.instance
          .collection('todos')
          .doc(firebaseAuth.currentUser!.uid)
          .collection("todos");

      subtasksStream = FirebaseFirestore.instance
          .collection('todos')
          .doc(firebaseAuth.currentUser!.uid)
          .collection("todos")
          .doc(queryDocument.id)
          .collection("subtasks")
          .snapshots();

      subTaskList = FirebaseFirestore.instance
          .collection('todos')
          .doc(firebaseAuth.currentUser!.uid)
          .collection("todos")
          .doc(queryDocument.id)
          .collection("subtasks");
    }
    return Scaffold(
        resizeToAvoidBottomInset: true,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AddSubTask(mainTaskId: queryDocument.id)));
            },
            icon: Icon(Icons.add),
            label: Text("Yeni alt görev")),
        appBar: AppBar(
          centerTitle: true,
          title: Text("Görev Detayları"),
        ),
        body: SingleChildScrollView(
          child: Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        if (queryDocument.get("important") == true) ...[
                          Container(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color.fromRGBO(0, 151, 181, 1),
                                        width: 1.0))),
                            width: MediaQuery.of(context).size.width * 0.95,
                            child:
                                const Flex(direction: Axis.horizontal, children: [
                              Icon(Icons.flag, color: Colors.red, size: 15),
                              Text(
                                "Önemli",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ]),
                          ),
                        ],
                        Divider(color: Colors.transparent, height: 8),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          child:
                              const Flex(direction: Axis.horizontal, children: [
                            Icon(
                              Icons.edit_calendar_sharp,
                              size: 20,
                              color: Color.fromARGB(255, 60, 89, 252),
                            ),
                            VerticalDivider(width: 3),
                            Text(
                              "Görev Başlığı",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 181, 12, 0)),
                            )
                          ]),
                        ),
                        Container(
                          
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: Text(
                              
                              queryDocument.get("todo"),

                              style: TextStyle(fontSize: 16),
                            )),
                        Divider(color: Colors.grey),
                        if(queryDocument.get("description") != null && queryDocument.get("description").length > 0)
                        Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          child:
                              const Flex(direction: Axis.horizontal, children: [
                            Icon(
                              Icons.comment,
                              size: 20,
                              color: Color.fromARGB(255, 60, 89, 252),
                            ),
                            VerticalDivider(width: 3),

                            Text(
                              "Görev Açıklaması",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 181, 12, 0)),
                            )
                          ]),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: Text(
                              queryDocument.get("description"),
                              style: const TextStyle(fontSize: 13),
                            ))
                      ],
                    )
                  ],
                ),
                const Divider(
                    color: Color.fromARGB(255, 20, 107, 247),
                    height: 25,
                    thickness: 8),
                  Row(
                    children: [
                      Column(
                        children: [
                          StreamBuilder(
                            stream: subtasksStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<DocumentSnapshot> subtasks =
                                    snapshot.data!.docs;
                                return Flex(
                                  direction: Axis.vertical,
                                  children: [
                                    if(subtasks.isNotEmpty)
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.95,
                                      child: const Flex(
                                          direction: Axis.horizontal,
                                          children: [
                                            Icon(
                                              Icons.list,
                                              size: 20,
                                              color: Color.fromARGB(
                                                  255, 60, 89, 252),
                                            ),
                                            VerticalDivider(width: 3),
                                            Text(
                                              "Bu göreve bağlı alt görevler",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 181, 12, 0)),
                                            )
                                          ]),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: subtasks.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              trailing: IconButton(icon: Icon(Icons.delete),style: ButtonStyle(iconColor: MaterialStateColor.resolveWith((states) {
                                                
                                                if(states.contains(MaterialState.pressed)){
                                                  return Color.fromARGB(255, 253, 116, 19);
                                                }else{
                                                  return Color.fromARGB(255, 255, 45, 30);
                                                }
                                              })),onPressed: ()=>{}),
                                              leading: const Icon(
                                                Icons.circle_rounded,
                                                size: 16,
                                              ),
                                              title: Text(
                                                  subtasks[index]
                                                          .get("subtaskData")! ??
                                                      "",
                                                  style: TextStyle(fontSize: 13)),
                                            );
                                          }),
                                    ),
                                  ],
                                );
                              } else {
                                return Text("");
                              }
                            },
                          )
                        ],
                      )
                    ],
                  ),
                Divider(color: Colors.transparent),
                Row(
                  children: [
                    Column(
                      children: [
                        if (isCompleted == false)
                          ElevatedButton(
                              onPressed: () {
                                todos
                                    .doc(queryDocument.id)
                                    .update({"completed": true}).then((value) => {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "Görev tamamlandı olarak işaretlendi"))),
                                        });
                                changeCompleteState();
                              },
                              child: Text("Tamamlandı olarak işaretle"))
                      ],
                    ),
                    VerticalDivider(color: Colors.transparent),
                    Column(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              todos
                                  .doc(queryDocument.id)
                                  .delete()
                                  .then((value) => {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text("Görev silindi"))),
                                        Navigator.pop(context)
                                      });
                            },
                            child: Text("Görevi sil"))
                      ],
                    ),

                  ],
                  
                ),
                Divider(color: Colors.transparent,height: 100),              
              ],
            )
          ]),
        ));
  }
}
