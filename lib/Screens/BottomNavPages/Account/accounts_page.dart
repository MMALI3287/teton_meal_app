import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teton_meal_app/Screens/Login.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final _formKey = GlobalKey<FormState>();
  User? user;

  // Text controllers
  TextEditingController? _nameController;
  TextEditingController? _emailController;
  bool _isEditing = false;
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Fetch the latest user data
      user = FirebaseAuth.instance.currentUser;
      await user
          ?.reload(); // Refresh the user's data from Firebase Authentication
      user = FirebaseAuth.instance.currentUser;

      // Initialize controllers with the latest user data
      _nameController = TextEditingController(text: user?.displayName ?? '');
      _emailController = TextEditingController(text: user?.email ?? '');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _emailController?.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Update user profile in Firebase Authentication
        await user?.updateDisplayName(_nameController?.text ?? '');
        if (user?.email != _emailController?.text) {
          await user?.updateEmail(_emailController?.text ?? '');
        }

        // Save the updated name and email to Firestore
        await FirebaseFirestore.instance
            .collection('users') // Users collection
            .doc(user?.uid) // Use the user's UID as the document ID
            .set(
          {
            'displayName': _nameController?.text ?? '', // Update the name
            'email': _emailController?.text ?? '', // Update the email
          },
          SetOptions(merge: true), // Merge with existing fields
        );

        await user?.reload(); // Refresh user data after update
        user = FirebaseAuth.instance.currentUser;

        // Hide loading indicator
        Navigator.pop(context);

        setState(() {
          _isEditing = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        // Hide loading indicator
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await FirebaseAuth.instance.signOut();

      // Navigate to login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture (optional)
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        child: Text(
                          _nameController!.text.isNotEmpty
                              ? _nameController!.text[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sign Out Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
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
