import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimetableResults extends StatelessWidget {
  final String? from;
  final String? to;

  const TimetableResults({Key? key, required this.from, required this.to}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (from == null || to == null) {
      return Expanded(
        child: Center(
          child: Text(
            'Enter stations and tap "Find Bus"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('timetables')
            .where('from', isEqualTo: from)
            .where('to', isEqualTo: to)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading data',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No buses found from $from to $to',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            );
          }

          // Flatten documents so each time becomes a separate item
          final allBusTimes = docs.expand((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final times = List<String>.from(data['times'] ?? []);
            return times.map((time) => {
              'from': data['from'],
              'to': data['to'],
              'time': time,
            });
          }).toList();

          return ListView.builder(
            itemCount: allBusTimes.length,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemBuilder: (context, index) {
              final bus = allBusTimes[index];

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: From and To with bus icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                bus['from'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.directions_bus_filled,
                            size: 36,
                            color: Colors.blueAccent,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'To',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                bus['to'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Divider(height: 24, thickness: 1),

                      // Bus number and time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time: ${bus['time']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),
                    
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
