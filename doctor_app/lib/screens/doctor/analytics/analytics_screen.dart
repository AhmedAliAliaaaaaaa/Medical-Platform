import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../providers/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/enhanced_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedPeriod = 'month';
  bool _isLoading = false;

  // Mock data
  final Map<String, dynamic> _analyticsData = {
    'totalCases': 156,
    'activeCases': 23,
    'completedCases': 133,
    'totalDoctors': 45,
    'activeDoctors': 38,
    'totalPatients': 892,
    'newPatients': 67,
    'totalRevenue': 45600.0,
    'monthlyGrowth': 12.5,
    'averageRating': 4.7,
    'responseTime': 2.3,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _loadAnalytics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadAnalytics() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        title: Text(isRTL ? 'الإحصائيات والتقارير' : 'Analytics & Reports'),
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadAnalytics();
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'week',
                    child: Text(isRTL ? 'هذا الأسبوع' : 'This Week'),
                  ),
                  PopupMenuItem(
                    value: 'month',
                    child: Text(isRTL ? 'هذا الشهر' : 'This Month'),
                  ),
                  PopupMenuItem(
                    value: 'quarter',
                    child: Text(isRTL ? 'هذا الربع' : 'This Quarter'),
                  ),
                  PopupMenuItem(
                    value: 'year',
                    child: Text(isRTL ? 'هذا العام' : 'This Year'),
                  ),
                ],
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () async {
                _loadAnalytics();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Selector
                    _buildPeriodSelector(isRTL),
                    const SizedBox(height: 24),

                    // Key Metrics
                    _buildKeyMetrics(isRTL),
                    const SizedBox(height: 24),

                    // Cases Analytics
                    _buildCasesAnalytics(isRTL),
                    const SizedBox(height: 24),

                    // Doctors Analytics
                    _buildDoctorsAnalytics(isRTL),
                    const SizedBox(height: 24),

                    // Patients Analytics
                    _buildPatientsAnalytics(isRTL),
                    const SizedBox(height: 24),

                    // Revenue Analytics
                    _buildRevenueAnalytics(isRTL),
                    const SizedBox(height: 24),

                    // Performance Metrics
                    _buildPerformanceMetrics(isRTL),
                    const SizedBox(height: 24),

                    // Charts Section
                    _buildChartsSection(isRTL),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'الفترة الزمنية' : 'Time Period',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildPeriodChip(
                  'week',
                  isRTL ? 'أسبوع' : 'Week',
                  isRTL,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPeriodChip(
                  'month',
                  isRTL ? 'شهر' : 'Month',
                  isRTL,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPeriodChip(
                  'quarter',
                  isRTL ? 'ربع' : 'Quarter',
                  isRTL,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPeriodChip('year', isRTL ? 'سنة' : 'Year', isRTL),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String value, String label, bool isRTL) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
        _loadAnalytics();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.lightGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRTL ? 'المؤشرات الرئيسية' : 'Key Metrics',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: isRTL ? 'إجمالي الحالات' : 'Total Cases',
                value: _analyticsData['totalCases'].toString(),
                icon: Icons.medical_services,
                color: AppTheme.primaryBlue,
                trend: '+${_analyticsData['monthlyGrowth']}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: isRTL ? 'إجمالي الأطباء' : 'Total Doctors',
                value: _analyticsData['totalDoctors'].toString(),
                icon: Icons.person_add,
                color: AppTheme.primaryGreen,
                trend: '+5.2%',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: isRTL ? 'إجمالي المرضى' : 'Total Patients',
                value: _analyticsData['totalPatients'].toString(),
                icon: Icons.people,
                color: AppTheme.primaryPurple,
                trend: '+8.7%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: isRTL ? 'الإيرادات' : 'Revenue',
                value:
                    '${NumberFormat('#,###').format(_analyticsData['totalRevenue'])} ${isRTL ? 'ريال' : 'SAR'}',
                icon: Icons.attach_money,
                color: AppTheme.warningYellow,
                trend: '+${_analyticsData['monthlyGrowth']}%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCasesAnalytics(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'تحليل الحالات' : 'Cases Analytics',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildAnalyticsItem(
                  label: isRTL ? 'حالات نشطة' : 'Active Cases',
                  value: _analyticsData['activeCases'].toString(),
                  color: AppTheme.primaryBlue,
                ),
              ),
              Expanded(
                child: _buildAnalyticsItem(
                  label: isRTL ? 'حالات مكتملة' : 'Completed Cases',
                  value: _analyticsData['completedCases'].toString(),
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRTL ? 'معدل الإنجاز' : 'Completion Rate',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value:
                    _analyticsData['completedCases'] /
                    _analyticsData['totalCases'],
                backgroundColor: AppTheme.lightGray,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${((_analyticsData['completedCases'] / _analyticsData['totalCases']) * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsAnalytics(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'تحليل الأطباء' : 'Doctors Analytics',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildAnalyticsItem(
                  label: isRTL ? 'أطباء نشطون' : 'Active Doctors',
                  value: _analyticsData['activeDoctors'].toString(),
                  color: AppTheme.primaryGreen,
                ),
              ),
              Expanded(
                child: _buildAnalyticsItem(
                  label: isRTL ? 'متوسط التقييم' : 'Average Rating',
                  value: _analyticsData['averageRating'].toString(),
                  color: AppTheme.warningYellow,
                  suffix: ' ⭐',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsAnalytics(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'تحليل المرضى' : 'Patients Analytics',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildAnalyticsItem(
                  label: isRTL ? 'مرضى جدد' : 'New Patients',
                  value: _analyticsData['newPatients'].toString(),
                  color: AppTheme.primaryPurple,
                ),
              ),
              Expanded(
                child: _buildAnalyticsItem(
                  label: isRTL ? 'معدل النمو' : 'Growth Rate',
                  value: _analyticsData['monthlyGrowth'].toString(),
                  color: AppTheme.primaryGreen,
                  suffix: '%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueAnalytics(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'تحليل الإيرادات' : 'Revenue Analytics',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRTL ? 'إجمالي الإيرادات' : 'Total Revenue',
                  style: const TextStyle(fontSize: 14, color: AppTheme.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '${NumberFormat('#,###').format(_analyticsData['totalRevenue'])} ${isRTL ? 'ريال سعودي' : 'SAR'}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: AppTheme.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${_analyticsData['monthlyGrowth']}% ${isRTL ? 'من الشهر الماضي' : 'from last month'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'مؤشرات الأداء' : 'Performance Metrics',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildPerformanceItem(
            icon: Icons.access_time,
            label: isRTL ? 'متوسط وقت الاستجابة' : 'Average Response Time',
            value:
                '${_analyticsData['responseTime']} ${isRTL ? 'ساعة' : 'hours'}',
            color: AppTheme.primaryBlue,
          ),

          const SizedBox(height: 12),

          _buildPerformanceItem(
            icon: Icons.star,
            label: isRTL ? 'متوسط تقييم الخدمة' : 'Average Service Rating',
            value: '${_analyticsData['averageRating']}/5.0',
            color: AppTheme.warningYellow,
          ),

          const SizedBox(height: 12),

          _buildPerformanceItem(
            icon: Icons.check_circle,
            label: isRTL ? 'معدل رضا المرضى' : 'Patient Satisfaction Rate',
            value: '94.2%',
            color: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartsSection(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'الرسوم البيانية' : 'Charts',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Placeholder for charts
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.mediumGray.withOpacity(0.3),
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    isRTL ? 'الرسوم البيانية قريباً' : 'Charts Coming Soon',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem({
    required String label,
    required String value,
    required Color color,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          '$value${suffix ?? ''}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
