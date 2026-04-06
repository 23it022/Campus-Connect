import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Custom Text Field Widget
/// Reusable text input field with focus-animated container, consistent styling, and validation
class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: _isFocused ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppShadows.subtle,
          ),
          child: Focus(
            onFocusChange: (focused) {
              setState(() => _isFocused = focused);
            },
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              validator: widget.validator,
              style: AppTextStyles.body1,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon:
                    widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
                suffixIcon: widget.suffixIcon,
                errorText: widget.errorText,
                fillColor: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
