import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notie/screens/list_editor.dart';
import 'package:notie/screens/note_editor.dart';
import 'package:notie/screens/note_reader.dart';
import 'package:notie/style/app_style.dart';
import 'package:notie/widgets/note_card.dart';

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
        padding: const EdgeInsets.all(16.0),
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
              height: 20.0,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("notes").snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  // Checking the connection state, if still loading display loading bar
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    // Get the document list from the snapshot
                    List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

                    // Sort the documents by the creation_date property
                    documents.sort((a, b) {
                      String dateStringA = a['creation_date'];
                      String dateStringB = b['creation_date'];
                      DateTime dateA =
                          DateFormat('dd/MM/yyyy hh:mm a').parse(dateStringA);
                      DateTime dateB =
                          DateFormat('dd/MM/yyyy hh:mm a').parse(dateStringB);
                      return dateB.compareTo(dateA); // Descending order
                    });

                    return GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      children: documents
                          .map((note) => noteCard(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NoteReaderScreen(note),
                                  ),
                                );
                              }, note))
                          .toList(),
                    );
                  }
                  return Text(
                    "There's no Notes",
                    style: GoogleFonts.nunito(color: Colors.white),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: _isExpanded ? const Icon(Icons.close) : const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _isExpanded
          ? Padding(
              padding: const EdgeInsets.only(right: 18),
              child: BottomAppBar(
                child: Container(
                  color: AppStyle.mainColor, // Set the background color
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NoteEditorScreen(null),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                              100, 40), // Set the minimum size of the button
                        ),
                        child: const Text("New Note"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ListEditorScreen(null),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                              100, 40), // Set the minimum size of the button
                        ),
                        child: const Text("New List"),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
