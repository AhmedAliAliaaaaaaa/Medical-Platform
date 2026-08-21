import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/language_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/doctor.dart';
import '../../widgets/enhanced_card.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  // App Bar with Doctor Image
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: AppTheme.primaryBlue,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            // Doctor Avatar
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.textLight,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child:
                                    widget.doctor.profilePicture != null
                                        ? Image.network(
                                          widget.doctor.profilePicture!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: AppTheme.textLight,
                                              child: const Icon(
                                                Icons.person,
                                                size: 60,
                                                color: AppTheme.primaryBlue,
                                              ),
                                            );
                                          },
                                        )
                                        : Container(
                                          color: AppTheme.textLight,
                                          child: const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: AppTheme.primaryBlue,
                                          ),
                                        ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Doctor Name
                            Text(
                              widget.doctor.user.fullName,
                              style: const TextStyle(
                                color: AppTheme.textLight,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Specialization
                            Text(
                              widget.doctor.specialization,
                              style: TextStyle(
                                color: AppTheme.textLight.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Rating and Reviews
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppTheme.warningYellow,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '4.8 (127 ${isRTL ? 'تقييم' : 'reviews'})',
                                  style: TextStyle(
                                    color: AppTheme.textLight.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Stats
                          _buildQuickStats(isRTL),
                          const SizedBox(height: 24),

                          // About Section
                          _buildAboutSection(isRTL),
                          const SizedBox(height: 24),

                          // Experience Section
                          _buildExperienceSection(isRTL),
                          const SizedBox(height: 24),

                          // Consultation Fees
                          _buildFeesSection(isRTL),
                          const SizedBox(height: 24),

                          // Contact Information
                          _buildContactSection(isRTL),
                          const SizedBox(height: 100), // Space for FAB
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(isRTL ? 'احجز استشارة' : 'Book Consultation'),
        icon: const Icon(Icons.calendar_today),
        onPressed:
            widget.doctor.isApproved
                ? () => _showBookingDialog(context, isRTL)
                : null,
        backgroundColor:
            widget.doctor.isApproved
                ? AppTheme.primaryGreen
                : AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildQuickStats(bool isRTL) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.work_outline,
            title: isRTL ? 'سنوات الخبرة' : 'Experience',
            value: '${widget.doctor.experienceYears}',
            subtitle: isRTL ? 'سنة' : 'years',
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people_outline,
            title: isRTL ? 'المرضى' : 'Patients',
            value: '500+', // Mock data
            subtitle: isRTL ? 'مريض' : 'patients',
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star_outline,
            title: isRTL ? 'التقييم' : 'Rating',
            value: '4.8',
            subtitle: isRTL ? 'نجوم' : 'stars',
            color: AppTheme.warningYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return EnhancedCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
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
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isRTL ? 'نبذة عن الطبيب' : 'About Doctor',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.doctor.bio ??
                (isRTL
                    ? 'طبيب متخصص في ${widget.doctor.specialization} مع خبرة ${widget.doctor.experienceYears} سنة في المجال الطبي.'
                    : 'Specialized doctor in ${widget.doctor.specialization} with ${widget.doctor.experienceYears} years of experience in the medical field.'),
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isRTL ? 'الخبرة والمؤهلات' : 'Experience & Qualifications',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // License Information
          _buildInfoRow(
            icon: Icons.verified,
            label: isRTL ? 'رقم الترخيص' : 'License Number',
            value: widget.doctor.licenseNumber,
            isRTL: isRTL,
          ),
          const SizedBox(height: 12),

          // Country
          _buildInfoRow(
            icon: Icons.location_on,
            label: isRTL ? 'الدولة' : 'Country',
            value: widget.doctor.country,
            isRTL: isRTL,
          ),
          const SizedBox(height: 12),

          // Languages
          _buildInfoRow(
            icon: Icons.language,
            label: isRTL ? 'اللغات' : 'Languages',
            value:
                widget.doctor.preferredLanguage == 'ar'
                    ? (isRTL ? 'العربية، الإنجليزية' : 'Arabic, English')
                    : (isRTL ? 'الإنجليزية، العربية' : 'English, Arabic'),
            isRTL: isRTL,
          ),
        ],
      ),
    );
  }

  Widget _buildFeesSection(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warningYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: AppTheme.warningYellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isRTL ? 'رسوم الاستشارة' : 'Consultation Fees',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Regular Consultation
          _buildFeeRow(
            icon: Icons.video_call,
            label: isRTL ? 'استشارة عادية' : 'Regular Consultation',
            fee: widget.doctor.consultationFee,
            currency: widget.doctor.currency,
            isRTL: isRTL,
          ),
          const SizedBox(height: 12),

          // Emergency Consultation
          _buildFeeRow(
            icon: Icons.emergency,
            label: isRTL ? 'استشارة طارئة' : 'Emergency Consultation',
            fee: widget.doctor.emergencyFee,
            currency: widget.doctor.currency,
            isRTL: isRTL,
          ),
          const SizedBox(height: 12),

          // Follow-up
          _buildFeeRow(
            icon: Icons.refresh,
            label: isRTL ? 'متابعة' : 'Follow-up',
            fee: widget.doctor.followUpFee,
            currency: widget.doctor.currency,
            isRTL: isRTL,
          ),

          if (widget.doctor.acceptsInsurance) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRTL ? 'يقبل التأمين الطبي' : 'Accepts Insurance',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.contact_phone,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isRTL ? 'معلومات التواصل' : 'Contact Information',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email
          _buildInfoRow(
            icon: Icons.email,
            label: isRTL ? 'البريد الإلكتروني' : 'Email',
            value: widget.doctor.user.email,
            isRTL: isRTL,
          ),
          const SizedBox(height: 12),

          // Phone (if available)
          if (widget.doctor.phoneNumber != null)
            _buildInfoRow(
              icon: Icons.phone,
              label: isRTL ? 'رقم الهاتف' : 'Phone Number',
              value: widget.doctor.phoneNumber!,
              isRTL: isRTL,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isRTL,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeeRow({
    required IconData icon,
    required String label,
    required double fee,
    required String currency,
    required bool isRTL,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
          ),
        ),
        Text(
          '$fee $currency',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }

  void _showBookingDialog(BuildContext context, bool isRTL) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isRTL ? 'حجز استشارة' : 'Book Consultation',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isRTL
                    ? 'هل تريد حجز استشارة مع الدكتور ${widget.doctor.user.fullName}؟'
                    : 'Would you like to book a consultation with Dr. ${widget.doctor.user.fullName}?',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isRTL ? 'رسوم الاستشارة:' : 'Consultation Fee:',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '${widget.doctor.consultationFee} ${widget.doctor.currency}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'إلغاء' : 'Cancel',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to booking screen or create case
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isRTL
                          ? 'تم حجز الاستشارة بنجاح'
                          : 'Consultation booked successfully',
                    ),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isRTL ? 'تأكيد الحجز' : 'Confirm Booking',
                style: const TextStyle(color: AppTheme.textLight),
              ),
            ),
          ],
        );
      },
    );
  }
}
