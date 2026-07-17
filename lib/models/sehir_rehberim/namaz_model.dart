import 'package:flutter/material.dart';

class NamazVakti {
final String saat;
final String vakit;

NamazVakti({required this.saat, required this.vakit});

factory NamazVakti.fromJson(Map<String, dynamic> json) {
return NamazVakti(
saat: json['saat'] ?? '',
vakit: json['vakit'] ?? '',
);
}
}