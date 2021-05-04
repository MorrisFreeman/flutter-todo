import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/states/authentication_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool signUp = false;
  String infoText = '';

  Future<void> createOrUpdateUser(String uid, String email, String name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'email': email});
  }

  Future<User> execSignUp(String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  Future<User> execSignIn(String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final UserCredential result =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: signUp ? Text('アカウント作成') : Text('ログイン'),
      ),
      body: Center(
        child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'メールアドレス'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'パスワード'),
                  obscureText: true,
                  controller: passwordController,
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Text(infoText),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        if (signUp) {
                          context.read<AuthenticationProvider>().signUp(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim());
                        } else {
                          context.read<AuthenticationProvider>().signIn(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim());
                        }
                      },
                      child: signUp ? Text('アカウント作成') : Text('ログイン')),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          signUp = !signUp;
                        });
                      },
                      child: signUp ? Text('ログインする') : Text('アカウントを作成する')),
                ),
              ],
            )),
      ),
    );
  }
}
