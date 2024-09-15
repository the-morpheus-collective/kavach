import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import 'package:kavach/secrets.dart' as s;
import 'package:kavach/components/components.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool isButtonEnabled = false;
  Color primaryColor = const Color(0xFF121212);
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

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
      final supabaseClient = SupabaseClient(s.supabaseUrl, s.supabaseAnonKey);
      final response = await supabaseClient.auth.verifyOTP(
        phone: '+91${widget.phoneNumber}',
        token: otp,
        type: OtpType.sms,
      );

      print(response);

      if (response.user != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('OTP verification successful!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
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
      ),
    );
  }
}
