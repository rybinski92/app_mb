import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class ZawodyScreen extends StatefulWidget {
  const ZawodyScreen({super.key});

  @override
  _ZawodyScreenState createState() => _ZawodyScreenState();
}

class _ZawodyScreenState extends State<ZawodyScreen> {
  List<Map<String, String>> zawody = [];
  List<String> wojewodztwa = [];
  List<String> miesiace = [];
  String? wybraneWojewodztwo;
  String wybranyMiesiac = "Cały rok";
  String wybranyRok = "2025";
  String? wybranyTypZawodow = "Wszystkie zawody"; // Dodany filtr na typ zawodów

  bool _pokazFiltry = true; // <-- Nowa zmienna do sterowania widocznością filtrów

  final String apiUrl = "https://api.appsheet.com/api/v2/apps/566e1354-d7f1-49a1-bb85-6ce2f26ce8b4/tables/zawody/records";
  final String apiKey = Config.apiKey3;
  

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
          "Properties": { "Locale": "pl-PL" },
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
            final wojewodztwo = zawod["wojewodztwo"] ?? zawod["Wojewodztwo"] ?? "";
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
            "KUJAWSKO-POMORSKIE" , 
            "LUBELSKIE",  
            "LUBUSKIE",  
            "ŁÓDZKIE" , 
            "MAŁOPOLSKIE" , 
            "MAZOWIECKIE",  
            "OPOLSKIE"  ,
            "PODKARPACKIE" , 
            "PODLASKIE"  ,
            "POMORSKIE" , 
            "ŚLĄSKIE" , 
            "ŚWIĘTOKRZYSKIE" , 
            "WARMIŃSKO-MAZURSKIE" ,
            "WIELKOPOLSKIE" , 
            "ZACHODNIOPOMORSKIE"
          ];

          setState(() {
            // Sortowanie miesięcy wg poprawnej kolejności
            miesiace = miesiaceSet.toList();
            miesiace.sort((a, b) => (miesiaceKolejnosc[a] ?? 99).compareTo(miesiaceKolejnosc[b] ?? 99));

            // Pobranie listy województw
            wojewodztwa = wojewodztwaSet.toList();
            
            // Usunięcie "Wszystkie województwa" przed sortowaniem
            wojewodztwa.remove("Wszystkie województwa");

            // Sortowanie wg poprawnej kolejności
            wojewodztwa.sort((a, b) {
              final indexA = poprawnaKolejnoscWojewodztw.indexOf(a);
              final indexB = poprawnaKolejnoscWojewodztw.indexOf(b);

              if (indexA == -1) return 1; // Jeśli województwo nie jest w liście, daj na koniec
              if (indexB == -1) return -1;
              return indexA.compareTo(indexB);
            });

            // Dodanie "Wszystkie województwa" na początek listy
            wojewodztwa.insert(0, "Wszystkie województwa");
          });
        });

        print("✅ Pobrano ${zawody.length} zawodów!");
      } else {
        print("❌ Błąd pobierania danych: ${response.statusCode} - ${response.body}");
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

  List<Map<String, String>> _filtrujZawody() {
    return zawody.where((z) {
      final wojFilter = wybraneWojewodztwo == null ||
          wybraneWojewodztwo == "Wszystkie województwa" ||
          wybraneWojewodztwo == z["wojewodztwo"];

      final miesiacFilter = wybranyMiesiac == "Cały rok" || wybranyMiesiac == z["miesiac"];
      final rokFilter = wybranyRok == z["rok"];
      final gorskieFilter = wybranyTypZawodow == "Wszystkie zawody" ||
          (wybranyTypZawodow == "Górskie zawody" && z["gorskie"] == "1");

      return wojFilter && miesiacFilter && rokFilter && gorskieFilter;
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

  @override
  Widget build(BuildContext context) {
    final filtrowaneZawody = _filtrujZawody();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Zawody | Filtry"),
            const SizedBox(width: 10),
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
        backgroundColor: Colors.orange,
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
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: "Wybierz województwo"),
                      value: wybraneWojewodztwo,
                      items: wojewodztwa.map((woj) {
                        return DropdownMenuItem(
                          value: woj,
                          child: Text(woj),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          wybraneWojewodztwo = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
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
                                child: Text(mies),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                wybranyMiesiac = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration:
                                const InputDecoration(labelText: "Wybierz rok"),
                            value: wybranyRok,
                            items: ["2025", "2026"].map((rok) {
                              return DropdownMenuItem(
                                value: rok,
                                child: Text(rok),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                wybranyRok = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: "Typ zawodów"),
                      value: wybranyTypZawodow,
                      items: ["Wszystkie zawody", "Górskie zawody"].map((typ) {
                        return DropdownMenuItem(
                          value: typ,
                          child: Text(typ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          wybranyTypZawodow = value;
                        });
                      },
                    ),
                    const SizedBox(height: 4),
                    // Zielony kwadrat obok tekstu jak legenda
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          color: Colors.green[300],
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Zawody górskie punktowane w serwisie RMT.",
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Drugi tekst w kursywie
                    Text(
                      "Kliknięcie w zawody -> wyszukiwarka Google.",
                      style:
                          TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
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
                        title: Text(zawod["nazwa"] ?? ''),
                        subtitle: Text(
                            "Data: ${zawod["dataPrzetworzona"]}\nMiejsce: ${zawod["miejsce"]}\nDystanse: ${zawod["dystanse"]}"),
                        trailing: Text(zawod["wojewodztwo"] ?? ''),
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
