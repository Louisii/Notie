import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notie/screens/list_editor.dart';
import 'package:notie/screens/note_editor.dart';
import 'package:notie/screens/note_reader.dart';
import 'package:notie/style/app_style.dart';

import 'package:notie/widgets/note_card.dart';
import 'package:notie/widgets/list_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.mainColor,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Notie"),
        centerTitle: true,
        backgroundColor: AppStyle.mainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, bottom: 8.0, right: 16.0, top: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your recent notes",
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("notes").snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    List<QueryDocumentSnapshot> noteDocuments =
                        snapshot.data!.docs;
                    if (noteDocuments.isEmpty) {
                      return Text(
                        "There's no Notes",
                        style: GoogleFonts.nunito(color: Colors.white),
                      );
                    }
                    noteDocuments.sort((a, b) {
                      String dateStringA = a['creation_date'];
                      String dateStringB = b['creation_date'];
                      DateTime dateA =
                          DateFormat('dd/MM/yyyy hh:mm a').parse(dateStringA);
                      DateTime dateB =
                          DateFormat('dd/MM/yyyy hh:mm a').parse(dateStringB);
                      return dateB.compareTo(dateA); // Descending order
                    });

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: noteDocuments.length,
                      itemBuilder: (context, index) {
                        QueryDocumentSnapshot note = noteDocuments[index];
                        return noteCard(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteReaderScreen(note),
                            ),
                          );
                        }, note);
                      },
                    );
                  }
                  return Text(
                    "Add a new Note to start!",
                    style: GoogleFonts.nunito(color: Colors.white),
                  );
                },
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              "Your recent lists",
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("lists").snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    List<QueryDocumentSnapshot> listDocuments =
                        snapshot.data!.docs;
                    if (listDocuments.isEmpty) {
                      return Text(
                        "Add a new List to start!",
                        style: GoogleFonts.nunito(color: Colors.white),
                      );
                    }
                    listDocuments.sort((a, b) {
                      String dateStringA = a['creation_date'];
                      String dateStringB = b['creation_date'];
                      DateTime dateA =
                          DateFormat('dd/MM/yyyy hh:mm a').parse(dateStringA);
                      DateTime dateB =
                          DateFormat('dd/MM/yyyy hh:mm a').parse(dateStringB);
                      return dateB.compareTo(dateA); // Descending order
                    });

                    return ListView.builder(
                      itemCount: listDocuments.length,
                      itemExtent: 150,
                      itemBuilder: (context, index) {
                        QueryDocumentSnapshot list = listDocuments[index];
                        return listCard(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListEditorScreen(list),
                            ),
                          );
                        }, list);
                      },
                    );
                  }
                  return Text(
                    "There are no Lists",
                    style: GoogleFonts.nunito(color: Colors.white),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: BottomAppBar(
          child: Container(
            color: AppStyle.mainColor,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the buttons horizontally
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center the buttons vertically
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NoteEditorScreen(null),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                  child: const Text("New Note"),
                ),
                const SizedBox(
                    width: 16), // Add a gap of 16 pixels between the buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ListEditorScreen(null),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                  child: const Text("New List"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
