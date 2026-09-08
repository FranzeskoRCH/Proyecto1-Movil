import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movil_proyecto/features/home/ui/widgets/app_bottom_nav_bar.dart';

void main() {
  testWidgets('bottom nav renders all tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppBottomNavBar(currentIndex: 0, onTap: (_) {}),
        ),
      ),
    );

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Explorar'), findsOneWidget);
    expect(find.text('Crear'), findsOneWidget);
    expect(find.text('Proyectos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });
}
