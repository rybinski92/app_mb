import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';

class OApkScreen extends StatefulWidget {
  const OApkScreen({super.key});

  @override
  _OApkScreenState createState() => _OApkScreenState();
}

class _OApkScreenState extends State<OApkScreen> {
  final TextEditingController _controller = TextEditingController();
  final String apiUrl =
      "https://api.appsheet.com/api/v2/apps/3b42e9e3-47fd-4cf0-8ee4-aefaab5b9795/tables/Arkusz1/Add";
  final String apiKey = Config.apiKey4;



// Funkcja do wysyłania wiadomości do AppSheet
  Future<void> _sendMessageToAppSheet() async {
    if (_controller.text.isEmpty) {
      _showSnackBar('Proszę wpisać wiadomość', Colors.red); // Czerwony SnackBar
      return;
    }

    final String message = _controller.text;
    // final String? apiKey4 = await Config.getApiKey4();

    try {
      final url = Uri.parse(apiUrl);
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json; charset=utf-8",
          "ApplicationAccessKey": apiKey,
          // "ApplicationAccessKey": apiKey4 ?? "",
        },
        body: jsonEncode({
          "Action": "Add",
          "Properties": {"Locale": "pl-PL"},
          "Rows": [
            {
              "tematy": message
            }, 
          ],
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar(
            'Wiadomość została wysłana', Colors.green); // Zielony SnackBar
        _controller.clear(); // Czyści pole tekstowe
      } else {
        _showSnackBar('Błąd wysyłania wiadomości: ${response.statusCode}',
            Colors.red); // Czerwony SnackBar
      }
    } catch (e) {
      _showSnackBar('Błąd: $e', Colors.red); // Czerwony SnackBar
    }
  }

  // Funkcja do wyświetlania SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color, // Kolor tła
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("O aplikacji"),
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
                  "Zawody, które zostały dodane pojawią się w ciągu 1-2 dni.\n\n"
                  "Jeśli widzisz błąd, masz propozycję współpracy lub chcesz zostać Partnerem aplikacji, "
                  "skontaktuj się z nami:\n\n",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),

                // Pole tekstowe do wiadomości
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  maxLength: 500, // Ustawienie limitu znaków
                  decoration: const InputDecoration(
                    labelText: "Napisz wiadomość",
                    hintText: "Wpisz wiadomość do nas (max 500 znaków)",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4, // Ustalamy wysokość pola
                ),
                const SizedBox(height: 15),

                // Przycisk wyślij wiadomość
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  onPressed: _sendMessageToAppSheet,
                  child: const Text(
                    "Wyślij wiadomość",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),

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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

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

                const SizedBox(height: 30),

                // Nazwa aplikacji na dole
                const Text(
                  "a10i",
                  style: TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Funkcja do otwierania aplikacji mailowej
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'adam_mojbieg@gmail.com',
      query:
          'subject=Kontakt w sprawie aplikacji&body=Witam, chciałbym się skontaktować w sprawie aplikacji.',
    );

    if (!await launchUrl(emailUri)) {
      throw 'Nie można otworzyć aplikacji e-mail.';
    }
  }
}
