import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bhoomiiq_frontend/main.dart';

void main() {
  testWidgets('BhoomiIQ smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BhoomiIQApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('BhoomiIQ'), findsAtLeast(1));
  });
}
