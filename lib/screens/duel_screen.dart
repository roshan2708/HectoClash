import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puzzle.dart';
import '../results_screen.dart';

class DuelScreen extends StatefulWidget {
  final String gameId;
  final String playerKey;

  DuelScreen({required this.gameId, required this.playerKey});

  @override
  _DuelScreenState createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> {
  final _database = FirebaseDatabase.instance;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late Puzzle _puzzle;
  final _answerController = TextEditingController();
  String _resultMessage = '';
  int userRatings = 0;
  int opponentRatings = 0;

  @override
  void initState() {
    super.initState();
    _puzzle = Puzzle.generate();
    _listenToGameUpdates();
  }

  void _listenToGameUpdates() {
    _database.ref("matches/${widget.gameId}").onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          userRatings = (data[widget.playerKey]?['ratings'] ?? 0);
          opponentRatings = (data[widget.playerKey == "player1" ? "player2" : "player1"]?['ratings'] ?? 0);
        });

        if (userRatings >= 100) {
          await _endMatch(true);
        } else if (opponentRatings >= 100) {
          await _endMatch(false);
        }
      }
    });
  }

  Future<void> _submitAnswer() async {
    String userExpression = _answerController.text.trim();
    bool isCorrect = _puzzle.isSolutionValid(userExpression);

    setState(() {
      _resultMessage = isCorrect ? 'Correct! $userExpression equals 100' : 'Incorrect. Try again.';
    });

    if (isCorrect) {
      DatabaseReference playerRef = _database.ref("matches/${widget.gameId}/${widget.playerKey}/ratings");
      DataSnapshot snapshot = await playerRef.get();
      int currentRatings = (snapshot.value as int?) ?? 0;
      await playerRef.set(currentRatings + 10);

      setState(() {
        _puzzle = Puzzle.generate();
        _answerController.clear();
        _resultMessage = '';
      });
    }
  }

  Future<void> _endMatch(bool isWinner) async {
    String uid = _auth.currentUser!.uid;
    if (isWinner) {
      await _firestore.collection('users').doc(uid).update({
        'stars': FieldValue.increment(1),
      });
    }
    await _database.ref("matches/${widget.gameId}").remove();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResultsScreen()));
  }

  void _addToAnswer(String value) {
    setState(() {
      _answerController.text += value;
    });
  }

  void _clearAnswer() {
    setState(() {
      _answerController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HectoClash Duel")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("You: $userRatings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Opponent: $opponentRatings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 20),
            Text('Sequence: ${_puzzle.sequence}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Make it equal 100', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'Enter expression',
              ),
              readOnly: true,
            ),
            SizedBox(height: 20),
            _buildCalculatorPanel(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAnswer,
              child: Text("Submit"),
            ),
            SizedBox(height: 20),
            Text(_resultMessage, style: TextStyle(fontSize: 18, color: Colors.teal)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorPanel() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _calcButton('1'), _calcButton('2'), _calcButton('3'), _calcButton('+'),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _calcButton('4'), _calcButton('5'), _calcButton('6'), _calcButton('-'),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _calcButton('7'), _calcButton('8'), _calcButton('9'), _calcButton('*'),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _calcButton('0'), _calcButton('/'), _calcButton('('), _calcButton(')'),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calcButton('C', onPressed: _clearAnswer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcButton(String value, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed ?? (() => _addToAnswer(value)),
      child: Text(value, style: TextStyle(fontSize: 20)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(60, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}