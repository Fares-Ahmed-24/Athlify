part of 'payment_cubit.dart';

@immutable
sealed class PaymentState {}

final class PaymentInitial extends PaymentState {}

final class PaymentLoading extends PaymentState {}

final class PaymentSuccess extends PaymentState {}

class PaymentFailure extends PaymentState {
  final String errMessage;

  PaymentFailure({required this.errMessage});
}
