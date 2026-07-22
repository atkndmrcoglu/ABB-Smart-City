import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartcity/models/sehir_rehberim/kultur_sanat_model.dart'; // Model dosyanızın yolu

class KulturSanatApi {
  final String baseUrl = "http://172.20.10.10/api/kultur_sanat.php";

  Future<List<KulturSanatModel>> fetchKulturSanatYerleri() async {
     final String fullUrl = '$baseUrl?action=AllPlaces';
    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        if (decodedData.containsKey('data')) {
          final List<dynamic> rawList = decodedData['data'];
          return rawList.map((item) => KulturSanatModel.fromJson(item)).toList();
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