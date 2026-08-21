import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/medical_case.dart';
import '../providers/language_provider.dart';

class CaseCard extends StatelessWidget {
  final MedicalCase medicalCase;
  final VoidCallback? onTap;
  final bool showPatientInfo;
  final bool showDoctorInfo;

  const CaseCard({
    super.key,
    required this.medicalCase,
    this.onTap,
    this.showPatientInfo = false,
    this.showDoctorInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor(medicalCase.status).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Priority Indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(medicalCase.priority),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),

                // Case Title
                Expanded(
                  child: Text(
                    medicalCase.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(medicalCase.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(medicalCase.status, isRTL),
                    style: TextStyle(
                      color: _getStatusColor(medicalCase.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              medicalCase.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Patient/Doctor Info
            if (showPatientInfo) ...[
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Text(
                    '${medicalCase.patient.firstName} ${medicalCase.patient.lastName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            if (showDoctorInfo && medicalCase.doctorName != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    medicalCase.doctorName!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Footer Row
            Row(
              children: [
                // Priority Label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(
                      medicalCase.priority,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityText(medicalCase.priority, isRTL),
                    style: TextStyle(
                      color: _getPriorityColor(medicalCase.priority),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Spacer(),

                // Attachments Count
                if (medicalCase.attachments.isNotEmpty) ...[
                  Icon(Icons.attach_file, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${medicalCase.attachments.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 16),
                ],

                // Date
                Text(
                  DateFormat('MMM dd, yyyy').format(medicalCase.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFF59E0B);
      case 'medium':
        return const Color(0xFF3B82F6);
      case 'normal': // backward compatibility
        return const Color(0xFF3B82F6);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, bool isRTL) {
    switch (status) {
      case 'pending':
        return isRTL ? 'في الانتظار' : 'Pending';
      case 'in_progress':
        return isRTL ? 'قيد المعالجة' : 'In Progress';
      case 'completed':
        return isRTL ? 'مكتملة' : 'Completed';
      case 'cancelled':
        return isRTL ? 'ملغية' : 'Cancelled';
      default:
        return status;
    }
  }

  String _getPriorityText(String priority, bool isRTL) {
    switch (priority) {
      case 'urgent':
        return isRTL ? 'عاجل' : 'Urgent';
      case 'high':
        return isRTL ? 'عالي' : 'High';
      case 'medium':
        return isRTL ? 'متوسط' : 'Medium';
      case 'normal': // backward compatibility
        return isRTL ? 'عادي' : 'Normal';
      case 'low':
        return isRTL ? 'منخفض' : 'Low';
      default:
        return priority;
    }
  }
}
