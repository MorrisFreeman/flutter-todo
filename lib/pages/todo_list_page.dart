import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';
import 'add_todo_page.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  Stream<QuerySnapshot> fetchTasksSnapshot(String userUid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('tasks')
        .orderBy('updated_at')
        .snapshots();
  }

  Stream<QuerySnapshot> fetchDoneTasksSnapshot(String userUid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('doneTasks')
        .orderBy('updated_at')
        .snapshots();
  }

  Future<void> taskToDone(String taskUid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'asia-northeast1')
            .httpsCallable('taskToDone');
    await callable({'taskUid': taskUid});
  }

  Future<void> taskToNotYet(String taskUid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'asia-northeast1')
            .httpsCallable('taskToNotYet');
    await callable({'taskUid': taskUid});
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<User>();

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
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: fetchTasksSnapshot(user.uid),
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
                      value: false,
                      onChanged: (bool _done) async {
                        await taskToDone(doc.id);
                      },
                    ),
                  );
                }).toList());
              }
              return Center(
                child: Text('読み込み中...'),
              );
            },
          )),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: fetchDoneTasksSnapshot(user.uid),
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
                              .collection('doneTasks')
                              .doc(doc.id)
                              .delete();
                        },
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: true,
                      onChanged: (bool _done) async {
                        await taskToNotYet(doc.id);
                      },
                    ),
                  );
                }).toList());
              }
              return Center(
                child: Text('読み込み中...'),
              );
            },
          )),
        ],
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
