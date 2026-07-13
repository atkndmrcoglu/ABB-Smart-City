import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wifi_noktasi_model.dart'; // Model adını buna göre güncelleyebilirsin

class WifiNoktasiService {
  final String baseUrl = "http://172.20.10.10/api/wifi_noktalari.php";

  Future<List<WifiNoktasi>> getTumWifiNoktalari() async {
    final String fullUrl = '$baseUrl?action=all_wifi_spots';
    
    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('WiFi API URL: $fullUrl');
      print('WiFi API Status: ${response.statusCode}');
      print('WiFi API Body: ${response.body}'); 
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // API'den Map (Obje) dönüyorsa (Örn: {"status": true, "data": [...]})
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            print('Yüklenen WiFi Noktası Sayısı: ${data.length}');
            return data.map((json) => WifiNoktasi.fromJson(json)).toList();
          }
          return [];
        }
        
        // API doğrudan liste dönüyorsa (Örn: [ {"id": 1, ...}, {"id": 2, ...} ])
        if (jsonData is List) {
          print('Yüklenen WiFi Noktası Sayısı: ${jsonData.length}');
          return jsonData.map((json) => WifiNoktasi.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("--- [WiFi API Hata] Veri çekilemedi: $e ---");
    }
    return [];
  }
}