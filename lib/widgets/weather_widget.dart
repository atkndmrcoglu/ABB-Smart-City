import 'package:flutter/material.dart';
import '../models/weather_model/weather_model.dart';

void showCircularWeatherPopup(BuildContext context, List<WeatherModel> fiveDayForecast) {
  final restrictedForecast = fiveDayForecast.take(5).toList();

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
            child: PageView.builder(
              itemCount: restrictedForecast.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final dayData = restrictedForecast[index];
                return buildCircularWeatherPage(context, dayData, index + 1);
              },
            ),
          ),
        ),
      );
    },
  );
}

Widget buildCircularWeatherPage(BuildContext context, WeatherModel weather, int dayNumber) {
  return Padding(
    padding: const EdgeInsets.all(32.0),                                                                                                                                                                                            //Atakan Demircioğlu Tarafından Adana Büyükşehir Belediyesi Bilgi İşlem Dairesi Başkanlığı için 2026 Yılında Geliştirilmiştir
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dayNumber == 1 ? "BUGÜN" : dayNumber == 2 ? "YARIN" : "${dayNumber - 1} GÜN SONRA",
          style: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: Colors.blueAccent
          ),
        ),
        const SizedBox(height: 4),
        Text(
          weather.city,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Icon(Icons.wb_sunny, size: 50, color: Colors.orange),
        const SizedBox(height: 12),
        Text(
          '${weather.temperature.toStringAsFixed(0)}°C',
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          weather.condition,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.thermostat, size: 14, color: Colors.redAccent),
            const SizedBox(width: 4),
            Text('${weather.feelsLike.toStringAsFixed(0)}°C', style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
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