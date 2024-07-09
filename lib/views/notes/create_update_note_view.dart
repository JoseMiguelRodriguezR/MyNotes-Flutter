import 'package:firstapp/services/auth/auth_service.dart';
import 'package:firstapp/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:firstapp/utilities/generics/get_arguments.dart';
import 'package:flutter/material.dart';
import 'package:firstapp/services/cloud/cloud_note.dart';
import 'package:firstapp/services/cloud/cloud_storage_exceptions.dart';
import 'package:firstapp/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({ Key? key }) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;


  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }


  // FUNCTIONALITIES -------
  //
  bool isExistingNote(BuildContext context) {
    final widgetNote = context.getArgument<CloudNote>();
    
    if (widgetNote != null){
      _note = widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null){
      return true;
    }

    return false;
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async{

    final widgetNote = context.getArgument<CloudNote>(); // inside "<>" we write the type of data we want to extract.
    
    if (widgetNote != null){
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null){
      return existingNote;
    } 
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote; 
  }

  // DELETE note
  void _deleteNoteIfTextIsEmpty(){
    // if the TextController detects no input in the "New Note" interface, the note will be deleted (we don't want empty notes).
    final note = _note;
    if (_textController.text.isEmpty && note != null){
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  // UPDATE note
  void _saveNoteIfTextNotEmpty() async{
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty){
      await _notesService.updateNote(documentId: note.documentId, text: text);
    }
  }
  
  // UPDATE our current note upon text changes.dart'
  void _textControllerListener() async{
    final note = _note;
    if (note == null){
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(documentId: note.documentId, text: text);
  }
  
  void _setupTextControllerListener(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }
  // ------------------------
 
 
  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }



  // UI --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isExistingNote(context)?
          const Text(''): 
          const Text('New Note'),
        actions: [
          IconButton(
            onPressed: () async{
              final text = _textController.text;
              if (_note == null || text.isEmpty){
                await showCannotShareEmptyNoteDialog(context);
              } else{
                Share.share(text);          //USAMOS EL PLUGIN PARA COMPARTIR EL TEXTO DE LA NOTA.
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body:  FutureBuilder(
        future: createOrGetExistingNote(context), 
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration( hintText: 'Start typing your note...' ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}