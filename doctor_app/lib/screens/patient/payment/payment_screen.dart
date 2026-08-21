import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/patient_api_service.dart';
import '../../../utils/app_theme.dart';
import 'package:doctor_app/screens/patient/dashboard/professional_patient_dashboard.dart';

class PaymentScreen extends StatefulWidget {
  // Either caseId is provided (existing case) OR details to create a new case
  final int? caseId;
  final int doctorId;
  final double amount;

  // Fields for creating a case after successful payment
  final String? title;
  final String? description;
  final String? symptoms;
  final String? priority; // low | medium | high
  final List<File>? attachments;

  const PaymentScreen({
    super.key,
    this.caseId,
    required this.doctorId,
    required this.amount,
    this.title,
    this.description,
    this.symptoms,
    this.priority,
    this.attachments,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  // القيم المختارة للشهر والسنة
  String? _selectedMonth;
  String? _selectedYear;
  // قوائم الأشهر والسنين
  final List<String> _months =
      List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
  late final List<String> _years;
  final _cvvController = TextEditingController();

  String _paymentType = 'credit_card';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // السنوات: من السنة الحالية وحتى +10 سنوات
    final currentYear = DateTime.now().year;
    _years =
        List.generate(11, (i) => (currentYear + i).toString().substring(2));
    // القيم الافتراضية: هذا الشهر وهذه السنة
    _selectedMonth = DateTime.now().month.toString().padLeft(2, '0');
    _selectedYear = _years.first;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // يمكن استخدام القيم المختارة لاحقًا لإرسالها للباكند
    final selectedMonth = _selectedMonth; // MM
    final selectedYear = _selectedYear; // YY

    setState(() {
      _isLoading = true;
    });

    try {
      // محاكاة عملية الدفع - في التطبيق الحقيقي سيتم الاتصال بواجهة الدفع
      await Future.delayed(const Duration(seconds: 2)); // محاكاة وقت المعالجة

      // في التطبيق الحقيقي، سيتم هنا إرسال بيانات الدفع إلى الخادم
      // والتحقق من صحة البطاقة وإتمام عملية الدفع

      // تم الدفع بنجاح (محاكاة)
      // بعد الدفع: إذا لم يكن لدينا caseId، ننشئ الحالة الآن ونرسلها للطبيب
      int? caseId = widget.caseId;
      if (caseId == null) {
        if (widget.title == null ||
            widget.description == null ||
            widget.symptoms == null) {
          throw Exception('بيانات الحالة غير مكتملة لإرسالها للطبيب بعد الدفع');
        }
        final result = await ApiService.createMedicalCase(
          title: widget.title!.trim(),
          description: widget.description!.trim(),
          symptoms: widget.symptoms!.trim(),
          doctorId: widget.doctorId,
          priority: widget.priority ?? 'medium',
        );
        caseId = result['case_id'] as int?;
        // ارفع المرفقات إن وجدت
        final files = widget.attachments ?? [];
        if (caseId != null && files.isNotEmpty) {
          await PatientApiService.uploadCaseAttachments(
              caseId: caseId, files: files);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الدفع وإرسال الحالة للطبيب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // العودة إلى لوحة تحكم المريض
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProfessionalPatientDashboard()),
        (route) => false,
      );
    } catch (e) {
      // حدث خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الدفع'),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات الدفع
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'معلومات الدفع',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // نوع الدفع
                        const Text(
                          'نوع الدفع',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _paymentType,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'credit_card',
                              child: Text('بطاقة ائتمان'),
                            ),
                            DropdownMenuItem(
                              value: 'debit_card',
                              child: Text('بطاقة خصم مباشر'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _paymentType = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء اختيار نوع الدفع';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // رقم البطاقة
                        const Text(
                          'رقم البطاقة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cardNumberController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: '1234 5678 9012 3456',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم البطاقة';
                            }
                            if (value.length < 13 || value.length > 16) {
                              return 'رقم البطاقة غير صالح';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // اسم حامل البطاقة
                        const Text(
                          'اسم حامل البطاقة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cardHolderNameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: 'الاسم كما يظهر على البطاقة',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم حامل البطاقة';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // تاريخ الانتهاء والـ CVV
                        Row(
                          children: [
                            // الشهر
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الشهر',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _selectedMonth,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 16),
                                    ),
                                    items: _months
                                        .map((m) => DropdownMenuItem(
                                            value: m, child: Text(m)))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => _selectedMonth = val),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'الشهر';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // السنة
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'السنة',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _selectedYear,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 16),
                                    ),
                                    items: _years
                                        .map((y) => DropdownMenuItem(
                                            value: y, child: Text(y)))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => _selectedYear = val),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'السنة';
                                      }
                                      // تحقق أن السنة ليست أقل من السنة الحالية (YY)
                                      final currentYear =
                                          DateTime.now().year % 100;
                                      final yy = int.tryParse(value);
                                      if (yy == null || yy < currentYear) {
                                        return 'انتهت صلاحية البطاقة';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // CVV
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'CVV',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _cvvController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      hintText: '123',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 16),
                                    ),
                                    keyboardType: TextInputType.number,
                                    maxLength: 3,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'CVV';
                                      }
                                      if (value.length < 3) {
                                        return 'CVV غير صالح';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // مبلغ الدفع
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'المبلغ الإجمالي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.amount.toStringAsFixed(2)} ريال',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // الأزرار
                Row(
                  children: [
                    // زر الرجوع
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'رجوع',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // زر الدفع
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'دفع',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
