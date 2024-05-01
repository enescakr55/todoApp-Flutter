import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddTodoWidget extends StatefulWidget {
  const AddTodoWidget({super.key});

  @override
  State<AddTodoWidget> createState() => _AddTodoWidgetState();
}

class _AddTodoWidgetState extends State<AddTodoWidget> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  late CollectionReference todos;

  TextEditingController todoName = new TextEditingController();
  TextEditingController todoDescription = new TextEditingController();
  TextEditingController lastDate = new TextEditingController();
  bool isImportant = false;
  Object lastDateTimestamp = Null;
  void addTodo() {
    var userId = firebaseAuth.currentUser?.uid ?? "";
    late Object addedTask;
    todos = FirebaseFirestore.instance
        .collection('todos')
        .doc(userId)
        .collection("todos");
    if (lastDateTimestamp == Null) {
      addedTask = {
        "todo": todoName.text,
        "addedDate":DateTime.now(),
        "description": todoDescription.text,
        "completed": false,
        "archive":null,
        "important":isImportant
        //"lastDate":lastDateTimestamp
      };
    } else {
      addedTask = {
        "todo": todoName.text,
        "description": todoDescription.text,
        "addedDate":DateTime.now(),
        "completed": false,
        "lastDate": lastDateTimestamp as Timestamp,
        "archive":null,
        "important":isImportant
      };
    }

    todos.add(addedTask).then((value) => {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Görev Eklendi"))),
          todoName.value = TextEditingValue.empty,
          todoDescription.value = TextEditingValue.empty,
          lastDate.value = TextEditingValue.empty,
          lastDateTimestamp = Null
        });
  }

  @override
  Widget build(BuildContext context) {
    @override
    void initState() async {
      lastDate.text = "Belirtilmedi";
      super.initState();
    }

    return Scaffold(
        appBar: AppBar(title: const Text("Yeni Görev")),
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: Form(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                controller: todoName,
                decoration: const InputDecoration(
                    labelText: "Görev Adı",
                    icon: Icon(Icons.task_alt_rounded,
                        color: Color.fromARGB(255, 255, 90, 90))),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  controller: todoDescription,
                  decoration: const InputDecoration(
                      labelText: "Görev Açıklaması",
                      icon: Icon(Icons.edit_note_rounded,
                          color: Color.fromARGB(255, 255, 90, 90)))),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: lastDate,
                
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: "Bitiş Tarihi",
                    icon: Icon(Icons.calendar_today,
                        color: Color.fromARGB(255, 255, 90, 90))),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2100));
                  if (pickedDate != null) {
                    print(pickedDate);
                    lastDateTimestamp = Timestamp.fromDate(pickedDate);
                    String formattedDate =
                        DateFormat('dd.MM.yyyy').format(pickedDate);
                    lastDate.text = formattedDate;
                  } else {}
                },
              ),
              const SizedBox(
                height: 5,
              ),
              CheckboxListTile(title:Text("Önemli"),value: isImportant, onChanged: (value)=>{
                setState((){
                  isImportant = value ?? false;
                })
              }),
              const SizedBox(
                height: 5,
              ),
              ElevatedButton(
                  onPressed: addTodo, child: const Text("Görev Ekle"))
            ],
          )),
        ));
  }
}
