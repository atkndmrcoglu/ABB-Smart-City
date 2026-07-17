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

class SinemaTiyatroModel {
  final String isim;
  final double lat;
  final double lon;
  final String adres;

  SinemaTiyatroModel({
    required this.isim,
    required this.lat,
    required this.lon,
    required this.adres,
  });

  factory SinemaTiyatroModel.fromJson(Map<String, dynamic> json) {
    return SinemaTiyatroModel(
      isim: json['isim'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      adres: json['adres'] ?? '',
    );
  }
}