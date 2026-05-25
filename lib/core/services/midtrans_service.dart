import 'package:midtrans_sdk/midtrans_sdk.dart';
import '../../main.dart';

class MidtransService {
  static MidtransSDK? get _sdk => midtransSDK;

  static bool get isReady => _sdk != null;

  static void setCallback(Function(TransactionResult) onFinished) {
    _sdk?.setTransactionFinishedCallback(onFinished);
  }

  static void removeCallback() {
    _sdk?.removeTransactionFinishedCallback();
  }

  static void startPayment(String snapToken) {
    _sdk?.startPaymentUiFlow(token: snapToken);
  }
}
