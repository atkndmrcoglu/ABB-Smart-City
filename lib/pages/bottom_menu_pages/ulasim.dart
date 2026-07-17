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
  int _aktifSekme = 0;
  List<Hat> _tumHatlar = [];
  List<Hat> _filtreliHatlar = [];
  Hat? _secilenHat;
  String _secilenHatAdi = "Tüm Duraklar";
  final TextEditingController _aramaController = TextEditingController();

  Timer? _moveEndTimer;
  LatLng? _sonMerkez;
  double? _sonZoom;

  @override
  void initState() {
    super.initState();
    _ilkVerileriYukle();
    _hatListesiniYukle();
    _aramaController.addListener(() {
      _hatlariFiltrele(_aramaController.text);
    });
  }

  @override
  void dispose() {
    _aramaController.dispose();
    _moveEndTimer?.cancel();
    super.dispose();
  }

  void _gorunurDuraklariGuncelle(MapCamera camera) {
    if (_secilenHat == null && _tumDuraklar.isNotEmpty) {
      final zoom = camera.zoom;
      if (zoom < 13.0) {
        if (_duraklar.isNotEmpty) {
          setState(() {
            _duraklar = [];
          });
        }
        return;
      }

      final bounds = camera.visibleBounds;
      
      final gorunurDuraklar = _tumDuraklar.where((durak) {
        return bounds.contains(durak.koordinat);
      }).toList();
      
      setState(() {
        _duraklar = gorunurDuraklar;
      });
    }
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    _moveEndTimer?.cancel();
    _moveEndTimer = Timer(const Duration(milliseconds: 400), () {
      if (_sonMerkez != camera.center || _sonZoom != camera.zoom) {
        _sonMerkez = camera.center;
        _sonZoom = camera.zoom;
        _gorunurDuraklariGuncelle(camera);
      }
    });
  }
  Future<void> _ilkVerileriYukle() async {
    setState(() => _yukleniyor = true);
    try {
      final duraklar = await _ulasimService.getTumDuraklar();
      _tumDuraklar = duraklar;
      setState(() {
        _yukleniyor = false;
      });
      _mapController.move(const LatLng(37.0, 35.3), 13.5);
    } catch (e) {
      setState(() {
        _yukleniyor = false;
        _hataMesaji = 'Duraklar yüklenirken bir hata oluştu.';
      });
    }
  }

  Future<void> _hatListesiniYukle() async {
    try {
      final List<Hat> hatlar = await _ulasimService.getTumHatlar();
      if (hatlar.isEmpty) {
        setState(() => _hataMesaji = 'Hiç hat bulunamadı!');
        return;
      }

      final List<Hat> gecerliHatlar = hatlar.where((hat) => hat.isValid).toList();
      final Map<String, Hat> uniqueHats = {};
      for (var hat in gecerliHatlar) {
        if (!uniqueHats.containsKey(hat.routeId)) {
          uniqueHats[hat.routeId] = hat;
        }
      }

      setState(() {
        _tumHatlar = uniqueHats.values.toList();
        _filtreliHatlar = _tumHatlar;
      });
    } catch (e) {
      setState(() => _hataMesaji = 'Hata: $e');
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
      final gelenDuraklar = await _ulasimService.getSeferDuraklari(tripId);
      List<LatLng> koordinatListesi = [];
      
      try {
        final rotalar = await _ulasimService.getRotaCizgisi(shapeId);
        if (rotalar.isNotEmpty) {
          koordinatListesi = rotalar.map((r) => r.koordinat).toList();
        }
      } catch (e) {
        print("Rota API hatası: $e");
      }

      if (koordinatListesi.isEmpty && gelenDuraklar.isNotEmpty) {
        koordinatListesi = gelenDuraklar.map((d) => d.koordinat).toList();
      }

      setState(() {
        _guzergahCizgisi = koordinatListesi;
        _duraklar = gelenDuraklar;
        _yukleniyor = false;
      });

      if (_duraklar.isNotEmpty) {
        _mapController.move(_duraklar[_duraklar.length ~/ 2].koordinat, 13.5);
      }
    } catch (e) {
      setState(() {
        _yukleniyor = false;
        _hataMesaji = 'Veri yükleme hatası: $e';
      });
    }
  }

  void _hatlariFiltrele(String sorgu) {
    setState(() {
      if (sorgu.isEmpty) {
        _filtreliHatlar = _tumHatlar;
      } else {
        _filtreliHatlar = _tumHatlar.where((hat) {
          return hat.routeShortName.toLowerCase().contains(sorgu.toLowerCase()) ||
                 hat.routeLongName.toLowerCase().contains(sorgu.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildFlutterMap(),
          _buildTopBar(),
          if (_hataMesaji.isNotEmpty) _buildHataMesaji(),
          _buildSolPanel(),
          _buildMenuButonu(),
          _buildZoomButonlari(),
          if (_yukleniyor) _buildYuklemeEkrani(),
        ],
      ),
    );
  }

  Widget _buildFlutterMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(37.0, 35.3),
        initialZoom: 12.0,
        onPositionChanged: (camera, hasGesture) {
          _onPositionChanged(camera, hasGesture);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.belediye.akillisehir',
        ),
        if (_guzergahCizgisi.isNotEmpty) _buildPolylineLayer(),
        if (_duraklar.isNotEmpty) _buildMarkerLayer(),
      ],
    );
  }

  PolylineLayer _buildPolylineLayer() {
    return PolylineLayer(
      polylines: [
        Polyline(
          points: _guzergahCizgisi,
          strokeWidth: 8.0,
          color: Colors.blue.shade900.withValues(alpha: 0.35),
        ),
        Polyline(
          points: _guzergahCizgisi,
          strokeWidth: 5.0,
          color: Colors.blue.shade600,
          borderColor: Colors.white,
          borderStrokeWidth: 1.5,
        ),
      ],
    );
  }

  MarkerLayer _buildMarkerLayer() {
    return MarkerLayer(
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
            onTap: () => _showDurakDetay(durak),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade600 : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.blue.shade300,
                  width: 2.5,
                ),
              ),
              child: Icon(
                Icons.directions_bus,
                size: isSelected ? 22 : 20,
                color: isSelected ? Colors.white : Colors.blue.shade600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
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
                  .withValues(alpha: 0.4),
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
    );
  }

  Widget _buildHataMesaji() {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 10),
            Expanded(child: Text(_hataMesaji, style: TextStyle(color: Colors.red.shade700))),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red.shade700, size: 18),
              onPressed: () => setState(() => _hataMesaji = ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolPanel() {
    return AnimatedPositioned(
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
            colors: [Colors.grey.shade900, Colors.grey.shade800],
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            _buildPanelHeader(),
            _buildSekmeButonlari(),
            if (_aktifSekme == 0) _buildAramaKutusu(),
            const SizedBox(height: 8),
            Expanded(
              child: _aktifSekme == 0 ? _buildHatListesi() : _buildDurakListesi(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 55, left: 20, right: 16, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment : CrossAxisAlignment.start,
              children: [
                Text(
                  _secilenHat != null ? '🚌 ${_secilenHat!.routeShortName}' : '📍 Tüm Duraklar',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _secilenHat != null ? _secilenHat!.routeLongName : '${_tumDuraklar.length} durak hafızada',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => setState(() => _solPanelAcik = false),
          ),
        ],
      ),
    );
  }

  Widget _buildSekmeButonlari() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildSekmeButonu("🚌 ROUTES", 0),
            _buildSekmeButonu("📍 STOPS", 1),
          ],
        ),
      ),
    );
  }

  Widget _buildSekmeButonu(String metin, int indeks) {
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

  Widget _buildAramaKutusu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _aramaController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "🔍 Hat ara...",
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildHatListesi() {
    if (_filtreliHatlar.isEmpty) {
      return Center(child: Text('Hat bulunamadı', style: TextStyle(color: Colors.white.withValues(alpha: .3))));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _filtreliHatlar.length,
      itemBuilder: (context, index) {
        final hat = _filtreliHatlar[index];
        final isSelected = _secilenHat?.routeId == hat.routeId;
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? Colors.blue : Colors.blue.withValues(alpha: 0.2),
              child: Text(
                hat.routeShortName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              hat.routeLongName,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _hatSec(hat),
          ),
        );
      },
    );
  }

  Widget _buildDurakListesi() {
    if (_duraklar.isEmpty) {
      return Center(child: Text('Görünür durak yok (Haritaya yaklaşın)', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _duraklar.length,
      itemBuilder: (context, index) {
        final durak = _duraklar[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withValues(alpha: 0.2),
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              durak.isim,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
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
    );
  }

  Widget _buildMenuButonu() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      top: 120,
      left: _solPanelAcik ? -60 : 12,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _solPanelAcik ? 0.0 : 1.0,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.menu_rounded, color: Colors.blue.shade600, size: 24),
            onPressed: () {
              setState(() {
                _solPanelAcik = !_solPanelAcik;
                if (_solPanelAcik) _aktifSekme = 0;
              });
            },
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButonlari() {
    return Positioned(
      bottom: 40,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
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
            ),
            Container(width: 30, height: 1, color: Colors.grey.shade300),
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.black87),
              onPressed: () {
                final center = _mapController.camera.center;
                final zoom = _mapController.camera.zoom;
                _mapController.move(center, zoom - 0.5);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYuklemeEkrani() {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
    );
  }

  void _showDurakDetay(Durak durak) async {
    setState(() => _yukleniyor = true);

    final hatlar = await _ulasimService.getDurakHatlar(durak.id);
    if (!mounted) return;

    setState(() => _yukleniyor = false);

    if (hatlar.isEmpty) {
      _showHataMesaji('Bu durakta aktif hat bulunmamaktadır.');
      return;
    }

    final List<Map<String, dynamic>> yaklasanAraclar = [];

    for (var hatNo in hatlar) {
      try {
        final hatDetay = await _ulasimService.getHatDetay(hatNo);
        final aracBilgisi = await _ulasimService.getYaklasanArac(durak.id, hatNo);
        final rawSaatler = hatDetay?['saatler'];
        final List<String> kalkisSaatleri = (rawSaatler is Iterable && rawSaatler != null)
          ? List<String>.from((rawSaatler as Iterable).map((e) => e?.toString() ?? ''))
          : <String>[];

        if (hatNo.isNotEmpty) {
          yaklasanAraclar.add({
            "hatNo": hatNo,
            "dakika": aracBilgisi?['dakika'] ?? "Bilinmiyor",
            "mesafe": aracBilgisi?['mesafe'] ?? "Bilinmiyor",
            "sonDurak": hatDetay?['sonDurak'] ?? "Bilinmiyor",
            "guzergah": hatDetay?['guzergah'] ?? "Bilinmiyor",
            "kalkisSaatleri": kalkisSaatleri,
          });
        }
      } catch (e) {
        print('Hat bilgisi alınamadı ($hatNo): $e');
      }
    }

    if (yaklasanAraclar.isEmpty) {
      _showHataMesaji('Hat bilgileri yüklenirken bir hata oluştu.');
      return;
    }

    int detaySekmesi = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setPanelState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    _buildDetayCubugu(),
                    _buildDetayHeader(durak),
                    const Divider(height: 1),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => setPanelState(() => detaySekmesi = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: detaySekmesi == 0 ? Colors.green.shade500 : Colors.transparent,
                                    width: 3.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Araçlar",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: detaySekmesi == 0 ? Colors.black87 : Colors.grey.shade500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      "${yaklasanAraclar.length}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => setPanelState(() => detaySekmesi = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: detaySekmesi == 1 ? Colors.green.shade500 : Colors.transparent,
                                    width: 3.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Hatlar",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: detaySekmesi == 1 ? Colors.black87 : Colors.grey.shade500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      "${yaklasanAraclar.length}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: detaySekmesi == 0
                          ? _buildAraclarListesi(yaklasanAraclar, scrollController)
                          : _buildHatlarListesi(yaklasanAraclar, scrollController),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetayCubugu() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 45,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildDetayHeader(Durak durak) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                durak.id.toString().padLeft(3, '0'),
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  durak.isim.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Durak No: ${durak.id}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAraclarListesi(List<Map<String, dynamic>> yaklasanAraclar, ScrollController controller) {
    if (yaklasanAraclar.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_bus, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text("Yaklaşan araç bulunmamaktadır."),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: yaklasanAraclar.length,
      itemBuilder: (context, index) {
        final arac = yaklasanAraclar[index];
        final saatler = (arac['kalkisSaatleri'] as List<String>?) ?? [];
        
        return GestureDetector(
          onTap: () {
            if (saatler.isNotEmpty) {
              _showSaatlerDetay(arac['hatNo'], saatler);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        arac['hatNo'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          arac['dakika'] != "Bilinmiyor" ? "${arac['dakika']} dk" : "--",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.directions_bus_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          arac['mesafe'] != "Bilinmiyor" ? "${arac['mesafe']} km" : "--",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        arac['sonDurak'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.alt_route, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        arac['guzergah'],
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHatlarListesi(List<Map<String, dynamic>> yaklasanAraclar, ScrollController controller) {
    if (yaklasanAraclar.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.route, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text("Hat bulunmamaktadır."),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: yaklasanAraclar.length,
      itemBuilder: (context, index) {
        final arac = yaklasanAraclar[index];
        // ÇÖZÜM: Null-Safety koruması eklendi.
        final saatler = (arac['kalkisSaatleri'] as List<String>?) ?? [];
        
        return GestureDetector(
          onTap: () {
            if (saatler.isNotEmpty) {
              _showSaatlerDetay(arac['hatNo'], saatler);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    arac['hatNo'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.alt_route, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          arac['guzergah'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHataMesaji(String mesaj) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bilgi'),
        content: Text(mesaj),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showSaatlerDetay(String hatNo, List<String> saatler) {
    final DateTime simdi = DateTime.now();
    final String suAnkiSaat = "${simdi.hour.toString().padLeft(2, '0')}:${simdi.minute.toString().padLeft(2, '0')}";

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "🚌 $hatNo Sefer Saatleri",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Cihaz Saati: $suAnkiSaat",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                "Günlük Planlanmış Kalkış Saatleri:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: saatler.length,
                  itemBuilder: (context, index) {
                    final saat = saatler[index];
                    final isPassed = saat.compareTo(suAnkiSaat) < 0;

                    return Container(
                      decoration: BoxDecoration(
                        color: isPassed ? Colors.grey.shade100 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPassed ? Colors.grey.shade300 : Colors.blue.shade200,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          saat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? Colors.grey.shade400 : Colors.blue.shade800,
                            decoration: isPassed ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}