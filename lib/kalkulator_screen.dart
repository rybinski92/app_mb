import 'package:flutter/material.dart';

class KalkulatorScreen extends StatefulWidget {
  const KalkulatorScreen({super.key});

  @override
  _KalkulatorScreenState createState() => _KalkulatorScreenState();
}

class _KalkulatorScreenState extends State<KalkulatorScreen> {
  final List<String> dystanse = [
    "1 km",
    "5 km",
    "10 km",
    "21.097 km",
    "42.195 km"
  ];

  // Kontrolery do kalkulatora tempa biegu
  String? _wybranyDystans;
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _mController = TextEditingController();
  final TextEditingController _hController = TextEditingController();
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _secController = TextEditingController();
  String _wynikTempo = "--:-- min/km";

  // Kontrolery do kalkulatora czasu odcinka
  final TextEditingController _tempoMinController = TextEditingController();
  final TextEditingController _tempoSecController = TextEditingController();
  final TextEditingController _odcinekKmController = TextEditingController();
  final TextEditingController _odcinekMController = TextEditingController();
  String _wynikCzasOdcinka = "--:--:--";

  // Obliczanie tempa biegu
  void _obliczTempo() {
    double dystans = _wybranyDystans != null
        ? double.parse(_wybranyDystans!.split(" ")[0])
        : (double.tryParse(_kmController.text) ?? 0) +
            (double.tryParse(_mController.text) ?? 0) / 1000;

    int calkowityCzasWSekundach =
        ((int.tryParse(_hController.text) ?? 0) * 3600) +
            ((int.tryParse(_minController.text) ?? 0) * 60) +
            (int.tryParse(_secController.text) ?? 0);

    if (dystans > 0 && calkowityCzasWSekundach > 0) {
      double tempoWSekundach = calkowityCzasWSekundach / dystans;
      int tempoMin = (tempoWSekundach / 60).floor();
      int tempoSek = (tempoWSekundach % 60).round();
      setState(() {
        _wynikTempo = "$tempoMin:${tempoSek.toString().padLeft(2, '0')} min/km";
      });
    } else {
      setState(() {
        _wynikTempo = "Niepoprawne dane";
      });
    }
  }

  // Obliczanie czasu odcinka
  void _obliczCzasOdcinka() {
    double tempoWSekundach =
        ((int.tryParse(_tempoMinController.text) ?? 0).toDouble() * 60) +
            (int.tryParse(_tempoSecController.text) ?? 0).toDouble();

    double dystans = (double.tryParse(_odcinekKmController.text) ?? 0) +
        (double.tryParse(_odcinekMController.text) ?? 0) / 1000;

    if (tempoWSekundach > 0 && dystans > 0) {
      int czasWSekundach = (tempoWSekundach * dystans).round();
      int godziny = czasWSekundach ~/ 3600;
      int minuty = (czasWSekundach % 3600) ~/ 60;
      int sekundy = czasWSekundach % 60;
      setState(() {
        _wynikCzasOdcinka =
            "$godziny:${minuty.toString().padLeft(2, '0')}:${sekundy.toString().padLeft(2, '0')}";
      });
    } else {
      setState(() {
        _wynikCzasOdcinka = "Niepoprawne dane";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalkulator biegowy"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700, // Ograniczamy szerokość formularza
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sekcjaTempaBiegu(),
                  const SizedBox(height: 40),
                  _sekcjaCzasuOdcinka(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Sekcja TEMPO BIEGU
  Widget _sekcjaTempaBiegu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tempo biegu",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _poleWybieraniaDystansu(),
        const SizedBox(height: 10),
        _poleWprowadzaniaDystansu(),
        const SizedBox(height: 10),
        _poleCzasu(),
        const SizedBox(height: 10),
        _przyciskOblicz(_obliczTempo),
        const SizedBox(height: 20),
        _wynik("Tempo biegu: $_wynikTempo"),
      ],
    );
  }

  // Sekcja CZAS ODCINKA
  Widget _sekcjaCzasuOdcinka() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Czas odcinka",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _poleWprowadzania("Planowane tempo biegu:", _tempoMinController, "min",
            _tempoSecController, "s"),
        const SizedBox(height: 10),
        _poleWprowadzania(
            "Dystans:", _odcinekKmController, "km", _odcinekMController, "m"),
        const SizedBox(height: 10),
        _przyciskOblicz(_obliczCzasOdcinka),
        const SizedBox(height: 20),
        _wynik("Czas odcinka: $_wynikCzasOdcinka"),
      ],
    );
  }

  // Elementy UI
  Widget _poleWybieraniaDystansu() {
    return DropdownButtonFormField<String>(
      value: _wybranyDystans,
      items: dystanse
          .map((dystans) =>
              DropdownMenuItem(value: dystans, child: Text(dystans)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _wybranyDystans = value;
          _kmController.clear();
          _mController.clear();
        });
      },
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget _poleWprowadzaniaDystansu() {
    return _poleWprowadzania(
        "Lub wprowadź dystans:", _kmController, "km", _mController, "m");
  }

  Widget _poleCzasu() {
    return _poleWprowadzania(
        "Planowany wynik:", _hController, "h", _minController, "min",
        dodatkowePole: _secController, dodatkowyLabel: "s");
  }

  Widget _poleWprowadzania(String label, TextEditingController ctrl1,
      String lbl1, TextEditingController ctrl2, String lbl2,
      {TextEditingController? dodatkowePole, String? dodatkowyLabel}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(children: [
          _input(ctrl1, lbl1),
          const SizedBox(width: 10),
          _input(ctrl2, lbl2),
          if (dodatkowePole != null) ...[
            const SizedBox(width: 10),
            _input(dodatkowePole, dodatkowyLabel!),
          ]
        ]),
      ],
    );
  }

  Widget _input(TextEditingController controller, String label) => Expanded(
      child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: label, border: const OutlineInputBorder())));

  Widget _przyciskOblicz(VoidCallback onPressed) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange, // Pomarańczowe tło
          foregroundColor: Colors.white, // Biały tekst
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        ),
        onPressed: onPressed,
        child: const Text(
          "OBLICZ",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _wynik(String text) => Center(
      child: Text(text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
}
