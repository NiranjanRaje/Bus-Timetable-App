import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(BusTimetableApp());
}

class BusTimetableApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Timetable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 6,
            shadowColor: Colors.blueAccent.withOpacity(0.5),
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          elevation: 4,
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: BusTimetableHomePage(),
    );
  }
}

class BusTimetableHomePage extends StatefulWidget {
  @override
  _BusTimetableHomePageState createState() => _BusTimetableHomePageState();
}

class _BusTimetableHomePageState extends State<BusTimetableHomePage> {
  int _selectedIndex = 0;

  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  String? _from;
  String? _to;

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

    setState(() {
      _from = from;
      _to = to;
    });
  }

  Widget _buildBusSearchUI() {
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

  Widget _buildResultsSection() {
    if (_from == null || _to == null) {
    return Expanded(
      child: Center(
        child: Text('Enter stations and tap "Find Bus"'),
      ),
    );
  }


    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('timetables')
            .where('from', isEqualTo: _from)
            .where('to', isEqualTo: _to)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text('No buses found from $_from to $_to'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                child: ListTile(
                  leading: Icon(Icons.directions_bus, color: Colors.blueAccent),
                  title: Text('Bus ${data['bus_number']}'),
                  subtitle: Text(
                    'Departs: ${data['departure_time']} - Arrives: ${data['arrival_time']}\n'
                    'Days: ${(data['days'] as List).join(", ")}\n${data['notes'] ?? ""}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return Column(
        children: [
          Flexible(
          flex: 0,
          child: _buildBusSearchUI(),
        ),
          _buildResultsSection(),
        ],
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Bus Timetable App\nVersion 1.0\n\nCreated with Flutter and Firebase',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Timetable'),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Bus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
