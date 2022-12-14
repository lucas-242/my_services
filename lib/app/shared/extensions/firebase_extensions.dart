import 'package:firebase_auth/firebase_auth.dart';
import '../../models/app_user.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

extension FirestoreDocumentExtension on DocumentReference {
  Future<DocumentSnapshot> getCacheFirst() async {
    try {
      DocumentSnapshot ds = await get(const GetOptions(source: Source.cache));
      if (ds.data() == null) {
        return get(const GetOptions(source: Source.server));
      }
      return ds;
    } catch (_) {
      return get(const GetOptions(source: Source.server));
    }
  }
}

extension FirestoreQueryExtension on Query {
  Future<QuerySnapshot> getCacheFirst() async {
    try {
      QuerySnapshot qs = await get(const GetOptions(source: Source.cache));
      if (qs.docs.isEmpty) {
        return get(const GetOptions(source: Source.server));
      }
      return qs;
    } catch (_) {
      return get(const GetOptions(source: Source.server));
    }
  }
}

extension FirebaseUserExtension on User {
  AppUser toAppUser() {
    return AppUser(
      uid: uid,
      email: email ?? '',
      name: displayName ?? email ?? '',
      photoUrl: photoURL,
    );
  }
}
