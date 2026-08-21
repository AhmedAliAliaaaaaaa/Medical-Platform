import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:doctor_app/providers/language_provider.dart';
import 'package:doctor_app/core/theme/app_theme.dart';
import 'package:doctor_app/widgets/enhanced_card.dart';
import 'package:doctor_app/widgets/enhanced_buttons.dart';
import 'package:doctor_app/widgets/enhanced_inputs.dart';
import 'package:doctor_app/models/doctor.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _searchController = TextEditingController();
  String _selectedSpecialization = '';
  String _selectedCountry = '';
  String _selectedLanguage = '';
  RangeValues _feeRange = const RangeValues(0, 1000);
  double _minRating = 0;
  bool _onlineOnly = false;
  bool _acceptsInsurance = false;
  String _sortBy = 'rating';

  List<Doctor> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  final List<String> _specializations = [
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

  final List<String> _languages = [
    'العربية',
    'الإنجليزية',
    'الفرنسية',
    'الألمانية',
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(isRTL ? 'البحث المتقدم' : 'Advanced Search'),
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              isRTL ? 'مسح' : 'Clear',
              style: const TextStyle(color: AppTheme.primaryBlue),
            ),
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
                // Search Filters
                Expanded(
                  flex: _hasSearched ? 1 : 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        _buildSearchBar(isRTL),
                        const SizedBox(height: 24),

                        // Filters
                        _buildFilters(isRTL),
                        const SizedBox(height: 24),

                        // Search Button
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            text: isRTL ? 'بحث' : 'Search',
                            onPressed: _performSearch,
                            isLoading: _isSearching,
                            icon: Icons.search,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Results
                if (_hasSearched)
                  Expanded(flex: 2, child: _buildSearchResults(isRTL)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'البحث العام' : 'General Search',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          EnhancedTextField(
            label:
                isRTL
                    ? 'ابحث عن طبيب أو تخصص'
                    : 'Search for doctor or specialty',
            controller: _searchController,
            prefixIcon: Icons.search,
            hint:
                isRTL
                    ? 'مثال: د. أحمد محمد أو طب القلب'
                    : 'e.g. Dr. Ahmed or Cardiology',
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isRTL) {
    return Column(
      children: [
        // Specialization & Country
        _buildSpecializationCountryFilters(isRTL),
        const SizedBox(height: 16),

        // Language & Rating
        _buildLanguageRatingFilters(isRTL),
        const SizedBox(height: 16),

        // Fee Range
        _buildFeeRangeFilter(isRTL),
        const SizedBox(height: 16),

        // Additional Options
        _buildAdditionalOptions(isRTL),
        const SizedBox(height: 16),

        // Sort Options
        _buildSortOptions(isRTL),
      ],
    );
  }

  Widget _buildSpecializationCountryFilters(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'التخصص والدولة' : 'Specialization & Country',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Specialization Dropdown
          DropdownButtonFormField<String>(
            value:
                _selectedSpecialization.isEmpty
                    ? null
                    : _selectedSpecialization,
            decoration: InputDecoration(
              labelText: isRTL ? 'التخصص' : 'Specialization',
              prefixIcon: const Icon(Icons.medical_services),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(isRTL ? 'جميع التخصصات' : 'All Specializations'),
              ),
              ..._specializations.map((spec) {
                return DropdownMenuItem(value: spec, child: Text(spec));
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSpecialization = value ?? '';
              });
            },
          ),

          const SizedBox(height: 16),

          // Country Dropdown
          DropdownButtonFormField<String>(
            value: _selectedCountry.isEmpty ? null : _selectedCountry,
            decoration: InputDecoration(
              labelText: isRTL ? 'الدولة' : 'Country',
              prefixIcon: const Icon(Icons.flag),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(isRTL ? 'جميع الدول' : 'All Countries'),
              ),
              ..._countries.map((country) {
                return DropdownMenuItem(value: country, child: Text(country));
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCountry = value ?? '';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageRatingFilters(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'اللغة والتقييم' : 'Language & Rating',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Language Dropdown
          DropdownButtonFormField<String>(
            value: _selectedLanguage.isEmpty ? null : _selectedLanguage,
            decoration: InputDecoration(
              labelText: isRTL ? 'اللغة' : 'Language',
              prefixIcon: const Icon(Icons.language),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(isRTL ? 'جميع اللغات' : 'All Languages'),
              ),
              ..._languages.map((lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value ?? '';
              });
            },
          ),

          const SizedBox(height: 16),

          // Rating Filter
          Text(
            '${isRTL ? 'الحد الأدنى للتقييم' : 'Minimum Rating'}: ${_minRating.toStringAsFixed(1)} ⭐',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          Slider(
            value: _minRating,
            min: 0,
            max: 5,
            divisions: 10,
            activeColor: AppTheme.warningYellow,
            onChanged: (value) {
              setState(() {
                _minRating = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRangeFilter(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'نطاق الرسوم' : 'Fee Range',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '${_feeRange.start.round()} - ${_feeRange.end.round()} ${isRTL ? 'ريال' : 'SAR'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
          ),

          RangeSlider(
            values: _feeRange,
            min: 0,
            max: 1000,
            divisions: 20,
            activeColor: AppTheme.primaryGreen,
            labels: RangeLabels(
              _feeRange.start.round().toString(),
              _feeRange.end.round().toString(),
            ),
            onChanged: (values) {
              setState(() {
                _feeRange = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'خيارات إضافية' : 'Additional Options',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Online Only
          SwitchListTile(
            title: Text(
              isRTL
                  ? 'متاح للاستشارة الإلكترونية فقط'
                  : 'Online consultation only',
              style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
            ),
            subtitle: Text(
              isRTL
                  ? 'أطباء متاحون للاستشارة عبر الإنترنت'
                  : 'Doctors available for online consultation',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            value: _onlineOnly,
            activeColor: AppTheme.primaryBlue,
            onChanged: (value) {
              setState(() {
                _onlineOnly = value;
              });
            },
          ),

          // Accepts Insurance
          SwitchListTile(
            title: Text(
              isRTL ? 'يقبل التأمين الطبي' : 'Accepts insurance',
              style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
            ),
            subtitle: Text(
              isRTL
                  ? 'أطباء يقبلون التأمين الطبي'
                  : 'Doctors who accept medical insurance',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            value: _acceptsInsurance,
            activeColor: AppTheme.primaryGreen,
            onChanged: (value) {
              setState(() {
                _acceptsInsurance = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'ترتيب النتائج' : 'Sort Results',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('rating', isRTL ? 'التقييم' : 'Rating', isRTL),
              _buildSortChip(
                'experience',
                isRTL ? 'الخبرة' : 'Experience',
                isRTL,
              ),
              _buildSortChip(
                'fee_low',
                isRTL ? 'الرسوم (الأقل)' : 'Fee (Low)',
                isRTL,
              ),
              _buildSortChip(
                'fee_high',
                isRTL ? 'الرسوم (الأعلى)' : 'Fee (High)',
                isRTL,
              ),
              _buildSortChip(
                'availability',
                isRTL ? 'التوفر' : 'Availability',
                isRTL,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label, bool isRTL) {
    final isSelected = _sortBy == value;
    return EnhancedFilterChip(
      label: label,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
      },
      selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
    );
  }

  Widget _buildSearchResults(bool isRTL) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Results Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_searchResults.length} ${isRTL ? 'نتيجة' : 'results'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Show filter options
                  },
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child:
                _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty
                    ? _buildEmptyResults(isRTL)
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return _buildDoctorCard(_searchResults[index], isRTL);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults(bool isRTL) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            isRTL ? 'لا توجد نتائج' : 'No results found',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRTL
                ? 'جرب تعديل معايير البحث'
                : 'Try adjusting your search criteria',
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor, bool isRTL) {
    return EnhancedCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () {
        // Navigate to doctor profile
      },
      child: Row(
        children: [
          // Doctor Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryBlue,
            child:
                doctor.profilePicture != null
                    ? ClipOval(
                      child: Image.network(
                        doctor.profilePicture!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: AppTheme.white,
                            size: 30,
                          );
                        },
                      ),
                    )
                    : const Icon(Icons.person, color: AppTheme.white, size: 30),
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
                    fontSize: 16,
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppTheme.warningYellow,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${doctor.consultationFee} ${doctor.currency}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Book Button
          PrimaryButton(
            text: isRTL ? 'حجز' : 'Book',
            onPressed: () {
              // Handle booking
            },
            width: 80,
            height: 36,
          ),
        ],
      ),
    );
  }

  void _performSearch() async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock search results
    setState(() {
      _searchResults = [
        // Add mock doctors based on search criteria
      ];
      _isSearching = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedSpecialization = '';
      _selectedCountry = '';
      _selectedLanguage = '';
      _feeRange = const RangeValues(0, 1000);
      _minRating = 0;
      _onlineOnly = false;
      _acceptsInsurance = false;
      _sortBy = 'rating';
      _searchResults.clear();
      _hasSearched = false;
    });
  }
}
