import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'duel_screen.dart';
import 'login_screen.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance;
  final _firestore = FirebaseFirestore.instance;
  final _inputController = TextEditingController(); // Added TextEditingController
  List<Map<String, dynamic>> _availablePlayers = [];
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailablePlayers();
    _loadFriends();
  }

  Future<void> _loadAvailablePlayers() async {
    setState(() => _isLoading = true);
    _database.ref("matchmaking").onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> players = [];
        for (var entry in data.entries) {
          if (entry.value['status'] == 'waiting' && entry.key != _auth.currentUser!.uid) {
            var userDoc = await _firestore.collection('users').doc(entry.key).get();
            players.add({
              'uid': entry.key,
              'username': userDoc['username'],
            });
          }
        }
        setState(() {
          _availablePlayers = players;
          _isLoading = false;
        });
      } else {
        setState(() {
          _availablePlayers = [];
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadFriends() async {
    String uid = _auth.currentUser!.uid;
    var friendsSnapshot = await _firestore.collection('users').doc(uid).collection('friends').get();
    List<Map<String, dynamic>> friendsList = [];
    for (var doc in friendsSnapshot.docs) {
      var friendDoc = await _firestore.collection('users').doc(doc.id).get();
      friendsList.add({
        'uid': doc.id,
        'username': friendDoc['username'],
      });
    }
    setState(() => _friends = friendsList);
  }

  Future<void> _startRandomMatch() async {
    setState(() => _isLoading = true);
    String uid = _auth.currentUser!.uid;
    String gameId = _database.ref("matches").push().key!;
    await _database.ref("matchmaking/$uid").set({'status': 'waiting'});
    await _database.ref("matches/$gameId").set({
      "player1": {"uid": uid, "ratings": 0},
      "status": "waiting",
    });

    _database.ref("matches/$gameId").onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> matchData = event.snapshot.value as Map<dynamic, dynamic>;
        if (matchData['status'] == 'started') {
          await _database.ref("matchmaking/$uid").remove();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DuelScreen(gameId: gameId, playerKey: "player1")),
          );
        }
      }
    });
    setState(() => _isLoading = false);
  }

  Future<void> _joinSpecificPlayer(String opponentUid) async {
    setState(() => _isLoading = true);
    String uid = _auth.currentUser!.uid;
    String gameId = _database.ref("matches").push().key!;
    await _database.ref("matches/$gameId").set({
      "player1": {"uid": opponentUid, "ratings": 0},
      "player2": {"uid": uid, "ratings": 0},
      "status": "started",
    });
    await _database.ref("matchmaking/$opponentUid").update({"status": "matched"});
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DuelScreen(gameId: gameId, playerKey: "player2")),
    );
    setState(() => _isLoading = false);
  }

  Future<void> _addFriend(String friendUsername) async {
    var friendSnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: friendUsername)
        .get();
    if (friendSnapshot.docs.isNotEmpty) {
      String friendUid = friendSnapshot.docs.first.id;
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).collection('friends').doc(friendUid).set({});
      _loadFriends();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Friend not found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HectoClash'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Matchmaking', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.shuffle),
              label: Text('Random Match'),
              onPressed: _startRandomMatch,
            ),
            SizedBox(height: 20),
            Text('Available Players', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _availablePlayers.isEmpty
                ? Text('No players available', textAlign: TextAlign.center)
                : ListView.builder(
              shrinkWrap: true,
              itemCount: _availablePlayers.length,
              itemBuilder: (context, index) {
                var player = _availablePlayers[index];
                return ListTile(
                  title: Text(player['username']),
                  trailing: ElevatedButton(
                    child: Text('Join'),
                    onPressed: () => _joinSpecificPlayer(player['uid']),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text('Friends', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              decoration: InputDecoration(
                labelText: 'Add Friend by Username',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _addFriend(_inputController.text.trim()),
                ),
              ),
              controller: _inputController,
            ),
            SizedBox(height: 10),
            _friends.isEmpty
                ? Text('No friends added', textAlign: TextAlign.center)
                : ListView.builder(
              shrinkWrap: true,
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                var friend = _friends[index];
                return ListTile(
                  title: Text(friend['username']),
                  trailing: ElevatedButton(
                    child: Text('Challenge'),
                    onPressed: () => _joinSpecificPlayer(friend['uid']),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}