import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<String> currencyController = ValueNotifier<String>('INR');

const String _kCurrencyKey = 'app_currency_code';

Future<void> initCurrency() async {
  try {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString(_kCurrencyKey) ?? 'INR';
    currencyController.value = code;
  } catch (_) {}
}

Future<void> setCurrencyPersisted(String code) async {
  currencyController.value = code;
  try {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kCurrencyKey, code);
  } catch (_) {}
}

class Currency {
  static const Map<String, double> _rateFromINR = {
    'INR': 1.0,
    'USD': 0.012,
    'GBP': 0.0095,
    'EUR': 0.011,
  };

  static String symbol(String code) {
    switch (code) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      default:
        return '';
    }
  }

  static double convertFromINR(double amountInINR, String targetCode) {
    final r = _rateFromINR[targetCode] ?? 1.0;
    return amountInINR * r;
  }

  static String formatINR(double amountInINR, {String? code}) {
    final c = code ?? currencyController.value;
    final v = convertFromINR(amountInINR, c);
    final s = symbol(c);
    return '$s${v.toStringAsFixed(0)}';
  }
}
