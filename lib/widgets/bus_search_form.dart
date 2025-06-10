import 'package:flutter/material.dart';

class BusSearchForm extends StatefulWidget {
  final Function(String from, String to) onSearch;

  const BusSearchForm({Key? key, required this.onSearch}) : super(key: key);

  @override
  _BusSearchFormState createState() => _BusSearchFormState();
}

class _BusSearchFormState extends State<BusSearchForm> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _search() {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    if (from.isEmpty || to.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill both stations')),
      );
      return;
    }

    widget.onSearch(from, to); // Call the onSearch function passed from the parent
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        children: [
          TextField(
            controller: _fromController,
            decoration: InputDecoration(
              hintText: 'From Station',
              prefixIcon: Icon(Icons.train),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _toController,
            decoration: InputDecoration(
              hintText: 'To Station',
              prefixIcon: Icon(Icons.train_outlined),
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _search,
              child: Text('Find Bus'),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}