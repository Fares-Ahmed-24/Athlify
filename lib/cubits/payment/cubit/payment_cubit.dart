import 'dart:developer';

import 'package:Athlify/models/payment/payment_intent_input_model.dart';
import 'package:Athlify/services/payment_service/repos/payment_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this.checkoutRepo) : super(PaymentInitial());

  final CheckoutRepo checkoutRepo;
  Future makePayment(
      {required PaymentIntentInputModel paymentIntentInputModel}) async {
    emit(PaymentLoading());

    var data = await checkoutRepo.makePayment(
        paymentIntentInputModel: paymentIntentInputModel);
    data.fold(
      (L) => emit(PaymentFailure(errMessage: L.errMessage)),
      (r) => emit(
        PaymentSuccess(),
      ),
    );
  }

  @override
  void onChange(Change<PaymentState> change) {
    log(change.toString());
    super.onChange(change);
  }
}
