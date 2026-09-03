import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/glass_card.dart';
import '../widgets/concentric_rings_chart.dart';
import '../services/auth_service.dart';

class Challenge {
  final String id;
  final String name;
  final String type;
  final String prize;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int participantCount;
  bool joined;
  double? progressPct;
  final String? metricType;
  final double? targetValue;
  final String resultStatus;
  final double? score;
  final int? rank;
  final bool isCurrentLeader;
  final bool isWinner;

  Challenge({
    required this.id,
    required this.name,
    required this.type,
    required this.prize,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.participantCount,
    required this.joined,
    required this.progressPct,
    required this.metricType,
    required this.targetValue,
    required this.resultStatus,
    required this.score,
    required this.rank,
    required this.isCurrentLeader,
    required this.isWinner,
  });

  bool get hasAutoTracking =>
      metricType != null && targetValue != null && targetValue! > 0;

  Color get color {
    switch (metricType) {
      case 'water':
        return Colors.blueAccent;
      case 'steps':
        return Colors.green;
      case 'sleep':
        return Colors.purple;
      case 'calories':
        return Colors.orange;
      default:
        return Colors.indigoAccent;
    }
  }

  String get timeLeft {
    if (resultStatus == 'finalized') return 'Finalized';
    if (resultStatus == 'calculating') return 'Results calculating';
    if (status == 'Ended') return "Ended";
    if (status == 'Scheduled') {
      if (startsAt == null) return "Upcoming";
      final diff = startsAt!.difference(DateTime.now());
      return diff.inDays > 0 ? "Starts in ${diff.inDays}d" : "Starting soon";
    }
    if (endsAt == null) return "Active";
    final diff = endsAt!.difference(DateTime.now());
    return diff.inDays > 0 ? "${diff.inDays} days left" : "Ends today";
  }

  String get metricLabel {
    if (!hasAutoTracking) return '';
    final target = targetValue!.round();
    switch (metricType) {
      case 'water':
        return "$target ml/day";
      case 'steps':
        return "$target total steps";
      case 'sleep':
        return "$target hrs/day";
      case 'calories':
        return "$target kcal/day";
      default:
        return "$target";
    }
  }

