import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/constants.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

/// Support Ticket Detail Screen
/// Displays detailed information about a support ticket
class SupportTicketDetailScreen extends StatefulWidget {
  final String ticketId;

  const SupportTicketDetailScreen({
    super.key,
    required this.ticketId,
  });

  @override
  State<SupportTicketDetailScreen> createState() =>
      _SupportTicketDetailScreenState();
}

class _SupportTicketDetailScreenState extends State<SupportTicketDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTicket();
    });
  }

  Future<void> _loadTicket() async {
    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.loadTicket(widget.ticketId);
  }

  Future<void> _closeTicket() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Ticket'),
        content: const Text('Are you sure you want to close this ticket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      final profileProvider = context.read<ProfileProvider>();
      final userId = authProvider.currentUser?.uid;

      if (userId != null) {
        final success = await profileProvider.updateTicketStatus(
          widget.ticketId,
          'closed',
          userId,
        );

        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ticket closed'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, _) {
              final ticket = profileProvider.selectedTicket;
              if (ticket != null && ticket.isOpen) {
                return PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'close',
                      child: ListTile(
                        leading: Icon(Icons.close),
                        title: Text('Close Ticket'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'close') {
                      _closeTicket();
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          if (profileProvider.isLoading &&
              profileProvider.selectedTicket == null) {
            return const LoadingWidget();
          }

          final ticket = profileProvider.selectedTicket;
          if (ticket == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Ticket not found',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject
                Text(
                  ticket.subject,
                  style: AppTextStyles.h2,
                ),

                const SizedBox(height: AppSpacing.md),

                // Status, Category, and Priority
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _buildStatusBadge(ticket.status),
                    _buildPriorityChip(ticket.priority),
                    Chip(
                      label: Text(ticket.category),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Date Info
                _buildInfoRow(
                  'Created',
                  DateFormat('MMMM dd, yyyy \'at\' hh:mm a')
                      .format(ticket.createdAt),
                ),

                if (ticket.resolvedAt != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _buildInfoRow(
                    'Resolved',
                    DateFormat('MMMM dd, yyyy \'at\' hh:mm a')
                        .format(ticket.resolvedAt!),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                // Description Section
                const Text(
                  'Description',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Text(
                    ticket.description,
                    style: AppTextStyles.body1,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Admin Response Section
                if (ticket.adminResponse != null) ...[
                  const Text(
                    'Support Response',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.support_agent,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Support Team',
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          ticket.adminResponse!,
                          style: AppTextStyles.body1,
                        ),
                      ],
                    ),
                  ),
                ] else if (ticket.status == 'open') ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Your ticket is in queue. Our support team will respond soon.',
                            style: AppTextStyles.body2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'open':
        color = Colors.orange;
        label = 'Open';
        break;
      case 'in_progress':
        color = Colors.blue;
        label = 'In Progress';
        break;
      case 'resolved':
        color = Colors.green;
        label = 'Resolved';
        break;
      case 'closed':
        color = Colors.grey;
        label = 'Closed';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;

    switch (priority) {
      case 'low':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'high':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag,
            size: 16,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            priority.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body2,
          ),
        ),
      ],
    );
  }
}
