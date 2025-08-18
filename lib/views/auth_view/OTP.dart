import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/auth.dart';
import 'package:Athlify/views/auth_view/setNewpassword.dart';
import 'package:Athlify/widget/button.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: OTPInputPage(email: ''),
  ));
}

class OTPInputPage extends StatefulWidget {
  final String email;

  const OTPInputPage({Key? key, required this.email}) : super(key: key);

  @override
  _OTPInputPageState createState() => _OTPInputPageState();
}

class _OTPInputPageState extends State<OTPInputPage> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  Timer? _timer;
  int _start = 300; // 5 minutes in seconds
  bool _isResendEnabled = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _isResendEnabled = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> resendOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.sendOTP(widget.email);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _start = 300;
          _isResendEnabled = false;
          _isLoading = false;
        });
        startTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resend code. Please try again later'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String getOTP() {
    return _controllers.map((c) => c.text).join();
  }

  String get timerText {
    final minutes = (_start ~/ 60).toString().padLeft(2, '0');
    final seconds = (_start % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[100],
            padding: const EdgeInsets.all(12),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
              child:FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      height: screenHeight * 0.3,
                      width: screenWidth * 0.7,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Icon(
                          Icons.check_circle_outline,
                          color: Colors.grey[350],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  const Text(
                    'Enter Verification Code',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'We have sent a verification code to\n${widget.email}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      return SizedBox(
                        width: screenWidth * 0.15,
                        height: screenWidth * 0.15,
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                            counterText: '',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: PrimaryColor,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) => _onChanged(value, index),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: Colors.grey[600],
                            size: screenWidth * 0.05,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            'Time remaining: $timerText',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : TextButton(
                            onPressed: _isResendEnabled ? resendOTP : null,
                            child: Text(
                              'Resend Code',
                              style: TextStyle(
                                color: _isResendEnabled ? PrimaryColor : Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                    child: SizedBox(
                      width: double.infinity,
                      child: Custbutton(
                        text: 'Verify OTP',
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
              
                          try {
                            final otpResult = await _authService.verifyOTP(
                              widget.email,
                              getOTP(),
                            );
              
                            if (otpResult['success'] && otpResult['isVerified']) {
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Newpassword(email: widget.email),
                                  ),
                                );
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(otpResult['message']),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Something went wrong. Please try again.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
