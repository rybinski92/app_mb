import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    "Dolnośląskie",
    "Kujawsko-Pomorskie",
    "Lubelskie",
    "Lubuskie",
    "Małopolskie",
    "Mazowieckie",
    "Opolskie",
    "Podkarpackie",
    "Podlaskie",
    "Pomorskie",
    "Śląskie",
    "Świętokrzyskie",
    "Warmińsko-Mazurskie",
    "Wielkopolskie",
    "Zachodniopomorskie"
  ];

  String? _selectedWojewodztwo;

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
        "https://api.appsheet.com/api/v2/apps/0e6e9e7d-d4f2-42a1-a631-d962f2aae09e/tables/Arkusz1/Add";

    const String applicationAccessKey = "V2-Us69h-0IidB-WN9C0-Uhitj-CZgM8-rwMpD-DL6d1-EQYrE"; // <-- Wstaw swój klucz API

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
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": applicationAccessKey, // ✅ Dodany klucz API
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