import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bloc/note_bloc.dart';
import 'models/note_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  var noteBox = await Hive.openBox<Note>('notes');

  runApp(MyApp(noteBox: noteBox));
}

class MyApp extends StatelessWidget {
  final Box<Note> noteBox;
  MyApp({required this.noteBox});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NoteBloc(noteBox)..add(LoadNotes()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NoteScreen(),
      ),
    );
  }
}

class NoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NotePad")),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NoteLoaded) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  return GestureDetector(
                    onTap: () {

                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Color(note.color),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Expanded(
                            child: Text(
                              note.content,
                              style: TextStyle(fontSize: 14),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _showEditNoteDialog(context, note);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    context.read<NoteBloc>().add(DeleteNote(note: note));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddNoteDialog(context);
        },
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    int selectedColor = Colors.white.value;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
              TextField(controller: contentController, decoration: InputDecoration(labelText: "Content")),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _colorBox(Colors.red.value, selectedColor, (color) {
                    selectedColor = color;
                  }),
                  _colorBox(Colors.blue.value, selectedColor, (color) {
                    selectedColor = color;
                  }),
                  _colorBox(Colors.green.value, selectedColor, (color) {
                    selectedColor = color;
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final note = Note(
                  title: titleController.text,
                  content: contentController.text,
                  color: selectedColor,
                );
                context.read<NoteBloc>().add(AddNote(note: note));
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showEditNoteDialog(BuildContext context, Note note) {
    TextEditingController titleController = TextEditingController(text: note.title);
    TextEditingController contentController = TextEditingController(text: note.content);
    int selectedColor = note.color;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
              TextField(controller: contentController, decoration: InputDecoration(labelText: "Content")),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _colorBox(Colors.red.value, selectedColor, (color) {
                    selectedColor = color;
                  }),
                  _colorBox(Colors.blue.value, selectedColor, (color) {
                    selectedColor = color;
                  }),
                  _colorBox(Colors.green.value, selectedColor, (color) {
                    selectedColor = color;
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final updatedNote = Note(
                  title: titleController.text,
                  content: contentController.text,
                  color: selectedColor,
                );
                context.read<NoteBloc>().add(UpdateNote(note: updatedNote));
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _colorBox(int color, int selectedColor, Function(int) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        width: 30,
        height: 30,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Color(color),
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
