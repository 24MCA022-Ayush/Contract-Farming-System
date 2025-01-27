import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  DocumentSnapshot? _userData;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    final userType = args is String ? args : null;

    _user = FirebaseAuth.instance.currentUser;
    if (_user != null && userType != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection(userType)
            .doc(_user!.uid)
            .get();
        setState(() {
          _userData = snapshot;
        });

      } catch (e) {
        // Handle errors (e.g., document not found)
        print('Error fetching user data: $e');
        // Consider showing an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error fetching user data.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final userType = args is String ? args : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: _userData != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${_userData!['name'] ?? 'User'}!'), // Display the user's name if available
            // Display other user data as needed
            Text('Email: ${_userData!['email'] ?? 'N/A'}'),
            // Example: Displaying age (assuming you have an 'age' field in Firestore)
            Text('User Type: ${_userData!['userType'] ?? 'N/A'}'),
          ],
        )
            : const CircularProgressIndicator(), // Show a loading indicator while fetching data
      ),
    );
  }
}