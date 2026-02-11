# Example Policy Notes

## App IDs
- Native Android: `dev.curogom.test.webview.android`
- Native iOS: `dev.curogom.test.webview.ios`
- RN Android (Expo): `dev.curogom.test.webview.rn.android`
- RN iOS (Expo): `dev.curogom.test.webview.rn.ios`
- Flutter Android: `dev.curogom.test.webview.flutter.android`
- Flutter iOS: `dev.curogom.test.webview.flutter.ios`

## Demo-vs-Production Principle
- This repository intentionally uses a loose policy for demo readability.
- Each sample keeps inline comments for production defaults:
  - strict URL allowlist
  - strict deep-link return URL validation
  - idempotent callback handling
  - minimal external scheme queries/allowlist
  - privacy-safe logger rules

## Environment split guidance (comment only)
- Example projects keep single env.
- Production should split dev/stage/prod by BASE_URL, allowlist, signing keys, and app IDs.
