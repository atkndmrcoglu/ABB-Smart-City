import 'package:flutter/material.dart';

class BaskanPage extends StatelessWidget {
  const BaskanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BAŞKAN'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Başkan'),
              Tab(text: 'Başkanın Mesajı'),
            ],
            indicatorColor: Colors.black,
          ),
        ),
        body: TabBarView(
          children: [
            _buildBaskan(context),
            _buildBaskaninMesaji(),
          ],
        ),
      ),
    );
  } 

  Widget _buildBaskan(BuildContext context) {
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

  Widget _buildBaskaninMesaji() {
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
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
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
}