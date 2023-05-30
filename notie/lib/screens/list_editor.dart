import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notie/screens/home_screen.dart';
import 'package:notie/style/app_style.dart';

class ListEditorScreen extends StatefulWidget {
  final QueryDocumentSnapshot? doc; // Pass the QueryDocumentSnapshot

  const ListEditorScreen(this.doc, {Key? key}) : super(key: key);

  @override
  _ListEditorScreenState createState() => _ListEditorScreenState();
}

class _ListEditorScreenState extends State<ListEditorScreen> {
  int color_id = Random().nextInt(AppStyle.cardsColor.length);
  String date = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
  TextEditingController _titleController = TextEditingController();
  List<TextEditingController> _itemTitleControllers = [];
  List<bool> _itemCompletedStatus = [];

  @override
  void initState() {
    super.initState();
    // Populate the editor fields if the snapshot is not null
    if (widget.doc != null) {
      _titleController.text = widget.doc!['list_title'];

      final List<dynamic> itemList = widget.doc!['list_items'];
      for (final item in itemList) {
        _itemTitleControllers
            .add(TextEditingController(text: item['item_title']));
        _itemCompletedStatus.add(item['item_completed']);
      }

      color_id = widget.doc!['color_id'];
      date = widget.doc!['creation_date'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _itemTitleControllers) {
      controller.dispose();
    }
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
          "Add a new list",
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
                labelText: 'List Title',
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
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _itemTitleControllers.length,
                itemBuilder: (context, index) {
                  return _buildListItem(index);
                },
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _itemTitleControllers.add(TextEditingController());
                  _itemCompletedStatus.add(false);
                });
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.doc != null) {
            // Handle update logic for existing list
            // Update the list using the Firestore update method
            final List<Map<String, dynamic>> itemList = [];
            for (int i = 0; i < _itemTitleControllers.length; i++) {
              itemList.add({
                'item_title': _itemTitleControllers[i].text,
                'item_completed': _itemCompletedStatus[i],
              });
            }
            widget.doc!.reference.update({
              'list_title': _titleController.text,
              'list_items': itemList,
              // Add any other fields you want to update
            }).then((_) {
              Navigator.pop(context); // Go back to the previous screen
              Navigator.pop(context);
            });
          } else {
            // Handle create logic for new list
            // Create a new list using the Firestore set method
            final List<Map<String, dynamic>> itemList = [];
            for (int i = 0; i < _itemTitleControllers.length; i++) {
              itemList.add({
                'item_title': _itemTitleControllers[i].text,
                'item_completed': _itemCompletedStatus[i],
              });
            }
            FirebaseFirestore.instance.collection('lists').add({
              'list_title': _titleController.text,
              'creation_date': date,
              'list_items': itemList,
              'color_id': color_id,
              // Add any other fields you want to include
            }).then((_) {
              Navigator.pop(context); // Go back to the previous screen
            }).catchError(
                (error) => print("Failed to add new list due to $error"));
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildListItem(int index) {
    return Row(
      children: [
        Checkbox(
          value: _itemCompletedStatus[index],
          onChanged: (value) {
            setState(() {
              _itemCompletedStatus[index] = value ?? false;
            });
          },
        ),
        Expanded(
          child: TextField(
            controller: _itemTitleControllers[index],
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: 'Item Title',
            ),
            style: AppStyle.mainContent,
          ),
        ),
      ],
    );
  }
}
