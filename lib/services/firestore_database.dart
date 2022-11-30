import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:noteapp/models/masjid_model.dart';
import 'package:noteapp/models/todo_model.dart';
import 'package:noteapp/models/user_model.dart';
import 'package:noteapp/services/firestore_path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:noteapp/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();
String documentIdFromUuid() => Uuid().v1();

/*
This is the main class access/call for any UI widgets that require to perform
any CRUD activities operation in FirebaseFirestore database.
This class work hand-in-hand with FirestoreService and FirestorePath.

Notes:
For cases where you need to have a special method such as bulk update specifically
on a field, then is ok to use custom code and write it here. For example,
setAllTodoComplete is require to change all todos item to have the complete status
changed to true.

 */
class FirestoreDatabase {
  FirestoreDatabase({required this.uid}) : assert(uid != null);
  final String uid;

  final _firestoreService = FirestoreService.instance;
  // final geo = Geoflutterfire();

  //Method to create/update todoModel
  Future<void> setTodo(TodoModel todo) async => await _firestoreService.set(
        path: FirestorePath.todo(uid, todo.id),
        data: todo.toMap(),
      );

  //Method to delete todoModel entry
  Future<void> deleteTodo(TodoModel todo) async {
    await _firestoreService.deleteData(path: FirestorePath.todo(uid, todo.id));
  }

  Future<void> setMyMasjid(String masjidId, {bool isDefault = false}) async {
    if (isDefault == true)
      await _firestoreService.set(
        path: FirestorePath.user(uid),
        data: {"defaultMasjidId": masjidId},
      );
    await _firestoreService.set(
      path: FirestorePath.myMasjid(uid, masjidId),
      data: {"masjidId": masjidId, "default": isDefault},
    );
  }

  Future<void> removeMyMasjid(Masjid masjid) async {
    await _firestoreService.deleteData(
        path: FirestorePath.myMasjid(uid, masjid.id));
  }

  //Method to retrieve todoModel object based on the given todoId
  Stream<TodoModel> todoStream({required String todoId}) =>
      _firestoreService.documentStream(
        path: FirestorePath.todo(uid, todoId),
        builder: (data, documentId) => TodoModel.fromMap(data, documentId),
      );

  //Method to retrieve all todos item from the same user based on uid
  Stream<List<TodoModel>> todosStream() => _firestoreService.collectionStream(
        path: FirestorePath.todos(uid),
        builder: (data, documentId) => TodoModel.fromMap(data, documentId),
      );

  //Method to mark all todoModel to be complete
  Future<void> setAllTodoComplete() async {
    final batchUpdate = FirebaseFirestore.instance.batch();

    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirestorePath.todos(uid))
        .get();

    for (DocumentSnapshot ds in querySnapshot.docs) {
      batchUpdate.update(ds.reference, {'complete': true});
    }
    await batchUpdate.commit();
  }

  Future<void> deleteAllTodoWithComplete() async {
    final batchDelete = FirebaseFirestore.instance.batch();

    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirestorePath.todos(uid))
        .where('complete', isEqualTo: true)
        .get();

    for (DocumentSnapshot ds in querySnapshot.docs) {
      batchDelete.delete(ds.reference);
    }
    await batchDelete.commit();
  }

