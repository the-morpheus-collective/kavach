import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavach/screens/mainScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:kavach/secrets.dart' as s;
import 'package:kavach/screens/tempScreen.dart';
import 'package:kavach/components/components.dart';
import 'package:kavach/screens/registerScreen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool isButtonEnabled = false;
  bool _isLoading = false;

  Color primaryColor = const Color(0xFF121212);
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  void checkIfOtpIsComplete(String code) {
    if (code.length == 6) {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text;

    try {
      setState(() {
        _isLoading = true;
      });
      final supabaseClient = SupabaseClient(s.supabaseUrl, s.supabaseAnonKey);
      final response = await supabaseClient.auth.verifyOTP(
        phone: '+91${widget.phoneNumber}',
        token: otp,
        type: OtpType.sms,
      );

      print(response);
      setState(() {
        _isLoading = false;
      });

      if (response.user != null) {
        final isRegistered = await _isUserRegistered();
        if (isRegistered) {
          print("User is already registered");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        } else {
          await _updateSession(widget.phoneNumber);
          print("User is not registered");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RegisterScreen(phoneNumber: widget.phoneNumber),
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Invalid OTP. Please try again.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error: ${error.toString()}'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<bool> _isUserRegistered() async {
    final userId = await _storage.read(key: 'user_id');
    return userId != null;
  }

  Future<void> _updateSession(String userId) async {
    await _storage.write(key: 'user_id', value: userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const TopScreenImage(screenImageName: "logo.png"),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  'We have sent you a PIN to the number +91 ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              OtpTextField(
                numberOfFields: 6,
                borderColor: primaryColor,
                focusedBorderColor: primaryColor,
                showFieldAsBox: false,
                borderWidth: 4.0,
                onCodeChanged: (String code) {
                  checkIfOtpIsComplete(code);
                },
                onSubmit: (String verificationCode) {
                  checkIfOtpIsComplete(verificationCode);
                  _otpController.text = verificationCode;
                },
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: isButtonEnabled ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? const Color(0xFFFF6666)
                        : const Color(0xFFE57373),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    )),
                child: Text(
                  'Ready to unlock the future of Security?',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child:
                    LoadingAnimationWidget.beat(color: Colors.white, size: 50),
              ),
            ),
          ),
      ]),
    );
  }
}
