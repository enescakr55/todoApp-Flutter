import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/register.dart';
import 'package:todo_app/services/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}
class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  @override
  Widget build(BuildContext context) {

    return Scaffold(body:     Column(

      mainAxisAlignment: MainAxisAlignment.center,
      children:[
      
      Form(child: Center(
      child: SizedBox(width: MediaQuery.of(context).size.width * 0.9,child: 
      Container(
        padding: EdgeInsets.fromLTRB(15, 40, 15, 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30)),border: Border.all(color: Colors.black,width: 2),color: Color.fromARGB(255, 171, 193, 255)),
        child: Column(
          children: [
            Container(child: Text("Giriş Yap",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),),
            TextFormField(
              keyboardType: TextInputType.emailAddress,      
              controller: email,
              decoration: const InputDecoration(hintText: "Kullanıcı Adı"),),
            TextFormField(
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,        
              controller: password,
              decoration: const InputDecoration(hintText: "Şifre"),),
              Divider(),
            ElevatedButton(onPressed: ()
            async {
              if(email.text.isEmpty || email.text.isEmpty){
                  ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("E-Posta adresi veya Şifre boş olamaz")));
              }else{
                try {
                    await _authService.signIn(email.text, password.text).then((value) => {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>MyApp()), (route) => false)
                }); 
                } catch (e) {
                    ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Giriş başarısız. ")));
                }
                  
              }

            }, child: Text("Giriş Yap"))
        ],),
      )),
    )),
    Divider(color: Colors.transparent,height: 16.0),
    Text("Henüz hesabın yok mu ?",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500)),
    ElevatedButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (_)=>RegisterScreen()));
    }, child: Text("Hesap Oluştur"),style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.white),backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 91, 148, 255))),)
    ]));

  }
}