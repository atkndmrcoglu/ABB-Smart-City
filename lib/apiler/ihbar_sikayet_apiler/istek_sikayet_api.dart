// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartcity/models/ihbar_sikayet/istek_sikayet_model.dart';

class RequestService {
  static const String _baseUrl = "http://172.20.10.10/api/istek_sikayet.php";

  Future<bool> gonderIstekSikayet({
    required Map<String, String> veri,
  }) async {
    try {
      var uri = Uri.parse('$_baseUrl?action=add_report');
      
      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(veri),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("İstek/Şikayet Başarıyla Gönderildi.");
        return true;
      } else {
        print("Sunucu Hatası Kodu: ${response.statusCode}");
        print("Sunucu Hata Detayı: ${response.body}");
        return false;
      }
    } catch (e) {
      print("İstek/Şikayet API Bağlantı Hatası: $e");
      return false;
    }
  }
}