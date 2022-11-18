import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_services/shared/themes/themes.dart';
import 'package:my_services/shared/models/base_state.dart';
import 'package:my_services/views/settings/settings.dart';

import '../../../shared/widgets/custom_snack_bar/custom_snack_bar.dart';

class AddServiceTypePage extends StatefulWidget {
  const AddServiceTypePage({super.key});

  @override
  State<AddServiceTypePage> createState() => _AddServiceTypePageState();
}

class _AddServiceTypePageState extends State<AddServiceTypePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<SettingsCubit>().eraseServiceType();
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == BaseStateStatus.success) {
                Navigator.of(context).pop();
              } else if (state.status == BaseStateStatus.error) {
                getCustomSnackBar(
                  context,
                  message: state.callbackMessage,
                  type: SnackBarType.error,
                );
              }
            },
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                final label =
                    state.serviceType.id != '' ? 'Editar' : 'Adicionar';
                return Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Column(
                    children: [
                      Visibility(
                        visible: state.serviceType.id != '',
                        child: Text('$label tipo de serviço',
                            style: context.headlineSmall),
                      ),
                      Visibility(
                        visible: state.serviceType.id == '',
                        child: Text('$label tipo de serviço',
                            style: context.headlineSmall),
                      ),
                      const SizedBox(height: 25),
                      AddServiceTypeForm(
                        labelButton: label,
                        onConfirm: () => state.serviceType.id == ''
                            ? context.read<SettingsCubit>().addServiceType()
                            : context.read<SettingsCubit>().updateServiceType(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
