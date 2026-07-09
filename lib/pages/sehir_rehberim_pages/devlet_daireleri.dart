import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

// --- VERİ MODELLERİ ---
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

// --- ANA EKRAN (BİRLEŞTİRİLMİŞ SAYFA) ---
class DevletDaireleri extends StatefulWidget {
  const DevletDaireleri({super.key});

  @override
  State<DevletDaireleri> createState() => _DevletDaireleriState();
}

class _DevletDaireleriState extends State<DevletDaireleri> {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harita uygulaması başlatılamadı.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Sekme sayısını 3'e çıkardık
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ADANA KURUMSAL VE TURİZM'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Başkan (Belediyeler)'),
              Tab(text: 'Başkan\'ın Mesajı'),
              Tab(text: 'Tarihi Yerler (Harita)'),
            ],
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black54,
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(), // Harita kaydırma jestleriyle çakışmaması için
          children: [
            _buildBelediyeler(context),
            _buildResmiKurumlar(),
            _buildHaritaVeTuristikYerler(),
          ],
        ),
      ),
    );
  }

  // --- SEKMELER (WIDGET'LAR) ---

  // 1. SEKME: BELEDİYELER (ZEYDAN KARALAR ÖZGEÇMİŞ)
  Widget _buildBelediyeler(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
                stops: [0.75, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              'assets/baskan.png',
              width: MediaQuery.of(context).size.width,
              height: 320,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 200,
                child: Icon(Icons.person, size: 100, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'ZEYDAN KARALAR',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(7, 7, 7, 1),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '1958 yılında Adana’nın Seyhan ilçesinde, on çocuklu bir ailenin altıncı çocuğu olarak dünyaya geldi. İlkokul, ortaokul, lise ve üniversiteyi Adana’da okudu. 1980 yılında Çukurova Üniversitesi Makina Mühendisliği bölümünden mezun oldu. 1982 yılında Nuray Karalar ile evlendi. Biri kız, ikisi erkek olmak üzere üç çocuk babasıdır.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 0, 0, 0),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.black12),
                const SizedBox(height: 16),
                const Text(
                  'İş Hayatı',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(7, 7, 7, 1),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '1981’de, 23 yaşında Makine Mühendisleri Odası Başkanlığına seçildi. 2 yıl bölge başkanlığı ve üst kurul (TMMOB) delegeliği yaptı. Oda tarihinde seçilen en genç başkandır.\n\n'
                  '1979 – 1985 yılları arasında Çukobirlik’te İplik İşletme Şefi olarak çalıştı. 1985 – 1991 yılları arasında Alman AEG ETİ Endüstri A.Ş.’de Müşteri Hizmetleri Yöneticiliği yaptı.\n\n'
                  '1991 – 1996 arasında Çukobirlik İplik Dokuma Fabrika Müdürü ve Teknik Genel Müdür Yardımcılığı görevlerinde bulundu.\n\n'
                  '1996 – 2007 yılları arasında Okan Tekstil A.Ş.’de Genel Müdürlük yaptı. Kazakistan’da Okan–Antriko Entegre Tekstil Fabrikası’nın Genel Müdürlüğü’nü yaptı.\n\n'
                  '2005 yılında kendi şirketi A-TEKS Mühendislik’i, 2008’de ikinci şirketi Başkent Pres’i kurdu.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 0, 0, 0),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.black12),
                const SizedBox(height: 16),
                const Text(
                  'Siyasi Geçmişi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(7, 7, 7, 1),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '1977’de Demokratik Sol Yüksek Öğrenim Derneğini kurdu ve yönetim kurulu başkanlığını yaptı.\n\n'
                  '1977 – 1980 arasında CHP İl Gençlik Kolları Saymanlığı ve Merkez İlçe Gençlik Kolları Başkanlığı yaptı.\n\n'
                  '7 Temmuz 2010’da Cumhuriyet Halk Partisi Merkez Yürütme Kurulu tarafından CHP Adana İl Başkanlığına atandı, 23 Ocak 2011’de yapılan CHP Adana İl Kongresi’nde delegelerin oylarıyla başkanlığa seçildi.\n\n'
                  '2014 yerel seçimlerinde, Ak Partili mevcut başkana karşı yarışarak Seyhan Belediye Başkanı seçildi.\n\n'
                  '31 Mart 2019 yerel seçimlerinde MHP’li mevcut başkana karşı yarıştı ve Adana Büyükşehir Belediye Başkanı olarak seçildi.\n\n'
                  '2022’de Dünya Belediyeler Birliği Sosyal İçerme Komitesi Eş Başkanı oldu. 2024 yılında Türkiye Belediyeler Birliği birinci başkan vekili seçildi. Halen ADSİAD ve MMO üyesidir.\n\n'
                  'İttifakın dağılması sonrası CHP adayı olarak girdiği 31 Mart 2024 yerel seçimlerinde yeniden Adana Büyükşehir Belediye Başkanlığı’na seçildi. Adana tarihinde üst üste iki kez seçilen ilk CHP’li Büyükşehir Belediye Başkanı’dır.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 0, 0, 0),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. SEKME: RESMİ KURUMLAR (BAŞKANIN MEKTUBU)
  Widget _buildResmiKurumlar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Değerli kardeşlerim,',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Memleketimiz için büyük bir öneme sahip olan 2019 yerel seçim sürecini Adana\'da başarılı bir şekilde geçirdik. Bu sürece başlarken tıpkı hayatım boyunca olduğu gibi; dürüstlük, çalışkanlık, vefalılık, halkçılık ve eşitlikçilik ana ilkelerimdi. Sizler de bunların gerçekliğini ve samimiyetini gördünüz, hissettiniz ve bizi desteklediniz. Çocuklardan yaşlılara, herkesin sahiplenebileceği halkın belediyesi olma hedefiyle 25 yıllık hasrete hep birlikte son verdik. Bu süreç içerisinde, bu başarıya katkı sunan siz değerli kardeşlerime gönülden teşekkürlerimi sunuyorum. Önemli olan bu teşekkürü sözlerin ötesinde, hizmetlerle sunmak aslında, bunu da yapacağımdan hiç şüpheniz olmasın.\n\n'
            'Adana\'da yeni bir dönemi başlatıyoruz. Aldığımız sorumluluğun ciddiyetinde ve bilincindeyiz. Adana\'yı gelişimine katkı sağlamak için bugüne kadar sürdürmüş olduğumuz inanç ve özveriyle durmadan çalışacağız. Halkın ihtiyaçlarını öncelik alıp bunları gidermeye çalışan, belediye ile halk arasındaki iletişim yollarını sürekli açık tutan ve halkın seçtiği kişileri denetleyebildiği bir yönetim anlayışını benimseyeceğiz. Adana\'da birikmiş ve ağır sorunlara sahip olduğunu biliyoruz. Biz, bu sorunları tek tek tespit eden ve çözümleri en kısa sürede hayata geçirecek bir hizmet anlayışını hakim kılacağız. Önümüze çıkan engellerden şikayet etmek yerine çözüme odaklanacağız. Hizmetleriyle, şeffaf yönetimiyle, güler yüzlü kadrosuyla Türkiye\'de örnek gösterilecek bir belediye yaratacağız.\n\n'
            'Sevgili hemşerilerim, Adana\'yı çok yukarılara taşımak için el birliğiyle çalışacağız. Adana’da sevgi, saygı ve kardeşlik kazandı demiştik. Bu sevgi, saygı ve kardeşlik duygularıyla siyasi parti ayrımı yapmaksızın herkese hizmet için çalışacağım. Umudumuz, kararlılığımız, inancımız, dürüstlüğümüz bize bu yolda rehber olmaya devam edecek.\n\n'
            'Hepinizi içtenlikle selamlıyorum.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 15,
              color: Color.fromARGB(255, 0, 0, 0),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.black12),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Zeydan KARALAR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Adana Büyükşehir Belediye Başkanı',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // 3. SEKME: TURİSTİK YERLER HARİTASI VE KARTLARI
  Widget _buildHaritaVeTuristikYerler() {
    return Stack(
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