import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'package:kavach/components/components.dart';

class TempScreen extends StatefulWidget {
  const TempScreen({super.key});

  @override
  State<TempScreen> createState() => _TempScreenState();
}

class _TempScreenState extends State<TempScreen> {
  @override
  void initState() {
    super.initState();
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
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
