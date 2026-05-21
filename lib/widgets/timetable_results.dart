import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus_timetable_app/screens/route_details.dart';

class TimetableResults extends StatelessWidget {
  final String? from;
  final String? to;
  final String sortBy;
  final Future<void> Function(Map<String, String>)? onResultSelected;

  const TimetableResults({Key? key, required this.from, required this.to, this.sortBy = 'time', this.onResultSelected}) : super(key: key);

  String capitalizeEveryWord(String str) {
    if (str.isEmpty) return str;
    return str.split(' ').map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '').join(' ');
  }

  List<String> _toStringList(dynamic value) {
    if (value is Iterable) {
      return value.map((item) => item?.toString() ?? '').where((item) => item.isNotEmpty).toList();
    }
    if (value is String) {
      return [value];
    }
    return [];
  }

  int _compareBusTimes(Map<String, dynamic> a, Map<String, dynamic> b) {
    final aValue = a[sortBy]?.toString() ?? '';
    final bValue = b[sortBy]?.toString() ?? '';
    return aValue.compareTo(bValue);
  }

  @override
  Widget build(BuildContext context) {
    if (from == null || to == null) {
      return const Center(child: Text('Enter stations and tap "Find Bus"'));
    }

    final capitalizedFrom = capitalizeEveryWord(from!.trim());
    final capitalizedTo = capitalizeEveryWord(to!.trim());

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('timetable')
          .where('from', isEqualTo: capitalizedFrom)
          .where('to', isEqualTo: capitalizedTo).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading data: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No timetable data available.'));
        }

        try {
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('No buses found from $capitalizedFrom to $capitalizedTo'));
          }

          final List<Map<String, dynamic>> allBusTimes = docs.expand((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final departuresList = _toStringList(data['departures']);
            return departuresList.map((time) => {
              'from': data['from'],
              'to': data['to'],
              'time': time,
              'service_type': data['service_type'] ?? 'Regular',
              'category': data['category'] ?? 'Rural',
              'depot': data['depot'] ?? 'Satara',
              'route_id': doc.id,
            });
          }).toList();

          allBusTimes.sort(_compareBusTimes);

          return ListView.builder(
            itemCount: allBusTimes.length,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemBuilder: (context, index) {
              final bus = allBusTimes[index];
              return GestureDetector(
                onTap: () async {
                  if (onResultSelected != null) {
                    await onResultSelected!({
                      'route_id': bus['route_id']?.toString() ?? '',
                      'from': bus['from']?.toString() ?? '',
                      'to': bus['to']?.toString() ?? '',
                      'time': bus['time']?.toString() ?? '',
                      'service_type': bus['service_type']?.toString() ?? '',
                      'depot': bus['depot']?.toString() ?? '',
                    });
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RouteDetails(routeId: bus['route_id'])));
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text("Depot: ${bus['depot']}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                          Text(bus['category'], style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          _buildCol('From', bus['from']),
                          const Icon(Icons.directions_bus_filled, size: 32, color: Colors.blueAccent),
                          _buildCol('To', bus['to'], end: true),
                        ]),
                        const Divider(height: 24),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Time: ${bus['time']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(bus['service_type'], style: TextStyle(color: bus['service_type'].contains('Non-Stop') ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                        ]),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } catch (error) {
          return Center(child: Text('Error displaying results: $error'));
        }
      },
    );
  }

  Widget _buildCol(String label, String name, {bool end = false}) {
    return Column(crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12)),
      Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
    ]);
  }
}