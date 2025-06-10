import 'package:flutter/material.dart';
import 'package:bus_timetable_app/widgets/bus_search_form.dart';
import 'package:bus_timetable_app/widgets/timetable_results.dart';
import 'package:bus_timetable_app/widgets/bottom_nav.dart';
import 'package:bus_timetable_app/widgets/timetable_image_section.dart';

class BusTimetableHomePage extends StatefulWidget {
  @override
  _BusTimetableHomePageState createState() => _BusTimetableHomePageState();
}

class _BusTimetableHomePageState extends State<BusTimetableHomePage> {
  int _selectedIndex = 0;
  String? _from;
  String? _to;

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
            child: BusSearchForm(onSearch: _search),
          ),
          TimetableResults(from: _from, to: _to),
        ],
      );
    } else {
      return TimetableImageSection(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Timetable'),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNav( // Use the BottomNav widget
        selectedIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}