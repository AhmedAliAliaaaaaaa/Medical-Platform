import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _ratings = const {};

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
      final data = await ApiService.getDoctorRatings();
      setState(() {
        _ratings = data;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final average =
        (_ratings['average_rating'] ?? _ratings['rating'] ?? 0).toString();
    final total = (_ratings['total_ratings'] ?? _ratings['total_reviews'] ?? 0)
        .toString();
    final list = List<Map<String, dynamic>>.from(
        _ratings['ratings'] ?? _ratings['recent_reviews'] ?? []);

    return Scaffold(
      appBar: AppBar(title: const Text('تقييمي')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 30),
                          const SizedBox(width: 8),
                          Text('$average / 5'),
                          const Spacer(),
                          Text('إجمالي المراجعات: $total'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (list.isEmpty)
                        const Center(child: Text('لا توجد تقييمات بعد'))
                      else
                        ...list.map((r) {
                          final rating = r['rating']?.toString() ?? '-';
                          final comment = r['comment']?.toString() ?? '';
                          final patient = r['patient_name']?.toString() ?? '';
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: Text('التقييم: $rating'),
                              subtitle: Text(
                                  comment.isEmpty ? 'بدون تعليق' : comment),
                              trailing: Text(patient),
                            ),
                          );
                        }),
                    ],
                  ),
      ),
    );
  }
}
