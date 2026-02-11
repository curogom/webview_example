import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_example/main.dart';

void main() {
  test('base URL and schemes are configured', () {
    expect(kBaseUrl.startsWith('https://'), isTrue);
    expect(kInAppSchemes.contains('http'), isTrue);
    expect(kInAppSchemes.contains('https'), isTrue);
  });
}
