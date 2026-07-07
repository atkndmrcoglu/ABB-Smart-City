import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class KentkartIslemleri extends StatefulWidget {
  const KentkartIslemleri({super.key});

  @override
  State<KentkartIslemleri> createState() => _KentkartIslemleriState();
}

class _KentkartIslemleriState extends State<KentkartIslemleri> {
  final List<Map<String, dynamic>> items = [
    {
      'title': 'BAKİYE SORGULAMA',
      'logo': 'assets/genc_adana_logo.png',
    },
    {
      'title': 'ABONMAN ÖĞRENCİ KARTI',
      'logo': 'assets/aski_logo.png',
    },
    {
      'title': 'SEYAHAT KARTI',
      'logo': 'assets/pkds_logo.png',
    },
    {
      'title': 'ÜCRET TARİFELERİ',
      'logo': 'assets/pkds_logo.png',
    },
    {
      'title': 'DOLUM NOKTALARI',
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
          'KENTKART İŞLEMLERİ',
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