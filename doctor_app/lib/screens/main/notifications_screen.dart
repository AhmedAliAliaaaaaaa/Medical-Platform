import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/notification_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    await notificationProvider.refresh();

    setState(() => _isLoading = false);
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(languageProvider.isArabic ? 'الإشعارات' : 'Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        automaticallyImplyLeading: false,
        actions: [
          if (notificationProvider.unreadCount > 0)
            TextButton(
              onPressed: () => _markAllAsRead(),
              child: Text(
                languageProvider.isArabic ? 'قراءة الكل' : 'Mark All Read',
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshNotifications,
          ),
        ],
      ),
      body: _buildBody(notificationProvider, languageProvider),
    );
  }

  Widget _buildBody(
    NotificationProvider notificationProvider,
    LanguageProvider languageProvider,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notificationProvider.notifications.isEmpty) {
      return _buildEmptyState(languageProvider);
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        itemCount: notificationProvider.notifications.length,
        itemBuilder: (context, index) {
          final notification = notificationProvider.notifications[index];
          return _buildNotificationCard(notification, languageProvider);
        },
      ),
    );
  }

  Widget _buildEmptyState(LanguageProvider languageProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: AppConstants.extraLargeIconSize,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            Text(
              languageProvider.isArabic
                  ? 'لا توجد إشعارات'
                  : 'No Notifications',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              languageProvider.isArabic
                  ? 'ستظهر الإشعارات الجديدة هنا'
                  : 'New notifications will appear here',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            CustomButton(
              text: languageProvider.isArabic ? 'تحديث' : 'Refresh',
              icon: Icons.refresh,
              onPressed: _refreshNotifications,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    dynamic notification,
    LanguageProvider languageProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.mediumSpacing),
      elevation:
          notification.isRead
              ? AppConstants.lowElevation
              : AppConstants.mediumElevation,
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.mediumSpacing),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            color:
                notification.isRead
                    ? null
                    : AppColors.primary.withOpacity(0.05),
            border:
                notification.isRead
                    ? null
                    : Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Notification Icon
                  Container(
                    padding: const EdgeInsets.all(AppConstants.smallSpacing),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(
                        notification.type,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallRadius,
                      ),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: AppConstants.mediumIconSize,
                    ),
                  ),

                  const SizedBox(width: AppConstants.mediumSpacing),

                  // Title and Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight:
                                notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppConstants.smallSpacing / 2),
                        Text(
                          AppHelpers.getTimeAgo(notification.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Unread Indicator
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppConstants.mediumSpacing),

              // Message
              Text(
                notification.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color:
                      notification.isRead
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Action Buttons (if any)
              if (notification.actionUrl != null ||
                  notification.caseId != null) ...[
                const SizedBox(height: AppConstants.mediumSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!notification.isRead)
                      TextButton(
                        onPressed: () => _markAsRead(notification),
                        child: Text(
                          languageProvider.isArabic
                              ? 'تم القراءة'
                              : 'Mark Read',
                        ),
                      ),
                    if (notification.actionUrl != null ||
                        notification.caseId != null)
                      TextButton(
                        onPressed:
                            () => _handleNotificationAction(notification),
                        child: Text(languageProvider.isArabic ? 'عرض' : 'View'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'new_case':
        return Icons.medical_services;
      case 'case_update':
        return Icons.update;
      case 'appointment':
        return Icons.event;
      case 'message':
        return Icons.message;
      case 'system':
        return Icons.info;
      case 'approval':
        return Icons.check_circle;
      case 'rejection':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'new_case':
        return AppColors.info;
      case 'case_update':
        return AppColors.warning;
      case 'appointment':
        return AppColors.primary;
      case 'message':
        return AppColors.success;
      case 'system':
        return AppColors.textSecondary;
      case 'approval':
        return AppColors.success;
      case 'rejection':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  void _handleNotificationTap(dynamic notification) {
    if (!notification.isRead) {
      _markAsRead(notification);
    }

    _handleNotificationAction(notification);
  }

  void _handleNotificationAction(dynamic notification) {
    if (notification.caseId != null) {
      // Navigate to case details
      Navigator.pushNamed(
        context,
        '/case-details',
        arguments: {'caseId': notification.caseId},
      );
    } else if (notification.actionUrl != null) {
      // Handle other actions
      // TODO: Implement URL handling
    }
  }

  Future<void> _markAsRead(dynamic notification) async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    await notificationProvider.markAsRead(notification.id);
  }

  Future<void> _markAllAsRead() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    final confirmed = await AppHelpers.showConfirmationDialog(
      context,
      title: languageProvider.isArabic ? 'تأكيد' : 'Confirm',
      message:
          languageProvider.isArabic
              ? 'هل تريد تمييز جميع الإشعارات كمقروءة؟'
              : 'Do you want to mark all notifications as read?',
      confirmText: languageProvider.isArabic ? 'نعم' : 'Yes',
      cancelText: languageProvider.isArabic ? 'إلغاء' : 'Cancel',
    );

    if (confirmed) {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      await notificationProvider.markAllAsRead();
    }
  }
}
