import 'package:flutter/material.dart';

class MessageBox extends StatelessWidget {
  final bool isCurrentUser;
  final String message;
  const MessageBox(
      {super.key, required this.isCurrentUser, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: isCurrentUser ? Colors.green[300] : Colors.grey[400],
      ),
      child: Text(message),
    );
  }
}
