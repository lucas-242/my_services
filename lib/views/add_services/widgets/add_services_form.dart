import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/dropdown_item.dart';
import '../../../shared/widgets/custom_date_picker/custom_date_picker.dart';
import '../../../shared/widgets/custom_dropdown/custom_dropdown_widget.dart';
import '../../../shared/widgets/custom_elevated_button/custom_elevated_button.dart';
import '../../../shared/widgets/custom_text_form_field/custom_text_form_field.dart';
import '../cubit/add_services_cubit.dart';

class AddServicesForm extends StatefulWidget {
  final String labelButton;
  final Function() onConfirm;
  const AddServicesForm(
      {super.key, required this.labelButton, required this.onConfirm});

  @override
  State<AddServicesForm> createState() => _AddServicesFormState();
}

class _AddServicesFormState extends State<AddServicesForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionKey = GlobalKey<FormFieldState>();
  final _dateKey = GlobalKey<FormFieldState>();
  final _dropdownKey = GlobalKey<FormFieldState>();
  final _valueKey = GlobalKey<FormFieldState>();
  final _discountKey = GlobalKey<FormFieldState>();

  final valueController = TextEditingController();
  final discountController = TextEditingController();

  final dateController =
      MaskedTextController(text: 'dd/MM/yyyy', mask: '00/00/0000');

  @override
  void initState() {
    final cubit = context.read<AddServicesCubit>();
    valueController.text = cubit.state.serviceProvided.value.toString();
    discountController.text =
        cubit.state.serviceProvided.discountPercent.toString();
    dateController.text =
        DateFormat.yMd().format(cubit.state.serviceProvided.date);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ServiceTypeField(
              fieldKey: _dropdownKey,
              valueController: valueController,
              discountController: discountController,
            ),
            const SizedBox(height: 25),
            _ValueField(fieldKey: _valueKey, controller: valueController),
            const SizedBox(height: 10),
            _DiscountField(
                fieldKey: _discountKey, controller: discountController),
            const SizedBox(height: 10),
            _DateField(fieldKey: _dateKey, controller: dateController),
            const SizedBox(height: 10),
            _DescriptionField(fieldKey: _descriptionKey),
            const SizedBox(height: 15),
            CustomElevatedButton(
              onTap: () => widget.onConfirm(),
              text: widget.labelButton,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTypeField extends StatelessWidget {
  final TextEditingController valueController;
  final TextEditingController discountController;
  final GlobalKey<FormFieldState> fieldKey;
  const _ServiceTypeField({
    Key? key,
    required this.fieldKey,
    required this.valueController,
    required this.discountController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddServicesCubit>();

    return CustomDropdown(
      key: fieldKey,
      label: 'Tipo de serviço',
      hint: 'Selecione o tipo do serviço',
      items: cubit.dropdownItems,
      selectedItem: cubit.selectedDropdownItem,
      onChanged: (DropdownItem? data) {
        if (data != null) {
          cubit.onChangeServiceType(data);
          valueController.text = cubit.state.serviceProvided.value.toString();
          discountController.text =
              cubit.state.serviceProvided.discountPercent.toString();
        }
      },
      showSeach: true,
    );
  }
}

class _ValueField extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormFieldState> fieldKey;
  const _ValueField(
      {Key? key, required this.fieldKey, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddServicesCubit>();

    return SizedBox(
      child: CustomTextFormField(
        textFormKey: fieldKey,
        controller: controller,
        labelText: 'Valor total',
        keyboardType: TextInputType.number,
        onChanged: (value) => cubit.onChangeServiceValue(value),
      ),
    );
  }
}

class _DiscountField extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormFieldState> fieldKey;
  const _DiscountField(
      {Key? key, required this.fieldKey, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AddServicesCubit>();

    return SizedBox(
      child: CustomTextFormField(
        textFormKey: fieldKey,
        controller: controller,
        labelText: 'Porcentagem do desconto',
        keyboardType: TextInputType.number,
        onChanged: (value) => cubit.onChangeServiceValue(value),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final GlobalKey<FormFieldState> fieldKey;
  final MaskedTextController controller;
  const _DateField({
    Key? key,
    required this.fieldKey,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddServicesCubit>();

    return CustomDatePicker(
      fieldKey: fieldKey,
      controller: controller,
      initialDate: cubit.state.serviceProvided.date,
      onChange: (date) {
        cubit.onChangeServiceDate(date);
        controller.text = DateFormat.yMd().format(date);
      },
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final GlobalKey<FormFieldState> fieldKey;
  const _DescriptionField({Key? key, required this.fieldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddServicesCubit>();

    return CustomTextFormField(
      textFormKey: fieldKey,
      labelText: 'Descrição',
      initialValue: cubit.state.serviceProvided.description,
      onChanged: (value) => cubit.onChangeServiceDescription(value),
    );
  }
}