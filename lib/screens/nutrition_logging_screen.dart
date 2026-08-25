import 'package:flutter/material.dart';

import '../models/meal_analysis.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class NutritionLoggingScreen extends StatefulWidget {
  final VoidCallback? onFoodLogged;
  final String? initialDescription;
  final MealAnalysis? initialAnalysis;

  const NutritionLoggingScreen({
    super.key,
    this.onFoodLogged,
    this.initialDescription,
    this.initialAnalysis,
  });

  @override
  State<NutritionLoggingScreen> createState() => _NutritionLoggingScreenState();
}

class _NutritionLoggingScreenState extends State<NutritionLoggingScreen> {
  final _descriptionController = TextEditingController();
  final _descriptionFocus = FocusNode();
  MealAnalysis? _analysis;
  List<Map<String, dynamic>> _logs = const [];
  NutritionTracker? _tracker;
  bool _loading = true;
  bool _estimating = false;
  bool _committing = false;
  int _trendDays = 7;

  @override
  void initState() {
    super.initState();
    _descriptionController.text =
        widget.initialDescription ?? widget.initialAnalysis?.description ?? '';
    _analysis = widget.initialAnalysis;
    _load();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final email = await ApiService.instance.getUserEmail();
      final results = await Future.wait([
        ApiService.instance.fetchNutritionLogs(email),
        ApiService.instance.fetchNutritionTracker(days: _trendDays),
      ]);
      if (!mounted) return;
      setState(() {
        final rawLogs =
            (results[0] as Map<String, dynamic>)['logs'] as List<dynamic>? ??
            [];
        _logs = rawLogs
            .whereType<Map>()
            .map((log) => Map<String, dynamic>.from(log))
            .toList();
        _tracker = results[1] as NutritionTracker;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('Could not refresh your meal tracker: $error');
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message.replaceFirst('Exception: ', ''))),
  );

  Future<void> _estimate() async {
    final description = _descriptionController.text.trim();
    if (_estimating) return;
    if (description.length < 3) {
      _showError('Please describe what you ate and how much.');
      return;
    }
    setState(() => _estimating = true);
    try {
      final result = _analysis == null
          ? await ApiService.instance.createMealAnalysis(description)
          : await ApiService.instance.updateMealAnalysis(_analysis!.id, description);
      if (mounted) setState(() => _analysis = result);
    } catch (error) {
      if (mounted) _showError(error.toString());
    } finally {
      if (mounted) setState(() => _estimating = false);
    }
  }

