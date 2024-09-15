import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui';

import 'package:kavach/screens/mainScreen.dart';
import 'package:kavach/components/components.dart';
import 'package:kavach/screens/otpScreen.dart';
import 'package:kavach/secrets.dart' as s;

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _controller = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isComplete = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSession();

    _controller.addListener(_checkInput);
  }

  Future<bool> _isUserRegistered() async {
    final userId = await _storage.read(key: 'user_id');
    return userId != null;
  }

  Future<void> _updateSession(String phoneNumber) async {
    await _storage.write(key: 'phoneNumber', value: phoneNumber);
  }

  void _checkSession() {
    _isUserRegistered().then((isRegistered) {
      if (isRegistered) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    });
  }

  void _checkInput() {
    setState(() {
      _isComplete = _controller.text.length == 10;
    });
  }

  Future<void> _sendOtp() async {
    final phoneNumber = _controller.text;

    try {
      setState(() {
        _isLoading = true;
      });
      final supabaseClient = SupabaseClient(s.supabaseUrl, s.supabaseAnonKey);
      await supabaseClient.auth.signInWithOtp(
        phone: '+91$phoneNumber',
      );

      setState(() {
        _isLoading = false;
      });

      _updateSession(phoneNumber);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(phoneNumber: phoneNumber),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                    'Create a free account to feel protected in your life',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
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
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your number',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 15.0,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: _isComplete ? _sendOtp : null,
                          child: Icon(
                            Icons.arrow_forward,
                            color: _isComplete ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
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
                  child: LoadingAnimationWidget.beat(
                      color: Colors.white, size: 50),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
