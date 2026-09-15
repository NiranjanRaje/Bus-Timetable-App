import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusSearchForm extends StatefulWidget {
  final Future<void> Function(String from, String to) onSearch;
  final List<String> stations;

  const BusSearchForm({
    Key? key,
    required this.onSearch,
    required this.stations,
  }) : super(key: key);

  @override
  BusSearchFormState createState() => BusSearchFormState();
}

class BusSearchFormState extends State<BusSearchForm> {
  late TextEditingController _fromController;
  late TextEditingController _toController;
  bool _hasSavedFrom = false;
  bool _hasSavedTo = false;
  FocusNode? _fromFocusNode;
  FocusNode? _toFocusNode;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController();
    _toController = TextEditingController();
    _loadSavedValues();
  }

  Future<void> _loadSavedValues() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSavedFrom = prefs.containsKey('search_form_from');
      final hasSavedTo = prefs.containsKey('search_form_to');

      final savedFrom = prefs.getString('search_form_from') ?? '';
      final savedTo = prefs.getString('search_form_to') ?? '';
      debugPrint('📥 Loaded from SharedPreferences - From: "$savedFrom", To: "$savedTo"');

      _hasSavedFrom = savedFrom.isNotEmpty;
      _hasSavedTo = savedTo.isNotEmpty;

      // Restore saved values only (no fallback to initialFrom)
      // If nothing is saved, show blank (invalid searches clear the prefs)
      final finalFrom = savedFrom.isNotEmpty ? savedFrom : '';
      final finalTo = savedTo.isNotEmpty ? savedTo : '';

      _fromController = TextEditingController(text: finalFrom);
      _toController = TextEditingController(text: finalTo);
      debugPrint('✅ Form initialized - From: "$finalFrom", To: "$finalTo"');

      setState(() {});
    } catch (e) {
      debugPrint('❌ Error loading saved values: $e');
      _fromController = TextEditingController(text: '');
      _toController = TextEditingController(text: '');
      setState(() {});
    }
  }

  String? _findMatchingStation(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final station in widget.stations) {
      if (station.toLowerCase() == normalized) {
        return station;
      }
    }
    return null;
  }

  Future<void> _saveFormValues(String from, String to) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final matchedFrom = _findMatchingStation(from);
      final matchedTo = _findMatchingStation(to);

      if (matchedFrom != null) {
        await prefs.setString('search_form_from', matchedFrom);
        _hasSavedFrom = true;
        debugPrint('✅ Saved search_form_from: "$matchedFrom"');
      } else {
        await prefs.remove('search_form_from');
        _hasSavedFrom = false;
        debugPrint('⚠️ Cleared search_form_from because it did not match suggestions');
      }

      if (matchedTo != null) {
        await prefs.setString('search_form_to', matchedTo);
        _hasSavedTo = true;
        debugPrint('✅ Saved search_form_to: "$matchedTo"');
      } else {
        await prefs.remove('search_form_to');
        _hasSavedTo = false;
        debugPrint('⚠️ Cleared search_form_to because it did not match suggestions');
      }
    } catch (e) {
      debugPrint('❌ Error saving form values: $e');
    }
  }



  void clearAutocompleteFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fromFocusNode?.unfocus();
      _toFocusNode?.unfocus();
    });
  }

  @override
  void dispose() {
    _fromFocusNode?.dispose();
    _toFocusNode?.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _clearSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_form_from');
    await prefs.remove('search_form_to');
  }

  Future<void> _search() async {
    FocusScope.of(context).unfocus();

    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    debugPrint('🔍 Search clicked - From: "$from", To: "$to"');

    if (from.isEmpty || to.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill both stations')),
      );
      return;
    }

    await _saveFormValues(from, to);
    debugPrint('➡️ Calling onSearch callback...');
    await widget.onSearch(from, to);
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 360 ? 12.0 : (screenWidth < 480 ? 16.0 : 24.0);
    final innerPadding = screenWidth < 360 ? 14.0 : 20.0;
    final fieldGap = screenWidth < 360 ? 12.0 : 18.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(innerPadding),
          child: Column(
            children: [
              _buildAutocompleteField(
                hint: 'From Station',
                icon: Icons.train,
                controller: _fromController,
                storageKey: 'search_form_from',
              ),
              SizedBox(height: fieldGap),
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
              SizedBox(height: fieldGap),
              _buildAutocompleteField(
                hint: 'To Station',
                icon: Icons.train_outlined,
                controller: _toController,
                storageKey: 'search_form_to',
              ),
              SizedBox(height: screenWidth < 360 ? 16.0 : 22.0),
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
    required String storageKey,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
        return widget.stations.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        if (storageKey == 'search_form_from') {
          _fromFocusNode ??= focusNode;
        } else if (storageKey == 'search_form_to') {
          _toFocusNode ??= focusNode;
        }

        // Initialize field controller with master controller value only when needed.
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
              onPressed: () async {
                fieldController.clear();
                controller.clear();
                // Clear saved values when clearing the field
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(storageKey);
                // Update saved flags
                if (storageKey == 'search_form_from') {
                  _hasSavedFrom = false;
                } else if (storageKey == 'search_form_to') {
                  _hasSavedTo = false;
                }
                setState(() {});
              },
            ),
            border: InputBorder.none,
          ),
        );
      },
      onSelected: (String selection) async {
        controller.text = selection;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(storageKey, selection);
        if (storageKey == 'search_form_from') {
          _hasSavedFrom = true;
        } else if (storageKey == 'search_form_to') {
          _hasSavedTo = true;
        }
      },
    );
  }
}