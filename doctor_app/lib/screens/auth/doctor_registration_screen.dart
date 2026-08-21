import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import 'pending_approval_screen.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  State<DoctorRegistrationScreen> createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _experienceController = TextEditingController();
  final _regularConsultationPriceController = TextEditingController();
  final _emergencyConsultationPriceController = TextEditingController();
  final _followUpConsultationPriceController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedCurrency = 'ريال سعودي';

  String _selectedSpecialization = 'general';
  // Default must match one of _countries exactly to avoid Dropdown assertion
  String _selectedCountry = 'السعودية';
  File? _licenseImage;
  File? _profileImage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptsInsurance = false;
  String? _errorMessage;

  final List<Map<String, String>> _specializations = [
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
    {'value': 'radiology', 'label': 'الأشعة'},
    {'value': 'anesthesia', 'label': 'التخدير'},
    {'value': 'emergency', 'label': 'طب الطوارئ'},
    {'value': 'surgery', 'label': 'الجراحة العامة'},
    {'value': 'internal', 'label': 'الباطنة'},
    {'value': 'family', 'label': 'طب الأسرة'},
    {'value': 'oncology', 'label': 'الأورام'},
    {'value': 'endocrinology', 'label': 'الغدد الصماء'},
  ];

  final List<String> _countries = [
    'السعودية',
    'الإمارات العربية المتحدة',
    'الكويت',
    'قطر',
    'البحرين',
    'عمان',
    'الأردن',
    'لبنان',
    'سوريا',
    'العراق',
    'مصر',
    'المغرب',
    'تونس',
    'الجزائر',
    'ليبيا',
    'السودان',
    'اليمن',
    'فلسطين',
    'تركيا',
    'إيران',
    'باكستان',
    'الهند',
    'بنغلاديش',
    'أفغانستان',
    'ماليزيا',
    'إندونيسيا',
    'الفلبين',
    'الولايات المتحدة',
    'كندا',
    'المملكة المتحدة',
    'ألمانيا',
    'فرنسا',
    'إيطاليا',
    'إسبانيا',
    'هولندا',
    'بلجيكا',
    'سويسرا',
    'النمسا',
    'السويد',
    'النرويج',
    'الدنمارك',
    'فنلندا',
    'أستراليا',
    'نيوزيلندا',
    'اليابان',
    'كوريا الجنوبية',
    'الصين',
    'روسيا',
    'البرازيل',
    'الأرجنتين',
    'المكسيك',
    'جنوب أفريقيا',
  ];

  final List<String> _currencies = [
    'ريال سعودي',
    'درهم إماراتي',
    'دينار كويتي',
    'ريال قطري',
    'دينار بحريني',
    'ريال عماني',
    'دينار أردني',
    'ليرة لبنانية',
    'ليرة سورية',
    'دينار عراقي',
    'جنيه مصري',
    'درهم مغربي',
    'دينار تونسي',
    'دينار جزائري',
    'دينار ليبي',
    'جنيه سوداني',
    'ريال يمني',
    'شيكل',
    'ليرة تركية',
    'ريال إيراني',
    'روبية باكستانية',
    'روبية هندية',
    'تاكا بنغلاديشي',
    'أفغاني',
    'رينغيت ماليزي',
    'روبية إندونيسية',
    'بيسو فلبيني',
    'دولار أمريكي',
    'دولار كندي',
    'جنيه إسترليني',
    'يورو',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل طبيب جديد'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // رسالة ترحيب
              Card(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_hospital,
                        size: 48,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'انضم إلى فريق الأطباء',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'سيتم مراجعة طلبك من قبل الإدارة قبل الموافقة',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // رسالة خطأ
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                    ],
                  ),
                ),

              // المعلومات الشخصية
              _buildSectionTitle('المعلومات الشخصية'),
              const SizedBox(height: 16),

              // صورة الملف الشخصي (اختيارية)
              _buildImagePicker(
                'صورة الملف الشخصي (اختيارية)',
                _profileImage,
                (image) => setState(() => _profileImage = image),
                Icons.person,
                false,
              ),
              const SizedBox(height: 16),

              // الاسم الكامل
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل *',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم الكامل';
                  }
                  if (value.trim().split(' ').length < 2) {
                    return 'يرجى إدخال الاسم الأول والأخير على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // اسم المستخدم
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'اسم المستخدم *',
                  prefixIcon: const Icon(Icons.account_circle),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  helperText: 'سيتم استخدامه لتسجيل الدخول',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم المستخدم';
                  }
                  if (value.length < 3) {
                    return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // البريد الإلكتروني
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني *',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'يرجى إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // كلمة المرور
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور *',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  if (value.length < 8) {
                    return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // تأكيد كلمة المرور
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى تأكيد كلمة المرور';
                  }
                  if (value != _passwordController.text) {
                    return 'كلمة المرور غير متطابقة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // رقم الهاتف
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف *',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // البلد
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: InputDecoration(
                  labelText: 'البلد *',
                  prefixIcon: const Icon(Icons.public),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _countries.map((country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // المعلومات المهنية
              _buildSectionTitle('المعلومات المهنية'),
              const SizedBox(height: 16),

              // التخصص
              DropdownButtonFormField<String>(
                value: _selectedSpecialization,
                decoration: InputDecoration(
                  labelText: 'التخصص *',
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
                },
              ),
              const SizedBox(height: 16),

              // رقم الترخيص
              TextFormField(
                controller: _licenseNumberController,
                decoration: InputDecoration(
                  labelText: 'رقم الترخيص الطبي *',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الترخيص الطبي';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // سنوات الخبرة
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'سنوات الخبرة *',
                  prefixIcon: const Icon(Icons.work),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال سنوات الخبرة';
                  }
                  final experience = int.tryParse(value);
                  if (experience == null || experience < 0) {
                    return 'يرجى إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // العملة
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'العملة *',
                  prefixIcon: const Icon(Icons.currency_exchange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _currencies.map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // سعر الاستشارة العادية
              TextFormField(
                controller: _regularConsultationPriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'سعر الاستشارة العادية *',
                  prefixIcon: const Icon(Icons.payments),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  helperText:
                      'يرجى إدخال سعر الاستشارة العادية بالعملة المحلية',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال سعر الاستشارة العادية';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'يرجى إدخال سعر صحيح أكبر من صفر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // سعر استشارة الطوارئ
              TextFormField(
                controller: _emergencyConsultationPriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'سعر استشارة الطوارئ *',
                  prefixIcon: const Icon(Icons.emergency),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  helperText: 'يرجى إدخال سعر استشارة الطوارئ بالعملة المحلية',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال سعر استشارة الطوارئ';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'يرجى إدخال سعر صحيح أكبر من صفر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // سعر استشارة المتابعة
              TextFormField(
                controller: _followUpConsultationPriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'سعر استشارة المتابعة *',
                  prefixIcon: const Icon(Icons.event_repeat),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  helperText: 'يرجى إدخال سعر استشارة المتابعة بالعملة المحلية',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال سعر استشارة المتابعة';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'يرجى إدخال سعر صحيح أكبر من صفر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // نبذة شخصية
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'نبذة شخصية (اختيارية)',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  helperText: 'اكتب نبذة مختصرة عن خبرتك وتخصصك',
                ),
              ),
              const SizedBox(height: 16),

              // قبول التأمين الطبي
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'قبول التأمين الطبي',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'هل تقبل المرضى الذين لديهم تأمين طبي؟',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _acceptsInsurance,
                        onChanged: (value) {
                          setState(() {
                            _acceptsInsurance = value;
                          });
                        },
                        activeColor: Colors.blue.shade700,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // صورة الترخيص الطبي (إلزامية)
              _buildImagePicker(
                'صورة الترخيص الطبي (إلزامية)',
                _licenseImage,
                (image) => setState(() => _licenseImage = image),
                Icons.document_scanner,
                true,
              ),
              const SizedBox(height: 32),

              // زر التسجيل
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'تسجيل الطلب',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // ملاحظة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'سيتم مراجعة طلبك من قبل الإدارة خلال 24-48 ساعة. ستتلقى إشعاراً عند الموافقة على حسابك.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildImagePicker(
    String label,
    File? image,
    Function(File?) onImageSelected,
    IconData icon,
    bool isRequired,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isRequired ? Colors.red.shade700 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(onImageSelected),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: image != null
                    ? AppTheme.primaryGreen
                    : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'اضغط لاختيار صورة',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(Function(File?) onImageSelected) async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('الكاميرا'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  onImageSelected(File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  onImageSelected(File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_licenseImage == null) {
      setState(() {
        _errorMessage = 'يرجى إرفاق صورة الترخيص الطبي';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // التحقق من الاتصال بالإنترنت قبل إرسال الطلب
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          _errorMessage =
              'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';
        });
        return;
      }

      await ApiService.registerDoctor(
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        specialization: _selectedSpecialization,
        country: _selectedCountry,
        licenseNumber: _licenseNumberController.text.trim(),
        experienceYears: int.parse(_experienceController.text),
        regularConsultationPrice:
            double.parse(_regularConsultationPriceController.text),
        emergencyConsultationPrice:
            double.parse(_emergencyConsultationPriceController.text),
        followUpConsultationPrice:
            double.parse(_followUpConsultationPriceController.text),
        currency: _selectedCurrency,
        acceptsInsurance: _acceptsInsurance,
        bio: _bioController.text.trim(),
        licenseImage: _licenseImage!,
        profileImage: _profileImage,
      );

      if (!mounted) return;

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إرسال طلب التسجيل بنجاح! سيتم مراجعته من قبل الإدارة.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // الانتقال إلى شاشة انتظار الموافقة
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PendingApprovalScreen()),
      );
    } catch (e) {
      String errorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

      if (e is SocketException) {
        errorMessage =
            'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';
      } else if (e.toString().contains('timeout') ||
          e.toString().contains('TimeoutException')) {
        errorMessage = 'استغرق الطلب وقتاً طويلاً. يرجى المحاولة مرة أخرى.';
      } else if (e.toString().contains('HttpException') ||
          e.toString().contains('http')) {
        errorMessage =
            'حدث خطأ في الخادم: ${e.toString().replaceAll('Exception: ', '')}';
      } else if (e is FormatException) {
        errorMessage =
            'حدث خطأ في معالجة البيانات. يرجى التحقق من البيانات المدخلة.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      if (mounted) {
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _licenseNumberController.dispose();
    _experienceController.dispose();
    _regularConsultationPriceController.dispose();
    _emergencyConsultationPriceController.dispose();
    _followUpConsultationPriceController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
