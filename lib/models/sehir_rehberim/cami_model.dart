class CamiModel {
  final String ad;
  final double lat;
  final double lon;

  CamiModel({
    required this.ad,
    required this.lat,
    required this.lon,
  });

  factory CamiModel.fromJson(Map<String, dynamic> json) {
    return CamiModel(
      ad: json['ad']?.toString() ?? 'Cami',
      lat: _toDouble(json['lat']),
      lon: _toDouble(json['lon']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}