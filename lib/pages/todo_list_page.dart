import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';
import 'add_todo_page.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage(this.user);
  final User user;

  @override
  _TodoListPageState createState() => _TodoListPageState(user);
}

class _TodoListPageState extends State<TodoListPage> {
  _TodoListPageState(this.user);
  final User user;

  Stream<QuerySnapshot> fetchTasksSnapshot() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('updated_at')
        .snapshots();
  }

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
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Text(user.email),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: fetchTasksSnapshot(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<DocumentSnapshot> docs = snapshot.data.docs;
                return ListView(
                    children: docs.map((doc) {
                  return Card(
                    child: CheckboxListTile(
                      title: Text(doc['text']),
                      secondary: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('tasks')
                              .doc(doc.id)
                              .delete();
                        },
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: doc['done'],
                      onChanged: (bool done) async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('tasks')
                            .doc(doc.id)
                            .update({'done': done});
                      },
                    ),
                  );
                }).toList());
              }
              return Center(
                child: Text('読み込み中...'),
              );
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) {
            return AddTodoPage(user.uid);
          }));
        },
      ),
    );
  }
}
