import 'package:flutter/material.dart';
import 'package:smartcity/pages/bottom_menu_pages/aski_birimler.dart';
import 'package:smartcity/pages/bottom_menu_pages/eczaneler.dart';
import 'package:smartcity/pages/bottom_menu_pages/halk_ekmek_noktalari.dart';
import 'package:smartcity/pages/bottom_menu_pages/hizmet_talepleri.dart';
import 'package:smartcity/pages/bottom_menu_pages/ihbar_sikayet.dart';
import 'package:smartcity/pages/bottom_menu_pages/metro.dart';
import 'package:smartcity/pages/bottom_menu_pages/sehir_rehberim.dart';
import 'package:smartcity/pages/bottom_menu_pages/turistik_adana.dart';
import 'package:smartcity/pages/bottom_menu_pages/ulasim.dart';
import 'package:smartcity/pages/bottom_menu_pages/wifi_noktalari.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu({super.key});

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
    final List<Map<String, dynamic>> items = [
      {
        'title': 'OTOBÜSLER',
        'logo': 'assets/bottom_drawer_images/otobus.png',
        'page': const Ulasim(),
      },
      {
        'title': 'KENTKART İŞLEMLERİ',
        'logo': 'assets/bottom_drawer_images/kentkart_islemleri.png',
        'url': 'https://m.kentkart.com/home',
      },
      {
        'title': 'METRO',
        'logo': 'assets/bottom_drawer_images/metro.png',
        'page': const Metro(),
      },
      {
        'title': 'ECZANELER',
        'logo': 'assets/bottom_drawer_images/eczane.png',
        'page': const Eczaneler(),
      },
      {
        'title': 'HALK EKMEK NOKTALARI',
        'logo': 'assets/bottom_drawer_images/halk_ekmek.png',
        'page': const HalkEkmekNoktalari(),
      },
      {
        'title': 'WİFİ NOKTALARI',
        'logo': 'assets/bottom_drawer_images/wifi.png',
        'page': const WifiNoktalari(),
      },
      {
        'title': 'ŞEHİR REHBERİM',
        'logo': 'assets/bottom_drawer_images/sehir_rehberim.png',
        'page': const SehirRehberim(),
      },
      {
        'title': 'KÜTÜPHANELER',
        'logo': 'assets/bottom_drawer_images/kutuphane.png',
        'url': 'https://kutuphane.adana.bel.tr/#',
      },
      {
        'title': 'ADANA 360',
        'logo': 'assets/bottom_drawer_images/adana360.png',
        'page': const Adana(),
      },
      {
        'title': 'İHBAR ŞİKAYET',
        'logo': 'assets/bottom_drawer_images/ihbar_sikayet.png',
        'page': const IhbarSikayet(),
      },
      {
        'title': 'HİZMET TALEPLERİ',
        'logo': 'assets/bottom_drawer_images/hizmet_talepleri.png',
        'page': const HizmetTalepleri()
      },
      {
        'title': 'ASKİ',
        'logo': 'assets/aski_logo.png',
        'page': const AskiBirimler(),
      },
      {
        'title': 'HAL GÜNLÜK RAİÇ BEDELLERİ',
        'logo': 'assets/bottom_drawer_images/hal.png',
        'url': 'https://www.adana.bel.tr/tr/hal-fiyat-listesi',
      },
      {
        'title': 'AFET BİLGİ',
        'logo': 'assets/bottom_drawer_images/afet_bilgi.png',
        'url': 'https://www.adana.bel.tr/tr/afet',
      },
      {
        'title': 'İHALE İLANLARI',
        'logo': 'assets/bottom_drawer_images/ihale_ilanlari.png',
        'url': 'https://www.adana.bel.tr/tr/ihale',
      },
      {
        'title': 'ŞEFKAT KÖPRÜSÜ',
        'logo': 'assets/bottom_drawer_images/sefkat_koprusu.png',
        'url': 'https://sefkatkoprusu.com/#/',
      },
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.22, 
      minChildSize: 0.22,    
      maxChildSize: 0.85,     
      snap: true,            
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Icon(Icons.keyboard_arrow_up_rounded, color: Colors.grey[400], size: 28),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Tıkla ve Hizmetleri Gör',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                  ],
                ),
              ),
            
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95, 
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];

                      return InkWell(
                        onTap: () => _onItemTap(context, item),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
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
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryTab extends StatelessWidget {
  final String title;
  final bool isActive;
  const CategoryTab({super.key, required this.title, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: isActive ? const Border(bottom: BorderSide(color: Color(0xFF5E35B1), width: 2)) : null,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? const Color(0xFF00B48B) : Colors.grey[600],
        ),
      ),
    );
  }
}