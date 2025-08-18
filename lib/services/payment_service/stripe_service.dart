import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/payment/ephemeral_key_model/ephemeral_key_model.dart';
import 'package:Athlify/models/payment/initPaymentSheetInputModel.dart';
import 'package:Athlify/models/payment/payment_intent_input_model.dart';
import 'package:Athlify/models/payment/payment_intent_model/payment_intent_model.dart';
import 'package:Athlify/services/payment_service/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StripeService {
  final ApiService apiService = ApiService();
  Future<PaymentIntentModel> createPaymentIntent(
      PaymentIntentInputModel paymentIntentInputModel) async {
    var response = await apiService.post(
      body: paymentIntentInputModel.toJson(),
      contentType: Headers.formUrlEncodedContentType,
      url: 'https://api.stripe.com/v1/payment_intents',
      token: secretKey,
    );

    var paymentIntentModel = PaymentIntentModel.fromJson(response.data);
    return paymentIntentModel;
  }

  Future initPaymentSheet(
      {required Initpaymentsheetinputmodel initpaymentsheetinputmodel}) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: initpaymentsheetinputmodel.clientSecrete,
        customerEphemeralKeySecret: initpaymentsheetinputmodel.ephemeralKey,
        customerId: initpaymentsheetinputmodel.customerId,
        merchantDisplayName: 'Athlify',
      ),
    );
  }

  Future displayPaymentSheet() async {
    await Stripe.instance.presentPaymentSheet();
  }

  Future makePayment(
      {required PaymentIntentInputModel paymentIntentInputModel}) async {
    var paymentIntentModel = await createPaymentIntent(paymentIntentInputModel);
    var ephemeralKeyModel = await createEphemeralKey(
        customerId: paymentIntentInputModel.customerId);

    var initpaymentsheetinputmodel = Initpaymentsheetinputmodel(
        clientSecrete: paymentIntentModel.clientSecret!,
        customerId: paymentIntentInputModel.customerId,
        ephemeralKey: ephemeralKeyModel.secret!);
    await initPaymentSheet(
        initpaymentsheetinputmodel: initpaymentsheetinputmodel);
    await displayPaymentSheet();
  }

  Future<String?> createStripeCustomer(
      String email, String name, String userId) async {
    try {
      print(
          "📩 Sending request to Stripe with: email=$email, name=$name, userId=$userId");
      final response = await apiService.post(
        url: 'https://api.stripe.com/v1/customers',
        token: secretKey,
        contentType: Headers.formUrlEncodedContentType,
        body: {
          'email': email,
          'name': name,
          'metadata[userId]': userId,
        },
      );

      final customerId = response.data['id'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('stripeCustomerId', customerId);

      print('✅ Stripe Customer Created: $customerId');
      return customerId; // ✅ رجعنا الـ ID هنا
    } catch (e) {
      if (e is DioException) {
        print('❌ Stripe Customer Creation Error: ${e.response?.data}');
      } else {
        print('❌ Unexpected Error: $e');
      }
      return null; // ❌ رجع null لو حصل خطأ
    }
  }

  Future<EphemeralKeyModel> createEphemeralKey(
      {required String customerId}) async {
    var response = await apiService.post(
        body: {'customer': customerId},
        contentType: Headers.formUrlEncodedContentType,
        url: 'https://api.stripe.com/v1/ephemeral_keys',
        token: secretKey,
        headers: {'Stripe-Version': '2025-05-28.basil'});

    var ephemeralKeyModel = EphemeralKeyModel.fromJson(response.data);
    return ephemeralKeyModel;
  }
}
