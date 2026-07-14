// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '/models/wifi_noktasi_model.dart';
import '/apiler/wifi_noktalari_api.dart';

class WifiNoktalari extends StatefulWidget {
  const WifiNoktalari({super.key});

  @override
  State<WifiNoktalari> createState() => _WifiNoktalariState();
}

class _WifiNoktalariState extends State<WifiNoktalari> {
  final WifiNoktasiService _wifiService = WifiNoktasiService();
  final LatLng _adanaMerkez = const LatLng(36.9931, 35.3256);
  
  List<WifiNoktasi> _wifiListesi = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _veriGetir();
  }

  Future<void> _veriGetir() async {
    try {
      final veriler = await _wifiService.getTumWifiNoktalari();
      setState(() {
        _wifiListesi = veriler;
        _yukleniyor = false;
      });
    } catch (e) {
      setState(() {
        _yukleniyor = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('WiFi noktaları yüklenirken hata oluştu: $e')),
      );
    }
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
          'WiFi Noktaları', 
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator()) // Veri çekilirken dönecek loader
          : FlutterMap(
              options: MapOptions(
                initialCenter: _adanaMerkez, 
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.belediye.akillisehir',
                ),
                MarkerLayer(
                  markers: _wifiListesi.map((wifi) {
                    return Marker(
                      point: LatLng(wifi.lat, wifi.lon),
                      width: 45,
                      height: 45,
                      child: GestureDetector(
                        onTap: () => _kuleBilgisiGoster(context, wifi.isim),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi, color: Colors.blue, size: 16),
                            Icon(Icons.online_prediction, color: Color(0xFF1E293B), size: 26),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  void _kuleBilgisiGoster(BuildContext context, String kuleAdi) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.wifi_tethering_rounded, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      kuleAdi, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Adana Büyükşehir Belediyesi ücretsiz Wi-Fi noktası.'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}