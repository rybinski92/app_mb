import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'config.dart';
import 'package:provider/provider.dart'; // Dodaj import Provider
import 'scalowanie.dart'; // Importuj ScaleNotifier
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:excel/excel.dart';
import 'dart:typed_data';

class ZawodyScreen extends StatefulWidget {
  const ZawodyScreen({super.key});

  @override
  _ZawodyScreenState createState() => _ZawodyScreenState();
}

class _ZawodyScreenState extends State<ZawodyScreen> {
  List<Map<String, String>> zawody = [];
  List<String> wojewodztwa = [];
  List<String> miesiace = [];
  List<String> wybraneWojewodztwa = ["Wszystkie województwa"];
  String wybranyMiesiac = "Cały rok";
  String? wybranyTypZawodow = "Wszystkie";
  Set<String> wybraneDystanse = {};
  bool _pokazFiltry = true;
  // bool _isFetching = false;

  final List<String> dystanseOpcje = [
    "< 5 km",
    "5 km",
    "10 km",
    "21 km",
    "42 km",
    "Ultra"
  ];

  final Map<String, int> miesiaceKolejnosc = {
    "styczeń": 1,
    "luty": 2,
    "marzec": 3,
    "kwiecień": 4,
    "maj": 5,
    "czerwiec": 6,
    "lipiec": 7,
    "sierpień": 8,
    "wrzesień": 9,
    "październik": 10,
    "listopad": 11,
    "grudzień": 12,
  };

  @override
  void initState() {
    super.initState();
    _loadLocalExcelData();
  }

  Future<void> _loadLocalExcelData() async {
    try {
      
      ByteData data = await rootBundle.load('pliki_bazy/zawody.xlsx');
      Uint8List bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      List<Map<String, String>> newZawody = [];
      Set<String> wojewodztwaSet = {"Wszystkie województwa"};
      Set<String> miesiaceSet = {"Cały rok"};

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null) continue;

        for (var row in sheet.rows.skip(1)) { // Pomijamy nagłówek
          String rawDate = row[1]?.value.toString() ?? "";
          String formattedDate = _formatDate(rawDate);
          String miesiac = row[2]?.value.toString() ?? "";
          String rok = row[3]?.value.toString() ?? "";
          String miejsce = row[5]?.value.toString() ?? "";
          String wojewodztwo = row[6]?.value.toString() ?? "";
          String dystanse = row[4]?.value.toString() ?? "";
          String gorskie = row[7]?.value.toString() ?? "0";

          wojewodztwaSet.add(wojewodztwo);
          miesiaceSet.add(miesiac);

          newZawody.add({
            "nazwa": row[0]?.value.toString() ?? "",
            "dataPrzetworzona": formattedDate,
            "miesiac": miesiac,
            "rok": rok,
            "miejsce": miejsce,
            "wojewodztwo": wojewodztwo,
            "dystanse": dystanse,
            "gorskie": gorskie,
          });
        }
      }

      // Sortowanie miesięcy
      List<String> sortedMiesiace = miesiaceSet.toList();
      sortedMiesiace.sort((a, b) => (miesiaceKolejnosc[a] ?? 99)
          .compareTo(miesiaceKolejnosc[b] ?? 99));

      // Sortowanie województw
      final List<String> poprawnaKolejnoscWojewodztw = [
        "DOLNOŚLĄSKIE",
        "KUJAWSKO-POMORSKIE",
        "LUBELSKIE",
        "LUBUSKIE",
        "ŁÓDZKIE",
        "MAŁOPOLSKIE",
        "MAZOWIECKIE",
        "OPOLSKIE",
        "PODKARPACKIE",
        "PODLASKIE",
        "POMORSKIE",
        "ŚLĄSKIE",
        "ŚWIĘTOKRZYSKIE",
        "WARMIŃSKO-MAZURSKIE",
        "WIELKOPOLSKIE",
        "ZACHODNIOPOMORSKIE"
      ];

      List<String> sortedWojewodztwa = wojewodztwaSet.toList();
      sortedWojewodztwa.remove("Wszystkie województwa");
      sortedWojewodztwa.sort((a, b) {
        final indexA = poprawnaKolejnoscWojewodztw.indexOf(a);
        final indexB = poprawnaKolejnoscWojewodztw.indexOf(b);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });
      sortedWojewodztwa.insert(0, "Wszystkie województwa");

      setState(() {
        zawody = newZawody;
        wojewodztwa = sortedWojewodztwa;
        miesiace = sortedMiesiace;
      });

