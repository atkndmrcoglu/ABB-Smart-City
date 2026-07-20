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

class KonaklamaModel {
  final String name;
  final double latitude;
  final double longitude;

  KonaklamaModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory KonaklamaModel.fromJson(Map<String, dynamic> json) {
    return KonaklamaModel(
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}