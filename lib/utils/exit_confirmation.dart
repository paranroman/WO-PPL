import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:eventure/utils/toast_helper.dart';

class ExitConfirmation extends StatefulWidget {
  final Widget child;

  const ExitConfirmation({super.key, required this.child});

  @override
  State<ExitConfirmation> createState() => _ExitConfirmationState();
}

class _ExitConfirmationState extends State<ExitConfirmation> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
          return;
        }

        final now = DateTime.now();
        final difference = _lastPressedAt == null
            ? null
            : now.difference(_lastPressedAt!);

        if (difference == null || difference > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ToastHelper.showShortToast("Tekan sekali lagi untuk keluar");
        } else {
          SystemNavigator.pop();
        }
      },
      child: widget.child,
    );
  }
}
