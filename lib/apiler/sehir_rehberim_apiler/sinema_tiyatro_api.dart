import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartcity/models/sehir_rehberim/sinema_tiyatro_model.dart';

class SinemaTiyatroApi {
  final String _baseUrl = "http://172.20.10.10/api/sinema_tiyatro.php?action=all_places";

  Future<List<SinemaTiyatroModel>> fetchAllPlaces() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        if (decodedData.containsKey('data')) {
          final List<dynamic> rawList = decodedData['data'];
          return rawList.map((item) => SinemaTiyatroModel.fromJson(item)).toList();
        } else {
          throw Exception("API 'data' anahtarı içermiyor.");
        }
      } else {
        throw Exception("Sunucu hatası: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }
}