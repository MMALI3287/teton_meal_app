import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import '../widgets/menu_poll_card_widget.dart';
import 'polls_by_date_screen.dart';

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
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        width: 393.w,
        height: 805.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50.h),
            _buildHeaderSection(),
            _buildOrdersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orders title
          Text(
            'Orders',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 24.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.12,
            ),
          ),
          // Right side with calendar icon
          GestureDetector(
            onTap: () async {
              // Navigate to history page with inactive polls
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
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: ShapeDecoration(
                    color: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    shadows: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 2.92.r,
                        offset: Offset(0, 2.92.h),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.white,
                    size: 18.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'History',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 10.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                style: TextStyle(color: AppColors.error),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }

          final polls = snapshot.data!.docs;

          return Container(
            height: 589.55.h,
            padding: EdgeInsets.only(top: 7.89.h),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: ListView.builder(
              itemCount: polls.length,
              itemBuilder: (context, index) {
                return MenuPollCard(pollData: polls[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
