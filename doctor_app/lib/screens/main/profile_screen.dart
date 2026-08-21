import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/language_switcher.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _emergencyFeeController = TextEditingController();
  final _followUpFeeController = TextEditingController();
  final _currencyController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _acceptsInsurance = false;
  String _preferredLanguage = 'ar';
  File? _newProfilePicture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _bioController.dispose();
    _experienceYearsController.dispose();
    _consultationFeeController.dispose();
    _emergencyFeeController.dispose();
    _followUpFeeController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final doctor = authProvider.doctor;

    if (user != null) {
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }

    if (doctor != null) {
      _specializationController.text = doctor.specialization ?? '';
      _bioController.text = doctor.bio ?? '';
      _experienceYearsController.text =
          (doctor.experienceYears?.toString() ?? '');
      _consultationFeeController.text =
          (doctor.consultationFee?.toString() ?? '');
      _emergencyFeeController.text = (doctor.emergencyFee?.toString() ?? '');
      _followUpFeeController.text = (doctor.followUpFee?.toString() ?? '');
      _currencyController.text = doctor.currency ?? 'USD';
      _acceptsInsurance = doctor.acceptsInsurance ?? false;
      _preferredLanguage = doctor.preferredLanguage ?? 'ar';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      specialization: _specializationController.text.trim(),
      bio: _bioController.text.trim(),
      experienceYears: int.tryParse(_experienceYearsController.text),
      consultationFee: double.tryParse(_consultationFeeController.text),
      emergencyFee: double.tryParse(_emergencyFeeController.text),
      followUpFee: double.tryParse(_followUpFeeController.text),
      currency: _currencyController.text,
      acceptsInsurance: _acceptsInsurance,
      preferredLanguage: _preferredLanguage,
      profilePicture: _newProfilePicture,
    );

    setState(() => _isLoading = false);

    if (success) {
      setState(() {
        _isEditing = false;
        _newProfilePicture = null;
      });
      AppHelpers.showSuccessSnackBar(context, 'تم تحديث الملف الشخصي بنجاح');
    } else {
      AppHelpers.showErrorSnackBar(
        context,
        authProvider.error ?? 'فشل في تحديث الملف الشخصي',
      );
    }
  }

  Future<void> _logout() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    final confirmed = await AppHelpers.showConfirmationDialog(
      context,
      title: languageProvider.isArabic ? 'تسجيل الخروج' : 'Logout',
      message:
          languageProvider.isArabic
              ? 'هل أنت متأكد من تسجيل الخروج؟'
              : 'Are you sure you want to logout?',
      confirmText: languageProvider.isArabic ? 'نعم' : 'Yes',
      cancelText: languageProvider.isArabic ? 'إلغاء' : 'Cancel',
    );

    if (confirmed) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(languageProvider.isArabic ? 'الملف الشخصي' : 'Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        automaticallyImplyLeading: false,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _newProfilePicture = null;
                });
                _loadUserData();
              },
              child: Text(
                languageProvider.isArabic ? 'إلغاء' : 'Cancel',
                style: const TextStyle(color: AppColors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Picture Section
              _buildProfilePictureSection(authProvider, languageProvider),

              const SizedBox(height: AppConstants.largeSpacing),

              // Personal Information
              _buildPersonalInfoSection(languageProvider),

              const SizedBox(height: AppConstants.mediumSpacing),

              // Professional Information
              _buildProfessionalInfoSection(languageProvider),

              const SizedBox(height: AppConstants.mediumSpacing),

              // Settings Section
              _buildSettingsSection(languageProvider),

              const SizedBox(height: AppConstants.largeSpacing),

              // Action Buttons
              if (_isEditing)
                CustomButton(
                  text:
                      languageProvider.isArabic
                          ? 'حفظ التغييرات'
                          : 'Save Changes',
                  onPressed: _isLoading ? null : _saveProfile,
                  isLoading: _isLoading,
                  icon: Icons.save,
                )
              else
                CustomButton(
                  text: languageProvider.isArabic ? 'تسجيل الخروج' : 'Logout',
                  onPressed: _logout,
                  isOutlined: true,
                  icon: Icons.logout,
                  textColor: AppColors.error,
                  backgroundColor: AppColors.error,
                ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider<Object>? _getProfileImage(AuthProvider authProvider) {
    if (_newProfilePicture != null) {
      return FileImage(_newProfilePicture!);
    }
    final pic = authProvider.user?.profilePicture;
    if (pic is String && pic.isNotEmpty) {
      return NetworkImage('${AppConstants.mediaUrl}/$pic');
    }
    return null;
  }

  Widget _buildProfilePictureSection(
    AuthProvider authProvider,
    LanguageProvider languageProvider,
  ) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.greyLight,
            backgroundImage: _getProfileImage(authProvider),
            child: _newProfilePicture == null &&
                    (authProvider.user?.profilePicture == null ||
                     (authProvider.user?.profilePicture is String &&
                      (authProvider.user?.profilePicture as String).isEmpty))
                ? const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),

          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickProfilePicture,
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.smallSpacing),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: AppConstants.mediumIconSize,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(LanguageProvider languageProvider) {
    return Card(
      elevation: AppConstants.mediumElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.isArabic
                  ? 'المعلومات الشخصية'
                  : 'Personal Information',
              style: AppTextStyles.heading4,
            ),

            const SizedBox(height: AppConstants.mediumSpacing),

            CustomTextField(
              controller: _firstNameController,
              label: languageProvider.isArabic ? 'الاسم الأول' : 'First Name',
              enabled: _isEditing,
              prefixIcon: Icons.person_outlined,
              validator:
                  (value) =>
                      Validators.validateName(value, fieldName: 'الاسم الأول'),
            ),

            const SizedBox(height: AppConstants.mediumSpacing),

            CustomTextField(
              controller: _lastNameController,
              label: languageProvider.isArabic ? 'الاسم الأخير' : 'Last Name',
              enabled: _isEditing,
              prefixIcon: Icons.person_outlined,
              validator:
                  (value) =>
                      Validators.validateName(value, fieldName: 'الاسم الأخير'),
            ),

            const SizedBox(height: AppConstants.mediumSpacing),

            CustomTextField(
              controller: _emailController,
              label: languageProvider.isArabic ? 'البريد الإلكتروني' : 'Email',
              enabled: false, // Email cannot be changed
              prefixIcon: Icons.email_outlined,
              textDirection: TextDirection.ltr,
            ),

            const SizedBox(height: AppConstants.mediumSpacing),

            CustomTextField(
              controller: _phoneController,
              label: languageProvider.isArabic ? 'رقم الهاتف' : 'Phone Number',
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: Validators.validatePhoneNumber,
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoSection(LanguageProvider languageProvider) {
    return Card(
      elevation: AppConstants.mediumElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.isArabic
                  ? 'المعلومات المهنية'
                  : 'Professional Information',
              style: AppTextStyles.heading4,
            ),

            const SizedBox(height: AppConstants.mediumSpacing),

            CustomTextField(
              controller: _specializationController,
              label: languageProvider.isArabic ? 'التخصص' : 'Specialization',
              enabled: _isEditing,
              prefixIcon: Icons.medical_services_outlined,
              validator:
                  (value) =>
                      Validators.validateRequired(value, fieldName: 'التخصص'),
            ),

            const SizedBox(height: AppConstants.mediumSpacing),

            CustomTextField(
              controller: _experienceYearsController,
              label:
                  languageProvider.isArabic
                      ? 'سنوات الخبرة'
                      : 'Years of Experience',
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.work_outline,
              validator: Validators.validateExperienceYears,
            ),

            const SizedBox(height: AppConstants.mediumSpacing),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _consultationFeeController,
                    label:
                        languageProvider.isArabic
                            ? 'رسوم الاستشارة'
                            : 'Consultation Fee',
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money,
                    validator:
                        (value) => Validators.validateFee(
                          value,
                          fieldName: 'رسوم الاستشارة',
                        ),
                  ),
                ),
                const SizedBox(width: AppConstants.smallSpacing),
                SizedBox(
                  width: 80,
                  child: CustomTextField(
                    controller: _currencyController,
                    label: languageProvider.isArabic ? 'العملة' : 'Currency',
                    enabled: _isEditing,
                    validator:
                        (value) => Validators.validateRequired(
                          value,
                          fieldName: 'العملة',
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.mediumSpacing),

            CustomTextField(
              controller: _emergencyFeeController,
              label:
                  languageProvider.isArabic ? 'رسوم الطوارئ' : 'Emergency Fee',
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.emergency,
              validator:
                  (value) =>
                      Validators.validateFee(value, fieldName: 'رسوم الطوارئ'),
            ),

            const SizedBox(height: AppConstants.mediumSpacing),

            CustomTextField(
              controller: _followUpFeeController,
              label:
                  languageProvider.isArabic ? 'رسوم المتابعة' : 'Follow-up Fee',
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.follow_the_signs,
              validator:
                  (value) =>
                      Validators.validateFee(value, fieldName: 'رسوم المتابعة'),
            ),

            const SizedBox(height: AppConstants.mediumSpacing),

            CustomTextField(
              controller: _bioController,
              label: languageProvider.isArabic ? 'السيرة الذاتية' : 'Bio',
              enabled: _isEditing,
              maxLines: 4,
              prefixIcon: Icons.description_outlined,
              validator: Validators.validateBio,
            ),

            if (_isEditing) ...[
              const SizedBox(height: AppConstants.mediumSpacing),

              // Preferred Language
              Text(
                languageProvider.isArabic
                    ? 'اللغة المفضلة'
                    : 'Preferred Language',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppConstants.smallSpacing),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('العربية'),
                      value: 'ar',
                      groupValue: _preferredLanguage,
                      onChanged: (value) {
                        setState(() => _preferredLanguage = value!);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('English'),
                      value: 'en',
                      groupValue: _preferredLanguage,
                      onChanged: (value) {
                        setState(() => _preferredLanguage = value!);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.mediumSpacing),

              // Accepts Insurance
              CheckboxListTile(
                title: Text(
                  languageProvider.isArabic
                      ? 'يقبل التأمين الطبي'
                      : 'Accepts Insurance',
                ),
                value: _acceptsInsurance,
                onChanged: (value) {
                  setState(() => _acceptsInsurance = value!);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(LanguageProvider languageProvider) {
    return Card(
      elevation: AppConstants.mediumElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.isArabic ? 'الإعدادات' : 'Settings',
              style: AppTextStyles.heading4,
            ),

            const SizedBox(height: AppConstants.mediumSpacing),

            // Language Switcher
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  languageProvider.isArabic ? 'اللغة' : 'Language',
                  style: AppTextStyles.bodyMedium,
                ),
                const LanguageSwitcher(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProfilePicture() async {
    AppHelpers.showImagePickerOptions(
      context,
      onImageSelected: (file) {
        setState(() => _newProfilePicture = file);
      },
      onError: (error) {
        AppHelpers.showErrorSnackBar(context, error);
      },
    );
  }
}
