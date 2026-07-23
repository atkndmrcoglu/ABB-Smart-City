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
  final PageController _pageController = PageController(viewportFraction: 0.90);
  final EczanelerApi _apiService = EczanelerApi();

  final LatLng adanaMerkez = const LatLng(36.9931, 35.3256);

  List<EczanelerModel> _tumEczaneler = [];
  List<EczanelerModel> _gorunurEczaneler = [];
  
  bool _yukleniyor = true;
  bool _sadeceNobetciler = true; // Varsayılan olarak nöbetçi eczaneler açık gelir

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    setState(() => _yukleniyor = true);
    
    // API'den verileri çeker
    final gelenVeri = await _apiService.fetchAllPlaces();

    setState(() {
      _tumEczaneler = gelenVeri;
      _filtrele();
      _yukleniyor = false;
    });

    if (_gorunurEczaneler.isNotEmpty) {
      _haritayiOdakla(_gorunurEczaneler[0].lat, _gorunurEczaneler[0].lon);
    }
  }

  void _filtrele() {
    if (_sadeceNobetciler) {
      _gorunurEczaneler = _tumEczaneler.where((e) => e.is_on_duty == 1).toList();
    } else {
      _gorunurEczaneler = List.from(_tumEczaneler);
    }
  }

  void _modDegistir(bool sadeceNobetci) {
    if (_sadeceNobetciler == sadeceNobetci) return;

    setState(() {
      _sadeceNobetciler = sadeceNobetci;
      _filtrele();
    });

    if (_gorunurEczaneler.isNotEmpty) {
      _haritayiOdakla(_gorunurEczaneler[0].lat, _gorunurEczaneler[0].lon);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  void _haritayiOdakla(double lat, double lon) {
    _mapController.move(LatLng(lat, lon), 14.5);
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
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _sadeceNobetciler ? 'Nöbetçi Eczaneler' : 'Tüm Eczaneler',
          style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // HARİTA KATMANI
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: adanaMerkez, 
              initialZoom: 12
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.belediye.akillisehir',
              ),
              MarkerLayer(
                markers: _gorunurEczaneler.asMap().entries.map((entry) {
                  int idx = entry.key;
                  EczanelerModel eczane = entry.value;
                  bool nobetci = eczane.is_on_duty == 1;

                  return Marker(
                    point: LatLng(eczane.lat, eczane.lon),
                    width: 45,
                    height: 45,
                    child: GestureDetector(
                      onTap: () {
                        _haritayiOdakla(eczane.lat, eczane.lon);
                        _pageController.animateToPage(
                          idx, 
                          duration: const Duration(milliseconds: 300), 
                          curve: Curves.easeInOut
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: nobetci ? Colors.red.shade600 : Colors.green.shade600,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                          ],
                        ),
                        child: const Icon(
                          Icons.local_pharmacy, 
                          color: Colors.white, 
                          size: 26
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // YÜKLENİYOR İNDİKATÖRÜ
          if (_yukleniyor)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator(color: Colors.red)),
            ),

          // KAYIT BULUNAMADI UYARISI
          if (!_yukleniyor && _gorunurEczaneler.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Kayıtlı eczane bulunamadı.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),

          // ALT KISIM (KARTLAR VE BUTON BARI)
          if (!_yukleniyor)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // PAGEVIEW (ECZANE KARTLARI)
                  if (_gorunurEczaneler.isNotEmpty)
                    SizedBox(
                      height: 190,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _gorunurEczaneler.length,
                        onPageChanged: (index) {
                          final eczane = _gorunurEczaneler[index];
                          _haritayiOdakla(eczane.lat, eczane.lon);
                        },
                        itemBuilder: (context, index) {
                          return _buildEczaneKarti(_gorunurEczaneler[index]);
                        },
                      ),
                    ),
                  
                  const SizedBox(height: 10),

                  // EN ALTTAKİ YATAY MOD SEÇİM BUTONU
                  _buildAltFiltreBar(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ALT DİKEY 100PX FİLTRE BUTON BARI
  Widget _buildAltFiltreBar() {
    return Container(
      height: 90,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12), 
            blurRadius: 15, 
            offset: const Offset(0, -4)
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            // NÖBETÇİ ECZANELER BUTONU
            Expanded(
              child: GestureDetector(
                onTap: () => _modDegistir(true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: _sadeceNobetciler ? Colors.red.shade600 : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_filled, 
                        size: 20, 
                        color: _sadeceNobetciler ? Colors.white : Colors.grey.shade700
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Nöbetçi Eczaneler",
                        style: TextStyle(
                          color: _sadeceNobetciler ? Colors.white : Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // TÜM ECZANELER BUTONU
            Expanded(
              child: GestureDetector(
                onTap: () => _modDegistir(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: !_sadeceNobetciler ? Colors.blue.shade700 : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_pharmacy, 
                        size: 20, 
                        color: !_sadeceNobetciler ? Colors.white : Colors.grey.shade700
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Tüm Eczaneler",
                        style: TextStyle(
                          color: !_sadeceNobetciler ? Colors.white : Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TEKİL ECZANE KARTI
  Widget _buildEczaneKarti(EczanelerModel eczane) {
    bool isNobetci = eczane.is_on_duty == 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), 
            blurRadius: 8, 
            offset: const Offset(0, 3)
          ),
        ],
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isNobetci ? Colors.red.shade50 : Colors.green.shade50,
                radius: 18,
                child: Icon(
                  Icons.local_pharmacy, 
                  color: isNobetci ? Colors.red : Colors.green, 
                  size: 20
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  eczane.name, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              // Rozet
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNobetci ? Colors.red.shade600 : Colors.grey.shade400, 
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(
                  isNobetci ? "NÖBETÇİ" : "STANDART", 
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                ),
              )
            ],
          ),

          const SizedBox(height: 6),

          // Yol Tarifi ve Arama Butonları
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _yolTarifiBaslat(eczane.lat, eczane.lon),
                  icon: const Icon(Icons.navigation_outlined, size: 18, color: Colors.white),
                  label: const Text("Yol Tarifi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
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