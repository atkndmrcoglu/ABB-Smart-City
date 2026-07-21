import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/halk_ekmek_model.dart';

class HalkEkmekApi {
  final String baseUrl = "http://172.20.10.10/api/halk_ekmek.php";

  Future<List<HalkEkmekModel>> getTumBufeler() async {
    final String fullUrl = '$baseUrl?action=all_bufeler';
    
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
            return data.map((json) => HalkEkmekModel.fromJson(json)).toList();
          }
          return [];
        }
        
        if (jsonData is List) {
          return jsonData.map((json) => HalkEkmekModel.fromJson(json)).toList();
        }
      }
    } finally{}
    return [];
  }
}