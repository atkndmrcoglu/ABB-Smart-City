// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:smartcity/apiler/ihbar_sikayet_apiler/istek_sikayet_api.dart';
import 'package:smartcity/models/ihbar_sikayet/istek_sikayet_model.dart';

class IstekSikayet extends StatefulWidget {
  const IstekSikayet({super.key});

  @override
  State<IstekSikayet> createState() => _IstekSikayetState();
}

class _IstekSikayetState extends State<IstekSikayet> {
  final _formKey = GlobalKey<FormState>();
  final RequestService _requestService = RequestService();

  bool _isLoading = false;

  String _icerikTuru = 'BİLGİ';
  bool _bilgilerimiGizle = false;
  String? _secilenGun;
  String? _secilenAy;
  String? _secilenYil;
  String? _secilenIlce;
  bool _kvkkOnay = false;
  bool _captchaOnay = false;

  final List<String> _yillar = List.generate(2026 - 1920 + 1, (index) => (2026 - index).toString());
  final List<String> _aylar = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

  final List<String> _ilceler = [
    'ALADAĞ', 'CEYHAN', 'ÇUKUROVA', 'FEKE', 'İMAMOĞLU', 
    'KARAİSALI', 'KARATAŞ', 'KOZAN', 'POZANTI', 'SAİMBEYLİ', 
    'SARIÇAM', 'SEYHAN', 'TUFANBEYLİ', 'YUMURTALIK', 'YÜREĞİR'
  ];

  final TextEditingController _tcController = TextEditingController();
  final TextEditingController _adSoyadController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mahalleController = TextEditingController();
  final TextEditingController _caddeController = TextEditingController();
  final TextEditingController _secilenDisKapiController = TextEditingController();
  final TextEditingController _secilenIcKapiController = TextEditingController();
  final TextEditingController _ekAdresController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  List<String> _getGunler() {
    if (_secilenAy == null) {
      return List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
    }
    int gunSayisi = 31;
    switch (_secilenAy) {
      case 'Nisan':
      case 'Haziran':
      case 'Eylül':
      case 'Kasım':
        gunSayisi = 30;
        break;
      case 'Şubat':
        if (_secilenYil != null) {
          int yil = int.parse(_secilenYil!);
          if ((yil % 4 == 0 && yil % 100 != 0) || (yil % 400 == 0)) {
            gunSayisi = 29;
          } else {
            gunSayisi = 28;
          }
        } else {
          gunSayisi = 28;
        }
        break;
    }
    return List.generate(gunSayisi, (index) => (index + 1).toString().padLeft(2, '0'));
  }

