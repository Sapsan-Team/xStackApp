import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstackapp/main.dart' as app;

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 12),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 120));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> _chord(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
}) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pump(const Duration(milliseconds: 250));
}

/// The desktop test app can reuse a stored token between tests. Land on the
/// sign-in screen either way so each test starts from a known state.
Future<void> _ensureSignedOut(WidgetTester tester) async {
  final deadline = DateTime.now().add(const Duration(seconds: 12));
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 120));
    if (find.text('Sign in to xstack').evaluate().isNotEmpty) return;
    if (find.text('~/chats').evaluate().isNotEmpty) break;
  }
  if (find.text('~/chats').evaluate().isNotEmpty) {
    await _chord(tester, LogicalKeyboardKey.keyQ, shift: true);
    await _waitFor(tester, find.text('Sign in to xstack'));
    return;
  }
  throw TestFailure('App never reached the sign-in screen or the workspace');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign in, open a chat and send a message', (tester) async {
    try {
      await const FlutterSecureStorage().deleteAll();
    } catch (_) {}
    // Use the English UI regardless of the preferences left by manual runs.
    SharedPreferences.setMockInitialValues({'app_locale': 'en'});
    await app.main();

    await _ensureSignedOut(tester);

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), '+79990000001');
    await tester.enterText(fields.at(1), 'password123');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await _waitFor(tester, find.text('~/chats'));

    // Desktop auto-opens the first conversation.
    await _waitFor(tester, find.text('design crew'));
    await _waitFor(tester, find.text('write a message'));

    final composer = find.byType(TextField).last;
    await tester.enterText(composer, 'integration test ping');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await _waitFor(tester, find.text('integration test ping'));

    // Command palette.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await _waitFor(tester, find.text('type a command or search conversations'));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('chats'), findsWidgets);
    expect(find.text('Alice Petrova'), findsWidgets);

    // New-conversation dialog.
    await _chord(tester, LogicalKeyboardKey.keyN);
    await _waitFor(tester, find.text('new conversation'));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 250));

    // Shortcuts sheet.
    await _chord(tester, LogicalKeyboardKey.slash);
    await _waitFor(tester, find.text('keyboard shortcuts'));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 250));

    // Profile and settings.
    await _chord(tester, LogicalKeyboardKey.comma);
    await _waitFor(tester, find.text('profile'));
    expect(find.text('appearance'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 250));

    // Theme toggle should apply without leaving the workspace.
    await _chord(tester, LogicalKeyboardKey.keyL, shift: true);
    expect(find.text('chats'), findsWidgets);
  });

  testWidgets('register form validates and tabs switch with alt keys', (
    tester,
  ) async {
    try {
      await const FlutterSecureStorage().deleteAll();
    } catch (_) {}
    // Use the English UI regardless of the preferences left by manual runs.
    SharedPreferences.setMockInitialValues({'app_locale': 'en'});
    await app.main();

    await _ensureSignedOut(tester);

    Future<void> alt(LogicalKeyboardKey key) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(key);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump(const Duration(milliseconds: 250));
    }

    await alt(LogicalKeyboardKey.digit2);
    await _waitFor(tester, find.text('Create your account'));
    await alt(LogicalKeyboardKey.digit1);
    await _waitFor(tester, find.text('Sign in to xstack'));
    await alt(LogicalKeyboardKey.digit2);
    await _waitFor(tester, find.text('Create your account'));

    await tester.tap(find.widgetWithText(FilledButton, 'Register'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Enter phone number'), findsOneWidget);
    expect(find.text('Enter password'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '+79990000009');
    await tester.enterText(fields.at(1), 'short');
    await tester.tap(find.widgetWithText(FilledButton, 'Register'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });
}
