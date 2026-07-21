import 'package:flutter/material.dart';
import 'package:smartcity/widgets/side_menu.dart';
import 'package:smartcity/widgets/bottom_menu.dart'; 
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startImageSlideshow();
    });
  }

  void _startImageSlideshow() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _pageController.hasClients) {
        final nextIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _startImageSlideshow();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          height: 60,
        ),
        actions: [
          IconButton(
            onPressed: () {
              showCircularWeatherPopup(context);
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
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const SafeArea(
                child: Center(),
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