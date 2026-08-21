import 'package:flutter/material.dart';
import 'package:doctor_app/utils/app_theme.dart';
import 'package:doctor_app/screens/patient/cases/create_case_screen.dart';
import 'package:doctor_app/screens/patient/dashboard/professional_patient_dashboard.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  static const Color _orange = Color(0xFFFF7A00);
  static const Color _blue = AppTheme.primaryBlue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _blue,
        title: const Text('الصفحة الرئيسية للمريض',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProfessionalPatientDashboard()));
            },
            icon: const Icon(Icons.dashboard_customize_outlined),
            label: const Text('لوحة التحكم'),
            style: TextButton.styleFrom(foregroundColor: _blue),
          ),
          IconButton(
            tooltip: 'الرئيسية',
            icon: const Icon(Icons.home_rounded),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              // يربط بزر الخروج لديك إن وجد
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
      body: const SafeArea(child: _HomeBody()),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  static const Color _orange = Color(0xFFFF7A00);
  static const Color _blue = AppTheme.primaryBlue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقة تعريفية باستيل
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE9D9), // باستيل برتقالي فاتح
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child:
                            Icon(Icons.health_and_safety_rounded, color: _blue),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'مرحباً بك! هذا التطبيق يساعدك على إنشاء حالات طبية ومتابعة الردود بشكل سهل وبسيط.',
                          style:
                              TextStyle(color: Color(0xFF475467), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // الأزرار الدائرية الرئيسية
                Row(
                  children: [
                    Expanded(
                      child: _CircleAction(
                        color: _orange,
                        icon: Icons.add_box_rounded,
                        label: 'إنشاء حالة جديدة',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CreateCaseScreen()));
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _CircleAction(
                        color: _blue,
                        icon: Icons.dashboard_rounded,
                        label: 'الانتقال إلى لوحة التحكم',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ProfessionalPatientDashboard()));
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // فوتر بثلاثة أزرار صغيرة
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MiniPill(
                        icon: Icons.info_outline_rounded,
                        label: 'من نحن',
                        onTap: () {}),
                    _MiniPill(
                        icon: Icons.call_rounded,
                        label: 'تواصل معنا',
                        onTap: () {}),
                    _MiniPill(
                        icon: Icons.help_outline_rounded,
                        label: 'الأسئلة الشائعة',
                        onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CircleAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CircleAction(
      {required this.color,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF101828)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MiniPill(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: AppTheme.primaryBlue),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF475467))),
        ]),
      ),
    );
  }
}
