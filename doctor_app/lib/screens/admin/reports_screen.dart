
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../services/admin_api_service.dart';
import '../../utils/app_theme.dart';
import 'admin_constants.dart';
import 'widgets/admin_loading_error_widgets.dart';
import 'widgets/admin_stat_card.dart';
import 'widgets/simple_bar_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedPeriod = 'month';

  final List<Map<String, String>> _periods = [
    {'value': 'week', 'label_ar': 'هذا الأسبوع', 'label_en': 'This Week'},
    {'value': 'month', 'label_ar': 'هذا الشهر', 'label_en': 'This Month'},
    {'value': 'quarter', 'label_ar': 'هذا الربع', 'label_en': 'This Quarter'},
    {'value': 'year', 'label_ar': 'هذا العام', 'label_en': 'This Year'},
  ];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📊 تحميل إحصائيات النظام...');
      final stats = await AdminApiService.getSystemStatistics();
      print('✅ تم تحميل الإحصائيات بنجاح');

      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ خطأ في تحميل الإحصائيات: $e');
      // استخدام بيانات تجريبية
      setState(() {
        _statistics = {
          'total_users': 1250,
          'total_patients': 980,
          'total_doctors': 85,
          'active_doctors': 72,
          'pending_doctors': 8,
          'total_cases': 2340,
          'pending_cases': 45,
          'in_progress_cases': 23,
          'completed_cases': 2272,
          'cancelled_cases': 12,
          'average_response_time': 18.5,
          'patient_satisfaction': 4.6,
          'doctor_satisfaction': 4.4,
          'revenue': {
            'total': 125000,
            'this_month': 15600,
            'last_month': 14200,
          },
          'growth': {'users': 12.5, 'cases': 8.3, 'revenue': 9.8},
          'top_specializations': [
            {'name': 'طب عام', 'count': 450},
            {'name': 'طب الأطفال', 'count': 320},
            {'name': 'أمراض القلب', 'count': 280},
            {'name': 'الأمراض الجلدية', 'count': 210},
            {'name': 'العظام', 'count': 180},
          ],
          'monthly_cases': [
            {'month': 'يناير', 'cases': 180},
            {'month': 'فبراير', 'cases': 195},
            {'month': 'مارس', 'cases': 220},
            {'month': 'أبريل', 'cases': 205},
            {'month': 'مايو', 'cases': 240},
            {'month': 'يونيو', 'cases': 260},
          ],
        };
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
      backgroundColor: AdminConstants.softBg,
      appBar: AppBar(
        title: Text(isRTL ? 'تقارير النظام' : 'System Reports'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadStatistics,
            icon: const Icon(Icons.refresh),
            tooltip: isRTL ? 'تحديث' : 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: languageProvider.textDirection,
          child: _isLoading
              ? const AdminLoadingWidget()
              : _errorMessage != null
                  ? AdminErrorWidget(
                      errorMessage: _errorMessage,
                      onRetry: _loadStatistics,
                    )
                  : _buildReportsContent(isRTL),
        ),
      ),
    );
  }

  Widget _buildReportsContent(bool isRTL) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(isRTL),
          const SizedBox(height: AdminConstants.spacingMedium),
          _buildOverviewCards(isRTL),
          const SizedBox(height: AdminConstants.spacingMedium),
          _buildPerformanceMetrics(isRTL),
          const SizedBox(height: AdminConstants.spacingMedium),
          _buildGrowthIndicators(isRTL),
          const SizedBox(height: AdminConstants.spacingMedium),
          _buildTopSpecializations(isRTL),
          const SizedBox(height: AdminConstants.spacingMedium),
          _buildMonthlyCasesChart(isRTL),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(AdminConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AdminConstants.card,
        borderRadius: AdminConstants.borderRadiusMedium,
        boxShadow: AdminConstants.shadowSoft,
      ),
      child: Row(
        children: [
          Text(
            isRTL ? 'الفترة الزمنية:' : 'Time Period:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: AdminConstants.spacingMedium),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: AdminConstants.borderRadiusSmall,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  isExpanded: true,
                  items: _periods.map((period) {
                    return DropdownMenuItem<String>(
                      value: period['value'],
                      child: Text(
                        isRTL ? period['label_ar']! : period['label_en']!,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                    });
                    _loadStatistics();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRTL ? 'نظرة عامة' : 'Overview',
          style: AdminConstants.title.copyWith(
            color: AdminConstants.darkBlue,
          ),
        ),
        const SizedBox(height: AdminConstants.spacingSmall),
        LayoutBuilder(builder: (context, constraints) {
          // Responsive columns: 1 on narrow, 2 on medium, 3 on wide
          final double width = constraints.maxWidth;
          int crossAxisCount = 2;
          double aspect = 1.5;
          if (width < 380) {
            crossAxisCount = 1;
            aspect = 2.2;
          } else if (width > 700) {
            crossAxisCount = 3;
            aspect = 1.7;
          }
          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: aspect,
            crossAxisSpacing: AdminConstants.spacingSmall,
            mainAxisSpacing: AdminConstants.spacingSmall,
            children: [
              AdminStatCard(
                title: isRTL ? 'إجمالي المستخدمين' : 'Total Users',
                value: '${_statistics!['total_users']}',
                icon: Icons.people,
                color: AppTheme.primaryBlue,
              ),
              AdminStatCard(
                title: isRTL ? 'إجمالي الحالات' : 'Total Cases',
                value: '${_statistics!['total_cases']}',
                icon: Icons.medical_information,
                color: AppTheme.primaryGreen,
              ),
              AdminStatCard(
                title: isRTL ? 'الأطباء النشطون' : 'Active Doctors',
                value: '${_statistics!['active_doctors']}',
                icon: Icons.medical_services,
                color: Colors.orange,
              ),
              AdminStatCard(
                title: isRTL ? 'الحالات المكتملة' : 'Completed Cases',
                value: '${_statistics!['completed_cases']}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPerformanceMetrics(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(AdminConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AdminConstants.card,
        borderRadius: AdminConstants.borderRadiusMedium,
        boxShadow: AdminConstants.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'مؤشرات الأداء' : 'Performance Metrics',
            style: AdminConstants.title.copyWith(
              color: AdminConstants.darkBlue,
            ),
          ),
          const SizedBox(height: AdminConstants.spacingMedium),
          _buildMetricRow(
            isRTL ? 'متوسط وقت الاستجابة' : 'Average Response Time',
            '${_statistics!['average_response_time']} ${isRTL ? 'ساعة' : 'hours'}',
            Icons.access_time,
            Colors.blue,
          ),
          const SizedBox(height: AdminConstants.spacingSmall),
          _buildMetricRow(
            isRTL ? 'رضا المرضى' : 'Patient Satisfaction',
            '${_statistics!['patient_satisfaction']}/5.0',
            Icons.sentiment_very_satisfied,
            Colors.green,
          ),
          const SizedBox(height: AdminConstants.spacingSmall),
          _buildMetricRow(
            isRTL ? 'رضا الأطباء' : 'Doctor Satisfaction',
            '${_statistics!['doctor_satisfaction']}/5.0',
            Icons.medical_services,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AdminConstants.spacingSmall),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AdminConstants.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthIndicators(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(AdminConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AdminConstants.card,
        borderRadius: AdminConstants.borderRadiusMedium,
        boxShadow: AdminConstants.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'مؤشرات النمو' : 'Growth Indicators',
            style: AdminConstants.title.copyWith(
              color: AdminConstants.darkBlue,
            ),
          ),
          const SizedBox(height: AdminConstants.spacingMedium),
          Row(
            children: [
              Expanded(
                child: _buildGrowthCard(
                  isRTL ? 'نمو المستخدمين' : 'User Growth',
                  '${_statistics!['growth']['users']}%',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: AdminConstants.spacingSmall),
              Expanded(
                child: _buildGrowthCard(
                  isRTL ? 'نمو الحالات' : 'Cases Growth',
                  '${_statistics!['growth']['cases']}%',
                  Colors.green,
                ),
              ),
              const SizedBox(width: AdminConstants.spacingSmall),
              Expanded(
                child: _buildGrowthCard(
                  isRTL ? 'نمو الإيرادات' : 'Revenue Growth',
                  '${_statistics!['growth']['revenue']}%',
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AdminConstants.paddingSmall),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AdminConstants.borderRadiusSmall,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AdminConstants.spacingSmall),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopSpecializations(bool isRTL) {
    final raw = _statistics?['top_specializations'];
    final List list = raw is List ? raw : const [];
    if (list.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AdminConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AdminConstants.card,
        borderRadius: AdminConstants.borderRadiusMedium,
        boxShadow: AdminConstants.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'أكثر التخصصات طلباً' : 'Top Specializations',
            style: AdminConstants.title.copyWith(
              color: AdminConstants.darkBlue,
            ),
          ),
          const SizedBox(height: AdminConstants.spacingMedium),
          ...list.map((e) {
            final spec = e is Map ? e : <String, dynamic>{};
            return Padding(
              padding: const EdgeInsets.only(bottom: AdminConstants.spacingSmall),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${spec['specialization'] ?? spec['name'] ?? ''}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: AdminConstants.borderRadiusSmall,
                    ),
                    child: Text(
                      '${spec['count'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMonthlyCasesChart(bool isRTL) {
    final raw = _statistics?['monthly_cases'];
    final List monthlyCases = raw is List ? raw : const [];
    if (monthlyCases.isEmpty) return const SizedBox.shrink();

    // تحويل البيانات إلى BarData
    final List<BarData> barData = monthlyCases.map((m) {
      final int cases = (m is Map && m['cases'] is int) ? m['cases'] as int : 0;
      final String month = (m is Map && m['month'] != null) ? '${m['month']}' : '';
      return BarData(label: month, value: cases.toDouble());
    }).toList();

    return SimpleBarChart(
      title: isRTL ? 'الحالات الشهرية' : 'Monthly Cases',
      data: barData,
      barColor: AppTheme.primaryBlue,
    );
  }
}
