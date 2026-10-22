import 'package:flutter/material.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

String failureCode(Failure failure) {
  return switch (failure) {
    AuthFailure(type: AuthFailureType.invalidCredentials) =>
      'auth/invalid-credentials',
    AuthFailure(type: AuthFailureType.sessionExpired) => 'auth/session-expired',
    NetworkFailure() => 'net/unreachable',
    ServerFailure(statusCode: 409) => 'account/conflict',
    ServerFailure() => 'server/error',
    ValidationFailure() => 'form/invalid',
    CacheFailure() => 'local/cache',
  };
}

/// Compiler-diagnostic style error line: one code, one sentence.
class FailureBanner extends StatelessWidget {
  const FailureBanner({
    super.key,
    required this.failure,
    this.onDismiss,
    this.compact = false,
  });

  final Failure failure;
  final VoidCallback? onDismiss;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: compact ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: colors.dangerMuted,
        border: Border.all(color: colors.danger.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '!',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.danger,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  failureCode(failure),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.danger,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  failure.localizedMessage(l10n),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    height: 1.45,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            InkWell(
              onTap: onDismiss,
              borderRadius: BorderRadius.circular(3),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '×',
                  style: TextStyle(fontSize: 14, color: colors.textMuted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
