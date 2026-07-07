import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class Iletisim extends StatefulWidget {
  const Iletisim({super.key});

  @override
  State<Iletisim> createState() => _IletisimState();
}

class _IletisimState extends State<Iletisim> {
  bool _isMapLoading = true;
  Future<void> _aramaYap(String telNo) async {
    final Uri launchUri = Uri(scheme: 'tel', path: telNo);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
  Future<void> _epostaGonder(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'İLETİŞİM',
          style: TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold, 
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _iletisimKarti(
                    icon: Icons.location_on,
                    title: 'Adres',
                    subtitle: 'Reşatbey Mh. Atatürk Cd. No:1 01120 Seyhan / ADANA',
                    onTap: null,
                  ),
                  const SizedBox(height: 12),
                  _iletisimKarti(
                    icon: Icons.phone,
                    title: 'Santral (Telefon)',
                    subtitle: 'ALO 153 / +90 (322) 455 35 00',
                    onTap: () => _aramaYap('+903224553500'),
                  ),
                  const SizedBox(height: 12),
                  _iletisimKarti(
                    icon: Icons.print,
                    title: 'Faks',
                    subtitle: '+90 (322) 455 35 72',
                    onTap: null,
                  ),
                  const SizedBox(height: 12),
                  _iletisimKarti(
                    icon: Icons.email,
                    title: 'E-Posta',
                    subtitle: 'info@adana.bel.tr',
                    onTap: () => _epostaGonder('info@adana.bel.tr'),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Haritada Konumumuz',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),

            Container(
              height: 250,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  InAppWebView(
                    initialData: InAppWebViewInitialData(
                      data: """
                        <!DOCTYPE html>
                        <html>
                        <head>
                          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                          <style>
                            body { margin: 0; padding: 0; overflow: hidden; }
                            iframe { border: none; width: 100vw; height: 100vh; }
                          </style>
                        </head>
                        <body>
                          <iframe 
                            src="https://maps.google.com/maps?q=36.993100,35.325650(Adana+Büyükşehir+Belediyesi)&z=16&output=embed"
                            allowfullscreen="" 
                            loading="lazy" 
                            referrerpolicy="no-referrer-when-downgrade">
                          </iframe>
                        </body>
                        </html>
                      """,
                    ),
                    initialSettings: InAppWebViewSettings(
                      supportZoom: true,
                      builtInZoomControls: false,
                    ),
                    onLoadStop: (controller, url) {
                      setState(() {
                        _isMapLoading = false;
                      });
                    },
                  ),
                  if (_isMapLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E293B)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _iletisimKarti({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1E293B), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w600),
        ),
        trailing: onTap != null ? const Icon(Icons.chevron_right, size: 18) : null,
        onTap: onTap,
      ),
    );
  }
}