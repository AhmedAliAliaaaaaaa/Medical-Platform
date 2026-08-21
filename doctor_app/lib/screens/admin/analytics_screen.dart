
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../services/admin_api_service.dart';
import '../../utils/app_theme.dart';
import 'admin_constants.dart';
import 'widgets/admin_loading_error_widgets.dart';
import 'widgets/admin_stat_card.dart';
import 'widgets/simple_bar_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? _statistics;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await AdminApiService.getSystemStatistics();
      setState(() {
        _statistics = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
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
        title: Text(isRTL ? 'التحليلات' : 'Analytics'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: languageProvider.textDirection,
          child: _loading
              ? const AdminLoadingWidget()
              : _error != null
                  ? AdminErrorWidget(
                      errorMessage: _error,
                      onRetry: _load,
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(AdminConstants.paddingMedium),
                        children: [
                          _analyticsOverview(isRTL),
                          const SizedBox(height: AdminConstants.spacingMedium),
                          _analyticsTrends(isRTL),
                          const SizedBox(height: AdminConstants.spacingMedium),
                          _topSpecializations(isRTL),
                          const SizedBox(height: AdminConstants.spacingMedium),
                          _userGrowthChart(isRTL),
                          const SizedBox(height: AdminConstants.spacingMedium),
                          _casesGrowthChart(isRTL),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _analyticsOverview(bool isRTL) {
    final s = _statistics!;
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
        LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth;
          int cols = 2;
          double ar = 1.2;
          if (w < 360) {
            cols = 1;
            ar = 2.0;
          }
          if (w > 700) {
            cols = 3;
            ar = 1.3;
          }
          return GridView.count(
            crossAxisCount: cols,
            childAspectRatio: ar,
            crossAxisSpacing: AdminConstants.spacingSmall,
            mainAxisSpacing: AdminConstants.spacingSmall,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              AdminStatCard(
                title: isRTL ? 'إجمالي المستخدمين' : 'Total Users',
                value: '${s['total_users'] ?? 0}',
                icon: Icons.people,
                color: Colors.blue,
              ),
              AdminStatCard(
                title: isRTL ? 'إجمالي الحالات' : 'Total Cases',
                value: '${s['total_cases'] ?? 0}',
                icon: Icons.medical_information,
                color: Colors.green,
              ),
              AdminStatCard(
                title: isRTL ? 'الأطباء النشطون' : 'Active Doctors',
                value: '${s['active_doctors'] ?? s['approved_doctors'] ?? 0}',
                icon: Icons.medical_services,
                color: Colors.orange,
              ),
              AdminStatCard(
                title: isRTL ? 'الحالات المكتملة' : 'Completed Cases',
                value: '${s['completed_cases'] ?? 0}',
                icon: Icons.check_circle,
                color: Colors.teal,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _analyticsTrends(bool isRTL) {
    final s = _statistics!;
    return Container(
      padding: const EdgeInsets.all(AdminConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AdminConstants.card,
        borderRadius: AdminConstants.borderRadiusMedium,
        boxShadow: AdminConstants.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isRTL ? 'اتجاهات النمو' : 'Growth Trends',
            style: AdminConstants.title.copyWith(
              color: AdminConstants.darkBlue,
            ),
          ),
          const SizedBox(height: AdminConstants.spacingMedium),
          _metricRow(
            isRTL ? 'نمو المستخدمين' : 'Users',
            '${s['growth']?['users'] ?? 0}%',
            Icons.trending_up,
            Colors.blue,
          ),
          const SizedBox(height: AdminConstants.spacingSmall),
          _metricRow(
            isRTL ? 'نمو الحالات' : 'Cases',
            '${s['growth']?['cases'] ?? 0}%',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: AdminConstants.spacingSmall),
          _metricRow(
            isRTL ? 'نمو الإيرادات' : 'Revenue',
            '${s['growth']?['revenue'] ?? 0}%',
            Icons.trending_up,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String title, String value, IconData icon, Color color) {
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

  Widget _topSpecializations(bool isRTL) {
    final list = (_statistics!['top_specializations'] as List?) ?? [];
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
            isRTL ? 'أعلى التخصصات' : 'Top Specializations',
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

  Widget _userGrowthChart(bool isRTL) {
    // بيانات تجريبية لنمو المستخدمين
    final userData = [
      BarData(label: 'يناير', value: 120),
      BarData(label: 'فبراير', value: 135),
      BarData(label: 'مارس', value: 150),
      BarData(label: 'أبريل', value: 165),
      BarData(label: 'مايو', value: 180),
      BarData(label: 'يونيو', value: 200),
    ];

    return SimpleBarChart(
      title: isRTL ? 'نمو المستخدمين' : 'User Growth',
      data: userData,
      barColor: Colors.blue,
    );
  }

  Widget _casesGrowthChart(bool isRTL) {
    // بيانات تجريبية لنمو الحالات
    final casesData = [
      BarData(label: 'يناير', value: 180),
      BarData(label: 'فبراير', value: 195),
      BarData(label: 'مارس', value: 220),
      BarData(label: 'أبريل', value: 205),
      BarData(label: 'مايو', value: 240),
      BarData(label: 'يونيو', value: 260),
    ];

    return SimpleBarChart(
      title: isRTL ? 'نمو الحالات' : 'Cases Growth',
      data: casesData,
      barColor: Colors.green,
    );
  }
}
