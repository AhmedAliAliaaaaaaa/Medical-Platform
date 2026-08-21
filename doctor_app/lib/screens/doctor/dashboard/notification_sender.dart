// import 'package:flutter/material.dart';
// import '../../../services/api_service.dart';
// import '../../../services/base_api_service.dart';

// class NotificationSender extends StatefulWidget {
//   const NotificationSender({Key? key}) : super(key: key);

//   @override
//   State<NotificationSender> createState() => _NotificationSenderState();
// }

// class _NotificationSenderState extends State<NotificationSender> {
//   final _titleController = TextEditingController();
//   final _messageController = TextEditingController();

//   List<Map<String, dynamic>> _patients = [];
//   String? _selectedPatientId;
//   String _notificationType = 'general';
//   bool _isLoading = false;
//   bool _isSending = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadPatients();
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadPatients() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       print('🔍 Starting comprehensive patient loading...');

//       List<Map<String, dynamic>> patients = [];
//       final Set<String> addedPatients = {};

//       // إزالة المرضى التجريبيين - نريد البيانات الحقيقية فقط
//       // _addTestPatients(patients, addedPatients); // تم تعطيلها

//       // الطريقة الأولى: جلب بيانات لوحة التحكم
//       await _loadPatientsFromDashboard(patients, addedPatients);

//       // الطريقة الثانية: جلب المرضى مباشرة
//       await _loadPatientsDirectly(patients, addedPatients);

//       // الطريقة الثالثة: جلب من جميع الحالات الطبية
//       await _loadPatientsFromCases(patients, addedPatients);

//       // الطريقة الرابعة: جلب من جميع المستخدمين (المرضى فقط)
//       await _loadAllPatientUsers(patients, addedPatients);

//       // ترتيب المرضى حسب الاسم
//       patients.sort((a, b) => a['name'].compareTo(b['name']));

//       setState(() {
//         _patients = patients;
//         _isLoading = false;
//       });

//       print('✅ Total patients loaded: ${patients.length}');
//       if (patients.isEmpty) {
//         print('⚠️ No patients found! This might indicate:');
//         print('   1. No patients have sent cases to this doctor');
//         print('   2. API endpoints are not working correctly');
//         print('   3. Database has no patient data');
//       } else {
//         for (final patient in patients) {
//           print('   - ${patient['name']} (ID: ${patient['id']})');
//         }
//       }
//     } catch (e) {
//       print('❌ Critical error loading patients: $e');
//       setState(() {
//         _patients = [];
//         _isLoading = false;
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('فشل تحميل قائمة المرضى: ${e.toString()}'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 5),
//           ),
//         );
//       }
//     }
//   }

//   void _addTestPatients(
//       List<Map<String, dynamic>> patients, Set<String> addedPatients) {
//     // إضافة مرضى تجريبيين للتأكد من عمل الواجهة
//     final testPatients = [
//       {'id': '999', 'name': 'مريض تجريبي 1'},
//       {'id': '998', 'name': 'مريض تجريبي 2'},
//       {'id': '997', 'name': 'مريض تجريبي 3'},
//     ];

//     for (final patient in testPatients) {
//       if (!addedPatients.contains(patient['id'])) {
//         patients.add(patient);
//         addedPatients.add(patient['id']!);
//         print(
//             '🧪 Added test patient: ${patient['name']} (ID: ${patient['id']})');
//       }
//     }
//   }

//   Future<void> _loadPatientsFromDashboard(
//       List<Map<String, dynamic>> patients, Set<String> addedPatients) async {
//     try {
//       print('📊 Method 1: Loading from dashboard...');
//       final dashboardData = await ApiService.getDoctorDashboard();
//       print('📊 Dashboard keys: ${dashboardData.keys.toList()}');

//       final allCasesKeys = [
//         'new_cases_list',
//         'new_cases',
//         'pending_cases',
//         'cases',
//         'answered_cases_list',
//         'my_responses',
//         'recent_cases'
//       ];

