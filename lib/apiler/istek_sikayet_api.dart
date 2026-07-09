import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestService {
  // BASE URL'inizi buraya tanımlayın (örn: https://api.belediye.gov.tr veya local test için http://10.0.2.2:8000)
  static const String _baseUrl = "https://YOUR_BACKEND_API_ENDPOINT.com";

  /// İstek ve Şikayet formunu backend sunucusuna iletir.
  /// [veri] formdaki metinsel alanları, [fotoPath] ve [dosyaPath] ise cihazdaki yerel dosya yollarını ifade eder.
  Future<bool> gonderIstekSikayet({
    required Map<String, String> veri,
    String? fotoPath,
    String? dosyaPath,
  }) async {
    try {
      // API uç noktasını (Endpoint) belirliyoruz
      var url = Uri.parse("$_baseUrl/api/istek-sikayet/kaydet");

      // İstek tipini Multipart olarak oluşturuyoruz
      var request = http.MultipartRequest('POST', url);

      // --- 1. HEADERS (Korumalar / Yetkilendirmeler) ---
      // Eğer backend tarafında Bearer Token veya özel bir Key mekanizması varsa buraya ekleyin
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        // 'Authorization': 'Bearer YOUR_TOKEN_HERE', 
      });

      // --- 2. TEXT FIELDS (Form Verileri) ---
      // Form içindeki tüm String key-value ikililerini isteğe ekliyoruz
      request.fields.addAll(veri);

      // --- 3. FILE ATTACHMENTS (Dosya / Fotoğraf Eki) ---
      // Fotoğraf seçildiyse byte akışı olarak isteğe ekleniyor
      if (fotoPath != null && fotoPath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'fotograf', // Backend tarafının beklediği parametre adı
            fotoPath,
          ),
        );
      }

      // Doküman/Belge seçildiyse isteğe ekleniyor
      if (dosyaPath != null && dosyaPath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'dosya', // Backend tarafının beklediği parametre adı
            dosyaPath,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("API Yanıtı Başarılı: ${response.body}");
        return true;
      } else {
        print("API Sunucu Hatası (${response.statusCode}): ${response.body}");
        return false;
      }
    } catch (e) {
      print("API Bağlantı Hatası: $e");
      return false;
    }
  }
}