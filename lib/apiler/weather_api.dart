import 'package:weather/weather.dart';

class AdanaWeatherData {
  final Weather current;
  final List<Weather> weekly;

  AdanaWeatherData({
    required this.current,
    required this.weekly,
  });
}

class WeatherApi {
  final String _apiKey = "770435898e33af3a489fd5950fdadcaf";
  final String _targetCity = "Adana";

  Future<AdanaWeatherData> fetchAdanaWeather() async {
    try {
      final WeatherFactory wf = WeatherFactory(_apiKey, language: Language.TURKISH);
      final Weather current = await wf.currentWeatherByCityName(_targetCity);
      final List<Weather> rawWeekly = await wf.fiveDayForecastByCityName(_targetCity);
      final Map<String, Weather> dailyBestForecast = {};

      for (var forecast in rawWeekly) {
        if (forecast.date != null) {
          String dateKey = "${forecast.date!.year}-${forecast.date!.month}-${forecast.date!.day}";
          double currentTemp = forecast.temperature?.celsius ?? -999.0;

          if (!dailyBestForecast.containsKey(dateKey)) {
            dailyBestForecast[dateKey] = forecast;
          } else {
            double existingTemp = dailyBestForecast[dateKey]!.temperature?.celsius ?? -999.0;
            if (currentTemp > existingTemp) {
              dailyBestForecast[dateKey] = forecast;
            }
          }
        }
      }

      final List<Weather> filteredWeekly = dailyBestForecast.values.toList();
      filteredWeekly.sort((a, b) => a.date!.compareTo(b.date!));
      final List<Weather> finalWeekly = filteredWeekly.take(5).toList();

      return AdanaWeatherData(
        current: current,
        weekly: finalWeekly,
      );
    } catch (e) {
      throw Exception("Adana hava durumu verisi alınamadı: $e");
    }
  }
}