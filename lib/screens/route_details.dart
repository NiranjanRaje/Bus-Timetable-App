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
          backgroundColor: Colors.blueAccent,  // Modern color
        ),
        body: Center(
          child: Text(
            'Route not available!',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Route Details'),
        backgroundColor: Colors.blueAccent,  // Modern color
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
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            );
          }

          // Now we fetch the 'stops' as a List of maps.
          final stops = routeData['stops'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.all(12.0), // Adjusted padding for modern feel
            child: ListView.builder(
              itemCount: stops.length,
              itemBuilder: (context, index) {
                // Get each stop and time
                final stop = stops[index]['stop'] as String;
                final time = stops[index]['time'] as String;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0), // Added spacing between cards
                  child: Column(
                    children: [
                      // Stop and Time inside a Card
                      Card(
                        elevation: 5, // Card elevation for modern shadow effect
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0), // Internal padding
                          child: Row(
                            children: [
                              // Stop and Time on the left side
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stop,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              // Icon for a modern touch
                              Icon(
                                Icons.access_time,
                                color: Colors.blueAccent,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Add down arrow between stops
                      if (index < stops.length - 1) // Avoid arrow after the last stop
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                            size: 30,
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
