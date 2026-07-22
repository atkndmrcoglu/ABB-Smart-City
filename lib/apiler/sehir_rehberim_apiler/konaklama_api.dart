import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartcity/models/sehir_rehberim/konaklama_model.dart';

class KonaklamaApi {
  final String baseUrl = "http://172.20.10.10/api/konaklama.php";

  Future<List<KonaklamaModel>> fetchAllPlaces() async {
    final String fullUrl = '$baseUrl?action=AllPlaces';

    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('error')) {
            return [];
          }
          if (jsonData.containsKey('data')) {
            final List<dynamic> data = jsonData['data'];
            return data
                .map((json) => KonaklamaModel.fromJson(json))
                .toList();
          }
          return [];
        }

        if (jsonData is List) {
          return jsonData
              .map((json) => KonaklamaModel.fromJson(json))
              .toList();
        }
      }
    } finally{}

    return [];
  }
}