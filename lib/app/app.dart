import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'shared/themes/themes.dart';
import 'views/add_services/add_services.dart';
import '../injector_container.dart';
import 'repositories/service_type_repository/service_type_repository.dart';
import 'services/auth_service/auth_service.dart';
import 'services/time_service/time_service.dart';
import 'views/calendar/calendar.dart';
import 'views/home/cubit/home_cubit.dart';
import 'views/settings/settings.dart';
import 'app_cubit.dart';
import 'app_scaffold.dart';
import 'repositories/services_repository/services_repository.dart';
import 'shared/l10n/generated/l10n.dart';
import 'shared/routes/app_routes.dart';
import 'views/login/login.dart';
import 'views/splash/pages/splash_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(
            create: (_) => AppCubit(locator.get<AuthService>())),
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(
            locator.get<ServiceTypeRepository>(),
            locator.get<ServicesRepository>(),
            locator.get<AuthService>(),
          ),
        ),
        BlocProvider<HomeCubit>(
          create: (_) => HomeCubit(
            locator.get<ServicesRepository>(),
            locator.get<ServiceTypeRepository>(),
            locator.get<AuthService>(),
          ),
          lazy: true,
        ),
        BlocProvider<AddServicesCubit>(
          create: (_) => AddServicesCubit(
            locator.get<ServicesRepository>(),
            locator.get<ServiceTypeRepository>(),
            locator.get<AuthService>(),
          ),
          lazy: true,
        ),
        BlocProvider<CalendarCubit>(
          create: (_) => CalendarCubit(
            locator.get<ServicesRepository>(),
            locator.get<ServiceTypeRepository>(),
            locator.get<AuthService>(),
            locator.get<TimeService>(),
          ),
          lazy: true,
        ),
      ],
      child: ThemeService(
        settings: lightThemeSettings,
        child: Builder(
          builder: ((context) {
            var appTheme = ThemeService.of(context);
            return MaterialApp(
              title: 'My Services',
              debugShowCheckedModeBanner: false,
              theme: appTheme.light(lightThemeSettings.sourceColor),
              darkTheme: appTheme.dark(darkThemeSettings.sourceColor),
              themeMode: lightThemeSettings.themeMode,
              initialRoute: AppRoutes.splash,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.delegate.supportedLocales,
              routes: {
                AppRoutes.splash: (context) => const SplashPage(),
                AppRoutes.app: (context) => const AppScaffold(),
                AppRoutes.login: (context) => const LoginPage(),
                AppRoutes.addServiceType: (context) =>
                    const AddServiceTypePage(),
                AppRoutes.addServices: (context) => const AddServicesPage(),
              },
            );
          }),
        ),
      ),
    );
  }
}