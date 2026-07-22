import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartcity/models/sehir_rehberim/sinema_tiyatro_model.dart';
import 'package:smartcity/apiler/sehir_rehberim_apiler/sinema_tiyatro_api.dart';

class SinemaTiyatro extends StatefulWidget {
  const SinemaTiyatro({super.key});

  @override
  State<SinemaTiyatro> createState() => _SinemaTiyatroState();
}

class _SinemaTiyatroState extends State<SinemaTiyatro> {
  final MapController _mapController = MapController();
  final SinemaTiyatroApi _apiService = SinemaTiyatroApi();
  final LatLng adanaMerkez = const LatLng(36.9931, 35.3256);
  
  late Future<List<SinemaTiyatroModel>> _futureYerler;

  @override
  void initState() {
    super.initState();
    _futureYerler = _apiService.fetchAllPlaces();
  }

  void _haritayiOdakla(double lat, double lon) {
    _mapController.move(LatLng(lat, lon), 13.0);
  }

  Future<void> _yolTarifiBaslat(double lat, double lon) async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lon";
    final Uri url = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
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
        title: const Text(
          'Sinemalar ve Tiyatrolar', 
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<SinemaTiyatroModel>>(
        future: _futureYerler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Veriler yüklenirken bir hata oluştu.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureYerler = _apiService.fetchAllPlaces();
                      });
                    },
                    child: const Text('Tekrar Dene'),
                  )
                ],
              ),
            );
          }

          final listem = snapshot.data!;

          if (listem.isEmpty) {
            return const Center(child: Text("Gösterilecek veri bulunamadı."));
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: adanaMerkez, initialZoom: 9.5),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.belediye.akillisehir',
                  ),
                  MarkerLayer(
                    markers: listem.map((yer) {
                      return Marker(
                        point: LatLng(yer.lat, yer.lon),
                        width: 45,
                        height: 45,
                        child: GestureDetector(
                          onTap: () => _haritayiOdakla(yer.lat, yer.lon),
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 120,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.88),
                    itemCount: listem.length,
                    onPageChanged: (index) {
                      final yer = listem[index];
                      _haritayiOdakla(yer.lat, yer.lon);
                    },
                    itemBuilder: (context, index) {
                      final yer = listem[index];
                      return _buildGenelBilgiKarti(yer);
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

  Widget _buildGenelBilgiKarti(SinemaTiyatroModel data) {
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
                backgroundColor: Colors.blue.shade50,
                radius: 18,
                child: const Icon(Icons.account_balance, color: Colors.black, size: 20),
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
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _yolTarifiBaslat(data.lat, data.lon),
              icon: const Icon(Icons.navigation_outlined, size: 18, color: Colors.white),
              label: const Text("Yol Tarifi Al", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
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