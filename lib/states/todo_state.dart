// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';

// class TodoState extends ChangeNotifier {
//   DocumentSnapshot taskList = [];
//   String status = 'notYet';

//   void fetchTaskList(String userUid, [String startAtUid]) async {
//     _setStatus('loading');

//     if (startAtUid == null) {
//       final taskSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userUid)
//           .collection('tasks')
//           .orderBy('updated_at', descending: true)
//           .limit(20)
//           .get();
//       _addTaskList(taskSnapshot.docs);
//       _setStatus('success');

//       return;
//     }

//     final startAtTaskSnapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userUid)
//         .collection('tasks')
//         .doc(startAtUid)
//         .get();

//     final todoSnapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userUid)
//         .collection('tasks')
//         .orderBy('updated_at', descending: true)
//         .startAtDocument(startAtTaskSnapshot)
//         .get();

//     final a = todoSnapshot.docs[0];
//     final b = a.data();
//     _addTaskList(todoSnapshot.docs[0]);
//     _setStatus('success');
//   }

//   void _addTaskList(List<DocumentSnapshot> newTaskList) {
//     taskList.add(newTaskList);
//     taskList.sort((a, b) => a.updated)
//   }

//   void _setStatus(String newStatus) {
//     status = newStatus;
//     notifyListeners();
//   }
// }
