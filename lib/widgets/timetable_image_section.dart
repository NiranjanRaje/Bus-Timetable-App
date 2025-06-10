import 'package:flutter/material.dart';

class TimetableImageSection extends StatelessWidget {
  const TimetableImageSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'Bus Timetable App\nVersion 1.0\n\nCreated with Flutter and Firebase',
          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}