class WeatherModel {
  final String city;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.humidity,
  });
}