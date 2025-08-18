import 'package:Athlify/views/market%20Screens/Payment/custome_Button_Bloc_consumer.dart';
import 'package:Athlify/views/market%20Screens/Payment/payment_method_Listview.dart';
import 'package:flutter/material.dart';

class PaymentMethodsBottomSheet extends StatelessWidget {
  final double amount;
  final VoidCallback onPaymentSuccess;

  const PaymentMethodsBottomSheet({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const PaymentMethodsListView(),
          const SizedBox(height: 32),
          CustomeButtonBlocConsumer(
            amount: amount,
            onPaymentSuccess: onPaymentSuccess, // Pass callback here
          ),
        ],
      ),
    );
  }
}
