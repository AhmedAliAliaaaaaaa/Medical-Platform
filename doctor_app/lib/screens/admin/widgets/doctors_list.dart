
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../admin_constants.dart';
import 'doctor_card.dart';
import 'admin_loading_error_widgets.dart';

class DoctorsList extends StatelessWidget {
  final List<dynamic> doctors;
  final bool isApproved;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final Function(Map<String, dynamic>) onViewDetails;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onToggleStatus;
  final Function(Map<String, dynamic>) onDelete;
  final Function(Map<String, dynamic>) onApprove;
  final Function(Map<String, dynamic>) onReject;
  final Function(String) onSearchChanged;

  const DoctorsList({
    required this.doctors,
    required this.isApproved,
    required this.isLoading,
    this.errorMessage,
    required this.searchQuery,
    required this.onViewDetails,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onApprove,
    required this.onReject,
    required this.onSearchChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تطبيق البحث
    List<dynamic> filteredDoctors = doctors;
    if (searchQuery.isNotEmpty) {
      filteredDoctors = doctors.where((doctor) {
        final name = (doctor['name'] ?? doctor['user']?['first_name'] ?? '')
            .toString()
            .toLowerCase();
        final email = (doctor['email'] ?? doctor['user']?['email'] ?? '')
            .toString()
            .toLowerCase();
        final specialization =
            (doctor['specialization'] ?? '').toString().toLowerCase();
        final query = searchQuery.toLowerCase();
        return name.contains(query) ||
            email.contains(query) ||
            specialization.contains(query);
      }).toList();
    }

    if (isLoading) {
      return const AdminLoadingWidget();
    }

    if (errorMessage != null) {
      return AdminErrorWidget(
        errorMessage: errorMessage,
        onRetry: () {
          // سيتم تحديث القائمة من الشاشة الأم
        },
      );
    }

    if (filteredDoctors.isEmpty) {
      return AdminEmptyWidget(
        message: searchQuery.isNotEmpty
            ? 'لا توجد نتائج للبحث'
            : isApproved
                ? 'لا يوجد أطباء معتمدين'
                : 'لا توجد طلبات معلقة',
        icon: isApproved ? Icons.medical_services : Icons.pending_actions,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // سيتم تحديث القائمة من الشاشة الأم
      },
      child: ListView(
        padding: const EdgeInsets.all(AdminConstants.paddingMedium),
        children: [
          // شريط البحث
          _buildSearchBar(),
          const SizedBox(height: AdminConstants.spacingMedium),

          // جدول الأطباء
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: AdminConstants.borderRadiusMedium,
            ),
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AdminConstants.paddingMedium),
                  child: Row(
                    children: [
                      Icon(
                        isApproved ? Icons.verified_user : Icons.pending_actions,
                        color: isApproved ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: AdminConstants.spacingSmall),
                      Text(
                        isApproved ? 'الأطباء المعتمدون' : 'طلبات الأطباء المعلقة',
                        style: AdminConstants.title,
                      ),
                      const Spacer(),
                      if (!isApproved)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: AdminConstants.borderRadiusSmall,
                          ),
                          child: Text(
                            '${filteredDoctors.length}',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDoctors.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    indent: AdminConstants.paddingMedium,
                    endIndent: AdminConstants.paddingMedium,
                  ),
                  itemBuilder: (context, index) {
                    final doctor = filteredDoctors[index];
                    return DoctorCard(
                      doctor: doctor,
                      isApproved: isApproved,
                      onViewDetails: () => onViewDetails(doctor),
                      onEdit: () => onEdit(doctor),
                      onToggleStatus: () => onToggleStatus(doctor),
                      onDelete: () => onDelete(doctor),
                      onApprove: () => onApprove(doctor),
                      onReject: () => onReject(doctor),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminConstants.paddingMedium,
        vertical: AdminConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AdminConstants.card,
        borderRadius: AdminConstants.borderRadiusMedium,
        boxShadow: AdminConstants.shadowSoft,
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade500),
          const SizedBox(width: AdminConstants.spacingSmall),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: isApproved ? 'بحث في الأطباء...' : 'بحث في الطلبات...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                onSearchChanged('');
              },
              icon: Icon(Icons.clear, color: Colors.grey.shade500),
            ),
        ],
      ),
    );
  }
}
