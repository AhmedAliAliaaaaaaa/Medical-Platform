from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.db import transaction
from .models import CustomUser
from doctors.models import Doctor
from .serializers import (
    UserSerializer,
    DoctorRegistrationSerializer,
    UserProfileSerializer,
    DoctorProfileSerializer,
)
from patients.models import Patient


class CustomTokenObtainPairView(TokenObtainPairView):
    """Custom login view that checks doctor approval status"""
    
    def post(self, request, *args, **kwargs):
        username = request.data.get('username')
        password = request.data.get('password')
        print(f"Login attempt for: {username}")
        
        # Try to authenticate with username, email, or first_name
        user = None
        try:
            # First try with username as provided
            user = authenticate(username=username, password=password)
            if not user:
                # Try to find user by email and authenticate with their username
                try:
                    user_obj = CustomUser.objects.get(email=username)
                    user = authenticate(username=user_obj.username, password=password)
                    print(f"Found user by email, trying with username: {user_obj.username}")
                except CustomUser.DoesNotExist:
                    pass
            
            if not user:
                # Try to find user by first_name and authenticate with their username
                try:
                    user_obj = CustomUser.objects.get(first_name=username)
                    user = authenticate(username=user_obj.username, password=password)
                    print(f"Found user by first_name, trying with username: {user_obj.username}")
                except CustomUser.DoesNotExist:
                    pass
        except Exception as e:
            print(f"Authentication error: {e}")
        
        if not user:
            print("Authentication failed")
            return Response({
                'success': False,
                'error': 'بيانات تسجيل الدخول غير صحيحة.',
            }, status=status.HTTP_401_UNAUTHORIZED)
        
        # Manual token generation since we bypassed the standard flow
        from rest_framework_simplejwt.tokens import RefreshToken
        refresh = RefreshToken.for_user(user)
        
        print(f"JWT authentication successful for: {user.username}")
        
        # Check if user is a doctor and their status
        if user.user_type == 'doctor':
            if hasattr(user, 'doctor'):
                doctor = user.doctor
                print(f"Doctor status: {doctor.status}")
                
                if doctor.status == 'pending':
                    return Response({
                        'success': False,
                        'error': 'حسابك قيد المراجعة من قبل الإدارة. سيتم إشعارك عند الموافقة.',
                        'status': 'pending'
                    }, status=status.HTTP_403_FORBIDDEN)
                elif doctor.status == 'rejected':
                    return Response({
                        'success': False,
                        'error': 'تم رفض طلب انضمامك. يرجى التواصل مع الإدارة.',
                        'status': 'rejected'
                    }, status=status.HTTP_403_FORBIDDEN)
                elif doctor.status == 'approved':
                    print("Doctor is approved, allowing login")
            else:
                print("User is doctor but no doctor profile found")
                return Response({
                    'success': False,
                    'error': 'ملف الطبيب غير موجود. يرجى التواصل مع الإدارة.',
                }, status=status.HTTP_400_BAD_REQUEST)
        
        # Return successful response with tokens and user data
        response_data = {
            'success': True,
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': UserSerializer(user).data,
            'doctor': DoctorProfileSerializer(user.doctor).data if hasattr(user, 'doctor') else None,
        }
        
        print(f"Login successful for user: {user.username}")
        return Response(response_data, status=status.HTTP_200_OK)


