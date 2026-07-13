class WifiNoktasi {
  final int? id;
  final String isim;
  final double lat;
  final double lon;

  WifiNoktasi({
    this.id,
    required this.isim,
    required this.lat,
    required this.lon,
  });

  factory WifiNoktasi.fromJson(Map<String, dynamic> json) {
    return WifiNoktasi(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      isim: json['isim'] ?? '',
      lat: json['lat'] is String ? double.parse(json['lat']) : (json['lat'] as num).toDouble(),
      lon: json['lon'] is String ? double.parse(json['lon']) : (json['lon'] as num).toDouble(),
    );
  }
}