import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class KartIcerikDetay {
  final String rozetMetni;
  final IconData anahtarIkon;
  final String anahtarVeri;

  KartIcerikDetay({
    required this.rozetMetni,
    required this.anahtarIkon,
    required this.anahtarVeri,
  });
}

class TuristikYerler extends StatefulWidget {
  const TuristikYerler({super.key});

  @override
  State<TuristikYerler> createState() => _TuristikYerlerState();
}

class _TuristikYerlerState extends State<TuristikYerler> {
  final MapController _mapController = MapController();
  final LatLng adanaMerkez = const LatLng(36.9931, 35.3256);
  final List<Map<String, dynamic>> benimYerlerim = [
  {
    'isim': 'Anavarza Ören Yeri',
    'lat': 37.249230,
    'lon': 35.895470,
    'altBaslik': 'Kozan, Adana',
    'aciklama': 'Antik dönemin en büyük metropollerinden biri olan Anavarza, devasa surları, zafer takı ve dünyanın ilk çift şeritli sütunlu caddesi ile ünlüdür.',
    'detaylar': [
      KartIcerikDetay(rozetMetni: 'Tarih', anahtarIkon: Icons.history, anahtarVeri: 'Roma Dönemi'),
      KartIcerikDetay(rozetMetni: 'Giriş', anahtarIkon: Icons.confirmation_number_outlined, anahtarVeri: 'Müzekart'),
    ]
  },
  {
    'isim': 'Şarköy Ören Yeri',
    'lat': 38.332731,
    'lon': 36.325306,
    'altBaslik': 'Tufanbeyli, Adana',
    'aciklama': 'Kappadokia bölgesinin önemli dini merkezlerinden biri olan Comana Antik Kenti kalıntılarını barındıran bölge, açık hava müzesi niteliğindedir.',
    'detaylar': [
      KartIcerikDetay(rozetMetni: 'Tür', anahtarIkon: Icons.account_balance, anahtarVeri: 'Antik Kent'),
      KartIcerikDetay(rozetMetni: 'Giriş', anahtarIkon: Icons.lock_open, anahtarVeri: 'Ücretsiz'),
    ]
  },
  {
    'isim': 'Misis Yakapınar Ören Yeri',
    'lat': 36.957596,
    'lon': 35.623851,
    'altBaslik': 'Yüreğir, Adana',
    'aciklama': 'İpek Yolu üzerinde kurulan antik kent, Lokman Hekim\'in ölümsüzlük iksirini üzerinden düşürdüğü Misis Köprüsü ve eşsiz zemin mozaikleriyle tanınır.',
    'detaylar': [
      KartIcerikDetay(rozetMetni: 'Mozaik', anahtarIkon: Icons.extension, anahtarVeri: 'Müze Mevcut'),
      KartIcerikDetay(rozetMetni: 'Giriş', anahtarIkon: Icons.lock_open, anahtarVeri: 'Ücretsiz'),
    ]
  },
  {
    'isim': 'Magarsus Ören Yeri',
    'lat': 36.545854,
    'lon': 35.347095,
    'altBaslik': 'Karataş, Adana',
    'aciklama': 'Mallos Antik Kenti\'nin dini merkezi olan Magarsus, Akdeniz\'e tam cepheden bakan muazzam bir antik tiyatroya ve Athena Tapınağı kalıntılarına sahiptir.',
    'detaylar': [
      KartIcerikDetay(rozetMetni: 'Manzara', anahtarIkon: Icons.waves, anahtarVeri: 'Deniz Kenarı'),
      KartIcerikDetay(rozetMetni: 'Yapı', anahtarIkon: Icons.theater_comedy, anahtarVeri: 'Antik Tiyatro'),
    ]
  },
  {
    'isim': 'Ayas Kalesi',
    'lat': 36.767179,
    'lon': 35.791830,
    'altBaslik': 'Yumurtalık, Adana',
    'aciklama': 'Orta Çağ\'da Kilikya\'nın en önemli liman kentlerinden biri olan Yumurtalık\'ta yer alan kale, hem kara hem de deniz savunması amacıyla inşa edilmiştir.',
    'detaylar': [
      KartIcerikDetay(rozetMetni: 'Yapı', anahtarIkon: Icons.fort, anahtarVeri: 'Liman Kalesi'),
      KartIcerikDetay(rozetMetni: 'Manzara', anahtarIkon: Icons.wb_sunny_outlined, anahtarVeri: 'Sahil Şeridi'),
    ]
  },
  {
    'isim': 'Akören Antik Kenti',
    'lat': 37.467425,
    'lon': 35.461922,
    'altBaslik': 'Aladağ, Adana',
    'aciklama': 'Bizans dönemine ait yoğun kalıntıların bulunduğu Akören, özellikle ayakta kalmayı başarmış tarihi kiliseleri ve antik taş evleri ile dikkat çeker.',
    'detaylar': [
      KartIcerikDetay(rozetMetni: 'Dönem', anahtarIkon: Icons.church, anahtarVeri: 'Bizans'),
      KartIcerikDetay(rozetMetni: 'Giriş', anahtarIkon: Icons.lock_open, anahtarVeri: 'Ücretsiz'),
    ]
  },
  {
    'isim': 'Muvattali Kabartması Ve Ören Yeri',
    'lat': 37.003879,
    'lon': 35.745788,
    'altBaslik': 'Ceyhan, Adana',
    'aciklama': 'Sirkeli Höyük\'te bulunan bu kabartma, Hitit Kralı 2. Muvattali\'ye aittir ve Anadolu\'daki tarihlenebilen en eski Hitit kaya kabartmalarından biridir.',
    'detaylar': [
      KartIcerikDetay(rozetMetni: 'Uygarlık', anahtarIkon: Icons.gavel, anahtarVeri: 'Hitit Dönemi'),
      KartIcerikDetay(rozetMetni: 'Eser', anahtarIkon: Icons.image_search, anahtarVeri: 'Kaya Oyma'),
    ]
  },
  {
    'isim': 'Tatarlı Höyük',
    'lat': 37.123000,
    'lon': 36.050790,
    'altBaslik': 'Ceyhan, Adana',
    'aciklama': 'Kilikya bölgesinin en büyük höyüklerinden biri olan Tatarlı, Hitit döneminin kutsal şehri Lawazantiya ile özdeşleştirilen çok önemli bir kazı alanıdır.',
    'detaylar': [
      KartIcerikDetay(rozetMetni: 'Kazı', anahtarIkon: Icons.landscape, anahtarVeri: 'Aktif Höyük'),
      KartIcerikDetay(rozetMetni: 'Önem', anahtarIkon: Icons.auto_awesome, anahtarVeri: 'Kutsal Şehir'),
    ]
  },
];

