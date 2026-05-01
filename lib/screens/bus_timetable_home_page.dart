import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:bus_timetable_app/widgets/bus_search_form.dart';
import 'package:bus_timetable_app/widgets/timetable_results.dart';
import 'package:bus_timetable_app/widgets/bottom_nav.dart';
import 'package:bus_timetable_app/widgets/timetable_image_section.dart';
import 'package:bus_timetable_app/screens/feedback_page.dart';

class BusTimetableHomePage extends StatefulWidget {
  @override
  _BusTimetableHomePageState createState() => _BusTimetableHomePageState();
}

class _BusTimetableHomePageState extends State<BusTimetableHomePage> {
  int _selectedIndex = 0;
  String? _from;
  String? _to;
  List<String> _allStations = [];

  @override
  void initState() {
    super.initState();
    _initStations();
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
    setState(() {
      _selectedIndex = index;
    });
  }

  void _search(String from, String to) {
    setState(() {
      _from = from;
      _to = to;
    });
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
          TimetableResults(from: _from, to: _to),
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