import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:xstackapp/core/logging/talker_service.dart';
import 'package:xstackapp/core/router/routes.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:xstackapp/features/auth/presentation/screens/login_screen.dart';
import 'package:xstackapp/features/auth/presentation/screens/register_screen.dart';
import 'package:xstackapp/features/home/presentation/screens/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthRouterNotifier(ref);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      if (state.matchedLocation == Routes.logs) {
        return null;
      }

      final authState = ref.read(authControllerProvider);
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == Routes.login;
      final isRegistering = state.matchedLocation == Routes.register;

      if (!isAuth) {
        if (!isLoggingIn && !isRegistering) {
          return Routes.login;
        }
        return null;
      }

      if (isLoggingIn || isRegistering) {
        return Routes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.logs,
        builder: (context, state) => TalkerScreen(talker: talker),
      ),
    ],
  );
});

class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(Ref ref) {
    ref.listen(
      authControllerProvider.select((s) => s.isAuthenticated),
      (previous, next) => notifyListeners(),
    );
  }
}
