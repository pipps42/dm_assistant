// lib/shared/layouts/desktop_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/shared/layouts/sidebar_navigation.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

class DesktopShell extends ConsumerWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const DesktopShell({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          const SidebarNavigation(),

          // Main content area
          Expanded(
            child: Column(
              children: [
                // App bar
                if (title != null)
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerColor.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: AppDimens.spacingL),
                        Expanded(
                          child: Text(
                            title!,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        if (actions != null) ...actions!,
                        const SizedBox(width: AppDimens.spacingL),
                      ],
                    ),
                  ),

                // Content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
