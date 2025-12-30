// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_custom_and_mix/main.dart';

void main() {
  testWidgets('AuthServiceTestPage basic structure test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the page has the expected title in the AppBar.
    expect(find.text('AuthService测试'), findsOneWidget);

    // Verify that the initial status text is displayed.
    expect(find.text('服务状态：未启动AuthService'), findsOneWidget);

    // Verify that all three buttons are present.
    expect(find.text('启动AuthService'), findsOneWidget);
    expect(find.text('加载微信链接并识别二维码'), findsOneWidget);
    expect(find.text('停止AuthService'), findsOneWidget);

    // Verify that WebView status is initially displayed.
    expect(find.text('WebView状态：WebView未加载'), findsOneWidget);
  });
}
