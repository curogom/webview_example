# Native Android WebView Example

## 개요
Android 네이티브 WebView 단일 컨테이너 예제입니다.

- App ID: `dev.curogom.test.webview.android`
- Deep link: `myapp://pay/return?url={encoded}`, `wvnative://pay/return?url={encoded}`

## 핵심 구현
- 파일: `/Users/curo/dev/webview_example/native-android/app/src/main/java/dev/curogom/test/webview/android/MainActivity.kt`
- `shouldOverrideUrlLoading` 기반 URL 라우팅
- `http/https`는 WebView 처리
- 비-http(s) 스킴 외부 실행
- 딥링크 복귀 후 WebView 재로딩

## 빌드
```bash
cd /Users/curo/dev/webview_example/native-android
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
./gradlew assembleDebug
```

APK 산출물:
- `/Users/curo/dev/webview_example/native-android/app/build/outputs/apk/debug/app-debug.apk`

## 메모
예제 특성상 일부 정책을 느슨하게 둡니다. 운영 환경에서는 URL allowlist, fallback 검증, 최소 queries 등록 정책을 적용하세요.
