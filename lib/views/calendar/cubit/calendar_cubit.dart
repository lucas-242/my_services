import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_services/models/service.dart';
import 'package:my_services/models/service_type.dart';
import 'package:my_services/repositories/services_repository/services_repository.dart';
import 'package:my_services/repositories/service_type_repository/service_type_repository.dart';
import 'package:my_services/services/auth_service/auth_service.dart';
import 'package:my_services/shared/utils/service_helper.dart';
import 'package:my_services/shared/utils/base_cubit.dart';
import 'package:my_services/shared/utils/base_state.dart';

import '../../../models/enums.dart';
import '../../../shared/errors/errors.dart';
import '../../../shared/extensions/extensions.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> with BaseCubit {
  final ServicesRepository _serviceProvidedRepository;
  final ServiceTypeRepository _serviceTypeRepository;
  final AuthService _authService;

  CalendarCubit(
    this._serviceProvidedRepository,
    this._serviceTypeRepository,
    this._authService,
  ) : super(CalendarState(status: BaseStateStatus.loading));

  void onInit() async {
    try {
      final range = _getRangeDateByFastSearch(state.selectedFastSearch);
      final result =
          await _fetchServices(range['startDate']!, range['endDate']!);
      _handleFetchServices(result);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError();
    }
  }

  Map<String, DateTime> _getRangeDateByFastSearch(FastSearch fastSearch) {
    final today = DateTime.now();
    DateTime startDate;
    DateTime endDate;
    switch (fastSearch) {
      case FastSearch.week:
        startDate = today.lastWeekday(DateTime.sunday);
        endDate = today.nextWeekday(DateTime.saturday);
        break;
      case FastSearch.fortnight:
        if (today.day <= 15) {
          startDate = DateTime(today.year, today.month, 1);
          endDate = DateTime(today.year, today.month, 15);
        } else {
          startDate = DateTime(today.year, today.month, 16);
          endDate = DateTime(today.year, today.month + 1, 0);
        }
        break;
      case FastSearch.month:
        startDate = DateTime(today.year, today.month, 1);
        endDate = DateTime(today.year, today.month + 1, 0);
        break;
      default:
        startDate = today;
        endDate = today;
        break;
    }
    return {
      'startDate': startDate.copyWith(hour: 0, minute: 0, second: 0),
      'endDate': endDate.copyWith(hour: 23, minute: 59, second: 59),
    };
  }

  Future<List<Service>> _fetchServices(
      DateTime startDate, DateTime endDate) async {
    final result = await _serviceProvidedRepository.get(
        _authService.user!.uid, startDate, endDate);
    return result;
  }

  Future<void> _handleFetchServices(List<Service> fetchResult) async {
    try {
      final types = await _fetchServiceTypes();
      var services = ServiceHelper.addServiceTypeToServices(fetchResult, types);
      services = orderServices(services, state.selectedOrderBy);

      final newStatus = fetchResult.isEmpty
          ? BaseStateStatus.noData
          : BaseStateStatus.success;
      emit(state.copyWith(status: newStatus, services: services));
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError();
    }
  }

  Future<List<ServiceType>> _fetchServiceTypes() async {
    final result = await _serviceTypeRepository.get(_authService.user!.uid);
    return result;
  }

  Future<void> onRefresh() async {
    try {
      emit(state.copyWith(status: BaseStateStatus.loading));
      final range = _getRangeDateByFastSearch(state.selectedFastSearch);
      final fetchResult =
          await _fetchServices(range['startDate']!, range['endDate']!);
      _handleFetchServices(fetchResult);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError();
    }
  }

  Future<void> deleteService(Service service) async {
    try {
      emit(state.copyWith(status: BaseStateStatus.loading));
      await _serviceProvidedRepository.delete(service.id);
      final newList = await _fetchServices(state.startDate, state.endDate);
      final newStatus =
          newList.isEmpty ? BaseStateStatus.noData : BaseStateStatus.success;

      emit(state.copyWith(status: newStatus, services: newList));
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError();
    }
  }

  Future<void> onChangeDate(DateTime startDate, DateTime endDate) async {
    try {
      emit(state.copyWith(
        status: BaseStateStatus.loading,
        startDate: startDate,
        endDate: endDate,
        selectedFastSearch: FastSearch.custom,
      ));
      final fetchResult = await _fetchServices(startDate, endDate);
      _handleFetchServices(fetchResult);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError();
    }
  }

  Future<void> onChageSelectedFastSearch(FastSearch fastSearch) async {
    try {
      if (fastSearch == state.selectedFastSearch) return;

      final range = _getRangeDateByFastSearch(fastSearch);

      emit(state.copyWith(
        status: BaseStateStatus.loading,
        selectedFastSearch: fastSearch,
        startDate: range['startDate']!,
        endDate: range['endDate']!,
      ));
      final fetchResult =
          await _fetchServices(range['startDate']!, range['endDate']!);
      _handleFetchServices(fetchResult);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError();
    }
  }

  void onChangeOrderBy(OrderBy orderBy) {
    final services = orderServices(state.services, orderBy);
    emit(state.copyWith(services: services, selectedOrderBy: orderBy));
  }

  @visibleForTesting
  List<Service> orderServices(List<Service> services, OrderBy orderBy) {
    switch (orderBy) {
      case OrderBy.dateAsc:
        services.sort((a, b) => a.date.compareTo(b.date));
        break;
      case OrderBy.dateDesc:
        services.sort((a, b) => b.date.compareTo(a.date));
        break;
      case OrderBy.typeAsc:
        services.sort((a, b) => a.type!.name.compareTo(b.type!.name));
        break;
      case OrderBy.typeDesc:
        services.sort((a, b) => b.type!.name.compareTo(a.type!.name));
        break;
      case OrderBy.valueAsc:
        services.sort((a, b) => a.value.compareTo(b.value));
        break;
      case OrderBy.valueDesc:
        services.sort((a, b) => b.value.compareTo(a.value));
        break;
    }
    return services;
  }

  Future<void> onChangeServices() async {
    try {
      emit(state.copyWith(status: BaseStateStatus.loading));
      final result = await _fetchServices(state.startDate, state.endDate);
      _handleFetchServices(result);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError();
    }
  }
}
