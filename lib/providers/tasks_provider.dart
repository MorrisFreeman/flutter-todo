import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TasksPrivider {
  final String userUid;
  Stream<QuerySnapshot> tasksSnapshot;

  Stream<QuerySnapshot> get tasks => tasksSnapshot;

  TasksPrivider(this.userUid);

  void subscribe() {
    tasksSnapshot = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('tasks')
        .orderBy('updated_at', descending: true)
        .snapshots();
  }
}
