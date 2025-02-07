import 'package:flutter/material.dart';
import 'package:teton_meal_app/Styles/colors.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Votes/votes_page.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Menus/menu_page.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Account/accounts_page.dart';
import 'package:teton_meal_app/Screens/Register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(const NavbarApp());

class NavbarApp extends StatelessWidget {
  const NavbarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Navbar(),
    );
  }
}

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;
  String _userRole = 'Diner';

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userRole = userDoc['role'];
      });
    }
  }

  List<Widget> _getScreens() {
    if (_userRole == 'Admin') {
      return [
        const VotesPage(),
        const MenusPage(),
        const Register(),
        const AccountsPage(),
      ];
    } else if (_userRole == 'Planner') {
      return [
        const VotesPage(),
        const MenusPage(),
        const AccountsPage(),
      ];
    } else {
      return [
        const VotesPage(),
        const AccountsPage(),
      ];
    }
  }

  List<BottomNavigationBarItem> _getBottomNavItems() {
    if (_userRole == 'Admin') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.poll),
          label: 'Vote',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.app_registration),
          label: 'Register',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box_sharp),
          label: 'Account',
        ),
      ];
    } else if (_userRole == 'Planner') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.poll),
          label: 'Vote',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box_sharp),
          label: 'Account',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.poll),
          label: 'Vote',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box_sharp),
          label: 'Account',
        ),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreens()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _getBottomNavItems(),
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.secondaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
