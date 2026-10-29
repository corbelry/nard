import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../ui/background.dart';
import '../ui/layout.dart';

/// Tab roots: Əsas and Profil (Phase 2 shows two of the five tabs).
class TabShell extends StatelessWidget {
  const TabShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: NardBackground(child: shell),
      bottomNavigationBar: NardTabBar(
        tabs: [
          NardTab(LucideIcons.home, l.tabHome),
          NardTab(LucideIcons.user, l.tabProfile),
        ],
        index: shell.currentIndex,
        onTap:
            (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}
