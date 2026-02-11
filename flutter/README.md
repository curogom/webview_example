# Flutter WebView Example

## 개요
`flutter_inappwebview` 기반 단일 WebView 컨테이너 예제입니다.

- App ID(Android): `dev.curogom.test.webview.flutter.android`
- Bundle ID(iOS): `dev.curogom.test.webview.flutter.ios`
- Deep link: `myapp://pay/return?url={encoded}`, `wvflutter://pay/return?url={encoded}`

## 핵심 구현
- 파일: `/Users/curo/dev/webview_example/flutter/lib/main.dart`
- `useShouldOverrideUrlLoading=true`
- `http/https`는 WebView 내부 처리
- 비-http(s) 스킴은 외부 앱 실행
- 딥링크 수신 후 `url` 파라미터 decode -> WebView 재로딩
- 로깅: navigation / external launch / deep link 이벤트

## 실행
```bash
cd /Users/curo/dev/webview_example/flutter
fvm spawn stable pub get
fvm spawn stable run
```

## 테스트/빌드
```bash
cd /Users/curo/dev/webview_example/flutter
fvm spawn stable test
fvm spawn stable build apk --debug
```

APK 산출물:
- `/Users/curo/dev/webview_example/flutter/build/app/outputs/flutter-apk/app-debug.apk`

## 메모
예제 특성상 일부 보안 설정을 느슨하게 두었습니다. 운영 환경에서는 allowlist, return URL strict validation, 최소 권한/스킴 정책으로 강화해야 합니다.
