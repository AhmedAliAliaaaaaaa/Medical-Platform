/// Central exports for Patient and Doctor screens
/// Grouped to simplify imports and keep structure organized without moving files.

// ===================== PATIENT SCREENS =====================
export 'patient/dashboard/professional_patient_dashboard.dart';

// Patient Cases
export 'patient/cases/create_case_screen.dart';
export 'patient/cases/cases_list_screen.dart';
export 'cases/case_details_screen.dart';

// Patient Doctors (browse/select doctor)
export 'patient/doctors/doctor_list_screen.dart';
export 'patient/doctors/enhanced_doctor_list.dart';

// Patient Notifications & Profile
export 'notifications/notifications_screen.dart';
export 'profile/profile_screen.dart';

// Patient Rating / Reviews (if used)
export 'patient/rating/rate_doctor_screen.dart';
export 'patient/reviews/reviews_screen.dart';

// Patient Payment
export 'patient/payment/payment_screen.dart';


// ===================== DOCTOR SCREENS =====================
export 'doctor/dashboard/doctor_dashboard.dart';

// Doctor Cases
export 'cases/respond_to_case_screen.dart';
export 'cases/case_details_screen.dart';

// Doctor Profile & Analytics
export 'doctor/profile/doctor_profile_screen.dart';
export 'analytics/analytics_screen.dart';
export 'appointments/appointments_screen.dart';
export 'search/advanced_search_screen.dart';

// ===================== AUTH COMMONS =====================
export 'auth/login_screen.dart';
export 'auth/register_screen.dart';
export 'auth/doctor_registration_screen.dart';
export 'auth/pending_approval_screen.dart';

// ===================== MISC =====================
export 'main_navigation.dart';
