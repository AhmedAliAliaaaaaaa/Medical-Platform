import 'package:doctor_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:doctor_app/services/api_service.dart';
import 'package:doctor_app/core/theme/app_theme.dart';
import 'package:doctor_app/services/translation_service.dart';

class RespondToCaseScreen extends StatefulWidget {
  final Map<String, dynamic> caseData;

  const RespondToCaseScreen({super.key, required this.caseData});

  @override
  State<RespondToCaseScreen> createState() => _RespondToCaseScreenState();
}

class _RespondToCaseScreenState extends State<RespondToCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentPlanController = TextEditingController();
  final _notesController = TextEditingController();

  // Translation helpers for doctor reply
  final _replyTranslateInputController = TextEditingController();
  final _replyTranslatedOutputController = TextEditingController();
  String _replyTargetLang = 'ar';
  bool _isReplyTranslating = false;

  Future<void> _translateReply() async {
    final text = _replyTranslateInputController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isReplyTranslating = true);
    try {
      final translated = await TranslationService.translateText(
        text: text,
        targetLang: _replyTargetLang,
      );
      _replyTranslatedOutputController.text = translated;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الترجمة: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isReplyTranslating = false);
    }
  }

  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرد على الحالة'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // معلومات الحالة
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'تفاصيل الحالة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'المريض',
                        widget.caseData['patient_name'] ?? 'غير محدد',
                      ),
                      _buildInfoRow('العنوان', widget.caseData['title'] ?? ''),
                      _buildInfoRow(
                        'الوصف',
                        widget.caseData['description'] ?? '',
                      ),
                      _buildInfoRow(
                        'الأعراض',
                        widget.caseData['symptoms'] ?? '',
                      ),
                      _buildInfoRow(
                        'الأولوية',
                        _getPriorityText(widget.caseData['priority']),
                      ),
                      _buildInfoRow(
                        'تاريخ الإنشاء',
                        _formatDate(widget.caseData['created_at']),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // رسالة خطأ
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                    ],
                  ),
                ),

              // الرد الطبي
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'الرد الطبي',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                          // اختيار لغة سريعة + زر ترجمة محتوى حقل الرد
                          // نستخدم أداة ترجمة واحدة فقط (أسفل)، لذا نزيل زر الترجمة السريع هنا
                          SizedBox(
                            width: 110,
                            child: DropdownButtonFormField<String>(
                              value: _replyTargetLang,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                border: OutlineInputBorder(),
                                labelText: 'اللغة',
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'ar', child: Text('العربية')),
                                DropdownMenuItem(
                                    value: 'en', child: Text('English')),
                                DropdownMenuItem(
                                    value: 'zh', child: Text('中文')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _replyTargetLang = v ?? 'ar'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _contentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'الرد الطبي *',
                          hintText: 'اكتب ردك الطبي على الحالة...',
                          prefixIcon: const Icon(Icons.edit),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى كتابة الرد الطبي';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),
                      // أداة ترجمة موحَّدة (مثل Google): إدخال + اختيار لغة + زر ترجمة + نتيجة
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'مترجم فوري للرد (Google-like)',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _replyTranslateInputController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'نص للترجمة',
                                  hintText: 'اكتب الرد بأي لغة... (EN/AR)',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _replyTargetLang,
                                      decoration: InputDecoration(
                                        labelText: 'اللغة المستهدفة',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'ar',
                                            child: Text('العربية')),
                                        DropdownMenuItem(
                                            value: 'en',
                                            child: Text('English')),
                                      ],
                                      onChanged: (v) => setState(
                                          () => _replyTargetLang = v ?? 'ar'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    height: 44,
                                    child: ElevatedButton.icon(
                                      onPressed: _isReplyTranslating
                                          ? null
                                          : _translateReply,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryBlue,
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: _isReplyTranslating
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white),
                                            )
                                          : const Icon(Icons.translate),
                                      label: const Text('ترجمة'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _replyTranslatedOutputController,
                                maxLines: 3,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'النص المترجم',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      final txt =
                                          _replyTranslatedOutputController.text
                                              .trim();
                                      if (txt.isNotEmpty) {
                                        _contentController.text = txt;
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.content_paste),
                                    label:
                                        const Text('استخدام النص المترجم كَرد'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // التوصيات
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'التوصيات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _recommendationsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'التوصيات *',
                          hintText: 'اكتب توصياتك للمريض...',
                          prefixIcon: const Icon(Icons.recommend),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى كتابة التوصيات';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // التشخيص (اختياري)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'التشخيص (اختياري)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _diagnosisController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'التشخيص',
                          hintText: 'اكتب التشخيص المبدئي...',
                          prefixIcon: const Icon(Icons.local_hospital),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // خطة العلاج (اختياري)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'خطة العلاج (اختياري)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _treatmentPlanController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'خطة العلاج',
                          hintText: 'اكتب خطة العلاج المقترحة...',
                          prefixIcon: const Icon(Icons.healing),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ملاحظات إضافية (اختياري)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ملاحظات إضافية (اختياري)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'ملاحظات إضافية',
                          hintText: 'أي ملاحظات إضافية...',
                          prefixIcon: const Icon(Icons.note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // زر الإرسال
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitResponse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'إرسال الرد',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ملاحظة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'سيتم إرسال ردك إلى المريض وسيتلقى إشعاراً بذلك. تأكد من دقة المعلومات الطبية.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  String _getPriorityText(String? priority) {
    switch (priority) {
      case 'low':
        return 'منخفضة';
      case 'medium':
        return 'متوسطة';
      case 'high':
        return 'عالية';
      case 'urgent':
        return 'عاجلة';
      default:
        return 'غير محدد';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'غير محدد';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _submitResponse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ApiService.respondToCase(
        caseId: widget.caseData['id'],
        content: _contentController.text.trim(),
        recommendations: _recommendationsController.text.trim(),
        diagnosis: _diagnosisController.text.trim().isNotEmpty
            ? _diagnosisController.text.trim()
            : null,
        treatmentPlan: _treatmentPlanController.text.trim().isNotEmpty
            ? _treatmentPlanController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال الرد بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // إرجاع قيمة تشير إلى أن الرد تم إرساله بنجاح
      Navigator.pop(context, true);

      // تحديث لوحة التحكم بعد إرسال الرد
      if (mounted) {
        // إذا كنا في صفحة لوحة تحكم الطبيب، قم بتحديثها
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }

        // إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال الرد بنجاح وتم إزالة الإشعار'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _recommendationsController.dispose();
    _diagnosisController.dispose();
    _treatmentPlanController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
