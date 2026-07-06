import 'package:flutter/material.dart';
import 'package:smartcity/widgets/side_menu.dart';
import 'package:smartcity/widgets/bottom_menu.dart'; 
import '../models/weather_model/weather_model.dart'; 
import '../widgets/weather_widget.dart';

class HOMEPAGE extends StatefulWidget {
  const HOMEPAGE({super.key});

  @override
  State<HOMEPAGE> createState() => _HOMEPAGEState();
}

class _HOMEPAGEState extends State<HOMEPAGE> {
  
  Future<List<WeatherModel>> _fetchLiveWeatherData() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      WeatherModel(city: 'Adana', temperature: 32, feelsLike: 36, condition: 'Sunny', humidity: 54),
      WeatherModel(city: 'Adana', temperature: 33, feelsLike: 37, condition: 'Sunny', humidity: 50),
      WeatherModel(city: 'Adana', temperature: 31, feelsLike: 34, condition: 'Partly Cloudy', humidity: 60),
      WeatherModel(city: 'Adana', temperature: 30, feelsLike: 33, condition: 'Rainy', humidity: 75),
      WeatherModel(city: 'Adana', temperature: 32, feelsLike: 35, condition: 'Mostly Sunny', humidity: 55),
    ];
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(), 
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/logo.png',
          height: 70,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              _showLoadingDialog(context);
              try {
                List<WeatherModel> liveForecastList = await _fetchLiveWeatherData();
                if (mounted) Navigator.of(context).pop();
                if (mounted) _showCircularWeatherPopup(context, liveForecastList);
              } catch (e) {
                if (mounted) Navigator.of(context).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veri çekilemedi: $e')),
                  );
                }
              }
            },
            icon: const Icon(
              Icons.wb_twilight_rounded,
              size: 32.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF1F5F9), 
              child: const SafeArea(
                child: Center(
                  child: Text(
                    'Welcome to the Home Page!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: BottomMenu(),
          ),
        ],
      ),
    );
  }
}

void _showCircularWeatherPopup(BuildContext context, List<WeatherModel> fiveDayForecast) {
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