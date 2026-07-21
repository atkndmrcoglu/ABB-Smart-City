import 'dart:convert';
import 'package:http/http.dart' as http;

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
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}