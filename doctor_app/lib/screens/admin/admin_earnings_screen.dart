import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';

class AdminEarningsScreen extends StatefulWidget {
  const AdminEarningsScreen({super.key});

  @override
  State<AdminEarningsScreen> createState() => _AdminEarningsScreenState();
}

class _AdminEarningsScreenState extends State<AdminEarningsScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AdminApiService.getEarnings();
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _updateWithdrawal(int id, String action) async {
    await AdminApiService.updateEarnings(action: action, withdrawalId: id);
    await _load();
  }

  Future<void> _saveSettings() async {
    final settings = Map<String, dynamic>.from(
      (_data?['settings'] as Map?)?.cast<String, dynamic>() ?? {},
    );
    await AdminApiService.updateEarnings(
      action: 'save_settings',
      settings: settings,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ إعدادات الأرباح')),
      );
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final summary = (_data?['summary'] as Map?)?.cast<String, dynamic>() ?? {};
    final settings = (_data?['settings'] as Map?)?.cast<String, dynamic>() ?? {};
    final withdrawals = (_data?['withdrawals'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الأرباح')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _summaryCard('إجمالي المدفوعات', summary['total_revenue']),
                      _summaryCard('الرصيد المتاح للأطباء', summary['total_available_balance']),
                      _summaryCard('المبالغ المسحوبة', summary['total_withdrawn']),
                      _summaryCard('طلبات السحب المعلقة', summary['pending_withdrawals']),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('إعدادات المنصة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              _settingField(settings, 'platform_commission_rate', 'عمولة المنصة %'),
                              _settingField(settings, 'minimum_withdrawal_amount', 'الحد الأدنى للسحب'),
                              _settingField(settings, 'default_consultation_fee', 'الاستشارة العادية'),
                              _settingField(settings, 'default_follow_up_fee', 'المتابعة'),
                              _settingField(settings, 'default_emergency_fee', 'الطوارئ'),
                              ElevatedButton(onPressed: _saveSettings, child: const Text('حفظ الإعدادات')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Column(
                          children: [
                            const ListTile(title: Text('طلبات السحب', style: TextStyle(fontWeight: FontWeight.bold))),
                            ...withdrawals.map((raw) {
                              final item = (raw as Map).cast<String, dynamic>();
                              return ListTile(
                                title: Text('${item['doctor']} - ${item['amount']} ريال'),
                                subtitle: Text(item['status_display'] ?? item['status'] ?? ''),
                                trailing: item['status'] == 'pending'
                                    ? Wrap(spacing: 4, children: [
                                        IconButton(onPressed: () => _updateWithdrawal(item['id'], 'approve'), icon: const Icon(Icons.check, color: Colors.green)),
                                        IconButton(onPressed: () => _updateWithdrawal(item['id'], 'reject'), icon: const Icon(Icons.close, color: Colors.red)),
                                      ])
                                    : null,
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _summaryCard(String title, dynamic value) => Card(
        child: ListTile(
          leading: const Icon(Icons.monetization_on, color: Colors.teal),
          title: Text(title),
          trailing: Text('$value'),
        ),
      );

  Widget _settingField(Map<String, dynamic> settings, String key, String label) {
    return TextFormField(
      initialValue: '${settings[key] ?? 0}',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      onChanged: (value) => settings[key] = double.tryParse(value) ?? settings[key],
    );
  }
}
