import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:teton_meal_app/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/custom_exception_dialog.dart';
import 'package:teton_meal_app/app/app_theme.dart';

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
    final votes = widget.allVotes[widget.option];
    return votes != null && (votes as List).contains(userId);
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
        if (mounted) {
          CustomExceptionDialog.showError(
            context: context,
            title: "Error",
            message: "Menu not found",
          );
        }
        return;
      }

      final latestIsActive = pollDoc.data()?['isActive'] ?? false;

      if (!latestIsActive) {
        if (mounted) {
          CustomExceptionDialog.showWarning(
            context: context,
            title: "Menu Closed",
            message: "This menu is no longer accepting orders",
          );
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        CustomExceptionDialog.showError(
          context: context,
          title: "Error",
          message: "Error checking menu status",
        );
      }
      return;
    }

    if (!widget.isActive) {
      if (mounted) {
        CustomExceptionDialog.showWarning(
          context: context,
          title: "Menu Closed",
          message: "This menu is no longer accepting orders",
        );
      }
      return;
    }

    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to place your order'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.fRed2,
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

      if (kDebugMode) {
        print(
            'Voting attempt - User: $userId, Option: ${widget.option}, HasVoted: $hasVotedThisOption');
      }

      String? previousOption;
      for (var entry in widget.allVotes.entries) {
        if (entry.key != widget.option &&
            (entry.value as List?)?.contains(userId) == true) {
          previousOption = entry.key;
          break;
        }
      }

      if (previousOption != null) {
        if (kDebugMode) {
          print('User had previously voted for: $previousOption');
        }
      }

      final pollRef =
          FirebaseFirestore.instance.collection('polls').doc(widget.pollId);

      final pollDoc = await pollRef.get();
      if (!pollDoc.exists) {
        if (kDebugMode) {
          print('Poll document not found: ${widget.pollId}');
        }
        throw Exception('Poll not found');
      }

      final pollData = pollDoc.data() as Map<String, dynamic>;
      final currentVotes = Map<String, dynamic>.from(pollData['votes'] ?? {});

      if (kDebugMode) {
        print('Current votes before update: $currentVotes');
      }

      if (hasVotedThisOption) {
        if (currentVotes.containsKey(widget.option)) {
          final optionVotes =
              List<String>.from(currentVotes[widget.option] ?? []);
          optionVotes.remove(userId);
          if (optionVotes.isEmpty) {
            currentVotes.remove(widget.option);
          } else {
            currentVotes[widget.option] = optionVotes;
          }
        }
      } else {
        if (previousOption != null &&
            currentVotes.containsKey(previousOption)) {
          final prevOptionVotes =
              List<String>.from(currentVotes[previousOption] ?? []);
          prevOptionVotes.remove(userId);
          if (prevOptionVotes.isEmpty) {
            currentVotes.remove(previousOption);
          } else {
            currentVotes[previousOption] = prevOptionVotes;
          }
        }

        if (!currentVotes.containsKey(widget.option)) {
          currentVotes[widget.option] = [userId];
        } else {
          final optionVotes =
              List<String>.from(currentVotes[widget.option] ?? []);
          if (!optionVotes.contains(userId)) {
            optionVotes.add(userId);
            currentVotes[widget.option] = optionVotes;
          }
        }
      }

      await pollRef.update({'votes': currentVotes});

      if (kDebugMode) {
        print('Votes updated successfully: $currentVotes');
      }

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
                textColor: AppColors.fWhite,
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
                textColor: AppColors.fWhite,
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

    final bool canVote = widget.isActive;

    if (kDebugMode) {
      print(
          'VoteOption build - Option: ${widget.option}, IsActive: ${widget.isActive}, CanVote: $canVote, EndTime: ${widget.endTimeMillis}, CurrentTime: ${DateTime.now().millisecondsSinceEpoch}');
    }

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
          color: AppColors.fWhite,
          border: Border(
            bottom: BorderSide(
              color: AppColors.fLineaAndLabelBox,
              width: 1.w,
            ),
          ),
        ),
        child: InkWell(
          onTap: (_isProcessing || !canVote)
              ? null
              : () {
                  if (kDebugMode) {
                    print(
                        'Vote option tapped! Option: ${widget.option}, CanVote: $canVote, IsProcessing: $_isProcessing');
                  }
                  _handleVote();
                },
          splashColor:
              canVote ? theme.colorScheme.primary.withValues(alpha: 0.1) : null,
          highlightColor: canVote
              ? theme.colorScheme.primary.withValues(alpha: 0.05)
              : null,
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
                                  ? AppColors.fRedBright
                                  : AppColors.fIconAndLabelText,
                              width: 2.w,
                            ),
                            color: isSelected
                                ? AppColors.fRedBright
                                : AppColors.fTransparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: AppColors.fWhite,
                                  size: 12.sp,
                                )
                              : null,
                        ),
                        SizedBox(width: 16.w),
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: const BoxDecoration(
                            color: AppColors.fLineaAndLabelBox,
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
                              color: AppColors.fRedBright,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.fLineaAndLabelBox,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '$voteCount orders',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.fTextH2,
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
                        backgroundColor: AppColors.fLineaAndLabelBox,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage > 0
                              ? AppColors.fRedBright
                              : AppColors.fTransparent,
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
