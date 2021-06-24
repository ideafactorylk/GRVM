import 'package:flutter/material.dart';

class Products with ChangeNotifier {
  int bottleCount = 0;
  int packetCount = 0;
  int cupCount = 0;
  String currentProduct = '';
  String currentBarCode = '';
  bool updated = false;

  List<String> products = ['kkkkkkkkk'];

  void bottleCounts() {
    bottleCount++;
    notifyListeners();
  }

  void packetCounts() {
    packetCount++;
    notifyListeners();
  }

  void cupCounts() {
    cupCount++;
    notifyListeners();
  }

  void addProducts() {}

  void updatetrue() {
    updated = true;
  }

  void updatefalse() {
    updated = false;
  }
}
