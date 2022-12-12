import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_services/models/service.dart';

import '../../../../models/service_type.dart';

class FirebaseServiceModel extends Service {
  FirebaseServiceModel({
    required super.id,
    required super.description,
    required super.value,
    required super.discountPercent,
    super.type,
    required super.typeId,
    required super.date,
    required super.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'value': value,
      'typeId': typeId,
      'discountPercent': discountPercent,
      'date': Timestamp.fromDate(date),
      'userId': userId,
    };
  }

  factory FirebaseServiceModel.fromMap(Map<String, dynamic> map) {
    return FirebaseServiceModel(
      id: map['id'] ?? '',
      description: map['description'],
      value: map['value']?.toDouble(),
      discountPercent: map['discountPercent']?.toDouble(),
      type: map['type'] != null ? ServiceType.fromMap(map['type']) : null,
      typeId: map['typeId'],
      date: DateTime.fromMillisecondsSinceEpoch(
          map['date'].millisecondsSinceEpoch),
      userId: map['userId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory FirebaseServiceModel.fromJson(String source) =>
      FirebaseServiceModel.fromMap(json.decode(source));

  factory FirebaseServiceModel.fromService(Service source) =>
      FirebaseServiceModel(
        id: source.id,
        description: source.description,
        value: source.value,
        discountPercent: source.discountPercent,
        typeId: source.typeId,
        date: source.date,
        userId: source.userId,
      );
}