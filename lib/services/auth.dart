import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Future<User?> signIn(String email,String password) async{
    var user = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.user;
  } 
  signOut() async{
    return await firebaseAuth.signOut();
  }
  Future<User?> createAccount(String email,String password) async{
    var user = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user.user;
  }
  bool isLogged(){
    return firebaseAuth.currentUser == null ? false : true;
  }
}