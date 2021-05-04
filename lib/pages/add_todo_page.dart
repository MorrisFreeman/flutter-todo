import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTodoPage extends StatefulWidget {
  @override
  _AddTodoPageState createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  String task = 'empty message';

  @override
  Widget build(BuildContext context) {
    final user = context.read<User>();

    return Scaffold(
      appBar: AppBar(title: Text('Todo追加')),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'タスク'),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    task = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text('タスクを追加'),
                    onPressed: () async {
                      final date = DateTime.now().toLocal().toIso8601String();
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('tasks')
                          .add({
                        'text': task,
                        'created_at': date,
                        'updated_at': date
                      });
                      Navigator.of(context).pop();
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
