import 'package:flutter/material.dart';
import 'package:teton_meal_app/Styles/colors.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Votes/votes_page.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Menus/menu_page.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Account/accounts_page.dart';
import 'package:teton_meal_app/Screens/Register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teton_meal_app/services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;
  String _userRole = 'Diner';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final user = AuthService().currentUser;
      if (user != null) {
        setState(() {
          _userRole = user.role;
          _isLoading = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to fetch user role: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() => _isLoading = false);
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
          tooltip: 'View and cast votes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Menu',
          tooltip: 'View and manage menus',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.app_registration),
          label: 'Register',
          tooltip: 'Register new users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box_sharp),
          label: 'Account',
          tooltip: 'Manage your account',
        ),
      ];
    } else if (_userRole == 'Planner') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.poll),
          label: 'Vote',
          tooltip: 'View and cast votes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Menu',
          tooltip: 'View and manage menus',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box_sharp),
          label: 'Account',
          tooltip: 'Manage your account',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.poll),
          label: 'Vote',
          tooltip: 'View and cast votes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box_sharp),
          label: 'Account',
          tooltip: 'Manage your account',
        ),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    String message = '';
    switch (index) {
      case 0:
        message = 'Place your lunch order';
        break;
      case 1:
        message = _userRole == 'Diner' 
            ? 'Manage your profile'
            : 'Manage lunch menus';
        break;
      case 2:
        message = _userRole == 'Admin'
            ? 'Register new employee'
            : 'Manage your profile';
        break;
      case 3:
        message = 'Manage your profile';
        break;
    }
    
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _getScreens()[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: _getBottomNavItems(),
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.secondaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
