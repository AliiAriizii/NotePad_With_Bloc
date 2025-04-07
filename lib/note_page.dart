import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NotePage extends StatelessWidget {
  final Note note;
  const NotePage({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(note.color),
      appBar: AppBar(title: Text(note.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(note.content, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
