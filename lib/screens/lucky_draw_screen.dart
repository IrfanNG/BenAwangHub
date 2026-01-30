import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../services/lucky_draw_service.dart';

class LuckyDrawScreen extends StatefulWidget {
  final String eventId;

  const LuckyDrawScreen({super.key, required this.eventId});

  @override
  State<LuckyDrawScreen> createState() => _LuckyDrawScreenState();
}

class _LuckyDrawScreenState extends State<LuckyDrawScreen> {
  List<Map<String, String>> eligibleTickets = [];
  bool isLoading = true;
  bool isSpinning = false;
  String currentNumber = "000";
  Timer? _timer;
  final Random _random = Random();

  List<Map<String, String>> sessionWinners = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() => isLoading = true);
    try {
      final tickets = await LuckyDrawService.getEligibleTickets(widget.eventId);
      setState(() {
        eligibleTickets = tickets;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
<<<<<<< HEAD
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
=======
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
    }
  }

  void _startSpin() {
    if (eligibleTickets.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No eligible tickets!")));
      return;
    }

    setState(() => isSpinning = true);

    // Rapidly change numbers
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (eligibleTickets.isEmpty) return; // Safety
      final randomTicket =
          eligibleTickets[_random.nextInt(eligibleTickets.length)];
      setState(() {
        currentNumber = randomTicket["number"] ?? "000";
      });
    });
  }

  Future<void> _stopSpin() async {
    _timer?.cancel();

    if (eligibleTickets.isEmpty) return;

    // Pick a winner randomly
    final winnerIndex = _random.nextInt(eligibleTickets.length);
    final winnerTicket = eligibleTickets[winnerIndex];

    setState(() {
      currentNumber = winnerTicket["number"]!;
      isSpinning = false;
    });

    // Save winner
    try {
      await LuckyDrawService.saveWinner(widget.eventId, winnerTicket);

      // Update local state
      setState(() {
        sessionWinners.add(winnerTicket);
        // Remove from eligible so they can't win again immediately (optional logic, but standard)
        eligibleTickets.removeAt(winnerIndex);
      });

      if (mounted) {
        _showWinnerDialog(winnerTicket["number"]!);
      }
    } catch (e) {
<<<<<<< HEAD
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving winner: $e")));
      }
=======
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving winner: $e")));
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
    }
  }

  void _showWinnerDialog(String number) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.amber.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "🎉 WE HAVE A WINNER! 🎉",
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            Text(
              number,
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Awesome!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B), // Dark background for contrast
      appBar: AppBar(
        title: const Text("Lucky Draw"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                "LUCKY NUMBER",
                style: TextStyle(
                  color: Colors.amber.shade400,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 40),

              // The Slot Machine Display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  currentNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontFamily: "monospace", // Monospaced for stability
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Control Button
              if (!isLoading)
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSpinning ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                    ),
                    onPressed: eligibleTickets.isEmpty
                        ? null
                        : (isSpinning ? _stopSpin : _startSpin),
                    child: Text(
                      isSpinning ? "STOP" : "SPIN!",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              if (eligibleTickets.isEmpty && !isLoading)
                const Text(
                  "No more eligible tickets!",
                  style: TextStyle(color: Colors.white54),
                ),

              const Spacer(),

              // Recent Winners
              if (sessionWinners.isNotEmpty) ...[
                const Text(
                  "Session Winners",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sessionWinners.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            sessionWinners[index]["number"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
