import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  final String commentText;

  const CommentWidget({super.key, required this.commentText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(commentText),
        const Divider(),
      ],
    );
  }
}
