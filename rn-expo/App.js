import { useEffect, useMemo, useRef, useState } from 'react';
import { Platform, SafeAreaView, StyleSheet, Text, View, Linking } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { WebView } from 'react-native-webview';
import * as ExpoLinking from 'expo-linking';

const BASE_URL = 'https://choorai.com';
const ALLOW_IN_APP_SCHEMES = new Set(['http', 'https']);

const logger = {
  log(event, payload = {}) {
    const safe = { ...payload };
    if (safe.token) safe.token = '[REDACTED]';
    console.log(`[rn-expo][${event}]`, safe);
  },
};

export default function App() {
  const webRef = useRef(null);
  const [lastHandledReturn, setLastHandledReturn] = useState(null);
  const [currentUrl, setCurrentUrl] = useState(BASE_URL);
  const linking = useMemo(() => ExpoLinking, []);

  useEffect(() => {
    const handleUrl = ({ url }) => {
      logger.log('deep_link_received', { url });
      handleDeepLink(url);
    };

    const sub = linking.addEventListener('url', handleUrl);
    linking.getInitialURL().then((url) => {
      if (url) {
        logger.log('deep_link_initial', { url });
        handleDeepLink(url);
      }
    });

    return () => sub.remove();
  }, []);

  const handleDeepLink = (rawUrl) => {
    try {
      const parsed = new URL(rawUrl);
      const isReturn = parsed.hostname === 'pay' && parsed.pathname === '/return';
      if (!isReturn) return;

      // Example mode: loose parsing. Production should enforce allowlist + required params.
      const encoded = parsed.searchParams.get('url');
      if (!encoded) {
        logger.log('deep_link_error', { reason: 'missing_url' });
        return;
      }
      const decoded = decodeURIComponent(encoded);
      if (decoded === lastHandledReturn) {
        logger.log('deep_link_ignored', { reason: 'duplicate', decoded });
        return;
      }
      setLastHandledReturn(decoded);
      setCurrentUrl(decoded);
      webRef.current?.injectJavaScript(`window.location.href = ${JSON.stringify(decoded)}; true;`);
      logger.log('deep_link_loaded', { decoded });
    } catch (error) {
      logger.log('deep_link_error', { reason: String(error), rawUrl });
    }
  };

  const openExternal = async (url) => {
    try {
      const canOpen = await Linking.canOpenURL(url);
      if (!canOpen) {
        logger.log('external_launch_error', { reason: 'cannot_open', url });
        return;
      }
      await Linking.openURL(url);
      logger.log('external_launch', { url, success: true });
    } catch (error) {
      logger.log('external_launch_error', { reason: String(error), url });
    }
  };

  const onShouldStart = (request) => {
    const url = request?.url ?? '';
    logger.log('navigation', { url, platform: Platform.OS, isTopFrame: request?.isTopFrame });

    try {
      const parsed = new URL(url);
      if (ALLOW_IN_APP_SCHEMES.has(parsed.protocol.replace(':', ''))) {
        return true;
      }
    } catch {
      logger.log('navigation_blocked', { reason: 'malformed_url', url });
      return false;
    }

    // Example requirement: allow all intent:// routes in this demo.
    // Production default: allowlist package/host/path + fallback_url validation.
    if (url.startsWith('intent://')) {
      openExternal(url);
      return false;
    }

    openExternal(url);
    return false;
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar style="dark" />
      <View style={styles.header}>
        <Text style={styles.title}>RN Expo WebView Example</Text>
      </View>
      <WebView
        ref={webRef}
        source={{ uri: currentUrl }}
        onShouldStartLoadWithRequest={onShouldStart}
        javaScriptEnabled
        mixedContentMode="always"
        onLoadStart={(e) => logger.log('load_start', { url: e.nativeEvent.url })}
        onLoadEnd={(e) => logger.log('load_end', { url: e.nativeEvent.url })}
        onError={(e) => logger.log('web_error', { description: e.nativeEvent.description, url: e.nativeEvent.url })}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f6f8fb',
  },
  header: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#dce3ef',
    backgroundColor: '#ffffff',
  },
  title: {
    fontSize: 15,
    fontWeight: '700',
    color: '#1f2a44',
  },
});