//       int foundFromDashboard = 0;
//       for (final key in allCasesKeys) {
//         final casesList = dashboardData[key];
//         if (casesList is List && casesList.isNotEmpty) {
//           print('📊 Processing $key: ${casesList.length} items');
//           for (final caseItem in casesList) {
//             if (caseItem is Map<String, dynamic>) {
//               if (_extractPatientFromCase(caseItem, patients, addedPatients)) {
//                 foundFromDashboard++;
//               }
//             }
//           }
//         }
//       }
//       print('✅ Found $foundFromDashboard patients from dashboard');
//     } catch (e) {
//       print('⚠️ Dashboard method failed: $e');
//     }
//   }

//   Future<void> _loadPatientsDirectly(
//       List<Map<String, dynamic>> patients, Set<String> addedPatients) async {
//     try {
//       print('👥 Method 2: Loading patients directly...');
//       final patientsData = await ApiService.getPatients();
//       print('👥 Direct API returned: ${patientsData.length} items');

//       int foundDirectly = 0;
//       for (final patient in patientsData) {
//         if (patient is Map<String, dynamic>) {
//           final patientId = patient['id']?.toString();
//           final firstName = patient['first_name']?.toString() ?? '';
//           final lastName = patient['last_name']?.toString() ?? '';
//           final username = patient['username']?.toString() ?? '';
//           final email = patient['email']?.toString() ?? '';

//           String patientName = '$firstName $lastName'.trim();
//           if (patientName.isEmpty) {
//             patientName = username.isNotEmpty ? username : email;
//           }

//           if (patientId != null &&
//               patientName.isNotEmpty &&
//               !addedPatients.contains(patientId)) {
//             patients.add({
//               'id': patientId,
//               'name': patientName,
//             });
//             addedPatients.add(patientId);
//             foundDirectly++;
//             print('✅ Direct: $patientName (ID: $patientId)');
//           }
//         }
//       }
//       print('✅ Found $foundDirectly patients directly');
//     } catch (e) {
//       print('⚠️ Direct method failed: $e');
//     }
//   }

//   Future<void> _loadPatientsFromCases(
//       List<Map<String, dynamic>> patients, Set<String> addedPatients) async {
//     try {
//       print('📋 Method 3: Loading from all cases...');
//       final allCasesData = await ApiService.getAllPatientCases();
//       final allCases = allCasesData['cases'] ?? [];
//       print('📋 All cases returned: ${allCases.length} items');

//       int foundFromCases = 0;
//       if (allCases is List) {
//         for (final caseItem in allCases) {
//           if (caseItem is Map<String, dynamic>) {
//             if (_extractPatientFromCase(caseItem, patients, addedPatients)) {
//               foundFromCases++;
//             }
//           }
//         }
//       }
//       print('✅ Found $foundFromCases patients from cases');
//     } catch (e) {
//       print('⚠️ Cases method failed: $e');
//     }
//   }

//   Future<void> _loadAllPatientUsers(
//       List<Map<String, dynamic>> patients, Set<String> addedPatients) async {
//     try {
//       print('🌐 Method 4: Loading all patient users...');

//       // محاولة جلب جميع المستخدمين من نوع patient
//       // يمكن استخدام endpoint مختلف حسب API الخادم

//       // الطريقة الأولى: محاولة جلب من endpoint المستخدمين
//       try {
//         final response = await BaseApiService.get('/users/',
//             queryParams: {'user_type': 'patient'});
//         final data = BaseApiService.handleResponse(response);

//         if (data is Map<String, dynamic> && data['results'] is List) {
//           final users = data['results'] as List;
//           print('🌐 Found ${users.length} patient users from API');

