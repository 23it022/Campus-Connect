import 'package:flutter/material.dart';
import '../../../../shared/constants/constants.dart';
import '../../../auth/domain/models/user_model.dart';

/// Attendee List Widget
/// Displays list of event attendees
class AttendeeList extends StatefulWidget {
  final List<UserModel> attendees;
  final int totalCount;
  final bool showAll;

  const AttendeeList({
    super.key,
    required this.attendees,
    required this.totalCount,
    this.showAll = false,
  });

  @override
  State<AttendeeList> createState() => _AttendeeListState();
}

class _AttendeeListState extends State<AttendeeList> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.attendees.isEmpty) {
      return const Center(
        child: Text(
          'No attendees yet',
          style: AppTextStyles.body2,
        ),
      );
    }

    final displayedAttendees = widget.showAll || _isExpanded
        ? widget.attendees
        : widget.attendees.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attendees Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.8,
          ),
          itemCount: displayedAttendees.length,
          itemBuilder: (context, index) {
            final attendee = displayedAttendees[index];
            return _buildAttendeeAvatar(attendee);
          },
        ),

        // Show More/Less Button
        if (widget.attendees.length > 5 && !widget.showAll)
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              label: Text(
                _isExpanded ? 'Show Less' : '+${widget.totalCount - 5} more',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAttendeeAvatar(UserModel attendee) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: attendee.profileImage.isNotEmpty
              ? NetworkImage(attendee.profileImage)
              : null,
          child: attendee.profileImage.isEmpty
              ? Text(
                  attendee.name.isNotEmpty
                      ? attendee.name[0].toUpperCase()
                      : 'U',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          attendee.name.split(' ').first, // First name only
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Compact Attendee List (for small displays)
class CompactAttendeeList extends StatelessWidget {
  final List<UserModel> attendees;
  final int totalCount;

  const CompactAttendeeList({
    super.key,
    required this.attendees,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    if (attendees.isEmpty) return const SizedBox.shrink();

    final displayedAttendees = attendees.take(3).toList();
    final remaining = totalCount - displayedAttendees.length;

    return Row(
      children: [
        // Stack of avatars
        SizedBox(
          width: displayedAttendees.length * 28.0,
          height: 32,
          child: Stack(
            children: List.generate(
              displayedAttendees.length,
              (index) => Positioned(
                left: index * 24.0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.white,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage:
                        displayedAttendees[index].profileImage.isNotEmpty
                            ? NetworkImage(
                                displayedAttendees[index].profileImage)
                            : null,
                    child: displayedAttendees[index].profileImage.isEmpty
                        ? Text(
                            displayedAttendees[index].name.isNotEmpty
                                ? displayedAttendees[index]
                                    .name[0]
                                    .toUpperCase()
                                : 'U',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Remaining count
        if (remaining > 0)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              '+$remaining',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
