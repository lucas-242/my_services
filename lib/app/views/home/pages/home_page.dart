import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../shared/l10n/generated/l10n.dart';
import '../../../shared/themes/themes.dart';
import '../../calendar/calendar.dart';
import '../cubit/home_cubit.dart';

import '../../../shared/routes/app_routes.dart';
import '../../../models/service.dart';
import '../../../shared/utils/base_state.dart';
import '../../../shared/widgets/custom_elevated_button/custom_elevated_button.dart';
import '../../../shared/widgets/custom_snack_bar/custom_snack_bar.dart';
import '../../../shared/widgets/order_by_bottom_sheet/order_by_bottom_sheet.dart';
import '../../../shared/widgets/service_list/service_list.dart';
import '../../add_services/cubit/add_services_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    final cubit = context.read<HomeCubit>();
    cubit.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.current.home, style: context.titleLarge),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.read<HomeCubit>().signOut(),
          icon: const Icon(Icons.logout),
        ),
        actions: [
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => OrderByBottomSheet(
                onPressed: (orderBy) {
                  Navigator.of(context).pop();
                  context.read<HomeCubit>().onChangeOrderBy(orderBy);
                },
              ),
            ),
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addServices),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().onRefresh(),
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
            child: BlocListener<HomeCubit, HomeState>(
              listenWhen: (previous, current) =>
                  previous.status != current.status,
              listener: (context, state) {
                if (state.status == BaseStateStatus.error) {
                  getCustomSnackBar(
                    context,
                    message: state.callbackMessage,
                    type: SnackBarType.error,
                  );
                }
              },
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  return state.when(
                    onState: (_) => _Build(state: state),
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
      ),
    );
  }
}

class _Build extends StatelessWidget {
  final HomeState state;
  const _Build({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void onDelete(Service service) async {
      final calendarCubit = context.read<CalendarCubit>();
      await context.read<HomeCubit>().deleteService(service);
      calendarCubit.onChangeServices();
    }

    void onEdit(Service service) async {
      context.read<AddServicesCubit>().onChangeService(service);
      Navigator.pushNamed(context, AppRoutes.addServices);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ServiceList(
          title: DateFormat.MMMMd().format(DateTime.now()),
          services: state.services,
          totalValue: state.totalValue,
          totalDiscounted: state.totalDiscounted,
          totalWithDiscount: state.totalWithDiscount,
          onTapEdit: onEdit,
          onTapDelete: onDelete,
        ),
      ],
    );
  }
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            '${AppLocalizations.current.noServicesOnDay} ${DateFormat.MMMMd().format(DateTime.now())} ',
            style: context.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          CustomElevatedButton(
            onTap: () => Navigator.pushNamed(context, AppRoutes.addServices),
            text: AppLocalizations.current.addNewService,
          ),
        ],
      ),
    );
  }
}
