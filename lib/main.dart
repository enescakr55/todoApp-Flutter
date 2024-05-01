import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/addTodo.dart';
import 'package:todo_app/login.dart';
import 'package:todo_app/services/auth.dart';
import 'package:todo_app/todoDetails.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Yapılacaklar Listesi'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  FirebaseAuth authState = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  AuthService authService = AuthService();
  late CollectionReference todos;
  late Stream<QuerySnapshot<Map<String, dynamic>>> todoStream;
  //late List<QueryDocumentSnapshot<Object?>> todoDocuments;
  late DocumentSnapshot response;
  @override
  void initState() {
    // TODO: implement initState
    authState.authStateChanges().listen((event) {
      if (authState.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Hoşgeldiniz, devam etmek için giriş yapmanız gerekiyor")));
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
  }

  Future<void> addTodo() {
    _counter++;
    return todos
        .add({
          'todo': 'Todo $_counter',
          'description': 'Todo $_counter desc',
          'completed': false
        })
        .then((value) => print('todo added'))
        .catchError((err) => {print('Görev eklenirken bir sorun oluştu')});
  }

  /*Future<void> getTodo() async {
      var response = await todos.get();
      todoDocuments = response.docs;
      print(todoDocuments[1].data());
  }*/
  Widget importantFlag(isImportant) {
    return isImportant == true
        ? Icon(
            Icons.flag,
            color: Colors.red,
          )
        : Text("");
  }

  Widget todoScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          StreamBuilder(
              stream: todoStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text("Bir hata oluştu");
                } else if (snapshot.hasData) {
                  List<DocumentSnapshot> docs = snapshot.data!.docs;

                  return SizedBox(
                      height: MediaQuery.of(context).size.height - 100,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            String lastDate = "";
                            try {
                              print("start");
                              Timestamp lastDateTimestamp =
                                  docs[index]["lastDate"];
                              print("end");
                              DateTime lastDateTime = DateTime.parse(
                                  lastDateTimestamp.toDate().toString());
                              print(lastDateTime);
                              lastDate = "\nBitiş Tarihi : ";
                              lastDate +=
                                  DateFormat("dd.MM.yyyy").format(lastDateTime);
                            } catch (e) {
                              lastDate = "";
                            }
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xff6ae792),
                                child: Text(
                                  index.toString(),
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                              textColor:
                                  const Color.fromARGB(255, 38, 118, 255),
                              title: Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Flex(
                                  
                                  direction: Axis.horizontal,
                                  children: [
                                    importantFlag(docs[index].get("important")),
                                    Text(docs[index].get("todo"),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: true,
                                        style: const TextStyle(fontSize: 14))
                                  ],
                                ),
                              ),
                              subtitle: Text(
                                  docs[index].get("description") + lastDate,
                                  style: const TextStyle(fontSize: 13)),
                              shape: const Border(
                                  bottom: BorderSide(color: Colors.grey)),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => TodoDetailsWidget(
                                            data: docs[index])));
                              },
                              trailing: docs[index].get("completed") == true
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : const Icon(Icons.access_time,
                                      color: Colors.red),
                            );
                          }));
                } else {
                  return const Text("");
                }
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: const Color(0xff6ae792),
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 18),
          title: Text(widget.title),
          actions: [
            authState.currentUser != null
                ? IconButton(
                    onPressed: () => authService.signOut(),
                    icon: Icon(Icons.logout))
                : Text("")
          ],
        ),
        body: StreamBuilder(
            stream: authState.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Bir hata oluştu");
              } else {
                if (authState.currentUser == null) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                    );
                  });
                  return Text("");
                } else {
                  var userId = authState.currentUser?.uid ?? "";
                  todos = FirebaseFirestore.instance
                      .collection("todos")
                      .doc(userId)
                      .collection("todos");
                  todoStream = FirebaseFirestore.instance
                      .collection("todos")
                      .doc(userId)
                      .collection("todos")
                      .where('archive', isNull: true)
                      .snapshots();
                  return todoScreen();
                }
              }
            }),
        floatingActionButton: authState.currentUser != null
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddTodoWidget()));
                },
                tooltip: 'Add Todo',
                child: const Icon(Icons.add),
              )
            : null // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
