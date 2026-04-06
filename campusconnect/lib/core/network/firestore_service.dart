import 'package:cloud_firestore/cloud_firestore.dart';
import '../errors/app_errors.dart';

/// Firestore Service
/// Provides centralized Firestore operations with error handling
/// Generic CRUD methods for all collections

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get a single document from a collection
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      throw NetworkException('Failed to fetch document: $e');
    }
  }

  /// Get all documents from a collection
  Future<QuerySnapshot> getDocuments({
    required String collection,
    Query Function(Query)? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      return await query.get();
    } catch (e) {
      throw NetworkException('Failed to fetch documents: $e');
    }
  }

  /// Stream a single document
  Stream<DocumentSnapshot> streamDocument({
    required String collection,
    required String docId,
  }) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  /// Stream documents from a collection
  Stream<QuerySnapshot> streamDocuments({
    required String collection,
    Query Function(Query)? queryBuilder,
  }) {
    Query query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  /// Add a document to a collection
  Future<DocumentReference> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _firestore.collection(collection).add(data);
    } catch (e) {
      throw NetworkException('Failed to add document: $e');
    }
  }

  /// Set a document in a collection
  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).set(
            data,
            SetOptions(merge: merge),
          );
    } catch (e) {
      throw NetworkException('Failed to set document: $e');
    }
  }

  /// Update a document in a collection
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw NetworkException('Failed to update document: $e');
    }
  }

  /// Delete a document from a collection
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw NetworkException('Failed to delete document: $e');
    }
  }

  /// Batch write operations
  WriteBatch batch() {
    return _firestore.batch();
  }

  /// Commit a batch operation
  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      throw NetworkException('Failed to commit batch: $e');
    }
  }

  /// Run a transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) transactionHandler,
  ) async {
    try {
      return await _firestore.runTransaction(transactionHandler);
    } catch (e) {
      throw NetworkException('Transaction failed: $e');
    }
  }

  /// Get collection reference
  CollectionReference collection(String path) {
    return _firestore.collection(path);
  }

  /// Get document reference
  DocumentReference document(String path) {
    return _firestore.doc(path);
  }
}
