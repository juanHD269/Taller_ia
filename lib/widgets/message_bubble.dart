import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const MessageBubble({Key? key, required this.text, required this.isMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isMe ? Colors.blueAccent : Colors.grey.shade300;
    final fgColor = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text, style: TextStyle(color: fgColor)),
      ),
    );
  }
}