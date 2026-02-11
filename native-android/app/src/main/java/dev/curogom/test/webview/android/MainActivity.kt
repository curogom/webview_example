package dev.curogom.test.webview.android

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity

private const val TAG = "native-android-webview"
private const val BASE_URL = "https://choorai.com"

class MainActivity : AppCompatActivity() {
    private lateinit var webView: WebView
    private var lastHandledReturnUrl: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        webView = WebView(this)
        setContentView(webView)

        webView.settings.javaScriptEnabled = true
        // Example mode: loose security settings for demo compatibility.
        // Production default: tighten mixed content, file access, JS bridge.
        webView.settings.allowFileAccess = true
        webView.settings.allowContentAccess = true

        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                val url = request?.url?.toString().orEmpty()
                Log.i(TAG, "navigation url=$url")

                val uri = request?.url ?: return true
                if (uri.scheme == "http" || uri.scheme == "https") {
                    // Android production rule: return false for URLs WebView should handle.
                    return false
                }

                if (uri.toString().startsWith("intent://")) {
                    // Example requirement: unlimited intent handling in this sample.
                    // Production default: package/host/path allowlist + fallback_url 검증.
                    launchExternal(uri)
                    return true
                }

                launchExternal(uri)
                return true
            }
        }

        webView.loadUrl(BASE_URL)
        handleDeepLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleDeepLink(intent)
    }

    private fun handleDeepLink(intent: Intent?) {
        val data = intent?.data ?: return
        Log.i(TAG, "deep_link_received uri=$data")

        val isReturn = data.host == "pay" && data.path == "/return"
        if (!isReturn) return

        // Example mode: loose parsing.
        // Production default: strict returnUrl validation and idempotency by order key.
        val encoded = data.getQueryParameter("url") ?: return
        val decoded = Uri.decode(encoded)
        if (decoded == lastHandledReturnUrl) return
        lastHandledReturnUrl = decoded

        val returnUri = Uri.parse(decoded)
        if (returnUri.scheme == "http" || returnUri.scheme == "https") {
            webView.loadUrl(decoded)
            Log.i(TAG, "deep_link_loaded url=$decoded")
        }
    }

    private fun launchExternal(uri: Uri) {
        try {
            startActivity(Intent(Intent.ACTION_VIEW, uri))
            Log.i(TAG, "external_launch url=$uri success=true")
        } catch (e: Exception) {
            Log.e(TAG, "external_launch_error url=$uri reason=${e.message}")
        }
    }
}
