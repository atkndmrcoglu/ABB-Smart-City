import 'package:latlong2/latlong.dart';

class Durak {
  final String id;
  final String isim;
  final LatLng koordinat;
  final List<String> hatlar;

  Durak({
    required this.id,
    required this.isim,
    required this.koordinat,
    this.hatlar = const [],
  });

  factory Durak.fromJson(Map<String, dynamic> json) {
    final stopId = json['stop_id'];
    final stopName = json['stop_name'];
    final stopLat = json['stop_lat'] ?? json['lat'];
    final stopLon = json['stop_lon'] ?? json['lon']; 
    
    double lat = 0.0;
    double lon = 0.0;
    
    if (stopLat != null) {
      lat = double.tryParse(stopLat.toString()) ?? 0.0;
    }
    if (stopLon != null) {
      lon = double.tryParse(stopLon.toString()) ?? 0.0;
    }
    
    return Durak(
      id: stopId?.toString() ?? '',
      isim: stopName?.toString() ?? 'Bilinmeyen Durak',
      koordinat: LatLng(lat, lon),
      hatlar: const [], // Başlangıçta boş, servis katmanında doldurulacak
    );
  }
  
  // Duraktan geçen hatları güncellemek için copyWith metodu
  Durak copyWith({
    String? id,
    String? isim,
    LatLng? koordinat,
    List<String>? hatlar,
  }) {
    return Durak(
      id: id ?? this.id,
      isim: isim ?? this.isim,
      koordinat: koordinat ?? this.koordinat,
      hatlar: hatlar ?? this.hatlar,
    );
  }
}

class Hat {
  final String routeId;
  final String routeShortName;
  final String routeLongName;
  final String shapeId;
  final String tripId;

  Hat({
    required this.routeId,
    required this.routeShortName,
    required this.routeLongName,
    required this.shapeId,
    required this.tripId,
  });

  factory Hat.fromJson(Map<String, dynamic> json) {
    final routeId = json['route_id'];
    final routeShortName = json['route_short_name'];
    final routeLongName = json['route_long_name'];
    final shapeId = json['shape_id'];
    final tripId = json['trip_id'];
    
    // Değerlerin null veya metinsel "null" olma durumlarını temizleyen yardımcı fonksiyon
    String parseString(dynamic value) {
      if (value == null || value.toString().trim().toLowerCase() == 'null') {
        return '';
      }
      return value.toString().trim();
    }

    return Hat(
      routeId: parseString(routeId),
      routeShortName: parseString(routeShortName).isEmpty ? 'Bilinmeyen' : parseString(routeShortName),
      routeLongName: parseString(routeLongName).isEmpty ? 'Hat' : parseString(routeLongName),
      shapeId: parseString(shapeId),
      tripId: parseString(tripId),
    );
  }
  
  bool get isValid {
    return routeId.isNotEmpty && 
           tripId.isNotEmpty && 
           shapeId.isNotEmpty;
  }
}

class RotaNoktasi {
  final LatLng koordinat;

  RotaNoktasi({
    required this.koordinat,
  });

  factory RotaNoktasi.fromJson(Map<String, dynamic> json) {
    // API'den gelebilecek farklı koordinat parametrelerine karşı esneklik sağlandı
    final lat = json['shape_pt_lat'] ?? json['lat'] ?? json['latitude'];
    final lon = json['shape_pt_lon'] ?? json['lon'] ?? json['longitude'];
    
    double latitude = 0.0;
    double longitude = 0.0;
    
    if (lat != null) {
      latitude = double.tryParse(lat.toString()) ?? 0.0;
    }
    if (lon != null) {
      longitude = double.tryParse(lon.toString()) ?? 0.0;
    }
    
    return RotaNoktasi(
      koordinat: LatLng(latitude, longitude),
    );
  }
}