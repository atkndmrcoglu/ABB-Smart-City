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

class UniversitiesModel {
  final String name;
  final double latitude;
  final double longitude;

  UniversitiesModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory UniversitiesModel.fromJson(Map<String, dynamic> json) {
    return UniversitiesModel(
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}