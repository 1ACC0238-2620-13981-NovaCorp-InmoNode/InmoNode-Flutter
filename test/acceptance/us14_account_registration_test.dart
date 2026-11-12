// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@Tags(['acceptance', 'US-14'])
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_visitor_opens_inmonode_without_a_session.dart';
import './step/the_visitor_signs_up_as_with_a_valid_password.dart';
import './step/the_account_is_created_as_inactive.dart';
import './step/a_singleuse_verification_link_is_emailed_to.dart';
import './step/the_visitor_is_asked_to_open_the_link_sent_to.dart';
import './step/an_account_already_exists_for.dart';
import './step/the_signup_is_rejected_with.dart';
import './step/no_new_account_is_created_for.dart';
import './step/the_visitor_is_offered_the_password_recovery_flow.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Web account registration''', () {
    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''Account creation and validation''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Account creation and validation''');
        await theVisitorOpensInmonodeWithoutASession(tester);
        await theVisitorSignsUpAsWithAValidPassword(tester, 'ana@mail.com');
        await theAccountIsCreatedAsInactive(tester, 'ana@mail.com');
        await aSingleuseVerificationLinkIsEmailedTo(tester, 'ana@mail.com');
        await theVisitorIsAskedToOpenTheLinkSentTo(tester, 'ana@mail.com');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Account creation and validation''',
          success,
        );
      }
    });
    testWidgets('''Email already registered''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Email already registered''');
        await anAccountAlreadyExistsFor(tester, 'luis@mail.com');
        await theVisitorOpensInmonodeWithoutASession(tester);
        await theVisitorSignsUpAsWithAValidPassword(tester, 'luis@mail.com');
        await theSignupIsRejectedWith(tester,
            'El correo ya está registrado; usa la recuperación de contraseña');
        await noNewAccountIsCreatedFor(tester, 'luis@mail.com');
        await theVisitorIsOfferedThePasswordRecoveryFlow(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Email already registered''',
          success,
        );
      }
    });
  });
}
