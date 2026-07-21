import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartcity/models/sehir_rehberim/restoranlar_model.dart';
import 'package:smartcity/models/sehir_rehberim/konaklama_model.dart';
import 'package:smartcity/apiler/sehir_rehberim_apiler/restoranlar_api.dart' as restoranlar_api;
import 'package:smartcity/apiler/sehir_rehberim_apiler/konaklama_api.dart' as konaklama_api;

class RestoranlarVeKonaklama extends StatefulWidget {
  const RestoranlarVeKonaklama({super.key});

  @override
  State<RestoranlarVeKonaklama> createState() => _RestoranlarVeKonaklamaState();
}

class _RestoranlarVeKonaklamaState extends State<RestoranlarVeKonaklama> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final restoranlar_api.RestoranlarApi _restoranlarApi = restoranlar_api.RestoranlarApi();
  final konaklama_api.KonaklamaApi _konaklamaApi = konaklama_api.KonaklamaApi();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Restoranlar ve Konaklama',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black45,
          indicatorColor: Colors.black,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: "Restoranlar"),
            Tab(text: "Konaklama"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HaritaSekmesi<RestoranlarModel>(
            veriGetirmeFonksiyonu: _restoranlarApi.fetchAllPlaces, 
            ikonData: Icons.restaurant,
            ikonRengi: Colors.orange.shade700,
            getName: (model) => model.name,
            getLat: (model) => model.latitude,
            getLon: (model) => model.longitude,
          ),
          
          HaritaSekmesi<KonaklamaModel>(
            veriGetirmeFonksiyonu: _konaklamaApi.fetchAllPlaces, 
            ikonData: Icons.hotel,
            ikonRengi: Colors.blue.shade700,
            getName: (model) => model.name,
            getLat: (model) => model.latitude,
            getLon: (model) => model.longitude,
          ),
        ],
      ),
    );
  }
}
class HaritaSekmesi<T> extends StatefulWidget {
  final Future<List<T>> Function() veriGetirmeFonksiyonu;
  final IconData ikonData;
  final Color ikonRengi;
  
  final String Function(T item) getName;
  final double Function(T item) getLat;
  final double Function(T item) getLon;

  const HaritaSekmesi({
    super.key,
    required this.veriGetirmeFonksiyonu,
    required this.ikonData,
    required this.ikonRengi,
    required this.getName,
    required this.getLat,
    required this.getLon,
  });

  @override
  State<HaritaSekmesi<T>> createState() => _HaritaSekmesiState<T>();
}

class _HaritaSekmesiState<T> extends State<HaritaSekmesi<T>> {
  final MapController _mapController = MapController();
  late PageController _pageController;
  
  List<T> _veriListesi = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _seciliIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _verileriYukle();

    _pageController.addListener(() {
      if (_pageController.page == null) return;
      int next = _pageController.page!.round();
      if (_veriListesi.isNotEmpty && _seciliIndex != next && next < _veriListesi.length) {
        setState(() {
          _seciliIndex = next;
        });
        final mekan = _veriListesi[next];
        _mapController.move(LatLng(widget.getLat(mekan), widget.getLon(mekan)), 14.0);
      }
    });
  }

  Future<void> _verileriYukle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final veriler = await widget.veriGetirmeFonksiyonu();
      if (mounted) {
        setState(() {
          _veriListesi = veriler;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("API Çekme hatası: $e");
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Veriler yüklenirken bir hata oluştu:\n$_errorMessage",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_veriListesi.isEmpty) {
      return const Center(
        child: Text(
          "Bu kategoride kayıt bulunamadı.",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(widget.getLat(_veriListesi.first), widget.getLon(_veriListesi.first)),
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.belediye.akillisehir',
            ),
            MarkerLayer(
              markers: _veriListesi.asMap().entries.map((entry) {
                int idx = entry.key;
                T mekan = entry.value;
                final isSelected = _seciliIndex == idx;
                
                final lat = widget.getLat(mekan);
                final lon = widget.getLon(mekan);

                return Marker(
                  point: LatLng(lat, lon),
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      _mapController.move(LatLng(lat, lon), 14.5);
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
                        color: isSelected ? Colors.red.shade700 : Colors.black87,
                        size: isSelected ? 44 : 36,
                      ),
                    ),
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
              controller: _pageController,
              itemCount: _veriListesi.length,
              itemBuilder: (context, index) {
                final mekan = _veriListesi[index];
                
                final ad = widget.getName(mekan);
                final lat = widget.getLat(mekan);
                final lon = widget.getLon(mekan);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12), 
                        blurRadius: 15,
                        offset: const Offset(0, 5),
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
                            backgroundColor: widget.ikonRengi.withValues(alpha:0.1),
                            radius: 18,
                            child: Icon(widget.ikonData, color: widget.ikonRengi, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ad, 
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.black87
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => _yolTarifiBaslat(lat, lon), 
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
              },
            ),
          ),
        ),
      ],
    );
  }
}