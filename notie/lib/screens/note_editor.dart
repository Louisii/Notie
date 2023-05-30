import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notie/style/app_style.dart';

class NoteEditorScreen extends StatefulWidget {
  final QueryDocumentSnapshot? doc; // Pass the QueryDocumentSnapshot

  const NoteEditorScreen(this.doc, {Key? key}) : super(key: key);

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  int color_id = Random().nextInt(AppStyle.cardsColor.length);
  String date = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Populate the editor fields if the snapshot is not null
    if (widget.doc != null) {
      _titleController.text = widget.doc!['note_title'];
      _contentController.text = widget.doc!['note_content'];
      color_id = widget.doc!['color_id'];
      date = widget.doc!['creation_date'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.cardsColor[color_id],
      appBar: AppBar(
        backgroundColor: AppStyle.cardsColor[color_id],
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Add a new note",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: 'Title',
              ),
              style: AppStyle.mainTitle,
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(
              date,
              style: AppStyle.dateTitle,
            ),
            TextField(
              controller: _contentController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: 'Content',
              ),
              style: AppStyle.mainContent,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.doc != null) {
            // Handle update logic for existing note
            // Update the note using the Firestore update method
            widget.doc!.reference.update({
              'note_title': _titleController.text,
              'note_content': _contentController.text,
              // Add any other fields you want to update
            }).then((_) {
              Navigator.pop(context); // Go back to the previous screen
              Navigator.pop(context);
            });
          } else {
            // Handle create logic for new note
            // Create a new note using the Firestore set method
            FirebaseFirestore.instance.collection('notes').add({
              'note_title': _titleController.text,
              'creation_date': date,
              'note_content': _contentController.text,
              'color_id': color_id,
              // Add any other fields you want to include
            }).then((_) {
              Navigator.pop(context); // Go back to the previous screen
            }).catchError(
                (error) => print("Fail to add new note due to $error"));
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
