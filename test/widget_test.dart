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
