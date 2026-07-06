import 'package:flutter/material.dart';

class BaskanPage extends StatelessWidget {
  const BaskanPage({super.key});

  @override
  Widget build(BuildContext context) {
  TextStyle(
      fontSize: 15,
      color: Color(0xFF6B809B),
      height: 1.5,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'BAŞKAN',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                'assets/baskan.png', // Update with your image asset path
                width: MediaQuery.of(context).size.width,
                height: 320,
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 24),

            // 2. Name Heading
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'ZEYDAN KARALAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF2D3142),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Biography Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Introduction
                  const Text(
                    '1958 yılında Adana’nın Seyhan ilçesinde, on çocuklu bir ailenin altıncı çocuğu olarak dünyaya geldi. İlkokul, ortaokul, lise ve üniversiteyi Adana’da okudu. 1980 yılında Çukurova Üniversitesi Makina Mühendisliği bölümünden mezun oldu. 1982 yılında Nuray Karalar ile evlendi. Biri kız, ikisi erkek olmak üzere üç çocuk babasıdır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B809B),
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(color: Colors.black12),
                  const SizedBox(height: 16),
                  
                  // Section: İş Hayatı
                  const Text('İş Hayatı', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3142),
                  )),
                  const SizedBox(height: 12),
                  const Text(
                    '1981’de, 23 yaşında Makine Mühendisleri Odası Başkanlığına seçildi. 2 yıl bölge başkanlığı ve üst kurul (TMMOB) delegeliği yaptı. Oda tarihinde seçilen en genç başkandır.\n\n'
                    '1979 – 1985 yılları arasında Çukobirlik’te İplik İşletme Şefi olarak çalıştı. 1985 – 1991 yılları arasında Alman AEG ETİ Endüstri A.Ş.’de Müşteri Hizmetleri Yöneticiliği yaptı.\n\n'
                    '1991 – 1996 arasında Çukobirlik İplik Dokuma Fabrika Müdürü ve Teknik Genel Müdür Yardımcılığı görevlerinde bulundu.\n\n'
                    '1996 – 2007 yılları arasında Okan Tekstil A.Ş.’de Genel Müdürlük yaptı. Kazakistan’da Okan–Antriko Entegre Tekstil Fabrikası’nın Genel Müdürlüğü’nü yaptı.\n\n'
                    '2005 yılında kendi şirketi A-TEKS Mühendislik’i, 2008’de ikinci şirketi Başkent Pres’i kurdu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B809B),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Colors.black12),
                  const SizedBox(height: 16),

                  // Section: Siyasi Geçmişi
                  const Text('Siyasi Geçmişi', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3142),
                  )),
                  const SizedBox(height: 12),
                  const Text(
                    '1977’de Demokratik Sol Yüksek Öğrenim Derneğini kurdu ve yönetim kurulu başkanlığını yaptı.\n\n'
                    '1977 – 1980 arasında CHP İl Gençlik Kolları Saymanlığı ve Merkez İlçe Gençlik Kolları Başkanlığı yaptı.\n\n'
                    '7 Temmuz 2010’da Cumhuriyet Halk Partisi Merkez Yürütme Kurulu tarafından CHP Adana İl Başkanlığına atandı, 23 Ocak 2011’de yapılan CHP Adana İl Kongresi’nde delegelerin oylarıyla başkanlığa seçildi.\n\n'
                    '2014 yerel seçimlerinde, Ak Partili mevcut başkana karşı yarışarak Seyhan Belediye Başkanı seçildi.\n\n'
                    '31 Mart 2019 yerel seçimlerinde MHP’li mevcut başkana karşı yarıştı ve Adana Büyükşehir Belediye Başkanı olarak seçildi.\n\n'
                    '2022’de Dünya Belediyeler Birliği Sosyal İçerme Komitesi Eş Başkanı oldu. 2024 yılında Türkiye Belediyeler Birliği birinci başkan vekili seçildi. Halen ADSİAD ve MMO üyesidir.\n\n'
                    'İttifakın dağılması sonrası CHP adayı olarak girdiği 31 Mart 2024 yerel seçimlerinde yeniden Adana Büyükşehir Belediye Başkanlığı’na seçildi. Adana tarihinde üst üste iki kez seçilen ilk CHP’li Büyükşehir Belediye Başkanı’dır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B809B),
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}