class DoctorRegistrationView(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        try:
            with transaction.atomic():
                # Create user
                user_data = {
                    'email': request.data.get('email'),
                    'password': request.data.get('password'),
                    'first_name': request.data.get('firstName') or request.data.get('first_name'),
                    'last_name': request.data.get('lastName') or request.data.get('last_name'),
                    'phone_number': request.data.get('phoneNumber') or request.data.get('phone_number'),
                    'user_type': 'doctor'
                }
                
                user = CustomUser.objects.create_user(
                    username=user_data['email'],
                    email=user_data['email'],
                    password=user_data['password'],
                    first_name=user_data['first_name'],
                    last_name=user_data['last_name'],
                    phone_number=user_data['phone_number'],
                    user_type=user_data['user_type']
                )
                
                # Create doctor profile
                doctor = Doctor.objects.create(
                    user=user,
                    specialization=request.data.get('specialization'),
                    license_number=request.data.get('licenseNumber') or request.data.get('license_number'),
                    country=request.data.get('country'),
                    bio=request.data.get('bio'),
                    experience_years=request.data.get('experienceYears') or request.data.get('experience_years', 0),
                    consultation_fee=request.data.get('consultationFee') or request.data.get('consultation_fee', 0),
                    emergency_fee=request.data.get('emergencyFee') or request.data.get('emergency_fee', 0),
                    follow_up_fee=request.data.get('followUpFee') or request.data.get('follow_up_fee', 0),
                    currency=request.data.get('currency', 'USD'),
                    accepts_insurance=request.data.get('acceptsInsurance') or request.data.get('accepts_insurance', False),
                    preferred_language=request.data.get('preferredLanguage') or request.data.get('preferred_language', 'en'),
                    status='pending'
                )
                
                # Generate tokens
                refresh = RefreshToken.for_user(user)
                
                return Response({
                    'success': True,
                    'user': UserSerializer(user).data,
                    'doctor': DoctorProfileSerializer(doctor).data,
                    'access': str(refresh.access_token),
                    'refresh': str(refresh),
                }, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            return Response({
                'success': False,
                'error': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)


class PatientRegistrationView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        try:
            with transaction.atomic():
                # Validate required fields
                required_fields = ['email', 'password', 'first_name', 'last_name', 'phone_number']
                for field in required_fields:
                    if not request.data.get(field):
                        return Response({'error': f'{field} مطلوب'}, status=status.HTTP_400_BAD_REQUEST)

                # Create user
                user = CustomUser.objects.create_user(
                    username=request.data.get('username') or request.data.get('first_name'),
                    email=request.data.get('email'),
                    password=request.data.get('password'),
                    first_name=request.data.get('first_name'),
                    last_name=request.data.get('last_name'),
                    phone_number=request.data.get('phone_number') or request.data.get('phone'),
                    user_type='patient'
                )

                # Create patient profile
                patient = Patient.objects.create(user=user)

                # Generate tokens
                refresh = RefreshToken.for_user(user)

                return Response({
                    'success': True,
                    'user': UserSerializer(user).data,
                    'patient': {'id': patient.id},
                    'access': str(refresh.access_token),
                    'refresh': str(refresh),
                }, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({'success': False, 'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            user = request.user
            doctor = None
            
            if hasattr(user, 'doctor'):
                doctor = user.doctor
                
            return Response({
                'success': True,
                'user': UserSerializer(user).data,
                'doctor': DoctorProfileSerializer(doctor).data if doctor else None,
            })
        except Exception as e:
            return Response({
                'success': False,
                'error': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        try:
            user = request.user
            
            # Update user fields
            if 'firstName' in request.data:
                user.first_name = request.data['firstName']
            if 'lastName' in request.data:
                user.last_name = request.data['lastName']
            if 'phoneNumber' in request.data:
                user.phone_number = request.data['phoneNumber']
            if 'email' in request.data:
                user.email = request.data['email']
                user.username = request.data['email']
                
            user.save()
            
            return Response({
                'success': True,
                'user': UserSerializer(user).data,
            })
        except Exception as e:
            return Response({
                'success': False,
                'error': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)


class DoctorProfileView(APIView):
    permission_classes = [IsAuthenticated]
    
    def put(self, request):
        try:
            if not hasattr(request.user, 'doctor'):
                return Response({
                    'success': False,
                    'error': 'User is not a doctor'
                }, status=status.HTTP_400_BAD_REQUEST)
                
            doctor = request.user.doctor
            
            # Update doctor fields
            if 'specialization' in request.data:
                doctor.specialization = request.data['specialization']
            if 'bio' in request.data:
                doctor.bio = request.data['bio']
            if 'experienceYears' in request.data:
                doctor.experience_years = request.data['experienceYears']
            if 'consultationFee' in request.data:
                doctor.consultation_fee = request.data['consultationFee']
            if 'emergencyFee' in request.data:
                doctor.emergency_fee = request.data['emergencyFee']
            if 'followUpFee' in request.data:
                doctor.follow_up_fee = request.data['followUpFee']
            if 'currency' in request.data:
                doctor.currency = request.data['currency']
            if 'acceptsInsurance' in request.data:
                doctor.accepts_insurance = request.data['acceptsInsurance']
            if 'preferredLanguage' in request.data:
                doctor.preferred_language = request.data['preferredLanguage']
                
            doctor.save()
            
            return Response({
                'success': True,
                'doctor': DoctorProfileSerializer(doctor).data,
            })
        except Exception as e:
            return Response({
                'success': False,
                'error': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def doctor_register_with_files(request):
    """تسجيل طبيب جديد مع رفع الملفات"""
    try:
        with transaction.atomic():

            # التحقق من البيانات المطلوبة
            # التحقق الذكي من الحقول المطلوبة (يدعم phone أو phone_number)
            required_fields = ['full_name', 'username', 'email', 'password', 'specialization', 'country', 'experience_years', 'license_number']
            for field in required_fields:
                if not request.data.get(field):
                    return Response({'error': f'الحقل {field} مطلوب'}, status=status.HTTP_400_BAD_REQUEST)

            phone_number = request.data.get('phone_number') or request.data.get('phone')
            if not phone_number:
                return Response({'error': 'الحقل phone_number أو phone مطلوب'}, status=status.HTTP_400_BAD_REQUEST)
            
            # التحقق من وجود صورة الترخيص
            if 'license_image' not in request.FILES:
                return Response({'error': 'صورة الترخيص الطبي مطلوبة'}, status=status.HTTP_400_BAD_REQUEST)
            
            # تقسيم الاسم الكامل
            full_name = request.data.get('full_name').strip()
            name_parts = full_name.split()
            first_name = name_parts[0] if name_parts else ''
            last_name = ' '.join(name_parts[1:]) if len(name_parts) > 1 else ''
            
            # إنشاء المستخدم
            user = CustomUser.objects.create_user(
                username=request.data.get('username') or request.data.get('email'),
                email=request.data.get('email'),
                password=request.data.get('password'),
                first_name=first_name,
                last_name=last_name,
                phone_number=phone_number,
                user_type='doctor'
            )
            
            # تحويل العملة من الاسم إلى الرمز
            currency_mapping = {
                'ريال سعودي': 'SAR',
                'درهم إماراتي': 'AED',
                'دينار كويتي': 'KWD',
                'ريال قطري': 'QAR',
                'دينار بحريني': 'BHD',
                'ريال عماني': 'OMR',
                'دينار أردني': 'JOD',
                'جنيه مصري': 'EGP',
                'دولار أمريكي': 'USD',
                'يورو': 'EUR',
            }
            
            currency_name = request.data.get('currency', 'ريال سعودي')
            currency_code = currency_mapping.get(currency_name, 'SAR')
            

            # إنشاء ملف الطبيب
            doctor = Doctor.objects.create(
                user=user,
                specialization=request.data.get('specialization'),
                license_number=request.data.get('license_number'),
                license_image=request.FILES.get('license_image'),
                country=request.data.get('country'),
                bio=request.data.get('bio') or f"طبيب {request.data.get('specialization')} بخبرة {request.data.get('experience_years')} سنوات",
                experience_years=int(request.data.get('experience_years', 0)),
                consultation_fee=float(request.data.get('regular_consultation_price', 100.00)),
                emergency_fee=float(request.data.get('emergency_consultation_price', 200.00)),
                follow_up_fee=float(request.data.get('follow_up_consultation_price', 50.00)),
                currency=currency_code,
                accepts_insurance=request.data.get('accepts_insurance', 'false').lower() == 'true',
                status='pending'
            )
            
            # إضافة الصورة الشخصية إذا كانت موجودة
            if 'profile_image' in request.FILES:
                # يمكن إضافة حقل profile_image للطبيب لاحقاً
                pass
            
            # إرسال إشعار للإدارة
            try:
                from admin_panel.models import AdminNotification
                AdminNotification.objects.create(
                    title='طبيب جديد يطلب التسجيل',
                    message=f'طبيب جديد: د. {user.get_full_name()} - {doctor.specialization}',
                    notification_type='doctor_registration',
                    related_doctor=doctor,
                    created_by=user
                )
            except Exception as notification_error:
                # إذا فشل إنشاء الإشعار، لا نريد أن يفشل التسجيل كله
                print(f"فشل في إنشاء الإشعار: {notification_error}")
            
            return Response({
                'message': 'تم إرسال طلب التسجيل بنجاح. سيتم مراجعة بياناتك قريباً.',
                'doctor_id': doctor.id
            }, status=status.HTTP_201_CREATED)
            
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)