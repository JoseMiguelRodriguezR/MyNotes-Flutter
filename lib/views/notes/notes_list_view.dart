import 'package:firstapp/services/cloud/cloud_note.dart';
import 'package:firstapp/utilities/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  // Firebase works with ITERABLES.
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;
  const NotesListView({ 
    Key? key, 
    required this.notes, 
    required this.onDeleteNote,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index){
        final note = notes.elementAt(index);    // Iterables not longer work like this "notes[index]".
        return ListTile(
          onTap: (){
            onTap(note);
          },
          title: Text(
            note.text,
            maxLines:1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete){
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}