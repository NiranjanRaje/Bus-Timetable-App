import 'package:flutter/material.dart';

class BusSearchForm extends StatefulWidget {
  final Function(String from, String to) onSearch;
  final List<String> stations; // ✅ Added required parameter

  const BusSearchForm({
    Key? key,
    required this.onSearch,
    required this.stations, // ✅ Required in constructor
  }) : super(key: key);

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
        const SnackBar(content: Text('Please fill both stations')),
      );
      return;
    }
    widget.onSearch(from, to);
  }

  void _swapStations() {
    setState(() {
      final temp = _fromController.text;
      _fromController.text = _toController.text;
      _toController.text = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildAutocompleteField(
                hint: 'From Station',
                icon: Icons.train,
                controller: _fromController,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: Divider(color: Colors.blue, thickness: 1.5)),
                  OutlinedButton(
                    onPressed: _swapStations,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      side: const BorderSide(color: Colors.blue),
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(Icons.swap_vert, color: Colors.blue),
                  ),
                  const Expanded(child: Divider(color: Colors.blue, thickness: 1.5)),
                ],
              ),
              const SizedBox(height: 20),
              _buildAutocompleteField(
                hint: 'To Station',
                icon: Icons.train_outlined,
                controller: _toController,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _search,
                  child: const Text('Find Bus'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutocompleteField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
        return widget.stations.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        // Sync internal Autocomplete controller with your master controller
        if (fieldController.text != controller.text) {
          fieldController.text = controller.text;
        }

        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          onChanged: (val) => controller.text = val,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                fieldController.clear();
                controller.clear();
                setState(() {});
              },
            ),
            border: InputBorder.none,
          ),
        );
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
    );
  }
}