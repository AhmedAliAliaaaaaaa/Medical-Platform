class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'تنسيق البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (value != password) {
      return 'كلمات المرور غير متطابقة';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value, {String fieldName = 'الاسم'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }

    if (value.length < 2) {
      return '$fieldName يجب أن يكون حرفين على الأقل';
    }

    if (value.length > 50) {
      return '$fieldName يجب أن يكون أقل من 50 حرف';
    }

    // Allow Arabic and English letters, spaces, and some special characters
    final nameRegex = RegExp(r'^[a-zA-Zأ-ي\s\-\.]+$');
    if (!nameRegex.hasMatch(value)) {
      return '$fieldName يحتوي على أحرف غير صالحة';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    // Remove spaces, dashes, and parentheses
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it starts with + and has 10-15 digits
    final phoneRegex = RegExp(r'^\+?[1-9]\d{9,14}$');
    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'تنسيق رقم الهاتف غير صحيح';
    }

    return null;
  }

  // License number validation
  static String? validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الرخصة مطلوب';
    }

    if (value.length < 5) {
      return 'رقم الرخصة يجب أن يكون 5 أحرف على الأقل';
    }

    if (value.length > 20) {
      return 'رقم الرخصة يجب أن يكون أقل من 20 حرف';
    }

    // Allow letters, numbers, and some special characters
    final licenseRegex = RegExp(r'^[a-zA-Z0-9\-\/]+$');
    if (!licenseRegex.hasMatch(value)) {
      return 'رقم الرخصة يحتوي على أحرف غير صالحة';
    }

    return null;
  }

  // Bio validation
  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return 'السيرة الذاتية مطلوبة';
    }

    if (value.length < 50) {
      return 'السيرة الذاتية يجب أن تكون 50 حرف على الأقل';
    }

    if (value.length > 1000) {
      return 'السيرة الذاتية يجب أن تكون أقل من 1000 حرف';
    }

    return null;
  }

  // Experience years validation
  static String? validateExperienceYears(String? value) {
    if (value == null || value.isEmpty) {
      return 'سنوات الخبرة مطلوبة';
    }

    final years = int.tryParse(value);
    if (years == null) {
      return 'سنوات الخبرة يجب أن تكون رقم';
    }

    if (years < 0) {
      return 'سنوات الخبرة لا يمكن أن تكون سالبة';
    }

    if (years > 50) {
      return 'سنوات الخبرة لا يمكن أن تكون أكثر من 50 سنة';
    }

    return null;
  }

  // Fee validation
  static String? validateFee(String? value, {String fieldName = 'الرسوم'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوبة';
    }

    final fee = double.tryParse(value);
    if (fee == null) {
      return '$fieldName يجب أن تكون رقم';
    }

    if (fee < 0) {
      return '$fieldName لا يمكن أن تكون سالبة';
    }

    if (fee > 10000) {
      return '$fieldName لا يمكن أن تكون أكثر من 10000';
    }

    return null;
  }

  // Country validation
  static String? validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'البلد مطلوب';
    }

    if (value.length < 2) {
      return 'البلد يجب أن يكون حرفين على الأقل';
    }

    if (value.length > 50) {
      return 'البلد يجب أن يكون أقل من 50 حرف';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String fieldName = 'الحقل'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }

    return null;
  }

  // Diagnosis validation
  static String? validateDiagnosis(String? value) {
    if (value == null || value.isEmpty) {
      return 'التشخيص مطلوب';
    }

    if (value.length < 10) {
      return 'التشخيص يجب أن يكون 10 أحرف على الأقل';
    }

    if (value.length > 2000) {
      return 'التشخيص يجب أن يكون أقل من 2000 حرف';
    }

    return null;
  }

  // Treatment plan validation
  static String? validateTreatmentPlan(String? value) {
    if (value == null || value.isEmpty) {
      return 'خطة العلاج مطلوبة';
    }

    if (value.length < 10) {
      return 'خطة العلاج يجب أن تكون 10 أحرف على الأقل';
    }

    if (value.length > 2000) {
      return 'خطة العلاج يجب أن تكون أقل من 2000 حرف';
    }

    return null;
  }

  // Notes validation (optional)
  static String? validateNotes(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > 1000) {
        return 'الملاحظات يجب أن تكون أقل من 1000 حرف';
      }
    }

    return null;
  }

  // File size validation
  static String? validateFileSize(int fileSizeInBytes, {int maxSizeInMB = 10}) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;

    if (fileSizeInBytes > maxSizeInBytes) {
      return 'حجم الملف يجب أن يكون أقل من ${maxSizeInMB}MB';
    }

    return null;
  }

  // File type validation
  static String? validateFileType(String fileName, List<String> allowedTypes) {
    final extension = fileName.split('.').last.toLowerCase();

    if (!allowedTypes.contains(extension)) {
      return 'نوع الملف غير مدعوم. الأنواع المدعومة: ${allowedTypes.join(', ')}';
    }

    return null;
  }

  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Age is optional
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'العمر يجب أن يكون رقم';
    }

    if (age < 0) {
      return 'العمر لا يمكن أن يكون سالب';
    }

    if (age > 150) {
      return 'العمر لا يمكن أن يكون أكثر من 150 سنة';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'تنسيق الرابط غير صحيح';
    }

    return null;
  }
}
