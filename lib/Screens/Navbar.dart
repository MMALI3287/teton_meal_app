import 'package:flutter/material.dart';
import 'package:teton_meal_app/Styles/colors.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Votes/votes_page.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Menus/menu_page.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Account/accounts_page.dart';

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
  static final List<Widget> _screens = <Widget>[
    const VotesPage(),
    const MenusPage(),
    const AccountsPage(),
  ];
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Vote',
      style: optionStyle,
    ),
    Text(
      'Menus',
      style: optionStyle,
    ),
    Text(
      'Account',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.secondaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
