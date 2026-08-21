import 'package:flutter/material.dart';
import '../../../services/doctor_api_service.dart';
import '../../../services/api_service.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  Map<String, dynamic>? _earnings;
  List<dynamic>? _completedCases;
  bool _loading = true;
  String? _error;
  double _totalEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    _loadEarningsAndCases();
  }

  Future<void> _loadEarningsAndCases() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // جلب بيانات الأرباح
      final earningsData = await DoctorApiService.getEarnings();

      // جلب الحالات المكتملة لحساب الأرباح الإجمالية
      final casesData = await ApiService.getDoctorCompletedCases();

      // حساب إجمالي الأرباح من الحالات المكتملة
      double total = 0.0;
      for (var caseItem in casesData) {
        if (caseItem is Map<String, dynamic>) {
          final price = caseItem['price'] ?? caseItem['fee'] ?? 0;
          if (price is num) {
            total += price.toDouble();
          } else if (price is String) {
            total += double.tryParse(price) ?? 0.0;
          }
        }
      }

      setState(() {
        _earnings = earningsData;
        _completedCases = casesData;
        _totalEarnings = total;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أرباحي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEarningsAndCases,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _loadEarningsAndCases,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // بطاقة إجمالي الأرباح المحسوبة من الحالات
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.monetization_on, color: Colors.green, size: 28),
                                  SizedBox(width: 12),
                                  Text(
                                    'إجمالي الأرباح من الاستشارات',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${_totalEarnings.toStringAsFixed(2)} ريال',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'من ${_completedCases?.length ?? 0} حالة مكتملة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(),

                      ListTile(
                        leading: const Icon(Icons.account_balance_wallet_outlined),
                        title: const Text('إجمالي الأرباح (من النظام)'),
                        trailing: Text('${_earnings?['total_earnings'] ?? 0}'),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.savings_outlined),
                        title: const Text('الرصيد المتاح'),
                        trailing: Text('${_earnings?['available_balance'] ?? 0}'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.timelapse_outlined),
                        title: const Text('الرصيد المعلق'),
                        trailing: Text('${_earnings?['pending_balance'] ?? 0}'),
                      ),
                      const Divider(),
                      const ListTile(
                        leading: Icon(Icons.payment_outlined),
                        title: Text('آخر عمليات السحب'),
                        subtitle: Text('سيتم عرضها هنا عند ربط الخدمة'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
