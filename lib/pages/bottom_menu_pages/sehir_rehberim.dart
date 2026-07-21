import 'package:flutter/material.dart';
import 'package:smartcity/pages/sehir_rehberim_pages/alisveris_spor.dart';
import 'package:smartcity/pages/sehir_rehberim_pages/bankalar.dart';
import 'package:smartcity/pages/sehir_rehberim_pages/devlet_daireleri.dart';
import 'package:smartcity/pages/sehir_rehberim_pages/namaz_vakitleri.dart';
import 'package:smartcity/pages/sehir_rehberim_pages/restoran_konaklama.dart';
import 'package:smartcity/pages/sehir_rehberim_pages/sinemalar_tiyatrolar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartcity/pages/sehir_rehberim_pages/kultur_sanat.dart';
import 'package:smartcity/pages/sehir_rehberim_pages/egitim_universiteler.dart';

class SehirRehberim extends StatefulWidget {
  const SehirRehberim({super.key});

  @override
  State<SehirRehberim> createState() => _SehirRehberimState();
}

class _SehirRehberimState extends State<SehirRehberim> {
  final List<Map<String, dynamic>> items = [
    {
      'title': 'TAŞKÖPRÜ KONUKEVİ',
      'logo': 'assets/sehir_rehberim_images/taskopru.png',
      'url': 'https://taskoprukonukevi.adana.bel.tr/',
    },
    {
      'title': 'ALTINKOZA FİLM FESTİVALİ',
      'logo': 'assets/sehir_rehberim_images/altinkoza.png',
      'url': 'https://altinkozaff.org.tr/',
    },
    {
      'title': 'RESTORAN/KONAKLAMA',
      'logo': 'assets/sehir_rehberim_images/restoran_konaklama.png',
      'page': () => RestoranlarVeKonaklama(),
    },
    {
      'title': 'SİNEMALAR/TİYATROLAR',
      'logo': 'assets/sehir_rehberim_images/sinemalar_tiyatrolar.png',
      'page': () => SinemaTiyatro(),
    },
    {
      'title': 'ALIŞVERİŞ/SPOR',
      'logo': 'assets/sehir_rehberim_images/alisveris_spor.png',
      'page': () => AlisverisSpor(),
    },
    {
      'title': 'KÜLTÜR SANAT',
      'logo': 'assets/sehir_rehberim_images/kultur_sanat.png',
      'page': () => KulturSanat(),
    },
    {
      'title': 'EĞİTİM/ÜNİVERSİTELER',
      'logo': 'assets/sehir_rehberim_images/egitim.png',
      'page': () => EgitimUniversiteler(),
    },
    {
      'title': 'NAMAZ VAKİTLERİ',
      'logo': 'assets/sehir_rehberim_images/namaz_vakitleri.png',
      'page': () => Namaz(),
    },
    {
      'title': 'BANKALAR',
      'logo':'assets/sehir_rehberim_images/bankalar.png',
      'page': () => Bankalar(),
    },
    {
      'title': 'DEVLET DAİRELERİ',
      'logo': 'assets/sehir_rehberim_images/devlet_daireleri.png',
      'page': () => DevletDaireleri(),
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
          'ŞEHİR REHBERİM',
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