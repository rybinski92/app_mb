import 'package:flutter/material.dart';

const beginPosition = Alignment.topLeft;
const endPosition = Alignment.bottomRight;

class GradientContainer extends StatelessWidget {
  final List<Color> colors; // Kolory gradientu
  final Widget child; // Parametr child

  // Konstruktor
  const GradientContainer(
      {super.key, required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors, // Użycie przekazanych kolorów
            begin: beginPosition,
            end: endPosition,
          ),
        ),
        child: child, // Użycie widgetu przekazanego jako child
      ),
    );
  }
}
