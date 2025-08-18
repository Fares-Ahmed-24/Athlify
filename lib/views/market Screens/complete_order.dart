import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/cubits/payment/cubit/payment_cubit.dart';
import 'package:Athlify/models/user_model.dart';
import 'package:Athlify/services/UserController.dart';
import 'package:Athlify/services/market/orderpage_service.dart';
import 'package:Athlify/services/payment_service/repos/check_out_repo_implementation.dart';
import 'package:Athlify/views/market%20Screens/Payment/PaymentMethodBottomSheet.dart';
import 'package:Athlify/views/market%20Screens/orderSuccess.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class CompleteOrderPage extends StatefulWidget {
  final double totalPrice;
  final String userId;
  final List<Map<String, dynamic>> cartProducts;

  CompleteOrderPage({
    required this.totalPrice,
    required this.userId,
    required this.cartProducts,
  });

  @override
  _CompleteOrderPageState createState() => _CompleteOrderPageState();
}

class _CompleteOrderPageState extends State<CompleteOrderPage> {
  final _formKey = GlobalKey<FormState>();

  String _paymentMethod = '';
  String? _name, _phone, _address, _email;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isAddingNewInfo = false;
  Map<String, String?> _previousInfo = {};
  bool _isLoadingInfo = true;

  @override
  void initState() {
    super.initState();
    _fetchPreviousUserInfo();
  }

  void _fetchPreviousUserInfo() async {
    final result = await UserController().getUserByEmail();
    if (result['success']) {
      final user = result['user'] as User;
      setState(() {
        _previousInfo = {
          'name': user.Username,
          'phone': user.phone,
          'email': user.email,
        };
        _nameController.text = user.Username;
        _phoneController.text = user.phone;
        _emailController.text = user.email;
        _isLoadingInfo = false;
      });
    } else {
      setState(() => _isLoadingInfo = false);
    }
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethod = method;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                method == 'Visa' ? 'Add new card' : method,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Radio<String>(
              value: method,
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onSaved,
    required String? Function(String?) validator,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          counterText: maxLength != null ? "" : null,
        ),
        validator: validator,
        onSaved: (value) => onSaved(value!),
      ),
    );
  }

  void _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || _paymentMethod.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Missing Information"),
          content: Text(
              "Please fill in all required fields and select a payment method."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    _formKey.currentState?.save();

    // ✅ استخدم البيانات حسب حالة الـ form
    _name = _isAddingNewInfo ? _nameController.text : _previousInfo['name'];
    _phone = _isAddingNewInfo ? _phoneController.text : _previousInfo['phone'];
    _email = _isAddingNewInfo ? _emailController.text : _previousInfo['email'];
    _address = _addressController.text;

    Future<void> submitOrder() async {
      final orderData = {
        "name": _name,
        "phone": _phone,
        "address": _address,
        "email": _email,
        "paymentMethod": _paymentMethod,
        "subtotal": widget.totalPrice,
        "delivery": 50.0,
        "totalPrice": widget.totalPrice + 50.0,
        "userId": widget.userId,
        "date": DateTime.now().toIso8601String(),
        "products": widget.cartProducts.map((product) {
          return {
            "productId": product["_id"],
            "productName": product["productName"],
            "productImage": product["productImage"],
            "productPrice": product["productPrice"],
            "productDescription": product["productDescription"] ?? "",
            "quantity": product["quantity"],
            "size": product["selectedSize"] ?? null,
          };
        }).toList(),
      };

      // باقي الكود كما هو...

      bool success = await OrderService.submitOrder(orderData);

      if (success) {
        try {
          final email = _emailController.text;
          final response = await http.delete(
            Uri.parse('$baseUrl/api/users/cart/$email'),
          );
        } catch (e) {
          print("Error clearing cart: $e");
        }

        _formKey.currentState?.reset();
        _nameController.clear();
        _phoneController.clear();
        _addressController.clear();
        _emailController.clear();
        setState(() {
          _paymentMethod = '';
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OrderSuccessPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting order")),
        );
      }
    }

    if (_paymentMethod == 'Visa') {
      showModalBottomSheet(
        backgroundColor: ContainerColor,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return BlocProvider(
            create: (context) => PaymentCubit(CheckOutRepoImplementation()),
            child: PaymentMethodsBottomSheet(
              amount: widget.totalPrice + 50,
              onPaymentSuccess: () async {
                await submitOrder();
              },
            ),
          );
        },
      );
      return;
    } else {
      await submitOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title:
            Text('Complete Your Order', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff243555),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Customer Information",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                if (!_isAddingNewInfo && !_isLoadingInfo)
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: ContainerColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text("Name"),
                          subtitle: Text(_previousInfo['name'] ?? ''),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text("Phone"),
                          subtitle: Text(_previousInfo['phone'] ?? ''),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text("Email"),
                          subtitle: Text(_previousInfo['email'] ?? ''),
                        ),
                        SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _isAddingNewInfo = true);
                          },
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Add New Information",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff243555),
                          ),
                        )
                      ],
                    ),
                  ),
                if (_isAddingNewInfo)
                  Column(
                    children: [
                      _buildTextField(
                        label: "Full Name",
                        controller: _nameController,
                        onSaved: (val) {
                          _name = val != null && val.isNotEmpty
                              ? val
                              : _previousInfo['name'];
                        },
                        validator: (val) {
                          final oldVal = _previousInfo['name'];
                          if ((val == null || val.isEmpty) &&
                              (oldVal == null || oldVal.isEmpty)) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: "Phone Number",
                        controller: _phoneController,
                        inputType: TextInputType.number,
                        maxLength: 11,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        onSaved: (val) {
                          _phone = val != null && val.isNotEmpty
                              ? val
                              : _previousInfo['phone'];
                        },
                        validator: (val) {
                          final oldVal = _previousInfo['phone'];
                          if ((val == null || val.isEmpty) &&
                              (oldVal == null || oldVal.isEmpty)) {
                            return 'Phone is required';
                          }
                          if ((val ?? oldVal)!.length != 11) {
                            return 'Phone must be 11 digits';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: "Email",
                        controller: _emailController,
                        inputType: TextInputType.emailAddress,
                        onSaved: (val) {
                          _email = val != null && val.isNotEmpty
                              ? val
                              : _previousInfo['email'];
                        },
                        validator: (val) {
                          final oldVal = _previousInfo['email'];
                          final email = val ?? oldVal;

                          if (email == null || email.isEmpty)
                            return 'Email is required';

                          if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w]{2,4}$')
                              .hasMatch(email)) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                _buildTextField(
                  label: "Address",
                  controller: _addressController,
                  onSaved: (val) => _address = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Address is required' : null,
                ),
                SizedBox(height: 32),
                Text("Payment Summary",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                summaryRow(
                    "Subtotal", "EGP ${widget.totalPrice.toStringAsFixed(2)}"),
                summaryRow("Delivery", "EGP 50.00"),
                Divider(thickness: 1.2),
                summaryRow("Total",
                    "EGP ${(widget.totalPrice + 50.00).toStringAsFixed(2)}",
                    bold: true),
                SizedBox(height: 30),
                Text("Choose Payment Method",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildPaymentOption('Cash', Icons.money),
                _buildPaymentOption('Visa', Icons.credit_card),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff243555),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text("Checkout",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
