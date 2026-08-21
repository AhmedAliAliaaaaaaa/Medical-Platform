
import 'package:flutter/material.dart';
import '../admin_constants.dart';

class AdminLoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;

  const AdminLoadingWidget({
    this.message,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: color ?? AdminConstants.orange),
          const SizedBox(height: 16),
          Text(
            message ?? 'جاري تحميل البيانات...',
            style: AdminConstants.subtitle,
          ),
        ],
      ),
    );
  }
}

class AdminErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryText;

  const AdminErrorWidget({
    this.errorMessage,
    this.title,
    this.onRetry,
    this.retryText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title ?? 'خطأ في تحميل البيانات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryText ?? 'إعادة المحاولة'),
            ),
          ],
        ],
      ),
    );
  }
}

class AdminEmptyWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;

  const AdminEmptyWidget({
    this.message,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'لا توجد بيانات',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
