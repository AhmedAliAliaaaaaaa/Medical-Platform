import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'admin_constants.dart';

class DoctorDetailsEnhancedScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsEnhancedScreen({
    required this.doctor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = doctor['user'] ?? {};
    final name = doctor['name'] ??
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}';
    final email = doctor['email'] ?? user['email'] ?? '';
    final phone =
        doctor['phone'] ?? user['phone'] ?? user['phone_number'] ?? '';
    final specialization = doctor['specialization'] ?? 'طبيب عام';
    final status = doctor['status'] ?? 'approved';
    final rating = (doctor['rating'] ?? 0.0).toDouble();
    final casesCount = doctor['cases_count'] ?? 0;
    final experienceYears = doctor['experience_years'] ?? 0;
    final licenseNumber = doctor['license_number'] ?? 'غير محدد';
    final country = doctor['country'] ?? 'غير محدد';
    final bio = doctor['bio'] ?? '';
    final profileImage = doctor['profile_image'];
    final licenseImage = doctor['license_image'];
    final isAvailable = doctor['is_available'] ?? true;
    final createdAt = doctor['created_at'] ?? '';
    final totalReviews = doctor['total_reviews'] ?? 0;
    // استخراج بيانات الأسعار من قاعدة البيانات (الحقول الصحيحة)
    double? regularPrice;
    double? emergencyPrice;
    double? followUpPrice;

    // تحويل الأسعار من String إلى double بأمان
    try {
      regularPrice = doctor['consultation_fee'] != null
          ? double.tryParse(doctor['consultation_fee'].toString())
          : null;
      emergencyPrice = doctor['emergency_fee'] != null
          ? double.tryParse(doctor['emergency_fee'].toString())
          : null;
      followUpPrice = doctor['follow_up_fee'] != null
          ? double.tryParse(doctor['follow_up_fee'].toString())
          : null;
    } catch (e) {
      print('خطأ في تحويل الأسعار: $e');
    }

    // تحويل القيم إلى نصوص مع التأكد من عدم وجود قيم فارغة
    final consultationFee = regularPrice != null && regularPrice > 0
        ? regularPrice.toStringAsFixed(0)
        : 'غير محدد';
    final emergencyFee = emergencyPrice != null && emergencyPrice > 0
        ? emergencyPrice.toStringAsFixed(0)
        : 'غير محدد';
    final followUpFee = followUpPrice != null && followUpPrice > 0
        ? followUpPrice.toStringAsFixed(0)
        : 'غير محدد';
    final currency = doctor['currency'] ?? 'SAR';
    final acceptsInsurance = doctor['accepts_insurance'] ?? false;

    // قائمة الحالات الطبية للطبيب
    final List<dynamic> doctorCases = doctor['doctor_cases'] ?? [];
    // قائمة ردود الطبيب
    final List<dynamic> doctorResponses = doctor['doctor_responses'] ?? [];

    return Scaffold(
      backgroundColor: AdminConstants.softBg,
      appBar: AppBar(
        title: Text('ملف الطبيب: د. $name'),
        backgroundColor: AdminConstants.darkBlue,
        foregroundColor: Colors.white,
        actions: [
          // زر العودة للأطباء
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          // زر تعديل البيانات
          if (status != 'pending')
            IconButton(
              onPressed: () {
                // TODO: الانتقال لصفحة تعديل بيانات الطبيب
              },
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AdminConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الطبيب الشخصية
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: AdminConstants.borderRadiusMedium,
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AdminConstants.paddingMedium),
                child: Column(
                  children: [
                    // صورة الطبيب
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AdminConstants.darkBlue,
                        backgroundImage: profileImage != null
                            ? CachedNetworkImageProvider(
                                profileImage,
                              )
                            : null,
                        child: profileImage == null
                            ? Text(
                                name.isNotEmpty ? name[0] : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: AdminConstants.spacingMedium),

                    // اسم الطبيب
                    Center(
                      child: Text(
                        'د. $name',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AdminConstants.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AdminConstants.spacingSmall),

                    // التخصص
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AdminConstants.darkBlue.withOpacity(0.1),
                          borderRadius: AdminConstants.borderRadiusLarge,
                        ),
                        child: Text(
                          specialization,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AdminConstants.darkBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AdminConstants.spacingMedium),

                    // معلومات الاتصال
                    _buildInfoRow('البريد الإلكتروني', email),
                    _buildInfoRow('رقم الهاتف', phone),
                    _buildInfoRow('البلد', country),
                    _buildInfoRow('سنوات الخبرة', '$experienceYears سنة'),
                    _buildInfoRow('رقم الترخيص', licenseNumber),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AdminConstants.spacingMedium),

            // الأسعار والرسوم
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: AdminConstants.borderRadiusMedium,
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AdminConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الأسعار والرسوم',
                      style: AdminConstants.title.copyWith(
                        color: AdminConstants.darkBlue,
                      ),
                    ),
                    const SizedBox(height: AdminConstants.spacingMedium),

                    // استشارة عادية
                    _buildPriceRow('استشارة عادية', consultationFee, currency,
                        Icons.medical_services, Colors.green),

                    // استشارة طوارئ
                    if (emergencyFee != 'غير محدد')
                      _buildPriceRow('استشارة طوارئ', emergencyFee, currency,
                          Icons.warning, Colors.red),

                    // استشارة متابعة
                    if (followUpFee != 'غير محدد')
                      _buildPriceRow('استشارة متابعة', followUpFee, currency,
                          Icons.redo, Colors.blue),

                    const Divider(),

                    // العملة
                    Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'العملة: ${_getCurrencyName(currency)}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    // يقبل التأمين
                    if (acceptsInsurance)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.security,
                                color: Colors.blue.shade700, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'يقبل التأمين الطبي',
                              style: TextStyle(
                                  color: Colors.blue.shade700, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AdminConstants.spacingMedium),

            // حالة الطبيب
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: AdminConstants.borderRadiusMedium,
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AdminConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالة الطبيب',
                      style: AdminConstants.title.copyWith(
                        color: AdminConstants.darkBlue,
                      ),
                    ),
                    const SizedBox(height: AdminConstants.spacingMedium),

                    // حالة التفعيل
                    Row(
                      children: [
                        const Text(
                          'حالة التفعيل: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'approved'
                                ? Colors.green.shade100
                                : status == 'pending'
                                    ? Colors.orange.shade100
                                    : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status == 'approved'
                                ? 'معتمد'
                                : status == 'pending'
                                    ? 'قيد المراجعة'
                                    : 'مرفوض',
                            style: TextStyle(
                              color: status == 'approved'
                                  ? Colors.green.shade700
                                  : status == 'pending'
                                      ? Colors.orange.shade700
                                      : Colors.red.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AdminConstants.spacingSmall),

                    // متاح للاستشارات
                    Row(
                      children: [
                        const Text(
                          'متاح للاستشارات: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green.shade100
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAvailable ? 'متاح' : 'غير متاح',
                            style: TextStyle(
                              color: isAvailable
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AdminConstants.spacingSmall),

                    // التقييم
                    Row(
                      children: [
                        const Text(
                          'التقييم: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rating/5 ($totalReviews تقييم)',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    const SizedBox(height: AdminConstants.spacingSmall),

                    // تاريخ التسجيل
                    Row(
                      children: [
                        const Text(
                          'تاريخ التسجيل: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          createdAt.isNotEmpty
                              ? _formatDate(createdAt)
                              : 'غير محدد',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AdminConstants.spacingMedium),

            // إجراءات المراجعة (للأطباء المعلقين فقط)
            if (status == 'pending')
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: AdminConstants.borderRadiusMedium,
                ),
                elevation: 2,
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(AdminConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجراءات المراجعة',
                        style: AdminConstants.title.copyWith(
                          color: Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: AdminConstants.spacingSmall),
                      const Text(
                        'هذا الطبيب في انتظار المراجعة والموافقة. يرجى مراجعة جميع البيانات والمستندات قبل اتخاذ القرار.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: AdminConstants.spacingMedium),

                      // أزرار الإجراءات
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: تنفيذ الموافقة على الطبيب
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('الموافقة على الطبيب'),
                            ),
                          ),
                          const SizedBox(width: AdminConstants.spacingMedium),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: تنفيذ رفض الطبيب
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('رفض الطبيب'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AdminConstants.spacingMedium),

            // نبذة عن الطبيب
            if (bio.isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: AdminConstants.borderRadiusMedium,
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AdminConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نبذة عن الطبيب',
                        style: AdminConstants.title.copyWith(
                          color: AdminConstants.darkBlue,
                        ),
                      ),
                      const SizedBox(height: AdminConstants.spacingSmall),
                      Text(
                        bio,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AdminConstants.spacingMedium),

            // صورة الترخيص
            if (licenseImage != null && licenseImage.toString().isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: AdminConstants.borderRadiusMedium,
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AdminConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صورة الترخيص',
                        style: AdminConstants.title.copyWith(
                          color: AdminConstants.darkBlue,
                        ),
                      ),
                      const SizedBox(height: AdminConstants.spacingSmall),
                      GestureDetector(
                        onTap: () => _showImageDialog(context, licenseImage),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: AdminConstants.borderRadiusSmall,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: AdminConstants.borderRadiusSmall,
                            child: CachedNetworkImage(
                              imageUrl: licenseImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(Icons.error, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AdminConstants.spacingSmall),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showImageDialog(context, licenseImage),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('فتح في نافذة جديدة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AdminConstants.spacingMedium),

            // الحالات الأخيرة
            if (doctorCases.isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: AdminConstants.borderRadiusMedium,
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AdminConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الحالات الأخيرة (${doctorCases.length})',
                        style: AdminConstants.title.copyWith(
                          color: AdminConstants.darkBlue,
                        ),
                      ),
                      const SizedBox(height: AdminConstants.spacingSmall),

                      // جدول الحالات
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 12,
                          headingTextStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          columns: const [
                            DataColumn(label: Text('رقم الحالة')),
                            DataColumn(label: Text('المريض')),
                            DataColumn(label: Text('العنوان')),
                            DataColumn(label: Text('الحالة')),
                            DataColumn(label: Text('التاريخ')),
                            DataColumn(label: Text('الإجراءات')),
                          ],
                          rows: List<DataRow>.generate(
                            doctorCases.length > 5 ? 5 : doctorCases.length,
                            (index) {
                              final caseItem = doctorCases[index];
                              final patient = caseItem['patient'] ?? {};
                              final patientUser = patient['user'] ?? {};
                              final patientName = patientUser[
                                      'get_full_name'] ??
                                  '${patientUser['first_name'] ?? ''} ${patientUser['last_name'] ?? ''}';
                              final caseStatus =
                                  caseItem['status'] ?? 'pending';
                              final caseDate = caseItem['created_at'] ?? '';

                              return DataRow(
                                cells: [
                                  DataCell(Text('#${caseItem['id'] ?? ''}')),
                                  DataCell(Text(patientName)),
                                  DataCell(
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        caseItem['title'] ?? '',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(_buildStatusBadge(caseStatus)),
                                  DataCell(Text(caseDate.isNotEmpty
                                      ? _formatDate(caseDate)
                                      : '')),
                                  DataCell(
                                    IconButton(
                                      onPressed: () {
                                        // TODO: الانتقال لصفحة تفاصيل الحالة
                                      },
                                      icon: const Icon(Icons.visibility),
                                      tooltip: 'عرض التفاصيل',
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      if (doctorCases.length > 5)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: عرض جميع الحالات
                            },
                            child: const Text('عرض جميع الحالات'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AdminConstants.spacingMedium),

            // الردود الأخيرة
            if (doctorResponses.isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: AdminConstants.borderRadiusMedium,
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AdminConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الردود الأخيرة (${doctorResponses.length})',
                        style: AdminConstants.title.copyWith(
                          color: AdminConstants.darkBlue,
                        ),
                      ),
                      const SizedBox(height: AdminConstants.spacingSmall),

                      // قائمة الردود
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: doctorResponses.length > 3
                            ? 3
                            : doctorResponses.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final response = doctorResponses[index];
                          final medicalCase = response['medical_case'] ?? {};
                          final patient = medicalCase['patient'] ?? {};
                          final patientUser = patient['user'] ?? {};
                          final patientName = patientUser['get_full_name'] ??
                              '${patientUser['first_name'] ?? ''} ${patientUser['last_name'] ?? ''}';
                          final responseDate = response['created_at'] ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        medicalCase['title'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      responseDate.isNotEmpty
                                          ? _formatDate(responseDate)
                                          : '',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'المريض: $patientName',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'التشخيص: ${response['diagnosis'] ?? ''}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // TODO: الانتقال لصفحة تفاصيل الرد
                                      },
                                      icon: const Icon(Icons.visibility),
                                      label: const Text('عرض التفاصيل'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      if (doctorResponses.length > 3)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: عرض جميع الردود
                            },
                            child: const Text('عرض جميع الردود'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminConstants.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AdminConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AdminConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
      String label, String price, String currency, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              price == 'غير محدد' ? price : '$price $currency',
              style: TextStyle(
                color: price == 'غير محدد' ? Colors.grey : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'قيد الانتظار';
        break;
      case 'in_progress':
        color = Colors.blue;
        text = 'قيد المراجعة';
        break;
      case 'completed':
        color = Colors.green;
        text = 'مكتملة';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('صورة الترخيص الطبي'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AdminConstants.paddingMedium),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.grey,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencyName(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'SAR':
        return 'ريال سعودي';
      case 'USD':
        return 'دولار أمريكي';
      case 'EUR':
        return 'يورو';
      case 'AED':
        return 'درهم إماراتي';
      case 'KWD':
        return 'دينار كويتي';
      case 'QAR':
        return 'ريال قطري';
      case 'BHD':
        return 'دينار بحريني';
      case 'OMR':
        return 'ريال عماني';
      case 'JOD':
        return 'دينار أردني';
      case 'EGP':
        return 'جنيه مصري';
      default:
        return currencyCode;
    }
  }
}
