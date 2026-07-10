import 'package:latlong2/latlong.dart';

class Durak {
  final String id;
  final String isim;
  final LatLng koordinat;
  List<String> hatlar; // Duraktan geçen hatlar

  Durak({
    required this.id,
    required this.isim,
    required this.koordinat,
    this.hatlar = const [],
  });

  factory Durak.fromJson(Map<String, dynamic> json) {
    final stopId = json['stop_id'];
    final stopName = json['stop_name'];
    final stopLat = json['stop_lat'];
    final stopLon = json['stop_lon'];
    
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
      hatlar: [], // Başlangıçta boş, sonra doldurulacak
    );
  }
  
  // Duraktan geçen hatları ekle
  Durak copyWith({List<String>? hatlar}) {
    return Durak(
      id: id,
      isim: isim,
      koordinat: koordinat,
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
    
    return Hat(
      routeId: routeId?.toString() ?? '',
      routeShortName: routeShortName?.toString() ?? 'Bilinmeyen',
      routeLongName: routeLongName?.toString() ?? 'Hat',
      shapeId: shapeId != null && shapeId.toString() != 'null' ? shapeId.toString() : '',
      tripId: tripId != null && tripId.toString() != 'null' ? tripId.toString() : '',
    );
  }
  
  bool get isValid {
    return routeId.isNotEmpty && 
           tripId.isNotEmpty && 
           shapeId.isNotEmpty && 
           tripId != 'null' && 
           shapeId != 'null';
  }
}

class RotaNoktasi {
  final LatLng koordinat;

  RotaNoktasi({
    required this.koordinat,
  });

  factory RotaNoktasi.fromJson(Map<String, dynamic> json) {
    final lat = json['shape_pt_lat'] ?? json['lat'];
    final lon = json['shape_pt_lon'] ?? json['lon'];
    
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