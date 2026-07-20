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

class DevletDaireleriModel {
  final String name;
  final double latitude;
  final double longitude;

  DevletDaireleriModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory DevletDaireleriModel.fromJson(Map<String, dynamic> json) {
    return DevletDaireleriModel(
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}