//           int foundFromUsers = 0;
//           for (final user in users) {
//             if (user is Map<String, dynamic>) {
//               final userId = user['id']?.toString();
//               final firstName = user['first_name']?.toString() ?? '';
//               final lastName = user['last_name']?.toString() ?? '';
//               final username = user['username']?.toString() ?? '';
//               final email = user['email']?.toString() ?? '';

//               String userName = '$firstName $lastName'.trim();
//               if (userName.isEmpty) {
//                 userName = username.isNotEmpty ? username : email;
//               }

//               if (userId != null &&
//                   userName.isNotEmpty &&
//                   !addedPatients.contains(userId)) {
//                 patients.add({
//                   'id': userId,
//                   'name': userName,
//                 });
//                 addedPatients.add(userId);
//                 foundFromUsers++;
//                 print('✅ User: $userName (ID: $userId)');
//               }
//             }
//           }
//           print('✅ Found $foundFromUsers patients from users API');
//         }
//       } catch (e) {
//         print('⚠️ Users API method failed: $e');
//       }

//       // الطريقة الثانية: محاولة جلب من endpoint مخصص للمرضى
//       try {
//         final response = await BaseApiService.get('/patients/');
//         final data = BaseApiService.handleResponse(response);

//         if (data is List) {
//           print('🌐 Found ${data.length} patients from patients API');

//           int foundFromPatientsAPI = 0;
//           for (final patient in data) {
//             if (patient is Map<String, dynamic>) {
//               final patientId =
//                   patient['id']?.toString() ?? patient['user_id']?.toString();
//               final firstName = patient['first_name']?.toString() ?? '';
//               final lastName = patient['last_name']?.toString() ?? '';
//               final username = patient['username']?.toString() ?? '';
//               final email = patient['email']?.toString() ?? '';

//               String patientName = '$firstName $lastName'.trim();
//               if (patientName.isEmpty) {
//                 patientName = username.isNotEmpty ? username : email;
//               }

//               if (patientId != null &&
//                   patientName.isNotEmpty &&
//                   !addedPatients.contains(patientId)) {
//                 patients.add({
//                   'id': patientId,
//                   'name': patientName,
//                 });
//                 addedPatients.add(patientId);
//                 foundFromPatientsAPI++;
//                 print('✅ Patient API: $patientName (ID: $patientId)');
//               }
//             }
//           }
//           print('✅ Found $foundFromPatientsAPI patients from patients API');
//         }
//       } catch (e) {
//         print('⚠️ Patients API method failed: $e');
//       }
//     } catch (e) {
//       print('⚠️ All users method failed: $e');
//     }
//   }

//   bool _extractPatientFromCase(
//     Map<String, dynamic> caseItem,
//     List<Map<String, dynamic>> patients,
//     Set<String> addedPatients,
//   ) {
//     print('🔍 Analyzing case item: ${caseItem.keys.toList()}');

//     // محاولة استخراج معرف المريض من جميع الحقول الممكنة
//     String? patientId = caseItem['patient_id']?.toString() ??
//         caseItem['patient']?['id']?.toString() ??
//         caseItem['user_id']?.toString() ??
//         caseItem['created_by']?.toString() ??
//         caseItem['submitted_by']?.toString();

//     // محاولة استخراج اسم المريض
//     String? patientName;

//     // الطريقة الأولى: من حقل patient_name مباشرة
//     patientName = caseItem['patient_name']?.toString();

//     // الطريقة الثانية: من كائن patient
//     if (patientName == null || patientName.isEmpty) {
//       final patient = caseItem['patient'];
//       if (patient is Map<String, dynamic>) {
//         final firstName = patient['first_name']?.toString() ?? '';
//         final lastName = patient['last_name']?.toString() ?? '';
//         final username = patient['username']?.toString() ?? '';
//         final email = patient['email']?.toString() ?? '';

//         patientName = '$firstName $lastName'.trim();
//         if (patientName.isEmpty) {
//           patientName = username.isNotEmpty ? username : email;
//         }
//       }
//     }

