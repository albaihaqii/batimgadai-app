import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/app_green_header.dart';

class PaymentResult {
  final String status;
  final String transactionId;
  final String paymentType;
  const PaymentResult({
    required this.status,
    this.transactionId = '',
    this.paymentType = '',
  });
}

class MidtransWebViewScreen extends StatefulWidget {
  final String snapToken;
  final String title;
  const MidtransWebViewScreen({
    super.key,
    required this.snapToken,
    required this.title,
  });

  @override
  State<MidtransWebViewScreen> createState() => _MidtransWebViewScreenState();
}

class _MidtransWebViewScreenState extends State<MidtransWebViewScreen> {
  late final WebViewController _ctrl;
  bool _loading = true;

  static const _snapBase = 'https://app.sandbox.midtrans.com/snap/v2/vtweb/';

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onNavigationRequest: (req) {
          final url = req.url;
          debugPrint('[WebView] $url');
          final uri = Uri.tryParse(url);
          final txId = uri?.queryParameters['transaction_id'] ?? '';
          final payType = uri?.queryParameters['payment_type'] ?? '';

          if (_isSuccess(url)) {
            Navigator.pop(
                context,
                PaymentResult(
                  status: 'success',
                  transactionId: txId,
                  paymentType: payType,
                ));
            return NavigationDecision.prevent;
          }
          if (_isPending(url)) {
            Navigator.pop(
                context,
                PaymentResult(
                  status: 'pending',
                  transactionId: txId,
                  paymentType: payType,
                ));
            return NavigationDecision.prevent;
          }
          if (_isCancel(url)) {
            Navigator.pop(context, const PaymentResult(status: 'cancel'));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse('$_snapBase${widget.snapToken}'));
  }

  bool _isSuccess(String url) =>
      url.contains('transaction_status=capture') ||
      url.contains('transaction_status=settlement') ||
      url.contains('transaction_status=success') ||
      url.contains('status_code=200');

  bool _isPending(String url) => url.contains('transaction_status=pending');

  bool _isCancel(String url) =>
      url.contains('transaction_status=cancel') ||
      url.contains('transaction_status=deny') ||
      url.contains('transaction_status=failure') ||
      url.contains('status_code=202');

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFB6D96C),
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            AppGreenHeader(title: widget.title),
            Expanded(
              child: Stack(children: [
                WebViewWidget(controller: _ctrl),
                if (_loading)
                  const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
