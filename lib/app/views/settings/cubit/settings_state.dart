part of 'settings_cubit.dart';

class SettingsState extends BaseState with EquatableMixin {
  List<ServiceType> serviceTypes;
  ServiceType serviceType;
  String userId;

  SettingsState(
      {required this.userId,
      ServiceType? serviceType,
      List<ServiceType>? serviceTypeList,
      required super.status,
      super.callbackMessage})
      : serviceType = serviceType ?? ServiceType(userId: userId),
        serviceTypes = serviceTypeList ?? [];

  @override
  SettingsState copyWith({
    List<ServiceType>? serviceTypes,
    ServiceType? serviceType,
    BaseStateStatus? status,
    String? callbackMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      serviceType: serviceType ?? this.serviceType,
      serviceTypeList: serviceTypes ?? this.serviceTypes,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      userId: userId,
    );
  }

  @override
  List<Object?> get props =>
      [serviceTypes, serviceType, userId, status, callbackMessage];
}
