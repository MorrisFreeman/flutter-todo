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
      title: 'Todo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String newUserEmail = "";
  String newUserPassword = "";
  String loginUserEmail = "";
  String loginUserPassword = "";
  String infoText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            padding: EdgeInsets.all(32),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: "メールアドレス"),
                  onChanged: (String value) {
                    setState(() {
                      newUserEmail = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(labelText: "パスワード（6文字以上）"),
                  onChanged: (String value) {
                    setState(() {
                      newUserPassword = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final UserCredential result =
                          await auth.createUserWithEmailAndPassword(
                              email: newUserEmail, password: newUserPassword);
                      final User user = result.user;
                      setState(() {
                        infoText = "登録OK：${user.email}";
                      });
                    } catch (e) {
                      setState(() {
                        infoText = "登録NG：${e.toString()}";
                      });
                    }
                  },
                  child: Text("ユーザー登録"),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  decoration: InputDecoration(labelText: "メールアドレス"),
                  onChanged: (String value) {
                    setState(() {
                      loginUserEmail = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "パスワード"),
                  onChanged: (String value) {
                    setState(() {
                      loginUserPassword = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: () async {
                      try {
                        final FirebaseAuth auth = FirebaseAuth.instance;
                        final UserCredential result =
                            await auth.signInWithEmailAndPassword(
                                email: loginUserEmail,
                                password: loginUserPassword);
                        final User user = result.user;
                        setState(() {
                          infoText = "ログインOK：${user.email}";
                        });
                      } catch (e) {
                        setState(() {
                          infoText = "ログインNG：${e.toString()}";
                        });
                      }
                    },
                    child: Text("ログイン")),
                const SizedBox(height: 8),
                Text(infoText),
              ],
            )),
      ),
    );
  }
}

// class MyTodoApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: TodoListPage(),
//     );
//   }
// }

// class TodoListPage extends StatefulWidget {
//   @override
//   _TodoListPageState createState() => _TodoListPageState();
// }

// class _TodoListPageState extends State<TodoListPage> {
//   List<String> todoList = [];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('リスト一覧')),
//       body: ListView.builder(
//         itemCount: todoList.length,
//         itemBuilder: (context, index) {
//           return Card(
//             child: ListTile(
//               title: Text(todoList[index]),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final newListText = await Navigator.of(context).push(
//             MaterialPageRoute(builder: (context) {
//               return TodoAddPage();
//             }),
//           );
//           if (newListText != null) {
//             setState(() {
//               todoList.add(newListText);
//             });
//           }
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

// class TodoAddPage extends StatefulWidget {
//   @override
//   _TodoAddPageState createState() => _TodoAddPageState();
// }

// class _TodoAddPageState extends State<TodoAddPage> {
//   String _text = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('リスト追加')),
//       body: Container(
//         padding: EdgeInsets.all(64),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             TextField(
//               onChanged: (String value) {
//                 setState(() {
//                   _text = value;
//                 });
//               },
//             ),
//             const SizedBox(
//               height: 8,
//             ),
//             Container(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(_text);
//                   },
//                   child: Text('リスト追加', style: TextStyle(color: Colors.white)),
//                 )),
//             Container(
//                 width: double.infinity,
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Text('キャンセル'),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }
