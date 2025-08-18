import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/views/auth_view/signIn.dart';
import 'package:Athlify/widget/textField.dart';
import '../../services/createUser.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool _passwordVisible = true;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final createUser = CreateUserService();

  String? userType;
  bool showDropdown = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  backgroundColor: const Color(0XffE9E9E9),
                  child: IconButton(
                    color: PrimaryColor,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Register Now",
                      style: TextStyle(
                        color: PrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const Text(
                        "Sign up to get started with your email and password"),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      CustomTextFormField(
                        controller: emailController,
                        labelText: "Email",
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      CustomTextFormField(
                        controller: userNameController,
                        labelText: "Username",
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z\s]")),
                        ],
                        prefixIcon: Icons.person,
                      ),
                      CustomTextFormField(
                        controller: ageController,
                        labelText: "Age",
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        prefixIcon: Icons.calendar_month,
                        keyboardType: TextInputType.number,
                        maxlength: 2,
                      ),
                      CustomTextFormField(
                        controller: phoneController,
                        labelText: "Mobile Phone",
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.number,
                        maxlength: 11,
                      ),
                      CustomTextFormField(
                        controller: passwordController,
                        labelText: "Password",
                        suffixIcon: IconButton(
                          icon: Icon(_passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        prefixIcon: Icons.lock_outline,
                        obscureText: _passwordVisible,
                      ),

                      /// Inline Dropdown instead of dialog
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showDropdown = !showDropdown;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "You are a club owner or trainer?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Icon(
                                showDropdown
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (showDropdown)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: userType,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(23)),
                            hint: Text("Select user type"),
                            onChanged: (newValue) {
                              setState(() {
                                userType = newValue;
                                showDropdown = false;
                              });
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'trainer',
                                child: Text('Trainer'),
                              ),
                              DropdownMenuItem(
                                value: 'clubowner',
                                child: Text('Club Owner'),
                              ),
                            ],
                          ),
                        ),

                      if (userType != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            "Selected: $userType",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);

                          var response = await createUser.signUp(
                            userNameController.text,
                            emailController.text,
                            passwordController.text,
                            ageController.text,
                            phoneController.text,
                            userType,
                          );

                          int resp = response['statusCode'];
                          String message = response['message'];

                          setState(() => _isLoading = false);

                          if (resp == 201) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Signin()),
                            );
                          } else {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              animType: AnimType.rightSlide,
                              title: 'Failed',
                              desc: message,
                              btnCancelOnPress: () {},
                              btnOkOnPress: () {},
                            ).show();
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PrimaryColor,
                  fixedSize: const Size(380, 60),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "Sign up",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
