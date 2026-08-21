from rest_framework import serializers
from .models import CustomUser
from doctors.models import Doctor


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 
                 'phone_number', 'user_type', 'date_joined']
        read_only_fields = ['id', 'username', 'date_joined']


class DoctorRegistrationSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(min_length=8)
    firstName = serializers.CharField(max_length=30)
    lastName = serializers.CharField(max_length=30)
    phoneNumber = serializers.CharField(max_length=20)
    specialization = serializers.CharField(max_length=100)
    licenseNumber = serializers.CharField(max_length=50)
    country = serializers.CharField(max_length=50)
    bio = serializers.CharField()
    experienceYears = serializers.IntegerField(min_value=0)
    consultationFee = serializers.DecimalField(max_digits=10, decimal_places=2)
    emergencyFee = serializers.DecimalField(max_digits=10, decimal_places=2)
    followUpFee = serializers.DecimalField(max_digits=10, decimal_places=2)
    currency = serializers.CharField(max_length=3, default='USD')
    acceptsInsurance = serializers.BooleanField(default=False)
    preferredLanguage = serializers.CharField(max_length=10, default='en')


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 
                 'phone_number', 'user_type', 'profile_picture', 'is_verified',
                 'created_at', 'updated_at']


class DoctorProfileSerializer(serializers.ModelSerializer):
    user = UserProfileSerializer(read_only=True)
    
    class Meta:
        model = Doctor
        fields = ['id', 'user', 'specialization', 'license_number', 'country',
                 'bio', 'experience_years', 'consultation_fee', 'emergency_fee',
                 'follow_up_fee', 'currency', 'accepts_insurance', 
                 'preferred_language', 'status', 'rating', 'total_reviews',
                 'is_available', 'license_image', 'created_at', 'updated_at']