class HalkEkmekModel{
  final String kod;
  final String adres;
  final double lat;
  final double lon;

  HalkEkmekModel({
    required this.kod,
    required this.adres,
    required this.lat,
    required this.lon,
  });

  factory HalkEkmekModel.fromJson(Map<String, dynamic> json) {
    return HalkEkmekModel(
      kod: json['isim'] ?? 'Halk Ekmek Büfesi',
      adres: json['adres'] ?? 'Adres bilgisi yok',
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
    );
  }
}