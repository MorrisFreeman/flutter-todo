import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'todo_list_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String infoText = '';
  String email = '';
  String password = '';

  Future<void> createOrUpdateUser(uid, email, name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'email': email});
  }

  Future<User> execSignUp(email, password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  Future<User> execSignIn(email, password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final UserCredential result =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  Future<void> onPressedSignUp(email, password) async {
    try {
      final user = await execSignUp(email, password);
      await createOrUpdateUser(user.uid, user.email, user.displayName);
      await Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return TodoListPage(user);
      }));
    } catch (e) {
      setState(() {
        infoText = "登録に失敗しました：${e.toString()}";
      });
    }
  }

  Future<void> onPressedSignIn(email, password) async {
    try {
      final user = await execSignIn(email, password);
      await createOrUpdateUser(user.uid, user.email, user.displayName);
      await Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return TodoListPage(user);
      }));
    } catch (e) {
      setState(() {
        infoText = "ログインに失敗しました：${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'メールアドレス'),
                  onChanged: (String value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'パスワード'),
                  obscureText: true,
                  onChanged: (String value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Text(infoText),
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        await onPressedSignUp(email, password);
                      },
                      child: Text('ユーザー登録')),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        await onPressedSignIn(email, password);
                      },
                      child: Text('ログイン')),
                ),
              ],
            )),
      ),
    );
  }
}
