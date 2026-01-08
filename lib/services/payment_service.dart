import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  PaymentService._internal();
  static final PaymentService instance = PaymentService._internal();

  Razorpay? _razorpay;

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
  }) {
    _razorpay ??= Razorpay();

    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});
  }

  void openCheckout({
    required String orderId,
    required int amount,
    required String name,
    required String description,
  }) {
    final options = {
      'key': 'rzp_test_RrlPuxMVwuuslq',
      'amount': amount * 100,
      'currency': 'INR',
      'order_id': orderId,
      'name': name,
      'description': description,
      'timeout': 180, // IMPORTANT
    };

    _razorpay!.open(options);
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
