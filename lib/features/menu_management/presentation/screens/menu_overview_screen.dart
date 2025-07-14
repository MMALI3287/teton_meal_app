import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/features/menu_management/presentation/widgets/menu_poll_card_widget.dart';
import 'package:teton_meal_app/features/menu_management/presentation/screens/polls_by_date_screen.dart';

class MenusPage extends StatefulWidget {
  const MenusPage({super.key});

  @override
  _MenusPageState createState() => _MenusPageState();
}

class _MenusPageState extends State<MenusPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _buildHeaderSection(),
            SizedBox(height: 20.h),
            _buildIllustrationSection(),
            SizedBox(height: 20.h),
            _buildOrdersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Orders',
            style: TextStyle(
              color: AppColors.fTextH1,
              fontSize: 24.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.12,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final inactivePolls = await FirebaseFirestore.instance
                  .collection('polls')
                  .where('isActive', isEqualTo: false)
                  .orderBy('createdAt', descending: true)
                  .get();

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PollsByDatePage(polls: inactivePolls.docs),
                  ),
                );
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: AppColors.fRedBright,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.fTextH1.withValues(alpha: 0.1),
                        blurRadius: 3.r,
                        offset: Offset(0, 3.h),
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.fWhite,
                    size: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'History',
                  style: TextStyle(
                    color: AppColors.fTextH2,
                    fontSize: 10.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustrationSection() {
    return Container(
      height: 140.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
      child: Center(
        child: Image.asset(
          'assets/images/orders.png',
          height: 111.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('polls')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: AppColors.fRed2),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.fRedBright,
              ),
            );
          }

          final polls = snapshot.data!.docs;

          if (polls.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu_outlined,
                    size: 64.sp,
                    color: AppColors.fIconAndLabelText,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fTextH1,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Orders will appear here when menus are created',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.fIconAndLabelText,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            itemCount: polls.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                child: MenuPollCard(pollData: polls[index]),
              );
            },
          );
        },
      ),
    );
  }
}
