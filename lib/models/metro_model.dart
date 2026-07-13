import 'package:latlong2/latlong.dart';

// 1. STATIONS TABLOSU MODELİ
class MetroStation {
  final int id;
  final String stationName; // Veritabanındaki 'station_name' ile eşleşti
  final int stationOrder;  // Veritabanındaki 'station_order' ile eşleşti
  final double latitude;
  final double longitude;

  MetroStation({
    required this.id,
    required this.stationName,
    required this.stationOrder,
    required this.latitude,
    required this.longitude,
  });

  // Haritada kullanmak için getter
  LatLng get koordinat => LatLng(latitude, longitude);

  factory MetroStation.fromJson(Map<String, dynamic> json) {
    return MetroStation(
      id: int.parse(json['id'].toString()),
      stationName: json['station_name'] ?? '', // SQL'den gelen kolon ismi
      stationOrder: int.parse((json['station_order'] ?? 0).toString()),
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
    );
  }
}

// 2. METRO_SCHEDULES TABLOSU MODELİ
class MetroSchedule {
  final int id;
  final int stationId;
  final String departureTime;
  final String directionType; // Veritabanındaki 'direction_type'
  final String dayType;       // Veritabanındaki 'day_type'

  MetroSchedule({
    required this.id,
    required this.stationId,
    required this.departureTime,
    required this.directionType,
    required this.dayType,
  });

  factory MetroSchedule.fromJson(Map<String, dynamic> json) {
    return MetroSchedule(
      id: int.parse(json['id'].toString()),
      stationId: int.parse(json['station_id'].toString()),
      departureTime: json['departure_time'] ?? '',
      directionType: json['direction_type'] ?? '', // SQL'den gelen kolon ismi
      dayType: json['day_type'] ?? '',             // SQL'den gelen kolon ismi
    );
  }
}