  Future<void> _formuGonder() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_kvkkOnay) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen KVKK metnini onaylayın.')));
      return;
    }
    if (!_captchaOnay) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen reCAPTCHA doğrulamasını yapın.')));
      return;
    }

    setState(() => _isLoading = true);

    String dogumTarihi = "${_secilenYil ?? ''}-${_secilenAy ?? ''}-${_secilenGun ?? ''}";

    final yeniTalep = IstekSikayetModel(
      icerikTuru: _icerikTuru,
      tcNo: _tcController.text.trim(),
      dogumTarihi: dogumTarihi,
      adSoyad: _adSoyadController.text.trim(),
      telefon: _telefonController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      bilgileriGizle: _bilgilerimiGizle,
      ilce: _secilenIlce ?? '',
      mahalle: _mahalleController.text.trim(), // Değer doğrudan textfield'dan alınıyor
      caddeSokak: _caddeController.text.trim(), // Değer doğrudan textfield'dan alınıyor
      disKapiNo: _secilenDisKapiController.text.trim().isEmpty ? null : _secilenDisKapiController.text.trim(),
      icKapiNo: _secilenIcKapiController.text.trim().isEmpty ? null : _secilenIcKapiController.text.trim(),
      ekAdres: _ekAdresController.text.trim().isEmpty ? null : _ekAdresController.text.trim(),
      aciklama: _aciklamaController.text.trim(),
    );

    bool basariliMi = await _requestService.gonderIstekSikayet(
      veri: yeniTalep.toJson(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (basariliMi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form başarıyla gönderildi!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form gönderilirken bir hata oluştu.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _tcController.dispose();
    _adSoyadController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    _mahalleController.dispose();
    _caddeController.dispose();
    _secilenDisKapiController.dispose();
    _secilenIcKapiController.dispose();
    _ekAdresController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 28),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('İSTEK ŞİKAYET', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                  child: Column(
                    children: [
                      _buildSectionTitle('İçerik Türü', zorunlu: true),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildRadioTile('BİLGİ', Icons.info_outline),
                          _buildRadioTile('TALEP', Icons.help_outline),
                          _buildRadioTile('TEŞEKKÜR', Icons.front_hand_outlined),
                          _buildRadioTile('ŞİKAYET', Icons.error_outline),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Kişisel Bilgiler', altCizgi: true),
                      const SizedBox(height: 12),

                      _buildFormRow(
                        label: 'TC Kimlik No',
                        zorunlu: true,
                        child: _buildTextFormField(_tcController, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null),
                      ),
                      _buildFormRow(
                        label: 'Doğum Tarihi',
                        zorunlu: true,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSimpleDropdown('Gün', _getGunler(), _secilenGun, (v) => setState(() => _secilenGun = v)),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _buildSimpleDropdown('Ay', _aylar, _secilenAy, (v) {
                                setState(() {
                                  _secilenAy = v;
                                  if (_secilenGun != null && !_getGunler().contains(_secilenGun)) {
                                    _secilenGun = null;
                                  }
                                });
                              }),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _buildSimpleDropdown('Yıl', _yillar, _secilenYil, (v) {
                                setState(() {
                                  _secilenYil = v;
                                  if (_secilenAy == 'Şubat' && _secilenGun != null && !_getGunler().contains(_secilenGun)) {
                                    _secilenGun = null;
                                  }
                                });
                              }),
                            ),
                          ],
                        ),
                      ),
                      _buildFormRow(
                        label: 'Ad Soyad',
                        zorunlu: true,
                        child: _buildTextFormField(_adSoyadController, validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null),
                      ),
                      _buildFormRow(
                        label: 'Cep Telefonu',
                        zorunlu: true,
                        child: _buildTextFormField(_telefonController, hint: '(___) ___ __ __', keyboardType: TextInputType.phone, validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null),
                      ),
                      _buildFormRow(
                        label: 'E-Mail',
                        child: _buildTextFormField(_emailController, keyboardType: TextInputType.emailAddress),
                      ),
                      _buildFormRow(
                        label: 'Bilgilerimi Gizle',
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Checkbox(
                            value: _bilgilerimiGizle,
                            activeColor: Colors.blue,
                            onChanged: (bool? value) => setState(() => _bilgilerimiGizle = value ?? false),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Talep / Şikayet Adres Bilgileri', altCizgi: true),
                      const SizedBox(height: 12),

                      _buildFormRow(
                        label: 'İlçe',
                        zorunlu: true,
                        child: _buildFormDropdown(_ilceler, _secilenIlce, (v) {
                          setState(() {
                            _secilenIlce = v;
                          });
                        }),
                      ),
                      _buildFormRow(
                        label: 'Mahalle',
                        zorunlu: true,
                        child: _buildTextFormField(
                          _mahalleController, 
                          hint: 'Mahalle adını yazınız',
                          validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null
                        ),
                      ),
                      _buildFormRow(
                        label: 'Cadde/ Sokak',
                        zorunlu: true,
                        child: _buildTextFormField(
                          _caddeController, 
                          hint: 'Cadde veya sokak adını yazınız',
                          validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null
                        ),
                      ),
                      _buildFormRow(
                        label: 'Dış Kapı No',
                        child: _buildTextFormField(_secilenDisKapiController, keyboardType: TextInputType.number),
                      ),
                      _buildFormRow(
                        label: 'İç Kapı No',
                         child: _buildTextFormField(_secilenIcKapiController, keyboardType: TextInputType.text),
                      ),
                      _buildFormRow(
                        label: 'Ek Adres',
                        child: _buildTextFormField(_ekAdresController, maxLines: 2),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('İçerik Bilgileri', altCizgi: true),
                      const SizedBox(height: 12),

                      _buildFormRow(
                        label: 'Açıklama',
                        zorunlu: true,
                        child: _buildTextFormField(_aciklamaController, maxLines: 5, validator: (v) => v == null || v.isEmpty ? 'Açıklama boş bırakılamaz' : null),
                      ),
                      const Divider(color: Color(0xFFEEEEEE), height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _kvkkOnay,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (v) => setState(() => _kvkkOnay = v ?? false),
                          ),
                          const Text('KVKK AYDINLATMA METNİ', style: TextStyle(color: Color(0xFF3A9AD4), fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: Container(
                          width: 290,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFF9F9F9), border: Border.all(color: const Color(0xFFD3D3D3)), borderRadius: BorderRadius.circular(3)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(value: _captchaOnay, onChanged: (v) => setState(() => _captchaOnay = v ?? false)),
                                  const Text('Ben robot değilim', style: TextStyle(fontSize: 14, color: Colors.black)),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/RecaptchaLogo.svg/1200px-RecaptchaLogo.svg.png', height: 28, errorBuilder: (c, o, s) => const Icon(Icons.refresh, color: Colors.grey)),
                                  const Text('reCAPTCHA', style: TextStyle(fontSize: 8, color: Colors.grey)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _formuGonder,
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Gönder', style: TextStyle(fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6BA4E0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, {bool zorunlu = false, bool altCizgi = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
            if (zorunlu) const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        if (altCizgi) ...[const SizedBox(height: 4), const Divider(color: Colors.grey, thickness: 1.5)]
      ],
    );
  }

  Widget _buildFormRow({required String label, bool zorunlu = false, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Row(
              children: [
                Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF555555), fontSize: 13))),
                if (zorunlu) const Text('* ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, {String? hint, TextInputType keyboardType = TextInputType.text, int maxLines = 1, FormFieldValidator<String>? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFCCCCCC)), borderRadius: BorderRadius.circular(2)),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFCCCCCC)), borderRadius: BorderRadius.circular(2)),
        isDense: true,
      ),
    );
  }

  Widget _buildFormDropdown(List<String> items, String? selectedValue, ValueChanged<String?> onChanged, {String? disabledHint}) {
    return DropdownButtonFormField<String>(
      value: items.contains(selectedValue) ? selectedValue : null,
      isExpanded: true,
      disabledHint: Text(disabledHint ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
      menuMaxHeight: 260,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
      style: const TextStyle(fontSize: 14, color: Colors.black),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        border: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFCCCCCC)), borderRadius: BorderRadius.circular(2)),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFCCCCCC)), borderRadius: BorderRadius.circular(2)),
        isDense: true,
      ),
      items: items.isEmpty 
          ? null 
          : items.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      validator: (v) => v == null ? 'Seçim yapınız' : null,
    );
  }

  Widget _buildSimpleDropdown(String hint, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      isExpanded: true,
      menuMaxHeight: 200,
      icon: const Icon(Icons.unfold_more, color: Colors.grey, size: 18),
      style: const TextStyle(fontSize: 13, color: Colors.black),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 6),
        border: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFCCCCCC)), borderRadius: BorderRadius.circular(2)),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFCCCCCC)), borderRadius: BorderRadius.circular(2)),
        isDense: true,
      ),
      items: items.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? '!' : null,
    );
  }

  Widget _buildRadioTile(String value, IconData icon) {
    bool isSelected = _icerikTuru == value;
    return InkWell(
      onTap: () => setState(() => _icerikTuru = value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: Colors.blue, size: 20),
          const SizedBox(width: 4),
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        ],
      ),
    );
  }
}