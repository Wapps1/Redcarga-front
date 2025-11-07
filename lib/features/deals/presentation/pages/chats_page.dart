import 'package:flutter/material.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Chats page', style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
