import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/game_screen.dart';

class ResultsScreen extends StatefulWidget {
  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Leaderboard")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Top Players', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('stars', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var data = users[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(data['username'] ?? 'Unknown'),
                      subtitle: Text("Stars: ${data['stars']} | Ratings: ${data['ratings']}"),
                      tileColor: index % 2 == 0 ? Colors.teal[50] : null,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GameScreen()));
              },
              child: Text("Play Again"),
            ),
          ),
        ],
      ),
    );
  }
}