// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/halk_ekmek_model.dart';

class HalkEkmekService {
  final String baseUrl = "http://172.20.10.10/api/halk_ekmek.php";

  Future<List<HalkEkmekBufe>> getTumBufeler() async {
    final String fullUrl = '$baseUrl?action=all_bufeler';
    
    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Halk Ekmek API URL: $fullUrl');
      print('Halk Ekmek API Status: ${response.statusCode}');
      print('Halk Ekmek API Body: ${response.body}'); 
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            print('Yüklenen Büfe Sayısı: ${data.length}');
            return data.map((json) => HalkEkmekBufe.fromJson(json)).toList();
          }
          return [];
        }
        
        if (jsonData is List) {
          print('Yüklenen Büfe Sayısı: ${jsonData.length}');
          return jsonData.map((json) => HalkEkmekBufe.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("--- [Halk Ekmek API Hata] Veri çekilemedi: $e ---");
    }
    return [];
  }
}