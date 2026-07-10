import 'package:flutter/material.dart';
import 'package:smartcity/pages/turistik_adana_pages/tarihi_turistik_yerler.dart';
import 'package:url_launcher/url_launcher.dart';

class Adana extends StatefulWidget {
  const Adana({super.key});

  @override
  State<Adana> createState() => _AdanaState();
}

class _AdanaState extends State<Adana> {
  final List<Map<String, dynamic>> items = [
    {
      'title': 'ADANA 360',
      'logo': 'assets/turistik_adana_images/adana360.png',
      'url': 'https://www.adana.bel.tr/tr/360-derece'
    },
    {
      'title': 'TARİHİ TURİSTİK YERLER',
      'logo': 'assets/turistik_adana_images/tarihi_turistik_yerler.png',
      'page': const TuristikYerler()
    },
  ];

  void _onItemTap(BuildContext context, Map<String, dynamic> item) async {
    if (item['page'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => item['page'] as Widget),
      );
    } 
    else if (item['url'] != null) {
      final Uri url = Uri.parse(item['url'] as String);
      final bool isExternal = item['isExternal'] == true;

      if (!await launchUrl(
        url, 
        mode: isExternal ? LaunchMode.externalApplication : LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
      )) {
        debugPrint('Could not launch: ${item['url']}');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'TURİSTİK ADANA',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: GridView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return InkWell(
              onTap: () => _onItemTap(context, item),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(50),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   Image.asset(
                              item['logo'] as String,
                              height: 90,
                              width: 90,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.apps, size: 45, color: Colors.grey),
                            ),
                    const SizedBox(height: 12),
                    Text(
                              item['title'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}