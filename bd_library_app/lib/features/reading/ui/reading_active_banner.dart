import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/reading_session_store.dart';
import 'end_reading_session_sheet.dart';

class ReadingActiveBanner extends StatelessWidget {
  const ReadingActiveBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingSessionStore>(
      builder: (context, store, _) {
        if (!store.hasActiveSession) return const SizedBox.shrink();
        final title = store.activeBook?.title ?? 'Livre';
        return Material(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_stories,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Séance en cours',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        ),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => showEndReadingSessionSheet(context),
                    child: const Text('Terminer'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
