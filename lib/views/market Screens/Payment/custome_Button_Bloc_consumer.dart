import 'package:Athlify/cubits/payment/cubit/payment_cubit.dart';
import 'package:Athlify/models/payment/payment_intent_input_model.dart';
import 'package:Athlify/views/market%20Screens/Payment/custome_payment_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomeButtonBlocConsumer extends StatelessWidget {
  final double amount;
  final VoidCallback onPaymentSuccess;

  const CustomeButtonBlocConsumer({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          Navigator.of(context).pop(); // Close the bottom sheet
          onPaymentSuccess(); // Call to continue with order saving
        } else if (state is PaymentFailure) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errMessage)),
          );
        }
      },
      builder: (context, state) {
        return CustomButton(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            final customerId = prefs.getString('stripeCustomerId');
            if (customerId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('❌ Missing Stripe customer ID')),
              );
              return;
            }
            final model = PaymentIntentInputModel(
              amount: amount.toInt(),
              currency: 'USD',
              customerId: customerId,
            );
            BlocProvider.of<PaymentCubit>(context)
                .makePayment(paymentIntentInputModel: model);
          },
          isLoading: state is PaymentLoading,
          text: 'Continue',
        );
      },
    );
  }
}
