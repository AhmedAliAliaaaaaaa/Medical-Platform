import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/base_api_service.dart';

class NotificationSenderFixed extends StatefulWidget {
  const NotificationSenderFixed({Key? key}) : super(key: key);

  @override
  State<NotificationSenderFixed> createState() =>
      _NotificationSenderFixedState();
}

class _NotificationSenderFixedState extends State<NotificationSenderFixed> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  List<Map<String, dynamic>> _patients = [];
  String? _selectedPatientId;
  String _notificationType = 'doctor_message';
  bool _isLoading = false;
  bool _isSending = false;
  bool _sendToAll = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 Loading patients from API...');

      // استخدام دالة واحدة لجلب المرضى الذين تعامل معهم الطبيب
      final patientsData = await ApiService.getPatients();

      List<Map<String, dynamic>> patients = [];

      if (patientsData is List) {
        for (final patient in patientsData) {
          if (patient is Map<String, dynamic>) {
            // استخراج معرف واسم المريض
            final patientId = patient['id']?.toString();
            String patientName = '';

            // محاولة الحصول على اسم المريض من حقول مختلفة
            if (patient['name'] != null) {
              patientName = patient['name'];
            } else if (patient['patient_name'] != null) {
              patientName = patient['patient_name'];
            } else {
              // تجميع الاسم من الاسم الأول والأخير
              final firstName = patient['first_name']?.toString() ?? '';
              final lastName = patient['last_name']?.toString() ?? '';
              patientName = '$firstName $lastName'.trim();

              // إذا كان الاسم فارغًا، استخدم اسم المستخدم أو البريد الإلكتروني
              if (patientName.isEmpty) {
                patientName = patient['username']?.toString() ??
                    patient['email']?.toString() ??
                    'مريض بدون اسم';
              }
            }

            if (patientId != null && patientName.isNotEmpty) {
              patients.add({
                'id': patientId,
                'name': patientName,
              });
            }
          }
        }
      }

      // ترتيب المرضى حسب الاسم
      patients.sort((a, b) => a['name'].compareTo(b['name']));

      setState(() {
        _patients = patients;
        _isLoading = false;
      });

      print('✅ Total patients loaded: ${patients.length}');
      if (patients.isEmpty) {
        print('⚠️ No patients found! This might indicate:');
        print('   1. No patients have sent cases to this doctor');
        print('   2. API endpoint is not working correctly');
      } else {
        for (final patient in patients) {
          print('   - ${patient['name']} (ID: ${patient['id']})');
        }
      }
    } catch (e) {
      print('❌ Critical error loading patients: $e');
      setState(() {
        _patients = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل قائمة المرضى: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _sendNotification() async {
    print('🔔 _sendNotification called');
    print('📋 _sendToAll: $_sendToAll');
    print('📋 _selectedPatientId: $_selectedPatientId');
    print('📋 Title: "${_titleController.text.trim()}"');
    print('📋 Message: "${_messageController.text.trim()}"');
    print('📋 Patients count: ${_patients.length}');

    if ((!_sendToAll && _selectedPatientId == null) ||
        _messageController.text.trim().isEmpty ||
        _titleController.text.trim().isEmpty) {
      print('❌ Validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('يرجى اختيار مريض أو "جميع المرضى" وكتابة العنوان والرسالة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('✅ Validation passed, starting send process');
    setState(() {
      _isSending = true;
    });

    try {
      print('🚀 Starting notification sending process...');
      String patientName = '';
      int successCount = 0;
      int failureCount = 0;
      List<String> errors = [];

      if (_sendToAll) {
        patientName = 'جميع المرضى';
        print('📢 Sending to all patients (${_patients.length} patients)');

        // إرسال لجميع المرضى
        for (final patient in _patients) {
          final patientId = int.tryParse(patient['id']);
          if (patientId != null) {
            try {
              print(
                  '📤 Sending notification to ${patient['name']} (ID: $patientId)');

              final result = await ApiService.sendNotificationToPatient(
                patientId: patientId,
                title: _titleController.text.trim(),
                message: _messageController.text.trim(),
                type: _notificationType,
              );

              print('✅ Successfully sent to ${patient['name']}: $result');
              successCount++;
            } catch (e) {
              print(
                  '❌ Failed to send notification to patient ${patient['name']}: $e');
              failureCount++;
              errors.add('${patient['name']}: $e');
            }
          } else {
            print(
                '⚠️ Invalid patient ID for ${patient['name']}: ${patient['id']}');
            failureCount++;
            errors.add('${patient['name']}: معرف غير صحيح');
          }
        }

        // تحديث اسم المريض ليشمل الإحصائيات
        patientName = 'جميع المرضى (نجح: $successCount، فشل: $failureCount)';
      } else {
        // إرسال لمريض واحد
        final selectedPatient =
            _patients.firstWhere((p) => p['id'] == _selectedPatientId);
        patientName = selectedPatient['name'];
        final patientId = int.tryParse(_selectedPatientId!);

        if (patientId == null) {
          throw Exception('معرف المريض غير صحيح: $_selectedPatientId');
        }

        print(
            '📤 Sending notification to single patient: $patientName (ID: $patientId)');
        print('📝 Title: ${_titleController.text.trim()}');
        print('📝 Message: ${_messageController.text.trim()}');
        print('📝 Type: $_notificationType');

        final result = await ApiService.sendNotificationToPatient(
          patientId: patientId,
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          type: _notificationType,
        );

        print('✅ Successfully sent notification: $result');
        successCount = 1;
      }

      if (mounted) {
        // عرض رسالة النجاح مع التفاصيل
        String successMessage;
        if (_sendToAll) {
          if (failureCount == 0) {
            successMessage =
                'تم إرسال الإشعار لجميع المرضى بنجاح ($successCount مريض)';
          } else {
            successMessage =
                'تم إرسال الإشعار لـ $successCount مريض، فشل مع $failureCount مريض';
          }
        } else {
          successMessage = 'تم إرسال الإشعار إلى $patientName بنجاح';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: failureCount == 0 ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );

        // عرض تفاصيل الأخطاء إذا وجدت
        if (errors.isNotEmpty && _sendToAll) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تفاصيل الأخطاء'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: errors
                          .map((error) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text('• $error',
                                    style: const TextStyle(fontSize: 12)),
                              ))
                          .toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('حسناً'),
                    ),
                  ],
                ),
              );
            }
          });
        }

        // مسح الحقول بعد الإرسال الناجح (فقط إذا لم تكن هناك أخطاء أو كان إرسال فردي)
        if (failureCount == 0 || !_sendToAll) {
          _messageController.clear();
          _titleController.clear();
          setState(() {
            _selectedPatientId = null;
            _notificationType = 'doctor_message';
            _sendToAll = false;
          });
        }
      }
    } catch (e) {
      print('❌ Critical error in notification sending: $e');

      if (mounted) {
        String errorMessage = 'فشل إرسال الإشعار';

        // تحسين رسائل الخطأ حسب نوع المشكلة
        if (e.toString().contains('لا يوجد اتصال بالإنترنت')) {
          errorMessage =
              'لا يوجد اتصال بالإنترنت. تحقق من الاتصال وحاول مرة أخرى.';
        } else if (e.toString().contains('401')) {
          errorMessage =
              'انتهت صلاحية تسجيل الدخول. يرجى تسجيل الدخول مرة أخرى.';
        } else if (e.toString().contains('404')) {
          errorMessage = 'خدمة الإشعارات غير متاحة حالياً.';
        } else if (e.toString().contains('500')) {
          errorMessage = 'خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.';
        } else if (e.toString().contains('معرف المريض غير صحيح')) {
          errorMessage = 'معرف المريض غير صحيح. يرجى إعادة تحميل قائمة المرضى.';
        } else {
          errorMessage = 'فشل إرسال الإشعار: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: () => _sendNotification(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إرسال إشعار للمرضى'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل قائمة المرضى...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // بطاقة اختيار المريض
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              const Text(
                                'اختيار المريض',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_patients.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.info, color: Colors.orange[700]),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'لا توجد مرضى متاحين',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'لإرسال الإشعارات، يجب أن يكون لديك مرضى قاموا بإرسال حالات طبية إليك.',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: _loadPatients,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('إعادة المحاولة'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: [
                                // خيار إرسال لجميع المرضى
                                CheckboxListTile(
                                  title: const Text('إرسال لجميع المرضى'),
                                  value: _sendToAll,
                                  onChanged: (value) {
                                    setState(() {
                                      _sendToAll = value ?? false;
                                      if (_sendToAll) {
                                        _selectedPatientId = null;
                                      }
                                    });
                                  },
                                  activeColor: Colors.blue[600],
                                ),

                                // قائمة المرضى
                                if (!_sendToAll)
                                  DropdownButtonFormField<String>(
                                    value: _selectedPatientId,
                                    decoration: const InputDecoration(
                                      labelText: 'اختر المريض',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person_search),
                                    ),
                                    items: _patients.map((patient) {
                                      return DropdownMenuItem<String>(
                                        value: patient['id'],
                                        child: Text(patient['name']),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPatientId = value;
                                      });
                                    },
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // بطاقة تفاصيل الإشعار
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.notifications,
                                  color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              const Text(
                                'تفاصيل الإشعار',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // عنوان الإشعار
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'عنوان الإشعار',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.title),
                            ),
                            maxLength: 100,
                          ),

                          const SizedBox(height: 16),

                          // نوع الإشعار
                          DropdownButtonFormField<String>(
                            value: _notificationType,
                            decoration: const InputDecoration(
                              labelText: 'نوع الإشعار',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'doctor_message',
                                child: Text('رسالة من الطبيب'),
                              ),
                              DropdownMenuItem(
                                value: 'appointment',
                                child: Text('موعد'),
                              ),
                              DropdownMenuItem(
                                value: 'case_update',
                                child: Text('تحديث حالة'),
                              ),
                              DropdownMenuItem(
                                value: 'general',
                                child: Text('عام'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _notificationType = value!;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // نص الإشعار
                          TextFormField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              labelText: 'نص الإشعار',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.message),
                            ),
                            maxLines: 4,
                            maxLength: 500,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // زر الإرسال
                  ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendNotification,
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send),
                    label:
                        Text(_isSending ? 'جاري الإرسال...' : 'إرسال الإشعار'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // بطاقة الملاحظات
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              const Text(
                                'ملاحظات',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'سيتم إرسال الإشعار فوراً إلى المريض المحدد أو جميع المرضى.',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'يرجى التأكد من صحة المعلومات قبل الإرسال.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
