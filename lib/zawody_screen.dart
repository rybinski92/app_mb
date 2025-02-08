import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';

class ZawodyScreen extends StatefulWidget {
  final Uint8List excelBytes;

  const ZawodyScreen({required this.excelBytes, super.key});

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
    _odczytajExcel(widget.excelBytes);
  }

  void _odczytajExcel(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final zawodySheet = excel.tables[excel.tables.keys.first];

    if (zawodySheet == null) return;

    final wojewodztwaSet = <String>{"Wszystkie województwa"};
    final miesiaceSet = <String>{"Cały rok"};

    for (var row in zawodySheet.rows.skip(1)) {
      final nazwa = row[0]?.value.toString() ?? '';
      final dataPrzetworzona = row[1]?.value.toString().split('T').first ?? '';
      final miesiac = row[2]?.value.toString().trim() ?? '';
      final rok = row[3]?.value.toString() ?? '';
      final miejsce = row[5]?.value.toString() ?? '';
      final wojewodztwo = row[6]?.value.toString() ?? '';
      final dystanse = row[4]?.value.toString() ?? '';
      final gorskie = row[7]?.value.toString().trim() ?? '0';

      if (nazwa.isNotEmpty &&
          dataPrzetworzona.isNotEmpty &&
          miesiac.isNotEmpty &&
          miejsce.isNotEmpty &&
          wojewodztwo.isNotEmpty &&
          rok.isNotEmpty) {
        zawody.add({
          "nazwa": nazwa,
          "dataPrzetworzona": dataPrzetworzona,
          "miesiac": miesiac,
          "rok": rok,
          "miejsce": miejsce,
          "wojewodztwo": wojewodztwo,
          "dystanse": dystanse,
          "gorskie": gorskie,
        });
        wojewodztwaSet.add(wojewodztwo);
        miesiaceSet.add(miesiac);
      }
    }

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

      miesiace = miesiaceSet.toList();
      miesiace.sort((a, b) => (miesiaceKolejnosc[a] ?? 99).compareTo(miesiaceKolejnosc[b] ?? 99));
      
      wojewodztwa = wojewodztwaSet.toList();
      wojewodztwa.remove("Wszystkie województwa");

      wojewodztwa.sort((a, b) {
        final indexA = poprawnaKolejnoscWojewodztw.indexOf(a);
        final indexB = poprawnaKolejnoscWojewodztw.indexOf(b);

        if (indexA == -1) return 1; // Jeśli brak w liście, daj na koniec
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });

      wojewodztwa.insert(0, "Wszystkie województwa"); // Dodaj na początek
    });
  }

  List<Map<String, String>> _filtrujZawody() {
    return zawody.where((zawod) {
      final wojFilter = wybraneWojewodztwo == null ||
          wybraneWojewodztwo == "Wszystkie województwa" ||
          wybraneWojewodztwo == zawod["wojewodztwo"];

      final miesiacFilter =
          wybranyMiesiac == "Cały rok" || wybranyMiesiac == zawod["miesiac"];

      final rokFilter = wybranyRok == zawod["rok"];

      // Filtracja według typu zawodów: Górskie zawody
      final gorskieFilter = wybranyTypZawodow == "Wszystkie zawody" ||
          (wybranyTypZawodow == "Górskie zawody" && zawod["gorskie"] == "1");

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
            const Text("Zawody biegowe"),
            const SizedBox(width: 5),
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
