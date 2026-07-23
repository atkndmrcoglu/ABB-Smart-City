import 'package:flutter/material.dart';

class KartIcerikDetay {
  final String rozetMetni;
  final IconData anahtarIkon;
  final String anahtarVeri;

  KartIcerikDetay({
    required this.rozetMetni,
    required this.anahtarIkon,
    required this.anahtarVeri,
  });
}

class EczanelerModel {
  final String name;
  final double lat;
  final double lon;
  final int is_on_duty;

  EczanelerModel({
    required this.name,
    required this.lat,
    required this.lon,
    required this.is_on_duty,
  });

  factory EczanelerModel.fromJson(Map<String, dynamic> json) {
    return EczanelerModel(
      name: json['name']?.toString() ?? '',
      
      // double.tryParse kullanarak dönüşüm hatalarının önüne geçildi
      lat: double.tryParse(json['lat']?.toString() ?? '') ?? 0.0,
      
      // Hem 'lon' hem de 'long' gelme ihtimaline karşı ikisi de kontrol ediliyor
      lon: double.tryParse((json['lon'] ?? json['long'])?.toString() ?? '') ?? 0.0,
      
      // int.tryParse ile güvenli sayı dönüşümü
      is_on_duty: int.tryParse(json['is_on_duty']?.toString() ?? '') ?? 0,
    );
  }
}