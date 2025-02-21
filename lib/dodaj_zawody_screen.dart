import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class DodajZawodyScreen extends StatefulWidget {
  const DodajZawodyScreen({Key? key}) : super(key: key);

  @override
  _DodajZawodyScreenState createState() => _DodajZawodyScreenState();
}

class _DodajZawodyScreenState extends State<DodajZawodyScreen> {
  DateTime? _selectedDate;
  final _nazwaController = TextEditingController();
  final _dystansController = TextEditingController();
  final _miejscowoscController = TextEditingController();

  final List<String> wojewodztwa = [
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

  String? _selectedWojewodztwo;
  bool _isGorskiePunktowane = false; // Nowa zmienna

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Zawody'),
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
                children: [
                  _poleTekstowe(_nazwaController, 'Nazwa zawodów'),
                  const SizedBox(height: 20),
                  _poleDaty(),
                  const SizedBox(height: 20),
                  _poleTekstowe(_dystansController, 'Dystans (np. 5 km, 10 km)'),
                  const SizedBox(height: 20),
                  _poleTekstowe(_miejscowoscController, 'Miejscowość'),
                  const SizedBox(height: 20),
                  _poleDropdown(),
                  const SizedBox(height: 20),
                  _poleGorskiePunktowane(), // Dodajemy nowe pole
                  const SizedBox(height: 30),
                  _przyciskZapisz(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Pole tekstowe
  Widget _poleTekstowe(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // Pole daty
  Widget _poleDaty() {
    return TextField(
      readOnly: true,
      onTap: () => _selectDate(context),
      controller: TextEditingController(
        text: _selectedDate == null ? '' : DateFormat('dd-MM-yyyy').format(_selectedDate!),
      ),
      decoration: const InputDecoration(
        labelText: 'Data zawodów',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
    );
  }

  // Pole wyboru województwa
  Widget _poleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedWojewodztwo,
      hint: const Text('Wybierz województwo'),
      onChanged: (newValue) {
        setState(() {
          _selectedWojewodztwo = newValue;
        });
      },
      items: wojewodztwa.map((wojewodztwo) {
        return DropdownMenuItem(
          value: wojewodztwo,
          child: Text(wojewodztwo),
        );
      }).toList(),
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
      ),
    );
  }

  // Pole "Czy zawody górskie punktowane w RMT"
  Widget _poleGorskiePunktowane() {
    return Row(
      children: [
        const Text('Czy zawody górskie punktowane w RMT?'),
        Switch(
          value: _isGorskiePunktowane,
          onChanged: (value) {
            setState(() {
              _isGorskiePunktowane = value;
            });
          },
        ),
        Text(_isGorskiePunktowane ? 'Tak' : 'Nie'),
      ],
    );
  }

  // Przycisk "Zapisz"
  Widget _przyciskZapisz() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      onPressed: () => _sendToAppSheet(),
      child: const Text(
        'Zapisz',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  // Wybór daty
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Wysyłanie danych do AppSheet
  Future<void> _sendToAppSheet() async {
    const String apiUrl =
        "https://api.appsheet.com/api/v2/apps/57025f21-4219-4291-ba75-6745b608e965/tables/Arkusz1/Add";

    const String applicationAccessKey = Config.apiKey1;  
    // final String? apiKey1 = await Config.getApiKey1(); 

    if (_nazwaController.text.isEmpty ||
        _selectedDate == null ||
        _dystansController.text.isEmpty ||
        _miejscowoscController.text.isEmpty ||
        _selectedWojewodztwo == null) {
      _showSnackBar('Wypełnij wszystkie pola!', Colors.red);
      return;
    }

    final Map<String, dynamic> zawodyData = {
      "Action": "Add",
      "Properties": {"Locale": "pl-PL"},
      "Rows": [
        {
          "nazwa": _nazwaController.text,
          "data": DateFormat('yyyy-MM-dd').format(_selectedDate!),
          "dystans": _dystansController.text,
          "miejsce": _miejscowoscController.text,
          "wojewodztwo": _selectedWojewodztwo!,
          "czy_gorskie": _isGorskiePunktowane ? "1" : "0", // Dodajemy nową kolumnę
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": applicationAccessKey, 
          // "ApplicationAccessKey": apiKey1 ?? "",
        },
        body: jsonEncode(zawodyData),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Zawody zapisane, po zweryfikowaniu dodamy je do listy.', Colors.green);
      } else {
        _showSnackBar('Błąd zapisu: ${response.body}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Błąd: $e', Colors.red);
    }
  }

  // Powiadomienie SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}