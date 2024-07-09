/*
  Servicio que gestiona las llamadas a BD y sus funcionalidades (incluyendo las CRUD).
  Al ser SINGLETON, solo existe una instancia de esta clase para todo el programa
  a la cual se puede acceder globalmente en todo el sistema.
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstapp/services/cloud/cloud_note.dart';
import 'package:firstapp/services/cloud/cloud_storage_constants.dart';
import 'package:firstapp/services/cloud/cloud_storage_exceptions.dart';
import 'package:firstapp/services/crud/crud_exceptions.dart';

class FirebaseCloudStorage{

  // Grab all notes from Firestore
  final notes = FirebaseFirestore.instance.collection("notes");


  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
    notes.snapshots()                                   // Nos subscribimos al STREAM de datos (para poder ver los cambios en vivo).
    .map((event) => event.docs                          // dentro del STREAM se mueven "QuerySnapshot"s.
    .map((doc) => CloudNote.fromSnapshot(doc))          // dentro de "QuerySnapshot" hay un DOCUMENT que para poder tratarlo, 
                                                        //    lo mapeamos con nuestra función "fromSnapshot"      
    .where((note) => note.ownerUserId == ownerUserId)   // después del mapeo, ya podemos tratar con la NOTA.
    );

  // GET notes by user Id. --> Va a buscar la info directamente en la BD.
  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try{
      return await notes
        .where(        // OJO! where devuelve una QUERY, para ejecutarla 
          ownerUserIdFieldName,   // usamos una de sus funcionalidades, ex. ".get()"
          isEqualTo: ownerUserId,
        )
        .get()                   // obtenemos un FUTURE, que podemos tratar con ".then()"
        .then(
          (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
        );
    } catch(e){
      throw CouldNotGetAllNotesException();
    }
  }


  // C in CRUD (create)
  Future<CloudNote> createNewNote({required String ownerUserId}) async{  // ASYNC devuelve un FUTURE
    final document = await notes.add({                                    // entonces, importante poner el AWAIT.          
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchedNote = await document.get();   // "document" es una referencia, no un snapshot
    return CloudNote(                           // por eso le hacemos el "get()"
      documentId: fetchedNote.id, 
      ownerUserId: ownerUserId, 
      text: '',
    );
  }

  // U in CRUD (update)
  Future<void> updateNote({required String documentId, required String text,}) async {
    try{
      await notes.doc(documentId).update({textFieldName: text});
    } catch(e){
      throw CouldNotUpdateNoteException();
    }
  }

  // D in CRUD (delete)
  Future<void> deleteNote({required String documentId}) async {
    try{
      await notes.doc(documentId).delete();
    } catch(e){
      throw CouldNotDeleteNoteException();
    }
  }

  // Define FirebaseCloudStorage as a SINGLETON --------
  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance(); 
  factory FirebaseCloudStorage() => _shared;
  //--------------------------------------------

}
  

