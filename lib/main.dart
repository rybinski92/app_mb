import 'package:flutter/material.dart';
import 'package:app_kb/zawody_screen.dart';
import 'package:app_kb/kalkulator_screen.dart';
import 'package:app_kb/o_aplikacji_screen.dart';
import 'package:app_kb/partnerzy_screen.dart';
import 'package:app_kb/dodaj_zawody_screen.dart';
import 'package:app_kb/recommended_zawody.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mój Bieg',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> polecaneZawody = [];

  // URL AppSheet API (Zmień na swój)
  final String apiUrl = "https://api.appsheet.com/api/v2/apps/5408db07-71e1-4309-a30a-dc9c7c1ae7a3/tables/Arkusz1/records";
  final String apiKey = "V2-ntiId-0dGpB-P6FJ7-85gTl-dH3t4-0yYCV-daevp-gBs1Q";

  @override
  void initState() {
    super.initState();
    _fetchPolecaneZawody();
  }

  Future<void> _fetchPolecaneZawody() async {
  try {
    final url = Uri.parse("https://api.appsheet.com/api/v2/apps/5408db07-71e1-4309-a30a-dc9c7c1ae7a3/tables/Arkusz1/records");
    
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json; charset=utf-8",
        "ApplicationAccessKey": "V2-ZLb8Y-JzyV1-eUXjV-46Nbq-oFpXU-jr8IP-Eozsk-7aEOK"
      },
      body: jsonEncode({    "Action": "Find", // AppSheet wymaga tej akcji do pobierania danych
    "Properties": {
      "Locale": "pl-PL"
    },
    "Rows": []}) // pusty JSON – AppSheet może tego wymagać!
    );

    // print("📩 Odpowiedź API (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        print("⚠ API zwróciło pustą odpowiedź!");
        return;
      }

      // Ręczne dekodowanie odpowiedzi jako UTF-8
      final decodedBody = utf8.decode(response.bodyBytes);

      List<dynamic> data;
      try {
        data = json.decode(decodedBody);
      } catch (e) {
        print("❌ Błąd dekodowania JSON: $e");
        return;
      }

      if (data.isEmpty) {
        print("⚠ API zwróciło pustą listę zawodów!");
        return;
      }

        // Logowanie nazw kluczy w pierwszym rekordzie (żeby sprawdzić poprawność)
        // print("🔑 Klucze API: ${data[0].keys}");

        setState(() {
          polecaneZawody = data.map((zawod) {
            // Obsługa potencjalnych zmian nazw kolumn w API
            final nazwa = _handlePolishCharacters(zawod["nazwa"] ?? zawod["Nazwa"] ?? "");
            final rawDate = zawod["data"] ?? zawod["Data"] ?? "";
            final dystans = zawod["dystans"] ?? zawod["Dystans"] ?? "";
            final miejsce = zawod["miejsce"] ?? zawod["Miejsce"] ?? "";
            final wojewodztwo = zawod["wojewodztwo"] ?? zawod["Wojewodztwo"] ?? "";
            // final link = zawod["link"] ?? zawod["Link"] ?? "";
            var link = zawod["link"] ?? zawod["Link"] ?? "";

          // Jeśli link to JSON w postaci tekstowej, przetwórz go
          if (link is String) {
            try {
              final linkData = jsonDecode(link);
              link = linkData["Url"] ?? "";
            } catch (e) {
              print("❌ Błąd parsowania linku JSON: $e");
            }
          }

// Poprawienie formatu daty na dd-MM-yyyy
            String formattedDate = rawDate;
            try {
              final parsedDate = _parseDate(rawDate);
              if (parsedDate != null) {
                formattedDate = "${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}";
              }
            } catch (e) {
              print("⚠ Błąd parsowania daty: $rawDate");
            }

            return {
              "nazwa": nazwa.toString(),
              "data": formattedDate,
              "dystans": dystans.toString(),
              "miejsce": miejsce.toString(),
              "wojewodztwo": wojewodztwo.toString(),
              "link": link.toString(),
            };
          }).toList();
        });

        print("✅ Pobrano ${polecaneZawody.length} zawodów!");

      } else {
        print("❌ Błąd pobierania danych: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Błąd połączenia: $e");
    }
  }

// Funkcja pomocnicza do parsowania daty w formacie MM/DD/YYYY
DateTime? _parseDate(String rawDate) {
  try {
    final dateParts = rawDate.split('/');
    if (dateParts.length == 3) {
      final month = int.parse(dateParts[0]);
      final day = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);
      return DateTime(year, month, day);
    }
  } catch (e) {
    print("❌ Błąd parsowania daty: $rawDate");
  }
  return null;
}


String _handlePolishCharacters(String text) {
  // Obsługuje polskie znaki: jeśli nie działają, można spróbować ręcznie konwertować
  return text.runes
      .map((rune) {
        final character = String.fromCharCode(rune);
        return character;
      })
      .join('');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 255, 89, 34), Color.fromARGB(255, 255, 137, 34)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 120),

            // Przycisk Polecane Zawody
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecommendedZawodyScreen()),
                  );
                },
                child: const Text("Polecane zawody", style: TextStyle(fontSize: 18)),
              ),
            ),

            // Sekcja Polecane Zawody (przewijana lista)
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 700,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    itemCount: polecaneZawody.length,
                    itemBuilder: (context, index) {
                      final zawod = polecaneZawody[index];
                      return _buildZawodyCard(zawod);
                    },
                  ),
                ),
              ),
            ),

            // Układ przycisków na dole
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(context, "Przejdź do zawodów", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ZawodyScreen()),
                      );
                    }),
                      const SizedBox(width: 20),
                      _buildButton(context, "Dodaj zawody", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DodajZawodyScreen()));
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(context, "Partnerzy", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PartnerzyScreen()));
                      }),
                      const SizedBox(width: 15),
                      _buildButton(context, "Kalkulator 🏃", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const KalkulatorScreen()));
                      }),
                      const SizedBox(width: 15),
                      _buildButton(context, "ℹ", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OApkScreen()));
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }

  Widget _buildZawodyCard(Map<String, String> zawod) {
    return GestureDetector(
      onTap: () => _launchURL(zawod["link"] ?? ""),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(zawod["nazwa"] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("🗓 ${zawod["data"] ?? ''}"),
                  Text("📍 ${zawod["miejsce"] ?? ''}"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("📏 ${zawod["dystans"] ?? ''}"),
                  Text("📌 ${zawod["wojewodztwo"] ?? ''}"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String? url) async {
  if (url == null || url.isEmpty) {
    print("❌ Błąd: URL jest pusty!");
    return;
  }

  final Uri uri = Uri.parse(url.startsWith("http") ? url : "https://$url"); // Dodaj "https://" jeśli brakuje

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication); // Otwórz w przeglądarce
  } else {
    print("❌ Nie można otworzyć linku: $url");
    // print("🔗 Otrzymany link: $link");
  }
}
}