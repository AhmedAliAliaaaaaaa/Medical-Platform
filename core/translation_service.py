"""
خدمة الترجمة الفورية المحسنة للمنصة الطبية
توفر ترجمة فورية متقدمة بين العربية والإنجليزية مع قاموس طبي متخصص
"""

from deep_translator import GoogleTranslator
from django.conf import settings
from django.core.cache import cache
import logging
import hashlib
import re
from typing import Dict, Optional, List

logger = logging.getLogger(__name__)

class TranslationService:
    def __init__(self):
        self.cache_timeout = 3600  # 1 hour cache
        
        # قاموس طبي متخصص للترجمة الدقيقة
        self.medical_dictionary = {
            # الأعراض الشائعة
            'صداع': 'headache', 'حمى': 'fever', 'سعال': 'cough', 'ألم': 'pain',
            'غثيان': 'nausea', 'دوخة': 'dizziness', 'إسهال': 'diarrhea', 'إمساك': 'constipation',
            'ضيق تنفس': 'shortness of breath', 'خفقان': 'palpitations', 'أرق': 'insomnia',
            'تعب': 'fatigue', 'ضعف': 'weakness', 'طفح جلدي': 'skin rash', 'حكة': 'itching',
            'تورم': 'swelling', 'نزيف': 'bleeding', 'كدمات': 'bruising', 'تنميل': 'numbness',
            
            # أجزاء الجسم
            'رأس': 'head', 'عين': 'eye', 'أذن': 'ear', 'أنف': 'nose', 'فم': 'mouth',
            'رقبة': 'neck', 'صدر': 'chest', 'بطن': 'abdomen', 'ظهر': 'back', 'يد': 'hand',
            'قدم': 'foot', 'ساق': 'leg', 'ذراع': 'arm', 'قلب': 'heart', 'رئة': 'lung',
            'كبد': 'liver', 'كلى': 'kidney', 'معدة': 'stomach', 'أمعاء': 'intestines',
            
            # التشخيصات
            'التهاب': 'inflammation', 'عدوى': 'infection', 'حساسية': 'allergy',
            'فيروس': 'virus', 'بكتيريا': 'bacteria', 'مرض السكري': 'diabetes',
            'ضغط الدم': 'blood pressure', 'كوليسترول': 'cholesterol', 'أنيميا': 'anemia',
            'التهاب المفاصل': 'arthritis', 'ربو': 'asthma', 'اكتئاب': 'depression',
            'قلق': 'anxiety', 'صرع': 'epilepsy', 'صداع نصفي': 'migraine',
            
            # العلاجات
            'دواء': 'medication', 'مضاد حيوي': 'antibiotic', 'مسكن': 'painkiller',
            'مضاد التهاب': 'anti-inflammatory', 'فيتامين': 'vitamin', 'مكمل غذائي': 'supplement',
            'حقنة': 'injection', 'كبسولة': 'capsule', 'قرص': 'tablet', 'شراب': 'syrup',
            'مرهم': 'ointment', 'كريم': 'cream', 'قطرة': 'drops', 'بخاخ': 'spray',
            
            # التوجيهات الطبية
            'راحة': 'rest', 'نوم': 'sleep', 'شرب الماء': 'drink water', 'تناول الطعام': 'eat food',
            'تجنب': 'avoid', 'توقف عن': 'stop', 'استمر في': 'continue', 'مراجعة الطبيب': 'see doctor',
            'طوارئ': 'emergency', 'فوري': 'immediate', 'عاجل': 'urgent', 'عادي': 'normal',
            'خفيف': 'mild', 'متوسط': 'moderate', 'شديد': 'severe',
            
            # الفحوصات
            'تحليل دم': 'blood test', 'أشعة': 'x-ray', 'أشعة مقطعية': 'CT scan',
            'رنين مغناطيسي': 'MRI', 'موجات فوق صوتية': 'ultrasound', 'تخطيط قلب': 'ECG',
            'تحليل بول': 'urine test', 'خزعة': 'biopsy', 'منظار': 'endoscopy',
            
            # العبارات الطبية الشائعة
            'أعاني من': 'I suffer from', 'أشعر بـ': 'I feel', 'لدي ألم في': 'I have pain in',
            'منذ متى': 'since when', 'كم مرة': 'how many times', 'ما هو العلاج': 'what is the treatment',
            'هل يمكنني': 'can I', 'هل يجب أن': 'should I', 'ما هي الأعراض': 'what are the symptoms',
            'كيف أتناول': 'how to take', 'متى أتناول': 'when to take', 'ما هي الجرعة': 'what is the dose',
            'هل هناك آثار جانبية': 'are there side effects', 'متى أراجع الطبيب': 'when to see doctor',
            'هل هذا طبيعي': 'is this normal', 'هل هذا خطير': 'is this serious',
        }
        
        # القاموس العكسي (إنجليزي -> عربي)
        self.reverse_medical_dictionary = {v: k for k, v in self.medical_dictionary.items()}
    
    def get_cache_key(self, text, source_lang, target_lang):
        """Generate cache key for translation"""
        text_hash = hashlib.md5(text.encode('utf-8')).hexdigest()
        return f"translation_{source_lang}_{target_lang}_{text_hash}"
    
    def detect_language(self, text):
        """Detect the language of the text"""
        try:
            arabic_chars = len(re.findall(r'[\u0600-\u06FF]', text))
            english_chars = len(re.findall(r'[a-zA-Z]', text))
            if arabic_chars > english_chars:
                return 'ar'
            elif english_chars > arabic_chars:
                return 'en'
            return 'ar'
        except Exception as e:
            logger.error(f"Language detection error: {e}")
            return 'ar'
    
    def detect_language_enhanced(self, text: str) -> str:
        """كشف لغة النص بطريقة محسنة"""
        if not text:
            return 'unknown'
        
        arabic_chars = len(re.findall(r'[\u0600-\u06FF]', text))
        english_chars = len(re.findall(r'[a-zA-Z]', text))
        
        if arabic_chars > english_chars:
            return 'ar'
        elif english_chars > arabic_chars:
            return 'en'
        else:
            return 'ar'
    
    def translate_with_medical_dictionary(self, text: str, target_lang: str = 'en') -> Dict:
        """ترجمة النص باستخدام القاموس الطبي المتخصص"""
        if not text:
            return {
                'original_text': text,
                'translated_text': text,
                'source_lang': 'unknown',
                'target_lang': target_lang,
                'success': True,
                'medical_terms_found': 0,
                'confidence': 0.0
            }
        
        source_lang = self.detect_language_enhanced(text)
        
        # تحديد القاموس المناسب
        if source_lang == 'ar' and target_lang == 'en':
            dictionary = self.medical_dictionary
        elif source_lang == 'en' and target_lang == 'ar':
            dictionary = self.reverse_medical_dictionary
        else:
            # استخدام Google Translate للغات الأخرى
            return self.translate_text_google(text, target_lang, source_lang)
        
        # ترجمة باستخدام القاموس الطبي
        translated_text = text
        medical_terms_found = 0
        
        # ترجمة العبارات الطويلة أولاً (مع مراعاة الحالة)
        for term, translation in sorted(dictionary.items(), key=lambda x: len(x[0]), reverse=True):
            # البحث عن المصطلح بطريقة أكثر دقة
            import re
            pattern = re.compile(re.escape(term), re.IGNORECASE)
            if pattern.search(text):
                translated_text = pattern.sub(translation, translated_text)
                medical_terms_found += 1
        
        # حساب مستوى الثقة
        confidence = min(medical_terms_found / max(len(text.split()), 1), 1.0)
        
        # إذا لم نجد مصطلحات طبية كافية، استخدم Google Translate
        if medical_terms_found == 0 or confidence < 0.3:
            google_result = self.translate_text_google(text, target_lang, source_lang)
            return {
                **google_result,
                'medical_terms_found': medical_terms_found,
                'confidence': 0.5  # ثقة متوسطة لـ Google Translate
            }
        
        return {
            'original_text': text,
            'translated_text': translated_text,
            'source_lang': source_lang,
            'target_lang': target_lang,
            'success': True,
            'medical_terms_found': medical_terms_found,
            'confidence': confidence
        }
    
    def translate_text_google(self, text: str, target_lang: str = 'en', source_lang: str = 'auto') -> Dict:
        """ترجمة النص باستخدام Google Translate"""
        if not text or not text.strip():
            return {
                'original_text': text,
                'translated_text': text,
                'source_lang': source_lang,
                'target_lang': target_lang,
                'success': True,
                'medical_terms_found': 0,
                'confidence': 0.0
            }
        
        # التحقق من الكاش أولاً
        cache_key = self.get_cache_key(text, source_lang, target_lang)
        cached_result = cache.get(cache_key)
        if cached_result:
            return cached_result
        
        try:
            # كشف اللغة المصدر إذا كانت تلقائية
            if source_lang == 'auto':
                detected_lang = self.detect_language_enhanced(text)
                source_lang = detected_lang
            
            # تخطي الترجمة إذا كانت اللغة المصدر والهدف متشابهة
            if source_lang == target_lang:
                result = {
                    'original_text': text,
                    'translated_text': text,
                    'source_lang': source_lang,
                    'target_lang': target_lang,
                    'success': True,
                    'medical_terms_found': 0,
                    'confidence': 1.0
                }
                cache.set(cache_key, result, self.cache_timeout)
                return result
            
            # تنفيذ الترجمة
            translator = GoogleTranslator(source=source_lang, target=target_lang)
            translated_text = translator.translate(text)
            
            result = {
                'original_text': text,
                'translated_text': translated_text,
                'source_lang': source_lang,
                'target_lang': target_lang,
                'success': True,
                'medical_terms_found': 0,
                'confidence': 0.8  # ثقة عالية لـ Google Translate
            }
            
            # حفظ في الكاش
            cache.set(cache_key, result, self.cache_timeout)
            return result
            
        except Exception as e:
            logger.error(f"Translation error: {e}")
            return {
                'original_text': text,
                'translated_text': text,
                'source_lang': source_lang,
                'target_lang': target_lang,
                'success': False,
                'medical_terms_found': 0,
                'confidence': 0.0,
                'error': str(e)
            }
    
    def translate_text(self, text: str, target_lang: str = 'en', source_lang: str = 'auto', use_medical_dict: bool = True) -> Dict:
        """
        الوظيفة الرئيسية للترجمة - تجمع بين القاموس الطبي و Google Translate
        """
        # استخدم Google Translate كأساس
        google_result = self.translate_text_google(text, target_lang, source_lang)
        
        if use_medical_dict and google_result['success']:
            # أضف معلومات المصطلحات الطبية
            source_lang_detected = google_result['source_lang']
            
            # تحديد القاموس المناسب
            if source_lang_detected == 'ar' and target_lang == 'en':
                dictionary = self.medical_dictionary
            elif source_lang_detected == 'en' and target_lang == 'ar':
                dictionary = self.reverse_medical_dictionary
            else:
                return google_result
            
            # عد المصطلحات الطبية الموجودة
            medical_terms_found = 0
            for term in dictionary.keys():
                import re
                pattern = re.compile(re.escape(term), re.IGNORECASE)
                if pattern.search(text):
                    medical_terms_found += 1
            
            # أضف معلومات المصطلحات الطبية للنتيجة
            google_result['medical_terms_found'] = medical_terms_found
            if medical_terms_found > 0:
                google_result['confidence'] = min(google_result.get('confidence', 0.8) + 0.1, 1.0)
        
        return google_result
    
    def translate_medical_case(self, case_data, target_lang='en'):
        """
        Translate medical case data
        
        Args:
            case_data (dict): Medical case data
            target_lang (str): Target language
        
        Returns:
            dict: Translated case data
        """
        translated_data = case_data.copy()
        
        # Fields to translate
        translatable_fields = ['title', 'description', 'diagnosis', 'treatment_plan', 'notes']
        
        for field in translatable_fields:
            if field in case_data and case_data[field]:
                translation_result = self.translate_text(
                    case_data[field], 
                    target_lang=target_lang,
                    use_medical_dict=True
                )
                translated_data[f'{field}_translated'] = translation_result['translated_text']
                translated_data[f'{field}_original'] = translation_result['original_text']
                translated_data[f'{field}_confidence'] = translation_result.get('confidence', 0.0)
                translated_data[f'{field}_medical_terms'] = translation_result.get('medical_terms_found', 0)
        
        return translated_data
    
    def get_bidirectional_translation(self, text, source_lang='auto'):
        """
        Get both Arabic and English translations
        
        Args:
            text (str): Text to translate
            source_lang (str): Source language
        
        Returns:
            dict: Both Arabic and English versions
        """
        if source_lang == 'auto':
            source_lang = self.detect_language(text)
        
        result = {
            'original_text': text,
            'source_lang': source_lang,
            'arabic_text': text,
            'english_text': text
        }
        
        if source_lang == 'ar':
            # Translate to English
            en_translation = self.translate_text(text, target_lang='en', source_lang='ar')
            result['english_text'] = en_translation['translated_text']
        elif source_lang == 'en':
            # Translate to Arabic
            ar_translation = self.translate_text(text, target_lang='ar', source_lang='en')
            result['arabic_text'] = ar_translation['translated_text']
        
        return result
    
    def translate_case_for_doctor(self, case_data: Dict, doctor_language: str = 'en') -> Dict:
        """ترجمة الحالة الطبية للطبيب حسب لغته المفضلة"""
        return self.translate_medical_case(case_data, target_lang=doctor_language)
    
    def translate_response_for_patient(self, response_data: Dict, patient_language: str = 'ar') -> Dict:
        """ترجمة رد الطبيب للمريض حسب لغته المفضلة"""
        return self.translate_medical_case(response_data, target_lang=patient_language)
    
    def get_medical_suggestions(self, text: str, max_suggestions: int = 5) -> List[Dict]:
        """الحصول على اقتراحات المصطلحات الطبية"""
        suggestions = []
        text_lower = text.lower()
        
        # البحث في القاموس الطبي
        for arabic_term, english_term in self.medical_dictionary.items():
            if (text_lower in arabic_term.lower() or 
                text_lower in english_term.lower()):
                suggestions.append({
                    'arabic': arabic_term,
                    'english': english_term,
                    'relevance': len(text_lower) / max(len(arabic_term), len(english_term))
                })
        
        # ترتيب حسب الصلة
        suggestions.sort(key=lambda x: x['relevance'], reverse=True)
        return suggestions[:max_suggestions]

# إنشاء مثيل عام من خدمة الترجمة
translation_service = TranslationService()