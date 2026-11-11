import 'package:flutter/material.dart';

class ShellSection {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder builder;

  const ShellSection({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });
}

/// Main navigation of a role: a bottom bar on phones and a side rail on wide screens (Web).
///
/// Sections keep their state while the user switches between them.
class RoleShell extends StatefulWidget {
  static const double railBreakpoint = 840;

  final List<ShellSection> sections;

  const RoleShell({super.key, required this.sections});

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int selectedIndex = 0;

  void _select(int index) => setState(() => selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final sections = widget.sections;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= RoleShell.railBreakpoint;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (wide) ...[
                  NavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: _select,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final section in sections)
                        NavigationRailDestination(
                          icon: Icon(section.icon),
                          selectedIcon: Icon(section.selectedIcon),
                          label: Text(section.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                ],
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: [
                      for (final section in sections) Builder(builder: section.builder),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: _select,
                  destinations: [
                    for (final section in sections)
                      NavigationDestination(
                        icon: Icon(section.icon),
                        selectedIcon: Icon(section.selectedIcon),
                        label: section.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}
