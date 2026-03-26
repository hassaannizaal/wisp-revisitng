import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String iconPath; // In a real app, this would be an asset path or IconData
  final VoidCallback onPressed;
  final bool isIconData;
  final IconData? iconData;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconPath = '',
    this.isIconData = true,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isIconData && iconData != null)
            Icon(iconData, size: 24)
          else if (!isIconData && iconPath.isNotEmpty)
            Image.asset(iconPath, height: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
