import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavach/screens/mainScreen.dart';
import 'package:permission_handler/permission_handler.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _hasPermissions = false;

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.serviceStatus.then((status) {
      setState(() => _hasPermissions = status == ServiceStatus.enabled);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    var baseTheme = ThemeData(brightness: Brightness.light);

    return MaterialApp(
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
      ),
      debugShowCheckedModeBanner: false,
      home: _hasPermissions
          ? const LogInScreen()
          : const Scaffold(
              body: Center(
                child: Text("Grant permission to use this app!"),
              ),
            ),
    );
  }
}
