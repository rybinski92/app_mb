import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'package:provider/provider.dart'; // Dodaj import Provider
import 'scalowanie.dart'; // Importuj ScaleNotifier

class ZawodyScreen extends StatefulWidget {
  const ZawodyScreen({super.key});

  @override
  _ZawodyScreenState createState() => _ZawodyScreenState();
}

class _ZawodyScreenState extends State<ZawodyScreen> {
  List<Map<String, String>> zawody = [];
  List<String> wojewodztwa = [];
  List<String> miesiace = [];
  // String? wybraneWojewodztwo;
  List<String> wybraneWojewodztwa = ["Wszystkie województwa"];
  String wybranyMiesiac = "Cały rok";
  // String wybranyRok = "2025";
  String? wybranyTypZawodow = "Wszystkie"; // Dodany filtr na typ zawodów
  Set<String> wybraneDystanse = {}; // Brak domyślnego dystansu

  bool _pokazFiltry =
      true; // <-- Nowa zmienna do sterowania widocznością filtrów

  final String apiUrl =
      "https://api.appsheet.com/api/v2/apps/566e1354-d7f1-49a1-bb85-6ce2f26ce8b4/tables/zawody/records";
  final String apiKey = Config.apiKey3;

  final List<String> dystanseOpcje = [
    "< 5 km",
    "5 km",
    "10 km",
    "21 km",
    "42 km",
    "Ultra"
  ]; // Opcje dla filtra dystansu

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
    _pobierzDaneZAppSheet();
  }

  /// 📡 Pobiera dane z AppSheet API
  Future<void> _pobierzDaneZAppSheet() async {
    try {
      final url = Uri.parse(apiUrl);
      // final String? apiKey3 = await Config.getApiKey3();
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json; charset=utf-8",
          "ApplicationAccessKey": apiKey,
          // "ApplicationAccessKey": apiKey3 ?? "",
        },
        body: jsonEncode({
          "Action": "Find",
          "Properties": {"Locale": "pl-PL"},
          "Rows": []
        }),
      );

      // print("📩 Odpowiedź status code: ${response.statusCode}");
      // print("📩 Odpowiedź headers: ${response.headers}");
      // print("📩 Odpowiedź body: '${response.body}'");

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) {
          print("⚠ API zwróciło pustą odpowiedź!");
          return;
        }

        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);

        final wojewodztwaSet = <String>{"Wszystkie województwa"};
        final miesiaceSet = <String>{"Cały rok"};

        setState(() {
          zawody = data.map((zawod) {
            final nazwa = zawod["nazwa"] ?? zawod["Nazwa"] ?? "";
            final rawDate = zawod["data"] ?? zawod["Data"] ?? "";
            final miesiac = zawod["miesiac"] ?? zawod["Miesiac"] ?? "";
            final rok = zawod["rok"] ?? zawod["Rok"] ?? "";
            final miejsce = zawod["miejsce"] ?? zawod["Miejsce"] ?? "";
            final wojewodztwo =
                zawod["wojewodztwo"] ?? zawod["Wojewodztwo"] ?? "";
            final dystanse = zawod["dystans"] ?? zawod["Dystans"] ?? "";
            final gorskie = zawod["gorskie"] ?? zawod["Gorskie"] ?? "0";

            wojewodztwaSet.add(wojewodztwo);
            miesiaceSet.add(miesiac);

            return {
              "nazwa": nazwa.toString(),
              "dataPrzetworzona": _formatDate(rawDate),
              "miesiac": miesiac.toString(),
              "rok": rok.toString(),
              "miejsce": miejsce.toString(),
              "wojewodztwo": wojewodztwo.toString(),
              "dystanse": dystanse.toString(),
              "gorskie": gorskie.toString(),
            };
          }).toList();

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

          setState(() {
            // Sortowanie miesięcy wg poprawnej kolejności
            miesiace = miesiaceSet.toList();
            miesiace.sort((a, b) => (miesiaceKolejnosc[a] ?? 99)
                .compareTo(miesiaceKolejnosc[b] ?? 99));

            // Pobranie listy województw
            wojewodztwa = wojewodztwaSet.toList();

            // Usunięcie "Wszystkie województwa" przed sortowaniem
            wojewodztwa.remove("Wszystkie województwa");

            // Sortowanie wg poprawnej kolejności
            wojewodztwa.sort((a, b) {
              final indexA = poprawnaKolejnoscWojewodztw.indexOf(a);
              final indexB = poprawnaKolejnoscWojewodztw.indexOf(b);

              if (indexA == -1)
                return 1; // Jeśli województwo nie jest w liście, daj na koniec
              if (indexB == -1) return -1;
              return indexA.compareTo(indexB);
            });

            // Dodanie "Wszystkie województwa" na początek listy
            wojewodztwa.insert(0, "Wszystkie województwa");
          });
        });

        print("✅ Pobrano ${zawody.length} zawodów!");
      } else {
        print(
            "❌ Błąd pobierania danych: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Błąd połączenia: $e");
    }
  }

  /// ✅ Formatuje datę z MM/DD/YYYY na DD-MM-YYYY
  String _formatDate(String rawDate) {
    try {
      final dateParts = rawDate.split('/');
      if (dateParts.length == 3) {
        final month = int.parse(dateParts[0]);
        final day = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        return "${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-${year}";
      }
    } catch (e) {
      print("❌ Błąd parsowania daty: $rawDate");
    }
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
    final scaleNotifier = Provider.of<ScaleNotifier>(context); // Pobierz ScaleNotifier
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700, // Ograniczamy szerokość formularza
          ),
          child: Column(
            children: [
              if (_pokazFiltry) // Pokazujemy filtry tylko, jeśli _pokazFiltry == true
                Padding(
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
                      SizedBox(height: 10 * scaleNotifier.scale), // Skalowanie odstępu
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
                                    fontSize: 16, // Skalowanie czcionki
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
                                    fontSize: 16, // Skalowanie czcionki
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
                      // Filtr dystansów
                      Wrap(
                        spacing: 1.0 * scaleNotifier.scale, // Odstępy między elementami
                        children: [
                          // Użycie spread operator (...) do rozpakowania listy elementów
                          ...dystanseOpcje.map((dystans) {
                            return FilterChip(
                              label: Text(
                              dystans,
                              style: TextStyle(
                                fontSize: 14 * scaleNotifier.scale, // Skalowanie czcionki
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
              Expanded(
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
                          fontSize: 18 * scaleNotifier.scale, // Skalowanie czcionki
                        ),
                      ),
                        subtitle: Text(
                        "Data: ${zawod["dataPrzetworzona"]}\nMiejsce: ${zawod["miejsce"]}\nDystanse: ${zawod["dystanse"]}",
                        style: TextStyle(
                          fontSize: 14 * scaleNotifier.scale, // Skalowanie czcionki
                        ),
                      ),
                        trailing: Text(
                        zawod["wojewodztwo"] ?? '',
                        style: TextStyle(
                          fontSize: 14 * scaleNotifier.scale, // Skalowanie czcionki
                        ),
                      ),
                        onTap: () => _otworzGoogle(zawod["nazwa"] ?? ''),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

