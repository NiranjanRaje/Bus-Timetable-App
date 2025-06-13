import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus_timetable_app/screens/route_details.dart';

class TimetableResults extends StatelessWidget {
  final String? from;
  final String? to;

  const TimetableResults({Key? key, required this.from, required this.to}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If the 'from' or 'to' are null, show a prompt to the user
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

    // Query the 'timetables' collection based on 'from' and 'to'
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('timetables') // Query the 'timetables' collection
            .where('from', isEqualTo: from) // Filter by 'from' station
            .where('to', isEqualTo: to) // Filter by 'to' station
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

          // If no results found, show a message
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No buses found from $from to $to',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            );
          }

          // Expand the timetable documents and map them to a list of bus times
          final allBusTimes = docs.expand((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final times = List<String>.from(data['times'] ?? []);
            return times.map((time) => {
              'from': data['from'],
              'to': data['to'],
              'time': time,
              'route_id': data['route_id'], // This links the timetable to a route
            });
          }).toList();

          // Build the list view to display all the bus times
          return ListView.builder(
            itemCount: allBusTimes.length,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemBuilder: (context, index) {
              final bus = allBusTimes[index];

              return GestureDetector(
                onTap: () {
                  // When an item is clicked, navigate to the RouteDetails page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteDetails(
                        routeId: bus['route_id'], // Pass the route_id to RouteDetails
                      ),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  bus['from'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
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
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  bus['to'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(height: 24, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Time: ${bus['time']}',
                              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
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
