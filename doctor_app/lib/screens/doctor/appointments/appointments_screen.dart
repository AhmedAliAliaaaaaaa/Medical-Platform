import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:doctor_app/providers/language_provider.dart';
import 'package:doctor_app/core/theme/app_theme.dart';
import 'package:doctor_app/widgets/enhanced_card.dart';
import 'package:doctor_app/widgets/enhanced_buttons.dart';
import 'package:doctor_app/models/doctor.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<Appointment> _appointments = [];
  List<Appointment> _selectedDayAppointments = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _loadAppointments();
    _updateSelectedDayAppointments();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadAppointments() {
    setState(() {
      _isLoading = true;
    });

    // Mock appointments - replace with actual API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _appointments = [
            Appointment(
              id: '1',
              doctorName: 'د. أحمد محمد',
              doctorSpecialization: 'طب الباطنة',
              date: DateTime.now().add(const Duration(days: 1)),
              time: const TimeOfDay(hour: 10, minute: 0),
              status: AppointmentStatus.confirmed,
              type: AppointmentType.consultation,
              fee: 150.0,
              currency: 'SAR',
            ),
            Appointment(
              id: '2',
              doctorName: 'د. فاطمة علي',
              doctorSpecialization: 'طب الأطفال',
              date: DateTime.now().add(const Duration(days: 3)),
              time: const TimeOfDay(hour: 14, minute: 30),
              status: AppointmentStatus.pending,
              type: AppointmentType.followUp,
              fee: 100.0,
              currency: 'SAR',
            ),
            Appointment(
              id: '3',
              doctorName: 'د. محمد حسن',
              doctorSpecialization: 'طب القلب',
              date: DateTime.now().subtract(const Duration(days: 2)),
              time: const TimeOfDay(hour: 9, minute: 0),
              status: AppointmentStatus.completed,
              type: AppointmentType.consultation,
              fee: 200.0,
              currency: 'SAR',
            ),
            Appointment(
              id: '4',
              doctorName: 'د. سارة أحمد',
              doctorSpecialization: 'طب النساء',
              date: DateTime.now().add(const Duration(days: 7)),
              time: const TimeOfDay(hour: 16, minute: 0),
              status: AppointmentStatus.confirmed,
              type: AppointmentType.emergency,
              fee: 300.0,
              currency: 'SAR',
            ),
          ];
          _isLoading = false;
        });
        _updateSelectedDayAppointments();
      }
    });
  }

  void _updateSelectedDayAppointments() {
    setState(() {
      _selectedDayAppointments =
          _appointments
              .where((appointment) => isSameDay(appointment.date, _selectedDay))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    final filteredAppointments = _getFilteredAppointments();

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(isRTL ? 'المواعيد' : 'Appointments'),
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'all',
                    child: Text(isRTL ? 'الكل' : 'All'),
                  ),
                  PopupMenuItem(
                    value: 'upcoming',
                    child: Text(isRTL ? 'القادمة' : 'Upcoming'),
                  ),
                  PopupMenuItem(
                    value: 'completed',
                    child: Text(isRTL ? 'المكتملة' : 'Completed'),
                  ),
                  PopupMenuItem(
                    value: 'cancelled',
                    child: Text(isRTL ? 'الملغية' : 'Cancelled'),
                  ),
                ],
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () async {
                _loadAppointments();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Calendar
                    _buildCalendar(isRTL),

                    // Quick Stats
                    _buildQuickStats(isRTL),

                    // Selected Day Appointments
                    if (_selectedDayAppointments.isNotEmpty)
                      _buildSelectedDayAppointments(isRTL),

                    // All Appointments List
                    _buildAppointmentsList(filteredAppointments, isRTL),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookAppointmentDialog(isRTL),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: AppTheme.textLight),
        label: Text(
          isRTL ? 'حجز موعد' : 'Book Appointment',
          style: const TextStyle(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(bool isRTL) {
    return EnhancedCard(
      margin: const EdgeInsets.all(20),
      child: TableCalendar<Appointment>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: (day) {
          return _appointments
              .where((appointment) => isSameDay(appointment.date, day))
              .toList();
        },
        startingDayOfWeek: StartingDayOfWeek.saturday,
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppTheme.warningYellow,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _updateSelectedDayAppointments();
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildQuickStats(bool isRTL) {
    final upcomingCount =
        _appointments
            .where(
              (a) =>
                  a.date.isAfter(DateTime.now()) &&
                  a.status != AppointmentStatus.cancelled,
            )
            .length;
    final completedCount =
        _appointments
            .where((a) => a.status == AppointmentStatus.completed)
            .length;
    final pendingCount =
        _appointments
            .where((a) => a.status == AppointmentStatus.pending)
            .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: isRTL ? 'القادمة' : 'Upcoming',
              value: upcomingCount.toString(),
              icon: Icons.schedule,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: isRTL ? 'مكتملة' : 'Completed',
              value: completedCount.toString(),
              icon: Icons.check_circle,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: isRTL ? 'في الانتظار' : 'Pending',
              value: pendingCount.toString(),
              icon: Icons.hourglass_empty,
              color: AppTheme.warningYellow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayAppointments(bool isRTL) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${isRTL ? 'مواعيد يوم' : 'Appointments for'} ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ..._selectedDayAppointments.map((appointment) {
            return _buildAppointmentCard(appointment, isRTL, isCompact: true);
          }),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments, bool isRTL) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRTL ? 'جميع المواعيد' : 'All Appointments',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (_selectedFilter != 'all')
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'all';
                    });
                  },
                  child: Text(isRTL ? 'عرض الكل' : 'Show All'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (appointments.isEmpty)
            _buildEmptyState(isRTL)
          else
            ...appointments.map((appointment) {
              return _buildAppointmentCard(appointment, isRTL);
            }),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
    Appointment appointment,
    bool isRTL, {
    bool isCompact = false,
  }) {
    return EnhancedCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _showAppointmentDetails(appointment, isRTL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Doctor Avatar
              CircleAvatar(
                radius: isCompact ? 20 : 25,
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  appointment.doctorName.substring(2, 3), // Skip "د."
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: isCompact ? 16 : 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Appointment Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: TextStyle(
                        fontSize: isCompact ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.doctorSpecialization,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isCompact) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(appointment.date),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.time.format(context),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Status and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        appointment.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(appointment.status, isRTL),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(appointment.status),
                      ),
                    ),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${appointment.fee} ${appointment.currency}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          if (!isCompact &&
              appointment.status == AppointmentStatus.confirmed) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: isRTL ? 'إلغاء' : 'Cancel',
                    onPressed: () => _cancelAppointment(appointment, isRTL),
                    height: 36,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: isRTL ? 'إعادة جدولة' : 'Reschedule',
                    onPressed: () => _rescheduleAppointment(appointment, isRTL),
                    height: 36,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isRTL) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isRTL ? 'لا توجد مواعيد' : 'No appointments',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRTL
                ? 'احجز موعدك الأول مع طبيب'
                : 'Book your first appointment with a doctor',
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  List<Appointment> _getFilteredAppointments() {
    switch (_selectedFilter) {
      case 'upcoming':
        return _appointments
            .where(
              (a) =>
                  a.date.isAfter(DateTime.now()) &&
                  a.status != AppointmentStatus.cancelled,
            )
            .toList();
      case 'completed':
        return _appointments
            .where((a) => a.status == AppointmentStatus.completed)
            .toList();
      case 'cancelled':
        return _appointments
            .where((a) => a.status == AppointmentStatus.cancelled)
            .toList();
      default:
        return _appointments;
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return AppTheme.primaryGreen;
      case AppointmentStatus.pending:
        return AppTheme.warningYellow;
      case AppointmentStatus.completed:
        return AppTheme.primaryBlue;
      case AppointmentStatus.cancelled:
        return AppTheme.dangerRed;
    }
  }

  String _getStatusText(AppointmentStatus status, bool isRTL) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return isRTL ? 'مؤكد' : 'Confirmed';
      case AppointmentStatus.pending:
        return isRTL ? 'في الانتظار' : 'Pending';
      case AppointmentStatus.completed:
        return isRTL ? 'مكتمل' : 'Completed';
      case AppointmentStatus.cancelled:
        return isRTL ? 'ملغي' : 'Cancelled';
    }
  }

  void _showAppointmentDetails(Appointment appointment, bool isRTL) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isRTL ? 'تفاصيل الموعد' : 'Appointment Details',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                isRTL ? 'الطبيب' : 'Doctor',
                appointment.doctorName,
                Icons.person,
              ),
              _buildDetailRow(
                isRTL ? 'التخصص' : 'Specialization',
                appointment.doctorSpecialization,
                Icons.medical_services,
              ),
              _buildDetailRow(
                isRTL ? 'التاريخ' : 'Date',
                DateFormat('MMM dd, yyyy').format(appointment.date),
                Icons.calendar_today,
              ),
              _buildDetailRow(
                isRTL ? 'الوقت' : 'Time',
                appointment.time.format(context),
                Icons.access_time,
              ),
              _buildDetailRow(
                isRTL ? 'النوع' : 'Type',
                _getTypeText(appointment.type, isRTL),
                Icons.category,
              ),
              _buildDetailRow(
                isRTL ? 'الرسوم' : 'Fee',
                '${appointment.fee} ${appointment.currency}',
                Icons.attach_money,
              ),
              _buildDetailRow(
                isRTL ? 'الحالة' : 'Status',
                _getStatusText(appointment.status, isRTL),
                Icons.info,
                color: _getStatusColor(appointment.status),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'إغلاق' : 'Close',
                style: const TextStyle(color: AppTheme.primaryBlue),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color ?? AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeText(AppointmentType type, bool isRTL) {
    switch (type) {
      case AppointmentType.consultation:
        return isRTL ? 'استشارة' : 'Consultation';
      case AppointmentType.followUp:
        return isRTL ? 'متابعة' : 'Follow-up';
      case AppointmentType.emergency:
        return isRTL ? 'طارئ' : 'Emergency';
    }
  }

  void _showBookAppointmentDialog(bool isRTL) {
    // Navigate to doctor selection or booking screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL
              ? 'سيتم توجيهك لصفحة حجز الموعد'
              : 'You will be redirected to booking page',
        ),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _cancelAppointment(Appointment appointment, bool isRTL) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isRTL ? 'إلغاء الموعد' : 'Cancel Appointment',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            isRTL
                ? 'هل أنت متأكد من إلغاء هذا الموعد؟'
                : 'Are you sure you want to cancel this appointment?',
            style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'لا' : 'No',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  appointment.status = AppointmentStatus.cancelled;
                });
                Navigator.of(context).pop();
                _updateSelectedDayAppointments();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isRTL ? 'تم إلغاء الموعد' : 'Appointment cancelled',
                    ),
                    backgroundColor: AppTheme.dangerRed,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isRTL ? 'نعم، إلغاء' : 'Yes, Cancel',
                style: const TextStyle(color: AppTheme.textLight),
              ),
            ),
          ],
        );
      },
    );
  }

  void _rescheduleAppointment(Appointment appointment, bool isRTL) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL
              ? 'ميزة إعادة الجدولة قريباً'
              : 'Reschedule feature coming soon',
        ),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }
}

// Appointment Model
class Appointment {
  final String id;
  final String doctorName;
  final String doctorSpecialization;
  final DateTime date;
  final TimeOfDay time;
  AppointmentStatus status;
  final AppointmentType type;
  final double fee;
  final String currency;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.date,
    required this.time,
    required this.status,
    required this.type,
    required this.fee,
    required this.currency,
  });
}

enum AppointmentStatus { pending, confirmed, completed, cancelled }

enum AppointmentType { consultation, followUp, emergency }
