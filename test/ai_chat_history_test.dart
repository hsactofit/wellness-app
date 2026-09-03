import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/screens/ai_screen.dart';

void main() {
  testWidgets('chat history confirms deletion and removes the chat', (
    tester,
  ) async {
    final deletedConversationIds = <String>[];
    final conversations = <dynamic>[
      {
        'id': 'conversation-1',
        'title': 'Hydration tips',
        'last_message_preview': 'Sip water regularly.',
        'started_at': '2026-09-03T10:00:00Z',
      },
      {
        'id': 'conversation-2',
        'title': 'Sleep routine',
        'last_message_preview': 'Keep a consistent bedtime.',
        'started_at': '2026-09-02T10:00:00Z',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: AIScreen(
          listConversations: () async => conversations,
          getConversationMessages: (conversationId) async => [
            {
              'role': 'user',
              'content': conversationId == 'conversation-1'
                  ? 'Hydration tips'
                  : 'Sleep routine',
              'created_at': '2026-09-03T10:00:00Z',
            },
          ],
          deleteConversation: (conversationId) async {
            deletedConversationIds.add(conversationId);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Chat history'));
    await tester.pumpAndSettle();

    final historyTiles = find.byType(ListTile);
    expect(
      find.descendant(of: historyTiles, matching: find.text('Hydration tips')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: historyTiles, matching: find.text('Sleep routine')),
      findsOneWidget,
    );
    expect(find.byTooltip('Delete chat'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Delete chat').first);
    await tester.pumpAndSettle();
    expect(find.text('Delete chat?'), findsOneWidget);
    expect(
      find.text(
        'Delete “Hydration tips” and all of its messages? This cannot be undone.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(deletedConversationIds, ['conversation-1']);
    expect(find.text('Hydration tips'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Sleep routine'),
      ),
      findsOneWidget,
    );
    expect(find.text('Chat deleted.'), findsOneWidget);
  });

  testWidgets('cancelling chat deletion keeps the chat', (tester) async {
    var deleteCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AIScreen(
          listConversations: () async => [
            {
              'id': 'conversation-1',
              'title': 'Hydration tips',
              'last_message_preview': 'Sip water regularly.',
              'started_at': '2026-09-03T10:00:00Z',
            },
          ],
          getConversationMessages: (_) async => [
            {
              'role': 'user',
              'content': 'Hydration tips',
              'created_at': '2026-09-03T10:00:00Z',
            },
          ],
          deleteConversation: (_) async => deleteCalled = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Chat history'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete chat'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(deleteCalled, isFalse);
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Hydration tips'),
      ),
      findsOneWidget,
    );
  });
}
