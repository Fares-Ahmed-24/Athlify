import 'package:Athlify/models/payment/payment_intent_input_model.dart';
import 'package:Athlify/services/payment_service/failur.dart';
import 'package:dartz/dartz.dart';

abstract class CheckoutRepo {
  Future<Either<Failure, void>> makePayment(
      {required PaymentIntentInputModel paymentIntentInputModel});
}
