import 'package:flutter/material.dart';
import 'package:bus_timetable_app/widgets/timetable_results.dart';

enum SortOption { time, serviceType, area }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.serviceType:
        return 'Service Type';
      case SortOption.area:
        return 'Area';
      case SortOption.time:
      default:
        return 'Time';
    }
  }

  String get fieldName {
    switch (this) {
      case SortOption.serviceType:
        return 'service_type';
      case SortOption.area:
        return 'depot';
      case SortOption.time:
      default:
        return 'time';
    }
  }
}

class SearchResultsPage extends StatefulWidget {
  final String from;
  final String to;
  final Future<void> Function(Map<String, String>)? onResultSelected;

  const SearchResultsPage({Key? key, required this.from, required this.to, this.onResultSelected}) : super(key: key);

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  SortOption _selectedSort = SortOption.time;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        toolbarHeight: 80,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.from.trim()} → ${widget.to.trim()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Sort by: ${_selectedSort.label}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 14, bottom: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SortOption>(
                  dropdownColor: Colors.white,
                  value: _selectedSort,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  icon: const Icon(Icons.sort, color: Colors.black),
                  iconSize: 20,
                  underline: const SizedBox.shrink(),
                  items: SortOption.values.map((option) {
                    return DropdownMenuItem<SortOption>(
                      value: option,
                      child: Text(option.label, style: const TextStyle(fontSize: 12, color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (SortOption? newOption) {
                    if (newOption == null) return;
                    setState(() {
                      _selectedSort = newOption;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: TimetableResults(
        from: widget.from,
        to: widget.to,
        sortBy: _selectedSort.fieldName,
        onResultSelected: widget.onResultSelected,
      ),
    );
  }
}
