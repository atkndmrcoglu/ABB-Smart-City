import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HizmetTalepleri extends StatefulWidget {
  const HizmetTalepleri({super.key});

  @override
  State<HizmetTalepleri> createState() => _HizmetTalepleriState();
}

class _HizmetTalepleriState extends State<HizmetTalepleri> {
  final List<Map<String, dynamic>> items = [
    {
      'title': 'İŞ YERİ RUHSAT İŞLEMLERİ',
      'logo': 'assets/hizmet_talepleri_images/is_yeri_ruhsat_islemleri.png',
      'url': 'https://www.adana.bel.tr/tr/hizmetlerimiz/is-yeri-ruhsat-islemleri',
    },
    {
      'title': 'DENİZCİLİK İÇ SU HİZMETLERİ',
      'logo': 'assets/hizmet_talepleri_images/denizcilik_ic_su_hizmetleri.png',
      'url': 'https://www.adana.bel.tr/tr/hizmetlerimiz/denizcilik-ve-ic-su-hizmetleri',
    },
    {
      'title': 'İŞ TALEPLERİ',
      'logo': 'assets/hizmet_talepleri_images/is_talepleri.png',
      'url': 'https://www.adana.bel.tr/tr/hizmetlerimiz/is-talepleri'
    },
    {
      'title': 'ALTYAPI HİZMETLERİ',
      'logo': 'assets/hizmet_talepleri_images/altyapi_hizmetleri.png',
      'url': 'https://www.adana.bel.tr/tr/hizmetlerimiz/altyapi-ve-koordinasyon-hizmetleri'
    },
    {
      'title': 'TEKERLEKLİ SANDALYE BAŞVURU',
      'logo': 'assets/hizmet_talepleri_images/tekerlekli_sandalye_basvuru.png',
      'url': 'https://www.adana.bel.tr/tr/hizmetlerimiz/tekerlekli-sandalye-basvurusu'
    },
    {
      'title': 'MEZARLIK DEFİN',
      'logo': 'assets/hizmet_talepleri_images/mezarlik_defin.png',
      'url': 'https://www.adana.bel.tr/tr/hizmetlerimiz/mezarlik-defin-islemleri'
    },
    {
      'title': 'TİCARİ ARAÇ İŞLEMLERİ',
      'logo': 'assets/hizmet_talepleri_images/ticari_arac_islemleri.png',
      'url': 'https://www.adana.bel.tr/tr/hizmetlerimiz/ticari-arac-islemleri'
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu hizmet için henüz bir yönlendirme eklenmedi.')),
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
          'HİZMET TALEPLERİ',
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
            final Map<String, dynamic> currentItem = items[index];
            final String title = (currentItem['title'] ?? 'Uygulama').toString();
            final String logo = (currentItem['logo'] ?? '').toString();

            return InkWell(
              onTap: () => _onItemTap(context, currentItem),
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Yazıların taşmaması için padding eklendi
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
              ),
            );
          },
        ),
      ),
    );
  }
}