import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_taker/features/auth/services/auth_service.dart';

typedef FromMap<T> = T Function(Map<String, dynamic> data, String docId);

class FirestoreServices {
  FirestoreServices._();

  static final FirestoreServices _instance = FirestoreServices._();
  static FirestoreServices get instance => _instance;

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// ---------------- CREATE ----------------
  static Future<String> addData({
    required String collectionName,
    required Map<String, dynamic> data,
    required String id, // custom doc ID
  }) async {
    try {
      final docRef = _firestore.collection(collectionName).doc(id);
      await docRef.set(data); // set with your provided id
      return docRef.id; // return the custom doc ID
    } catch (e) {
      throw Exception('Failed to add data: $e');
    }
  }

  static Future<void> createCollectionWithDoc({
    required String collectionName,
    required String docName,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionName).doc(docName).set(data);
  }

  static Future<DocumentReference<Map<String, dynamic>>> createCollection({
    required String collectionName,
    required Map<String, dynamic> data,
  }) async {
    return await _firestore.collection(collectionName).add(data);
  }

  static Future<void> createSubCollectionWithDoc({
    required String firstCollectionName,
    required String secondCollectionName,
    required String firstDocName,
    required String secondDocName,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(firstCollectionName)
        .doc(firstDocName)
        .collection(secondCollectionName)
        .doc(secondDocName)
        .set(data);
  }

  /// ---------------- DELETE ----------------

  static Future<void> deleteData({
    required String collectionName,
    required String documentId,
  }) async {
    await _firestore.collection(collectionName).doc(documentId).delete();
  }

  static Future<void> deleteCollection({required String collectionName}) async {
    final snapshot = await _firestore.collection(collectionName).get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> deleteSubCollection({
    required String firstCollectionName,
    required String secondCollectionName,
    required String docName,
  }) async {
    final snapshot = await _firestore
        .collection(firstCollectionName)
        .doc(docName)
        .collection(secondCollectionName)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> deleteSubCollectionWithDoc({
    required String firstCollectionName,
    required String secondCollectionName,
    required String docName,
    required String subDocId,
  }) async {
    await _firestore
        .collection(firstCollectionName)
        .doc(docName)
        .collection(secondCollectionName)
        .doc(subDocId)
        .delete();
  }

  /// ---------------- UPDATE ----------------
  static Future<void> upsertData({
    required String collectionName,
    required String docName,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(collectionName)
        .doc(docName)
        .set(data, SetOptions(merge: true));
  }

  static Future<void> updateData({
    required String collectionName,
    required String docName,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionName).doc(docName).update(data);
  }

  static Future<void> updateSubCollectionDoc({
    required String firstCollectionName,
    required String secondCollectionName,
    required String firstDocName,
    required String secondDocName,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(firstCollectionName)
        .doc(firstDocName)
        .collection(secondCollectionName)
        .doc(secondDocName)
        .update(data);
  }

  /// ---------------- READ ----------------

  /// Get a whole collection as List<T>
  static Future<List<T>> getData<T>({
    required String collectionName,
    required FromMap<T> fromMap,
  }) async {
    final snapshot = await _firestore.collection(collectionName).get();
    return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
  }

  /// Get a single document
  static Future<T?> getDocData<T>({
    required String collectionName,
    required String docName,
    required FromMap<T> fromMap,
  }) async {
    final doc = await _firestore.collection(collectionName).doc(docName).get();
    if (!doc.exists) return null;
    return fromMap(doc.data()!, doc.id);
  }

  /// Get a subCollection
  static Future<List<T>> getSubCollectionDocData<T>({
    required String firstCollectionName,
    required String secondCollectionName,
    required String docName,
    required FromMap<T> fromMap,
  }) async {
    final snapshot = await _firestore
        .collection(firstCollectionName)
        .doc(docName)
        .collection(secondCollectionName)
        .get();

    return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
  }

  /// Get collection with pagination
  static Future<List<T>> getDataWithPagination<T>({
    required String collectionName,
    required int limit,
    required FromMap<T> fromMap,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(collectionName)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
  }

  /// Get subCollection with pagination
  static Future<List<T>> getSubCollectionDocDataWithPagination<T>({
    required String firstCollectionName,
    required String secondCollectionName,
    required String docName,
    required int limit,
    required FromMap<T> fromMap,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(firstCollectionName)
        .doc(docName)
        .collection(secondCollectionName)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
  }

  static Future<void> incrementField({
    required String collectionName,
    required String docName,
    required String field,
    required int byValue,
  }) async {
    await _firestore.collection(collectionName).doc(docName).set({
      field: FieldValue.increment(byValue),
    }, SetOptions(merge: true));
  }

  static Future<void> createData({
    required String collectionName,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionName).add(data);
  }

  static Stream<List<T>> streamData<T>({
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)?
    queryBuilder,
    required String collectionName,
    required T Function(Map<String, dynamic> data, String docId) fromMap,
  }) {
    // Start with the base collection reference.
    Query<Map<String, dynamic>> baseQuery = _firestore.collection(
      collectionName,
    );

    // Apply the custom query builder if provided.
    if (queryBuilder != null) {
      baseQuery = queryBuilder(baseQuery);
    }

    // Listen to snapshots and map each document to your model.
    return baseQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// ---------------- SEARCH ----------------
  static Future<List<T>> searchNotes<T>({
    required String query,
    required String about,
    required FromMap<T> fromMap,
    required String Function(T item) getTitle,
    required String Function(T item) getContent,
  }) async {
    final uid = AuthServicesImpl().currentUser()!.uid;

    final results = await FirebaseFirestore.instance
        .collection('users/$uid/$about')
        .where('tokens', arrayContains: query.toLowerCase())
        .get();

    return results.docs
        .map((doc) => fromMap(doc.data(), doc.id))
        .where(
          (item) =>
              getTitle(item).toLowerCase().contains(query.toLowerCase()) ||
              getContent(item).toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
