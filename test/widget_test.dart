// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:harcama_takip/main.dart';

void main() {
  testWidgets('Login screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const HarcamaTakipApp());

    expect(find.text('Giriş Yap'), findsOneWidget);
    expect(find.text('E-posta'), findsOneWidget);
    expect(find.text('Şifre'), findsOneWidget);
    expect(find.text('Hesabınız yok mu? Kayıt olun'), findsOneWidget);
  });
}
