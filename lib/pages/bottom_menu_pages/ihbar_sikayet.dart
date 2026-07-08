import 'package:flutter/material.dart';
import 'package:smartcity/pages/ihbar_sikayet_pages/istek_sikayet.dart';
import 'package:smartcity/pages/ihbar_sikayet_pages/atik_bildir.dart';
import 'package:smartcity/pages/ihbar_sikayet_pages/atik_bildir.dart';
import 'package:url_launcher/url_launcher.dart';

class IhbarSikayet extends StatefulWidget {
  const IhbarSikayet({super.key});

  @override
  State<IhbarSikayet> createState() => _IhbarSikayetState();
}

class _IhbarSikayetState extends State<IhbarSikayet> {
  final List<Map<String, dynamic>> items = [
    {
      'title': 'ALO 153',
      'logo': 'assets/ihbar_sikayet_images/alo153.png',
      'url': 'tel:153',
      'isExternal': true,
    },
    {
      'title': 'ÇEK GÖNDER',
      'logo': 'assets/ihbar_sikayet_images/cek_gonder.png',
      'url': 'https://wa.me/905354540101',
      'isExternal': true,
    },
    {
      'title': 'İSTEK & ŞİKAYET',
      'logo': 'assets/ihbar_sikayet_images/istek_sikayet.png',
      'page': () => const IstekSikayet(),
    },
    {
      'title': 'ATIK BİLDİR',
      'logo': 'assets/ihbar_sikayet_images/atik_bildir.png',
      'page': () => const AtikBildir(),
    },
    {
      'title': 'ALO 185 ASKİ İHBAR',
      'logo': 'assets/aski_images/alo_185.png',
      'url': 'tel:185',
      'isExternal': true,
    },
    {
      'title': 'ASKİ WHATSAPP İHBAR HATTI',
      'logo': 'assets/whatsapp.png',
      'url': 'https://wa.me/905331505985',
      'isExternal': true,
    },
  ];
  void _onItemTap(Map<String, dynamic> item) async {
    if (item['page'] != null) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => (item['page'] as Widget Function())(),
          ),
        );
      }
    } 
    else if (item['url'] != null) {
      final Uri url = Uri.parse(item['url'] as String);
      final bool isExternal = item['isExternal'] == true;

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url, 
          mode: isExternal ? LaunchMode.externalApplication : LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
        );
      } else {
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
          'İHBAR & ŞİKAYET',
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
            final String title = (item['title'] ?? 'Uygulama').toString();
            final String logo = (item['logo'] ?? '').toString();

            return InkWell(
              onTap: () => _onItemTap(item),
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
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Image.asset(
                        logo,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
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