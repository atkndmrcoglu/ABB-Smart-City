import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DigerUygulamalar extends StatefulWidget {
  const DigerUygulamalar({super.key});

  @override
  State<DigerUygulamalar> createState() => _DigerUygulamalarState();
}

class _DigerUygulamalarState extends State<DigerUygulamalar> {
  final List<Map<String, dynamic>> items = [
    {
      'title': 'GENÇ ADANA',
      'logo': 'assets/genc_adana_logo.png',
      'androidUrl': 'https://play.google.com/store/apps/details?id=com.gencadana.abb',
      'iosUrl': 'https://apps.apple.com/tr/app/gen%C3%A7-adana/id6755651854',
    },
    {
      'title': 'ASKİ MOBİL',
      'logo': 'assets/aski_logo.png',
      'androidUrl': 'https://play.google.com/store/apps/details?id=tr.bel.adana.aski',
      'iosUrl': 'https://apps.apple.com/tr/app/adana-aski-mobil/id6444313258',
    },
    {
      'title': 'PERSONEL PKDS',
      'logo': 'assets/pkds_logo.png',
      'androidUrl': 'https://play.google.com/store/apps/details?id=com.adana.adanapdks',
      'iosUrl': 'https://apps.apple.com/tr/app/adana-bb-pdks/id6475201396',
    },
  ];
  Future<void> _magazayaGonder(String androidUrl, String iosUrl) async {
    String urlSecimi = '';
    if (Platform.isAndroid) {
      urlSecimi = androidUrl;
    } else if (Platform.isIOS) {
      urlSecimi = iosUrl;
    }

    if (urlSecimi.isNotEmpty) {
      final Uri url = Uri.parse(urlSecimi);

      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        } else {
          _hataMesajiGoster('Mağaza bağlantısı şu an açılamıyor.');
        }
      } catch (e) {
        _hataMesajiGoster('Bir hata oluştu: $e');
      }
    } else {
      _hataMesajiGoster('Bu cihaz için mağaza linki bulunamadı.');
    }
  }

  void _hataMesajiGoster(String mesaj) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mesaj),
          duration: const Duration(seconds: 3),
        ),
      );
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
          'DİĞER MOBİL UYGULAMALARIMIZ',
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
            final String title = (items[index]['title'] ?? 'Uygulama').toString();
            final String logo = (items[index]['logo'] ?? '').toString();
            final String androidUrl = (items[index]['androidUrl'] ?? '').toString();
            final String iosUrl = (items[index]['iosUrl'] ?? '').toString();

            return InkWell(
              onTap: () => _magazayaGonder(androidUrl, iosUrl),
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
                      width: 65,
                      height: 65,
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