import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';

enum BootPhase { starting, restoringSession, ready }

class BootState {
  const BootState({
    this.phase = BootPhase.starting,
    this.ready = false,
  });

  final BootPhase phase;
  final bool ready;

  BootState copyWith({BootPhase? phase, bool? ready}) {
    return BootState(
      phase: phase ?? this.phase,
      ready: ready ?? this.ready,
    );
  }
}

final bootControllerProvider =
    NotifierProvider<BootController, BootState>(BootController.new);

/// Restores the persisted session once, then hands the router over to the
/// normal auth guard. Kept separate from [AuthController] so the boot screen
/// can report progress without making auth state a UI concern.
class BootController extends Notifier<BootState> {
  bool _started = false;

  @override
  BootState build() => const BootState();

  Future<void> run() async {
    if (_started || state.ready) return;
    _started = true;

    state = state.copyWith(phase: BootPhase.starting);
    await Future<void>.delayed(const Duration(milliseconds: 320));

    state = state.copyWith(phase: BootPhase.restoringSession);
    await Future.wait([
      ref.read(authControllerProvider.notifier).checkAuthStatus(),
      Future<void>.delayed(const Duration(milliseconds: 480)),
    ]);

    state = state.copyWith(phase: BootPhase.ready, ready: true);
  }
}
