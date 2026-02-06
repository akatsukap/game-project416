import 'package:flutter/material.dart';
import 'horse_race_screen.dart';

void main() {
  runApp(const HorseRaceDevApp());
}

class HorseRaceDevApp extends StatelessWidget {
  const HorseRaceDevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HorseRaceScreen(),
    );
  }
}
