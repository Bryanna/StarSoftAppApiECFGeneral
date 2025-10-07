import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String path) => _db.collection(path);

  DocumentReference<Map<String, dynamic>> doc(String path) => _db.doc(path);

  Future<void> add(String collectionPath, Map<String, dynamic> data, {String? id}) async {
    final col = collection(collectionPath);
    if (id != null) {
      await col.doc(id).set(data);
    } else {
      await col.add(data);
    }
  }

  Future<void> set(String docPath, Map<String, dynamic> data, {bool merge = true}) async {
    await doc(docPath).set(data, SetOptions(merge: merge));
  }

  Future<void> update(String docPath, Map<String, dynamic> data) async {
    await doc(docPath).update(data);
  }

  Future<void> delete(String docPath) async {
    await doc(docPath).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(String collectionPath, {Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> q)? buildQuery}) {
    Query<Map<String, dynamic>> q = collection(collectionPath);
    if (buildQuery != null) q = buildQuery(q);
    return q.snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDoc(String docPath) {
    return doc(docPath).snapshots();
  }
}