class Eczane {
  final String isim;
  final String telefon;
  final String adres;
  final String ilce;
  final double lat;
  final double lon;
  final bool nobetcimi;

  Eczane({
    required this.isim,
    required this.telefon,
    required this.adres,
    required this.ilce,
    required this.lat,
    required this.lon,
    this.nobetcimi = true,
  });

  factory Eczane.fromJson(Map<String, dynamic> json) {
    return Eczane(
      isim: json['name'] ?? json['eczane_adi'] ?? '',
      telefon: json['phone'] ?? json['telefon'] ?? '',
      adres: json['address'] ?? json['adres'] ?? '',
      ilce: json['dist'] ?? json['ilce'] ?? '',
      // Gelen string veya int değerleri güvenli bir şekilde double'a çeviriyoruz
      lat: double.tryParse(json['loc']?.split(',')[0] ?? json['lat']?.toString() ?? '36.9931') ?? 36.9931,
      lon: double.tryParse(json['loc']?.split(',')[1] ?? json['lon']?.toString() ?? '35.3256') ?? 35.3256,
    );
  }
}