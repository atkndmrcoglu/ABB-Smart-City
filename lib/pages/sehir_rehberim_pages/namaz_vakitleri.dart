import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartcity/apiler/sehir_rehberim_apiler/namaz_vakitleri_api.dart' as namaz_api;
import 'package:smartcity/apiler/sehir_rehberim_apiler/cami_api.dart';
import 'package:smartcity/models/sehir_rehberim/cami_model.dart';

class Namaz extends StatefulWidget {
  const Namaz({super.key});

  @override
  State<Namaz> createState() => _NamazState();
}

class _NamazState extends State<Namaz> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final namaz_api.NamazApi _namazService = namaz_api.NamazApi();
  final MapController _mapController = MapController();
  final LatLng adanaMerkez = const LatLng(36.9931, 35.3256);

  late Future<List<namaz_api.NamazVakti>> _namazVakitleriFuture;
  List<namaz_api.NamazVakti> _guncelVakitler = [];
  
  Timer? _countdownTimer;
  String _kalanSureYazisi = "Yükleniyor...";
  String _hedefVakitYazisi = "Ezanına";

  final CamiApi _camiService = CamiApi();
  late PageController _pageController;
  List<CamiModel> _camiListesi = [];
  bool _isCamilerLoading = true;
  int _seciliCamiIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController(viewportFraction: 0.88);
    _getNamazVakitleri();
    _camileriYukle();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_guncelVakitler.isNotEmpty) {
        _hesaplaKalanSure();
      }
    });

    _pageController.addListener(() {
      if (_pageController.page == null) return;
      int next = _pageController.page!.round();
      if (_camiListesi.isNotEmpty && _seciliCamiIndex != next && next < _camiListesi.length) {
        setState(() {
          _seciliCamiIndex = next;
        });
        final cami = _camiListesi[next];
        _mapController.move(LatLng(cami.lat, cami.lon), 14.0);
      }
    });
  }

  Future<void> _camileriYukle() async {
    setState(() => _isCamilerLoading = true);
    final veriler = await _camiService.getTumCamiler();
    setState(() {
      _camiListesi = veriler;
      _isCamilerLoading = false;
    });
  }

  void _getNamazVakitleri() {
    setState(() {
      _namazVakitleriFuture = _namazService.fetchNamazVakitleri('adana');
    });
    
    _namazVakitleriFuture.then((vakitler) {
      setState(() {
        _guncelVakitler = vakitler;
        _hesaplaKalanSure();
      });
    }).catchError((error) {
      debugPrint("API BAĞLANTI HATASI: $error");
    });
  }

  void _hesaplaKalanSure() {
    if (_guncelVakitler.isEmpty) return;

    final simdi = DateTime.now();
    DateTime? enYakinVakit;
    String enYakinVakitAdi = "";

    final Map<String, String> vakitMap = {
      'imsak': 'İmsak',
      'güneş': 'Güneş',
      'gunes': 'Güneş',
      'öğle': 'Öğle',
      'ogle': 'Öğle',
      'ikindi': 'İkindi',
      'akşam': 'Akşam',
      'aksam': 'Akşam',
      'yatsı': 'Yatsı',
      'yatsi': 'Yatsı',
    };

    for (var v in _guncelVakitler) {
      try {
        final vakitParcalari = v.saat.split(':');
        final vakitTime = DateTime(
          simdi.year,
          simdi.month,
          simdi.day,
          int.parse(vakitParcalari[0]),
          int.parse(vakitParcalari[1]),
        );

        if (vakitTime.isAfter(simdi)) {
          if (enYakinVakit == null || vakitTime.isBefore(enYakinVakit)) {
            enYakinVakit = vakitTime;
            final temizKey = v.vakit.toLowerCase().trim();
            enYakinVakitAdi = vakitMap[temizKey] ?? v.vakit;
          }
        }
      } catch (e) {
        debugPrint("Saat parse hatası: $e");
      }
    }

    if (enYakinVakit == null) {
      final ilkVakit = _guncelVakitler.first;
      final vakitParcalari = ilkVakit.saat.split(':');
      enYakinVakit = DateTime(
        simdi.year,
        simdi.month,
        simdi.day + 1,
        int.parse(vakitParcalari[0]),
        int.parse(vakitParcalari[1]),
      );
      final temizKey = ilkVakit.vakit.toLowerCase().trim();
      enYakinVakitAdi = vakitMap[temizKey] ?? ilkVakit.vakit;
    }

    final fark = enYakinVakit.difference(simdi);
    final saat = fark.inHours;
    final dakika = fark.inMinutes.remainder(60);
    final saniye = fark.inSeconds.remainder(60);

    setState(() {
      _hedefVakitYazisi = "$enYakinVakitAdi Ezanına";
      _kalanSureYazisi = "$saat Saat $dakika Dakika $saniye Saniye Kaldı";
    });
  }

  String _vakitSaatiniAl(List<namaz_api.NamazVakti> liste, String vakitAdi) {
    try {
      return liste.firstWhere(
        (v) => v.vakit.toLowerCase().trim() == vakitAdi.toLowerCase(),
        orElse: () => namaz_api.NamazVakti(saat: '--:--', vakit: ''),
      ).saat;
    } catch (_) {
      return '--:--';
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
    _countdownTimer?.cancel();
    _tabController.dispose();
    _pageController.dispose();
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
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: const Text(
          'Namaz Vakitleri/Camiler', 
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black45,
          indicatorColor: Colors.black,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: "Namaz Vakitleri"),
            Tab(text: "Yakın Camiler"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNamazVakitleriSekmesi(),
          _buildYakinCamilerSekmesi(),
        ],
      ),
    );
  }

  Widget _buildNamazVakitleriSekmesi() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [       
          const SizedBox(height: 12),
          Text(
            _hedefVakitYazisi, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)
          ),
          const SizedBox(height: 6),
          Text(
            _kalanSureYazisi, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)
          ),
          const SizedBox(height: 28),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: _buildVakitHeaderRow(),
                ),
                _buildVakitleriListele(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVakitHeaderRow() {
    const TextStyle headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black87);
    return const Row(
      children: [
        Expanded(flex: 3, child: Text('Tarih', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black))),
        Expanded(child: Text('İmsak', textAlign: TextAlign.center, style: headerStyle)),
        Expanded(child: Text('Güneş', textAlign: TextAlign.center, style: headerStyle)),
        Expanded(child: Text('Öğle', textAlign: TextAlign.center, style: headerStyle)),
        Expanded(child: Text('İkindi', textAlign: TextAlign.center, style: headerStyle)),
        Expanded(child: Text('Akşam', textAlign: TextAlign.center, style: headerStyle)),
        Expanded(child: Text('Yatsı', textAlign: TextAlign.center, style: headerStyle)),
      ],
    );
  }

  Widget _buildVakitleriListele() {
    return FutureBuilder<List<namaz_api.NamazVakti>>(
      future: _namazVakitleriFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        } else if (snapshot.hasError) {
          return Padding(
            
            padding: const EdgeInsets.all(24.0),
            child: Center(child: Text('Hata: ${snapshot.error.toString().replaceAll("Exception:", "")}', style: const TextStyle(color: Colors.black))),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: Text('Namaz vakti verileri alınamadı.', style: TextStyle(color: Colors.black54))),
          );
        }

        final vakitler = snapshot.data!;
        
        return Column(
          children: List.generate(7, (index) {
            final gun = DateTime.now().add(Duration(days: index));
            final formatliTarih = DateFormat('dd-MM-yyyy').format(gun);
            final Color solSutunRengi = Colors.black;
            final Color sagSutunRengi = index % 2 == 0 ? Colors.grey.shade50 : Colors.white;

            return Container(
              margin: const EdgeInsets.only(bottom: 1),
              child: ClipRRect(
                borderRadius: index == 6 
                    ? const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
                    : BorderRadius.zero,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2, 
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: solSutunRengi,
                        child: Text(
                          formatliTarih, 
                          textAlign: TextAlign.center, 
                          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: sagSutunRengi,
                        child: Row(
                          children: [
                            Expanded(child: Text(_vakitSaatiniAl(vakitler, 'imsak'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold))),
                            Expanded(child: Text(_vakitSaatiniAl(vakitler, 'güneş'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold))),
                            Expanded(child: Text(_vakitSaatiniAl(vakitler, 'öğle'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold))),
                            Expanded(child: Text(_vakitSaatiniAl(vakitler, 'ikindi'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold))),
                            Expanded(child: Text(_vakitSaatiniAl(vakitler, 'akşam'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold))),
                            Expanded(child: Text(_vakitSaatiniAl(vakitler, 'yatsı'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildYakinCamilerSekmesi() {
    if (_isCamilerLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (_camiListesi.isEmpty) {
      return const Center(
        child: Text(
          "Yakınlarda cami bulunamadı.",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(_camiListesi.first.lat, _camiListesi.first.lon),
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.belediye.akillisehir',
            ),
            MarkerLayer(
              markers: _camiListesi.asMap().entries.map((entry) {
                int idx = entry.key;
                CamiModel cami = entry.value;
                final isSelected = _seciliCamiIndex == idx;

                return Marker(
                  point: LatLng(cami.lat, cami.lon),
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      _mapController.move(LatLng(cami.lat, cami.lon), 14.5);
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
                        color: isSelected ? Colors.red.shade700 : Colors.black,
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
              itemCount: _camiListesi.length,
              itemBuilder: (context, index) {
                final cami = _camiListesi[index];

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
                            backgroundColor: Colors.grey.shade100,
                            radius: 18,
                            child: const Icon(Icons.mosque, color: Colors.black, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cami.ad,
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
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => _yolTarifiBaslat(cami.lat, cami.lon),
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