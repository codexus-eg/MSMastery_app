// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/network/local/shared_pref_helper.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Result of the hosted checkout, returned via `Navigator.pop`.
enum PaymentResult { success, fail, pending, cancelled }

class PaymentWebviewScreen extends StatefulWidget {
  PaymentWebviewScreen({super.key, required this.url});
  String url;
  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  late final WebViewController controller;

  /// One-shot guard: the gateway fires navigation events more than once for a
  /// single redirect (main frame + redirect chain), so without this the result
  /// would be handled — and the screen popped — multiple times.
  bool _handled = false;
  bool _loading = true;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() => _loading = true);
            // Server-side (302) redirects may skip onNavigationRequest, so we
            // also inspect the resolved url here. The guard keeps it one-shot.
            //    _resolveResult(url);
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            /*
            if (_resolveResult(request.url)) {
              // Already a terminal url — stop the webview from loading it.
              return NavigationDecision.prevent;
            }
            */
            return NavigationDecision.navigate;
          },
          onUrlChange: (urlChange) {
            _resolveResult(urlChange.url!);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  /// Returns `true` when [url] is a terminal (success/fail/pending) redirect.
  /// Closes the screen exactly once, returning the matching [PaymentResult].
  bool _resolveResult(String url) {
    if (_handled) return true;
    debugPrint('ssssssssssss $url');
    PaymentResult? result;
    if (url.contains('success')) {
      result = PaymentResult.success;
    } else if (url.contains('error') || url.contains('fail')) {
      result = PaymentResult.fail;
    } else if (url.contains('pending')) {
      result = PaymentResult.pending;
    }

    if (result == null) return false;

    _handled = true;
    debugPrint('PaymentWebview: $result ($url)');
    // Defer the pop so we never pop during the synchronous navigation callback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, result);
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Treat a manual back-press as a cancellation (only if not already done).
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!_handled) {
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.warning,
            title: 'خلي بالك',
            message: S.of(context).sure_exit,
            primaryActionText:
                SharedPrefHelper.getData('isAr') ?? true ? 'خروج' : 'Exit',
            onPrimaryAction: () {
              _handled = true;
              Navigator.pop(context);
              Navigator.pop(context, PaymentResult.cancelled);
            },
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).proceed_to_payment),
          bottom: _loading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: _progress == 0 ? null : _progress / 100,
                    minHeight: 3,
                  ),
                )
              : null,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (_loading && _progress < 100)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
