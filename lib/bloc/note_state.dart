part of 'note_bloc.dart';

abstract class NoteState {}

class NoteInitial extends NoteState {}

class NoteLoaded extends NoteState {
  final List<Note> notes;
  NoteLoaded({required this.notes});
}
