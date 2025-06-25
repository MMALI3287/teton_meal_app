import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/menu_poll_card.dart';

class PollsByDatePage extends StatelessWidget {
  final List<QueryDocumentSnapshot> polls;

  const PollsByDatePage({super.key, required this.polls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders by Date'),
      ),
      body: ListView.builder(
        itemCount: polls.length,
        itemBuilder: (context, index) {
          return MenuPollCard(pollData: polls[index]);
        },
      ),
    );
  }
}
