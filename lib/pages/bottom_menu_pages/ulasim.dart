import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smartcity/models/ulasim_model.dart';
import 'package:smartcity/apiler/ulasim_api_services.dart';
import 'dart:async';

class Ulasim extends StatefulWidget {
  const Ulasim({super.key});

  @override
  State<Ulasim> createState() => _UlasimState();
}

class _UlasimState extends State<Ulasim> {
  final MapController _mapController = MapController();
  final UlasimService _ulasimService = UlasimService();

  List<LatLng> _guzergahCizgisi = [];
  List<Durak> _duraklar = [];
  List<Durak> _tumDuraklar = [];
  bool _yukleniyor = false;
  String _hataMesaji = '';

  bool _solPanelAcik = false;
  int _aktifSekme = 0; // 0: ROUTES, 1: STOPS
  List<Hat> _tumHatlar = [];
  List<Hat> _filtreliHatlar = [];
  Hat? _secilenHat;
  String _secilenHatAdi = "Tüm Duraklar";
  final TextEditingController _aramaController = TextEditingController();

  Timer? _moveEndTimer;
  
  bool _haritaHareketEdiyor = false;
  LatLng? _sonMerkez;
  double? _sonZoom;

  @override
  void initState() {
    super.initState();
    _tumDuraklariYukle();
    _hatListesiniYukle();
    _aramaController.addListener(() {
      _hatlariFiltrele(_aramaController.text);
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.mapEventStream?.listen((event) {
        if (event is MapEventMoveEnd) {
          _onMapMoveEnd(event.camera);
        } else if (event is MapEventMoveStart) {
          _haritaHareketEdiyor = true;
          print('🔄 Harita hareket etmeye başladı');
        }
      });
    });
  }

  @override
  void dispose() {
    _aramaController.dispose();
    _moveEndTimer?.cancel();
    super.dispose();
  }

  void _onMapMoveEnd(MapCamera camera) {
    _haritaHareketEdiyor = false;
    
    _moveEndTimer?.cancel();

    _moveEndTimer = Timer(const Duration(milliseconds: 500), () {
      print('=== HARİTA HAREKETİ DURDU (MOVEEND) ===');
      print('📍 Yeni Merkez: ${camera.center}');
      print('🔍 Zoom Seviyesi: ${camera.zoom}');
      
      if (_sonMerkez != camera.center || _sonZoom != camera.zoom) {
        _sonMerkez = camera.center;
        _sonZoom = camera.zoom;
        _gorunurDuraklariGuncelle(camera);
      }
    });
  }

  void _gorunurDuraklariGuncelle(MapCamera camera) {
    if (_secilenHat == null && _tumDuraklar.isNotEmpty) {
      final center = camera.center;
      final zoom = camera.zoom;
      final double degreeRange = 0.05 / (zoom / 10);
      
      final double minLat = center.latitude - degreeRange;
      final double maxLat = center.latitude + degreeRange;
      final double minLng = center.longitude - degreeRange;
      final double maxLng = center.longitude + degreeRange;
      
      final gorunurDuraklar = _tumDuraklar.where((durak) {
        final lat = durak.koordinat.latitude;
        final lng = durak.koordinat.longitude;
        return lat >= minLat &&
               lat <= maxLat &&
               lng >= minLng &&
               lng <= maxLng;
      }).toList();
      
      print('👁️ Görünür durak sayısı: ${gorunurDuraklar.length} / ${_tumDuraklar.length}');
      if (gorunurDuraklar.length < _duraklar.length && gorunurDuraklar.isNotEmpty) {
        setState(() {
          _duraklar = gorunurDuraklar;
        });
      }
    } else if (_secilenHat != null) {
      print('🚌 Hat seçili: ${_secilenHat!.routeShortName} - ${_duraklar.length} durak');
    }
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _haritaHareketEdiyor = true;
    _moveEndTimer?.cancel();
    _moveEndTimer = Timer(const Duration(milliseconds: 600), () {
      _haritaHareketEdiyor = false;
      print('=== HARİTA HAREKETİ DURDU (POSITION CHANGED) ===');
      print('📍 Yeni Merkez: ${camera.center}');
      print('🔍 Zoom Seviyesi: ${camera.zoom}');
      
      if (_sonMerkez != camera.center || _sonZoom != camera.zoom) {
        _sonMerkez = camera.center;
        _sonZoom = camera.zoom;
        _gorunurDuraklariGuncelle(camera);
      }
    });
  }

