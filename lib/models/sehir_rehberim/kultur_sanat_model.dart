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

class KulturSanatModel {
  final String isim;
  final double lat;
  final double lon;
  final String adres;
  final String altBaslik;
  final String aciklama;
  final List<KartIcerikDetay> detaylar;

  KulturSanatModel({
    required this.isim,
    required this.lat,
    required this.lon,
    required this.adres,
    required this.altBaslik,
    required this.aciklama,
    required this.detaylar,
  });

  factory KulturSanatModel.fromJson(Map<String, dynamic> json) {
    return KulturSanatModel(
      isim: json['isim'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      adres: json['adres'] ?? '',
      altBaslik: json['alt_baslik'] ?? 'Adana',
      aciklama: json['aciklama'] ?? '',
      detaylar: [
        KartIcerikDetay(
          rozetMetni: json['rozet_1'] ?? 'Tarih',
          anahtarIkon: Icons.star_border_rounded,
          anahtarVeri: json['rozet_1_veri'] ?? 'Ziyarete Açık',
        ),
        KartIcerikDetay(
          rozetMetni: json['rozet_2'] ?? 'Giriş',
          anahtarIkon: Icons.confirmation_number_outlined,
          anahtarVeri: json['rozet_2_veri'] ?? 'Ücretsiz',
        ),
      ],
    );
  }
}