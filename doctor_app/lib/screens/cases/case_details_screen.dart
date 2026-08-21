import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../utils/app_theme.dart';

class CaseDetailsScreen extends StatefulWidget {
  final int caseId;

  const CaseDetailsScreen({super.key, required this.caseId});

  @override
  State<CaseDetailsScreen> createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends State<CaseDetailsScreen> {
  Map<String, dynamic>? _caseDetails;
  bool _isLoading = true;
  String? _errorMessage;

  // للرد على الحالة (للأطباء)
  final _responseController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmittingResponse = false;

  // للتقييم (للمرضى)
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isSubmittingRating = false;

  @override
  void initState() {
    super.initState();
    _loadCaseDetails();
  }

  Future<void> _loadCaseDetails() async {
    try {
      final details = await AdminApiService.getCaseDetails(widget.caseId);
      final caseJson = (details['case'] ?? details) as Map<String, dynamic>;
      setState(() {
        _caseDetails = caseJson;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitResponse() async {
    if (_responseController.text.isEmpty ||
        _recommendationsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingResponse = true;
    });

    try {
      await AdminApiService.respondToCase(
        caseId: widget.caseId,
        content: _responseController.text.trim(),
        recommendations: _recommendationsController.text.trim(),
        diagnosis: _diagnosisController.text.trim(),
        treatmentPlan: _treatmentController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال الرد بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // إعادة تحميل البيانات
      _loadCaseDetails();

      // مسح النموذج
      _responseController.clear();
      _recommendationsController.clear();
      _diagnosisController.clear();
      _treatmentController.clear();
      _notesController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إرسال الرد: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmittingResponse = false;
      });
    }
  }

  Future<void> _submitRating() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى كتابة تعليق'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingRating = true;
    });

    try {
      await AdminApiService.rateDoctor(
        caseId: widget.caseId,
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال التقييم بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // إعادة تحميل البيانات
      _loadCaseDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إرسال التقييم: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmittingRating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الحالة'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorWidget()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الحالة
                    _buildCaseInfoCard(),
                    const SizedBox(height: 16),

                    // معلومات المريض/الطبيب
                    _buildUserInfoCard(),
                    const SizedBox(height: 16),

                    // ردود الأطباء
                    if (_caseDetails!['responses'] != null &&
                        (_caseDetails!['responses'] as List).isNotEmpty)
                      _buildResponsesSection()
                    else if (_caseDetails!['status'] == 'completed')
                      _buildNoResponsesMessage(),

                    // نموذج الرد (للأطباء)
                    if (_isDoctor()) _buildResponseForm(),

                    // نموذج التقييم (للمرضى)
                    if (_isPatient() && _hasResponses()) _buildRatingForm(),
                  ],
                ),
              ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'خطأ في تحميل البيانات',
            style: TextStyle(fontSize: 18, color: Colors.red.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCaseDetails,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(_caseDetails!['status'].toString()),
                  color: _getStatusColor(_caseDetails!['status'].toString()),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(_caseDetails!['status'].toString()),
                  style: TextStyle(
                    color: _getStatusColor(_caseDetails!['status'].toString()),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(_caseDetails!['priority'].toString()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityText(_caseDetails!['priority'].toString()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _caseDetails!['title'] ?? 'حالة طبية',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'تاريخ الإنشاء: ${_formatDate(_caseDetails!['created_at'].toString())}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'وصف الحالة:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_caseDetails!['description'] ?? ''),
            const SizedBox(height: 16),
            const Text(
              'الأعراض:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_caseDetails!['symptoms'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    final user =
        _isDoctor()
            ? _caseDetails!['patient']['user']
            : _caseDetails!['doctor']?['user'];

    if (user == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryBlue,
              child: Text(
                (user['first_name'] ?? user['username'] ?? '?').toString()[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isDoctor() ? 'المريض' : 'الطبيب',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user['first_name']} ${user['last_name']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_isDoctor() && _caseDetails!['doctor'] != null)
                    Text(
                      _caseDetails!['doctor']['specialization'] ?? 'طبيب عام',
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesSection() {
    final responses = _caseDetails!['responses'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ردود الأطباء',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...responses.map((response) => _buildResponseCard(response)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNoResponsesMessage() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ردود الأطباء',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'لا توجد ردود من الأطباء على هذه الحالة بعد',
                      style: TextStyle(color: Colors.orange.shade800),
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

  Widget _buildResponseCard(Map<String, dynamic> response) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'د. ${response['doctor']['user']['first_name']} ${response['doctor']['user']['last_name']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(response['created_at']),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (response['diagnosis'] != null &&
                response['diagnosis'].isNotEmpty) ...[
              const Text(
                'التشخيص:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(response['diagnosis']),
              const SizedBox(height: 12),
            ],

            const Text('الرد:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(response['content']),
            const SizedBox(height: 12),

            const Text(
              'التوصيات:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(response['recommendations']),

            if (response['treatment_plan'] != null &&
                response['treatment_plan'].isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'خطة العلاج:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(response['treatment_plan']),
            ],

            if (response['notes'] != null && response['notes'].isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'ملاحظات:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(response['notes']),
            ],

            // إضافة زر لعرض التقييم إذا كان موجوداً
            if (response['rating'] != null && _isPatient()) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'تقييمك:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < response['rating'] ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponseForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الرد على الحالة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'التشخيص (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _responseController,
              decoration: const InputDecoration(
                labelText: 'الرد *',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _recommendationsController,
              decoration: const InputDecoration(
                labelText: 'التوصيات *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _treatmentController,
              decoration: const InputDecoration(
                labelText: 'خطة العلاج (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات إضافية (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmittingResponse ? null : _submitResponse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                ),
                child:
                    _isSubmittingResponse
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'إرسال الرد',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تقييم الطبيب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),

            const Text('التقييم:'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'التعليق *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmittingRating ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
                child:
                    _isSubmittingRating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'إرسال التقييم',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isDoctor() {
    // يمكن تحديد هذا بناءً على نوع المستخدم المسجل دخوله
    // هنا نفترض أنه يمكن تحديده من البيانات
    return false; // يجب تحديث هذا حسب المنطق الفعلي
  }

  bool _isPatient() {
    return !_isDoctor();
  }

  bool _hasResponses() {
    return _caseDetails!['responses'] != null &&
        (_caseDetails!['responses'] as List).isNotEmpty;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.hourglass_empty;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد المراجعة';
      case 'completed':
        return 'تم الرد';
      case 'cancelled':
        return 'ملغية';
      default:
        return status;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
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
        return priority;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  void dispose() {
    _responseController.dispose();
    _recommendationsController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}
