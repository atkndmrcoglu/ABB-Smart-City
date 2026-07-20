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

class SporModel {
  final String name;
  final String sport;
  final double latitude;
  final double longitude;

  SporModel({
    required this.name,
    required this.sport,
    required this.latitude,
    required this.longitude,
  });

  factory SporModel.fromJson(Map<String, dynamic> json) {
    return SporModel(
      name: json['name'] ?? '',
      sport: json['sport'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}