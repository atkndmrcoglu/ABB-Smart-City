import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartcity/models/sehir_rehberim/devlet_daireleri_model.dart';
import 'package:smartcity/apiler/sehir_rehberim_apiler/devlet_daireleri_api.dart';

class DevletDaireleri extends StatefulWidget {
  const DevletDaireleri({super.key});

  @override
  State<DevletDaireleri> createState() => _DevletDaireleriState();
}

class _DevletDaireleriState extends State<DevletDaireleri> {
  final MapController _mapController = MapController();
  final DevletDaireleriApi _apiService = DevletDaireleriApi();
  final LatLng adanaMerkez = const LatLng(36.9931, 35.3256);
  
  late Future<List<DevletDaireleriModel>> _futureYerler;

  @override
  void initState() {
    super.initState();
    _futureYerler = _apiService.fetchAllPlaces();
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Devlet Daireleri',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DevletDaireleriModel>>(
        future: _futureYerler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Hata: ${snapshot.error}', textAlign: TextAlign.center),
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

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Gösterilecek veri bulunamadı."));
          }

          final listem = snapshot.data!;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(listem.first.latitude, listem.first.longitude), 
                  initialZoom: 13.0
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.belediye.akillisehir',
                  ),
                  MarkerLayer(
                    markers: listem.map((yer) {
                      return Marker(
                        point: LatLng(yer.latitude, yer.longitude),
                        width: 45,
                        height: 45,
                        child: GestureDetector(
                          onTap: () => _haritayiOdakla(yer.latitude, yer.longitude),
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
                  height: 140,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.88),
                    itemCount: listem.length,
                    onPageChanged: (index) {
                      final yer = listem[index];
                      _haritayiOdakla(yer.latitude, yer.longitude);
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

  Widget _buildGenelBilgiKarti(DevletDaireleriModel data) {
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
                child: Text(
                  data.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _yolTarifiBaslat(data.latitude, data.longitude),
              icon: const Icon(Icons.navigation_outlined, size: 18, color: Colors.white),
              label: const Text(
                "Yol Tarifi Al", 
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
              ),
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