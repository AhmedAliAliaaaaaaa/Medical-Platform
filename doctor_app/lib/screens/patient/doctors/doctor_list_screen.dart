import 'package:flutter/material.dart';
import 'dart:io';
import 'package:doctor_app/services/api_service.dart';
import 'package:doctor_app/utils/app_theme.dart';
import 'package:doctor_app/widgets/custom_button.dart';
import '../payment/payment_screen.dart';

class DoctorListScreen extends StatefulWidget {
  final Map<String, dynamic>? caseData;

  const DoctorListScreen({super.key, this.caseData});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  List<dynamic> _doctors = [];
  List<dynamic> _filteredDoctors = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedSpecialization = 'all';
  String _selectedCountry = 'all';
  String _sortBy = 'rating'; // rating, price, experience

  final List<Map<String, String>> _countries = [
    {'value': 'all', 'label': 'جميع الدول'},
    {'value': 'sa', 'label': 'المملكة العربية السعودية'},
    {'value': 'eg', 'label': 'مصر'},
    {'value': 'ae', 'label': 'الإمارات العربية المتحدة'},
    {'value': 'jo', 'label': 'الأردن'},
    {'value': 'kw', 'label': 'الكويت'},
    {'value': 'qa', 'label': 'قطر'},
    {'value': 'bh', 'label': 'البحرين'},
    {'value': 'om', 'label': 'عمان'},
    {'value': 'iq', 'label': 'العراق'},
    {'value': 'lb', 'label': 'لبنان'},
    {'value': 'sy', 'label': 'سوريا'},
    {'value': 'tn', 'label': 'تونس'},
    {'value': 'dz', 'label': 'الجزائر'},
    {'value': 'ma', 'label': 'المغرب'},
    {'value': 'ly', 'label': 'ليبيا'},
    {'value': 'sd', 'label': 'السودان'},
    {'value': 'ye', 'label': 'اليمن'},
    {'value': 'other', 'label': 'دول أخرى'},
  ];

