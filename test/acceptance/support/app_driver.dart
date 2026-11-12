import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/di/dependency_injection.dart';
import 'package:inmonode/features/catalog/domain/project_repository.dart';
import 'package:inmonode/features/catalog/presentation/project_card.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_catalog_repository.dart';
import 'package:inmonode/features/iam/domain/auth_repository.dart';
import 'package:inmonode/features/iam/domain/session_repository.dart';
import 'package:inmonode/features/quotations/domain/quotation_repository.dart';
import 'package:inmonode/main.dart';

import 'in_memory_accounts.dart';
import 'world.dart';

/// A desktop browser window, tall enough for the back-office forms to fit without scrolling.
const Size _window = Size(1280, 4000);

/// Starts the real app, wired as in `main.dart` except that the Web Services and the device storage are
/// the in-memory ones of the scenario.
Future<void> startApp(WidgetTester tester) async {
  final world = World.current;
  tester.view.physicalSize = _window;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await getIt.reset();
  setupDependencies();
  getIt.allowReassignment = true;
  getIt.registerSingleton<AuthRepository>(world.accounts);
  getIt.registerSingleton<SessionRepository>(world.sessions);
  getIt.registerSingleton<ProjectRepository>(world.catalog.buyers);
  getIt.registerSingleton<AdminCatalogRepository>(world.catalog.admin);
  getIt.registerSingleton<QuotationRepository>(world.quotations);
  getIt.allowReassignment = false;

  await tester.pumpWidget(const MainApp());
  await tester.pumpAndSettle();
}

/// Opens the app with the session of [email] already on the device.
Future<void> startSignedIn(WidgetTester tester, String email) async {
  final world = World.current;
  world.sessions.session = world.accounts.sessionOf(email);
  await startApp(tester);
}

/// Signs in from the login page, as anyone who opens the app without a session.
Future<void> signInFromLogin(WidgetTester tester, String email) async {
  await enterField(tester, 'Correo electrónico', email);
  await enterField(tester, 'Contraseña', InMemoryAccounts.seededPassword);
  await tapButton(tester, find.widgetWithText(FilledButton, 'Iniciar sesión'));
}

Future<void> signOut(WidgetTester tester) async {
  await openSection(tester, 'Perfil');
  await tapButton(tester, find.widgetWithText(OutlinedButton, 'Cerrar sesión'));
  expect(find.widgetWithText(FilledButton, 'Iniciar sesión'), findsOneWidget);
}

/// Leaves the back-office and signs in as the seeded buyer, who lands on the project catalog.
Future<void> switchToBuyer(WidgetTester tester) async {
  await signOut(tester);
  await signInFromLogin(tester, InMemoryAccounts.buyerEmail);
  await openSection(tester, 'Proyectos');
}

/// Selects a section of the role's navigation rail.
Future<void> openSection(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(of: find.byType(NavigationRail), matching: find.text(label)));
  await tester.pumpAndSettle();
}

/// The text field whose label is [label]; a `TextFormField` builds one too.
Finder field(String label) => find.widgetWithText(TextField, label);

Future<void> enterField(WidgetTester tester, String label, String text) async {
  final target = field(label);
  await tester.ensureVisible(target);
  await tester.enterText(target, text);
  await tester.pump();
}

Future<void> tapButton(WidgetTester tester, Finder button) async {
  expect(button, findsOneWidget);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

/// The catalog card of the project [name].
Finder projectCard(String name) => find.ancestor(of: find.text(name), matching: find.byType(ProjectCard));

/// The card of the lot [code] in the back-office.
Finder adminLotCard(String code) =>
    find.ancestor(of: find.textContaining(RegExp('^${RegExp.escape(code)} · Etapa ')), matching: find.byType(Card));
