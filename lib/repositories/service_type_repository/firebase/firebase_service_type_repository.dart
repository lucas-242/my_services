import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_services/shared/errors/errors.dart';
import 'package:my_services/models/service_type.dart';
import 'package:my_services/repositories/service_type_repository/service_type_repository.dart';
import 'package:my_services/shared/extensions/extensions.dart';
import 'package:my_services/shared/l10n/generated/l10n.dart';

class FirebaseServiceTypeRepository extends ServiceTypeRepository {
  final FirebaseFirestore _firestore;

  @visibleForTesting
  String get path => 'serviceTypes';

  FirebaseServiceTypeRepository(FirebaseFirestore firestore)
      : _firestore = firestore;

  @override
  Future<ServiceType> add(ServiceType serviceType) async {
    try {
      final data = serviceType.toMap();
      final document = await _firestore.collection(path).add(data);
      final result = serviceType.copyWith(id: document.id);
      return result;
    } catch (exception) {
      throw ExternalError(AppLocalizations.current.errorToAddServiceType,
          trace: exception.toString());
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _firestore.collection(path).doc(id).delete();
    } catch (exception) {
      throw ExternalError(AppLocalizations.current.errorToDeleteServiceType,
          trace: exception.toString());
    }
  }

  @override
  Future<List<ServiceType>> get(String userId) async {
    try {
      final query = await _firestore
          .collection(path)
          .where('userId', isEqualTo: userId)
          .getCacheFirst();

      final result = query.docs.map((DocumentSnapshot snapshot) {
        final data = snapshot.data() as Map<String, dynamic>;
        return ServiceType.fromMap(data).copyWith(id: snapshot.id);
      }).toList();

      return result;
    } catch (exception) {
      throw ExternalError(AppLocalizations.current.errorToGetServiceTypes,
          trace: exception.toString());
    }
  }

  @override
  Future<void> update(ServiceType serviceType) async {
    try {
      final data = serviceType.toMap();
      await _firestore.collection(path).doc(serviceType.id).update(data);
    } catch (exception) {
      throw ExternalError(AppLocalizations.current.errorToUpdateServiceType,
          trace: exception.toString());
    }
  }
}
