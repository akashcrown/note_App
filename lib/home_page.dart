import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/constant.dart';

import 'addnote.dart';
import 'editnote.dart';
import 'helpers.dart';
import 'todo.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Todo> todos = [];
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> stream;

  @override
  void initState() {
    super.initState();

    stream = FirebaseFirestore.instance
        .collection('notes')
        .where('userId', isEqualTo: currentUser.id)
        .snapshots()
        .listen(
      (snapshot) {
        for (var change in snapshot.docChanges) {
          final doc = change.doc;
          Todo todo = Todo.fromDoc(doc);
          if (change.type == DocumentChangeType.added) {
            todos.add(todo);
          } else if (change.type == DocumentChangeType.removed) {
            todos.remove(todo);
          } else if (change.type == DocumentChangeType.modified) {
            int index = todos.indexOf(todo);
            todos[index] = todo;
          }
        }
        // todos.sort((a, b) => a.title.compareTo(b.title));
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crown Note App'),
        backgroundColor: Color.fromARGB(255, 100, 105, 231),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.note_add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddNote()));
        },
      ),
      body: GridView(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        children: [
          for (var todo in todos)
            Builder(builder: (context) {
              var color =
                  Colors.primaries[Random().nextInt(Colors.primaries.length)];
              return GestureDetector(
                onTap: () {
                  to(context, EditNote(todo: todo, color: color));
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  // height: 150,
                  color: color,
                  child: Column(
                    children: [
                      Text(
                        todo.title,
                        style: GoogleFonts.secularOne(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        todo.content,
                        style: GoogleFonts.caveat(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