  String get verifiedScoreLabel {
    if (score == null) return '';
    if (metricType == 'steps') return '${score!.round()} verified steps';
    if (metricType == 'water') return '${score!.round()} qualifying days';
    return score!.toStringAsFixed(0);
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'Individual',
      prize: json['prize'] as String? ?? '',
      status: json['status'] as String? ?? 'Scheduled',
      startsAt: DateTime.tryParse(json['starts_at'] as String? ?? ''),
      endsAt: DateTime.tryParse(json['ends_at'] as String? ?? ''),
      participantCount: json['participant_count'] as int? ?? 0,
      joined: json['joined'] as bool? ?? false,
      progressPct: (json['progress_pct'] as num?)?.toDouble(),
      metricType: json['metric_type'] as String?,
      targetValue: (json['target_value'] as num?)?.toDouble(),
      resultStatus: json['result_status'] as String? ?? 'pending',
      score: (json['score'] as num?)?.toDouble(),
      rank: json['rank'] as int?,
      isCurrentLeader: json['is_current_leader'] as bool? ?? false,
      isWinner: json['is_winner'] as bool? ?? false,
    );
  }
}

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int _userPoints = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<Challenge> _challenges = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool showLoadingIndicator = true}) async {
    await Future.wait([
      _fetchPointsBalance(),
      _fetchChallenges(showLoadingIndicator: showLoadingIndicator),
    ]);
  }

  Future<void> _fetchPointsBalance() async {
    try {
      final token = await AuthService.instance.getAccessToken();
      final response = await http.get(
        AuthService.apiUrl('/api/rewards/balance'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _userPoints = data['balance'] as int? ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching points balance: $e");
    }
  }

  Future<void> _fetchChallenges({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final token = await AuthService.instance.getAccessToken();
      final url = AuthService.apiUrl('/api/challenges');

      var response = await http.get(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        await AuthService.instance.refreshSessionToken();
        final newToken = await AuthService.instance.getAccessToken();
        response = await http.get(
          url,
          headers: {if (newToken != null) 'Authorization': 'Bearer $newToken'},
        );
      }

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        final fetched = list.map((json) => Challenge.fromJson(json)).toList();
        setState(() {
          _challenges = fetched;
        });
      } else {
        setState(() {
          _errorMessage =
              "Failed to load challenges from server (${response.statusCode})";
        });
      }
    } catch (e) {
      debugPrint("Error loading challenges: $e");
      setState(() {
        _errorMessage = "Failed to connect to server: $e";
      });
    } finally {
      if (showLoadingIndicator) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _joinChallenge(Challenge challenge) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final token = await AuthService.instance.getAccessToken();
      final url = AuthService.apiUrl('/api/challenges/${challenge.id}/join');

      var response = await http.post(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        await AuthService.instance.refreshSessionToken();
        final newToken = await AuthService.instance.getAccessToken();
        response = await http.post(
          url,
          headers: {if (newToken != null) 'Authorization': 'Bearer $newToken'},
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          challenge.joined = true;
        });
        await _fetchChallenges(showLoadingIndicator: false);
        await _fetchPointsBalance();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Joined ${challenge.name} challenge!"),
            backgroundColor: challenge.color,
          ),
        );
      } else {
        final detail = jsonDecode(response.body)['detail']?.toString();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              detail ?? "Failed to join challenge: ${response.statusCode}",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error joining challenge: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    if (_errorMessage != null) {
      return Scaffold(
        body: Container(
          color: isDark ? const Color(0xFF0F0F12) : const Color(0xFFF6F8FC),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("⚠️", style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        body: Container(
          color: isDark ? const Color(0xFF0F0F12) : const Color(0xFFF6F8FC),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0F0F12) : const Color(0xFFF6F8FC),
            ),
          ),
          Positioned(
            top: -50,
            left: -50,
            width: 250,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withValues(alpha: isDark ? 0.15 : 0.1),
                    Colors.blue.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              color: Colors.blueAccent,
              onRefresh: () async {
                await _loadData(showLoadingIndicator: false);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Challenges 🏆",
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                            Text(
                              "Join company challenges and follow verified scores",
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text("🪙 ", style: TextStyle(fontSize: 14)),
                              Text(
                                "$_userPoints Pts",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildProgressCard(isDark),
                    const SizedBox(height: 24),

                    Text(
                      "Active Challenges",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_challenges.where((c) => c.joined).isEmpty)
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 16,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Text(
                                "🧗‍♂️",
                                style: TextStyle(fontSize: 36),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No Active Challenges",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Join a challenge below to start tracking your progress & earning rewards!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._challenges
                          .where((c) => c.joined)
                          .map(
                            (c) => Column(
                              children: [
                                _buildChallengeCard(c, isDark),
                                const SizedBox(height: 14),
                              ],
                            ),
                          ),

                    const SizedBox(height: 12),

                    Text(
                      "Explore New Challenges",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_challenges.where((c) => !c.joined).isEmpty)
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Text("🎉", style: TextStyle(fontSize: 32)),
                              const SizedBox(height: 8),
                              Text(
                                "You have joined all challenges!",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Stay tuned for new events.",
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._challenges
                          .where((c) => !c.joined)
                          .map(
                            (c) => Column(
                              children: [
                                _buildUpcomingChallengeCard(c, isDark),
                                const SizedBox(height: 14),
                              ],
                            ),
                          ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(bool isDark) {
    final activeChallenges = _challenges.where((c) => c.joined).toList();
    final ringsData = activeChallenges.isEmpty
        ? [
            ConcentricRingData(
              value: 0.0,
              color: Colors.grey.withValues(alpha: 0.2),
              label: "No active challenges",
            ),
          ]
        : activeChallenges.map((c) {
            return ConcentricRingData(
              value: ((c.progressPct ?? 0.0) / 100).clamp(0.0, 1.0),
              color: c.color,
              label: c.name,
            );
          }).toList();

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CHALLENGES OVERVIEW",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white60 : Colors.black54,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blueAccent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${activeChallenges.length} ACTIVE",
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueAccent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 170,
            height: 145,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: ConcentricRingsChart(rings: ringsData),
                ),
                Positioned(
                  left: 82,
                  top: 76,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "$_userPoints",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            "pts",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Total Points",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            color: isDark ? Colors.white10 : Colors.black12,
            height: 32,
            thickness: 1,
          ),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: activeChallenges.map((c) {
              final pct = (c.progressPct ?? 0.0).round();
              return _buildLegendItem(
                "${c.name.split(' ').first}: $pct%",
                c.color,
                isDark,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard(Challenge challenge, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final color = challenge.color;
    final progressPct = challenge.progressPct;
    final progressVal = ((progressPct ?? 0.0) / 100).clamp(0.0, 1.0);
    final isCompleted = (progressPct ?? 0.0) >= 100.0;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  challenge.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  challenge.timeLeft,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.hasAutoTracking
                ? "${challenge.type} · Goal: ${challenge.metricLabel}"
                : challenge.type,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (challenge.score != null || challenge.rank != null) ...[
            const SizedBox(height: 7),
            Text(
              [
                if (challenge.score != null) challenge.verifiedScoreLabel,
                if (challenge.rank != null) 'Rank #${challenge.rank}',
              ].join(' · '),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("👥 ", style: TextStyle(fontSize: 12)),
                  Text(
                    "${challenge.participantCount} participants",
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (challenge.prize.isNotEmpty)
                Row(
                  children: [
                    const Text("🏆 ", style: TextStyle(fontSize: 12)),
                    Text(
                      challenge.prize,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (challenge.isWinner)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '🏆 You are the final winner. Your organization will contact you about the prize.',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            )
          else if (challenge.isCurrentLeader &&
              challenge.resultStatus == 'pending')
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'You are currently leading. The winner is decided after the timeline and sync grace period.',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else if (challenge.resultStatus == 'calculating')
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Challenge ended — calculating verified results during the sync grace period.',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ),
          if (progressPct != null || challenge.hasAutoTracking) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progressVal,
                minHeight: 6,
                backgroundColor: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05),
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCompleted ? "Verified target reached" : "Verified progress",
                  style: TextStyle(color: secondaryTextColor, fontSize: 11),
                ),
                Text(
                  "${(progressVal * 100).round()}%",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              "Verified progress will appear after your activity syncs.",
              style: TextStyle(color: secondaryTextColor, fontSize: 11.5),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingChallengeCard(Challenge challenge, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final color = challenge.color;
    final canJoin =
        (challenge.status == 'Live' || challenge.status == 'Scheduled') &&
        challenge.resultStatus == 'pending';

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  challenge.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
              Text(
                challenge.timeLeft,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.hasAutoTracking
                ? "${challenge.type} · Goal: ${challenge.metricLabel}"
                : challenge.type,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (challenge.resultStatus == 'calculating') ...[
            const SizedBox(height: 8),
            const Text(
              'Challenge ended — results are calculating.',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("👥 ", style: TextStyle(fontSize: 12)),
                  Text(
                    "${challenge.participantCount} joined",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                  if (challenge.prize.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    const Text("🏆 ", style: TextStyle(fontSize: 12)),
                    Text(
                      challenge.prize,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canJoin
                      ? color
                      : Colors.grey.withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                ),
                onPressed: canJoin ? () => _joinChallenge(challenge) : null,
                child: Text(
                  canJoin ? "Join Challenge" : challenge.timeLeft,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
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
