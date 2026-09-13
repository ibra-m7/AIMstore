import 'package:aimstore/features/auth/presentation/widgets/profile_luxe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raoah_alkhamsa/features/auth/presentation/widgets/profile_luxe.dart';

void main() {
  testWidgets('luxe wave band preview', (tester) async {
    tester.view.physicalSize = const Size(390, 140);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: ColoredBox(
          color: Colors.white,
          child: SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(painter: LuxeWavePainter()),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('luxe_wave_band.png'),
    );
  });
}
