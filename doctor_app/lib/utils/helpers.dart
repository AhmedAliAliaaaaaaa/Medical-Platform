import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';

class AppHelpers {
  // Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? AppColors.textOnPrimary),
        ),
        backgroundColor: backgroundColor ?? AppColors.primary,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        ),
      ),
    );
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.success);
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.error);
  }

  // Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.warning);
  }

  // Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.info);
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: AppConstants.mediumSpacing),
                  Text(message),
                ],
              ],
            ),
          ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'نعم',
    String cancelText = 'لا',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style:
                    confirmColor != null
                        ? ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                        )
                        : null,
                child: Text(confirmText),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  // Show error dialog
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'موافق',
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(buttonText),
              ),
            ],
          ),
    );
  }

  // Pick image from camera or gallery
  static Future<File?> pickImage({
    required ImageSource source,
    int imageQuality = 80,
  }) async {
    try {
      // Request permission
      Permission permission =
          source == ImageSource.camera ? Permission.camera : Permission.photos;

      final status = await permission.request();
      if (!status.isGranted) {
        throw Exception('Permission denied');
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Pick file
  static Future<File?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          return File(file.path!);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  // Show image picker options
  static void showImagePickerOptions(
    BuildContext context, {
    required Function(File) onImageSelected,
    Function(String)? onError,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.largeRadius),
        ),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('اختر مصدر الصورة', style: AppTextStyles.heading4),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('الكاميرا'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        final image = await pickImage(
                          source: ImageSource.camera,
                        );
                        if (image != null) {
                          onImageSelected(image);
                        }
                      } catch (e) {
                        onError?.call(e.toString());
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('المعرض'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        final image = await pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          onImageSelected(image);
                        }
                      } catch (e) {
                        onError?.call(e.toString());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Get file extension
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  // Check if file is image
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return AppConstants.allowedImageTypes.contains(extension);
  }

  // Check if file is document
  static bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    return AppConstants.allowedDocumentTypes.contains(extension);
  }

  // Check if file is video
  static bool isVideoFile(String fileName) {
    final extension = getFileExtension(fileName);
    return AppConstants.allowedVideoTypes.contains(extension);
  }

  // Launch URL
  static Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  // Launch phone call
  static Future<void> launchPhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch phone call');
    }
  }

  // Launch email
  static Future<void> launchEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    String emailUrl = 'mailto:$email';
    if (subject != null || body != null) {
      emailUrl += '?';
      if (subject != null) {
        emailUrl += 'subject=${Uri.encodeComponent(subject)}';
      }
      if (body != null) {
        if (subject != null) emailUrl += '&';
        emailUrl += 'body=${Uri.encodeComponent(body)}';
      }
    }

    final uri = Uri.parse(emailUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch email');
    }
  }

  // Copy to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // Vibrate device
  static void vibrate() {
    HapticFeedback.lightImpact();
  }

  // Format date
  static String formatDate(DateTime date, {bool includeTime = false}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Today
      if (includeTime) {
        return 'اليوم ${_formatTime(date)}';
      } else {
        return 'اليوم';
      }
    } else if (difference.inDays == 1) {
      // Yesterday
      if (includeTime) {
        return 'أمس ${_formatTime(date)}';
      } else {
        return 'أمس';
      }
    } else if (difference.inDays < 7) {
      // This week
      final weekdays = [
        'الأحد',
        'الاثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
      ];
      final weekday = weekdays[date.weekday % 7];
      if (includeTime) {
        return '$weekday ${_formatTime(date)}';
      } else {
        return weekday;
      }
    } else {
      // Older dates
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      if (includeTime) {
        return '$day/$month/$year ${_formatTime(date)}';
      } else {
        return '$day/$month/$year';
      }
    }
  }

  // Format time
  static String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour =
        hour > 12
            ? hour - 12
            : hour == 0
            ? 12
            : hour;
    return '$displayHour:$minute $period';
  }

  // Get time ago
  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks أسبوع';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months شهر';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years سنة';
    }
  }

  // Validate network connection
  static Future<bool> hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Get device info
  static Future<Map<String, String>> getDeviceInfo() async {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
    };
  }

  // Generate random string
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random % chars.length)),
    );
  }

  // Debounce function calls
  static Timer? _debounceTimer;
  static void debounce(Duration duration, VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  // Show file picker options
  static void showFilePickerOptions(
    BuildContext context, {
    required Function(File) onFileSelected,
    Function(String)? onError,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.largeRadius),
        ),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('اختر نوع الملف', style: AppTextStyles.heading4),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text('صورة'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        final file = await pickFile(type: FileType.image);
                        if (file != null) {
                          onFileSelected(file);
                        }
                      } catch (e) {
                        onError?.call(e.toString());
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: const Text('PDF'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        final file = await pickFile(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        if (file != null) {
                          onFileSelected(file);
                        }
                      } catch (e) {
                        onError?.call(e.toString());
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('مستند'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        final file = await pickFile(
                          type: FileType.custom,
                          allowedExtensions: ['doc', 'docx', 'txt'],
                        );
                        if (file != null) {
                          onFileSelected(file);
                        }
                      } catch (e) {
                        onError?.call(e.toString());
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.video_file),
                    title: const Text('فيديو'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        final file = await pickFile(type: FileType.video);
                        if (file != null) {
                          onFileSelected(file);
                        }
                      } catch (e) {
                        onError?.call(e.toString());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Format date time
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'اليوم ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'أمس ${_formatTime(dateTime)}';
    } else {
      return formatDate(dateTime, includeTime: true);
    }
  }
}
