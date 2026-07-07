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
      'logo': 'assets/genc_adana_logo.png',
    },
    {
      'title': 'DENİZCİLİK İÇ SU HİZMETLERİ',
      'logo': 'assets/aski_logo.png',
    },
    {
      'title': 'İŞ TALEPLERİ',
      'logo': 'assets/pkds_logo.png',
    },
    {
      'title': 'ALTYAPI HİZMETLERİ',
      'logo': 'assets/pkds_logo.png',
    },
    {
      'title': 'TEKERLEKLİ SANDALYE BAŞVURU',
      'logo': 'assets/pkds_logo.png',
    },
    {
      'title': 'MEZARLIK DEFİN',
      'logo': 'assets/pkds_logo.png',
    },
    {
      'title': 'TİCARİ ARAÇ İŞLEMLERİ',
      'logo': 'assets/pkds_logo.png',
    },
  ];

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
            final String title = (items[index]['title'] ?? 'Uygulama').toString();
            final String logo = (items[index]['logo'] ?? '').toString();

            return InkWell(
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