  Future<void> _tumDuraklariYukle() async {
    setState(() {
      _yukleniyor = true;
    });

    final duraklar = await _ulasimService.getTumDuraklar();
    print('Tüm duraklar yüklendi: ${duraklar.length}');

    setState(() {
      _tumDuraklar = duraklar;
      _duraklar = duraklar;
      _yukleniyor = false;
    });

    if (duraklar.isNotEmpty) {
      final center = duraklar[duraklar.length ~/ 2].koordinat;
      _mapController.move(center, 12.0);
    }
  }

  Future<void> _hatListesiniYukle() async {
    try {
      final List<Hat> hatlar = await _ulasimService.getTumHatlar();
      print('Gelen hat sayısı: ${hatlar.length}');

      if (hatlar.isEmpty) {
        setState(() {
          _hataMesaji = 'Hiç hat bulunamadı!';
        });
        return;
      }

      final List<Hat> gecerliHatlar = hatlar.where((hat) => hat.isValid).toList();
      print('Geçerli hat sayısı: ${gecerliHatlar.length}');

      if (gecerliHatlar.isEmpty) {
        setState(() {
          _hataMesaji = 'Geçerli hat bulunamadı!';
        });
        return;
      }

      final Map<String, Hat> uniqueHats = {};
      for (var hat in gecerliHatlar) {
        if (!uniqueHats.containsKey(hat.routeId)) {
          uniqueHats[hat.routeId] = hat;
        }
      }

      final List<Hat> benzersizHatlar = uniqueHats.values.toList();
      print('Benzersiz hat sayısı: ${benzersizHatlar.length}');

      setState(() {
        _tumHatlar = benzersizHatlar;
        _filtreliHatlar = benzersizHatlar;
      });
    } catch (e) {
      setState(() {
        _hataMesaji = 'Hata: $e';
      });
      print("Hat listesi yüklenirken hata oluştu: $e");
    }
  }

  void _hatSec(Hat hat) {
    setState(() {
      _secilenHat = hat;
      _solPanelAcik = false;
      _secilenHatAdi = "${hat.routeShortName} - ${hat.routeLongName}";
    });
    _hatDuraklariniYukle(hat.shapeId, hat.tripId);
  }

  Future<void> _hatDuraklariniYukle(String shapeId, String tripId) async {
    setState(() {
      _yukleniyor = true;
      _hataMesaji = '';
      _duraklar = [];
      _guzergahCizgisi = [];
    });

    try {
      print('=== HAT DURAKLARI YÜKLENİYOR ===');
      print('Shape ID: $shapeId');
      print('Trip ID: $tripId');

      if (shapeId.isEmpty || tripId.isEmpty) {
        setState(() {
          _duraklar = _tumDuraklar;
          _yukleniyor = false;
          _secilenHat = null;
          _secilenHatAdi = "Tüm Duraklar";
        });
        return;
      }

      final rotalar = await _ulasimService.getRotaCizgisi(shapeId);
      print('Rota noktası sayısı: ${rotalar.length}');

      final gelenDuraklar = await _ulasimService.getSeferDuraklari(tripId);
      print('Gelen durak sayısı: ${gelenDuraklar.length}');

      setState(() {
        _guzergahCizgisi = rotalar.map((r) => r.koordinat).toList();
        _duraklar = gelenDuraklar.isNotEmpty ? gelenDuraklar : _tumDuraklar;
        _yukleniyor = false;
      });

      if (_duraklar.isNotEmpty) {
        final center = _duraklar[_duraklar.length ~/ 2].koordinat;
        _mapController.move(center, 13.5);
      }
    } catch (e) {
      setState(() {
        _yukleniyor = false;
        _hataMesaji = 'Veri yükleme hatası: $e';
      });
      print("Veri yükleme hatası: $e");
    }
  }

