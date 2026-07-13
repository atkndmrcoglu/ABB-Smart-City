import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/metro_model.dart';

class MetroApi {
  static const String _baseUrl = "http://172.20.10.10/api/metro.php";

  // 1. Tablo: Tüm İstasyonları Çek
  Future<List<MetroStation>> fetchStations() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl?action=stations"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData['status'] == 'success') {
          List<dynamic> rawList = decodedData['data'];
          return rawList.map((item) => MetroStation.fromJson(item)).toList();
        } else {
          throw Exception(decodedData['message']);
        }
      }
      throw Exception("Sunucu hatası: ${response.statusCode}");
    } catch (e) {
      throw Exception("İstasyonlar yüklenemedi: $e");
    }
  }

  // 2. Tablo: Seçilen İstasyonun Sefer Saatlerini Çek
  Future<List<MetroSchedule>> fetchSchedules(int stationId) async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl?action=schedules&station_id=$stationId"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData['status'] == 'success') {
          List<dynamic> rawList = decodedData['data'];
          return rawList.map((item) => MetroSchedule.fromJson(item)).toList();
        } else {
          throw Exception(decodedData['message']);
        }
      }
      throw Exception("Sunucu hatası: ${response.statusCode}");
    } catch (e) {
      throw Exception("Sefer saatleri yüklenemedi: $e");
    }
  }
}