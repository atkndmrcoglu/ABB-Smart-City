import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HakkindaPage extends StatelessWidget {
  const HakkindaPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HAKKINDA'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'GENEL BİLGİLER'),
              Tab(text: 'TARİHÇE'),
              Tab(text: 'MİSYON & VİZYON'),
            ],
            indicatorColor: Colors.black, 
          ),
        ),
        body: TabBarView(
          children: [
            _buildGenelBilgiler(),
            _buildTarihce(),
            _buildMisyonVizyon(),
          ],
        ),
      ),
    );
  }

  Widget _buildGenelBilgiler() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 250,
              width: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              'Adana Büyükşehir Belediyesi - Akıllı Kent Uygulamasında yer alan konumlar, telefonlar vb. tüm içerikler bilgilendirme amaçlıdır. Doğabilecek her türlü zararda Adana Büyükşehir Belediyesi sorumlu tutulamaz. Tüm hakları Adana Büyükşehir Belediyesine aittir.',
              style: TextStyle(fontSize: 18,),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _launchURL('https://www.adana.bel.tr/'),
              child: const Text(
                'Adana Büyükşehir Belediyesi',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0), 
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _launchURL('https://aydinlatma.adana.bel.tr/ar/?aref=C685C7B4-FF40-428E-BA33-73AC26C121CC'),
              child: const Text(
                'Aydınlatma Metni İçin Tıklayınız',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
Widget _buildTarihce() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kurum Tarihçesi',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 2),
        const SizedBox(height: 15),

        _tarihceBaslik('Osmanlı Dönemi ve Vakıflar (1840 Öncesi)'),
        _tarihceMetin(
          '1840 yılına kadar bugünkü anlamda belediye hizmetlerini yerine getiren bir kurum yoktu. '
          'Kamu hizmetlerinin yerine getirilmesinde, mutasarrıf ve valilerin direktiflerine göre hareket edilir, '
          'vakıfların sosyal amaçlı faaliyetlerinden yararlanılırdı.\n\n'
          '1833-1840 yılları arasında Adana’ya hakim olan Mısırlı İbrahim döneminde vakıflara da çeki düzen verildi ve hizmetler yelpazesi arttırıldı. '
          'XIX’uncu yüzyılın ikinci yarısına girilirken, bugünkü vilayet sınırları içinde 350 kadar vakıf bulunmakta idi.',
        ),

        _tarihceBaslik('Amerikan İç Savaşı ve Tarımsal Dönüşüm (1860)'),
        _tarihceMetin(
          '1860 yılında patlayan Amerikan İç Savaşı, Adana’yı önemli ölçüde etkilemişti. '
          'Avrupa’nın tekstil için gerekli pamuk ihtiyacını karşılamak üzere İngiliz, Fransız ve Alman heyetleri Adana’da pamuk ekimini teşvik için özel imkanlar kopardılar. '
          '1863’ten itibaren yüzlerce Avrupalının (Levantenler) Adana’ya gelmesiyle kentin genel görünümü değişti ve modern kent yaşamı gereksinimleri ortaya çıktı.',
        ),

        _tarihceBaslik('Muhtesiplikten Belediyeye (1870 - 1871)'),
        _tarihceMetin(
          'Yeni arayışların bir sonucu olarak, 1870 yılında "Muhtesiplik" adı altında, günümüz belediye kavramının ilk formu olan bir kurum oluşturuldu. '
          'Bu süreçte kentin Ezene olan ismi Atana şekline dönüştürüldü.\n\n'
          '1871 yılında ise kurum resmen "Adana Belediyesi" adını aldı ve kentin ismi Adana olarak kesinleşti. '
          'İlk Belediye Başkanlığına Gözlüklü Süleyman Efendi getirildi.',
        ),

        _tarihceBaslik('Modern Şehircilik Adımları (1877 - 1909)'),
        _tarihceMetin(
          '1877-1881 yılları arasında görev yapan Kirkor Bezdikyan ve Sinyor Artin dönemlerinde yollar genişletildi, parke taş kaplamalarına geçildi ve drenaj kanalları açıldı. '
          '1908 yılında ise kentteki ilk kanalizasyon çalışması başlatıldı. '
          'Ancak 1909 Ermeni Ayaklanması (İğtişaş) ve 1918-1921 Fransız işgali dönemlerinde belediye hizmetleri büyük sekteye uğradı.',
        ),

        _tarihceBaslik('Milli Mücadele ve Cumhuriyet Dönemi'),
        _tarihceMetin(
          '8 Ekim’de toplanan Pozantı Kongresi, Adana’nın gerçek Belediye Başkanlığı’na Dıblanzade Mehmet Fuad Bey’i seçti. '
          'Kurtuluştan sonra başkanlığa getirilen Ali Münif Yeğenağa ise Cumhuriyet döneminin ilk başkanı oldu (1922-1926).\n\n'
          '1926-1938 yılları arasında aktif başkanlık yapan Turhan Cemal Beriker; sebze hali, parklar, yeni yollar ve buzhane gibi planlı çalışmalara imza attı. '
          'Ayrıca 1930\'da kurulan Adana Elektrik Şirketi’ni teşvik ederek kente elektriğin gelmesini sağladı.',
        ),

        _tarihceBaslik('Baraj Yapımı, Sanayileşme ve Büyük Göç (1956)'),
        _tarihceMetin(
          '6 Nisan 1956’da açılışı yapılan Seyhan Hidroelektrik Santrali ve Toprak Barajı, Adana için bir dönüm noktası oldu. '
          'Tarımda makineleşme ve fabrikaların açılması Adana\'yı devasa bir iş merkezi haline getirdi ve büyük göç dalgaları başladı.\n\n'
          '1957-1960 yılları arasında Başbakan Adnan Menderes’in özel ilgisiyle; kapalı betonarme ana kanalizasyon sistemine geçildi, Özler Caddesi genişletildi ve Ziyapaşa Bulvarı inşa edildi.',
        ),

        _tarihceBaslik('Modern Atılımlar ve Büyükşehir Statüsü (1984 - 1989)'),
        _tarihceMetin(
          '1984-1989 yılları arasında; Adnan Menderes Bulvarı, Yeni Adana projesi, toplu konut hamleleri ve belediye hizmetlerinin özelleştirilmesi gibi Türk belediyecilik tarihine damga vuran atılımlar gerçekleştirildi. '
          'Aynı dönem içinde Adana’ya "Büyükşehir" statüsü verildi.',
        ),
        const SizedBox(height: 30),
      ],
    ),
  );
}