  final List<Map<String, String>> _specializations = [
    {'value': 'all', 'label': 'جميع التخصصات'},
    {'value': 'general', 'label': 'طب عام'},
    {'value': 'cardiology', 'label': 'أمراض القلب'},
    {'value': 'dermatology', 'label': 'الأمراض الجلدية'},
    {'value': 'neurology', 'label': 'الأمراض العصبية'},
    {'value': 'orthopedics', 'label': 'العظام'},
    {'value': 'pediatrics', 'label': 'طب الأطفال'},
    {'value': 'psychiatry', 'label': 'الطب النفسي'},
    {'value': 'gynecology', 'label': 'أمراض النساء'},
    {'value': 'urology', 'label': 'المسالك البولية'},
    {'value': 'ophthalmology', 'label': 'طب العيون'},
    {'value': 'ent', 'label': 'الأنف والأذن والحنجرة'},
    {'value': 'dentistry', 'label': 'طب الأسنان'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doctors = await ApiService.getAvailableDoctors();
      setState(() {
        _doctors = doctors;
        _filteredDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        final user = (doctor['user'] as Map<String, dynamic>?) ?? const {};
        final firstName =
            (user['first_name'] ?? user['username'] ?? doctor['name'] ?? '')
                .toString();
        final lastName = (user['last_name'] ?? '').toString();
        final fullName = ('$firstName $lastName').trim();
        final specialization = (doctor['specialization'] ?? '').toString();

        final query = _searchQuery.toLowerCase();
        final matchesSearch = query.isEmpty ||
            fullName.toLowerCase().contains(query) ||
            specialization.toLowerCase().contains(query);

        final matchesSpecialization = _selectedSpecialization == 'all' ||
            specialization == _selectedSpecialization;

        final country = (doctor['country'] ?? '').toString();
        final matchesCountry =
            _selectedCountry == 'all' || country == _selectedCountry;

        return matchesSearch && matchesSpecialization && matchesCountry;
      }).toList();

      // Apply sorting after filtering
      _sortDoctors();
    });
  }

  void _sortDoctors() {
    setState(() {
      switch (_sortBy) {
        case 'rating':
          _filteredDoctors
              .sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
          break;
        case 'price':
          _filteredDoctors
              .sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
          break;
        case 'experience':
          _filteredDoctors.sort((a, b) => (b['experience_years'] ?? 0)
              .compareTo(a['experience_years'] ?? 0));
          break;
      }
    });
  }

  Future<void> _refreshDoctors() async {
    await _loadDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأطباء المتاحون'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDoctors,
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث والفلترة
          _buildSearchAndFilter(),

          // قائمة الأطباء
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : RefreshIndicator(
                        onRefresh: _refreshDoctors,
                        child: _filteredDoctors.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredDoctors.length,
                                itemBuilder: (context, index) {
                                  final doctor = _filteredDoctors[index];
                                  return _buildDoctorCard(doctor);
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // شريط البحث
          TextField(
            decoration: InputDecoration(
              hintText: 'البحث عن طبيب...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterDoctors();
            },
          ),
          const SizedBox(height: 12),

          // فلتر التخصص
          DropdownButtonFormField<String>(
            value: _selectedSpecialization,
            decoration: InputDecoration(
              labelText: 'التخصص',
              prefixIcon: const Icon(Icons.medical_services),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: _specializations.map((spec) {
              return DropdownMenuItem<String>(
                value: spec['value'],
                child: Text(spec['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSpecialization = value!;
              });
              _filterDoctors();
            },
          ),
          const SizedBox(height: 12),

          // فلتر الدولة
          DropdownButtonFormField<String>(
            value: _selectedCountry,
            decoration: InputDecoration(
              labelText: 'الدولة',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: _countries.map((country) {
              return DropdownMenuItem<String>(
                value: country['value'],
                child: Text(country['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCountry = value!;
              });
              _filterDoctors();
            },
          ),
          const SizedBox(height: 12),

          // خيارات الترتيب
          Row(
            children: [
              Expanded(
                child: Text(
                  'الترتيب حسب:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'rating',
                      child: Text('التقييم'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'price',
                      child: Text('السعر'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'experience',
                      child: Text('الخبرة'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    _sortDoctors();
                  },
                ),
              ),
            ],
          ),
        ],
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
            'خطأ في تحميل قائمة الأطباء',
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
            onPressed: _refreshDoctors,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تغيير معايير البحث',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final user = (doctor['user'] as Map<String, dynamic>?) ?? const {};
    final String firstName =
        (user['first_name'] ?? user['username'] ?? doctor['name'] ?? 'طبيب')
            .toString();
    final String lastName = (user['last_name'] ?? '').toString();
    final displayName = ('د. $firstName $lastName').trim();

    final double rating =
        (doctor['rating'] is num) ? (doctor['rating'] as num).toDouble() : 0.0;
    final int totalReviews = (doctor['total_reviews'] is num)
        ? (doctor['total_reviews'] as num).toInt()
        : 0;
    final bool isAvailable = (doctor['is_available'] == true);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // صورة الطبيب
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryBlue,
                  child: Text(
                    firstName.isNotEmpty ? firstName[0] : 'ط',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // معلومات الطبيب
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSpecializationText(doctor['specialization']),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // التقييم
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : index < rating
                                      ? Icons.star_half
                                      : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${rating.toStringAsFixed(1)} ($totalReviews)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // حالة التوفر
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAvailable ? 'متاح' : 'غير متاح',
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

            // معلومات إضافية
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.work,
                    'الخبرة',
                    '${doctor['experience_years']} سنة',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.location_on,
                    'البلد',
                    doctor['country'] ?? 'غير محدد',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.language,
                    'اللغة',
                    doctor['preferred_language'] == 'ar'
                        ? 'العربية'
                        : 'الإنجليزية',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // الأزرار
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDoctorProfile(doctor),
                    icon: const Icon(Icons.person),
                    label: const Text('الملف الشخصي'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        isAvailable ? () => _consultDoctor(doctor) : null,
                    icon: const Icon(Icons.chat),
                    label: const Text('استشارة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showDoctorProfile(Map<String, dynamic> doctor) {
    // Safely derive user/display info from the doctor map
    final user = (doctor['user'] as Map<String, dynamic>?) ?? const {};
    final String firstName =
        (user['first_name'] ?? user['username'] ?? doctor['name'] ?? 'طبيب')
            .toString();
    final String lastName = (user['last_name'] ?? '').toString();
    final String displayName = ('د. $firstName $lastName').trim();
    final String bio = (doctor['bio'] ?? '').toString();
    final double rating =
        (doctor['rating'] is num) ? (doctor['rating'] as num).toDouble() : 0.0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  firstName.isNotEmpty ? firstName[0] : 'ط',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getSpecializationText(doctor['specialization']),
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (bio.isNotEmpty) ...[
                const Text(
                  'نبذة:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(bio, textAlign: TextAlign.center),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        '${doctor['experience_years']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const Text('سنة خبرة'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${doctor['rating']?.toStringAsFixed(1) ?? '0.0'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const Text('التقييم'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${doctor['total_reviews'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const Text('مراجعة'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _consultDoctor(doctor);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('استشارة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _consultDoctor(Map<String, dynamic> doctor) async {
    if (widget.caseData == null) {
      // إذا لم تكن هناك بيانات حالة، ارجع فقط معرف الطبيب
      Navigator.pop(context, doctor['id']);
      return;
    }

    // عرض تأكيد الحجز
    final confirmed = await _showBookingConfirmation(doctor);
    if (!confirmed) return;

    // الانتقال إلى صفحة الدفع مع بيانات الحالة والطبيب
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          doctorId: doctor['id'],
          amount: (doctor['consultation_fee'] is num)
              ? (doctor['consultation_fee'] as num).toDouble()
              : 50.0,
          title: widget.caseData!['title'],
          description: widget.caseData!['description'],
          symptoms: '', // يمكن إضافة الأعراض إذا كانت متوفرة
          priority: widget.caseData!['priority'],
          attachments: widget.caseData!['attachments'] ?? [],
        ),
      ),
    );

    // إذا تم الدفع بنجاح، العودة مع نتيجة إيجابية
    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  Future<bool> _showBookingConfirmation(Map<String, dynamic> doctor) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الحجز'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('هل تريد حجز استشارة مع:'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'] ?? 'طبيب',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'التخصص: ${_getSpecializationText(doctor['specialization'] ?? 'general')}',
                      ),
                      if (doctor['country'] != null)
                        Text('الدولة: ${doctor['country']}'),
                      Text(
                        'التقييم: ${(doctor['rating'] ?? 0.0).toString()} ⭐',
                      ),
                      Text(
                        'رسوم الاستشارة: \$${(doctor['consultation_fee'] ?? 50.0).toString()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '• سيتم إرسال حالتك للطبيب\n• ستحصل على الرد خلال 48 ساعة\n• يمكنك متابعة الحالة من لوحة التحكم',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('تأكيد الحجز'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _getSpecializationText(String specialization) {
    final spec = _specializations.firstWhere(
      (s) => s['value'] == specialization,
      orElse: () => {'value': specialization, 'label': specialization},
    );
    return spec['label']!;
  }
}
