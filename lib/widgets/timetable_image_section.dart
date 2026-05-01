import 'package:flutter/material.dart';

class TimetableImageSection extends StatelessWidget {
  const TimetableImageSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- CUTE ANIMATED GIF ---
              // This shows a cute character waiting at a bus stop
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  'https://media.giphy.com/media/fTfGYpG7Vl33P2X3mO/giphy.gif',
                  height: 220,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator(color: Colors.pinkAccent);
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.favorite, size: 80, color: Colors.pinkAccent);
                  },
                ),
              ),
              const SizedBox(height: 40),

              // --- INFORMATION TEXT ---
              const Text(
                'Timetable Photo Gallery',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Soon you will be able to view scanned copies of the official bus schedules.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- CUTE COMING SOON BADGE ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.pinkAccent, Colors.orangeAccent],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'COMING SOON ✨',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}