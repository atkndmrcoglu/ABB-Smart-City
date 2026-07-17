class IstekSikayetModel {
  final String icerikTuru;
  final String tcNo;
  final String dogumTarihi;
  final String adSoyad;
  final String telefon;
  final String? email;
  final bool bilgileriGizle;
  final String ilce;
  final String mahalle;
  final String caddeSokak;
  final String? disKapiNo;
  final String? icKapiNo;
  final String? ekAdres;
  final String aciklama;

  IstekSikayetModel({
    required this.icerikTuru,
    required this.tcNo,
    required this.dogumTarihi,
    required this.adSoyad,
    required this.telefon,
    this.email,
    required this.bilgileriGizle,
    required this.ilce,
    required this.mahalle,
    required this.caddeSokak,
    this.disKapiNo,
    this.icKapiNo,
    this.ekAdres,
    required this.aciklama,
  });

  // JSON'dan nesneye (Gerekirse sunucudan okumak için)
  factory IstekSikayetModel.fromJson(Map<String, dynamic> json) {
    return IstekSikayetModel(
      icerikTuru: json['icerik_turu']?.toString() ?? 'BİLGİ',
      tcNo: json['tc_no']?.toString() ?? '',
      dogumTarihi: json['dogum_tarihi']?.toString() ?? '',
      adSoyad: json['ad_soyad']?.toString() ?? '',
      telefon: json['telefon']?.toString() ?? '',
      email: json['email']?.toString(),
      bilgileriGizle: _toBool(json['bilgileri_gizle']),
      ilce: json['ilce']?.toString() ?? '',
      mahalle: json['mahalle']?.toString() ?? '',
      caddeSokak: json['cadde_sokak']?.toString() ?? '',
      disKapiNo: json['dis_kapi_no']?.toString(),
      icKapiNo: json['ic_kapi_no']?.toString(),
      ekAdres: json['ek_adres']?.toString(),
      aciklama: json['aciklama']?.toString() ?? '',
    );
  }

  // Nesneden JSON'a (Sunucuya veri gönderirken çok işinize yarar)
  Map<String, String> toJson() {
    return {
      'icerik_turu': icerikTuru,
      'tc_no': tcNo,
      'dogum_tarihi': dogumTarihi,
      'ad_soyad': adSoyad,
      'telefon': telefon,
      'email': email ?? '',
      'bilgileri_gizle': bilgileriGizle ? '1' : '0',
      'ilce': ilce,
      'mahalle': mahalle,
      'cadde_sokak': caddeSokak,
      'dis_kapi_no': disKapiNo ?? '',
      'ic_kapi_no': icKapiNo ?? '',
      'ek_adres': ekAdres ?? '',
      'aciklama': aciklama,
    };
  }

  // Güvenli bool dönüşüm yardımcısı (0/1 veya "0"/"1" değerlerini bool yapar)
  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }
}