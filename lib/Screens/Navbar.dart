import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/Styles/colors.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Votes/votes_page.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Menus/menu_page.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Account/accounts_page.dart';
import 'package:teton_meal_app/Screens/Authentications/register.dart';
import 'package:teton_meal_app/services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _userRole = 'Diner';
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  List<NavItemData> _getNavItems() {
    if (_userRole == 'Admin') {
      return [
        NavItemData(
          icon: Icons.how_to_vote_rounded,
          activeIcon: Icons.how_to_vote,
          label: 'Vote',
          tooltip: 'Place your vote',
        ),
        NavItemData(
          icon: Icons.menu_book_rounded,
          activeIcon: Icons.menu_book,
          label: 'Order',
          tooltip: 'View and manage orders',
        ),
        NavItemData(
          icon: Icons.people_rounded,
          activeIcon: Icons.people,
          label: 'User',
          tooltip: 'User management',
        ),
        NavItemData(
          icon: Icons.settings_rounded,
          activeIcon: Icons.settings,
          label: 'Settings',
          tooltip: 'Manage settings',
        ),
      ];
    } else if (_userRole == 'Planner') {
      return [
        NavItemData(
          icon: Icons.how_to_vote_rounded,
          activeIcon: Icons.how_to_vote,
          label: 'Vote',
          tooltip: 'Place your vote',
        ),
        NavItemData(
          icon: Icons.menu_book_rounded,
          activeIcon: Icons.menu_book,
          label: 'Order',
          tooltip: 'Manage lunch menus',
        ),
        NavItemData(
          icon: Icons.settings_rounded,
          activeIcon: Icons.settings,
          label: 'Settings',
          tooltip: 'Manage settings',
        ),
      ];
    } else {
      return [
        NavItemData(
          icon: Icons.how_to_vote_rounded,
          activeIcon: Icons.how_to_vote,
          label: 'Vote',
          tooltip: 'Place your vote',
        ),
        NavItemData(
          icon: Icons.settings_rounded,
          activeIcon: Icons.settings,
          label: 'Settings',
          tooltip: 'Manage settings',
        ),
      ];
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      _controller.stop();
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60.h,
                width: 60.w,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentScreen = _getScreens()[_selectedIndex];
    final navItems = _getNavItems();
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: currentScreen,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.5.h),
        height: 67.h,
        decoration: ShapeDecoration(
          color: AppColors.fWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.w),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 4,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 4,
              offset: Offset(2, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              navItems.length,
              (index) => Flexible(
                child: _buildNavItem(navItems[index], index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItemData item, int index) {
    final isSelected = _selectedIndex == index;
    const activeColor = AppColors.fRedBright;
    const inactiveColor = AppColors.fTextH1;

    return InkWell(
      onTap: () => _onItemTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 20.w,
            ),
            SizedBox(height: 5.37.h),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10.sp,
                fontFamily: 'DMSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String tooltip;

  NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.tooltip,
  });
}
