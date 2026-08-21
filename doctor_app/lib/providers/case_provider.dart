import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/medical_case.dart';
import '../models/doctor_response.dart';
import '../services/case_service.dart';

class CaseProvider with ChangeNotifier {
  List<MedicalCase> _cases = [];
  List<DoctorResponse> _responses = [];
  MedicalCase? _selectedCase;
  bool _isLoading = false;
  String? _error;
  int _totalCases = 0;
  int _currentPage = 1;
  bool _hasNextPage = false;
  Map<String, dynamic>? _statistics;

  List<MedicalCase> get cases => _cases;
  List<MedicalCase> get myCases => _cases;
  List<MedicalCase> get assignedCases =>
      _cases.where((c) => c.status != 'available').toList();
  List<MedicalCase> get availableCases =>
      _cases.where((c) => c.status == 'available').toList();
  List<DoctorResponse> get responses => _responses;
  MedicalCase? get selectedCase => _selectedCase;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCases => _totalCases;
  int get currentPage => _currentPage;
  bool get hasNextPage => _hasNextPage;
  Map<String, dynamic>? get statistics =>
      _statistics ??
      {
        'totalCases': 0,
        'pendingCases': 0,
        'inProgressCases': 0,
        'completedCases': 0,
      };

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Add loadMyCases method for compatibility
  Future<void> loadMyCases() async {
    await getAssignedCases(refresh: true);
  }

