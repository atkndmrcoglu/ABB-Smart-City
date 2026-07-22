class BankalarModel {
  final String isim;
  final double lat;
  final double lon;

  BankalarModel({
    required this.isim,
    required this.lat,
    required this.lon,
  });

  factory BankalarModel.fromJson(Map<String, dynamic> json) {
    return BankalarModel(
      isim: json['isim'] ?? '',
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