import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../../models/metro_model.dart'; 
import '../../apiler/metro_api.dart';

class Metro extends StatefulWidget {
  const Metro({super.key});

  @override
  State<Metro> createState() => _MetroState();
}

class _MetroState extends State<Metro> {
  final MapController _mapController = MapController();
  final MetroApi _apiService = MetroApi();

  List<MetroStation> _tumIstasyonlar = []; 
  List<MetroStation> _gorunurIstasyonlar = []; 
  List<MetroSchedule> _secilenHatSeferleri = []; 
  
  bool _yukleniyor = false;
  String _hataMesaji = '';
  bool _solPanelAcik = false;

  MetroStation? _secilenIstasyon;
  String _secilenIstasyonAdi = "Tüm İstasyonlar";
  final TextEditingController _aramaController = TextEditingController();
  List<MetroStation> _filtreliIstasyonlar = [];

  Timer? _moveEndTimer;
  LatLng? _sonMerkez;
  double? _sonZoom;

  @override
  void initState() {
    super.initState();
    _istasyonlariYukle();
    _aramaController.addListener(() {
      _istasyonlariFiltrele(_aramaController.text);
    });
  }

  @override
  void dispose() {
    _aramaController.dispose();
    _moveEndTimer?.cancel();
    super.dispose();
  }

  Future<void> _istasyonlariYukle() async {
    setState(() {
      _yukleniyor = true;
      _hataMesaji = '';
    });

    try {
      final istasyonlar = await _apiService.fetchStations();
      setState(() {
        _tumIstasyonlar = istasyonlar;
        _filtreliIstasyonlar = istasyonlar;
        _gorunurIstasyonlar = istasyonlar;
        _yukleniyor = false;
      });

      if (istasyonlar.isNotEmpty) {
        _mapController.move(istasyonlar.first.koordinat, 13.0);
      }
    } catch (e) {
      setState(() {
        _yukleniyor = false;
        _hataMesaji = 'İstasyonlar yüklenirken hata oluştu: $e';
      });
    }
  }

  void _onMapMoveEnd(MapCamera camera) {
    _moveEndTimer?.cancel();
    _moveEndTimer = Timer(const Duration(milliseconds: 500), () {
      if (_sonMerkez != camera.center || _sonZoom != camera.zoom) {
        _sonMerkez = camera.center;
        _sonZoom = camera.zoom;
        _gorunurDuraklariGuncelle(camera);
      }
    });
  }

  void _gorunurDuraklariGuncelle(MapCamera camera) {
    if (_secilenIstasyon == null && _tumIstasyonlar.isNotEmpty) {
      final center = camera.center;
      final zoom = camera.zoom;
      
      final double degreeRange = 0.06 / (zoom / 12);
      
      final double minLat = center.latitude - degreeRange;
      final double maxLat = center.latitude + degreeRange;
      final double minLng = center.longitude - degreeRange;
      final double maxLng = center.longitude + degreeRange;
      
      final filtrelenler = _tumIstasyonlar.where((ist) {
        return ist.latitude >= minLat && ist.latitude <= maxLat &&
               ist.longitude >= minLng && ist.longitude <= maxLng;
      }).toList();
      
      setState(() {
        _gorunurIstasyonlar = filtrelenler.isNotEmpty ? filtrelenler : _tumIstasyonlar;
      });
    }
  }

  void _istasyonSec(MetroStation istasyon) async {
    setState(() {
      _secilenIstasyon = istasyon;
      _secilenIstasyonAdi = istasyon.stationName; 
      _solPanelAcik = false;
      _yukleniyor = true;
    });

    try {
      final seferler = await _apiService.fetchSchedules(istasyon.id);
      setState(() {
        _secilenHatSeferleri = seferler;
        _gorunurIstasyonlar = [istasyon]; 
        _yukleniyor = false;
      });
      
      _mapController.move(istasyon.koordinat, 15.0);
      _showSeferDetayBottomSheet(istasyon);
    } catch (e) {
      setState(() {
        _yukleniyor = false;
        _hataMesaji = 'Sefer saatleri çekilemedi: $e';
      });
    }
  }

  void _tumIstasyonlariGoster() {
    setState(() {
      _secilenIstasyon = null;
      _gorunurIstasyonlar = _tumIstasyonlar;
      _secilenIstasyonAdi = "Tüm İstasyonlar (${_tumIstasyonlar.length})";
      _solPanelAcik = false;
    });
    if (_tumIstasyonlar.isNotEmpty) {
      _mapController.move(_tumIstasyonlar.first.koordinat, 13.0);
    }
  }

  void _istasyonlariFiltrele(String sorgu) {
    setState(() {
      if (sorgu.isEmpty) {
        _filtreliIstasyonlar = _tumIstasyonlar;
      } else {
        _filtreliIstasyonlar = _tumIstasyonlar
            .where((ist) => ist.stationName.toLowerCase().contains(sorgu.toLowerCase())) 
            .toList();
      }
    });
  }