  // Get assigned cases
  Future<void> getAssignedCases({
    String? status,
    String? priority,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _cases.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('CaseProvider: Getting assigned cases...');
      final result = await CaseService.getAssignedCases(
        status: status,
        priority: priority,
        page: _currentPage,
      );

      print('CaseProvider: Result received: $result');

      if (result['success'] == true) {
        final newCases = result['cases'] as List<MedicalCase>;

        if (refresh) {
          _cases = newCases;
        } else {
          _cases.addAll(newCases);
        }

        _totalCases = result['total'] ?? newCases.length;
        _hasNextPage = result['hasNext'] ?? false;

        if (_hasNextPage) {
          _currentPage++;
        }

        print('CaseProvider: Updated cases list, total: $_totalCases');
      } else {
        _error = result['error'] ?? 'فشل تحميل الحا��ات';
        print('CaseProvider: Error: $_error');
      }
    } catch (e) {
      _error = e.toString();
      print('CaseProvider: Exception: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new case
  Future<bool> createCase({
    required String title,
    required String description,
    required String priority,
    required int doctorId,
    List<File>? attachments,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await CaseService.createCase(
        title: title,
        description: description,
        priority: priority,
        doctorId: doctorId,
        attachments: attachments,
      );

      if (result['success']) {
        final newCase = result['case'] as MedicalCase;
        _cases.insert(0, newCase);
        _totalCases++;
        _setLoading(false);
        return true;
      } else {
        _error = result['error'];
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Get my cases
  Future<void> getMyCases({
    String? status,
    String? priority,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _cases.clear();
    }

    _setLoading(true);
    _error = null;

    try {
      final result = await CaseService.getMyCases(
        page: _currentPage,
        status: status,
        priority: priority,
      );

      if (result['success']) {
        final newCases = result['cases'] as List<MedicalCase>;

        if (refresh) {
          _cases = newCases;
        } else {
          _cases.addAll(newCases);
        }

        _totalCases = result['total'] ?? 0;
        _hasNextPage = result['hasNext'] ?? false;
        _currentPage++;
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Load case details
  Future<void> loadCaseDetails(int caseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await CaseService.getCaseDetails(caseId);

      if (result['success']) {
        _selectedCase = result['case'];
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Accept case
  Future<bool> acceptCase(int caseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await CaseService.acceptCase(caseId);

      if (result['success']) {
        final updatedCase = result['case'] as MedicalCase;

        // Update case in list
        final index = _cases.indexWhere(
          (medicalCase) => medicalCase.id == caseId,
        );
        if (index != -1) {
          _cases[index] = updatedCase;
        }

        // Update selected case
        if (_selectedCase?.id == caseId) {
          _selectedCase = updatedCase;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Send response to case
  Future<bool> sendResponse({
    required int caseId,
    required String diagnosis,
    required String treatmentPlan,
    String? notes,
    String responseLanguage = 'ar',
    dynamic responseFile,
    dynamic responseVideo,
    List<File>? attachments,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await CaseService.sendResponse(
        caseId: caseId,
        diagnosis: diagnosis,
        treatmentPlan: treatmentPlan,
        notes: notes,
        responseLanguage: responseLanguage,
        responseFile: responseFile,
        responseVideo: responseVideo,
        attachments: attachments,
      );

      if (result['success']) {
        final response = result['response'] as DoctorResponse;

        // Add response to list
        _responses.insert(0, response);

        // Update case status
        final caseIndex = _cases.indexWhere(
          (medicalCase) => medicalCase.id == caseId,
        );
        if (caseIndex != -1) {
          // Create updated case with completed status
          final updatedCase = MedicalCase(
            id: _cases[caseIndex].id,
            patient: _cases[caseIndex].patient,
            doctor: _cases[caseIndex].doctor,
            title: _cases[caseIndex].title,
            description: _cases[caseIndex].description,
            titleTranslated: _cases[caseIndex].titleTranslated,
            descriptionTranslated: _cases[caseIndex].descriptionTranslated,
            sourceLanguage: _cases[caseIndex].sourceLanguage,
            translationConfidence: _cases[caseIndex].translationConfidence,
            priority: _cases[caseIndex].priority,
            status: 'completed',
            createdAt: _cases[caseIndex].createdAt,
            updatedAt: DateTime.now(),
            expectedResponseTime: _cases[caseIndex].expectedResponseTime,
            attachments: _cases[caseIndex].attachments,
          );
          _cases[caseIndex] = updatedCase;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get doctor's responses
  Future<void> getMyResponses({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _responses.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await CaseService.getMyResponses(page: _currentPage);

      if (result['success']) {
        final newResponses = result['responses'] as List<DoctorResponse>;

        if (refresh) {
          _responses = newResponses;
        } else {
          _responses.addAll(newResponses);
        }

        _hasNextPage = result['next'] != null;

        if (_hasNextPage) {
          _currentPage++;
        }
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get case statistics
  Future<void> getCaseStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await CaseService.getCaseStatistics();

      if (result['success']) {
        _statistics = result['statistics'];
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search cases
  Future<void> searchCases({
    String? query,
    String? status,
    String? priority,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _cases.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await CaseService.searchCases(
        query: query,
        status: status,
        priority: priority,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: _currentPage,
      );

      if (result['success']) {
        final newCases = result['cases'] as List<MedicalCase>;

        if (refresh) {
          _cases = newCases;
        } else {
          _cases.addAll(newCases);
        }

        _totalCases = result['count'];
        _hasNextPage = result['next'] != null;

        if (_hasNextPage) {
          _currentPage++;
        }
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter cases by status
  List<MedicalCase> getCasesByStatus(String status) {
    return _cases.where((medicalCase) => medicalCase.status == status).toList();
  }

  // Filter cases by priority
  List<MedicalCase> getCasesByPriority(String priority) {
    return _cases
        .where((medicalCase) => medicalCase.priority == priority)
        .toList();
  }

  // Get pending cases
  List<MedicalCase> get pendingCases => getCasesByStatus('pending');

  // Submit case response
  Future<bool> submitCaseResponse({
    required int caseId,
    required String response,
    List<File>? attachments,
  }) async {
    try {
      _setLoading(true);

      final result = await CaseService.sendResponse(
        caseId: caseId,
        diagnosis: response,
        treatmentPlan: '',
        attachments: attachments,
      );

      if (result['success']) {
        // Update the case in the list
        final caseIndex = _cases.indexWhere(
          (medicalCase) => medicalCase.id == caseId,
        );
        if (caseIndex != -1) {
          final updatedCase = await getCaseDetails(caseId);
          if (updatedCase != null) {
            _cases[caseIndex] = updatedCase;
          }
        }
      }

      return result['success'];
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get case details
  Future<MedicalCase?> getCaseDetails(int caseId) async {
    try {
      final result = await CaseService.getCaseDetails(caseId);
      if (result['success']) {
        return result['case'] as MedicalCase;
      }
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Get in progress cases
  List<MedicalCase> get inProgressCases => getCasesByStatus('in_progress');

  // Get completed cases
  List<MedicalCase> get completedCases => getCasesByStatus('completed');

  // Get urgent cases
  List<MedicalCase> get urgentCases => getCasesByPriority('urgent');

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Update case status
  Future<bool> updateCaseStatus(int caseId, String status) async {
    try {
      _setLoading(true);

      // Find and update the case in the list
      final caseIndex = _cases.indexWhere(
        (medicalCase) => medicalCase.id == caseId,
      );
      if (caseIndex != -1) {
        final updatedCase = await getCaseDetails(caseId);
        if (updatedCase != null) {
          _cases[caseIndex] = updatedCase;
        }
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Filter cases
  void filterCases({String? status, String? priority, String? searchQuery}) {
    // This method can be used to apply filters to the cases list
    // For now, we'll just refresh the cases with the filters
    getAssignedCases(status: status, priority: priority, refresh: true);
  }

  // Clear selected case
  void clearSelectedCase() {
    _selectedCase = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await getAssignedCases(refresh: true);
    await getCaseStatistics();
  }
}