  void _haritayiOdakla(double lat, double lon) {
    _mapController.move(LatLng(lat, lon), 13.0);
  }

  Future<void> _yolTarifiBaslat(double lat, double lon) async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lon";
    final Uri url = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harita uygulaması başlatılamadı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tarihi Turistik Yerler', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: adanaMerkez, initialZoom: 9.5),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.belediye.akillisehir',
              ),
              MarkerLayer(
                markers: benimYerlerim.map((yer) {
                  return Marker(
                    point: LatLng(yer['lat'], yer['lon']),
                    width: 45,
                    height: 45,
                    child: GestureDetector(
                      onTap: () => _haritayiOdakla(yer['lat'], yer['lon']),
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 270,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.88),
                itemCount: benimYerlerim.length,
                onPageChanged: (index) {
                  final yer = benimYerlerim[index];
                  _haritayiOdakla(yer['lat'], yer['lon']);
                },
                itemBuilder: (context, index) {
                  final yer = benimYerlerim[index];
                  return _buildGenelBilgiKarti(yer);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenelBilgiKarti(Map<String, dynamic> data) {
    final List<KartIcerikDetay> detaylar = data['detaylar'] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                radius: 18,
                child: const Icon(Icons.account_balance, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['isim'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      data['altBaslik'] ?? 'Adana',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16, thickness: 0.5),
          Text(
            data['aciklama'] ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: detaylar.length,
              itemBuilder: (context, dIndex) {
                final detay = detaylar[dIndex];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(detay.rozetMetni, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Icon(detay.anahtarIkon, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(detay.anahtarVeri, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              },
            ),
          ),
          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _yolTarifiBaslat(data['lat'], data['lon']),
              icon: const Icon(Icons.navigation_outlined, size: 18, color: Colors.white),
              label: const Text("Yol Tarifi Al", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          )
        ],
      ),
    );
  }
}