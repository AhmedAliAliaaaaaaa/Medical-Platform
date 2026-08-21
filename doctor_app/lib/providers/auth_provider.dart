import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  Doctor? _doctor;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  User? get currentUser => _user; // Add this getter
  Doctor? get doctor => _doctor;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isDoctorApproved => _doctor?.isApproved ?? false;
  bool get isDoctorPending => _doctor?.isPending ?? false;
  bool get isDoctorRejected => _doctor?.isRejected ?? false;

  // Initialize authentication state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.initializeToken();

      if (ApiService.isAuthenticated) {
        await getCurrentUser();
      }
    } catch (e) {
      _error = e.toString();
      print('❌ AuthProvider: Error during initialization: $e');
      // محاولة تحميل بيانات المستخدم من التخزين المحلي
      await _loadUserDataFromStorage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحميل بيانات المستخدم من التخزين المحلي
  Future<void> _loadUserDataFromStorage() async {
    try {
      final userType = await ApiService.getUserType();
      final userData = await ApiService.getUserData();

      if (userType != null && userData != null) {
        if (userType == 'patient') {
          _user = User.fromJson(userData);
        } else if (userType == 'doctor') {
          _user = User.fromJson(userData);
          _doctor = Doctor.fromJson(userData);
        }
        notifyListeners();
      }
    } catch (e) {
      print('❌ AuthProvider: Error loading user data from storage: $e');
    }
  }

  // Check authentication status
  Future<void> checkAuthStatus() async {
    await initialize();
  }

  // Login with email or username
  Future<bool> login(
    String loginIdentifier,
    String password, [
    String? userType,
  ]) async {
    print('AuthProvider: Starting login for identifier: $loginIdentifier');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AuthProvider: Calling ApiService.login');
      final result = await ApiService.login(loginIdentifier, password);
      print('AuthProvider: Got result keys: ${result?.keys ?? "null"}');

      // Check if result is not null and has required data
      if (result != null && result is Map<String, dynamic>) {
        // For mock users, the structure is different
        if (result.containsKey('user') && result['user'] != null) {
          print('AuthProvider: Login successful');

          // Safely extract user data
          final userData = result['user'];
          if (userData is Map<String, dynamic>) {
            _user = User.fromJson(userData);

            // Extract user type safely
            final extractedUserType = userData['user_type'];
            print('AuthProvider: User type: $extractedUserType');

            // Load doctor data if user is a doctor
            if (extractedUserType == 'doctor' && result.containsKey('doctor') && result['doctor'] != null) {
              final doctorData = result['doctor'];
              if (doctorData is Map<String, dynamic>) {
                _doctor = Doctor.fromJson(doctorData);
                print('AuthProvider: Doctor data loaded');
              }
            }
          }

          _isLoading = false;
          notifyListeners();
          return true;
        } 
        // For API users, the structure might be different
        else if (result.containsKey('access') && result.containsKey('user')) {
          print('AuthProvider: API login successful');

          // Safely extract user data
          final userData = result['user'];
          if (userData is Map<String, dynamic>) {
            _user = User.fromJson(userData);

            // Extract user type safely
            final extractedUserType = userData['user_type'];
            print('AuthProvider: User type: $extractedUserType');

            // Load doctor data if user is a doctor
            if (extractedUserType == 'doctor' && result.containsKey('doctor') && result['doctor'] != null) {
              final doctorData = result['doctor'];
              if (doctorData is Map<String, dynamic>) {
                _doctor = Doctor.fromJson(doctorData);
                print('AuthProvider: Doctor data loaded');
              }
            }
          }

          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      // If we reach here, login failed
      final errorMsg = result is Map && result.containsKey('error') 
          ? result['error'] 
          : 'بيانات تسجيل الدخول غير صحيحة';
      print('AuthProvider: Login failed with error: $errorMsg');
      _error = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('AuthProvider: Exception during login: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login with username
  Future<bool> loginWithUsername(String username, String password) async {
    print('AuthProvider: Starting login for username: $username');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AuthProvider: Calling ApiService.login');
      final result = await ApiService.login(username, password);
      print('AuthProvider: Got result keys: ${result?.keys ?? "null"}');

      // Check if result is not null and has required data
      if (result != null && result is Map<String, dynamic>) {
        // For mock users, the structure is different
        if (result.containsKey('user') && result['user'] != null) {
          print('AuthProvider: Login successful');

          // Safely extract user data
          final userData = result['user'];
          if (userData is Map<String, dynamic>) {
            _user = User.fromJson(userData);

            // Extract user type safely
            final extractedUserType = userData['user_type'];
            print('AuthProvider: User type: $extractedUserType');

            // Load doctor data if user is a doctor
            if (extractedUserType == 'doctor' && result.containsKey('doctor') && result['doctor'] != null) {
              final doctorData = result['doctor'];
              if (doctorData is Map<String, dynamic>) {
                _doctor = Doctor.fromJson(doctorData);
                print('AuthProvider: Doctor data loaded');
              }
            }
          }

          _isLoading = false;
          notifyListeners();
          return true;
        } 
        // For API users, the structure might be different
        else if (result.containsKey('access') && result.containsKey('user')) {
          print('AuthProvider: API login successful');

          // Safely extract user data
          final userData = result['user'];
          if (userData is Map<String, dynamic>) {
            _user = User.fromJson(userData);

            // Extract user type safely
            final extractedUserType = userData['user_type'];
            print('AuthProvider: User type: $extractedUserType');

            // Load doctor data if user is a doctor
            if (extractedUserType == 'doctor' && result.containsKey('doctor') && result['doctor'] != null) {
              final doctorData = result['doctor'];
              if (doctorData is Map<String, dynamic>) {
                _doctor = Doctor.fromJson(doctorData);
                print('AuthProvider: Doctor data loaded');
              }
            }
          }

          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      // If we reach here, login failed
      final errorMsg = result is Map && result.containsKey('error') 
          ? result['error'] 
          : 'بيانات تسجيل الدخول غير صحيحة';
      print('AuthProvider: Login failed with error: $errorMsg');
      _error = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('AuthProvider: Exception during login: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register patient
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String userType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.registerPatient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phoneNumber,
        age: 25, // Default age, should be passed as parameter
        gender: 'male', // Default gender, should be passed as parameter
      );

      if (result['success']) {
        _user = User.fromJson(result['user']);
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

  // Register doctor
  Future<bool> registerDoctor({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String specialization,
    required String licenseNumber,
    required String country,
    required String bio,
    required int experienceYears,
    required double consultationFee,
    required double emergencyFee,
    required double followUpFee,
    required String currency,
    required bool acceptsInsurance,
    required String preferredLanguage,
    required dynamic licenseImage,
    dynamic profilePicture,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.registerDoctor(
        fullName: '$firstName $lastName',
        username: email.split('@')[0], // Use email prefix as username
        email: email,
        password: password,
        phone: phoneNumber,
        specialization: specialization,
        country: country,
        experienceYears: experienceYears,
        licenseNumber: licenseNumber,
        licenseImage: licenseImage,
        regularConsultationPrice: consultationFee,
        emergencyConsultationPrice: emergencyFee,
        followUpConsultationPrice: followUpFee,
        currency: currency,
        profileImage: profilePicture,
        bio: bio,
      );

      if (result['success']) {
        _user = result['user'];
        _doctor = result['doctor'];
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

  // Get current user
  Future<void> getCurrentUser() async {
    try {
      print('AuthProvider: Getting current user...');

      // محاولة الحصول على بيانات المستخدم من التخزين المحلي أولاً
      final userType = await ApiService.getUserType();
      final userData = await ApiService.getUserData();

      if (userType != null && userData != null) {
        print('AuthProvider: Loading user from storage data...');
        try {
          if (userType == 'patient') {
            _user = User.fromJson(userData);
          } else if (userType == 'doctor') {
            _user = User.fromJson(userData);
            _doctor = Doctor.fromJson(userData);
          }
          notifyListeners();
        } catch (jsonError) {
          print('AuthProvider: Error parsing user data from storage: $jsonError');
          // Continue to try loading from API
        }
      }

      // محاولة تحديث البيانات من الخادم
      try {
        final result = await ApiService.getUserProfile();
        print('AuthProvider: API response received');

        if (result != null && result is Map<String, dynamic>) {
          // Check for both mock and API response formats
          if (result.containsKey('user') && result['user'] != null) {
            final userData = result['user'];
            if (userData is Map<String, dynamic>) {
              _user = User.fromJson(userData);

              // Update userType from API data if needed
              final apiUserType = userData['user_type'];
              if (apiUserType != null && apiUserType != userType) {
                // Save the updated user type
                await ApiService.saveUserData({
                  ...userData,
                  'user_type': apiUserType,
                });
              }

              // Load doctor data if user is a doctor
              if (apiUserType == 'doctor' && result.containsKey('doctor') && result['doctor'] != null) {
                final doctorData = result['doctor'];
                if (doctorData is Map<String, dynamic>) {
                  _doctor = Doctor.fromJson(doctorData);
                }
              }

              print('AuthProvider: User updated from API - Doctor status: ${_doctor?.status}');

              // تحديث البيانات في التخزين المحلي
              await ApiService.saveUserData(result);

              notifyListeners();
            }
          }
        } else {
          print('AuthProvider: API response failed or user data is null');
          // إذا فشل تحديث البيانات من الخادم، نستخدم البيانات المحلية
          if (_user == null) {
            _error = result is Map && result.containsKey('error') 
                ? result['error'] 
                : 'فشل تحميل بيانات المستخدم';
            print('AuthProvider: Failed to get user: $_error');
            notifyListeners();
          }
        }
      } catch (apiError) {
        print('AuthProvider: API error getting user: $apiError');
        // إذا فشل تحديث البيانات من الخادم، نستخدم البيانات المحلية
        if (_user == null) {
          _error = apiError.toString().replaceAll('Exception: ', '');
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('AuthProvider: Exception getting user: $_error');
      notifyListeners();
    }
  }

  // Refresh doctor status (useful after approval)
  Future<void> refreshDoctorStatus() async {
    print('AuthProvider: Refreshing doctor status...');
    await getCurrentUser();
  }

  // Update profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? specialization,
    String? bio,
    int? experienceYears,
    double? consultationFee,
    double? emergencyFee,
    double? followUpFee,
    String? currency,
    bool? acceptsInsurance,
    String? preferredLanguage,
    dynamic profilePicture,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update user profile
      Map<String, dynamic> updateData = {};

      if (firstName != null) updateData['first_name'] = firstName;
      if (lastName != null) updateData['last_name'] = lastName;
      if (phoneNumber != null) updateData['phone'] = phoneNumber;
      if (email != null) updateData['email'] = email;
      if (specialization != null) updateData['specialization'] = specialization;
      if (bio != null) updateData['bio'] = bio;
      if (experienceYears != null) {
        updateData['experience_years'] = experienceYears;
      }
      if (consultationFee != null) {
        updateData['consultation_fee'] = consultationFee;
      }
      if (emergencyFee != null) updateData['emergency_fee'] = emergencyFee;
      if (followUpFee != null) updateData['follow_up_fee'] = followUpFee;
      if (currency != null) updateData['currency'] = currency;
      if (acceptsInsurance != null) {
        updateData['accepts_insurance'] = acceptsInsurance;
      }
      if (preferredLanguage != null) {
        updateData['preferred_language'] = preferredLanguage;
      }

      final result = await ApiService.updateUserProfile(updateData);

      if (result['success']) {
        _user = result['user'];
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

  // Update doctor profile
  Future<bool> updateDoctorProfile({
    String? specialization,
    String? country,
    String? bio,
    int? experienceYears,
    double? consultationFee,
    double? emergencyFee,
    double? followUpFee,
    String? currency,
    bool? acceptsInsurance,
    String? preferredLanguage,
    bool? isAvailable,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Map<String, dynamic> updateData = {};

      if (specialization != null) updateData['specialization'] = specialization;
      if (country != null) updateData['country'] = country;
      if (bio != null) updateData['bio'] = bio;
      if (experienceYears != null) {
        updateData['experience_years'] = experienceYears;
      }
      if (consultationFee != null) {
        updateData['consultation_fee'] = consultationFee;
      }
      if (emergencyFee != null) updateData['emergency_fee'] = emergencyFee;
      if (followUpFee != null) updateData['follow_up_fee'] = followUpFee;
      if (currency != null) updateData['currency'] = currency;
      if (acceptsInsurance != null) {
        updateData['accepts_insurance'] = acceptsInsurance;
      }
      if (preferredLanguage != null) {
        updateData['preferred_language'] = preferredLanguage;
      }
      if (isAvailable != null) updateData['is_available'] = isAvailable;

      final result = await ApiService.updateUserProfile(updateData);

      if (result['success']) {
        _doctor = result['doctor'];
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

  // Change password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result['success']) {
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

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      _user = null;
      _doctor = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
