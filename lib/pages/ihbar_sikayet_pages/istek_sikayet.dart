import 'package:flutter/material.dart';

class IstekSikayet extends StatefulWidget {
  const IstekSikayet({super.key});

  @override
  State<IstekSikayet> createState() => _IstekSikayetState();
}

class _IstekSikayetState extends State<IstekSikayet> {
  final _formKey = GlobalKey<FormState>();

  String _icerikTuru = 'BİLGİ';
  bool _bilgilerimiGizle = false;
  String? _secilenGun;
  String? _secilenAy;
  String? _secilenYil;
  String? _secilenIlce;
  String? _secilenMahalle;
  
  final List<String> _ilceler = [
    'ALADAĞ', 'CEYHAN', 'ÇUKUROVA', 'FEKE', 'İMAMOĞLU', 
    'KARAİSALI', 'KARATAŞ', 'KOZAN', 'POZANTI', 'SAİMBEYLİ', 
    'SARIÇAM', 'SEYHAN', 'TUFENBEYLİ', 'YUMURTALIK', 'YÜREĞİR'
  ];

  final Map<String, List<String>> _mahallelerMap = {
    'ALADAĞ': ['AKÖREN', 'AKPINAR', 'BAŞPINAR', 'BOZTAHTA', 'BÜYÜKSOFULU', 'CERİTLER', 'DAİLER', 'DARILIK', 'DÖLEKLİ', 'EBRİŞİM', 'EĞNER', 'GERDİBİ', 'GİREĞİYENİKÖY', 'GÖKÇEKÖY', 'KABASAKAL', 'KARAHAN', 'KICAK', 'KIŞLAK', 'KIZILDAM', 'KÖKEZ', 'KÖPRÜCÜK', 'KÜP', 'MEDENLİ', 'MANSURLU', 'MAZILIK', 'POSYAĞBASAN', 'SİNANPAŞA', 'TOPALLI', 'UZUNKUYU', 'YETİMLİ', 'YÜKSEKÖREN'],
    'CEYHAN': ['ADAPINAR', 'ADATEPE', 'AĞAÇLI', 'AĞAÇPINAR', 'AKDAM', 'ALTIGÖZBEKİRLİ', 'ALTIKARA', 'ALTIOCAK', 'ATATÜRK', 'AYDEMİROĞLU', 'AYDINLAR', 'AZİZLİ', 'BAŞÖREN', 'BELEDİYE EVLERİ', 'BİRKENT', 'BOTA', 'BURHANİYE', 'BURHANLI', 'BÜYÜKBURHANİYE', 'BÜYÜKKIRIM', 'BÜYÜKMANGIT', 'ÇAKALDERE', 'CAMUZAĞILI', 'ÇATAKLI', 'ÇATALHÜYÜK', 'ÇEVRETEPE', 'CEYHANBEKİRLİ', 'ÇİÇEKLİ', 'ÇİFTLİKLER', 'CİVANTAYAK', 'ÇOKÇAPINAR', 'CUMHURİYET', 'DAĞISTAN', 'DEĞİRMENDERE', 'DEĞİRMENLİ', 'DİKİLİTAŞ', 'DOKUZTEKNE', 'DORUK', 'DURHASANDEDE', 'DUTLUPINAR', 'EKİNYAZI', 'ELMAGÖLÜ', 'EMEK', 'ERENLER', 'ESENTEPE', 'FATİH SULTAN MEHMET', 'GAZİ OSMAN PAŞA', 'GÜMÜRDÜLÜ', 'GÜNDOĞAN', 'GÜNLÜCE', 'HAMDİLLİ', 'HAMİDİYE', 'HAMİTBEY', 'HAMİTBEYBUCAĞI', 'HÜRRİYET', 'İMRAN', 'İNCEYER', 'İNÖNÜ', 'IRMAKLI', 'İSALI', 'ISIRGANLI', 'İSTİKLAL', 'KARAKAYALI', 'KELEMETİ', 'KILIÇKAYA', 'KIVRIKLI', 'KIZILDERE', 'KONAKOĞLU', 'KÖPRÜLÜ', 'KÖRKUYU', 'KORUKLU', 'KÖRSELİ', 'KÜÇÜKBURHANİYE', 'KÜÇÜKKIRIM', 'KÜÇÜKMANGIT', 'KURTKULAĞI', 'KURTPINAR', 'KUZUCAK', 'MERCİMEK', 'MERCİN', 'MİTHAT PAŞA', 'MODERNEVLER', 'MURADİYE', 'MUSTAFABEYLİ', 'NAMIK KEMAL', 'NARLIK', 'NAZIMBEY YENİKÖY', 'SAĞIRLAR', 'SAĞKAYA', 'ŞAHİN ÖZBİLEN', 'SARIBAHÇE', 'SARIMAZI', 'SARIMAZI SB', 'SARISAKAL', 'ŞEHİT HACI İBRAHİM', 'SELİMİYE', 'SİRKELİ', 'SOĞUKPINAR', 'SOYSALLI', 'TATARLI', 'TATLIKUYU', 'TOKTAMIŞ', 'TUMLU', 'ÜÇDUTYEŞİLOVA', 'ULUS', 'VEYSİYE', 'YALAK', 'YARSUAT', 'YELLİBEL', 'YEŞİLBAHÇE', 'YEŞİLDAM', 'YILANKALE', 'ZÜBEYDE HANIM'],
    'ÇUKUROVA': ['Güzelyalı Mah.', 'Toros Mah.', 'Kenan Evren Mah.', 'Yurt Mah.'],
    'FEKE': ['İslam Mah.', 'Karacaoğlan Mah.'],
    'İMAMOĞLU': ['Fatih Mah.', 'Cumhuriyet Mah.'],
    'KARAİSALI': ['Karapınar Mah.', 'Selampınar Mah.'],
    'KARATAŞ': ['Kemaliye Mah.', 'Karşıyaka Mah.'],
    'KOZAN': ['Tufanpaşa Mah.', 'Arslanpaşa Mah.'],
    'POZANTI': ['Zafer Mah.', 'İstiklal Mah.'],
    'SAİMBEYLİ': ['İslam Mah.', 'Yeşilbağ Mah.'],
    'SARIÇAM': ['Mehmet Akif Ersoy Mah.', 'Beyceli Mah.'],
    'SEYHAN': ['Baraj Mah.', 'Reşatbey Mah.', 'Gazipaşa Mah.', 'Ziyapaşa Mah.'],
    'TUFENBEYLİ': ['Merkez Mah.', 'Cumhuriyet Mah.'],
    'YUMURTALIK': ['Ayas Mah.', 'Devlet Mah.'],
    'YÜREĞİR': ['Akıncılar Mah.', 'Yavuzlar Mah.', 'Serinevler Mah.'],
  };

