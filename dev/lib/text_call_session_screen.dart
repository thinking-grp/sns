import 'package:flutter/material.dart';

class TextCallSessionScreen extends StatelessWidget {
  const TextCallSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Call Session'),
      ),
      body: const Center(
        child: Text('Text Call Session Screen'),
      ),
    );
  }
}