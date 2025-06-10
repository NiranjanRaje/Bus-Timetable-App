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

          return ListView.builder(
            itemCount: docs.length,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: From and To with bus icon in center
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // From station
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
                                from ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),

                          // Bus icon
                          Icon(
                            Icons.directions_bus_filled,
                            size: 36,
                            color: Colors.blueAccent,
                          ),

                          // To station
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
                                to ?? '',
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

                      // Bus details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Bus number
                          Text(
                            'Bus ${data['bus_number']}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),

                          // Departure and arrival times
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Arrives: ${data['arrival_time']}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Departs: ${data['departure_time']}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      // Days and notes
                      Text(
                        'Days: ${(data['days'] as List).join(", ")}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),

                      if (data['notes'] != null && (data['notes'] as String).isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          data['notes'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
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