//     // الطريقة الثالثة: من الحقول المباشرة في الحالة
//     if (patientName == null || patientName.isEmpty) {
//       final firstName = caseItem['first_name']?.toString() ??
//           caseItem['patient_first_name']?.toString() ??
//           '';
//       final lastName = caseItem['last_name']?.toString() ??
//           caseItem['patient_last_name']?.toString() ??
//           '';
//       final username = caseItem['username']?.toString() ??
//           caseItem['patient_username']?.toString() ??
//           '';
//       final email = caseItem['email']?.toString() ??
//           caseItem['patient_email']?.toString() ??
//           '';

//       patientName = '$firstName $lastName'.trim();
//       if (patientName.isEmpty) {
//         patientName = username.isNotEmpty ? username : email;
//       }
//     }

//     // الطريقة الرابعة: من كائن user إذا كان موجوداً
//     if (patientName == null || patientName.isEmpty) {
//       final user = caseItem['user'];
//       if (user is Map<String, dynamic>) {
//         final firstName = user['first_name']?.toString() ?? '';
//         final lastName = user['last_name']?.toString() ?? '';
//         final username = user['username']?.toString() ?? '';
//         final email = user['email']?.toString() ?? '';

//         patientName = '$firstName $lastName'.trim();
//         if (patientName.isEmpty) {
//           patientName = username.isNotEmpty ? username : email;
//         }
//       }
//     }

//     // طباعة تفاصيل التحليل
//     print('🔍 Patient ID found: $patientId');
//     print('🔍 Patient name found: $patientName');

//     // إضافة المريض إذا كانت البيانات صحيحة
//     if (patientId != null &&
//         patientName != null &&
//         patientName.isNotEmpty &&
//         patientName != 'null' &&
//         !addedPatients.contains(patientId)) {
//       patients.add({
//         'id': patientId,
//         'name': patientName,
//       });
//       addedPatients.add(patientId);
//       print('✅ Extracted patient from case: $patientName (ID: $patientId)');
//       return true;
//     } else {
//       print('❌ Could not extract valid patient data from case');
//       return false;
//     }
//   }

//   Future<void> _sendNotification() async {
//     if (_selectedPatientId == null ||
//         _messageController.text.trim().isEmpty ||
//         _titleController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('يرجى اختيار مريض وكتابة العنوان والرسالة'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isSending = true;
//     });

//     try {
//       final patientName =
//           _patients.firstWhere((p) => p['id'] == _selectedPatientId)['name'];

//       final patientId = int.tryParse(_selectedPatientId!);
//       if (patientId == null) {
//         throw Exception('معرف المريض غير صحيح');
//       }

