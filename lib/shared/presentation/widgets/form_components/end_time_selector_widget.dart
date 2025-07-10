import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';

class EndTimeSelectorComponent extends StatelessWidget {
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const EndTimeSelectorComponent({
    super.key,
    required this.selectedTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        width: double.infinity,
        height: 64.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.fWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.fTextH2, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.fRedBright.withValues(alpha: 0.1),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.fLineaAndLabelBox,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.fTextH2.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                Icons.schedule,
                color: AppColors.fIconAndLabelText,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'End Time',
                  style: TextStyle(
                    color: AppColors.fTextH2,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  selectedTime.format(context),
                  style: TextStyle(
                    color: AppColors.fTextH1,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.fRedBright.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.fRedBright.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.fRedBright,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.fRedBright,
                  onPrimary: AppColors.fWhite,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      onTimeChanged(picked);
    }
  }
}
