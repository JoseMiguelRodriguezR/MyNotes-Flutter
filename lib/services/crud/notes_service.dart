// import 'dart:async';

// import 'package:firstapp/extensions/list/filter.dart';
// import 'package:firstapp/services/crud/crud_exceptions.dart';
// import 'package:flutter/foundation.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';

// // Fichero que comunica la aplicación Flutter con la BD de SQLite (local) !!!
// // Dejaremos de uasr este fichero cuando paselos al Cloud (remoto).

// const dbName = 'notes.db'; // DB name
// const noteTable = 'note'; // tables names
// const userTable = 'user';

// const idColumn = 'id';  // column identifiers
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';

// const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
//         "id"	INTEGER NOT NULL,
//         "user_id"	INTEGER NOT NULL,
//         "text"	TEXT,
//         "is_synced_with_cloud"	BLOB NOT NULL DEFAULT 0,
//         FOREIGN KEY("user_id") REFERENCES "user"("id"),
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );''';

// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
// 	      "id"	INTEGER NOT NULL,
// 	      "email"	TEXT NOT NULL UNIQUE,
// 	      PRIMARY KEY("id" AUTOINCREMENT)
//       );''';

// // class that allows the CRUD service that works with our DB.
// class NotesService {
//   Database? _db;

//   List<DatabaseNote> _notes = [];

//   DatabaseUser? _user;  //user should be set before reading all notes (for security).
//                         //crud_exception created "UserShouldBeSetBeforeAllNotes".
  
//   // Define NotesService as a SINGLETON --------
//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance(){
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );

//   }
//   factory NotesService() => _shared;
//   //--------------------------------------------

//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   Stream<List<DatabaseNote>> get allNotes => 
//   _notesStreamController.stream.filter((note) {
//     final currentUser = _user;
//     if (currentUser != null){
//       return note.userId == currentUser.id;
//     } else {
//       throw UserShouldBeSetBeforeAllNotes();
//     }
//   } );

//   // function to cash (add) the STREAM data from the DB. 
//   Future<void> _cashNotes() async{
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }
  
//   // open DB connection ------
//   Future<void> open() async {
//     if (_db != null){
//       throw DatabaseAlreadyOpenException();
//     }
//     try{
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;

//       // CREATE THE USER TABLE
//       // we add "IF NOT EXISTS"
//       await db.execute(createUserTable);
//       await db.execute(createNoteTable);
//       await _cashNotes(); // reads the notes and places them into the STREAM.

//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectory();
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try{
//       await open();
//     } on DatabaseAlreadyOpenException {
//       //empty
//     }
//   }

//   Future<void> close() async{
//     final db = _db;
//     if (db == null){
//       throw DatabaseIsNotOpen();
//     } else {
//       await db.close();
//       _db = null; // to reset the DB
//     }
    
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if(db == null){
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }

//   // user functions ----------
//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable, 
//       where: 'email = ?', 
//       whereArgs: [email.toLowerCase()],
//     );
//     // remember that the users ara UNIQUE per email.
//     if (deletedCount != 1){
//       throw CouldNotDeleteUser();
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isNotEmpty){
//       throw UserAlreadyExists();
//     }

//     final userId =  await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });

//     return DatabaseUser(
//       id: userId,
//       email: email,
//     );
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );    

//     if (results.isEmpty){
//       throw CouldNotFindUser();
//     } else {
//       return DatabaseUser.fromRow(results.first);
//     }
//   }

//   Future<DatabaseUser> getOrCreateUser({required String email, bool setAsCurrentUser = true}) async {
//     try{
//       final user = await getUser(email: email);
//       if (setAsCurrentUser){
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUser{
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser){
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow; // only for debug.
//     }
    
//   }

//   // notes functions ---------
//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
    
//     // make sure owner exists in the DB with the correct id.
//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFindUser();
//     }

//     const text = '';
//     // create the notes
//     final noteId = await db.insert(noteTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });

//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );

//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       noteTable, 
//       where: 'id = ?', 
//       whereArgs: [id],
//     );

//     if (deletedCount == 0){
//       throw CouldNotDeleteNote();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletions = await db.delete(noteTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return numberOfDeletions;
//   }

//   //take the id of a note and return the information
//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (notes.isEmpty) {
//       throw CouldNotFindNote();
//     } else {
//       final note =  DatabaseNote.fromRow(notes.first);
//       // remove old note with dame id and add the new one
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       // update stream
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(
//       noteTable
//     );

//     return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
//   }

//   Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async { 
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     //make sure note exists
//     await getNote(id: note.id);

//     //update DB
//     final updatesCount = await db.update(
//       noteTable, 
//       {
//         textColumn: text,
//         isSyncedWithCloudColumn: 0, 
//       }, 
//       where: 'id = ?',  //el id de la columna a la que nos estamos refiriendo.
//       whereArgs: [note.id],
//     );

//     if (updatesCount == 0){
//       throw CouldNotUpdateNote();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       _notes.removeWhere((note) => note.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);
//       return updatedNote;

//     }
//   } 
// }


// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;
//   const DatabaseUser({
//     required this.id, 
//     required this.email,
//   });

//   // constructor
//   DatabaseUser.fromRow(Map<String, Object?> map) 
//     : id = map[idColumn] as int, 
//       email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person, ID = $id, email = $email';
  
//   // "covariant" permite cambiar el comportamiento de la variable de entrada
//   // donde deberia ir un objeto de tipo "Object" ahora podemos usar objetos "DatabaseUser".
//   @override bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }


// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;
  
//   const DatabaseNote({
//     required this.id, 
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseNote.fromRow(Map<String, Object?> map) 
//     : id = map[idColumn] as int, 
//       userId = map[userIdColumn] as int,
//       text = map[textColumn] as String,
//       isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;


//   @override
//   String toString() => 'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';
  
//   @override bool operator ==(covariant DatabaseNote other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

