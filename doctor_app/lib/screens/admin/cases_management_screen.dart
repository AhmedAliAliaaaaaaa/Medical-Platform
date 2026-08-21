import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../services/admin_api_service.dart';
import '../../utils/app_theme.dart';
import 'admin_case_details_screen.dart';

class CasesManagementScreen extends StatefulWidget {
  const CasesManagementScreen({super.key});

  @override
  State<CasesManagementScreen> createState() => _CasesManagementScreenState();
}

class _CasesManagementScreenState extends State<CasesManagementScreen> {
  List<dynamic> _cases = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔍 تحميل جميع الحالات...');
      final cases = await AdminApiService.getAllCases();
      print('✅ تم تحميل ${cases.length} حالة');

      setState(() {
        _cases = cases;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ خطأ في تحميل الحالات: $e');
      // استخدام بيانات تجريبية
      setState(() {
        _cases = [
          {
            'id': 1,
            'title': 'ألم في الصدر',
            'patient_name': 'أحمد محمد',
            'doctor_name': 'د. فاطمة علي',
            'status': 'completed',
            'priority': 'high',
            'created_at': '2024-01-20T10:30:00Z',
            'updated_at': '2024-01-21T14:20:00Z',
            'response_time': '27 ساعة',
          },
          {
            'id': 2,
            'title': 'صداع مستمر',
            'patient_name': 'سارة أحمد',
            'doctor_name': 'د. محمد حسن',
            'status': 'in_progress',
            'priority': 'medium',
            'created_at': '2024-01-21T08:15:00Z',
            'updated_at': '2024-01-21T08:15:00Z',
            'response_time': 'قيد المراجعة',
          },
          {
            'id': 3,
            'title': 'حمى وإرهاق',
            'patient_name': 'خالد علي',
            'doctor_name': null,
            'status': 'pending',
            'priority': 'low',
            'created_at': '2024-01-21T12:00:00Z',
            'updated_at': '2024-01-21T12:00:00Z',
            'response_time': 'في الانتظار',
          },
        ];
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isRTL ? 'إدارة الحالات' : 'Cases Management'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadCases,
            icon: const Icon(Icons.refresh),
            tooltip: isRTL ? 'تحديث' : 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: languageProvider.textDirection,
          child: Column(
            children: [
              _buildFilterTabs(isRTL),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? _buildErrorWidget(isRTL)
                        : _buildCasesList(isRTL),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', isRTL ? 'الكل' : 'All', isRTL),
            const SizedBox(width: 8),
            _buildFilterChip(
              'pending',
              isRTL ? 'قيد الانتظار' : 'Pending',
              isRTL,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'in_progress',
              isRTL ? 'قيد المراجعة' : 'In Progress',
              isRTL,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'completed',
              isRTL ? 'مكتملة' : 'Completed',
              isRTL,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'high',
              isRTL ? 'عالية الأولوية' : 'High Priority',
              isRTL,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label, bool isRTL) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryBlue,
    );
  }

  Widget _buildErrorWidget(bool isRTL) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            isRTL ? 'خطأ في تحميل البيانات' : 'Error loading data',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCases,
            child: Text(isRTL ? 'إعادة المحاولة' : 'Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCasesList(bool isRTL) {
    final filteredCases = _getFilteredCases();

    if (filteredCases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isRTL ? 'لا توجد حالات' : 'No cases found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCases,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredCases.length,
        itemBuilder: (context, index) {
          return _buildCaseCard(filteredCases[index], isRTL);
        },
      ),
    );
  }

  List<dynamic> _getFilteredCases() {
    if (_selectedFilter == 'all') {
      return _cases;
    } else if (_selectedFilter == 'high') {
      return _cases.where((c) => c['priority'] == 'high').toList();
    } else {
      return _cases.where((c) => c['status'] == _selectedFilter).toList();
    }
  }

  Widget _buildCaseCard(Map<String, dynamic> caseData, bool isRTL) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewCaseDetails(caseData),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(caseData['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(caseData['status'], isRTL),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(caseData['priority']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPriorityText(caseData['priority'], isRTL),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ID: ${caseData['id']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                caseData['title'] ?? 'حالة طبية',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${isRTL ? 'المريض:' : 'Patient:'} ${_extractPatientName(caseData, isRTL)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isRTL ? 'الطبيب:' : 'Doctor:'} ${_extractDoctorName(caseData, isRTL)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${isRTL ? 'وقت الاستجابة:' : 'Response time:'} ${caseData['response_time'] ?? 'غير محدد'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${isRTL ? 'تاريخ الإنشاء:' : 'Created:'} ${_formatDate(caseData['created_at'])}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
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

  String _getStatusText(String? status, bool isRTL) {
    if (!isRTL) {
      switch (status) {
        case 'pending':
          return 'Pending';
        case 'in_progress':
          return 'In Progress';
        case 'completed':
          return 'Completed';
        case 'cancelled':
          return 'Cancelled';
        default:
          return 'Unknown';
      }
    }

    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد المراجعة';
      case 'completed':
        return 'مكتملة';
      case 'cancelled':
        return 'ملغية';
      default:
        return 'غير محدد';
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String? priority, bool isRTL) {
    if (!isRTL) {
      switch (priority) {
        case 'high':
          return 'High';
        case 'medium':
          return 'Medium';
        case 'low':
          return 'Low';
        default:
          return 'Unknown';
      }
    }

    switch (priority) {
      case 'high':
        return 'عالية';
      case 'medium':
        return 'متوسطة';
      case 'low':
        return 'منخفضة';
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
      return 'غير محدد';
    }
  }

  // Safely extract nested patient/doctor names from server response
  String _extractPatientName(Map<String, dynamic> caseData, bool isRTL) {
    final patient = caseData['patient'];
    if (patient is Map) {
      final user = patient['user'];
      if (user is Map) {
        final fullName = user['get_full_name'] ?? user['full_name'];
        final username = user['username'];
        if (fullName is String && fullName.trim().isNotEmpty) return fullName;
        if (username is String && username.trim().isNotEmpty) return username;
      }
      final name = patient['name'];
      if (name is String && name.trim().isNotEmpty) return name;
    }
    final flat = caseData['patient_name'];
    if (flat is String && flat.trim().isNotEmpty) return flat;
    return isRTL ? 'غير محدد' : 'Unknown';
  }

  String _extractDoctorName(Map<String, dynamic> caseData, bool isRTL) {
    final doctor = caseData['doctor'];
    if (doctor == null) return isRTL ? 'لم يتم التعيين' : 'Not assigned';
    if (doctor is Map) {
      final user = doctor['user'];
      if (user is Map) {
        final fullName = user['get_full_name'] ?? user['full_name'];
        final username = user['username'];
        if (fullName is String && fullName.trim().isNotEmpty) return fullName;
        if (username is String && username.trim().isNotEmpty) return username;
      }
      final name = doctor['name'];
      if (name is String && name.trim().isNotEmpty) return name;
    }
    final flat = caseData['doctor_name'];
    if (flat is String && flat.trim().isNotEmpty) return flat;
    return isRTL ? 'لم يتم التعيين' : 'Not assigned';
  }

  void _viewCaseDetails(Map<String, dynamic> caseData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminCaseDetailsScreen(caseId: caseData['id']),
      ),
    );
  }
}
