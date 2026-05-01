import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_issue.dart';

class RouteDetails extends StatelessWidget {
  final String routeId;

  const RouteDetails({Key? key, required this.routeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('timetable').doc(routeId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('Route details not found.')));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        // --- DATA EXTRACTION ---
        final String from = data['from'] ?? 'Unknown';
        final String to = data['to'] ?? 'Unknown';
        final String routeName = "$from to $to";

        // Extracting your specific Firestore fields
        final String category = data['category'] ?? 'Rural';
        final String depot = data['depot'] ?? 'Satara';
        final String serviceType = data['service_type'] ?? 'All Stops';

        final List<String> intermediateStops = List<String>.from(data['stops'] ?? []);
        final List<String> departures = List<String>.from(data['departures'] ?? []);
        final List<String> fullPath = [from, ...intermediateStops, to];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Journey Details'),
            backgroundColor: Colors.blueAccent,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.feedback_outlined, color: Colors.black),
                tooltip: 'Report data error',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportIssuePage(
                        routeId: routeId,
                        routeName: routeName,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.directions_bus, size: 50, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  routeName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // --- BADGE SECTION (Custom Labels & Natural Case) ---
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 10,
                  children: [
                    _badge("Area: $category", Colors.purple),
                    _badge("Depot: $depot", Colors.orange),
                    _badge("Service: $serviceType", Colors.green),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Divider(),
                ),

                const Text(
                  "COMPLETE ROUTE PATH",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      letterSpacing: 1.1,
                      fontSize: 14
                  ),
                ),
                const SizedBox(height: 32),

                // Centered timeline with blue highlights
                _buildRoutePath(fullPath),

                const SizedBox(height: 40),
                const Text(
                  "ALL DEPARTURES",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      letterSpacing: 1.1,
                      fontSize: 14
                  ),
                ),
                const SizedBox(height: 20),
                _buildDepartureGrid(departures),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Badge: Mixed Case (Not Capitalized) ---
  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        text, // Removed .toUpperCase()
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  // --- Centered Timeline: Blue Accent for Start and Stop ---
  Widget _buildRoutePath(List<String> path) {
    return Column(
      children: path.asMap().entries.map((entry) {
        int idx = entry.key;
        String stopName = entry.value;
        bool isFirst = idx == 0;
        bool isLast = idx == path.length - 1;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              child: Column(
                children: [
                  Icon(
                    isFirst || isLast ? Icons.radio_button_checked : Icons.radio_button_off,
                    size: 20,
                    color: isFirst || isLast ? Colors.blueAccent : Colors.grey,
                  ),
                  if (!isLast)
                    Container(
                      height: 35,
                      width: 2,
                      color: Colors.grey[300],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 180,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  stopName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.w500,
                    color: isFirst || isLast ? Colors.blueAccent : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDepartureGrid(List<String> times) {
    if (times.isEmpty) return const Text("No departure times available.");
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: times.map((t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2)
            )
          ],
        ),
        child: Text(
            t,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.black87
            )
        ),
      )).toList(),
    );
  }
}