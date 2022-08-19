import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CheckConnection {
  Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
          msg: "Not connected. Please check your network and try again");
      return false;
    } else {
      return true;
    }
  }
}
