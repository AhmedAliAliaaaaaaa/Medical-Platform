from rest_framework import serializers
from patients.models import MedicalCase, DoctorResponse, ResponseAttachment, CaseAttachment
from accounts.models import CustomUser


class UserBasicSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'first_name', 'last_name', 'email']


class CaseAttachmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = CaseAttachment
        fields = ['id', 'file', 'file_type', 'uploaded_at']


class ResponseAttachmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = ResponseAttachment
        fields = ['id', 'file', 'file_type', 'uploaded_at']


class DoctorResponseSerializer(serializers.ModelSerializer):
    attachments = ResponseAttachmentSerializer(many=True, read_only=True)
    doctor_name = serializers.CharField(source='doctor.user.get_full_name', read_only=True)
    
    class Meta:
        model = DoctorResponse
        fields = ['id', 'diagnosis', 'treatment_plan', 'doctor_name', 
                 'created_at', 'attachments']


class MedicalCaseSerializer(serializers.ModelSerializer):
    patient = UserBasicSerializer(source='patient.user', read_only=True)
    attachments = CaseAttachmentSerializer(many=True, read_only=True)
    responses = DoctorResponseSerializer(many=True, read_only=True)
    doctor_name = serializers.CharField(
        source='doctor.user.get_full_name', 
        read_only=True
    )
    
    class Meta:
        model = MedicalCase
        fields = ['id', 'title', 'description', 'priority', 'status',
                 'patient', 'doctor_name', 'created_at', 'updated_at',
                 'attachments', 'responses']


class CaseResponseCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = DoctorResponse
        fields = ['case', 'doctor', 'diagnosis', 'treatment_plan']