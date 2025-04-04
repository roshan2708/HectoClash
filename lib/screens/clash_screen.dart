import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../widgets/custom_button.dart';
import '../services/backend_service.dart';

class ClashScreen extends StatelessWidget {
  final String userId;
  const ClashScreen({super.key, required this.userId});

  void _startBattle(BuildContext context, String mode) async {
    String? matchId = await BackendService.startMatch(userId, mode);
    if (matchId != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => GameScreen(userId: userId, matchId: matchId)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to start match')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Let's Clash")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Choose Your Battle', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            CustomButton(text: 'Random Opponent', onPressed: () => _startBattle(context, 'random')),
            const SizedBox(height: 16),
            CustomButton(text: 'Nearby Players', onPressed: () => _startBattle(context, 'nearby')),
            const SizedBox(height: 16),
            CustomButton(text: 'Friends', onPressed: () => _startBattle(context, 'friends')),
          ],
        ),
      ),
    );
  }
}