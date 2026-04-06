import 'package:flutter/material.dart';
import '../../domain/models/report_model.dart';
import '../../../../shared/constants/constants.dart';

/// Report Dialog Widget
/// Shows options for reporting a post

class ReportDialog extends StatefulWidget {
  final Function(ReportReason, String) onReport;

  const ReportDialog({
    super.key,
    required this.onReport,
  });

  /// Show report dialog
  static void show(
    BuildContext context, {
    required Function(ReportReason, String) onReport,
  }) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(onReport: onReport),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportReason? _selectedReason;
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(
                  Icons.flag,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Report Post',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            const Text(
              'Why are you reporting this post?',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: AppSpacing.md),

            // Reason options
            ...ReportReason.values.map((reason) => RadioListTile<ReportReason>(
                  title: Text(
                    reason.label,
                    style: AppTextStyles.body1,
                  ),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )),

            const SizedBox(height: AppSpacing.md),

            // Optional details
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(
                labelText: 'Additional details (optional)',
                hintText: 'Provide more context...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _selectedReason == null
                      ? null
                      : () {
                          widget.onReport(
                            _selectedReason!,
                            _detailsController.text.trim(),
                          );
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Submit Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
