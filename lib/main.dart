import 'package:flutter/material.dart';
import 'package:app_kb/zawody_screen.dart';
import 'package:app_kb/kalkulator_screen.dart';
import 'package:app_kb/o_aplikacji_screen.dart';
import 'package:app_kb/partnerzy_screen.dart';
import 'package:app_kb/dodaj_zawody_screen.dart';
import 'package:app_kb/recommended_zawody.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:excel/excel.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';


void main()  {
  // WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load();
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

  @override
  void initState() {
    super.initState();
    _loadPolecaneZawody();
  }

  Future<void> _loadPolecaneZawody() async {
    final ByteData data = await rootBundle.load('pliki_bazy/polecane.xlsx');
    final excel = Excel.decodeBytes(data.buffer.asUint8List());
    final zawodySheet = excel.tables[excel.tables.keys.first];

    if (zawodySheet == null) return;

    List<Map<String, String>> loadedZawody = [];

    for (var row in zawodySheet.rows.skip(1)) {
      final nazwa = row[0]?.value.toString() ?? '';
      final data = row[1]?.value.toString().split('T').first ?? '';
      final dystans = row[2]?.value.toString() ?? '';
      final miejsce = row[3]?.value.toString() ?? '';
      final wojewodztwo = row[4]?.value.toString() ?? '';
      final link = row[5]?.value.toString() ?? '';

      if (nazwa.isNotEmpty && link.isNotEmpty) {
        loadedZawody.add({
          "nazwa": nazwa,
          "data": data,
          "dystans": dystans,
          "miejsce": miejsce,
          "wojewodztwo": wojewodztwo,
          "link": link,
        });
      }
    }

    setState(() {
      polecaneZawody = loadedZawody;
    });
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
            // Odstęp na górze
            const SizedBox(height: 200),

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
                    maxWidth: 700, // Ograniczenie szerokości do 600
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(context, "Przejdź do zawodów", () async {
                        final ByteData data = await rootBundle.load('pliki_bazy/zawody.xlsx');
                        final excelBytes = data.buffer.asUint8List();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ZawodyScreen(excelBytes: excelBytes),
                          ),
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
                      _buildButton(context, "O aplikacji", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OApkScreen()));
                      }),
                      const SizedBox(width: 15),
                      _buildButton(context, "📟 🏃", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const KalkulatorScreen()));
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

  // Funkcja do tworzenia przycisku
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

  // Karta z zawodami
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

  // Otwieranie linku
  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}