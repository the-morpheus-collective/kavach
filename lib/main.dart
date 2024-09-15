import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavach/screens/mainScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    var baseTheme = ThemeData(brightness: Brightness.light);

    return MaterialApp(
      theme: baseTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme)),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
