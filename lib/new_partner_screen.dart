import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewPartnerScreen extends StatelessWidget {
  const NewPartnerScreen({super.key});

  // Funkcja do otwierania aplikacji mailowej
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'adam_mojbieg@gmail.com',
      query: 'subject=Zapytanie o współpracę&body=Witam, chciałbym zapytać o możliwość zostania partnerem.',
    );

    if (!await launchUrl(emailUri)) {
      throw 'Nie można otworzyć aplikacji e-mail.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zostań Partnerem"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tekst informacyjny
              const Text(
                "Jeśli chcesz, aby Twoje logo wyświetlało się w sekcji Partnerzy w aplikacji, "
                "skontaktuj się z nami mailowo, \n\n można dodać informację o długości planowanego partnerstwa "
                "np. 3 miesiące, pół roku, rok.\n\n"
                "Przygotujemy indywidualną ofertę.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),

              // Mail w formie graficznej
              GestureDetector(
                onTap: _sendEmail,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email, color: Colors.orange, size: 30),
                    const SizedBox(width: 10),
                    const Text(
                      "adam.mojbieg@gmail.com",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // Przycisk Powrót
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Powrót",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}