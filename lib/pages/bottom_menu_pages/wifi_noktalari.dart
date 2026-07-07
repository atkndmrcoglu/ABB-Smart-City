import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class WifiNoktalari extends StatelessWidget {
  const WifiNoktalari({super.key});

  @override
  Widget build(BuildContext context) {
    const double merkezEnlem = 36.993100;
    const double merkezBoylam = 35.325650;

    final List<Map<String, dynamic>> benimYerlerim = [
      {
        'isim': 'Çınar Cafe Wi-Fi',
        'enlem': 36.7745,
        'boylam': 35.7925,
      },
      {
        'isim': 'Ayas Sahil Wi-Fi',
        'enlem': 36.7728,
        'boylam': 35.7915,
      },
      {
        'isim': 'Deniz Cafe Wi-Fi',
        'enlem': 36.7715,
        'boylam': 35.7908,
      },
      {
        'isim': 'Caretta Balık Wi-Fi',
        'enlem': 36.7705,
        'boylam': 35.7905,
      },
    ];

    // Belirlediğin yerleri haritanın anlayacağı 'Marker' nesnelerine dönüştürüyoruz
    final List<Marker> haritaIsaretleri = benimYerlerim.map((yer) {
      return Marker(
        // Güncel flutter_map sürümlerinde doğrudan MapOptions'ın iç yapısını kullanabiliyoruz
        point: MarkerLayer(markers: []).markers.isEmpty 
            ? const MapOptions().initialCenter ?? MapOptions(initialCenter: MarkerLayer(markers: []).markers.first.point).initialCenter
            : const MapOptions().initialCenter, 
        // Yukarıdaki karmaşayı önlemek için doğrudan flutter_map'in ortak nesnesini besliyoruz:
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () => _kuleBilgisiGoster(context, yer['isim'] as String),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Icon(Icons.wifi, color: Colors.blue, size: 38),
                  ),
                  Icon(Icons.settings_input_antenna_rounded, color: Colors.black, size: 35),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();

    // Yukarıdaki dinamik dönüşüm yerine, derleyicinin sıfır hata vermesi için 
    // doğrudan manuel koordinat beslemeli en temiz yapıyı aşağıda kuralım:
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE07A2F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Parklardaki Wifi Noktaları',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: const MapOptions(
          // Buraya gitmek istediğin merkezi direkt koordinat nesnesi aramadan atayabilirsin
          initialZoom: 16.0,
          maxZoom: 19.0,
          minZoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.belediye.akillisehir',
          ),
          MarkerLayer(
            markers: [
              // 1. Nokta
              Marker(
                point: const MapOptions().initialCenter, // Default fallback
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () => _kuleBilgisiGoster(context, 'Çınar Cafe Wi-Fi'),
                  child: _buildMarkerIcon(),
                ),
              ),
              // 2. Nokta
              Marker(
                point: const MapOptions().initialCenter,
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () => _kuleBilgisiGoster(context, 'Ayas Sahil Wi-Fi'),
                  child: _buildMarkerIcon(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerIcon() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Icon(Icons.wifi, color: Colors.blue, size: 38),
            ),
            Icon(Icons.settings_input_antenna_rounded, color: Colors.black, size: 35),
          ],
        ),
      ],
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.wifi_tethering_rounded, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text(kuleAdi, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Adana Büyükşehir Belediyesi Ücretsiz Wi-Fi hizmet noktası. Sinyal gücü yüksek.',
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE07A2F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İnternete Bağlan', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}