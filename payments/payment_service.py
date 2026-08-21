"""
Payment Service for Medical Platform
Handles Stripe and PayPal payment processing
"""

import stripe
import paypalrestsdk
from django.conf import settings
from django.utils import timezone
from decimal import Decimal
import logging
import uuid

logger = logging.getLogger(__name__)

# Configure Stripe safely (development fallback)
STRIPE_SECRET_KEY = getattr(settings, 'STRIPE_SECRET_KEY', None)
STRIPE_ENABLED = bool(STRIPE_SECRET_KEY)
if STRIPE_ENABLED:
    stripe.api_key = STRIPE_SECRET_KEY
else:
    logger.warning("Stripe is not configured (STRIPE_SECRET_KEY missing). Payments via Stripe will be disabled in this environment.")

# Configure PayPal safely (development fallback)
PAYPAL_MODE = getattr(settings, 'PAYPAL_MODE', None)
PAYPAL_CLIENT_ID = getattr(settings, 'PAYPAL_CLIENT_ID', None)
PAYPAL_CLIENT_SECRET = getattr(settings, 'PAYPAL_CLIENT_SECRET', None)
PAYPAL_ENABLED = all([PAYPAL_MODE, PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET])
if PAYPAL_ENABLED:
    paypalrestsdk.configure({
        "mode": PAYPAL_MODE,
        "client_id": PAYPAL_CLIENT_ID,
        "client_secret": PAYPAL_CLIENT_SECRET
    })
else:
    logger.warning("PayPal is not fully configured (PAYPAL_MODE/CLIENT_ID/CLIENT_SECRET missing). PayPal will be disabled in this environment.")

