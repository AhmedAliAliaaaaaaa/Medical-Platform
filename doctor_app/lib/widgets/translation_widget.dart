import 'package:flutter/material.dart';
import 'package:doctor_app/utils/app_theme.dart';
import 'package:doctor_app/services/translation_service.dart';
import 'package:doctor_app/widgets/custom_text_field.dart';

class TranslationWidget extends StatefulWidget {
  final Function(String) onTranslationComplete;
  final String? initialText;

  const TranslationWidget({
    super.key,
    required this.onTranslationComplete,
    this.initialText,
  });

  @override
  State<TranslationWidget> createState() => _TranslationWidgetState();
}

class _TranslationWidgetState extends State<TranslationWidget> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();

  String _sourceLang = 'ar';
  String _targetLang = 'en';
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _inputController.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.translate, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'مترجم النصوص',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Language Selection
            _buildLanguageSelector(),
            const SizedBox(height: 16),

            // Input Text
            CustomTextField(
              controller: _inputController,
              label: _sourceLang == 'ar' ? 'النص العربي' : 'English Text',
              hint: _sourceLang == 'ar'
                  ? 'اكتب النص العربي هنا للترجمة...'
                  : 'Type English text here to translate...',
              maxLines: 4,
            ),
            const SizedBox(height: 12),

            // Translate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTranslating ? null : _translateText,
                icon: _isTranslating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.translate),
                label: Text(_isTranslating ? 'جاري الترجمة...' : 'ترجم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Output Text
            CustomTextField(
              controller: _outputController,
              label: _targetLang == 'ar' ? 'النص العربي' : 'English Text',
              hint: 'النص المترجم سيظهر هنا...',
              maxLines: 4,
              readOnly: true,
            ),
            const SizedBox(height: 12),

            // Action Buttons
            if (_outputController.text.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _useTranslation,
                      icon: const Icon(Icons.check),
                      label: const Text('استخدم الترجمة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _clearTranslation,
                      icon: const Icon(Icons.clear),
                      label: const Text('مسح'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Tips
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'نصيحة: يمكنك كتابة وصف حالتك بالعربية ثم ترجمته للإنجليزية للحصول على استشارة أدق',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: '$_sourceLang-$_targetLang',
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'ar-en',
                    child: Text('العربية → English'),
                  ),
                  DropdownMenuItem(
                    value: 'en-ar',
                    child: Text('English → العربية'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    final parts = value!.split('-');
                    _sourceLang = parts[0];
                    _targetLang = parts[1];
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: _swapLanguages,
          icon: const Icon(Icons.swap_horiz),
          tooltip: 'عكس اتجاه الترجمة',
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _translateText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال نص للترجمة')),
      );
      return;
    }

    setState(() => _isTranslating = true);

    try {
      final translated = await TranslationService.translateText(
        text: text,
        targetLang: _targetLang,
      );

      setState(() {
        _outputController.text = translated;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الترجمة: ${e.toString()}')),
      );
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;

      // تبديل النصوص أيضاً
      final tempText = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = tempText;
    });
  }

  void _useTranslation() {
    final translation = _outputController.text.trim();
    if (translation.isNotEmpty) {
      widget.onTranslationComplete(translation);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم استخدام الترجمة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearTranslation() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
    });
  }
}
