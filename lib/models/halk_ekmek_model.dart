class HalkEkmekBufe {
  final String kod;
  final String adres;
  final double lat;
  final double lon;

  HalkEkmekBufe({
    required this.kod,
    required this.adres,
    required this.lat,
    required this.lon,
  });

  factory HalkEkmekBufe.fromJson(Map<String, dynamic> json) {
    return HalkEkmekBufe(
      kod: json['isim'] ?? 'Halk Ekmek Büfesi',
      adres: json['adres'] ?? 'Adres bilgisi yok',
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
    );
  }
}