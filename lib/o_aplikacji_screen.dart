import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OApkScreen extends StatelessWidget {
  const OApkScreen({super.key});

  // Funkcja do otwierania aplikacji mailowej
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'adam_mojbieg@gmail.com',
      query: 'subject=Kontakt w sprawie aplikacji&body=Witam, chciałbym się skontaktować w sprawie aplikacji.',
    );

    if (!await launchUrl(emailUri)) {
      throw 'Nie można otworzyć aplikacji e-mail.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("O aplikacji"),
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
                "Baza z zawodami odświeżana raz w tygodniu.\n\n"
                "Zawody, które zostały dodane i zaznaczono opcję promowania, "
                "pojawią się w ciągu 1-2 dni.\n\n"
                "Jeśli widzisz błąd, masz propozycję współpracy lub chcesz zostać Partnerem aplikacji, "
                "skontaktuj się z nami:\n\n",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),

              // Klikalny adres e-mail
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

              const SizedBox(height: 40),

              // Nazwa aplikacji na dole
              const Text(
                "a10i",
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}