// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartcity/models/sehir_rehberim/cami_model.dart';

class CamiService {
  final String baseUrl = "http://172.20.10.10/api/camiler.php";

  Future<List<CamiModel>> getTumCamiler() async {
    final String fullUrl = '$baseUrl?action=all_mosque';
    
    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Cami API URL: $fullUrl');
      print('Cami API Status: ${response.statusCode}');
      print('Cami API Body: ${response.body}'); 
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            print('Yüklenen Cami Sayısı: ${data.length}');
            return data.map((json) => CamiModel.fromJson(json)).toList();
          }
          return [];
        }
        
        if (jsonData is List) {
          print('Yüklenen Cami Sayısı: ${jsonData.length}');
          return jsonData.map((json) => CamiModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("--- [Cami API Hata] Veri çekilemedi: $e ---");
    }
    return [];
  }
}