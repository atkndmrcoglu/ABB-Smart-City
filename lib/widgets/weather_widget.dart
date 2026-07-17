import 'package:flutter/material.dart';
// open_weather takma adıyla import ederek isim çakışmalarını engelliyoruz
import 'package:weather/weather.dart' as open_weather; 
// Kendi yazdığımız api dosyasını import ediyoruz
import 'package:smartcity/apiler/weather_api.dart'; 

/// Adana'nın hava durumunu çeker ve yükleme durumuna göre dairesel popup gösterir.
void showCircularWeatherPopup(BuildContext context) {
  final WeatherApi weatherApi = WeatherApi();

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: 340,
          height: 340,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: FutureBuilder<AdanaWeatherData>(
              future: weatherApi.fetchAdanaWeather(),
              builder: (context, snapshot) {
                // 1. Durum: Veri yükleniyor
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  );
                }

                // 2. Durum: Hata oluştu (İnternet yoksa veya API'den veri dönmediyse)
                if (snapshot.hasError || !snapshot.hasData) {
                  print("WEATHER API HATASI: ${snapshot.error}"); 

                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          "Hata Oluştu",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Hata: ${snapshot.error ?? 'Veri bulunamadı'}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                // 3. Durum: Veri başarıyla geldi (API tarafında filtrelenmiş temiz 5 gün)
                final List<open_weather.Weather> uniqueDaysForecast = snapshot.data!.weekly;

                return PageView.builder(
                  itemCount: uniqueDaysForecast.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final dayData = uniqueDaysForecast[index];
                    return buildCircularWeatherPage(context, dayData, index + 1);
                  },
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

/// Popup içindeki her bir gün sayfasını çizen widget.
Widget buildCircularWeatherPage(BuildContext context, open_weather.Weather weather, int dayNumber) {
  final double temp = weather.temperature?.celsius ?? 0.0;
  final double feelsLike = weather.tempFeelsLike?.celsius ?? 0.0;
  final String cityName = weather.areaName ?? "Adana";
  final String condition = weather.weatherDescription ?? "Açık";

  // Tarihe göre dinamik gün ismini hesaplayan yardımcı fonksiyon
  String getDayTitle(DateTime? date, int dayNum) {
    if (dayNum == 1) return "BUGÜN";
    if (dayNum == 2) return "YARIN";
    if (date == null) return "";

    switch (date.weekday) {
      case DateTime.monday:
        return "PAZARTESİ";
      case DateTime.tuesday:
        return "SALI";
      case DateTime.wednesday:
        return "ÇARŞAMBA";
      case DateTime.thursday:
        return "PERŞEMBE";
      case DateTime.friday:
        return "CUMA";
      case DateTime.saturday:
        return "CUMARTESİ";
      case DateTime.sunday:
        return "PAZAR";
      default:
        return "";
    }
  }

  final String dayTitle = getDayTitle(weather.date, dayNumber);

  return Padding(
    padding: const EdgeInsets.all(32.0), // Atakan Demircioğlu Tarafından Adana Büyükşehir Belediyesi Bilgi İşlem Dairesi Başkanlığı için 2026 Yılında Geliştirilmiştir
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dinamik olarak hesaplanan gün başlığı (BUGÜN, YARIN, CUMA vb.)
        Text(
          dayTitle,
          style: const TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w600, 
            color: Colors.blueAccent
          ),
        ),
        const SizedBox(height: 4),
        Text(
          cityName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Icon(Icons.wb_sunny, size: 45, color: Colors.orange),
        const SizedBox(height: 8),
        Text(
          '${temp.toStringAsFixed(0)}°C',
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        Text(
          condition.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.thermostat, size: 14, color: Colors.redAccent),
            const SizedBox(width: 4),
            Text(
              'Hissedilen: ${feelsLike.toStringAsFixed(0)}°C', 
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Sayfa Gösterge Noktaları
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (dotIndex) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (dayNumber - 1) == dotIndex ? Colors.blueAccent : Colors.grey[300],
              ),
            );
          }),
        )
      ],
    ),
  );
}