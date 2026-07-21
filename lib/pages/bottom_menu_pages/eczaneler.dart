// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartcity/models/eczane_model.dart';
import 'package:smartcity/apiler/eczane_api_service.dart';

class Eczaneler extends StatefulWidget {
  const Eczaneler({super.key});

  @override
  State<Eczaneler> createState() => _EczanelerState();
}

class _EczanelerState extends State<Eczaneler> {
  final MapController _mapController = MapController();
  final PageController _pageController = PageController(viewportFraction: 0.88);
  final EczaneApiService _apiService = EczaneApiService();
  
  final LatLng adanaMerkez = const LatLng(36.9931, 35.3256);
  
  List<Eczane> _eczaneler = [];
  bool _yukleniyor = true;
  String _seciliIlce = "Seyhan"; 

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    setState(() => _yukleniyor = true);
    final gelenVeri = await _apiService.nobetciEczaneleriGetir(_seciliIlce);
    setState(() {
      _eczaneler = gelenVeri;
      _yukleniyor = false;
    });

    if (_eczaneler.isNotEmpty) {
      _haritayiOdakla(_eczaneler[0].lat, _eczaneler[0].lon);
    }
  }

  void _haritayiOdakla(double lat, double lon) {
    _mapController.move(LatLng(lat, lon), 14.0);
  }

  Future<void> _telefonuAra(String tel) async {
    final Uri url = Uri.parse('tel:$tel');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _yolTarifiBaslat(double lat, double lon) async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lon";
    final Uri url = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harita uygulaması başlatılamadı.')),
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
        title: Text('$_seciliIlce Nöbetçi Eczaneleri', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // İlçe değiştirmek için hızlı bir menü butonu
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onSelected: (String yeniIlce) {
              _seciliIlce = yeniIlce;
              _verileriYukle();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'Seyhan', child: Text('Seyhan')),
              const PopupMenuItem<String>(value: 'Çukurova', child: Text('Çukurova')),
              const PopupMenuItem<String>(value: 'Yüreğir', child: Text('Yüreğir')),
              const PopupMenuItem<String>(value: 'Sarıçam', child: Text('Sarıçam')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // HARİTA KATMANI
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: adanaMerkez, initialZoom: 11),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.belediye.akillisehir',
              ),
              MarkerLayer(
                markers: _eczaneler.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Eczane eczane = entry.value;
                  return Marker(
                    point: LatLng(eczane.lat, eczane.lon),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        _haritayiOdakla(eczane.lat, eczane.lon);
                        _pageController.animateToPage(idx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                      child: const Icon(Icons.local_pharmacy, color: Colors.green, size: 40), // Eczane Logosu (Yeşil)
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // YÜKLENİYOR İNDİKATÖRÜ
          if (_yukleniyor)
            const Center(child: CircularProgressIndicator(color: Colors.green)),

          // ALT KARTLAR (PAGE VIEW)
          if (!_yukleniyor && _eczaneler.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 250,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _eczaneler.length,
                  onPageChanged: (index) {
                    final eczane = _eczaneler[index];
                    _haritayiOdakla(eczane.lat, eczane.lon);
                  },
                  itemBuilder: (context, index) {
                    return _buildEczaneKarti(_eczaneler[index]);
                  },
                ),
              ),
            ),
            
          if (!_yukleniyor && _eczaneler.isEmpty)
            const Center(child: Text("Bu ilçede aktif nöbetçi eczane kaydı bulunamadı.")),
        ],
      ),
    );
  }

  Widget _buildEczaneKarti(Eczane eczane) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.12), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade50,
                radius: 18,
                child: const Icon(Icons.local_pharmacy, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(eczane.isim, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("${eczane.ilce}, Adana", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              // Nöbetçi Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(8)),
                child: const Text("NÖBETÇİ", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const Divider(height: 16, thickness: 0.5),
          Text(eczane.adres, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _telefonuAra(eczane.telefon),
                  icon: const Icon(Icons.phone, size: 18, color: Colors.green),
                  label: const Text("Ara", style: TextStyle(color: Colors.green)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _yolTarifiBaslat(eczane.lat, eczane.lon),
                  icon: const Icon(Icons.navigation_outlined, size: 18, color: Colors.white),
                  label: const Text("Yol Tarifi", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}