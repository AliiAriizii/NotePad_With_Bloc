import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../models/note_model.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final Box<Note> noteBox;

  NoteBloc(this.noteBox) : super(NoteInitial()) {
    on<LoadNotes>((event, emit) {
      emit(NoteLoaded(notes: noteBox.values.toList()));
    });

    on<AddNote>((event, emit) {
      noteBox.add(event.note);
      emit(NoteLoaded(notes: noteBox.values.toList()));
    });
    on<DeleteNote>((event, emit) {
      int key = event.note.key;
      noteBox.delete(key);
      emit(NoteLoaded(notes: noteBox.values.toList()));
    });
  }
}
