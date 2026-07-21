import 'package:latlong2/latlong.dart';
class MetroStation {
  final int id;
  final String stationName;
  final int stationOrder;
  final double latitude;
  final double longitude;

  MetroStation({
    required this.id,
    required this.stationName,
    required this.stationOrder,
    required this.latitude,
    required this.longitude,
  });

  LatLng get koordinat => LatLng(latitude, longitude);

  factory MetroStation.fromJson(Map<String, dynamic> json) {
    return MetroStation(
      id: int.parse(json['id'].toString()),
      stationName: json['station_name'] ?? '', 
      stationOrder: int.parse((json['station_order'] ?? 0).toString()),
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
    );
  }
}

class MetroSchedule {
  final int id;
  final int stationId;
  final String departureTime;
  final String directionType;
  final String dayType; 

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
      directionType: json['direction_type'] ?? '',
      dayType: json['day_type'] ?? '',
    );
  }
}