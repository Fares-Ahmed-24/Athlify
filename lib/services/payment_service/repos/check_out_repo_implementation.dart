import 'package:Athlify/models/payment/payment_intent_input_model.dart';
import 'package:Athlify/services/payment_service/failur.dart';
import 'package:Athlify/services/payment_service/stripe_service.dart';
import 'package:Athlify/services/payment_service/repos/payment_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class CheckOutRepoImplementation extends CheckoutRepo {
  final StripeService stripeService = StripeService();

  @override
  Future<Either<Failure, void>> makePayment(
      {required PaymentIntentInputModel paymentIntentInputModel}) async {
    try {
      await stripeService.makePayment(
          paymentIntentInputModel: paymentIntentInputModel);
      return right(null);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return left(
            ServerFailure(errMessage: 'Payment was canceled by the user.'));
      } else {
        return left(ServerFailure(
            errMessage:
                'Payment failed: ${e.error.localizedMessage ?? "Unknown error"}'));
      }
    } catch (e) {
      return left(ServerFailure(errMessage: 'Unexpected error: $e'));
    }
  }
}
