import 'dart:convert';
import 'package:http/http.dart' as http;

class NamazApi {
  static const String _baseUrl = 'https://api.collectapi.com/pray/all';
  static const String _apiKey = 'apikey 7tL19WvowcXsMSYg2urBpJ:3qgax2KqoUvckr8MOsfOk4'; 

  Future<List<NamazVakti>> fetchNamazVakitleri(String city) async {
    final String formattedCity = city.trim().toLowerCase();
    final Uri url = Uri.parse('$_baseUrl?city=$formattedCity');

    try {
      final response = await http.get(
        url,
        headers: {
          'content-type': 'application/json',
          'authorization': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        if (decodedData['success'] == true) {
          final List<dynamic> resultList = decodedData['result'];
          return resultList.map((json) => NamazVakti.fromJson(json)).toList();
        } else {
          throw Exception('API Başarısız Yanıt Döndü');
        }
      } else {
        throw Exception('Bağlantı Hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bir hata oluştu: $e');
    }
  }
}
class NamazVakti {
  final String saat;
  final String vakit;

  NamazVakti({required this.saat, required this.vakit});

  factory NamazVakti.fromJson(Map<String, dynamic> json) {
    return NamazVakti(
      saat: json['saat'] ?? '',
      vakit: json['vakit'] ?? '',
    );
  }
}