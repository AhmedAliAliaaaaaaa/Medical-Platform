import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/config/server_settings.dart';
import '../../core/config/app_config.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/helpers.dart';

class ServerSettingsScreen extends StatefulWidget {
  const ServerSettingsScreen({Key? key}) : super(key: key);

  @override
  _ServerSettingsScreenState createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String _currentUrl = '';
  String _defaultUrl = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUrl = await ServerSettings.getCurrentServerUrl();
      final defaultUrl = ServerSettings.getDefaultServerUrl();

      setState(() {
        _currentUrl = currentUrl;
        _defaultUrl = defaultUrl;
        _urlController.text = currentUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, 'فشل تحميل الإعدادات: ${e.toString()}');
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newUrl = _urlController.text.trim();

    if (!ServerSettings.isValidUrl(newUrl)) {
      showSnackBar(context, 'عنوان الخادم غير صالح');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ServerSettings.saveServerUrl(newUrl);

      // تحديث الإعدادات في التطبيق
      setState(() {
        _currentUrl = newUrl;
        _isLoading = false;
      });

      showSnackBar(context, 'تم حفظ الإعدادات بنجاح');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, 'فشل حفظ الإعدادات: ${e.toString()}');
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _resetToDefault() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ServerSettings.resetToDefault();
      final defaultUrl = ServerSettings.getDefaultServerUrl();

      setState(() {
        _currentUrl = defaultUrl;
        _urlController.text = defaultUrl;
        _isLoading = false;
      });

      showSnackBar(context, 'تم إعادة التعيين إلى الإعدادات الافتراضية');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, 'فشل إعادة التعيين: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الخادم'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'عنوان الخادم الحالي:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentUrl,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'عنوان الخادم الجديد:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _urlController,
                      label: 'عنوان الخادم',
                      hint: 'أدخل عنوان الخادم',
                      prefixIcon: Icons.link,
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال عنوان الخادم';
                        }
                        if (!ServerSettings.isValidUrl(value.trim())) {
                          return 'عنوان الخادم غير صالح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'ملاحظات:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• العنوان الافتراضي: $_defaultUrl',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '• تأكد من أن العنوان يبدأ بـ http:// أو https://',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '• يجب أن يكون الخادم متاحًا على العنوان المحدد',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'حفظ',
                            onPressed: _saveSettings,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'إعادة تعيين',
                            onPressed: _resetToDefault,
                            isOutlined: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'نسخ العنوان الحالي',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _currentUrl));
                        showSnackBar(context, 'تم نسخ العنوان إلى الحافظة');
                      },
                      isOutlined: true,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
