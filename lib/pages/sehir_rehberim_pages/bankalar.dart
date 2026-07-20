// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartcity/models/sehir_rehberim/bankalar_model.dart';
import 'package:smartcity/apiler/sehir_rehberim_apiler/bankalar_api.dart';

class Bankalar extends StatefulWidget {
  const Bankalar({super.key});

  @override
  State<Bankalar> createState() => _BankalarState();
}

class _BankalarState extends State<Bankalar> {
  final MapController _mapController = MapController();
  final BankalarService _apiService = BankalarService();
  final LatLng adanaMerkez = const LatLng(36.9931, 35.3256);
  late PageController _pageController;
  
  late Future<List<BankalarModel>> _futureYerler;
  int _seciliBankaIndex = 0;
  List<BankalarModel> _bankalistesi = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _futureYerler = _apiService.getTumBankalar(); 

    _pageController.addListener(() {
      if (_pageController.page == null) return;
      int next = _pageController.page!.round();
      if (_bankalistesi.isNotEmpty && _seciliBankaIndex != next && next < _bankalistesi.length) {
        setState(() {
          _seciliBankaIndex = next;
        });
        final banka = _bankalistesi[next];
        _mapController.move(LatLng(banka.lat, banka.lon), 14.5);
      }
    });
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harita uygulaması başlatılamadı.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Bankalar & ATM\'ler', 
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<BankalarModel>>(
        future: _futureYerler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Bankalar yüklenirken bir hata oluştu.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureYerler = _apiService.getTumBankalar();
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: const Text('Tekrar Dene', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          _bankalistesi = snapshot.data!;

          if (_bankalistesi.isEmpty) {
            return const Center(child: Text("Gösterilecek banka veya ATM bulunamadı."));
          }

          return Stack(
            children: [
              // 1. HARİTA KATMANI
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(_bankalistesi.first.lat, _bankalistesi.first.lon), 
                  initialZoom: 13.0
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.belediye.akillisehir',
                  ),
                  MarkerLayer(
                    markers: _bankalistesi.asMap().entries.map((entry) {
                      int idx = entry.key;
                      final banka = entry.value;
                      final isSelected = _seciliBankaIndex == idx;

                      return Marker(
                        point: LatLng(banka.lat, banka.lon),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () {
                            _haritayiOdakla(banka.lat, banka.lon);
                            _pageController.animateToPage(
                              idx,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.location_on, 
                              color: isSelected ? Colors.red.shade700 : Colors.teal.shade700, 
                              size: isSelected ? 46 : 38
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // 2. ALTTAKİ BİLGİ KARTLARI (PAGEVIEW)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 150, // Detay rozetleri olmadığı için yüksekliği ideal seviyeye çektik
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _bankalistesi.length,
                    onPageChanged: (index) {
                      setState(() {
                        _seciliBankaIndex = index;
                      });
                      final banka = _bankalistesi[index];
                      _haritayiOdakla(banka.lat, banka.lon);
                    },
                    itemBuilder: (context, index) {
                      final banka = _bankalistesi[index];
                      return _buildGenelBilgiKarti(banka);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGenelBilgiKarti(BankalarModel data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.teal.shade50,
                radius: 18,
                child: const Icon(Icons.account_balance_outlined, color: Colors.teal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.isim,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Banka / ATM Hizmet Noktası",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _yolTarifiBaslat(data.lat, data.lon),
              icon: const Icon(Icons.navigation_outlined, size: 18, color: Colors.white),
              label: const Text("Yol Tarifi Al", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade800,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          )
        ],
      ),
    );
  }
}