  Future<void> _commit() async {
    final analysis = _analysis;
    if (analysis == null || analysis.needsClarification || _committing) return;
    setState(() => _committing = true);
    try {
      final log = await ApiService.instance.commitMealAnalysis(analysis.id);
      if (!mounted) return;
      widget.onFoodLogged?.call();
      await _load();
      if (!mounted) return;
      setState(() {
        _analysis = MealAnalysis(
          id: analysis.id,
          description: analysis.description,
          mealName: analysis.mealName,
          items: analysis.items,
          calories: analysis.calories,
          proteinG: analysis.proteinG,
          carbsG: analysis.carbsG,
          fatsG: analysis.fatsG,
          assumptions: analysis.assumptions,
          needsClarification: false,
          clarificationQuestion: null,
          status: 'logged',
          mealLogId: log['id']?.toString(),
        );
      });
      final logId = log['id']?.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meal added to today’s tracker.'),
          action: logId == null
              ? null
              : SnackBarAction(
                  label: 'Undo',
                  onPressed: () async {
                    await ApiService.instance.deleteNutritionLog(logId);
                    widget.onFoodLogged?.call();
                    await _load();
                  },
                ),
        ),
      );
    } catch (error) {
      if (mounted) _showError(error.toString());
    } finally {
      if (mounted) setState(() => _committing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF202332);
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1015) : const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Meal Tracker', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                children: [
                  _summaryCard(isDark, foreground),
                  const SizedBox(height: 16),
                  _composerCard(isDark, foreground),
                  if (_analysis != null) ...[
                    const SizedBox(height: 12),
                    _analysisCard(isDark, foreground, _analysis!),
                  ],
                  const SizedBox(height: 20),
                  _quickPrefills(foreground),
                  const SizedBox(height: 24),
                  _recentMeals(isDark, foreground),
                  const SizedBox(height: 24),
                  _trendSection(isDark, foreground),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(bool isDark, Color foreground) {
    final today = _tracker?.today ?? const <String, dynamic>{};
    final calories = (today['calories'] as num?)?.round() ?? 0;
    final protein = (today['protein_g'] as num?)?.toDouble() ?? 0;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726).withValues(alpha: .16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today’s intake', style: TextStyle(color: foreground, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text('${today['meal_count'] ?? 0} meals tracked', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          _summaryMetric('$calories', 'kcal', const Color(0xFFFF8A65)),
          const SizedBox(width: 14),
          _summaryMetric(protein.toStringAsFixed(protein == protein.roundToDouble() ? 0 : 1), 'protein g', const Color(0xFF43B581)),
        ],
      ),
    );
  }

  Widget _summaryMetric(String value, String label, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(value, style: TextStyle(color: color, fontSize: 19, fontWeight: FontWeight.w900)),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w700)),
    ],
  );

  Widget _composerCard(bool isDark, Color foreground) => GlassCard(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Describe your meal', style: TextStyle(color: foreground, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text('Include food and quantity for a better estimate.', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12)),
        const SizedBox(height: 14),
        TextField(
          controller: _descriptionController,
          focusNode: _descriptionFocus,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'e.g., 3 bananas and 1 cup of yogurt',
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: .06) : const Color(0xFFF0F1F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),
        Text('We estimate nutrition from the food and portion you describe.', style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 11)),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _estimating ? null : _estimate,
            icon: _estimating
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(_estimating ? 'Estimating your meal…' : 'Estimate nutrition'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: const Color(0xFFFF9F43)),
          ),
        ),
      ],
    ),
  );

  Widget _analysisCard(bool isDark, Color foreground, MealAnalysis analysis) {
    if (analysis.needsClarification) {
      return GlassCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: Color(0xFFFFA726)),
            const SizedBox(width: 12),
            Expanded(child: Text(analysis.clarificationQuestion ?? 'Please add the food and quantity you ate.', style: TextStyle(color: foreground, fontWeight: FontWeight.w600))),
          ],
        ),
      );
    }
    final saved = analysis.status == 'logged';
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(analysis.mealName ?? 'Your meal', style: TextStyle(color: foreground, fontSize: 17, fontWeight: FontWeight.w900))),
              _badge(saved ? 'TRACKED' : 'AI ESTIMATE'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _reportMetric('${analysis.calories ?? 0}', 'kcal', const Color(0xFFFF8A65)),
              const SizedBox(width: 12),
              _reportMetric('${(analysis.proteinG ?? 0).toStringAsFixed(1)}g', 'protein', const Color(0xFF43B581)),
              const SizedBox(width: 12),
              _reportMetric('${(analysis.carbsG ?? 0).round()}g', 'carbs', const Color(0xFF4D9DE0)),
              const SizedBox(width: 12),
              _reportMetric('${(analysis.fatsG ?? 0).round()}g', 'fat', const Color(0xFFFFB347)),
            ],
          ),
          if (analysis.items.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(analysis.items.map((item) => '${item['quantity']} ${item['name']}').join(' · '), style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12)),
          ],
          if (analysis.assumptions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Assumes: ${analysis.assumptions.join(' · ')}', style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 11)),
          ],
          if (!saved) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _descriptionFocus.requestFocus, child: const Text('Edit details'))),
                const SizedBox(width: 10),
                Expanded(child: FilledButton(onPressed: _committing ? null : _commit, child: Text(_committing ? 'Adding…' : 'Add to tracker'))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: const Color(0xFF7C6CFF).withValues(alpha: .14), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(color: Color(0xFF7C6CFF), fontWeight: FontWeight.w800, fontSize: 10)),
  );

  Widget _reportMetric(String value, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10))]),
    ),
  );

  Widget _quickPrefills(Color foreground) {
    const meals = ['1 medium banana', '2 boiled eggs', '1 cup cooked rice', '1 bowl dal'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick start', style: TextStyle(color: foreground, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: meals.map((meal) => ActionChip(label: Text(meal), onPressed: () { setState(() { _descriptionController.text = meal; _analysis = null; }); _descriptionFocus.requestFocus(); })).toList(),
        ),
      ],
    );
  }

  Widget _recentMeals(bool isDark, Color foreground) {
    final date = DateTime.now().toIso8601String().substring(0, 10);
    final today = _logs.where((log) => (log['logged_at']?.toString() ?? '').startsWith(date)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today’s meals', style: TextStyle(color: foreground, fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        if (today.isEmpty)
          GlassCard(padding: const EdgeInsets.all(24), child: Center(child: Text('Your first meal will appear here.', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))))
        else
          ...today.map(_mealTile),
      ],
    );
  }

  Widget _mealTile(Map<String, dynamic> log) {
    final foreground = Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF202332);
    final macros = log['macros'] as Map? ?? const {};
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Text('🍲', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(log['food']?.toString() ?? 'Meal', style: TextStyle(color: foreground, fontWeight: FontWeight.w800)), Text('${(macros['protein'] as num?)?.toStringAsFixed(0) ?? 0}g protein', style: const TextStyle(color: Colors.grey, fontSize: 11))])),
            Text('${log['calories'] ?? 0} kcal', style: const TextStyle(color: Color(0xFFFF8A65), fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _trendSection(bool isDark, Color foreground) {
    final loggedDays = (_tracker?.series ?? const []).where((day) => (day['meal_count'] as num? ?? 0) > 0).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Text('Your trend', style: TextStyle(color: foreground, fontSize: 16, fontWeight: FontWeight.w900)), const Spacer(), ChoiceChip(label: const Text('7 days'), selected: _trendDays == 7, onSelected: (_) async { setState(() => _trendDays = 7); await _load(); }), const SizedBox(width: 6), ChoiceChip(label: const Text('30 days'), selected: _trendDays == 30, onSelected: (_) async { setState(() => _trendDays = 30); await _load(); })]),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: loggedDays.isEmpty
              ? const Padding(padding: EdgeInsets.all(10), child: Text('Log meals to see your trend.', style: TextStyle(color: Colors.grey)))
              : Column(children: loggedDays.take(7).map((day) => _trendRow(day, isDark, foreground)).toList()),
        ),
      ],
    );
  }

  Widget _trendRow(Map<String, dynamic> day, bool isDark, Color foreground) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [SizedBox(width: 76, child: Text(day['date']?.toString().substring(5) ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12))), Expanded(child: LinearProgressIndicator(value: ((day['calories'] as num? ?? 0).toDouble() / 2500).clamp(0, 1), minHeight: 7, borderRadius: BorderRadius.circular(8), color: const Color(0xFFFF9F43), backgroundColor: isDark ? Colors.white12 : Colors.black12)), const SizedBox(width: 10), Text('${day['calories'] ?? 0} kcal · ${((day['protein_g'] as num?) ?? 0).round()}g P', style: TextStyle(color: foreground, fontSize: 11, fontWeight: FontWeight.w700))]),
  );
}
