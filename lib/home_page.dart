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
  late PageController _pageController;
  int _currentImageIndex = 0;
  
  final List<String> _backgroundImages = [
    'assets/homepage_images/istasyon.png',
    'assets/homepage_images/buyuksaat-2.png',
    'assets/homepage_images/karatas.png',
    'assets/homepage_images/kup-selalesi.png',
    'assets/homepage_images/merkez-camii.png',
    'assets/homepage_images/misis-koprusu.png',
    'assets/homepage_images/musa-bali-konagi.png',
    'assets/homepage_images/portakal-agaci.png',
    'assets/homepage_images/portakal.png',
    'assets/homepage_images/seyhan-nehri.png',
    'assets/homepage_images/tas-kopru.png',
    'assets/homepage_images/tepebag-evleri.png',
    'assets/homepage_images/toroslar.png',
    'assets/homepage_images/ulu-camii.png',
    'assets/homepage_images/varda-1.png',
    'assets/homepage_images/varda-2.png',

  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    Future.delayed(Duration.zero, () {
      _startImageSlideshow();
    });
  }

  void _startImageSlideshow() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        });
        _startImageSlideshow();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                if (mounted) {
                  Navigator.of(context).pop();
                  _showCircularWeatherPopup(context, liveForecastList);
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veri çekilemedi: $e')),
                  );
                }
              }
            },
            icon: const Icon(
              Icons.wb_twilight_rounded,
              size: 32.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _backgroundImages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  _backgroundImages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _backgroundImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

          // Ana içerik
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const SafeArea(
                child: Center(
                ),
              ),
            ),
          ),
          
          // Bottom Menu
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