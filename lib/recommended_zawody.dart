import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendedZawodyScreen extends StatelessWidget {
  const RecommendedZawodyScreen({super.key});

  // Funkcja do otwierania aplikacji mailowej
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'adam_mojbieg@gmail.com',
      query:
          'subject=Zapytanie o Polecane Zawody&body=Witam, chciałbym dodać moje zawody do sekcji Polecane Zawody. Oto szczegóły:\n\nNazwa zawodów: \nData: \nMiejsce: \nWojewództwo: \nLink do strony zawodów:',
    );

    if (!await launchUrl(emailUri)) {
      throw 'Nie można otworzyć aplikacji e-mail.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Polecane Zawody"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700, // Ograniczamy szerokość formularza
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tekst informacyjny
                const Text(
                  "Jeśli chcesz, aby Twoje zawody były wyświetlane na stronie głównej "
                  "w sekcji Polecane zawody, wyślij do nas maila z informacjami: "
                  "nazwa zawodów, data, miejsce, województwo, link do strony zawodów. "
                  "Dodanie zawodów do tej sekcji wiąże się z opłatą, którą podamy w odpowiedzi na mail.",
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // Przycisk Powrót
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
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
      ),
    );
  }
}