      print("✅ Załadowano ${zawody.length} zawodów z pliku Excel");
    } catch (e) {
      print("❌ Błąd odczytu pliku Excel: $e");
    }
  }

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

  /// Funkcja filtrująca dystanse
  bool _pasujeDystans(String? dystanse) {
    if (wybraneDystanse.isEmpty)
      return true; // Jeśli nic nie wybrano -> pokazuje wszystko
    if (dystanse == null || dystanse.isEmpty) return false;

    List<String> dystanseLista =
        dystanse.split(',').map((e) => e.trim()).toList();

    for (var dystans in dystanseLista) {
      try {
        double dystansValue = double.parse(dystans.split(' ')[0]);

        for (var wybrany in wybraneDystanse) {
          switch (wybrany) {
            case "< 5 km":
              if (dystansValue < 5) return true;
              break;
            case "5 km":
              if (dystansValue == 5 || (dystansValue > 5 && dystansValue < 6))
                return true;
              break;
            case "10 km":
              if (dystansValue == 10 ||
                  (dystansValue > 10 && dystansValue < 11)) return true;
              break;
            case "21 km":
              if (dystansValue == 21 ||
                  (dystansValue > 21 && dystansValue < 22)) return true;
              // if (dystansValue == 21.097) return true;
              break;
            case "42 km":
              if (dystansValue == 42 ||
                  (dystansValue > 42 && dystansValue < 43)) return true;
              // if (dystansValue == 42.195) return true;
              break;
            // case "> 42.195 km":
            case "Ultra":
              if (dystansValue > 42.195) return true;
              break;
          }
        }
      } catch (_) {}
    }

    return false;
  }

  List<Map<String, String>> _filtrujZawody() {
    return zawody.where((z) {
      final wojFilter = wybraneWojewodztwa.contains("Wszystkie województwa") ||
          wybraneWojewodztwa.contains(z["wojewodztwo"]);

      final miesiacFilter =
          wybranyMiesiac == "Cały rok" || wybranyMiesiac == z["miesiac"];
      // final rokFilter = wybranyRok == z["rok"];
      final gorskieFilter = wybranyTypZawodow == "Wszystkie" ||
          (wybranyTypZawodow == "Górskie" && z["gorskie"] == "1");
      final dystansFilter = _pasujeDystans(z["dystanse"]);

      return wojFilter && miesiacFilter && gorskieFilter && dystansFilter;
    }).toList();
  }

  Future<void> _otworzGoogle(String nazwaZawodow) async {
    final url = Uri.parse(
        'https://www.google.com/search?q=${Uri.encodeComponent(nazwaZawodow)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Nie można otworzyć URL: $url';
    }
  }

  void _wybierzWojewodztwa() async {
    // List<String> tempWybrane = List.from(wybraneWojewodztwa);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> tempWybrane =
            List.from(wybraneWojewodztwa); // Kopia dla dialogu

        return StatefulBuilder(
          // ✅ Kluczowy element do dynamicznej aktualizacji
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Wybierz województwa"),
              content: SizedBox(
                width: 400, // ✅ SZEROKIE OKNO
                child: SingleChildScrollView(
                  child: Column(
                    children: wojewodztwa.map((woj) {
                      return CheckboxListTile(
                        title: Text(woj),
                        value: tempWybrane.contains(woj),
                        onChanged: (bool? value) {
                          setDialogState(() {
                            // ✅ Aktualizacja dynamiczna w dialogu
                            if (woj == "Wszystkie województwa") {
                              tempWybrane.clear();
                              if (value == true) {
                                tempWybrane.add("Wszystkie województwa");
                              }
                            } else {
                              tempWybrane.remove("Wszystkie województwa");
                              if (value == true) {
                                tempWybrane.add(woj);
                              } else {
                                tempWybrane.remove(woj);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      // ✅ Aktualizacja globalna po zamknięciu dialogu
                      if (tempWybrane.contains("Wszystkie województwa") &&
                          tempWybrane.length > 1) {
                        tempWybrane.remove("Wszystkie województwa");
                      } else if (tempWybrane.isEmpty) {
                        tempWybrane.add("Wszystkie województwa");
                      }
                      wybraneWojewodztwa = List.from(tempWybrane);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Funkcja do wyświetlania opisu wyboru dystansów
  void _pokazOpisDystansow(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Informacje"),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Zapobiega rozciąganiu okna
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    color: Colors.green[300],
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      "Zawody górskie punktowane w serwisie RMT.",
                      style: TextStyle(
                        fontSize: 12,
                        // fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Drugi opis w kursywie
              const Text(
                "Kliknięcie w zawody -> wyszukiwarka Google.",
                style: TextStyle(
                  fontSize: 12,
                  // fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              // Opis dystansów
              const Text(
                "Wybór dystansów:\n"
                "< 5km: dystanse mniejsze od 5 km;\n"
                "5 km: dystans 5 km lub większy od 5 i mniejszy od 6;\n"
                "10 km: dystans 10 km lub większy od 10 i mniejszy od 11;\n"
                "21 km: dystans 21 km lub większy od 21 i mniejszy od 22;\n"
                "42 km: dystans 42 km lub większy od 42 i mniejszy od 43;\n"
                "Ultra: Dystanse większe od 42.195 km.",
                style: TextStyle(
                  fontSize: 12, // Ustawienie rozmiaru czcionki
                  fontWeight: FontWeight
                      .normal, // Opcjonalnie: możesz dodać wagę czcionki
                ),
              ),

              // Legenda - zielony kwadrat + opis
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleNotifier =
        Provider.of<ScaleNotifier>(context); // Pobierz ScaleNotifier
    final filtrowaneZawody = _filtrujZawody();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Row(
          children: [
            const Text("Zawody  |"),
            const SizedBox(width: 8),

            // const SizedBox(width: 6),
            // const Text("|"),
            // const SizedBox(width: 8),

            // Przycisk "ℹ Informacje"
            InkWell(
              onTap: () => _pokazOpisDystansow(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scaleNotifier.scale, // Skalowanie paddingu
                  vertical: 6 * scaleNotifier.scale,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Półprzezroczyste tło
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Tooltip(
                  message: "Informacje",
                  child: Text(
                    "ℹ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Tekst w kolorze białym
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            const Text("| Filtry"),
            const SizedBox(width: 8),
            // Switch do włączania filtrów
            Switch(
              value: _pokazFiltry,
              onChanged: (value) {
                setState(() {
                  _pokazFiltry = value;
                });
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.green,
              inactiveTrackColor: Colors.grey,
            ),
          ],
        ),
      ),
      
body: Center(
  child: Column(
    children: [
      if (_pokazFiltry)
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700, // Ogranicz szerokość filtrów do 400px
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0 * scaleNotifier.scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Wybierz województwa",
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  controller: TextEditingController(
                    text: wybraneWojewodztwa.join(", "),
                  ),
                  onTap: _wybierzWojewodztwa,
                ),
                SizedBox(height: 10 * scaleNotifier.scale),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: "Wybierz miesiąc"),
                        value: wybranyMiesiac,
                        items: miesiace.map((mies) {
                          return DropdownMenuItem(
                            value: mies,
                            child: Text(
                              mies,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            wybranyMiesiac = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10 * scaleNotifier.scale),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: "Typ zawodów"),
                        value: wybranyTypZawodow,
                        items: ["Wszystkie", "Górskie"].map((typ) {
                          return DropdownMenuItem(
                            value: typ,
                            child: Text(
                              typ,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            wybranyTypZawodow = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * scaleNotifier.scale),
                Wrap(
                  spacing: 1.0 * scaleNotifier.scale,
                  children: [
                    ...dystanseOpcje.map((dystans) {
                      return FilterChip(
                        label: Text(
                          dystans,
                          style: TextStyle(
                            fontSize: 14 * scaleNotifier.scale,
                          ),
                        ),
                        selected: wybraneDystanse.contains(dystans),
                        onSelected: (isSelected) {
                          setState(() {
                            if (isSelected) {
                              wybraneDystanse.add(dystans);
                            } else {
                              wybraneDystanse.remove(dystans);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        ),
      Expanded(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200, // Ogranicz szerokość listy zawodów do 900px
          ),
          child: ListView.builder(
            itemCount: filtrowaneZawody.length,
            itemBuilder: (context, index) {
              final zawod = filtrowaneZawody[index];
              return Card(
                color: zawod["gorskie"] == '1'
                    ? Colors.green[300]
                    : Colors.white,
                child: ListTile(
                  title: Text(
                    zawod["nazwa"] ?? '',
                    style: TextStyle(
                      fontSize: 18 * scaleNotifier.scale,
                    ),
                  ),
                  subtitle: Text(
                    "Data: ${zawod["dataPrzetworzona"]}\nMiejsce: ${zawod["miejsce"]}\nDystanse: ${zawod["dystanse"]}",
                    style: TextStyle(
                      fontSize: 14 * scaleNotifier.scale,
                    ),
                  ),
                  trailing: Text(
                    zawod["wojewodztwo"] ?? '',
                    style: TextStyle(
                      fontSize: 14 * scaleNotifier.scale,
                    ),
                  ),
                  onTap: () => _otworzGoogle(zawod["nazwa"] ?? ''),
                ),
              );
            },
          ),
        ),
      ),
    ],
  ),
),
    );
  }
}
