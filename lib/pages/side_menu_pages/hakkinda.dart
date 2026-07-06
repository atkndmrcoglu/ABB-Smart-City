import 'package:flutter/material.dart';

class HakkindaPage extends StatelessWidget {
  const HakkindaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HAKKINDA'),
      ),
      body: Center(
        child: Column(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 300,
              width: 300,
            ),
            const SizedBox(height: 20),
            const Text(
              'ADANA BÜYÜKŞEHİR BELEDİYESİ BİLGİ İŞLEM DAİRE BAŞKANLIĞI TARAFINDAN GELİŞTİRİLMİŞTİR.',
              style: TextStyle(fontSize: 20,),
               textAlign: TextAlign.center
            ),
          ],
        ),
      ),
    );
  }
}