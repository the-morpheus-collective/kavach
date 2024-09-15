import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import 'package:kavach/screens/otpScreen.dart';
import 'package:kavach/screens/loginScreen.dart';
// import 'package:kavach/screens/mainScreen.dart';

import 'package:kavach/secrets.dart' as s;

Future<void> main() async {
  await Supabase.initialize(
    url: s.supabaseUrl,
    anonKey: s.supabaseAnonKey,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LogInScreen(),
      // OtpScreen(phoneNumber: '9611118400',),
    );
  }
}
