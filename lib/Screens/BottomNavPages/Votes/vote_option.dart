import 'package:cloud_firestore/cloud_firestore.dart';
import "package:teton_meal_app/services/auth_service.dart";
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teton_meal_app/Styles/colors.dart';

class VoteOption extends StatefulWidget {
  final String option;
  final String pollId;
  final Map<String, dynamic> allVotes;
  final int? endTimeMillis;
  final bool isActive;

  const VoteOption({
    super.key,
    required this.option,
    required this.pollId,
    required this.allVotes,
    this.endTimeMillis,
    required this.isActive,
  });

  @override
  State<VoteOption> createState() => _VoteOptionState();
}

class _VoteOptionState extends State<VoteOption>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool isUserSelectedOption(String userId) {
    return widget.allVotes[widget.option] != null &&
        (widget.allVotes[widget.option] as List).contains(userId);
  }

  String _getFoodEmoji(String foodName) {
    final lowerName = foodName.toLowerCase();
    if (lowerName.contains('khichuri') || lowerName.contains('khichdi')) {
      return '🍚';
    } else if (lowerName.contains('rice')) {
      return '🍱';
    } else if (lowerName.contains('chicken')) {
      return '🍗';
    } else if (lowerName.contains('beef')) {
      return '🥩';
    } else if (lowerName.contains('fish')) {
      return '🐟';
    } else if (lowerName.contains('egg')) {
      return '🥚';
    } else if (lowerName.contains('vegetable') || lowerName.contains('veg')) {
      return '🥗';
    } else if (lowerName.contains('dal') || lowerName.contains('lentil')) {
      return '🟡';
    } else if (lowerName.contains('curry')) {
      return '🍛';
    } else {
      return '🍽️';
    }
  }

  Future<void> _handleVote() async {
    try {
      final pollDoc = await FirebaseFirestore.instance
          .collection('polls')
          .doc(widget.pollId)
          .get();

      if (!pollDoc.exists) {
        Fluttertoast.showToast(
            msg: "Menu not found",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
            fontSize: 16.sp);
        return;
      }

      final latestIsActive = pollDoc.data()?['isActive'] ?? false;

      if (!latestIsActive) {
        Fluttertoast.showToast(
            msg: "This menu is no longer accepting orders",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppColors.warning,
            textColor: AppColors.white,
            fontSize: 16.sp);
        return;
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error checking menu status",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
          fontSize: 16.sp);
      return;
    }

    if (!widget.isActive) {
      Fluttertoast.showToast(
          msg: "This menu is no longer accepting orders",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: AppColors.warning,
          textColor: AppColors.white,
          fontSize: 16.sp);
      return;
    }

    if (widget.endTimeMillis != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > widget.endTimeMillis!) {
        Fluttertoast.showToast(
            msg: "The time to place orders has ended",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
            fontSize: 16.sp);
        return;
      }
    }

    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to place your order'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    _animationController.forward(from: 0.0);
    setState(() {
      _isProcessing = true;
    });

    try {
      final userId = user.uid;
      final hasVotedThisOption = isUserSelectedOption(userId);

      String? previousOption;
      for (var entry in widget.allVotes.entries) {
        if (entry.key != widget.option &&
            (entry.value as List?)?.contains(userId) == true) {
          previousOption = entry.key;
          break;
        }
      }

      final pollRef =
          FirebaseFirestore.instance.collection('polls').doc(widget.pollId);
      final batch = FirebaseFirestore.instance.batch();

      if (hasVotedThisOption) {
        batch.update(pollRef, {
          'votes.${widget.option}': FieldValue.arrayRemove([userId])
        });
      } else {
        if (previousOption != null) {
          batch.update(pollRef, {
            'votes.$previousOption': FieldValue.arrayRemove([userId])
          });
        }

        batch.update(pollRef, {
          'votes.${widget.option}': FieldValue.arrayUnion([userId])
        });
      }

      await batch.commit();

      if (mounted) {
        final theme = Theme.of(context);
        if (!hasVotedThisOption) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Your order for "${widget.option}" has been placed'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              action: SnackBarAction(
                label: 'DISMISS',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Your order for "${widget.option}" has been canceled'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: theme.colorScheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              action: SnackBarAction(
                label: 'DISMISS',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _animationController
            .reverse()
            .then((_) => _animationController.forward());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService().currentUser;
    final bool isSelected = user != null && isUserSelectedOption(user.uid);
    final bool canVote = widget.isActive &&
        (widget.endTimeMillis == null ||
            DateTime.now().millisecondsSinceEpoch <= widget.endTimeMillis!);

    final voteCount = (widget.allVotes[widget.option] as List?)?.length ?? 0;

    int totalVotes = 0;
    for (var entry in widget.allVotes.entries) {
      totalVotes += (entry.value as List?)?.length ?? 0;
    }

    final double percentage = totalVotes > 0 ? (voteCount / totalVotes) : 0.0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child!,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider,
              width: 1.w,
            ),
          ),
        ),
        child: InkWell(
          onTap: (_isProcessing || !canVote) ? null : _handleVote,
          splashColor:
              canVote ? theme.colorScheme.primary.withOpacity(0.1) : null,
          highlightColor:
              canVote ? theme.colorScheme.primary.withOpacity(0.05) : null,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Container(
                          width: 20.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryText
                                  : AppColors.tertiaryText,
                              width: 2.w,
                            ),
                            color: isSelected
                                ? AppColors.primaryText
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: AppColors.white,
                                  size: 12.sp,
                                )
                              : null,
                        ),
                        SizedBox(width: 16.w),
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getFoodEmoji(widget.option),
                              style: TextStyle(fontSize: 20.sp),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            widget.option,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '$voteCount orders',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 20.h,
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    child: percentage > 0
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: percentage,
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 4.w),
                                child: Text(
                                  '${(percentage * 100).round()}%',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.fYellow,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ),
                  Container(
                    height: 6.h,
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3.r),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage > 0
                              ? AppColors.fRedBright
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
