import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:inmonode/core/di/dependency_injection.dart';
import 'package:inmonode/core/theme.dart';
import 'package:inmonode/features/iam/presentation/email_link.dart';
import 'package:inmonode/features/iam/presentation/session_view_model.dart';
import 'package:inmonode/features/main/app_entry.dart';

void main() {
  // Clean Web URLs (/verify-email instead of /#/verify-email), as the account emails expect.
  usePathUrlStrategy();
  setupDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = const TextTheme();
    return MaterialApp(
      title: 'InmoNode',
      debugShowCheckedModeBanner: false,
      theme: MaterialTheme(textTheme).light(),
      darkTheme: MaterialTheme(textTheme).dark(),
      // On Web the app can open at /verify-email?token=... or /reset-password?token=...;
      // any route lands on the app entry.
      onGenerateInitialRoutes: (initialRoute) => [
        _entryRoute(EmailLink.from(Uri.tryParse(initialRoute))),
      ],
      onGenerateRoute: (_) => _entryRoute(null),
    );
  }

  static Route<void> _entryRoute(EmailLink? emailLink) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: '/'),
      builder: (_) => AppEntry(
        sessionViewModel: getIt<SessionViewModel>(),
        emailLink: emailLink,
      ),
    );
  }
}
