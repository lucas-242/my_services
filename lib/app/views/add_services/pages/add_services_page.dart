import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_services/app/shared/l10n/generated/l10n.dart';
import '../../../app_cubit.dart';
import '../../../models/service.dart';
import '../../../shared/themes/themes.dart';
import '../../../shared/utils/base_state.dart';
import '../../calendar/calendar.dart';
import '../../home/cubit/home_cubit.dart';

import '../../../shared/widgets/custom_elevated_button/custom_elevated_button.dart';
import '../../../shared/widgets/custom_snack_bar/custom_snack_bar.dart';
import '../cubit/add_services_cubit.dart';
import '../widgets/add_services_form.dart';

class AddServicesPage extends StatefulWidget {
  const AddServicesPage({super.key});

  @override
  State<AddServicesPage> createState() => _AddServicesPageState();
}

class _AddServicesPageState extends State<AddServicesPage> {
  @override
  void initState() {
    context.read<AddServicesCubit>().onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final label = context.read<AddServicesCubit>().state.service.id != ''
        ? AppLocalizations.current.update
        : AppLocalizations.current.add;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$label ${AppLocalizations.current.service.toLowerCase()}',
          style: context.titleLarge,
        ),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocListener<AddServicesCubit, AddServicesState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == BaseStateStatus.success) {
                context.read<HomeCubit>().onChangeServices();
                context.read<CalendarCubit>().onChangeServices();
                Navigator.of(context).pop();
              } else if (state.status == BaseStateStatus.error) {
                getCustomSnackBar(
                  context,
                  message: state.callbackMessage,
                  type: SnackBarType.error,
                );
              }
            },
            child: BlocBuilder<AddServicesCubit, AddServicesState>(
              builder: (context, state) {
                return state.when(
                  onState: (_) => _Build(service: state.service),
                  onLoading: () => SizedBox(
                    height: context.height,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  onNoData: () => const _NoData(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Build extends StatelessWidget {
  final Service service;
  const _Build({required this.service});

  @override
  Widget build(BuildContext context) {
    final label = service.id != ''
        ? AppLocalizations.current.update
        : AppLocalizations.current.add;

    void onConfirm() {
      if (service.id.isEmpty) {
        context.read<AddServicesCubit>().addService();
      } else {
        context.read<AddServicesCubit>().updateService();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 25),
        AddServicesForm(
          labelButton: label,
          onConfirm: () => onConfirm(),
        ),
      ],
    );
  }
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.current.noServiceTypes,
          style: context.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 25),
        CustomElevatedButton(
          onTap: () {
            Navigator.of(context).pop();
            context.read<AppCubit>().changePage(2);
          },
          text: AppLocalizations.current.addNewServiceType,
        ),
      ],
    );
  }
}
