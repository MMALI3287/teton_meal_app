import 'package:cloud_firestore/cloud_firestore.dart';
import "package:teton_meal_app/services/auth_service.dart";
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  late Animation<double> _progressAnimation;

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

    final user = AuthService().currentUser;
    final voteCount = (widget.allVotes[widget.option] as List?)?.length ?? 0;
    final totalVotes = widget.allVotes.entries
        .fold(0, (sum, entry) => sum + ((entry.value as List?)?.length ?? 0));

    final double startValue = totalVotes > 0 ? voteCount / totalVotes : 0.0;
    _progressAnimation = Tween<double>(begin: 0.0, end: startValue).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
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

  Future<void> _handleVote() async {
    // Double-check poll status from Firestore to ensure we have the latest data
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
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }

      final latestIsActive = pollDoc.data()?['isActive'] ?? false;

      if (!latestIsActive) {
        Fluttertoast.showToast(
            msg: "This menu is no longer accepting orders",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error checking menu status",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    // Check if poll is still active (original check as backup)
    if (!widget.isActive) {
      Fluttertoast.showToast(
          msg: "This menu is no longer accepting orders",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if (widget.endTimeMillis != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > widget.endTimeMillis!) {
        Fluttertoast.showToast(
            msg: "The time to place orders has ended",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }
    }

    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to place your order'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
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
    final int percentageDisplay = (percentage * 100).round();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child!,
        );
      },
      child: Card(
        elevation: isSelected ? 3 : 1,
        shadowColor: isSelected
            ? theme.colorScheme.primary.withOpacity(0.3)
            : Colors.black12,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        color: canVote ? null : Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: !canVote
                ? Colors.grey.withOpacity(0.3)
                : isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: (_isProcessing || !canVote) ? null : _handleVote,
          borderRadius: BorderRadius.circular(16),
          splashColor:
              canVote ? theme.colorScheme.primary.withOpacity(0.1) : null,
          highlightColor:
              canVote ? theme.colorScheme.primary.withOpacity(0.05) : null,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Spacer in place of individual + button (moved to AppBar)
                        SizedBox(width: 42, height: 42),
                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.option,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.black87,
                                ),
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 14,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Your current selection',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            '$voteCount ${voteCount == 1 ? 'order' : 'orders'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, _) {
                                return LinearProgressIndicator(
                                  value: percentage,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.primary
                                            .withOpacity(0.5),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$percentageDisplay%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Overlay for disabled state
              if (!canVote)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'ORDERS CLOSED',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
