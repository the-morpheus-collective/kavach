import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui';
import 'dart:async';

import 'package:kavach/components/components.dart';
import 'package:kavach/secrets.dart' as s;

class RegisterScreen extends StatefulWidget {
  final String phoneNumber;

  const RegisterScreen({super.key, required this.phoneNumber});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _controllerFName = TextEditingController();
  final TextEditingController _controllerLName = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  void checkIfFilled() {
    if (_controllerFName.text.isNotEmpty && _controllerLName.text.isNotEmpty) {
      setState(() {
        _isButtonEnabled = true;
      });
    } else {
      setState(() {
        _isButtonEnabled = false;
      });
    }
  }

  Future<void> _register() async {
    final firstName = _controllerFName.text;
    final lastName = _controllerLName.text;

    try {
      setState(() {
        _isLoading = true;
      });

      final supabaseClient = SupabaseClient(s.supabaseUrl, s.supabaseAnonKey);

      await supabaseClient.from('users').insert({
        'username': '$firstName $lastName',
        'phone_number': widget.phoneNumber,
      });

      setState(() {
        _isLoading = false;
      });

      // @PJR - This is where we will navigate to the next screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => PjrOGScreen(phoneNumber: phoneNumber),
      //   ),
      // );
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
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
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
                  'Register your account',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      border: const Border(
                        top: BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        left: BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 4,
                        ),
                        right: BorderSide(
                          color: Colors.black,
                          width: 4,
                        ),
                      ),
                    ),
                    child: TextFormField(
                      controller: _controllerFName,
                      decoration: InputDecoration(
                        hintText: 'Enter your First Name',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 15.0,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (String fName) {
                        checkIfFilled();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      border: const Border(
                        top: BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        left: BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 4,
                        ),
                        right: BorderSide(
                          color: Colors.black,
                          width: 4,
                        ),
                      ),
                    ),
                    child: TextFormField(
                      controller: _controllerLName,
                      decoration: InputDecoration(
                        hintText: 'Enter your Last Name',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 15.0,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (String lName) {
                        checkIfFilled();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isButtonEnabled ? _register : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonEnabled
                            ? const Color(0xFFFF6666)
                            : const Color(0xFFE57373),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        )),
                    child: Text(
                      'Get started',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
