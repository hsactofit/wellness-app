import 'package:flutter/material.dart';

import '../models/meal_analysis.dart';
import 'nutrition_logging_screen.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

/// Real chat backed by /api/ai/chat — plain Q&A only, deliberately no
/// function-calling/action-logging (that would double the API cost per
/// message: one call for the model to request a tool, another for the
/// final reply). Server rate-limits messages per day; a 429 surfaces the
/// real limit message as a bot reply rather than a generic error.
class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  String? _conversationId;
  bool _isSending = false;
  bool _isLoadingHistory = false;

  final List<String> _suggestions = [
    "How can I sleep better?",
    "Suggest a healthy snack",
    "How to burn 500 kcal?",
    "Tips for staying hydrated",
  ];

  @override
  void initState() {
    super.initState();
    _bootstrapChat();
  }

  Future<void> _bootstrapChat() async {
    setState(() => _isLoadingHistory = true);
    try {
      final conversations = await ApiService.instance.listAiChatConversations();
      if (conversations.isNotEmpty) {
        final latest = Map<String, dynamic>.from(conversations.first as Map);
        final id = latest['id']?.toString();
        if (id != null) {
          final items = await ApiService.instance.getAiChatConversationMessages(
            id,
          );
          if (items.isNotEmpty && mounted) {
            setState(() {
              _conversationId = id;
              _messages
                ..clear()
                ..addAll(_messagesFromHistory(items));
            });
            _scrollToBottom();
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Chat history bootstrap failed: $e");
    } finally {
      if (mounted) setState(() => _isLoadingHistory = false);
    }

    _loadInitialGreeting();
  }

  List<Map<String, dynamic>> _messagesFromHistory(List<dynamic> items) {
    return items.whereType<Map>().map((raw) {
      final message = Map<String, dynamic>.from(raw);
      final role = (message['role'] as String? ?? '').toLowerCase();
      return {
        'isUser': role == 'user',
        'text': message['content'] as String? ?? '',
        'time': _formatTime(message['created_at'] as String?),
        if (message['meal_analysis'] is Map)
          'mealAnalysis': Map<String, dynamic>.from(
            message['meal_analysis'] as Map,
          ),
      };
    }).toList();
  }

  void _loadInitialGreeting() {
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..add({
          'isUser': false,
          'text':
              "Hi! I'm your fitness coach. ✨ Ask me about sleep, nutrition, hydration, or general fitness tips.",
          'time': "Just now",
        });
    });
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return "Just now";
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return "$h:$m";
    } catch (_) {
      return "Just now";
    }
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _messages.add({'isUser': true, 'text': trimmed, 'time': "Just now"});
      _messageController.clear();
    });
    _scrollToBottom();

    final typingIndex = _messages.length;
    setState(() {
      _messages.add({
        'isUser': false,
        'text': "Thinking...",
        'time': "Just now",
        'isTyping': true,
      });
    });
    _scrollToBottom();

    try {
      final resData = await ApiService.instance.sendAiChatMessage(
        message: trimmed,
        conversationId: _conversationId,
      );

      if (!mounted) return;

      final String reply =
          resData['reply'] as String? ?? "I couldn't process that.";
      final String? convId = resData['conversation_id'] as String?;

      setState(() {
        if (convId != null) _conversationId = convId;
        _messages[typingIndex] = {
          'isUser': false,
          'text': reply,
          'time': "Just now",
          if (resData['meal_analysis'] is Map)
            'mealAnalysis': Map<String, dynamic>.from(
              resData['meal_analysis'] as Map,
            ),
        };
        _isSending = false;
      });
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      debugPrint("AI chat error: $e");
      if (!mounted) return;
      setState(() {
        _messages[typingIndex] = {
          'isUser': false,
          'text': message.isNotEmpty
              ? message
              : "I'm having trouble connecting right now. Please try again.",
          'time': "Just now",
        };
        _isSending = false;
      });
    }
    _scrollToBottom();
  }

  Future<void> _startNewConversation() async {
    if (_isSending) return;
    setState(() {
      _conversationId = null;
      _messages.clear();
    });
    _loadInitialGreeting();
  }

  Future<void> _openConversationHistory() async {
    if (_isSending || _isLoadingHistory) return;

    final conversationsFuture = ApiService.instance.listAiChatConversations();
    final selectedConversationId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final sheetTheme = Theme.of(sheetContext);
        final sheetIsDark = sheetTheme.brightness == Brightness.dark;
        final sheetTextColor = sheetIsDark ? Colors.white : Colors.black87;
        return FractionallySizedBox(
          heightFactor: 0.68,
          child: Container(
            decoration: BoxDecoration(
              color: sheetIsDark ? const Color(0xFF151B1B) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
            ),
            child: SafeArea(
              top: false,
              child: FutureBuilder<List<dynamic>>(
                future: conversationsFuture,
                builder: (context, snapshot) {
                  Widget content;
                  if (snapshot.connectionState != ConnectionState.done) {
                    content = const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  } else if (snapshot.hasError) {
                    content = Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Could not load your chat history. Please try again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: sheetIsDark
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ),
                    );
                  } else {
                    final conversations = snapshot.data ?? const <dynamic>[];
                    content = conversations.isEmpty
                        ? Center(
                            child: Text(
                              'Your previous chats will appear here.',
                              style: TextStyle(
                                color: sheetIsDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                            itemCount: conversations.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              color: sheetIsDark
                                  ? Colors.white10
                                  : Colors.black12,
                            ),
                            itemBuilder: (context, index) {
                              final raw = conversations[index];
                              if (raw is! Map) return const SizedBox.shrink();
                              final conversation = Map<String, dynamic>.from(
                                raw,
                              );
                              final id = conversation['id']?.toString();
                              if (id == null) return const SizedBox.shrink();
                              final title =
                                  (conversation['title'] as String? ?? '')
                                      .trim();
                              final preview =
                                  (conversation['last_message_preview']
                                              as String? ??
                                          '')
                                      .trim();
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                leading: Icon(
                                  Icons.forum_outlined,
                                  color: id == _conversationId
                                      ? const Color(0xFFFF7A53)
                                      : (sheetIsDark
                                            ? Colors.white60
                                            : Colors.black54),
                                ),
                                title: Text(
                                  title.isEmpty ? 'New conversation' : title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: sheetTextColor,
                                    fontWeight: id == _conversationId
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  preview.isEmpty
                                      ? _formatConversationDate(
                                          conversation['started_at'] as String?,
                                        )
                                      : preview,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: sheetIsDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                                trailing: id == _conversationId
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFFFF7A53),
                                        size: 20,
                                      )
                                    : null,
                                onTap: () => Navigator.of(sheetContext).pop(id),
                              );
                            },
                          );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Chat history',
                                style: sheetTheme.textTheme.titleLarge
                                    ?.copyWith(
                                      color: sheetTextColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              icon: Icon(
                                Icons.close_rounded,
                                color: sheetIsDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: content),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (selectedConversationId != null && mounted) {
      await _loadConversation(selectedConversationId);
    }
  }

  Future<void> _loadConversation(String conversationId) async {
    if (_isSending || _isLoadingHistory) return;
    setState(() => _isLoadingHistory = true);
    try {
      final items = await ApiService.instance.getAiChatConversationMessages(
        conversationId,
      );
      if (!mounted) return;
      setState(() {
        _conversationId = conversationId;
        _messages
          ..clear()
          ..addAll(_messagesFromHistory(items));
      });
      _scrollToBottom();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  String _formatConversationDate(String? iso) {
    if (iso == null || iso.isEmpty) return 'Earlier conversation';
    try {
      final date = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return 'Today, ${_formatTime(iso)}';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        return 'Yesterday, ${_formatTime(iso)}';
      }
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return 'Earlier conversation';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0B1010) : const Color(0xFFF6F8FC),
            ),
          ),
          Positioned(
            top: -110,
            right: -70,
            width: 280,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(
                      0xFF27D7A1,
                    ).withValues(alpha: isDark ? 0.13 : 0.08),
                    const Color(0xFF27D7A1).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: -140,
            width: 280,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(
                      0xFFFF8A4C,
                    ).withValues(alpha: isDark ? 0.07 : 0.05),
                    const Color(0xFFFF8A4C).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.045)
                          : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.09)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9A5B), Color(0xFFEE6254)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFF7A53,
                                ).withValues(alpha: 0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: Colors.white,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Fitness Coach",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.25,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2EE5A3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Ready for your next rep",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Chat history',
                          onPressed: _isSending || _isLoadingHistory
                              ? null
                              : _openConversationHistory,
                          icon: Icon(
                            Icons.history_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                            size: 22,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _isSending ? null : _startNewConversation,
                          icon: const Icon(
                            Icons.add_comment_outlined,
                            size: 17,
                          ),
                          label: const Text('New'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF7A53),
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoadingHistory
                      ? const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isUser = msg['isUser'] as bool;
                            return _buildChatBubble(
                              msg['text'] as String,
                              isUser,
                              isDark,
                              isTyping: msg['isTyping'] == true,
                              analysis: msg['mealAnalysis'] is Map
                                  ? MealAnalysis.fromJson(
                                      Map<String, dynamic>.from(
                                        msg['mealAnalysis'] as Map,
                                      ),
                                    )
                                  : null,
                              onCommit: () => _commitChatAnalysis(index),
                            );
                          },
                        ),
                ),
                if (!_isLoadingHistory &&
                    _messages.where((m) => m['isUser'] == true).isEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final text = _suggestions[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            elevation: 0,
                            pressElevation: 0,
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.055)
                                : Colors.white.withValues(alpha: 0.9),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                            avatar: Icon(
                              [
                                Icons.nightlight_round,
                                Icons.restaurant_menu_rounded,
                                Icons.local_fire_department_rounded,
                                Icons.water_drop_rounded,
                              ][index],
                              size: 14,
                              color: const Color(0xFFFF8A4C),
                            ),
                            label: Text(
                              text,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: _isSending
                                ? null
                                : () => _sendMessage(text),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 96,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: TextField(
                            controller: _messageController,
                            enabled: !_isSending,
                            style: TextStyle(color: textColor, fontSize: 14),
                            onSubmitted: (v) => _sendMessage(v),
                            decoration: InputDecoration(
                              hintText:
                                  "Ask your coach about your next workout…",
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white30 : Colors.black38,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF8A4C), Color(0xFFEF5D51)],
                          ),
                        ),
                        child: IconButton(
                          icon: _isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          onPressed: _isSending
                              ? null
                              : () => _sendMessage(_messageController.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
    String text,
    bool isUser,
    bool isDark, {
    bool isTyping = false,
    MealAnalysis? analysis,
    VoidCallback? onCommit,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? null
              : (isDark
                    ? Colors.white.withValues(alpha: 0.045)
                    : Colors.white.withValues(alpha: 0.82)),
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFFFF8A4C), Color(0xFFEF5D51)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser
                ? const Color(0xFFFFB27D).withValues(alpha: 0.65)
                : (isDark ? Colors.white10 : Colors.black12),
          ),
        ),
        child: isTyping
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? Colors.tealAccent : Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  if (!isUser && analysis != null) ...[
                    const SizedBox(height: 10),
                    _mealAnalysisCard(analysis, isDark, onCommit),
                  ],
                ],
              ),
      ),
    );
  }

  Future<void> _commitChatAnalysis(int index) async {
    final raw = _messages[index]['mealAnalysis'];
    if (raw is! Map) return;
    final analysis = MealAnalysis.fromJson(Map<String, dynamic>.from(raw));
    if (analysis.needsClarification || analysis.status == 'logged') return;
    try {
      await ApiService.instance.commitMealAnalysis(analysis.id);
      if (!mounted) return;
      setState(() {
        final updated = Map<String, dynamic>.from(raw);
        updated['status'] = 'logged';
        _messages[index]['mealAnalysis'] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal added to your tracker.')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  Widget _mealAnalysisCard(
    MealAnalysis analysis,
    bool isDark,
    VoidCallback? onCommit,
  ) {
    final saved = analysis.status == 'logged';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: .18)
            : const Color(0xFFFFF5EE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            analysis.needsClarification
                ? 'Tell me a little more'
                : 'AI meal estimate',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFF8A4C),
            ),
          ),
          if (!analysis.needsClarification) ...[
            const SizedBox(height: 4),
            Text(
              '${analysis.calories ?? 0} kcal · ${(analysis.proteinG ?? 0).toStringAsFixed(1)}g protein',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            NutritionLoggingScreen(initialAnalysis: analysis),
                      ),
                    );
                  },
                  child: Text(
                    analysis.needsClarification ? 'Edit details' : 'Review',
                  ),
                ),
              ),
              if (!analysis.needsClarification && !saved) ...[
                const SizedBox(width: 4),
                Expanded(
                  child: FilledButton(
                    onPressed: onCommit,
                    child: const Text('Add to tracker'),
                  ),
                ),
              ],
              if (saved)
                const Expanded(
                  child: Text(
                    'Tracked',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF43B581),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
