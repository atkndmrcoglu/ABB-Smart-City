//ignore
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartcity/models/sehir_rehberim/kultur_sanat_model.dart';
import 'package:smartcity/apiler/sehir_rehberim_apiler/kultur_sanat_api.dart';

class KulturSanat extends StatefulWidget {
  const KulturSanat({super.key});

  @override
  State<KulturSanat> createState() => _KulturSanatState();
}

class _KulturSanatState extends State<KulturSanat> {
  final MapController _mapController = MapController();
  final KulturSanatApi _apiService = KulturSanatApi();
  final LatLng adanaMerkez = const LatLng(36.9931, 35.3256);
  
  late Future<List<KulturSanatModel>> _futureYerler;

  @override
  void initState() {
    super.initState();
    _futureYerler = _apiService.fetchKulturSanatYerleri();
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
          'Kültür Sanat', 
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<KulturSanatModel>>(
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
                        _futureYerler = _apiService.fetchKulturSanatYerleri();
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
                  height: 270,
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

  Widget _buildGenelBilgiKarti(KulturSanatModel data) {
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
                child: const Icon(Icons.account_balance, color: Colors.blue, size: 20),
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
                    Text(
                      data.altBaslik,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16, thickness: 0.5),
          Text(
            data.aciklama,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data.detaylar.length,
              itemBuilder: (context, dIndex) {
                final detay = data.detaylar[dIndex];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          detay.rozetMetni, 
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(detay.anahtarIkon, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(detay.anahtarVeri, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              },
            ),
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
                backgroundColor: Colors.blue,
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