import 'package:chatgpt_gui/widgets/chat_history.dart';
import 'package:chatgpt_gui/widgets/chat_screen.dart';
import 'package:chatgpt_gui/widgets/settings_screen.dart';
import 'package:go_router/go_router.dart';

import 'utils.dart';
import 'widgets/home_screen.dart';

final router = isDesktop() ? desktopRouter : mobileRouter;
final mobileRouter = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => ChatScreen(),
  ),
  GoRoute(
    path: '/history',
    builder: (context, state) => ChatHistory(),
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) => const SettingsScreen(),
  ),
]);

final desktopRouter = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => const DesktopHomeScreen(),
  ),
  GoRoute(
    path: '/history',
    builder: (context, state) => ChatHistory(),
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) => const SettingsScreen(),
  ),
]);
