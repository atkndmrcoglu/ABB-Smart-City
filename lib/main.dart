import 'dart:io'; // 1. SSL bypass kuralı için bu kütüphaneyi ekledik
import 'package:flutter/material.dart';
import 'package:smartcity/home_page.dart'; // Import your homepage file

// 2. Sertifika kontrolünü localhost ve yerel ağ için esneten sınıf
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Localhost, 127.0.0.1 veya Android emülatör IP'sine giden isteklerde sertifika sorma
        return host == "127.0.0.1" || host == "localhost" || host == "10.0.2.2";
      };
  }
}

void main() {
  // 3. Uygulama ayağa kalkmadan önce HTTP kurallarımızı küresel olarak aktif ediyoruz
  HttpOverrides.global = MyHttpOverrides();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart City',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HOMEPAGE(), // Set HomePage as the root screen
    );
  }
}