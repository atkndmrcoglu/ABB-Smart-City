// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/services.dart'; // rootBundle için gerekli
import '../models/eczane_model.dart';

class EczaneApiService {

  Future<List<Eczane>> nobetciEczaneleriGetir(String ilce) async {
    try {
      // 1. Gerçek API gecikmesini simüle etmek için 1 saniye bekletiyoruz
      await Future.delayed(const Duration(seconds: 1));

      // 2. Yerel JSON dosyamızı okuyoruz
      final String response = await rootBundle.loadString('assets/json_files/eczaneler.json');
      final Map<String, dynamic> responseData = json.decode(response);

      if (responseData['status'] == 'success' && responseData['data'] != null) {
        final List<dynamic> tumEczaneler = responseData['data'];
        
        // 3. Kullanıcın seçtiği ilçeye göre yerel filtreleme yapıyoruz
        final arananIlce = ilce.trim().toLowerCase();
        
        final filtrelenmisEczaneler = tumEczaneler.where((item) {
          // JSON içindeki 'Ilce' değerini kontrol ediyoruz
          return item['Ilce'] == arananIlce;
        }).toList();

        return filtrelenmisEczaneler.map((json) => Eczane.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print("Yerel veri okuma hatası: $e");
      return [];
    }
  }
}