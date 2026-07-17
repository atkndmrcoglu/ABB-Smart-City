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

      // 1. Anlık hava durumunu çek
      final Weather current = await wf.currentWeatherByCityName(_targetCity);

      // 2. 5 günlük ham tahmini çek (40 adet 3 saatlik veri)
      final List<Weather> rawWeekly = await wf.fiveDayForecastByCityName(_targetCity);

      // --- AKILLI AYRIŞTIRMA (Günün En Yüksek Sıcaklığını Seçme) ---
      final Map<String, Weather> dailyBestForecast = {};

      for (var forecast in rawWeekly) {
        if (forecast.date != null) {
          // Tarihi "YYYY-MM-DD" formatında grup anahtarı yapıyoruz
          String dateKey = "${forecast.date!.year}-${forecast.date!.month}-${forecast.date!.day}";
          double currentTemp = forecast.temperature?.celsius ?? -999.0;

          if (!dailyBestForecast.containsKey(dateKey)) {
            // Eğer o gün henüz eklenmediyse ilk veriyi kaydet
            dailyBestForecast[dateKey] = forecast;
          } else {
            // Eğer o gün zaten varsa, hangisinin sıcaklığı daha yüksekse (gündüz vakti) onu tut
            double existingTemp = dailyBestForecast[dateKey]!.temperature?.celsius ?? -999.0;
            if (currentTemp > existingTemp) {
              dailyBestForecast[dateKey] = forecast;
            }
          }
        }
      }

      // Map'teki en yüksek sıcaklıklı günleri listeye çevirip ilk 5 günü alıyoruz
      final List<Weather> filteredWeekly = dailyBestForecast.values.toList();
      
      // Günleri kronolojik sıraya diziyoruz (Bugünden geleceğe)
      filteredWeekly.sort((a, b) => a.date!.compareTo(b.date!));

      // Sadece 5 günü sınırla
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