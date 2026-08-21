from django import forms
from django.utils.translation import gettext as _
from .models import MedicalCase, CaseAttachment, DoctorRating

class MedicalCaseForm(forms.ModelForm):
    
    class Meta:
        model = MedicalCase
        fields = ['title', 'description', 'priority']
        widgets = {
            'title': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'عنوان الحالة (اختياري)'
            }),
            'description': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 6,
                'placeholder': 'اكتب وصفاً مفصلاً لحالتك الطبية والأعراض التي تعاني منها...'
            }),
            'priority': forms.Select(attrs={'class': 'form-control'}),
        }
        labels = {
            'title': 'عنوان الحالة',
            'description': 'وصف الحالة والأعراض',
            'priority': 'أولوية الحالة',
        }

class CaseAttachmentForm(forms.ModelForm):
    class Meta:
        model = CaseAttachment
        fields = ['file']
        widgets = {
            'file': forms.FileInput(attrs={'class': 'form-control'}),
        }

class DoctorRatingForm(forms.ModelForm):
    class Meta:
        model = DoctorRating
        fields = [
            'diagnosis_accuracy', 
            'treatment_clarity', 
            'response_speed', 
            'professionalism', 
            'communication', 
            'overall_satisfaction', 
            'comment'
        ]
        widgets = {
            'diagnosis_accuracy': forms.HiddenInput(),
            'treatment_clarity': forms.HiddenInput(),
            'response_speed': forms.HiddenInput(),
            'professionalism': forms.HiddenInput(),
            'communication': forms.HiddenInput(),
            'overall_satisfaction': forms.HiddenInput(),
            'comment': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 4,
                'placeholder': 'شاركنا رأيك وتجربتك مع الطبيب...'
            }),
        }
        labels = {
            'diagnosis_accuracy': 'دقة التشخيص',
            'treatment_clarity': 'وضوح العلاج',
            'response_speed': 'سرعة الرد',
            'professionalism': 'الاحترافية',
            'communication': 'التواصل',
            'overall_satisfaction': 'الرضا العام',
            'comment': 'تعليقك على الخدمة',
        }