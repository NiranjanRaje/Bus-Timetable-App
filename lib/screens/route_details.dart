import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RouteDetails extends StatelessWidget {
  final String? routeId;

  const RouteDetails({Key? key, required this.routeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If the routeId is null, show a message that the route is not available
    if (routeId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Route Details'),
        ),
        body: Center(
          child: Text(
            'Route not available!',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Route Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('routes') // Firestore collection to get the route
            .doc(routeId) // Fetching the route document by ID
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

          final routeData = snapshot.data?.data() as Map<String, dynamic>?;

          if (routeData == null) {
            return Center(
              child: Text(
                'Route not found!',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            );
          }

          // Now we fetch the 'stops' as a List of maps.
          final stops = routeData['stops'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: stops.length,
              itemBuilder: (context, index) {
                // Get each stop and time
                final stop = stops[index]['stop'] as String;
                final time = stops[index]['time'] as String;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      // Stop and Time on the left side
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Vertical line after every stop except the last one
                      if (index < stops.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
