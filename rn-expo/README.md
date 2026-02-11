# React Native (Expo) WebView Example

## 개요
Expo + `react-native-webview` 기반 단일 WebView 컨테이너 예제입니다.

- App ID(Android): `dev.curogom.test.webview.rn.android`
- Bundle ID(iOS): `dev.curogom.test.webview.rn.ios`
- Scheme: `wvrn`
- Deep link: `myapp://pay/return?url={encoded}`, `wvrn://pay/return?url={encoded}`

## 핵심 구현
- 파일: `/Users/curo/dev/webview_example/rn-expo/App.js`
- `onShouldStartLoadWithRequest`로 URL 라우팅
- `http/https`는 인앱 로딩
- 비-http(s) 스킴은 `Linking.openURL`로 외부 앱 실행
- 딥링크 복귀 처리 후 WebView 재로딩
- 로깅: navigation / external launch / deep link 이벤트

## 실행
```bash
cd /Users/curo/dev/webview_example/rn-expo
npm install
npx expo start
```

## 검증
```bash
cd /Users/curo/dev/webview_example/rn-expo
npx expo export --platform all --clear
npx expo-doctor
```

번들 산출물:
- `/Users/curo/dev/webview_example/rn-expo/dist`

## 메모
예제 모드에서는 일부 정책을 느슨하게 유지합니다. 운영 시에는 intent/scheme allowlist, return URL 검증, 민감 로그 마스킹 강화를 권장합니다.
