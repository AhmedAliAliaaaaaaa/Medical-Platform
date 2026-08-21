
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../admin_constants.dart';

class DoctorDetails extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetails({
    required this.doctor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = doctor['user'] ?? {};
    final name = doctor['name'] ??
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}';
    final email = doctor['email'] ?? user['email'] ?? '';
    final phone = doctor['phone'] ?? user['phone'] ?? '';
    final specialization = doctor['specialization'] ?? 'طبيب عام';
    final status = doctor['status'] ?? 'approved';
    final rating = doctor['rating'] ?? 0.0;
    final casesCount = doctor['cases_count'] ?? 0;
    final experienceYears = doctor['experience_years'] ?? 0;
    final licenseNumber = doctor['license_number'] ?? 'غير محدد';
    final country = doctor['country'] ?? 'غير محدد';
    final bio = doctor['bio'] ?? '';
    final profileImage = doctor['profile_image'];
    final licenseImage = doctor['license_image'];

    return Scaffold(
      backgroundColor: AdminConstants.softBg,
      appBar: AppBar(
        title: Text('تفاصيل الطبيب: $name'),
        backgroundColor: AdminConstants.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AdminConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الطبيب الأساسية
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
                        name,
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
                    _buildInfoRow('الحالة',
                        status == 'approved' ? 'معتمد' : 'قيد المراجعة'),
                    _buildInfoRow('التقييم', rating.toString()),
                    _buildInfoRow('عدد الحالات', casesCount.toString()),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AdminConstants.spacingMedium),

            // معلومات إضافية + جميع الحقول المطلوبة
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
                      'معلومات الترخيص والبيانات',
                      style: AdminConstants.title.copyWith(
                        color: AdminConstants.darkBlue,
                      ),
                    ),
                    const SizedBox(height: AdminConstants.spacingMedium),
                    _buildInfoRow(
                        'الحالة',
                        status == 'approved'
                            ? 'معتمد'
                            : status == 'pending'
                                ? 'قيد المراجعة'
                                : 'مرفوض'),
                    _buildInfoRow('التخصص', specialization),
                    _buildInfoRow('سنوات الخبرة', '$experienceYears سنة'),
                    _buildInfoRow('رقم الترخيص', licenseNumber),
                    _buildInfoRow('البلد', country),
                    // حقول إضافية شائعة لعرضها إن وُجدت
                    if (user['email'] != null)
                      _buildInfoRow('البريد الإلكتروني', email),
                    if (user['phone'] != null || doctor['phone'] != null)
                      _buildInfoRow('رقم الهاتف', phone),
                    _buildInfoRow('التقييم', rating.toString()),
                    _buildInfoRow('عدد الحالات', casesCount.toString()),
                    if (doctor['preferred_language'] != null)
                      _buildInfoRow('اللغة المفضلة',
                          doctor['preferred_language'].toString()),
                    if (doctor['accepts_insurance'] != null)
                      _buildInfoRow(
                          'يقبل التأمين',
                          (doctor['accepts_insurance'] ? 'نعم' : 'لا')
                              .toString()),
                    if (doctor['consultation_fee'] != null)
                      _buildInfoRow('رسوم الاستشارة',
                          doctor['consultation_fee'].toString()),
                    if (doctor['emergency_fee'] != null)
                      _buildInfoRow(
                          'رسوم الطوارئ', doctor['emergency_fee'].toString()),
                    if (doctor['follow_up_fee'] != null)
                      _buildInfoRow('رسوم المتابعة',
                          doctor['follow_up_fee'].toString()),
                    if (doctor['currency'] != null)
                      _buildInfoRow('العملة', doctor['currency'].toString()),
                    if (licenseImage != null && licenseImage.toString().isNotEmpty) ...[
                      const SizedBox(height: AdminConstants.spacingMedium),
                      const Text(
                        'صورة الترخيص:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                    ],
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
}
