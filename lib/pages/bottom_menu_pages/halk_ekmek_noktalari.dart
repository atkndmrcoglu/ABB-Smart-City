// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../apiler/halk_ekmek_api.dart';
import '../../models/halk_ekmek_model.dart';

class HalkEkmekNoktalari extends StatefulWidget {
  const HalkEkmekNoktalari({super.key});

  @override
  State<HalkEkmekNoktalari> createState() => _HalkEkmekNoktalariState();
}

class _HalkEkmekNoktalariState extends State<HalkEkmekNoktalari> {
  final MapController _mapController = MapController();
  LatLng _haritaMerkezi = const LatLng(37.0486, 35.2459); 
  bool _yukleniyor = true;
  bool _haritaHazir = false; 

  final _halkEkmekService = HalkEkmekService(); 
  List<HalkEkmekBufe> _halkEkmekBufeleri = [];

  @override
  void initState() {
    super.initState();
    _cihazKonumunuGetir();
    _veritabanindanBufeleriGetir();
  }

  Future<void> _cihazKonumunuGetir() async {
    bool servisEtkin = await Geolocator.isLocationServiceEnabled();
    if (!servisEtkin) return;

    LocationPermission izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
      if (izin == LocationPermission.denied) return;
    }
    if (izin == LocationPermission.deniedForever) return;

    Position konum = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    if (mounted) {
      setState(() {
        _haritaMerkezi = LatLng(konum.latitude, konum.longitude);
      });
      
      if (_haritaHazir) {
        _mapController.move(_haritaMerkezi, 13.0);
      }
    }
  }

  Future<void> _veritabanindanBufeleriGetir() async {
    if (!mounted) return;
    setState(() => _yukleniyor = true);
    try {
      final bufeler = await _halkEkmekService.getTumBufeler();

      if (mounted) {
        setState(() {
          _halkEkmekBufeleri = bufeler;
          _yukleniyor = false;
        });

        // Gelen listeden ("100. YIL-1" gibi) ilk büfenin koordinatını alıp haritayı oraya uçuruyoruz
        if (bufeler.isNotEmpty) {
          final firstBufeCenter = LatLng(bufeler.first.lat, bufeler.first.lon);
          setState(() {
            _haritaMerkezi = firstBufeCenter;
          });
          
          if (_haritaHazir) {
            _mapController.move(firstBufeCenter, 13.0);
          }
        }
      }
    } catch (e) {
      print("Büfeler haritaya yüklenirken hata oluştu: $e");
      if (mounted) {
        setState(() => _yukleniyor = false);
      }
    }
  }

  /// Seçilen büfeye dış harita uygulamaları üzerinden yol tarifi açan fonksiyon
  Future<void> _yolTarifiBaslat(double lat, double lon) async {
    // Statik url yerine tıklanan büfenin gerçek enlem boylamını dinamik gömüyoruz
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lon";
    final Uri url = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harita uygulaması başlatılamadı.')),
        );
      }
    }
  }

  /// Haritadaki iğneye (Marker) tıklanınca detay kartı açan alt pencere
  void _bufeBilgisiGoster(BuildContext context, HalkEkmekBufe bufe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_rounded, color: Colors.orange, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bufe.kod, // JSON'daki "kod" alanı başlık yapıldı (Örn: 100. YIL-1)
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  bufe.adres, // JSON'daki çözümlenmiş net Türkçe adres bilgisi
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.directions),
                  label: const Text('Yol Tarifi Al', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(context);
                    _yolTarifiBaslat(bufe.lat, bufe.lon);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Halk Ekmek Noktaları',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _haritaMerkezi,
              initialZoom: 13.0,
              onMapReady: () {
                _haritaHazir = true;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.belediye.smartcity',
              ),
              MarkerLayer(
                // Veritabanındaki tüm büfeleri döngüyle haritaya yerleştiriyoruz
                markers: _halkEkmekBufeleri.map((bufe) {
                  return Marker(
                    point: LatLng(bufe.lat, bufe.lon),
                    width: 45,
                    height: 45,
                    child: GestureDetector(
                      onTap: () => _bufeBilgisiGoster(context, bufe),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.location_on, color: Colors.orange, size: 40),
                          Positioned(
                            top: 6,
                            child: Icon(Icons.bakery_dining_rounded, color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          // Arka planda veriler yüklenirken haritanın üzerinde dönen hafif karartmalı loading ekranı
          if (_yukleniyor)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}