  void _tumDuraklariGoster() {
    setState(() {
      _secilenHat = null;
      _duraklar = _tumDuraklar;
      _guzergahCizgisi = [];
      _secilenHatAdi = "Tüm Duraklar (${_tumDuraklar.length})";
      _solPanelAcik = false;
    });

    if (_tumDuraklar.isNotEmpty) {
      final center = _tumDuraklar[_tumDuraklar.length ~/ 2].koordinat;
      _mapController.move(center, 12.0);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📍 ${_tumDuraklar.length} durak gösteriliyor'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _hatlariFiltrele(String sorgu) {
    setState(() {
      if (sorgu.isEmpty) {
        _filtreliHatlar = _tumHatlar;
      } else {
        _filtreliHatlar = _tumHatlar.where((hat) {
          final kisaAd = hat.routeShortName.toLowerCase();
          final uzunAd = hat.routeLongName.toLowerCase();
          final sorguLower = sorgu.toLowerCase();
          return kisaAd.contains(sorguLower) || uzunAd.contains(sorguLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(37.0, 35.3),
              initialZoom: 12.0,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  _onPositionChanged(camera, hasGesture);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.belediye.akillisehir',
              ),
              if (_guzergahCizgisi.isNotEmpty && _secilenHat != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _guzergahCizgisi,
                      strokeWidth: 6.0,
                      color: Colors.blue.shade700,
                      borderColor: Colors.white.withOpacity(0.3),
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),
              if (_duraklar.isNotEmpty)
                MarkerLayer(
                  markers: _duraklar.map((durak) {
                    final isSelected = _secilenHat != null &&
                        _guzergahCizgisi.isNotEmpty &&
                        _duraklar.contains(durak);
                    return Marker(
                      key: ValueKey(durak.id),
                      point: durak.koordinat,
                      width: isSelected ? 50 : 38,
                      height: isSelected ? 50 : 38,
                      child: GestureDetector(
                        onTap: () {
                          _showDurakDetay(durak);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.shade600 : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.blue.shade300,
                              width: 2.5,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 8,
                                child: Icon(Icons.directions_bus, size: 20, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),

          // TOP BAR
          Positioned(
            top: 55,
            left: 70,
            right: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                gradient: _secilenHat == null
                    ? LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: (_secilenHat == null ? Colors.green : Colors.blue)
                        .shade300
                        .withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _secilenHat == null ? Icons.location_on : Icons.directions_bus,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _secilenHatAdi,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // HATA MESAJI
          if (_hataMesaji.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _hataMesaji,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red.shade700, size: 18),
                      onPressed: () => setState(() => _hataMesaji = ''),
                    ),
                  ],
                ),
              ),
            ),

          // SOL PANEL
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            top: 0,
            bottom: 0,
            left: _solPanelAcik ? 0 : -380,
            child: Container(
              width: 360,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade900,
                    Colors.grey.shade800,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(4, 0),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Panel Header
                  Container(
                    padding: const EdgeInsets.only(top: 55, left: 20, right: 16, bottom: 16),
                    decoration: BoxDecoration(
                      color: (_secilenHat == null ? Colors.green : Colors.blue)
                          .shade700
                          .withOpacity(0.15),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _secilenHat != null
                                    ? '🚌 ${_secilenHat!.routeShortName}'
                                    : '📍 Tüm Duraklar',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _secilenHat != null
                                    ? _secilenHat!.routeLongName
                                    : '${_tumDuraklar.length} durak',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                          onPressed: () => setState(() => _solPanelAcik = false),
                        ),
                      ],
                    ),
                  ),
                  // Sekmeler
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildSekmeButonu2("🚌 ROUTES", 0),
                          _buildSekmeButonu2("📍 STOPS", 1),
                        ],
                      ),
                    ),
                  ),
                  // Arama Kutusu
                  if (_aktifSekme == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _aramaController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "🔍 Hat ara...",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Liste
                  Expanded(
                    child: _aktifSekme == 0
                        ? _filtreliHatlar.isEmpty
                            ? Center(
                                child: Text(
                                  'Hat bulunamadı',
                                  style: TextStyle(color: Colors.white.withOpacity(0.3)),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: _filtreliHatlar.length,
                                itemBuilder: (context, index) {
                                  final hat = _filtreliHatlar[index];
                                  final isSelected = _secilenHat?.routeId == hat.routeId;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue.withOpacity(0.2)
                                          : Colors.white.withOpacity(0.03),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue.shade400
                                            : Colors.white.withOpacity(0.05),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 2,
                                      ),
                                      leading: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.blue.shade400
                                              : Colors.blue.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            hat.routeShortName,
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        hat.routeLongName,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.white70,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: isSelected
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: Colors.blue,
                                              size: 18,
                                            )
                                          : null,
                                      onTap: () => _hatSec(hat),
                                    ),
                                  );
                                },
                              )
                        : _duraklar.isEmpty
                            ? Center(
                                child: Text(
                                  'Durak yok',
                                  style: TextStyle(color: Colors.white.withOpacity(0.3)),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: _duraklar.length,
                                itemBuilder: (context, index) {
                                  final durak = _duraklar[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.03),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 2,
                                      ),
                                      leading: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        durak.isim,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () {
                                        _mapController.move(durak.koordinat, 16.0);
                                        setState(() => _solPanelAcik = false);
                                        _showDurakDetay(durak);
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // SOL BUTONLAR
          Positioned(
            top: 120,
            left: 12,
            child: Column(
              children: [
                _buildFloatingActionButton(
                  Icons.menu_rounded,
                  () {
                    setState(() {
                      _solPanelAcik = !_solPanelAcik;
                      if (_solPanelAcik) _aktifSekme = 0;
                    });
                  },
                  Colors.blue.shade600,
                ),
                const SizedBox(height: 10),
                _buildFloatingActionButton(
                  Icons.location_on_rounded,
                  () {
                    if (_duraklar.isNotEmpty) {
                      final center = _duraklar[_duraklar.length ~/ 2].koordinat;
                      _mapController.move(center, 14.0);
                    }
                  },
                  Colors.green.shade600,
                ),
                const SizedBox(height: 10),
                _buildFloatingActionButton(
                  Icons.cleaning_services_rounded,
                  _tumDuraklariGoster,
                  Colors.orange.shade600,
                ),
              ],
            ),
          ),

          // ZOOM
          Positioned(
            bottom: 40,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.black87),
                    onPressed: () {
                      final center = _mapController.camera.center;
                      final zoom = _mapController.camera.zoom;
                      _mapController.move(center, zoom + 0.5);
                    },
                    splashRadius: 20,
                  ),
                  Container(
                    width: 30,
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.black87),
                    onPressed: () {
                      final center = _mapController.camera.center;
                      final zoom = _mapController.camera.zoom;
                      _mapController.move(center, zoom - 0.5);
                    },
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // YÜKLEME
          if (_yukleniyor)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.blue),
                      SizedBox(height: 16),
                      Text('Yükleniyor...'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSekmeButonu2(String metin, int indeks) {
    bool seciliMi = _aktifSekme == indeks;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _aktifSekme = indeks),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: seciliMi ? Colors.blue.shade600 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              metin,
              style: TextStyle(
                color: seciliMi ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight: seciliMi ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(IconData icon, VoidCallback onTap, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 24),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        splashRadius: 24,
      ),
    );
  }

  // DURAK DETAY BOTTOM SHEET
  void _showDurakDetay(Durak durak) async {
    final hatlar = await _ulasimService.getDurakHatlar(durak.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.6,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_bus_rounded,
                          color: Colors.blue.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              durak.isim,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '📍 ${durak.koordinat.latitude.toStringAsFixed(6)}, ${durak.koordinat.longitude.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                const Divider(height: 1),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🚌 Bu Duraktan Geçen Hatlar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${hatlar.length} hat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: hatlar.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // DÜZELTİLDİ: directions_bus_off_rounded yerine directions_bus_rounded kullanıldı
                              Icon(
                                Icons.directions_bus_rounded,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Bu duraktan geçen hat yok',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            controller: scrollController,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: hatlar.length,
                            itemBuilder: (context, index) {
                              final hatNo = hatlar[index];
                              return _buildHatKareWidget(hatNo);
                            },
                          ),
                        ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHatKareWidget(String hatNo) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    
    final int? hatNumber = int.tryParse(hatNo);
    final colorIndex = hatNumber != null ? hatNumber.hashCode.abs() % colors.length : 0;
    final color = colors[colorIndex];
    
    return GestureDetector(
      onTap: () {
        final selectedHat = _tumHatlar.firstWhere(
          (h) => h.routeShortName == hatNo,
          orElse: () => _tumHatlar.first,
        );
        _hatSec(selectedHat);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.7),
              color.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            hatNo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}