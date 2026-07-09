import 'package:http/http.dart' as http;
import 'dart:io'; // File işlemleri için gerekli

class AmbalajAtikService {
  // TODO: Kendi backend API url adresinizi buraya yazın
  static const String _baseUrl = 'https://api.example.com/ambalaj-atik';

  Future<bool> gonderAmbalajAtik({
    required Map<String, String> veri,
    String? fotoPath,
  }) async {
    try {
      // TODO: Backend tarafındaki endpoint rotasını düzenleyin (örn: /gonder veya /bildir)
      var uri = Uri.parse('$_baseUrl/gonder');
      var request = http.MultipartRequest('POST', uri);

      // Arayüzden gelen temizlenmiş form verilerini (Ad-Soyad, Atık Türü, Telefon vb.) ekliyoruz
      request.fields.addAll(veri);

      // TODO: Eğer backend tarafında her istekte Bearer Token (Yetkilendirme) isteniyorsa alt satırı aktif edin:
      // request.headers['Authorization'] = 'Bearer SIZIN_TOKEN_INIZ';
      
      request.headers['Accept'] = 'application/json';

      // Eğer bir fotoğraf seçildiyse ve dosya sistemde gerçekten mevcutsa ekliyoruz
      if (fotoPath != null && fotoPath.isNotEmpty) {
        File fotoDosyasi = File(fotoPath);
        
        if (await fotoDosyasi.exists()) {
          // TODO: 'fotograf' anahtar kelimesini (key), backend'in istekte beklediği isimle değiştirin (örn: 'image', 'file', 'atik_gorsel')
          var multipartFile = await http.MultipartFile.fromPath(
            'fotograf', 
            fotoDosyasi.path,
          );
          request.files.add(multipartFile);
        } else {
          print("Hata: Belirtilen yolda bir fotoğraf dosyası bulunamadı.");
        }
      }

      // İsteği sunucuya gönderiyoruz
      var response = await request.send();

      // Başarılı durum kodları (200 OK veya 201 Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // TODO: Sunucudan dönen yanıt mesajını okumak isterseniz alt satırı kullanabilirsiniz:
        // var responseData = await http.Response.fromStream(response);
        // print("Sunucu Yanıtı: ${responseData.body}");
        
        return true;
      } else {
        // Hata durumunda loglama yapıyoruz
        var responseData = await http.Response.fromStream(response);
        print("Sunucu Hatası Kodu: ${response.statusCode}");
        print("Sunucu Hata Detayı: ${responseData.body}");
        return false;
      }
    } catch (e) {
      print("Ambalaj Atık API Bağlantı Hatası: $e");
      return false;
    }
  }
}