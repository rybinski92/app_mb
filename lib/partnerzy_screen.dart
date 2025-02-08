import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'new_partner_screen.dart'; // Import nowego ekranu

class PartnerzyScreen extends StatelessWidget {
  const PartnerzyScreen({super.key});

  // Funkcja do otwierania linku w przeglądarce
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Nie można otworzyć $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partnerzy'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700, // Ograniczamy szerokość formularza
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Lista partnerów
                _buildPartnerCard(
                  "Sportiva",
                  "zdjecia/partnerzy/sportiva.jpg",
                  "https://www.sportiva.pl/",
                ),
                const SizedBox(height: 20),
                _buildPartnerCard(
                  "Zen.com Expo",
                  "zdjecia/partnerzy/zen_com.jpg",
                  "https://stage.expo.zen.com/",
                ),
                const SizedBox(height: 30),

                // Przycisk "Zostań Partnerem"
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    // Przechodzi do nowego ekranu
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NewPartnerScreen()),
                    );
                  },
                  child: const Text(
                    'Zostań Partnerem',
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

  // Funkcja do tworzenia karty z informacjami o partnerze
  Widget _buildPartnerCard(String name, String logoPath, String link) {
    return GestureDetector(
      onTap: () => _launchURL(link), // Otwiera link po kliknięciu
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Logo partnera
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  logoPath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              // Nazwa partnera
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Ikona otwierania linku
              const Icon(
                Icons.link,
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
