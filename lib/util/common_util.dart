import 'package:flutter/material.dart';
import 'package:khiem_vais_test/common/extensions.dart';
import 'package:khiem_vais_test/res/spacing.dart';

class CommonUtil {
  static void displaySnackbar({
    BuildContext? context,
    String content = '',
    bool isErrorMessage = true,
    TextStyle textStyle = const TextStyle(),
  }) {
    if (context == null || content.isEmpty) return;
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          content,
          style: textStyle.copyWith(
            color: isErrorMessage ? context.colorScheme.onError : null,
            fontSize: context.textTheme.bodyMedium?.fontSize ?? 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isErrorMessage ? context.colorScheme.error : null,
        margin: const EdgeInsetsDirectional.all(AppSpacing.sp8),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 500),
        elevation: 4,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp12,
          vertical: AppSpacing.sp16,
        ),
      ),
    );
  }
}
