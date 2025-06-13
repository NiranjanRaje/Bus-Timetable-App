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

  void _swapStations() {
    final temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
  }

  void _clearFromText() {
    _fromController.clear();
  }

  void _clearToText() {
    _toController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // "From Station" TextField with Remove Text Button
              TextField(
                controller: _fromController,
                decoration: InputDecoration(
                  hintText: 'From Station',
                  prefixIcon: Icon(Icons.train),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: _clearFromText, // Clears the text
                  ),
                  border: InputBorder.none, // Remove border
                ),
              ),
              SizedBox(height: 20),

              // Divider Line through Swap Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.blue, // Blue line
                      thickness: 1.5,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _swapStations,
                    child: Icon(Icons.swap_vert, color: Colors.blue),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.all(8),
                      side: BorderSide(color: Colors.blue),
                      shape: CircleBorder(),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.blue, // Blue line
                      thickness: 1.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // "To Station" TextField with Remove Text Button
              TextField(
                controller: _toController,
                decoration: InputDecoration(
                  hintText: 'To Station',
                  prefixIcon: Icon(Icons.train_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: _clearToText, // Clears the text
                  ),
                  border: InputBorder.none, // Remove border
                ),
              ),
              SizedBox(height: 24),

              // Find Bus Button inside the card
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
        ),
      ),
    );
  }
}
