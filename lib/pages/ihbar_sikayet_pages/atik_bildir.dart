// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:smartcity/apiler/ihbar_sikayet_apiler/atik_bildir_api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AtikBildir extends StatefulWidget {
  const AtikBildir({super.key});

  @override
  State<AtikBildir> createState() => _AtikBildirState();
}

class _AtikBildirState extends State<AtikBildir> {
  final _formKey = GlobalKey<FormState>();
  final AmbalajAtikService _atikService = AmbalajAtikService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  String? _secilenAtikTuru;
  String? _secilenFotoPath; 
  String? _secilenFotoAdi;

  LatLng _secilenKonum = const LatLng(36.9938, 35.3255); 
  final Set<Marker> _isaretciler = {};

  final List<String> _atikTurleri = [
    'AMBALAJ ATIKLARI', 'BİTKİSEL YAĞ', 'MADENİ YAĞ', 'PİL BATARYA AKÜ', 
    'ELEKTRİKLİ VE ELEKTRONİK EŞYA', 'TEKSTİL ÜRÜNLERİ', 'TIBBİ ATIK', 
    'İLAÇLAR', 'İNŞAAT/YIKINTI', 'LASTİK', 'EVSEL ATIKLAR', 
    'HACİMLİ ATIKLAR', 'PARK BAHÇE ATIKLARI', 'DİĞER'
  ];

  final TextEditingController _adSoyadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _adresController = TextEditingController();
  final TextEditingController _atikMiktariController = TextEditingController();
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();
  final TextEditingController _digerAtikController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isaretciGuncelle(_secilenKonum);
  }

  void _isaretciGuncelle(LatLng konum) {
    setState(() {
      _secilenKonum = konum;
      _isaretciler.clear();
      _isaretciler.add(
        Marker(
          markerId: const MarkerId('secilen_konum_id'),
          position: konum,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  Future<void> _fotoSec(ImageSource kaynak) async {
    try {
      final XFile? secilenDosya = await _picker.pickImage(
        source: kaynak,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (secilenDosya != null) {
        setState(() {
          _secilenFotoPath = secilenDosya.path;
          _secilenFotoAdi = secilenDosya.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf erişim hatası: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _formuGonder() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    String atikTuruSonuc = _secilenAtikTuru == 'DİĞER' 
        ? 'DİĞER (${_digerAtikController.text.trim()})' 
        : (_secilenAtikTuru ?? '');

    Map<String, String> formData = {
      'atik_turu': atikTuruSonuc,
      'ad_soyad': _adSoyadController.text.trim(),
      'email': _emailController.text.trim(),
      'telefon': _telefonController.text.trim(),
      'adres': _adresController.text.trim(),
      'atik_miktari': _atikMiktariController.text.trim(),
      'baslik': _baslikController.text.trim(),
      'aciklama': _aciklamaController.text.trim(),
      'latitude': _secilenKonum.latitude.toString(),
      'longitude': _secilenKonum.longitude.toString(),
    };

    bool basariliMi = await _atikService.gonderAmbalajAtik(
      veri: formData,
      fotoPath: _secilenFotoPath,
    );

    setState(() => _isLoading = false);

    if (basariliMi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atık talebiniz başarıyla iletildi!'), backgroundColor: Colors.green),
      );
      _temizle();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gönderim sırasında bir hata oluştu.'), backgroundColor: Colors.red),
      );
    }
  }

  void _temizle() {
    _adSoyadController.clear();
    _emailController.clear();
    _telefonController.clear();
    _adresController.clear();
    _atikMiktariController.clear();
    _baslikController.clear();
    _aciklamaController.clear();
    _digerAtikController.clear();
    setState(() {
      _secilenAtikTuru = null;
      _secilenFotoPath = null;
      _secilenFotoAdi = null;
      _secilenKonum = const LatLng(36.9938, 35.3255);
      _isaretciGuncelle(_secilenKonum);
    });
  }

  @override
  void dispose() {
    _adSoyadController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    _adresController.dispose();
    _atikMiktariController.dispose();
    _baslikController.dispose();
    _aciklamaController.dispose();
    _digerAtikController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const yesilTema = Color(0xFF4C8C04);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: yesilTema,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'ATIK BİLDİR', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 20)
        ),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: yesilTema)) 
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    children: [
                      _buildFormDropdown('Atık Türü Seçiniz', _atikTurleri, _secilenAtikTuru, (v) {
                        setState(() {
                          _secilenAtikTuru = v;
                          if (v != 'DİĞER') {
                            _digerAtikController.clear();
                          }
                        });
                      }),
                      if (_secilenAtikTuru == 'DİĞER')
                        _buildTextField(_digerAtikController, 'Diğer Atık Türünü Belirtiniz'),
                      _buildTextField(_adSoyadController, 'Ad-Soyad Giriniz'),
                      _buildTextField(_emailController, 'E-posta Giriniz', keyboardType: TextInputType.emailAddress),
                      _buildTextField(_telefonController, 'Telefon numarası giriniz', keyboardType: TextInputType.phone),
                      _buildTextField(_adresController, 'Atık Adresini giriniz'),
                      _buildTextField(_atikMiktariController, 'Atık Miktarı Giriniz'),
                      _buildTextField(_baslikController, 'Başlık Giriniz'),
                      _buildTextField(_aciklamaController, 'Açıklama Giriniz', maxLines: 4),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMediaButton(
                            icon: Icons.camera_alt_rounded,
                            label: 'Fotoğraf Çek',
                            onTap: () => _fotoSec(ImageSource.camera),
                          ),
                          _buildMediaButton(
                            icon: Icons.image_rounded,
                            label: 'Galeriden Yükle',
                            onTap: () => _fotoSec(ImageSource.gallery),
                          ),
                        ],
                      ),
                      if (_secilenFotoAdi != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(_secilenFotoAdi!, style: const TextStyle(fontSize: 12, color: yesilTema, fontWeight: FontWeight.w500)),
                        ),
                      const SizedBox(height: 20),
                      
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _secilenKonum,
                            zoom: 14.0,
                          ),
                          markers: _isaretciler,
                          onTap: (LatLng tiklananKonum) {
                            _isaretciGuncelle(tiklananKonum);
                          },
                          mapType: MapType.normal,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _formuGonder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yesilTema,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('Gönder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 15),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEFEFEF), width: 1.5),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4C8C04), width: 1.5),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? '$hintText boş bırakılamaz' : null,
      ),
    );
  }

  Widget _buildFormDropdown(String hint, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        isExpanded: true,
        hint: Text(hint, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 15)),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 28),
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEFEFEF), width: 1.5),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4C8C04), width: 1.5),
          ),
        ),
        items: items.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Lütfen bir atık türü seçin' : null,
      ),
    );
  }

  Widget _buildMediaButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 55, color: const Color(0xFF4C8C04)),
            const SizedBox(height: 6),
            Text(
              label, 
              style: const TextStyle(fontSize: 14, color: Color(0xFF555555), fontWeight: FontWeight.normal)
            ),
          ],
        ),
      ),
    );
  }
}