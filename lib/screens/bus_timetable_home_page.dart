import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:bus_timetable_app/widgets/bus_search_form.dart';
import 'package:bus_timetable_app/widgets/bottom_nav.dart';
import 'package:bus_timetable_app/widgets/timetable_image_section.dart';
import 'package:bus_timetable_app/screens/feedback_page.dart';
import 'package:bus_timetable_app/screens/route_details.dart';
import 'package:bus_timetable_app/screens/search_results_page.dart';
import 'package:bus_timetable_app/utils/route_observer.dart';

class BusTimetableHomePage extends StatefulWidget {
  @override
  _BusTimetableHomePageState createState() => _BusTimetableHomePageState();
}

class _BusTimetableHomePageState extends State<BusTimetableHomePage> with RouteAware {
  int _selectedIndex = 0;
  List<String> _allStations = [];
  List<Map<String, String>> _recentSelections = [];

  @override
  void initState() {
    super.initState();
    _initStations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes to refresh when returning to this page
    final modal = ModalRoute.of(context);
    if (modal is PageRoute) {
      routeObserver.subscribe(this, modal);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this route (another route was popped)
    _loadRecentSelections();
  }

  // Logic to load stations from local storage and check for updates
  Future<void> _initStations() async {
    final prefs = await SharedPreferences.getInstance();

    final String? cachedData = prefs.getString('stations_cache');
    if (cachedData != null) {
      setState(() {
        _allStations = List<String>.from(json.decode(cachedData));
      });
    }

    final String? recentData = prefs.getString('recent_selections');
    if (recentData != null) {
      final decoded = json.decode(recentData);
      if (decoded is List) {
        final routes = decoded.map<Map<String, String>>((item) {
          final routeMap = item as Map<String, dynamic>;
          return {
            'route_id': routeMap['route_id']?.toString() ?? '',
            'from': routeMap['from']?.toString() ?? '',
            'to': routeMap['to']?.toString() ?? '',
            'time': routeMap['time']?.toString() ?? '',
            'service_type': routeMap['service_type']?.toString() ?? '',
            'depot': routeMap['depot']?.toString() ?? '',
          };
        }).where((route) {
          final from = route['from'];
          final to = route['to'];
          final routeId = route['route_id'];
          return (from?.isNotEmpty ?? false) && (to?.isNotEmpty ?? false) && (routeId?.isNotEmpty ?? false);
        }).toList();

        setState(() {
          _recentSelections = routes;
        });
      }
    }

    try {
      DocumentSnapshot meta = await FirebaseFirestore.instance
          .collection('metadata')
          .doc('timetable_info')
          .get();

      if (meta.exists) {
        int serverVersion = meta['version'] ?? 0;
        int localVersion = prefs.getInt('stations_version') ?? -1;

        if (serverVersion > localVersion) {
          await _fetchAndCacheStations(serverVersion);
        }
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
    }
  }

  Future<void> _fetchAndCacheStations(int newVersion) async {
    final snapshot = await FirebaseFirestore.instance.collection('timetable').get();
    final Set<String> uniqueStations = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['from'] != null) uniqueStations.add(data['from']);
      if (data['to'] != null) uniqueStations.add(data['to']);
      if (data['stops'] != null) {
        for (var stop in (data['stops'] as List)) {
          uniqueStations.add(stop.toString());
        }
      }
    }

    final List<String> sortedList = uniqueStations.toList()..sort();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stations_cache', json.encode(sortedList));
    await prefs.setInt('stations_version', newVersion);

    setState(() {
      _allStations = sortedList;
    });
  }

  void _onNavTapped(int index) {
    // If switching to Home (index 0), refresh recent selections
    if (index == 0) {
      _loadRecentSelections().then((_) {
        setState(() {
          _selectedIndex = index;
        });
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _saveRecentSelection(Map<String, String> selection) async {
    final prefs = await SharedPreferences.getInstance();

    // Load the latest saved list (avoid stale in-memory state)
    final String? existingData = prefs.getString('recent_selections');
    List<dynamic> existingList = [];
    if (existingData != null) {
      try {
        final decoded = json.decode(existingData);
        if (decoded is List) existingList = decoded;
      } catch (_) {
        existingList = [];
      }
    }

    // Normalize to list of maps
    final List<Map<String, String>> normalized = existingList.map<Map<String, String>>((item) {
      final m = item as Map<String, dynamic>;
      return {
        'route_id': m['route_id']?.toString() ?? '',
        'from': m['from']?.toString() ?? '',
        'to': m['to']?.toString() ?? '',
        'time': m['time']?.toString() ?? '',
        'service_type': m['service_type']?.toString() ?? '',
        'depot': m['depot']?.toString() ?? '',
      };
    }).toList();

    // Remove any existing entry with same route_id and insert new at front
    normalized.removeWhere((item) => item['route_id'] == selection['route_id']);
    normalized.insert(0, selection);
    if (normalized.length > 5) normalized.removeRange(5, normalized.length);

    await prefs.setString('recent_selections', json.encode(normalized));
    debugPrint('Saved recent_selections: ${json.encode(normalized)}');
    setState(() {
      _recentSelections = normalized;
    });
  }

  Future<void> _loadRecentSelections() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recentData = prefs.getString('recent_selections');
    if (recentData == null) return;

    final decoded = json.decode(recentData);
    if (decoded is List) {
      final routes = decoded.map<Map<String, String>>((item) {
        final routeMap = item as Map<String, dynamic>;
        return {
          'route_id': routeMap['route_id']?.toString() ?? '',
          'from': routeMap['from']?.toString() ?? '',
          'to': routeMap['to']?.toString() ?? '',
          'time': routeMap['time']?.toString() ?? '',
          'service_type': routeMap['service_type']?.toString() ?? '',
          'depot': routeMap['depot']?.toString() ?? '',
        };
      }).where((route) {
        final from = route['from'];
        final to = route['to'];
        final routeId = route['route_id'];
        return (from?.isNotEmpty ?? false) && (to?.isNotEmpty ?? false) && (routeId?.isNotEmpty ?? false);
      }).toList();

      setState(() {
        _recentSelections = routes;
      });
    }
  }

  Future<void> _search(String from, String to) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          from: from,
          to: to,
          onResultSelected: _saveRecentSelection,
        ),
      ),
    );
    await _loadRecentSelections();
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return Column(
        children: [
          Flexible(
            flex: 0,
            child: BusSearchForm(
              onSearch: _search,
              stations: _allStations,
            ),
          ),
          if (_recentSelections.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Recently viewed trips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _recentSelections.length,
                        itemBuilder: (context, index) {
                          final route = _recentSelections[index];
                          final routeText = '${route['from']} → ${route['to']}';
                          final details = '${route['time']} • ${route['service_type']} • ${route['depot']}';
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(routeText, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(details),
                              trailing: const Icon(Icons.history, size: 16),
                              onTap: () async {
                                final routeId = route['route_id'] ?? '';
                                if (routeId.isEmpty) return;

                                // Ensure this selection becomes the most-recent
                                await _saveRecentSelection({
                                  'route_id': routeId,
                                  'from': route['from'] ?? '',
                                  'to': route['to'] ?? '',
                                  'time': route['time'] ?? '',
                                  'service_type': route['service_type'] ?? '',
                                  'depot': route['depot'] ?? '',
                                });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RouteDetails(routeId: routeId),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text('Tap Find Bus to see results on a separate screen'),
              ),
            ),
        ],
      );
    } else {
      return const TimetableImageSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Timetable'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review_outlined),
            tooltip: 'App Feedback',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackPage())
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}