//       await ApiService.sendNotification(
//         title: _titleController.text.trim(),
//         message: _messageController.text.trim(),
//         notificationType: _notificationType,
//         recipientType: 'patient',
//         recipientId: patientId,
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('تم إرسال الإشعار إلى $patientName بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         // مسح الحقول بعد الإرسال الناجح
//         _messageController.clear();
//         _titleController.clear();
//         setState(() {
//           _selectedPatientId = null;
//           _notificationType = 'general';
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('فشل إرسال الإشعار: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSending = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('إرسال إشعار للمرضى'),
//         backgroundColor: Colors.blue[600],
//         foregroundColor: Colors.white,
//       ),
//       body: _isLoading
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('جاري تحميل قائمة المرضى...'),
//                 ],
//               ),
//             )
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // بطاقة اختيار المريض
//                   Card(
//                     elevation: 4,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.person, color: Colors.blue[600]),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 'اختيار المريض',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           if (_patients.isEmpty)
//                             Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange[50],
//                                 border: Border.all(color: Colors.orange),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Column(
//                                 children: [
//                                   Icon(Icons.info, color: Colors.orange[700]),
//                                   const SizedBox(height: 8),
//                                   const Text(
//                                     'لا توجد مرضى متاحين',
//                                     style:
//                                         TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   const Text(
//                                     'لإرسال الإشعارات، يجب أن يكون لديك مرضى قاموا بإرسال حالات طبية إليك.',
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   const SizedBox(height: 12),
//                                   ElevatedButton.icon(
//                                     onPressed: _loadPatients,
//                                     icon: const Icon(Icons.refresh),
//                                     label: const Text('إعادة المحاولة'),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.orange,
//                                       foregroundColor: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           else
//                             DropdownButtonFormField<String>(
//                               value: _selectedPatientId,
//                               decoration: const InputDecoration(
//                                 labelText: 'اختر المريض',
//                                 border: OutlineInputBorder(),
//                                 prefixIcon: Icon(Icons.person_search),
//                               ),
//                               items: _patients.map((patient) {
//                                 return DropdownMenuItem<String>(
//                                   value: patient['id'],
//                                   child: Text(patient['name']),
//                                 );
//                               }).toList(),
//                               onChanged: (value) {
//                                 setState(() {
//                                   _selectedPatientId = value;
//                                 });
//                               },
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // بطاقة تفاصيل الإشعار
//                   Card(
//                     elevation: 4,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.notifications,
//                                   color: Colors.blue[600]),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 'تفاصيل الإشعار',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),

//                           // عنوان الإشعار
//                           TextFormField(
//                             controller: _titleController,
//                             decoration: const InputDecoration(
//                               labelText: 'عنوان الإشعار',
//                               border: OutlineInputBorder(),
//                               prefixIcon: Icon(Icons.title),
//                             ),
//                             maxLength: 100,
//                           ),

//                           const SizedBox(height: 16),

//                           // نوع الإشعار
//                           DropdownButtonFormField<String>(
//                             value: _notificationType,
//                             decoration: const InputDecoration(
//                               labelText: 'نوع الإشعار',
//                               border: OutlineInputBorder(),
//                               prefixIcon: Icon(Icons.category),
//                             ),
//                             items: const [
//                               DropdownMenuItem(
//                                 value: 'general',
//                                 child: Text('عام'),
//                               ),
//                               DropdownMenuItem(
//                                 value: 'doctor_message',
//                                 child: Text('رسالة طبيب'),
//                               ),
//                               DropdownMenuItem(
//                                 value: 'appointment',
//                                 child: Text('موعد'),
//                               ),
//                             ],
//                             onChanged: (value) {
//                               setState(() {
//                                 _notificationType = value!;
//                               });
//                             },
//                           ),

//                           const SizedBox(height: 16),

//                           // نص الإشعار
//                           TextFormField(
//                             controller: _messageController,
//                             decoration: const InputDecoration(
//                               labelText: 'نص الإشعار',
//                               border: OutlineInputBorder(),
//                               prefixIcon: Icon(Icons.message),
//                             ),
//                             maxLines: 4,
//                             maxLength: 500,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // زر الإرسال
//                   ElevatedButton.icon(
//                     onPressed: _isSending ? null : _sendNotification,
//                     icon: _isSending
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : const Icon(Icons.send),
//                     label:
//                         Text(_isSending ? 'جاري الإرسال...' : 'إرسال الإشعار'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue[600],
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       textStyle: const TextStyle(fontSize: 16),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // بطاقة الملاحظات
//                   Card(
//                     color: Colors.blue[50],
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.info, color: Colors.blue[600]),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 'ملاحظات مهمة:',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           const Text(
//                               '• يمكنك إرسال إشعارات للمرضى الذين أرسلوا حالات طبية إليك'),
//                           const Text(
//                               '• اختر نوع الإشعار المناسب لتصنيف الرسالة'),
//                           const Text(
//                               '• تأكد من كتابة رسالة واضحة ومفيدة للمريض'),
//                           const Text(
//                               '• سيتم إرسال الإشعار فوراً للمريض المختار'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
