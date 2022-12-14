import 'package:flutter/material.dart';
import 'package:my_services/app/shared/l10n/generated/l10n.dart';

import '../../../../injector_container.dart';
import '../../../services/auth_service/auth_service.dart';
import '../../../shared/routes/app_routes.dart';
import '../../../shared/themes/themes.dart';
import '../../../shared/widgets/custom_snack_bar/custom_snack_bar.dart';
import '../../../shared/widgets/social_login_button/social_login_button_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _login() {
    injector<AuthService>().signInWithGoogle().then((value) {
      if (value) Navigator.of(context).pushReplacementNamed(AppRoutes.app);
    }).catchError((error) {
      getCustomSnackBar(context, message: error.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: context.width,
        height: context.height,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: context.height * 0.3),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'My',
                      style: context.headlineLarge!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Text(
                      'Services',
                      style: context.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: context.height * 0.07),
                  Text(
                    AppLocalizations.current.appSubtitle,
                    textAlign: TextAlign.center,
                    style: context.headlineSmall,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 40, right: 40, top: 40),
                    child: SocialLoginButton(
                      onTap: () => _login(),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
