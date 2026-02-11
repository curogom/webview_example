import 'dart:developer' as developer;
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

const String kBaseUrl = 'https://choorai.com';
const String kReturnPath = '/pay/return';
const Set<String> kInAppSchemes = {'http', 'https'};

void main() {
  runApp(const WebViewContainerApp());
}

class AppLogger {
  static void event(String event, Map<String, Object?> data) {
    final safe = data.map((key, value) {
      if (key.toLowerCase().contains('token')) return MapEntry(key, '[REDACTED]');
      return MapEntry(key, value);
    });
    developer.log('$event $safe', name: 'flutter-webview-example');
  }
}

class WebViewContainerApp extends StatelessWidget {
  const WebViewContainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final AppLinks _appLinks = AppLinks();
  InAppWebViewController? _controller;
  String? _lastHandledReturnUrl;

  @override
  void initState() {
    super.initState();
    _listenDeepLinks();
  }

  void _listenDeepLinks() {
    _appLinks.uriLinkStream.listen((Uri uri) async {
      AppLogger.event('deep_link_received', {'uri': uri.toString()});
      await _handleDeepLink(uri);
    }, onError: (Object error) {
      AppLogger.event('deep_link_error', {'error': error.toString()});
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    // Example mode: parse loosely and fail safe.
    // Production default: strict host/path/allowlist + idempotency with orderId.
    final bool isReturn = uri.path == kReturnPath || uri.host == 'pay';
    if (!isReturn) {
      return;
    }

    final encoded = uri.queryParameters['url'];
    if (encoded == null || encoded.isEmpty) {
      AppLogger.event('deep_link_error', {'reason': 'missing_url'});
      return;
    }

    final decoded = Uri.decodeComponent(encoded);
    if (_lastHandledReturnUrl == decoded) {
      AppLogger.event('deep_link_ignored', {'reason': 'duplicate', 'url': decoded});
      return;
    }

    final returnUri = Uri.tryParse(decoded);
    if (returnUri == null) {
      AppLogger.event('deep_link_error', {'reason': 'malformed_url', 'raw': decoded});
      return;
    }

    _lastHandledReturnUrl = decoded;
    await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri.uri(returnUri)));
    AppLogger.event('deep_link_loaded', {'url': decoded});
  }

  Future<NavigationActionPolicy> _handleNavigation(NavigationAction action) async {
    final rawUrl = action.request.url?.toString() ?? '';
    final uri = Uri.tryParse(rawUrl);

    AppLogger.event('navigation', {
      'url': rawUrl,
      'isForMainFrame': action.isForMainFrame,
      'platform': Platform.operatingSystem,
    });

    if (uri == null) {
      AppLogger.event('navigation_blocked', {'reason': 'malformed_url', 'url': rawUrl});
      return NavigationActionPolicy.CANCEL;
    }

    if (kInAppSchemes.contains(uri.scheme)) {
      return NavigationActionPolicy.ALLOW;
    }

    // Example mode: allow all non-http(s) schemes to external apps.
    // Production default: only allow known schemes + host/path validation.
    await _launchExternal(uri);
    return NavigationActionPolicy.CANCEL;
  }

  Future<void> _launchExternal(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      AppLogger.event('external_launch', {'url': uri.toString(), 'success': ok});
      if (!ok) {
        AppLogger.event('external_launch_error', {'reason': 'launch_returned_false', 'url': uri.toString()});
      }
    } catch (e) {
      AppLogger.event('external_launch_error', {'reason': e.toString(), 'url': uri.toString()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(kBaseUrl)),
          initialSettings: InAppWebViewSettings(
            useShouldOverrideUrlLoading: true,
            javaScriptEnabled: true,
            // Example mode (loose): allow mixed content for demo compatibility.
            // Production default: strict mixed-content policy and minimal file access.
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
          ),
          onWebViewCreated: (controller) {
            _controller = controller;
          },
          onLoadStart: (_, url) {
            AppLogger.event('load_start', {'url': url.toString()});
          },
          onLoadStop: (_, url) {
            AppLogger.event('load_stop', {'url': url.toString()});
          },
          shouldOverrideUrlLoading: (_, action) => _handleNavigation(action),
          onReceivedError: (_, request, error) {
            AppLogger.event('web_error', {
              'url': request.url.toString(),
              'code': error.type.toString(),
              'message': error.description,
            });
          },
        ),
      ),
    );
  }
}
