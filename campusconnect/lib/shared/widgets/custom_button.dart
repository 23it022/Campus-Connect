import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Custom Button Widget
/// Reusable button with gradient background, loading state, and press animation
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton.icon(
          onPressed: widget.isLoading ? null : widget.onPressed,
          icon: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : (widget.icon != null
                  ? Icon(widget.icon)
                  : const SizedBox.shrink()),
          label: Text(widget.text),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: widget.isLoading
                ? LinearGradient(
                    colors: [
                      AppColors.primaryLight.withValues(alpha: 0.6),
                      AppColors.primary.withValues(alpha: 0.6),
                    ],
                  )
                : AppGradients.button,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.isLoading ? [] : AppShadows.elevated,
          ),
          child: ElevatedButton.icon(
            onPressed: widget.isLoading ? null : widget.onPressed,
            icon: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : (widget.icon != null
                    ? Icon(widget.icon)
                    : const SizedBox.shrink()),
            label: Text(widget.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
