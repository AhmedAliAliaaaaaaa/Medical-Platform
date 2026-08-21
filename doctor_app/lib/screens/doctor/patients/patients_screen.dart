import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _patients = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getPatients();
      setState(() => _patients = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مرضاي')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _patients.isEmpty
                    ? const Center(child: Text('لا يوجد مرضى حالياً'))
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        itemCount: _patients.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final p =
                              Map<String, dynamic>.from(_patients[i] as Map);
                          final name =
                              (p['name'] ?? p['patient_name'] ?? 'مريض')
                                  .toString();
                          final id = (p['id'] ?? '').toString();
                          return ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            leading:
                                const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(name),
                            subtitle: Text('ID: $id'),
                          );
                        },
                      ),
      ),
    );
  }
}
