import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  await Firebase.initializeApp();
  runApp(MyTodoApp());
}

class MyTodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FirestoreTest',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}

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

class TodoListPage extends StatefulWidget {
  TodoListPage(this.user);
  final User user;

  @override
  _TodoListPageState createState() => _TodoListPageState(user);
}

class _TodoListPageState extends State<TodoListPage> {
  _TodoListPageState(this.user);
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todoリスト'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }));
              })
        ],
      ),
      body: Center(
        child: Text(user.email),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) {
            return AddTodoPage();
          }));
        },
      ),
    );
  }
}

class AddTodoPage extends StatefulWidget {
  @override
  _AddTodoPageState createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo追加')),
    );
  }
}
