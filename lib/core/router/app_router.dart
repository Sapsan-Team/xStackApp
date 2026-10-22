import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:xstackapp/core/logging/talker_service.dart';
import 'package:xstackapp/core/router/routes.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:xstackapp/features/auth/presentation/screens/login_screen.dart';
import 'package:xstackapp/features/auth/presentation/screens/register_screen.dart';
import 'package:xstackapp/features/boot/presentation/controllers/boot_controller.dart';
import 'package:xstackapp/features/boot/presentation/screens/boot_screen.dart';
import 'package:xstackapp/features/chat/presentation/screens/workspace_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: Routes.boot,
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      if (state.matchedLocation == Routes.logs) {
        return null;
      }

      final boot = ref.read(bootControllerProvider);
      final atBoot = state.matchedLocation == Routes.boot;

      if (!boot.ready) {
        return atBoot ? null : Routes.boot;
      }

      final authState = ref.read(authControllerProvider);
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == Routes.login;
      final isRegistering = state.matchedLocation == Routes.register;

      if (atBoot) {
        return isAuth ? Routes.home : Routes.login;
      }

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
        path: Routes.boot,
        builder: (context, state) => const BootScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const WorkspaceScreen(),
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

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(
      authControllerProvider.select((s) => s.isAuthenticated),
      (previous, next) => notifyListeners(),
    );
    ref.listen(
      bootControllerProvider.select((s) => s.ready),
      (previous, next) => notifyListeners(),
    );
  }
}
