import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/case_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../cases/case_details_screen.dart';

class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCases();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCases() async {
    setState(() => _isLoading = true);

    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    await caseProvider.getAssignedCases(refresh: true);

    setState(() => _isLoading = false);
  }

  Future<void> _refreshCases() async {
    await _loadCases();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final caseProvider = Provider.of<CaseProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          languageProvider.isArabic ? 'الحالات الطبية' : 'Medical Cases',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshCases,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textOnPrimary,
          unselectedLabelColor: AppColors.textOnPrimary.withOpacity(0.7),
          indicatorColor: AppColors.white,
          tabs: [
            Tab(
              text: languageProvider.isArabic ? 'الكل' : 'All',
              icon: const Icon(Icons.list, size: 20),
            ),
            Tab(
              text: languageProvider.isArabic ? 'جديدة' : 'New',
              icon: const Icon(Icons.new_releases, size: 20),
            ),
            Tab(
              text: languageProvider.isArabic ? 'قيد المعالجة' : 'In Progress',
              icon: const Icon(Icons.hourglass_empty, size: 20),
            ),
            Tab(
              text: languageProvider.isArabic ? 'مكتملة' : 'Completed',
              icon: const Icon(Icons.check_circle, size: 20),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCasesList(caseProvider.cases, 'all'),
          _buildCasesList(caseProvider.pendingCases, 'pending'),
          _buildCasesList(caseProvider.inProgressCases, 'in_progress'),
          _buildCasesList(caseProvider.completedCases, 'completed'),
        ],
      ),
    );
  }

  Widget _buildCasesList(List<dynamic> cases, String status) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cases.isEmpty) {
      return _buildEmptyState(status, languageProvider);
    }

    return RefreshIndicator(
      onRefresh: _refreshCases,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        itemCount: cases.length,
        itemBuilder: (context, index) {
          final medicalCase = cases[index];
          return _buildCaseCard(medicalCase, languageProvider);
        },
      ),
    );
  }

  Widget _buildEmptyState(String status, LanguageProvider languageProvider) {
    String title, subtitle;
    IconData icon;

    switch (status) {
      case 'pending':
        title =
            languageProvider.isArabic ? 'لا توجد حالات جديدة' : 'No New Cases';
        subtitle =
            languageProvider.isArabic
                ? 'ستظهر الحالات الجديدة هنا عند وصولها'
                : 'New cases will appear here when they arrive';
        icon = Icons.new_releases_outlined;
        break;
      case 'in_progress':
        title =
            languageProvider.isArabic
                ? 'لا توجد حالات قيد المعالجة'
                : 'No Cases In Progress';
        subtitle =
            languageProvider.isArabic
                ? 'الحالات التي تعمل عليها ستظهر هنا'
                : 'Cases you are working on will appear here';
        icon = Icons.hourglass_empty_outlined;
        break;
      case 'completed':
        title =
            languageProvider.isArabic
                ? 'لا توجد حالات مكتملة'
                : 'No Completed Cases';
        subtitle =
            languageProvider.isArabic
                ? 'الحالات المكتملة ستظهر هنا'
                : 'Completed cases will appear here';
        icon = Icons.check_circle_outline;
        break;
      default:
        title = languageProvider.isArabic ? 'لا توجد حالات' : 'No Cases';
        subtitle =
            languageProvider.isArabic
                ? 'لم يتم تعيين أي حالات لك بعد'
                : 'No cases have been assigned to you yet';
        icon = Icons.medical_services_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppConstants.extraLargeIconSize,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            Text(
              title,
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            CustomButton(
              text: languageProvider.isArabic ? 'تحديث' : 'Refresh',
              icon: Icons.refresh,
              onPressed: _refreshCases,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseCard(
    dynamic medicalCase,
    LanguageProvider languageProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.mediumSpacing),
      elevation: AppConstants.mediumElevation,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CaseDetailsScreen(caseId: medicalCase.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Priority Indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          medicalCase.isUrgent
                              ? AppColors.urgentPriority
                              : AppColors.normalPriority,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(width: AppConstants.smallSpacing),

                  // Case Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                medicalCase.title,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (medicalCase.isUrgent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.smallSpacing,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.urgentPriority.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.smallRadius,
                                  ),
                                ),
                                child: Text(
                                  languageProvider.isArabic ? 'عاجل' : 'Urgent',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.urgentPriority,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: AppConstants.smallSpacing / 2),

                        Text(
                          medicalCase.patient.displayName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.smallSpacing,
                      vertical: AppConstants.smallSpacing / 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        medicalCase.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallRadius,
                      ),
                    ),
                    child: Text(
                      _getStatusText(
                        medicalCase.status,
                        languageProvider.isArabic,
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getStatusColor(medicalCase.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.mediumSpacing),

              // Case Description
              Text(
                medicalCase.description,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppConstants.mediumSpacing),

              // Footer Row
              Row(
                children: [
                  // Patient Info
                  Icon(
                    medicalCase.patient.gender == 'male'
                        ? Icons.male
                        : Icons.female,
                    size: AppConstants.smallIconSize,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppConstants.smallSpacing / 2),
                  Text(
                    '${medicalCase.patient.age} ${languageProvider.isArabic ? 'سنة' : 'years'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(width: AppConstants.mediumSpacing),

                  // Attachments
                  if (medicalCase.attachments.isNotEmpty) ...[
                    Icon(
                      Icons.attach_file,
                      size: AppConstants.smallIconSize,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppConstants.smallSpacing / 2),
                    Text(
                      '${medicalCase.attachments.length}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(width: AppConstants.mediumSpacing),
                  ],

                  const Spacer(),

                  // Time
                  Text(
                    AppHelpers.getTimeAgo(medicalCase.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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

  void _showFilterDialog() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              languageProvider.isArabic ? 'تصفية الحالات' : 'Filter Cases',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterOption(
                  'all',
                  languageProvider.isArabic ? 'جميع الحالات' : 'All Cases',
                  Icons.list,
                ),
                _buildFilterOption(
                  'urgent',
                  languageProvider.isArabic
                      ? 'الحالات العاجلة'
                      : 'Urgent Cases',
                  Icons.priority_high,
                ),
                _buildFilterOption(
                  'recent',
                  languageProvider.isArabic
                      ? 'الحالات الأخيرة'
                      : 'Recent Cases',
                  Icons.schedule,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(languageProvider.isArabic ? 'إلغاء' : 'Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _applyFilter();
                },
                child: Text(languageProvider.isArabic ? 'تطبيق' : 'Apply'),
              ),
            ],
          ),
    );
  }

  Widget _buildFilterOption(String value, String title, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedFilter,
      onChanged: (value) {
        setState(() {
          _selectedFilter = value!;
        });
      },
      title: Row(
        children: [
          Icon(icon, size: AppConstants.mediumIconSize),
          const SizedBox(width: AppConstants.smallSpacing),
          Text(title),
        ],
      ),
    );
  }

  void _applyFilter() {
    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    caseProvider.filterCases(status: _selectedFilter);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.pendingStatus;
      case 'in_progress':
        return AppColors.inProgressStatus;
      case 'completed':
        return AppColors.completedStatus;
      case 'cancelled':
        return AppColors.cancelledStatus;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status, bool isArabic) {
    switch (status) {
      case 'pending':
        return isArabic ? 'جديدة' : 'Pending';
      case 'in_progress':
        return isArabic ? 'قيد المعالجة' : 'In Progress';
      case 'completed':
        return isArabic ? 'مكتملة' : 'Completed';
      case 'cancelled':
        return isArabic ? 'ملغية' : 'Cancelled';
      default:
        return status;
    }
  }
}
