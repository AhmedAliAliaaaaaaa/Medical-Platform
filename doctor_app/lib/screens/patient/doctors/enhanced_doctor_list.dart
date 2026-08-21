import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:doctor_app/providers/language_provider.dart';
import 'package:doctor_app/core/theme/app_theme.dart';
import 'package:doctor_app/models/doctor.dart';
import 'package:doctor_app/widgets/enhanced_card.dart';
import 'package:doctor_app/widgets/enhanced_inputs.dart';
import 'package:doctor_app/widgets/enhanced_buttons.dart';
import 'package:doctor_app/screens/doctors/doctor_profile_screen.dart';

class EnhancedDoctorList extends StatefulWidget {
  const EnhancedDoctorList({super.key});

  @override
  State<EnhancedDoctorList> createState() => _EnhancedDoctorListState();
}

class _EnhancedDoctorListState extends State<EnhancedDoctorList>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialization = 'all';
  String _selectedCountry = 'all';
  List<Doctor> _filteredDoctors = [];
  List<Doctor> _allDoctors = [];

  final List<String> _specializations = [
    'all',
    'طب الباطنة',
    'طب الأطفال',
    'الجراحة العامة',
    'طب القلب',
    'طب الأعصاب',
    'طب العيون',
    'طب الأسنان',
    'طب النساء والولادة',
    'طب الجلدية',
    'الطب النفسي',
    'طب العظام',
    'طب الأنف والأذن والحنجرة',
  ];

  final List<String> _countries = [
    'all',
    'السعودية',
    'الإمارات',
    'الكويت',
    'قطر',
    'البحرين',
    'عمان',
    'مصر',
    'الأردن',
    'لبنان',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _loadDoctors();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadDoctors() {
    // Mock data - replace with actual API call
    _allDoctors = [
      // Add mock doctors here
    ];
    _filteredDoctors = _allDoctors;
    setState(() {});
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors =
          _allDoctors.where((doctor) {
            final matchesSearch =
                _searchController.text.isEmpty ||
                doctor.user.fullName.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                doctor.specialization.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );

            final matchesSpecialization =
                _selectedSpecialization == 'all' ||
                doctor.specialization == _selectedSpecialization;

            final matchesCountry =
                _selectedCountry == 'all' || doctor.country == _selectedCountry;

            return matchesSearch && matchesSpecialization && matchesCountry;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(isRTL ? 'الأطباء' : 'Doctors'),
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context, isRTL),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Search and Filters
                Container(
                  color: AppTheme.cardBackground,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Search Field
                      SearchField(
                        hint:
                            isRTL
                                ? 'البحث عن طبيب...'
                                : 'Search for a doctor...',
                        controller: _searchController,
                        onChanged: (value) => _filterDoctors(),
                        onClear: () {
                          _searchController.clear();
                          _filterDoctors();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: Text(isRTL ? 'الكل' : 'All'),
                              selected: _selectedSpecialization == 'all',
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSpecialization = 'all';
                                });
                                _filterDoctors();
                              },
                            ),
                            ..._specializations.skip(1).map((spec) {
                              return FilterChip(
                                label: Text(spec),
                                selected: _selectedSpecialization == spec,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedSpecialization = spec;
                                  });
                                  _filterDoctors();
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Doctors List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _loadDoctors();
                    },
                    child:
                        _filteredDoctors.isEmpty
                            ? _buildEmptyState(isRTL)
                            : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _filteredDoctors.length,
                              itemBuilder: (context, index) {
                                final doctor = _filteredDoctors[index];
                                return _buildDoctorCard(doctor, isRTL);
                              },
                            ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor, bool isRTL) {
    return EnhancedCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DoctorProfileScreen(doctor: doctor),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Doctor Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppTheme.primaryGradient,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child:
                      doctor.profilePicture != null
                          ? Image.network(
                            doctor.profilePicture!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: AppTheme.textLight,
                                size: 40,
                              );
                            },
                          )
                          : const Icon(
                            Icons.person,
                            color: AppTheme.textLight,
                            size: 40,
                          ),
                ),
              ),
              const SizedBox(width: 16),

              // Doctor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.user.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialization,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.country,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rating and Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          doctor.isApproved
                              ? AppTheme.primaryGreen.withOpacity(0.1)
                              : AppTheme.warningYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      doctor.isApproved
                          ? (isRTL ? 'معتمد' : 'Verified')
                          : (isRTL ? 'قيد المراجعة' : 'Pending'),
                      style: TextStyle(
                        color:
                            doctor.isApproved
                                ? AppTheme.primaryGreen
                                : AppTheme.warningYellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppTheme.warningYellow,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.8', // Mock rating
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Experience and Fees
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.work_outline,
                  label: isRTL ? 'الخبرة' : 'Experience',
                  value: '${doctor.experienceYears} ${isRTL ? 'سنة' : 'years'}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.attach_money,
                  label: isRTL ? 'رسوم الاستشارة' : 'Consultation Fee',
                  value: '${doctor.consultationFee} ${doctor.currency}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: isRTL ? 'عرض الملف' : 'View Profile',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DoctorProfileScreen(doctor: doctor),
                      ),
                    );
                  },
                  height: 44,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: isRTL ? 'احجز الآن' : 'Book Now',
                  onPressed:
                      doctor.isApproved
                          ? () {
                            // Navigate to booking screen
                          }
                          : null,
                  height: 44,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isRTL) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            isRTL ? 'لم يتم العثور على أطباء' : 'No doctors found',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRTL
                ? 'جرب تغيير معايير البحث'
                : 'Try changing your search criteria',
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, bool isRTL) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL ? 'تصفية النتائج' : 'Filter Results',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Specialization Filter
                  EnhancedDropdown<String>(
                    label: isRTL ? 'التخصص' : 'Specialization',
                    value: _selectedSpecialization,
                    items:
                        _specializations.map((spec) {
                          return DropdownMenuItem(
                            value: spec,
                            child: Text(
                              spec == 'all' ? (isRTL ? 'الكل' : 'All') : spec,
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        _selectedSpecialization = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Country Filter
                  EnhancedDropdown<String>(
                    label: isRTL ? 'الدولة' : 'Country',
                    value: _selectedCountry,
                    items:
                        _countries.map((country) {
                          return DropdownMenuItem(
                            value: country,
                            child: Text(
                              country == 'all'
                                  ? (isRTL ? 'الكل' : 'All')
                                  : country,
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        _selectedCountry = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: isRTL ? 'تطبيق الفلتر' : 'Apply Filter',
                      onPressed: () {
                        Navigator.of(context).pop();
                        _filterDoctors();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