class PaymentService:
    
    @staticmethod
    def create_stripe_payment_intent(amount, currency='sar', metadata=None):
        """
        Create a Stripe Payment Intent
        
        Args:
            amount (Decimal): Amount in the smallest currency unit
            currency (str): Currency code
            metadata (dict): Additional metadata
        
        Returns:
            dict: Payment intent data or error
        """
        try:
            # Convert amount to cents/halalas
            amount_cents = int(amount * 100)
            
            intent = stripe.PaymentIntent.create(
                amount=amount_cents,
                currency=currency,
                metadata=metadata or {},
                automatic_payment_methods={
                    'enabled': True,
                },
            )
            
            return {
                'success': True,
                'payment_intent_id': intent.id,
                'client_secret': intent.client_secret,
                'amount': amount,
                'currency': currency
            }
            
        except stripe.error.StripeError as e:
            logger.error(f"Stripe error: {e}")
            return {
                'success': False,
                'error': str(e)
            }
        except Exception as e:
            logger.error(f"Payment intent creation error: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    @staticmethod
    def confirm_stripe_payment(payment_intent_id):
        """
        Confirm a Stripe payment
        
        Args:
            payment_intent_id (str): Payment intent ID
        
        Returns:
            dict: Payment confirmation result
        """
        try:
            intent = stripe.PaymentIntent.retrieve(payment_intent_id)
            
            return {
                'success': True,
                'status': intent.status,
                'amount': intent.amount / 100,  # Convert back from cents
                'currency': intent.currency,
                'payment_method': intent.payment_method
            }
            
        except stripe.error.StripeError as e:
            logger.error(f"Stripe confirmation error: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    @staticmethod
    def create_paypal_payment(amount, currency='USD', description='Medical Consultation'):
        """
        Create a PayPal payment
        
        Args:
            amount (Decimal): Payment amount
            currency (str): Currency code
            description (str): Payment description
        
        Returns:
            dict: PayPal payment data or error
        """
        try:
            payment = paypalrestsdk.Payment({
                "intent": "sale",
                "payer": {
                    "payment_method": "paypal"
                },
                "redirect_urls": {
                    "return_url": f"{settings.SITE_URL}/payments/paypal/success/",
                    "cancel_url": f"{settings.SITE_URL}/payments/paypal/cancel/"
                },
                "transactions": [{
                    "item_list": {
                        "items": [{
                            "name": description,
                            "sku": "consultation",
                            "price": str(amount),
                            "currency": currency,
                            "quantity": 1
                        }]
                    },
                    "amount": {
                        "total": str(amount),
                        "currency": currency
                    },
                    "description": description
                }]
            })
            
            if payment.create():
                # Find approval URL
                approval_url = None
                for link in payment.links:
                    if link.rel == "approval_url":
                        approval_url = link.href
                        break
                
                return {
                    'success': True,
                    'payment_id': payment.id,
                    'approval_url': approval_url
                }
            else:
                logger.error(f"PayPal payment creation error: {payment.error}")
                return {
                    'success': False,
                    'error': payment.error
                }
                
        except Exception as e:
            logger.error(f"PayPal payment error: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    @staticmethod
    def execute_paypal_payment(payment_id, payer_id):
        """
        Execute a PayPal payment
        
        Args:
            payment_id (str): PayPal payment ID
            payer_id (str): Payer ID
        
        Returns:
            dict: Payment execution result
        """
        try:
            payment = paypalrestsdk.Payment.find(payment_id)
            
            if payment.execute({"payer_id": payer_id}):
                return {
                    'success': True,
                    'payment_id': payment_id,
                    'status': payment.state,
                    'amount': payment.transactions[0].amount.total,
                    'currency': payment.transactions[0].amount.currency
                }
            else:
                logger.error(f"PayPal execution error: {payment.error}")
                return {
                    'success': False,
                    'error': payment.error
                }
                
        except Exception as e:
            logger.error(f"PayPal execution error: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    @staticmethod
    def calculate_platform_fee(amount, commission_rate=None):
        """
        Calculate platform commission fee
        
        Args:
            amount (Decimal): Original amount
            commission_rate (Decimal): Commission rate percentage
        
        Returns:
            dict: Fee calculation breakdown
        """
        if commission_rate is None:
            commission_rate = Decimal(str(settings.PLATFORM_COMMISSION_RATE))
        
        platform_fee = amount * (commission_rate / 100)
        doctor_amount = amount - platform_fee
        
        return {
            'original_amount': amount,
            'platform_fee': platform_fee,
            'doctor_amount': doctor_amount,
            'commission_rate': commission_rate
        }
    
    @staticmethod
    def process_consultation_payment(patient, doctor, case, amount, payment_method='stripe'):
        """
        Process a consultation payment
        
        Args:
            patient: Patient instance
            doctor: Doctor instance
            case: MedicalCase instance
            amount (Decimal): Payment amount
            payment_method (str): Payment method ('stripe' or 'paypal')
        
        Returns:
            dict: Payment processing result
        """
        from .models import Payment
        
        try:
            # Calculate fees
            fee_breakdown = PaymentService.calculate_platform_fee(amount)
            
            # Create payment record
            payment = Payment.objects.create(
                user=patient.user,
                case=case,
                doctor=doctor,
                amount=amount,
                payment_purpose='consultation',
                description=f'استشارة طبية - د. {doctor.user.first_name} {doctor.user.last_name}'
            )
            
            # Process payment based on method
            if payment_method == 'stripe':
                result = PaymentService.create_stripe_payment_intent(
                    amount=amount,
                    metadata={
                        'payment_id': payment.payment_id,
                        'patient_id': patient.id,
                        'doctor_id': doctor.id,
                        'case_id': case.id
                    }
                )
            elif payment_method == 'paypal':
                result = PaymentService.create_paypal_payment(
                    amount=amount,
                    description=f'Medical Consultation - Dr. {doctor.user.first_name}'
                )
            else:
                return {
                    'success': False,
                    'error': 'Unsupported payment method'
                }
            
            if result['success']:
                payment.transaction_id = result.get('payment_intent_id') or result.get('payment_id')
                payment.status = 'processing'
                payment.save()
                
                return {
                    'success': True,
                    'payment': payment,
                    'fee_breakdown': fee_breakdown,
                    **result
                }
            else:
                payment.status = 'failed'
                payment.save()
                return result
                
        except Exception as e:
            logger.error(f"Consultation payment error: {e}")
            return {
                'success': False,
                'error': str(e)
            }

# Global instance
payment_service = PaymentService()