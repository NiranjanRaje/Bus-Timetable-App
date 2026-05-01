import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'rating': _rating,
        'comment': _feedbackController.text.trim(),
        'submitted_at': FieldValue.serverTimestamp(),
        'app_version': '1.0.0',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you! Your feedback helps us improve ❤️')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Your Thoughts'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.volunteer_activism_outlined, size: 70, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                "Your Voice Matters!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Tell us what you love or what we can do better.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),

              const Text(
                  "Overall Rating",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              ),
              const SizedBox(height: 10),
              Slider(
                value: _rating,
                min: 1,
                max: 5,
                divisions: 4,
                label: "${_rating.round()} Stars",
                activeColor: Colors.blueAccent,
                onChanged: (double value) {
                  setState(() => _rating = value);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("😞 Poor", style: TextStyle(color: Colors.grey)),
                  Text("Amazing 😍", style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 40),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    "Detailed Comments",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "I'd love to see...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) => (value == null || value.isEmpty) ? "Please write a small note" : null,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                      "SUBMIT FEEDBACK",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}