  String? _secilenCadde;
  String? _secilenDisKapi;
  String? _secilenIcKapi;
  bool _kvkkOnay = false;
  bool _captchaOnay = false;
  String? _secilenFotoAdi;
  String? _secilenDosyaAdi;

  final TextEditingController _tcController = TextEditingController();
  final TextEditingController _adSoyadController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ekAdresController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String> aktifMahalleler = _secilenIlce != null ? (_mahallelerMap[_secilenIlce] ?? []) : [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 28),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          'İSTEK ŞİKAYET',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- İÇERİK TÜRÜ ---
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
                  child: _buildTextField(_tcController, keyboardType: TextInputType.number),
                ),
                _buildFormRow(
                  label: 'Doğum Tarihi',
                  zorunlu: true,
                  child: Row(
                    children: [
                      Expanded(child: _buildSimpleDropdown('Gün', ['01', '02', '03', '04' , '05'], _secilenGun, (v) => setState(() => _secilenGun = v))),
                      const SizedBox(width: 4),
                      Expanded(child: _buildSimpleDropdown('Ay', ['Ocak', 'Şubat', ''], _secilenAy, (v) => setState(() => _secilenAy = v))),
                      const SizedBox(width: 4),
                      Expanded(child: _buildSimpleDropdown('Yıl', ['2000', '2001'], _secilenYil, (v) => setState(() => _secilenYil = v))),
                    ],
                  ),
                ),
                _buildFormRow(
                  label: 'Ad Soyad',
                  zorunlu: true,
                  child: _buildTextField(_adSoyadController),
                ),
                _buildFormRow(
                  label: 'Cep Telefonu',
                  zorunlu: true,
                  child: _buildTextField(_telefonController, hint: '(___) ___ __ __', keyboardType: TextInputType.phone),
                ),
                _buildFormRow(
                  label: 'E-Mail',
                  child: _buildTextField(_emailController, keyboardType: TextInputType.emailAddress),
                ),
                _buildFormRow(
                  label: 'Bilgilerimi Gizle',
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Checkbox(
                      value: _bilgilerimiGizle,
                      activeColor: Colors.blue,
                      onChanged: (bool? value) {
                        setState(() {
                          _bilgilerimiGizle = value ?? false;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- ADRES BİLGİLERİ ---
                _buildSectionTitle('Talep / Şikayet Adres Bilgileri', altCizgi: true),
                const SizedBox(height: 12),

                _buildFormRow(
                  label: 'İlçe',
                  zorunlu: true,
                  child: _buildFormDropdown(_ilceler, _secilenIlce, (v) {
                    setState(() {
                      _secilenIlce = v;
                      _secilenMahalle = null;
                    });
                  }),
                ),
                _buildFormRow(
                  label: 'Mahalle',
                  zorunlu: true,
                  child: _buildFormDropdown(aktifMahalleler, _secilenMahalle, (v) => setState(() => _secilenMahalle = v), disabledHint: 'Önce İlçe Seçiniz'),
                ),
                _buildFormRow(
                  label: 'Cadde/ Sokak',
                  zorunlu: true,
                  child: _buildFormDropdown(['İstasyon Cad.', 'Sivas Cad.'], _secilenCadde, (v) => setState(() => _secilenCadde = v)),
                ),
                _buildFormRow(
                  label: 'Dış Kapı No',
                  child: _buildFormDropdown(['1', '2', '3'], _secilenDisKapi, (v) => setState(() => _secilenDisKapi = v)),
                ),
                _buildFormRow(
                  label: 'İç Kapı No',
                  child: _buildFormDropdown(['A', 'B', 'C'], _secilenIcKapi, (v) => setState(() => _secilenIcKapi = v)),
                ),
                _buildFormRow(
                  label: 'Ek Adres',
                  child: _buildTextField(_ekAdresController, maxLines: 2),
                ),
                const SizedBox(height: 24),

                // --- YENİ EKLENEN: İÇERİK BİLGİLERİ ---
                _buildSectionTitle('İçerik Bilgileri', altCizgi: true),
                const SizedBox(height: 12),

                // Açıklama Alanı
                _buildFormRow(
                  label: 'Açıklama',
                  zorunlu: true,
                  child: _buildTextField(_aciklamaController, maxLines: 5),
                ),
                const Divider(color: Color(0xFFEEEEEE), height: 1),

                // Fotoğraf Yükle
                _buildFormRow(
                  label: 'Fotoğraf Yükle',
                  child: InkWell(
                    onTap: () => setState(() => _secilenFotoAdi = "fotograf_1.jpg"),
                    child: Row(
                      children: [
                        const Icon(Icons.image, color: Colors.grey, size: 28),
                        if (_secilenFotoAdi != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(_secilenFotoAdi!, style: const TextStyle(fontSize: 12, color: Colors.green)),
                          )
                      ],
                    ),
                  ),
                ),
                const Divider(color: Color(0xFFEEEEEE), height: 1),

                // Dosya Yükle
                _buildFormRow(
                  label: 'Dosya Yükle',
                  child: InkWell(
                    onTap: () => setState(() => _secilenDosyaAdi = "belge.pdf"),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file, color: Colors.grey, size: 28),
                        if (_secilenDosyaAdi != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(_secilenDosyaAdi!, style: const TextStyle(fontSize: 12, color: Colors.green)),
                          )
                      ],
                    ),
                  ),
                ),
                const Divider(color: Color(0xFFEEEEEE), height: 24),

                // KVKK Aydınlatma Metni Checkbox'ı (Görseldeki gibi ortalanmış)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _kvkkOnay,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (v) => setState(() => _kvkkOnay = v ?? false),
                    ),
                    const Text(
                      'KVKK AYDINLATMA METNİ',
                      style: TextStyle(color: Color(0xFF3A9AD4), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // reCAPTCHA Tasarımı
                Center(
                  child: Container(
                    width: 290,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      border: Border.all(color: const Color(0xFFD3D3D3)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _captchaOnay,
                              onChanged: (v) => setState(() => _captchaOnay = v ?? false),
                            ),
                            const Text(
                              'Ben robot değilim',
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/RecaptchaLogo.svg/1200px-RecaptchaLogo.svg.png',
                              height: 28,
                              errorBuilder: (c, o, s) => const Icon(Icons.refresh, color: Colors.grey),
                            ),
                            const Text('reCAPTCHA', style: TextStyle(fontSize: 8, color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Gönder Butonu (Görseldeki gibi Sağa Yaslı ve Mavi)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _kvkkOnay && _captchaOnay) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Form başarıyla gönderildi!')),
                        );
                      }
                    },
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Gönder', style: TextStyle(fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6BA4E0), // Görseldeki açık mavi tonu
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

  // Önceki fonksiyonel şablonlar aynen korunuyor...
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

  Widget _buildTextField(TextEditingController controller, {String? hint, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Container(
      height: maxLines == 1 ? 38 : null,
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFCCCCCC)), borderRadius: BorderRadius.circular(2)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildFormDropdown(List<String> items, String? selectedValue, ValueChanged<String?> onChanged, {String? disabledHint}) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          disabledHint: Text(disabledHint ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          menuMaxHeight: 260,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          items: items.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: items.isEmpty ? null : onChanged,
        ),
      ),
    );
  }

  Widget _buildSimpleDropdown(String hint, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFCCCCCC)), borderRadius: BorderRadius.circular(2)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          isExpanded: true,
          menuMaxHeight: 200,
          icon: const Icon(Icons.unfold_more, color: Colors.grey, size: 18),
          items: items.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
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