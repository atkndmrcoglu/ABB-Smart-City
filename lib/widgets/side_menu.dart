import 'package:flutter/material.dart';
import 'package:smartcity/pages/side_menu_pages/baskan.dart';
import 'package:smartcity/pages/side_menu_pages/hakkinda.dart';
import 'package:smartcity/pages/side_menu_pages/iletisim.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  // Helper method to safely launch external social links
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint('Could not launch: $urlString');
    }
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.grey,
      thickness: 1.0,
      height: 20.0,
      indent: 16.0,
      endIndent: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 90,
                    width: 90,
                  ),
                ),
                const ListTile(
                  title: Text('HABERLER ve DUYURULAR'),
                  trailing: Icon(Icons.arrow_right),
                ),
                _buildDivider(),
                ListTile(
                  title: const Text('BAŞKAN'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () {
                    Navigator.pop(context); 
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BaskanPage()),
                    );
                  },
                ),
                _buildDivider(), 
                ListTile(
                  title: const Text('HAKKINDA'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HakkindaPage()),
                    );
                  },
                ),
                _buildDivider(),
                ListTile(
                  title: const Text('İLETİŞİM'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Iletisim()),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
         
          // Horizontal side-by-side social tray
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.pink, size: 28),
                onPressed: () => _launchURL('https://www.instagram.com/adanabld/?igshid=YmMyMTA2M2Y%3D'),
              ),
              const SizedBox(width: 12),
              
              IconButton(
                icon: const Icon(Icons.facebook, color: Colors.blue, size: 30),
                onPressed: () => _launchURL('https://www.facebook.com/adana.bel.tr?mibextid=ZbWKwL'),
              ),
              const SizedBox(width: 12),
              
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.xTwitter, color: Colors.black, size: 26),
                onPressed: () => _launchURL('https://x.com/Adana_Bld?t=iJI5F36AA4IV_Cis5EG7-w&s=08'),
              ),
              const SizedBox(width: 12),
              
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.youtube, color: Colors.red, size: 28),
                onPressed: () => _launchURL('https://www.youtube.com/@AdanaBB'),
              ),
            ],
          ),
             
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
            child: Text(
              '© 2026 Adana Büyükşehir Belediyesi',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}