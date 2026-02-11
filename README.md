# webview_example

WebView 포팅 + 결제/복귀 흐름을 비교하기 위한 멀티 프레임워크 예제 모음입니다.

## 프로젝트 구성
- Flutter: `/Users/curo/dev/webview_example/flutter`
- React Native (Expo): `/Users/curo/dev/webview_example/rn-expo`
- Native Android: `/Users/curo/dev/webview_example/native-android`
- Native iOS: `/Users/curo/dev/webview_example/native-ios`
- 문서: `/Users/curo/dev/webview_example/docs`

## App ID 규칙
- Native Android: `dev.curogom.test.webview.android`
- Native iOS: `dev.curogom.test.webview.ios`
- RN Android: `dev.curogom.test.webview.rn.android`
- RN iOS: `dev.curogom.test.webview.rn.ios`
- Flutter Android: `dev.curogom.test.webview.flutter.android`
- Flutter iOS: `dev.curogom.test.webview.flutter.ios`

## 공통 동작 정책(예제 모드)
- `http/https`는 WebView 내부 로딩
- 그 외 스킴은 외부 앱 실행 시도
- 딥링크 복귀: `myapp://pay/return?url={encoded}`
- 로깅: `navigation`, `external_launch`, `deep_link_received` 중심

주의: 이 저장소는 주니어 온보딩용 예제로, 보안/검증 정책을 일부 느슨하게 둔 상태입니다. 각 프레임워크 코드에는 운영 환경 권장 규칙(allowlist, strict validation, 최소 scheme 노출)이 주석으로 포함되어 있습니다.

## 빠른 검증 상태
- Flutter: 테스트 통과, Android APK 빌드 성공
- RN(Expo): `expo export` 성공, `expo-doctor` 통과
- Native Android: `assembleDebug` 성공
- Native iOS: `xcodebuild` 성공(generic iOS target)

## 참고 문서
- 결제사/간편결제 레퍼런스: `/Users/curo/dev/webview_example/docs/kr-payment-providers.md`
- 정책 노트: `/Users/curo/dev/webview_example/docs/policy-notes.md`
