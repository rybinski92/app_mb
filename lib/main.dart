import 'package:flutter/material.dart';
import 'package:app_kb/zawody_screen.dart';
import 'package:app_kb/kalkulator_screen.dart';
import 'package:app_kb/o_aplikacji_screen.dart';
import 'package:app_kb/partnerzy_screen.dart';
import 'package:app_kb/dodaj_zawody_screen.dart';
import 'package:app_kb/recommended_zawody.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'config.dart';
import 'package:provider/provider.dart';
import 'scalowanie.dart'; // Zaimportuj plik z ScaleNotifier
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:excel/excel.dart';
import 'dart:typed_data';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ScaleNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mój bieg',
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
  // bool _isLoading = false;

@override
void initState() {
  super.initState();
  _loadLocalExcelData();
}



 
Future<void> _loadLocalExcelData() async {
  try {
    ByteData data = await rootBundle.load('pliki_bazy/polecane.xlsx');
    Uint8List bytes = data.buffer.asUint8List();
    var excel = Excel.decodeBytes(bytes);

    List<Map<String, String>> newPolecaneZawody = [];

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet == null) continue;

      for (var row in sheet.rows.skip(1)) {
        String rawDate = row[1]?.value.toString() ?? "";
        String formattedDate = _formatDate(rawDate); // Używamy nowej funkcji formatującej

        newPolecaneZawody.add({
          "nazwa": row[0]?.value.toString() ?? "",
          "data": formattedDate,
          "dystans": row[2]?.value.toString() ?? "",
          "miejsce": row[3]?.value.toString() ?? "",
          "wojewodztwo": row[4]?.value.toString() ?? "",
          "link": row[5]?.value.toString() ?? "",
        });
      }
    }

    setState(() {
      polecaneZawody = newPolecaneZawody;
    });

    print("✅ Załadowano zawody z pliku Excel (${polecaneZawody.length})");
  } catch (e) {
    print("❌ Błąd odczytu Excela: $e");
  }
}

// Nowa funkcja do formatowania daty
String _formatDate(String rawDate) {
  try {
    // Najpierw spróbuj parsować jako MM/DD/YYYY
    final dateParts = rawDate.split('/');
    if (dateParts.length == 3) {
      final month = int.parse(dateParts[0]);
      final day = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);
      return "${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year";
    }
    
    // Jeśli to nie zadziała, spróbuj parsować jako DateTime (np. jeśli Excel zapisał jako DateTime)
    DateTime? parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate != null) {
      return "${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}";
    }
  } catch (e) {
    print("❌ Błąd formatowania daty: $rawDate");
  }
  
  // Jeśli nic nie zadziała, zwróć oryginalną wartość
  return rawDate;
}

//   String _handlePolishCharacters(String text) {
//     // Obsługuje polskie znaki: jeśli nie działają, można spróbować ręcznie konwertować
//     return text.runes.map((rune) {
//       final character = String.fromCharCode(rune);
//       return character;
//     }).join('');
//   }

  @override
  Widget build(BuildContext context) {
    final scaleNotifier = Provider.of<ScaleNotifier>(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 89, 34),
              Color.fromARGB(255, 255, 137, 34)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: odstep),

            // Przyciski skalowania (+ i -)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 5.0, top: 5.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Text("➖",
                          style: TextStyle(fontSize: 22, color: Colors.white)),
                      onPressed:
                          scaleNotifier.zoomOut, // Użyj zoomOut z ScaleNotifier
                    ),
                    IconButton(
                      icon: const Text("➕",
                          style: TextStyle(fontSize: 22, color: Colors.white)),
                      onPressed:
                          scaleNotifier.zoomIn, // Użyj zoomIn z ScaleNotifier
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Przycisk Polecane Zawody
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RecommendedZawodyScreen()),
                  );
                },
                child: Text(
                  "Polecane zawody",
                  style: TextStyle(
                    fontSize: (MediaQuery.of(context).size.width > 500
                            ? 500
                            : MediaQuery.of(context).size.width) *
                        0.035,
                  ),
                ),
              ),
            ),

            // const SizedBox(height: 24),

            // Sekcja Polecane Zawody (przewijana lista)
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 900,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
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
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxWidth: 500), // Maksymalna szerokość na dużych ekranach
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // Ważne dla poprawnego działania ConstrainedBox
                    children: [
                      // Pierwszy rząd przycisków
                      Row(
                        children: [
                          Expanded(
                            child: _buildAutoScaleButton(
                                context, "Lista zawodów", () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ZawodyScreen()));
                            }),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildAutoScaleButton(
                                context, "Dodaj zawody", () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DodajZawodyScreen()));
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Drugi rząd przycisków
                      Row(
                        children: [
                          Expanded(
                            child:
                                _buildAutoScaleButton(context, "Partnerzy", () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PartnerzyScreen()));
                            }),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildAutoScaleButton(context, "Kalkulator",
                                () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const KalkulatorScreen()));
                            }),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: _buildAutoScaleButton(context, "📩", () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const OApkScreen()));
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Funkcja do budowania przycisków z auto-skalingiem
  Widget _buildAutoScaleButton(
      BuildContext context, String text, VoidCallback onPressed) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Ustalamy maksymalną szerokość do skalowania - nie więcej niż 700px
    final scalingWidth = screenWidth > 500 ? 500 : screenWidth;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: TextStyle(
            // Skalujemy tylko do 700px szerokości
            fontSize: scalingWidth * 0.035,
          ),
        ),
      ),
    );
  }

  Widget _buildZawodyCard(Map<String, String> zawod) {
    final scaleNotifier = Provider.of<ScaleNotifier>(context);
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
              Text(zawod["nazwa"] ?? '',
                  style: TextStyle(
                      fontSize: 15 * scaleNotifier.scale,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "🗓 ${zawod["data"] ?? ''}",
                    style: TextStyle(
                      fontSize: 14 * scaleNotifier.scale, // Skalowanie czcionki
                    ),
                  ),
                  Text(
                    "📍 ${zawod["miejsce"] ?? ''}",
                    style: TextStyle(
                      fontSize: 14 * scaleNotifier.scale, // Skalowanie czcionki
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "📏 ${zawod["dystans"] ?? ''}",
                    style: TextStyle(
                      fontSize: 14 * scaleNotifier.scale, // Skalowanie czcionki
                    ),
                  ),
                  Text(
                    "📌 ${zawod["wojewodztwo"] ?? ''}",
                    style: TextStyle(
                      fontSize: 14 * scaleNotifier.scale, // Skalowanie czcionki
                    ),
                  ),
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

    final Uri uri = Uri.parse(url.startsWith("http")
        ? url
        : "https://$url"); // Dodaj "https://" jeśli brakuje

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.externalApplication); // Otwórz w przeglądarce
    } else {
      print("❌ Nie można otworzyć linku: $url");
      // print("🔗 Otrzymany link: $link");
    }
  }
}
