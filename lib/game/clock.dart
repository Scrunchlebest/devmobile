import 'package:flutter/material.dart';

class ChessClock extends StatelessWidget {
  final int whiteTime;
  final int blackTime;

  const ChessClock({super.key, required this.whiteTime, required this.blackTime});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Text(
              "${(whiteTime ~/ 60).toString().padLeft(2, '0')}:${(whiteTime % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black,
            child: Text(
              "${(blackTime ~/ 60).toString().padLeft(2, '0')}:${(blackTime % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
