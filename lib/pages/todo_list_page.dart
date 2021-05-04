import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/states/authentication_provider.dart';

import 'login_page.dart';
import 'add_todo_page.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  int _currentIndex = 0;
  final _childPageList = [
    _TodoList(),
    _DoneTodoList(),
  ];

  @override
  Widget build(BuildContext context) {
    Future<void> _showLogoutDialog() async {
      final isLogouting = await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('ログアウトしますか？'),
                actions: [
                  SimpleDialogOption(
                      child: Text('はい'),
                      onPressed: () => Navigator.pop(context, true)),
                  SimpleDialogOption(
                      child: Text('いいえ'),
                      onPressed: () => Navigator.pop(context, false))
                ],
              ));
      if (isLogouting) {
        context.read<AuthenticationProvider>().signOut();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Todoリスト'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async => _showLogoutDialog())
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _childPageList,
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
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.check_box_outline_blank_outlined),
                label: 'NotYet'),
            BottomNavigationBarItem(
                icon: Icon(Icons.check_box_outlined), label: 'Done')
          ],
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          }),
    );
  }
}

class _TodoList extends StatelessWidget {
  Stream<QuerySnapshot> fetchTasksSnapshot(String userUid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('tasks')
        .orderBy('updated_at', descending: true)
        .snapshots();
  }

  Future<void> taskToDone(String userUid, String taskUid) async {
    // HttpsCallable callable =
    //     FirebaseFunctions.instanceFor(region: 'asia-northeast1')
    //         .httpsCallable('taskToDone');
    // await callable({'taskUid': taskUid});
    final db = FirebaseFirestore.instance;
    final taskRef =
        db.collection('users').doc(userUid).collection('tasks').doc(taskUid);
    final doneTaskRef = db
        .collection('users')
        .doc(userUid)
        .collection('doneTasks')
        .doc(taskUid);

    await db.runTransaction((transaction) async {
      final taskSnapshot = await transaction.get(taskRef);
      transaction.set(
          doneTaskRef, {...taskSnapshot.data(), 'updated_at': DateTime.now()});
      transaction.delete(taskRef);
    });
  }

  Future<void> _deleteTask(String userUid, String taskUid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('tasks')
        .doc(taskUid)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<User>();
    Future<void> _showDeleteDialog(String userUid, String taskUid) async {
      final isDeleting = await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('削除しますか？'),
                actions: [
                  SimpleDialogOption(
                      child: Text('はい'),
                      onPressed: () => Navigator.pop(context, true)),
                  SimpleDialogOption(
                      child: Text('いいえ'),
                      onPressed: () => Navigator.pop(context, false))
                ],
              ));
      if (isDeleting) {
        _deleteTask(userUid, taskUid);
      }
    }

    return Expanded(
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
                  onPressed: () async =>
                      await _showDeleteDialog(user.uid, doc.id),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                value: false,
                onChanged: (bool _done) async {
                  await taskToDone(user.uid, doc.id);
                },
              ),
            );
          }).toList());
        }
        return Center(
          child: Text('読み込み中...'),
        );
      },
    ));
  }
}

class _DoneTodoList extends StatelessWidget {
  Stream<QuerySnapshot> fetchDoneTasksSnapshot(String userUid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('doneTasks')
        .orderBy('updated_at', descending: true)
        .snapshots();
  }

  Future<void> taskToNotYet(String userUid, String taskUid) async {
    // HttpsCallable callable =
    //     FirebaseFunctions.instanceFor(region: 'asia-northeast1')
    //         .httpsCallable('taskToNotYet');
    // await callable({'taskUid': taskUid});
    final db = FirebaseFirestore.instance;
    final taskRef =
        db.collection('users').doc(userUid).collection('tasks').doc(taskUid);
    final doneTaskRef = db
        .collection('users')
        .doc(userUid)
        .collection('doneTasks')
        .doc(taskUid);

    await db.runTransaction((transaction) async {
      final doneTaskSnapshot = await transaction.get(doneTaskRef);
      transaction.set(
          taskRef, {...doneTaskSnapshot.data(), 'updated_at': DateTime.now()});
      transaction.delete(doneTaskRef);
    });
  }

  Future<void> _deleteDoneTask(String userUid, String taskUid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('doneTasks')
        .doc(taskUid)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<User>();

    Future<void> _showDeleteDialog(String userUid, String taskUid) async {
      final isDeleting = await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('削除しますか？'),
                actions: [
                  SimpleDialogOption(
                      child: Text('はい'),
                      onPressed: () => Navigator.pop(context, true)),
                  SimpleDialogOption(
                      child: Text('いいえ'),
                      onPressed: () => Navigator.pop(context, false))
                ],
              ));
      if (isDeleting) {
        _deleteDoneTask(userUid, taskUid);
      }
    }

    return Expanded(
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
                    onPressed: () async =>
                        await _showDeleteDialog(user.uid, doc.id)),
                controlAffinity: ListTileControlAffinity.leading,
                value: true,
                onChanged: (bool _done) async {
                  await taskToNotYet(user.uid, doc.id);
                },
              ),
            );
          }).toList());
        }
        return Center(
          child: Text('読み込み中...'),
        );
      },
    ));
  }
}
