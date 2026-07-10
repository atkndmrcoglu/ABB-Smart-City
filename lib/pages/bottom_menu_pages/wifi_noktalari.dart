import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WifiNoktalari extends StatelessWidget {
  const WifiNoktalari({super.key});

  @override
  Widget build(BuildContext context) {
    final LatLng adanaMerkez = const LatLng(36.9931, 35.3256);

    final List<Map<String, dynamic>> benimYerlerim = [
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 37.061600, 'lon': 35.299593},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 37.061767, 'lon': 35.301398},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 37.060967, 'lon': 35.300276},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 37.049952, 'lon': 35.284654},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 37.050176, 'lon': 35.284281},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 37.050265, 'lon': 35.285175},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 37.042688, 'lon': 35.290127},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 37.042942, 'lon': 35.290822},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 37.042435, 'lon': 35.290651},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 37.042038, 'lon': 35.290490},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 37.042234, 'lon': 35.291260},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.997227, 'lon': 35.322143},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.997421, 'lon': 35.323154},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.996685, 'lon': 35.323273},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.996754, 'lon': 35.323959},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.993700, 'lon': 35.325820},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.993532, 'lon': 35.325882},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.990720, 'lon': 35.326407},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.990833, 'lon': 35.326590},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.983734, 'lon': 35.333822},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.984667, 'lon': 35.333750},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.986905, 'lon': 35.333362},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.988640, 'lon': 35.332906},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.994251, 'lon': 35.334067},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.995208, 'lon': 35.334214},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.997217, 'lon': 35.334598},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.999241, 'lon': 35.334900},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 37.000417, 'lon': 35.334927},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.991057, 'lon': 35.337684},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.991004, 'lon': 35.337868},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.992254, 'lon': 35.338349},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.769267, 'lon': 35.791452},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.769646, 'lon': 35.791678},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.770457, 'lon': 35.791768},
      {'isim': 'Ücretsiz wifi erişim noktası', 'lat': 36.772286, 'lon': 35.792964},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Wifi Noktaları', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: adanaMerkez, initialZoom: 12.0),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.belediye.akillisehir',
          ),
         MarkerLayer(
  markers: benimYerlerim.map((yer) {
    return Marker(
      point: LatLng(yer['lat'], yer['lon']),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _kuleBilgisiGoster(context, yer['isim']),
        child: Container(
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi, color: Colors.blue, size: 15),
              Icon(Icons.online_prediction, color: Color(0xFF1E293B), size: 25),
            ],
          ),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.wifi_tethering_rounded, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Text(kuleAdi, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Adana Büyükşehir Belediyesi ücretsiz Wi-Fi noktası.'),
            ],
          ),
        );
      },
    );
  }
}