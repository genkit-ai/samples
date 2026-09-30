// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Application shell and Material 3 dark theme for Cymbal Bistro.
library;

import 'package:flutter/material.dart';

import 'chat_page.dart';

class A2uiApp extends StatelessWidget {
  const A2uiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF070B13);
    const surfaceDark = Color(0xFF0F1827);
    const borderDark = Color(0xFF222D47);
    const primaryBlue = Color(0xFF6582CC);
    const lightText = Color(0xFFE2E8F0);

    return MaterialApp(
      title: 'Cymbal Bistro - A2UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        colorScheme: const ColorScheme.dark(
          surface: surfaceDark,
          surfaceContainerHighest: Color(0xFF141F32),
          primary: primaryBlue,
          onPrimary: Colors.white,
          secondary: Color(0xFF7FA2FF),
          outline: borderDark,
        ),
        cardTheme: CardThemeData(
          color: surfaceDark,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borderDark, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceDark,
          selectedColor: const Color(0xFF1E325C),
          checkmarkColor: const Color(0xFF93B4FF),
          side: const BorderSide(color: borderDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          labelStyle: const TextStyle(color: lightText, fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0A101C),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 1.5),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: primaryBlue,
          inactiveTrackColor: const Color(0xFF1A2946),
          thumbColor: const Color(0xFF7FA2FF),
          overlayColor: primaryBlue.withValues(alpha: 0.2),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryBlue;
            }
            return Colors.transparent;
          }),
          side: const BorderSide(color: borderDark, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        useMaterial3: true,
      ),
      home: const ChatPage(),
    );
  }
}
