import 'package:flutter/material.dart';
import 'dart:io';

import 'package:doctor_app/utils/app_theme.dart';
import 'package:doctor_app/widgets/custom_button.dart';
import 'package:doctor_app/widgets/custom_text_field.dart';
import 'package:doctor_app/widgets/translation_widget.dart';
import 'package:doctor_app/widgets/file_picker_widget.dart';
import '../doctors/doctor_list_screen.dart';

class SimpleCreateCaseScreen extends StatefulWidget {
  const SimpleCreateCaseScreen({super.key});

  @override
  State<SimpleCreateCaseScreen> createState() => _SimpleCreateCaseScreenState();
}

class _SimpleCreateCaseScreenState extends State<SimpleCreateCaseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Form Data
  String _selectedPriority = 'normal'; // normal, high, urgent
  List<File> _attachedFiles = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('إنشاء حالة جديدة'),
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. عنوان الحالة
              _buildCaseTitleSection(),
              const SizedBox(height: 20),

              // 2. وصف الأعراض
              _buildSymptomsSection(),
              const SizedBox(height: 20),

              // 3. أولوية الحالة
              _buildPrioritySection(),
              const SizedBox(height: 20),

              // 4. رفع الملفات والصور
              FilePickerWidget(
                onFilesChanged: (files) {
                  setState(() {
                    _attachedFiles = files;
                  });
                },
                initialFiles: _attachedFiles,
              ),
              const SizedBox(height: 20),

              // 5. مترجم النصوص
              TranslationWidget(
                onTranslationComplete: (translatedText) {
                  setState(() {
                    _descriptionController.text = translatedText;
                  });
                },
                initialText: _descriptionController.text,
              ),
              const SizedBox(height: 30),

              // زر اختيار الطبيب
              _buildSelectDoctorButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 1. قسم عنوان الحالة
  Widget _buildCaseTitleSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.title, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'عنوان الحالة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _titleController,
              label: 'عنوان الحالة',
              hint: 'اكتب عنواناً مختصراً وواضحاً للحالة',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال عنوان الحالة';
                }
                if (value.trim().length < 5) {
                  return 'يجب أن يكون العنوان 5 أحرف على الأقل';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // 2. قسم وصف الأعراض
  Widget _buildSymptomsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'وصف الأعراض والحالة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'وصف الأعراض والحالة',
              hint:
                  'اشرح الأعراض والحالة بالتفصيل...\n\nمثال:\n- متى بدأت الأعراض؟\n- ما هي شدة الألم؟\n- هل تتناول أي أدوية؟\n- هل لديك تاريخ مرضي؟',
              maxLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال وصف الحالة';
                }
                if (value.trim().length < 20) {
                  return 'يجب أن يكون الوصف 20 حرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'نصيحة: كلما كان الوصف أكثر تفصيلاً، كان التشخيص أدق',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. قسم أولوية الحالة
  Widget _buildPrioritySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.priority_high, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'أولوية الحالة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildPriorityOption(
                    'normal', 'عادية', 'رد خلال 48 ساعة', Colors.green),
                _buildPriorityOption(
                    'high', 'مستعجلة', 'رد خلال 24 ساعة', Colors.orange),
                _buildPriorityOption(
                    'urgent', 'طارئة', 'رد خلال 6 ساعات', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityOption(
      String value, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: _selectedPriority == value ? color : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: _selectedPriority == value ? color.withOpacity(0.1) : null,
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedPriority,
        onChanged: (String? newValue) {
          setState(() {
            _selectedPriority = newValue!;
          });
        },
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _selectedPriority == value ? color : AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: _selectedPriority == value ? color : Colors.grey[600],
          ),
        ),
        activeColor: color,
      ),
    );
  }

  // زر اختيار الطبيب
  Widget _buildSelectDoctorButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'اختيار الطبيب والمتابعة',
        onPressed: _selectDoctor,
        icon: Icons.person_search,
        backgroundColor: AppTheme.primaryBlue,
        textColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  // الانتقال لصفحة اختيار الطبيب
  Future<void> _selectDoctor() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    // تجميع بيانات الحالة
    final caseData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'priority': _selectedPriority,
      'attachments': _attachedFiles,
    };

    // الانتقال لصفحة اختيار الطبيب مع تمرير بيانات الحالة
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorListScreen(caseData: caseData),
      ),
    );

    // إذا تم اختيار طبيب بنجاح، العودة للصفحة الرئيسية
    if (result == true) {
      Navigator.pop(context);
    }
  }
}
