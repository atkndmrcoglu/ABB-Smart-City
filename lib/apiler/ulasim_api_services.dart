import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ulasim_model.dart';

class UlasimService {
  final String baseUrl = "http://127.0.0.1/api/ulasim.php";

  // 1. Tüm Hatları Getir - DÜZELTİLDİ
  Future<List<Hat>> getTumHatlar() async {
    final String fullUrl = '$baseUrl?action=routes';
    
    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Hat URL: $fullUrl');
      print('Hat Status: ${response.statusCode}');
      print('Hat Body: ${response.body}'); // DEBUG
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        // Eğer gelen veri Map ise (hata mesajı veya debug içeriyorsa)
        if (jsonData is Map<String, dynamic>) {
          // Hata varsa
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          // data anahtarı varsa onu kullan
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            print('Hat Sayısı: ${data.length}');
            return data.map((json) => Hat.fromJson(json)).toList();
          }
          return [];
        }
        
        // Doğrudan liste ise
        if (jsonData is List) {
          print('Hat Sayısı: ${jsonData.length}');
          return jsonData.map((json) => Hat.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("--- [API HATA] Hat listesi hatası: $e ---");
    }
    return [];
  }

  // 2. Rota Çizgisini Getir - DÜZELTİLDİ
  Future<List<RotaNoktasi>> getRotaCizgisi(String shapeId) async {
    final String fullUrl = '$baseUrl?action=shapes&id=$shapeId';
    
    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Rota URL: $fullUrl');
      print('Rota Status: ${response.statusCode}');
      print('Rota Body: ${response.body}'); // DEBUG
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        // Eğer gelen veri Map ise (hata mesajı veya debug içeriyorsa)
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            print('Rota Noktası Sayısı: ${data.length}');
            return data.map((json) => RotaNoktasi.fromJson(json)).toList();
          }
          return [];
        }
        
        // Doğrudan liste ise
        if (jsonData is List) {
          print('Rota Noktası Sayısı: ${jsonData.length}');
          return jsonData.map((json) => RotaNoktasi.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("--- [API HATA] Rota çizgi hatası: $e ---");
    }
    return [];
  }

  // 3. Durakları Getir - DÜZELTİLDİ
  Future<List<Durak>> getSeferDuraklari(String tripId) async {
    final String fullUrl = '$baseUrl?action=stops&id=$tripId';

    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Durak URL: $fullUrl');
      print('Durak Status: ${response.statusCode}');
      print('Durak Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        // Eğer gelen veri Map ise (hata mesajı veya debug içeriyorsa)
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            print('Durak Sayısı: ${data.length}');
            return data.map((json) => Durak.fromJson(json)).toList();
          }
          return [];
        }
        
        // Doğrudan liste ise
        if (jsonData is List) {
          print('Durak Sayısı: ${jsonData.length}');
          if (jsonData.isNotEmpty) {
            print('İlk Durak: ${jsonData[0]}');
          }
          return jsonData.map((json) => Durak.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("--- [API HATA] Durak çekme hatası: $e ---");
    }
    return [];
  }

  // 4. Tüm Durakları Getir - YENİ
  Future<List<Durak>> getTumDuraklar() async {
    final String fullUrl = '$baseUrl?action=all_stops';

    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Tüm Duraklar URL: $fullUrl');
      print('Tüm Duraklar Status: ${response.statusCode}');
      print('Tüm Duraklar Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            print('Tüm Duraklar Sayısı: ${data.length}');
            return data.map((json) => Durak.fromJson(json)).toList();
          }
          return [];
        }
        
        if (jsonData is List) {
          print('Tüm Duraklar Sayısı: ${jsonData.length}');
          return jsonData.map((json) => Durak.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("--- [API HATA] Tüm duraklar hatası: $e ---");
    }
    return [];
  }

  // 5. Duraktan Geçen Hatları Getir
Future<List<String>> getDurakHatlar(String stopId) async {
  final String fullUrl = '$baseUrl?action=stop_routes&id=$stopId';

  try {
    final response = await http.get(Uri.parse(fullUrl));
    print('Durak Hatları URL: $fullUrl');
    print('Durak Hatları Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      
      List<String> hatlar = [];
      
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
        final List<dynamic> data = jsonData['data'];
        hatlar = data.map((e) => e['route_short_name']?.toString() ?? '').toList();
      } else if (jsonData is List) {
        hatlar = jsonData.map((e) => e['route_short_name']?.toString() ?? '').toList();
      }
      
      print('Durak $stopId için ${hatlar.length} hat bulundu');
      return hatlar;
    }
  } catch (e) {
    print("--- [API HATA] Durak hatları hatası: $e ---");
  }
  return [];
}
}