# Native iOS WebView Example

## 개요
iOS 네이티브(`WKWebView`) 단일 컨테이너 예제입니다.

- Bundle ID: `dev.curogom.test.webview.ios`
- Deep link: `myapp://pay/return?url={encoded}`, `wvnative://pay/return?url={encoded}`
- Xcode 프로젝트: `/Users/curo/dev/webview_example/native-ios/WebViewNativeiOS.xcodeproj`

## 핵심 구현
- 파일: `/Users/curo/dev/webview_example/native-ios/WebViewNativeiOS/WebViewController.swift`
- `WKNavigationDelegate`로 URL 라우팅
- `http/https`는 인앱 로딩
- 비-http(s) 스킴 외부 실행
- 딥링크 복귀 후 WebView 재로딩

## 실행/빌드
Xcode에서 `WebViewNativeiOS.xcodeproj`를 열어 실행하거나, CLI로 빌드 검증:

```bash
cd /Users/curo/dev/webview_example/native-ios
xcodebuild -project WebViewNativeiOS.xcodeproj \
  -scheme WebViewNativeiOS \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /Users/curo/dev/webview_example/native-ios/.derived \
  CODE_SIGNING_ALLOWED=NO build
```

앱 산출물:
- `/Users/curo/dev/webview_example/native-ios/.derived/Build/Products/Debug-iphoneos/WebViewNativeiOS.app`

## 메모
예제 모드에서는 설정을 단순화했습니다. 운영 시에는 `LSApplicationQueriesSchemes` 최소화, return URL 엄격 검증, 민감 로그 마스킹을 적용하세요.