Widget _tarihceBaslik(String baslik) {
  return Padding(
    padding: const EdgeInsets.only(top: 16.0, bottom: 6.0),
    child: Text(
      baslik,
      style: const TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold, 
        color: Colors.black,
      ),
    ),
  );
}

Widget _tarihceMetin(String icerik) {
  return Text(
    icerik,
    style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
    textAlign: TextAlign.justify,
  );
}

 Widget _buildMisyonVizyon() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKurumsalKart(
          baslik: 'MİSYONIMUZ',
          icerik: 'Büyükşehir Belediyesi sorumluluk alanında planlı, hızlı, etkin, şeffaf, adil ve vatandaş odaklı en iyi hizmeti sunmak.',
          ikon: Icons.flag_rounded,
          renk: Colors.blue.shade700,
        ),
        const SizedBox(height: 16),

        _buildKurumsalKart(
          baslik: 'VİZYONUMUZ',
          icerik: 'Lider ve öncü konumunu sürdürerek Türkiye ve Dünya’da örnek belediye olmak.',
          ikon: Icons.remove_red_eye_rounded,
          renk: Colors.teal.shade700,
        ),
        const SizedBox(height: 24),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'İLKELERİMİZ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 2),
        const SizedBox(height: 12),

        _buildIlkeMaddesi('Hukuktan, yasalardan ve dürüstlükten ödün vermeden herkese adil hizmet sunmak.'),
        _buildIlkeMaddesi('Kamu kaynaklarını yerinde kullanmak.'),
        _buildIlkeMaddesi('Kamu haklarını korumada cesur ve kararlı olmak.'),
        _buildIlkeMaddesi('Karar alma, uygulama ve eylemlerde şeffaf ve açık olmak.'),
        _buildIlkeMaddesi('Hizmette kalite, sürdürülebilirlik ve kalıcılığı hedeflemek.'),
        _buildIlkeMaddesi('Vatandaş-belediye işbirliği ile katılımcılık sağlamak.'),
        _buildIlkeMaddesi('Diğer kurum, kuruluş ve sivil toplum kuruluşları ile koordinasyon içinde çalışmak.'),
        _buildIlkeMaddesi('Faydası kent geneline yayılan projelere öncelik vermek.'),
        _buildIlkeMaddesi('Vatandaşın sorunlarına en kısa sürede çözüm bulmak.'),
        
        const SizedBox(height: 20),
      ],
    ),
  );
}

Widget _buildKurumsalKart({
  required String baslik,
  required String icerik,
  required IconData ikon,
  required Color renk,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: renk, width: 5)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: renk, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: renk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  icerik,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildIlkeMaddesi(String metin) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.blue.shade600,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            metin,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}
}