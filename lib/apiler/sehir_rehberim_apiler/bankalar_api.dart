// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartcity/models/sehir_rehberim/bankalar_model.dart';

class BankalarService {
  final String baseUrl = "http://172.20.10.10/api/bankalar.php";

  Future<List<BankalarModel>> getTumBankalar() async {
    final String fullUrl = '$baseUrl?action=all_bank';
    
    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Bankalar API URL: $fullUrl');
      print('Bankalar API Status: ${response.statusCode}');
      print('Bankalar API Body: ${response.body}'); 
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            print('Yüklenen Banka Sayısı: ${data.length}');
            return data.map((json) => BankalarModel.fromJson(json)).toList();
          }
          return [];
        }
        
        if (jsonData is List) {
          print('Yüklenen Banka Sayısı: ${jsonData.length}');
          return jsonData.map((json) => BankalarModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("--- [Cami API Hata] Veri çekilemedi: $e ---");
    }
    return [];
  }
}