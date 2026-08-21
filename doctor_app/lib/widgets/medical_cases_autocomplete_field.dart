import 'package:flutter/material.dart';
import '../services/doctor_api_service.dart';

/// حقل البحث التلقائي للحالات المرضية الفعلية
class MedicalCasesAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Function(Map<String, dynamic>)? onCaseSelected;
  final bool showRecentCases;

  const MedicalCasesAutocompleteField({
    super.key,
    required this.controller,
    this.label = 'الحالة المرضية',
    this.hint = 'ابحث في حالاتك المرضية...',
    this.onCaseSelected,
    this.showRecentCases = true,
  });

  @override
  State<MedicalCasesAutocompleteField> createState() =>
      _MedicalCasesAutocompleteFieldState();
}

class _MedicalCasesAutocompleteFieldState
    extends State<MedicalCasesAutocompleteField> {
  List<Map<String, dynamic>> _allCases = [];
  List<Map<String, dynamic>> _filteredCases = [];
  bool _showSuggestions = false;
  bool _isLoading = false;
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _loadMedicalCases();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  Future<void> _loadMedicalCases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // جلب جميع الحالات المرضية للطبيب
      final response = await DoctorApiService.getAllPatientCases();

      List<Map<String, dynamic>> cases = [];

      if (response is Map && response['cases'] is List) {
        for (final caseItem in response['cases']) {
          if (caseItem is Map<String, dynamic>) {
            cases.add({
              'id': caseItem['id'],
              'title': caseItem['title'] ?? 'بدون عنوان',
              'description': caseItem['description'] ?? '',
              'patient_name': _getPatientName(caseItem),
              'status': caseItem['status'] ?? 'unknown',
              'created_at': caseItem['created_at'] ?? '',
              'symptoms': caseItem['symptoms'] ?? '',
            });
          }
        }
      }

      setState(() {
        _allCases = cases;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading medical cases: $e');
      setState(() {
        _allCases = [];
        _isLoading = false;
      });
    }
  }

  String _getPatientName(Map<String, dynamic> caseItem) {
    if (caseItem['patient'] is Map) {
      final patient = caseItem['patient'] as Map<String, dynamic>;
      if (patient['user'] is Map) {
        final user = patient['user'] as Map<String, dynamic>;
        final firstName = user['first_name'] ?? '';
        final lastName = user['last_name'] ?? '';
        return '$firstName $lastName'.trim();
      }
    }
    return 'مريض غير معروف';
  }

  void _onTextChanged() {
    final query = widget.controller.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredCases = [];
        _showSuggestions = false;
      });
      _removeOverlay();
      return;
    }

    final filtered = _allCases
        .where((caseItem) {
          final title = (caseItem['title'] ?? '').toLowerCase();
          final description = (caseItem['description'] ?? '').toLowerCase();
          final symptoms = (caseItem['symptoms'] ?? '').toLowerCase();
          final patientName = (caseItem['patient_name'] ?? '').toLowerCase();

          return title.contains(query) ||
              description.contains(query) ||
              symptoms.contains(query) ||
              patientName.contains(query);
        })
        .take(8)
        .toList();

    setState(() {
      _filteredCases = filtered;
      _showSuggestions = filtered.isNotEmpty;
    });

    if (_showSuggestions) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
          });
          _removeOverlay();
        }
      });
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredCases.length,
                itemBuilder: (context, index) {
                  final caseItem = _filteredCases[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      _getCaseStatusIcon(caseItem['status']),
                      color: _getCaseStatusColor(caseItem['status']),
                      size: 20,
                    ),
                    title: Text(
                      caseItem['title'] ?? 'بدون عنوان',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المريض: ${caseItem['patient_name']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        if (caseItem['description'] != null &&
                            caseItem['description'].isNotEmpty)
                          Text(
                            caseItem['description'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCaseStatusColor(caseItem['status'])
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getCaseStatusColor(caseItem['status'])
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getCaseStatusText(caseItem['status']),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getCaseStatusColor(caseItem['status']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    onTap: () {
                      widget.controller.text = caseItem['title'] ?? '';
                      widget.onCaseSelected?.call(caseItem);
                      setState(() {
                        _showSuggestions = false;
                      });
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCaseStatusIcon(String? status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'in_progress':
        return Icons.medical_services;
      case 'completed':
        return Icons.check_circle;
      case 'closed':
        return Icons.lock;
      default:
        return Icons.help_outline;
    }
  }

  Color _getCaseStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getCaseStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'معلقة';
      case 'in_progress':
        return 'قيد المعالجة';
      case 'completed':
        return 'مكتملة';
      case 'closed':
        return 'مغلقة';
      default:
        return 'غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search, color: Colors.blue),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.controller.clear();
                        setState(() {
                          _filteredCases = [];
                          _showSuggestions = false;
                        });
                        _removeOverlay();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),

          // عرض الحالات الأخيرة عند عدم وجود نص
          if (widget.showRecentCases &&
              widget.controller.text.isEmpty &&
              _allCases.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'الحالات الأخيرة:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _allCases.take(5).length,
                itemBuilder: (context, index) {
                  final caseItem = _allCases[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () {
                        widget.controller.text = caseItem['title'] ?? '';
                        widget.onCaseSelected?.call(caseItem);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getCaseStatusIcon(caseItem['status']),
                                  size: 16,
                                  color:
                                      _getCaseStatusColor(caseItem['status']),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    caseItem['title'] ?? 'بدون عنوان',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'المريض: ${caseItem['patient_name']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                caseItem['description'] ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // رسالة عند عدم وجود حالات
          if (!_isLoading && _allCases.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'لا توجد حالات مرضية حالياً',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
