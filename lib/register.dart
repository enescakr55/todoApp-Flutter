
import 'package:flutter/material.dart';
import 'package:todo_app/services/auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
      TextEditingController email = new TextEditingController();
    TextEditingController password = new TextEditingController();
  AuthService authService = AuthService();
  register(email,password){

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: Column(

      mainAxisAlignment: MainAxisAlignment.center,
      children:[
      
      Form(child: Center(
      child: SizedBox(width: MediaQuery.of(context).size.width * 0.9,child: 
      Container(
        padding: EdgeInsets.fromLTRB(15, 40, 15, 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30)),border: Border.all(color: Colors.black,width: 2),color: Color.fromARGB(255, 171, 193, 255)),
        child: Column(
          children: [
            Container(child: Text("Kayıt Ol",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),),
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
            ElevatedButton.icon(icon:Icon(Icons.app_registration) ,onPressed: ()
            async {
              if(email.text.isEmpty || email.text.isEmpty){
                  ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("E-Posta adresi veya Şifre boş olamaz")));
              }else{
                try {
                    await authService.createAccount(email.text, password.text);
                                      ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Başarılı bir şekilde kayıt oldunuz.")));
                      Navigator.pop(context);
                } catch (e) {
                                      ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Kayıt işlemi başarısız.")));
                }

              }

            }, label: Text("Kayıt Ol"))
        ],),
      )),
    ))])
    );
  }
}