//Method to create/update masjid
  Future<void> setMasjid(Masjid masjid, {bool isDefault = false}) async {
    if (isDefault == true)
      await _firestoreService.set(
        path: FirestorePath.user(uid),
        data: {"defaultMasjidId": masjid.id},
      );

    await _firestoreService.set(
      path: FirestorePath.masjid(masjid.id),
      data: masjid.toMap(),
    );
  }

  Future<void> setDefaultMasjid(String masjidId) async {
    await _firestoreService.set(
      path: FirestorePath.user(uid),
      data: {"defaultMasjidId": masjidId},
    );
  }

  //Method to delete masjid entry
  Future<void> deleteMasjid(Masjid masjid) async {
    await _firestoreService.deleteData(path: FirestorePath.masjid(masjid.id));
  }

  //Method to retrieve masjid object based on the given todoId
  Stream<Masjid> masjidStream({required String masjidId}) =>
      _firestoreService.documentStream(
        path: FirestorePath.masjid(masjidId),
        builder: (data, documentId) => Masjid.fromMap(data, documentId),
      );

  //Method to retrieve all masjid item from the same user based on uid
  Stream<List<Masjid>> masjidsStream() => _firestoreService.collectionStream(
        path: FirestorePath.masjids(),
        builder: (data, documentId) => Masjid.fromMap(data, documentId),
      );

  // Stream<UserModel> userMasjidsStream() => _firestoreService.documentStream(
  //       path: FirestorePath.user(uid),
  //       builder: (data, documentId) => UserModel.fromMap(data, documentId),
  //     );

  Future<void> setAllMasjidDefaultToFalse() async {
    final batchUpdate = FirebaseFirestore.instance.batch();

    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirestorePath.myMasjids(uid))
        .get();

    for (DocumentSnapshot ds in querySnapshot.docs) {
      batchUpdate.update(ds.reference, {'default': false});
    }
    await batchUpdate.commit();
  }

  Stream<List<Masjid>> myMasjidsStream(List<String>? masjidIds) {
    print(uid);

    // print(masjidIds);
    // masjidIds = snapshots.map((snapshot) {
    //   List<String> ids = [];
    //   snapshot.map((e) {
    //     print(e.id);
    //     ids.add(e.id);
    //   });
    //   return ids;
    //   // return snapshot;
    // });

    // Stream<List<Masjid>> snapshots = _firestoreService.collectionStream(
    //   path: FirestorePath.myMasjids(uid),
    //   builder: (data, documentId) => Masjid.fromMap(data, documentId),
    // );

    // List<String> masjidIds = [];

    // snapshots.listen((masjids) {
    //   for (Masjid masjid in masjids) {
    //     masjidIds.add(masjid.id);
    //   }
    // });

    return _firestoreService.collectionStream(
      path: FirestorePath.masjids(),
      builder: (data, documentId) => Masjid.fromMap(data, documentId),
      queryBuilder: (query) {
        // return query.where(FieldPath.documentId, whereIn: masjidIds);
        return masjidIds == null || masjidIds.isEmpty
            ? query.where(FieldPath.documentId, isEqualTo: "jibberish")
            : query.where(FieldPath.documentId, whereIn: masjidIds);
      },
    );
  }

  Future<List<String>> getMyMasjidIds() async {
    Stream<List<Masjid>> snapshots = _firestoreService.collectionStream(
      path: FirestorePath.myMasjids(uid),
      builder: (data, documentId) => Masjid.fromMap(data, documentId),
    );

    List<String> masjidIds = [];

    snapshots.listen((masjids) {
      for (Masjid masjid in masjids) {
        masjidIds.add(masjid.id);
      }
    }).onDone(() {
      //run here
    });
    return masjidIds;
  }

  Stream<List<Masjid>> masjidsCreatedByMeStream() {
    return _firestoreService.collectionStream(
      path: FirestorePath.masjids(),
      builder: (data, documentId) => Masjid.fromMap(data, documentId),
      queryBuilder: (query) {
        return query.where("createdBy", isEqualTo: uid);
      },
    );
  }

  Stream<List<Masjid>> masjidsByNameStream({String name = ""}) {
    return _firestoreService.collectionStream(
      path: FirestorePath.masjids(),
      builder: (data, documentId) => Masjid.fromMap(data, documentId),
      queryBuilder: (query) {
        return query.where("enName", arrayContains: name);
      },
    );
  }

  Future<String?> getDefaultMasjidId() async {
    // var snapshot = _firestoreService.documentStream(
    //   path: FirestorePath.user(uid),
    //   builder: (data, documentId) => data,
    // );

    // return snapshot.first;

    var collection = FirebaseFirestore.instance.collection('users');
    var docSnapshot = await collection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data()!;

      // You can then retrieve the value from the Map like this:
      return data['defaultMasjidId'];
    }

    return null;
  }
}
