
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ulasim_model.dart';

class UlasimService {
  final String baseUrl = "http://172.20.10.10/api/ulasim.php";

  Future<List<Hat>> getTumHatlar() async {
    final String fullUrl = '$baseUrl?action=routes';
    
    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Hat URL: $fullUrl');
      print('Hat Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            return data.map((json) => Hat.fromJson(json)).toList();
          }
          return [];
        }
        
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

  Future<List<RotaNoktasi>> getRotaCizgisi(String shapeId) async {
    final String fullUrl = '$baseUrl?action=shapes&id=$shapeId';
    
    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Rota URL: $fullUrl');
      print('Rota Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            return data.map((json) => RotaNoktasi.fromJson(json)).toList();
          }
          return [];
        }
        
        if (jsonData is List) {
          return jsonData.map((json) => RotaNoktasi.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("--- [API HATA] Rota çizgi hatası: $e ---");
    }
    return [];
  }

  Future<List<Durak>> getSeferDuraklari(String tripId) async {
    final String fullUrl = '$baseUrl?action=stops&id=$tripId';

    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Durak URL: $fullUrl');
      print('Durak Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            return data.map((json) => Durak.fromJson(json)).toList();
          }
          return [];
        }
        
        if (jsonData is List) {
          return jsonData.map((json) => Durak.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("--- [API HATA] Durak çekme hatası: $e ---");
    }
    return [];
  }

  Future<List<Durak>> getTumDuraklar() async {
    final String fullUrl = '$baseUrl?action=all_stops';

    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Tüm Duraklar URL: $fullUrl');
      print('Tüm Duraklar Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            return data.map((json) => Durak.fromJson(json)).toList();
          }
          return [];
        }
        
        if (jsonData is List) {
          return jsonData.map((json) => Durak.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("--- [API HATA] Tüm duraklar hatası: $e ---");
    }
    return [];
  }

  Future<List<String>> getDurakHatlar(String stopId) async {
    final String fullUrl = '$baseUrl?action=stop_routes&id=$stopId';

    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Durak Hatları URL: $fullUrl');
      print('Durak Hatları Status: ${response.statusCode}');
      print('Durak Hatları Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        List<String> hatlar = [];
        
        if (jsonData is List) {
          hatlar = jsonData
              .map((e) => e is Map ? (e['route_short_name']?.toString() ?? '') : '')
              .where((item) => item.isNotEmpty)
              .toList();
        } else if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          final List<dynamic> data = jsonData['data'];
          hatlar = data
              .map((e) => e is Map ? (e['route_short_name']?.toString() ?? '') : '')
              .where((item) => item.isNotEmpty)
              .toList();
        }
        
        print('Durak $stopId için ${hatlar.length} aktif hat bulundu: $hatlar');
        return hatlar;
      }
    } catch (e) {
      print("--- [API HATA] Durak hatları hatası: $e ---");
    }
    return [];
  }
  Future<Map<String, String>?> getHatDetay(String hatNo) async {
    final String fullUrl = '$baseUrl?action=route_details&id=$hatNo';

    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Hat Detay URL: $fullUrl');
      print('Hat Detay Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return null;
          }
          
          String sonDurak = 'Bilinmiyor';
          String guzergah = 'Bilinmiyor';
          
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data is Map<String, dynamic>) {
              sonDurak = data['last_stop']?.toString() ?? 'Bilinmiyor';
              guzergah = data['route_description']?.toString() ?? 'Bilinmiyor';
            } else if (data is List && data.isNotEmpty) {
              final first = data[0];
              sonDurak = first['last_stop']?.toString() ?? 'Bilinmiyor';
              guzergah = first['route_description']?.toString() ?? 'Bilinmiyor';
            }
          } else {
            sonDurak = jsonData['last_stop']?.toString() ?? 'Bilinmiyor';
            guzergah = jsonData['route_description']?.toString() ?? 'Bilinmiyor';
          }
          
          return {
            'sonDurak': sonDurak,
            'guzergah': guzergah,
          };
        }
      }
    } catch (e) {
      print("--- [API HATA] Hat detay hatası: $e ---");
    }
    return null;
  }

  Future<Map<String, String>?> getYaklasanArac(String stopId, String hatNo) async {
    final String fullUrl = '$baseUrl?action=vehicle_info&stop_id=$stopId&route_id=$hatNo';

    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Yaklaşan Araç URL: $fullUrl');
      print('Yaklaşan Araç Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return null;
          }
          
          String dakika = 'Bilinmiyor';
          String mesafe = 'Bilinmiyor';
          
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data is Map<String, dynamic>) {
              dakika = data['minutes']?.toString() ?? 'Bilinmiyor';
              mesafe = data['distance']?.toString() ?? 'Bilinmiyor';
            } else if (data is List && data.isNotEmpty) {
              final first = data[0];
              dakika = first['minutes']?.toString() ?? 'Bilinmiyor';
              mesafe = first['distance']?.toString() ?? 'Bilinmiyor';
            }
          } else {
            dakika = jsonData['minutes']?.toString() ?? 'Bilinmiyor';
            mesafe = jsonData['distance']?.toString() ?? 'Bilinmiyor';
          }
          
          return {
            'dakika': dakika,
            'mesafe': mesafe,
          };
        }
      }
    } catch (e) {
      print("--- [API HATA] Yaklaşan araç hatası: $e ---");
    }
    return null;
  }

  Future<List<String>> getKalkisSaatleri(String hatNo) async {
    final String fullUrl = '$baseUrl?action=departure_times&route_id=$hatNo';

    try {
      final response = await http.get(Uri.parse(fullUrl));
      print('Kalkış Saatleri URL: $fullUrl');
      print('Kalkış Saatleri Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        List<String> saatler = [];
        
        if (jsonData is List) {
          saatler = jsonData
              .map((e) => e is Map ? (e['time']?.toString() ?? '') : '')
              .where((t) => t.isNotEmpty)
              .toList();
        } else if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            print('API Hatası: ${jsonData['error']}');
            return [];
          }
          
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data is List) {
              saatler = data
                  .map((e) => e is Map ? (e['time']?.toString() ?? '') : '')
                  .where((t) => t.isNotEmpty)
                  .toList();
            }
          }
        }
        
        print('Hat $hatNo için ${saatler.length} kalkış saati bulundu');
        return saatler;
      }
    } catch (e) {
      print("--- [API HATA] Kalkış saatleri hatası: $e ---");
    }
    return [];
  }
}