  String _yonIsminiFormatla(String yon) {
    final temizYon = yon.trim().toUpperCase();
    if (temizYon == 'H' || temizYon.contains('HASTANE')) {
      return "Hastane Yönü";
    } else if (temizYon == 'A' || temizYon.contains('AKINCILAR')) {
      return "Akıncılar Yönü";
    }
    return "$yon Yönü";
  }

  @override
  Widget build(BuildContext context) {
    List<LatLng> hatRotasi = [];
    if (_tumIstasyonlar.isNotEmpty) {
      final siraliIstasyonlar = List<MetroStation>.from(_tumIstasyonlar)
        ..sort((a, b) => a.stationOrder.compareTo(b.stationOrder));
      hatRotasi = siraliIstasyonlar.map((ist) => ist.koordinat).toList();
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. HARİTA KATMANI
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(37.0, 35.3), 
              initialZoom: 13.0,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) _onMapMoveEnd(camera);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.belediye.akillisehir',
              ),
              
              if (hatRotasi.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: hatRotasi,
                      strokeWidth: 5.0,
                      color: Colors.blue.shade600.withOpacity(0.75),
                      borderColor: Colors.blue.shade900,
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: _gorunurIstasyonlar.map((istasyon) {
                  final bool isSelected = _secilenIstasyon?.id == istasyon.id;
                  return Marker(
                    key: ValueKey(istasyon.id),
                    point: istasyon.koordinat,
                    width: isSelected ? 52 : 40,
                    height: isSelected ? 52 : 40,
                    child: GestureDetector(
                      onTap: () => _istasyonSec(istasyon),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade700 : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 3))
                          ],
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.blue.shade400,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.train_rounded,
                          size: isSelected ? 26 : 20,
                          color: isSelected ? Colors.white : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. ÜST BİLGİ BARI
          Positioned(
            top: 55,
            left: 70,
            right: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _secilenIstasyon == null 
                      ? [Colors.blue.shade700, Colors.blue.shade500] 
                      : [Colors.indigo.shade700, Colors.indigo.shade500],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_secilenIstasyon != null)
                    GestureDetector(
                      onTap: _tumIstasyonlariGoster,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    )
                  else
                    const Icon(Icons.directions_transit_filled, color: Colors.white, size: 18),
                  
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _secilenIstasyonAdi,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                  ),
                  if (_secilenIstasyon != null) const SizedBox(width: 24),
                ],
              ),
            ),
          ),

          // 3. SOL PANEL
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            top: 0,
            bottom: 0,
            left: _solPanelAcik ? 0 : -340,
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 15, offset: const Offset(4, 0))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 55, left: 20, right: 16, bottom: 16),
                    color: Colors.blue.shade900.withOpacity(0.3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🚇 İstasyon Listesi', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => setState(() => _solPanelAcik = false),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _aramaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "İstasyon ara...",
                        hintStyle: const TextStyle(color: Colors.white30),
                        prefixIcon: const Icon(Icons.search, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filtreliIstasyonlar.length,
                      itemBuilder: (context, index) {
                        final ist = _filtreliIstasyonlar[index];
                        return ListTile(
                          leading: const Icon(Icons.radio_button_checked, color: Colors.blue),
                          title: Text(ist.stationName, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          onTap: () => _istasyonSec(ist),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. SOL YÜZEN BUTONLAR (Yan menü açıldığında gizlenmesi sağlandı)
          if (!_solPanelAcik)
            Positioned(
              top: 120,
              left: 12,
              child: Column(
                children: [
                  _buildFab(Icons.menu, () => setState(() => _solPanelAcik = !_solPanelAcik), Colors.blue.shade600),
                  const SizedBox(height: 10),
                  _buildFab(Icons.refresh, _tumIstasyonlariGoster, Colors.orange.shade600),
                ],
              ),
            ),

          if (_hataMesaji.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text(_hataMesaji, style: TextStyle(color: Colors.red.shade800)),
              ),
            ),

          if (_yukleniyor)
            Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator(color: Colors.blue)),
            ),
        ],
      ),
    );
  }

  // 🕒 SEFER DETAY BOTTOM SHEET
  void _showSeferDetayBottomSheet(MetroStation istasyon) {
    // Ham yönleri çekiyoruz
    List<String> yonler = _secilenHatSeferleri.map((s) => s.directionType).toSet().toList();
    if (yonler.isEmpty) yonler.add("Bilinmeyen Yön");

    // 🔀 SABİT SIRALAMA MANTIĞI: Her zaman önce 'H' (Hastane), sonra 'A' (Akıncılar) gelmesini sağlıyoruz
    yonler.sort((a, b) {
      final temizA = a.trim().toUpperCase();
      final temizB = b.trim().toUpperCase();
      
      if ((temizA == 'H' || temizA.contains('HASTANE')) && !(temizB == 'H' || temizB.contains('HASTANE'))) {
        return -1; // A başa gelsin
      }
      if (!(temizA == 'H' || temizA.contains('HASTANE')) && (temizB == 'H' || temizB.contains('HASTANE'))) {
        return 1;  // B başa gelsin
      }
      return temizA.compareTo(temizB);
    });

    final simdi = DateTime.now();
    final simdiDakika = (simdi.hour * 60) + simdi.minute;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DefaultTabController(
        length: yonler.length,
        child: DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.train, color: Colors.blue)),
                    title: Text(istasyon.stationName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  
                  TabBar(
                    isScrollable: yonler.length > 2,
                    labelColor: Colors.blue.shade800,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue.shade700,
                    tabs: yonler.map((yon) => Tab(text: _yonIsminiFormatla(yon))).toList(),
                  ),
                  
                  const Divider(height: 1),
                  Expanded(
                    child: TabBarView(
                      children: yonler.map((aktifYon) {
                        final filtreliSeferler = _secilenHatSeferleri
                            .where((s) => s.directionType == aktifYon)
                            .toList();

                        if (filtreliSeferler.isEmpty) {
                          return const Center(child: Text("Bu yön için planlanmış sefer yok."));
                        }

                        int? siradakiIndeks;
                        int enYakinFark = 9999;

                        for (int i = 0; i < filtreliSeferler.length; i++) {
                          final parcalar = filtreliSeferler[i].departureTime.split(':');
                          if (parcalar.length >= 2) {
                            final saat = int.parse(parcalar[0]);
                            final dakika = int.parse(parcalar[1]);
                            final seferDakika = (saat * 60) + dakika;

                            final fark = seferDakika - simdiDakika;
                            if (fark >= 0 && fark < enYakinFark) {
                              enYakinFark = fark;
                              siradakiIndeks = i;
                            }
                          }
                        }

                        List<MetroSchedule> gecerliSeferlerListesi = [];
                        MetroSchedule? siradakiSeferObjesi;

                        if (siradakiIndeks != null) {
                          siradakiSeferObjesi = filtreliSeferler[siradakiIndeks];
                          
                          for (int i = 0; i < filtreliSeferler.length; i++) {
                            final parcalar = filtreliSeferler[i].departureTime.split(':');
                            if (parcalar.length >= 2) {
                              final saat = int.parse(parcalar[0]);
                              final dakika = int.parse(parcalar[1]);
                              final seferDakika = (saat * 60) + dakika;

                              if (seferDakika >= simdiDakika) {
                                gecerliSeferlerListesi.add(filtreliSeferler[i]);
                              }
                            }
                          }

                          gecerliSeferlerListesi.removeWhere((s) => s.id == siradakiSeferObjesi!.id);
                          gecerliSeferlerListesi.insert(0, siradakiSeferObjesi);
                        }

                        if (gecerliSeferlerListesi.isEmpty) {
                          return const Center(child: Text("Bugün için başka sefer kalmadı."));
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: gecerliSeferlerListesi.length,
                          itemBuilder: (context, index) {
                            final sefer = gecerliSeferlerListesi[index];
                            final bool isNext = siradakiSeferObjesi != null && sefer.id == siradakiSeferObjesi.id;

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                              color: isNext ? Colors.green.shade50 : Colors.grey.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isNext ? Colors.green.shade300 : Colors.transparent, 
                                  width: 1.5
                                )
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.access_time_filled, 
                                  color: isNext ? Colors.green.shade700 : Colors.indigo
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      sefer.departureTime.substring(0, 5), 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 17,
                                        color: isNext ? Colors.green.shade900 : Colors.black
                                      )
                                    ),
                                    const SizedBox(width: 8),
                                    if (isNext)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade600,
                                          borderRadius: BorderRadius.circular(6)
                                        ),
                                        child: const Text(
                                          "SIRADAKİ SEFER",
                                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isNext ? Colors.green.withOpacity(0.1) : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Text(
                                    sefer.dayType, 
                                    style: TextStyle(
                                      color: isNext ? Colors.green.shade800 : Colors.blue.shade800, 
                                      fontSize: 11, 
                                      fontWeight: FontWeight.w500
                                    )
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ).then((_) {
      if (mounted && _secilenIstasyon != null) {
        _tumIstasyonlariGoster();
      }
    });
  }

  Widget _buildFab(IconData icon, VoidCallback onTap, Color renk) {
    return Container(
      width: 44, height: 44,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
      child: IconButton(icon: Icon(icon, color: renk, size: 20), onPressed: onTap, padding: EdgeInsets.zero),
    );
  }
}