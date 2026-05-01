import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportIssuePage extends StatefulWidget {
  final String routeId;
  final String routeName;

  const ReportIssuePage({
    Key? key,
    required this.routeId,
    required this.routeName
  }) : super(key: key);

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  String _selectedIssue = 'Incorrect Timing';
  bool _isSubmitting = false;

  final List<String> _issueTypes = [
    'Incorrect Timing',
    'Missing Bus Stop',
    'Bus Cancelled',
    'Wrong Depot Info',
    'Other'
  ];

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'route_id': widget.routeId,
        'route_name': widget.routeName,
        'issue_type': _selectedIssue,
        'comment': _commentController.text.trim(),
        'reported_at': FieldValue.serverTimestamp(),
        'status': 'Open', // Useful for an admin panel later
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted! Thank you.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Reporting Issue For:",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                widget.routeName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              const Text("What's the problem?", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedIssue,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _issueTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _selectedIssue = value!),
              ),
              const SizedBox(height: 25),

              const Text("Additional Details", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Explain what's wrong (e.g., 'The 9:00 AM bus leaves at 9:15 AM')",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? "Please add a detail" : null,
              ),
              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SUBMIT REPORT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}