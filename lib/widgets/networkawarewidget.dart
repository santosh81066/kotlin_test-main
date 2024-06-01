// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../providers/networkprovider.dart';
// import 'networkoverlay.dart';

// class NetworkAwareWidget extends StatefulWidget {
//   final Widget? child;

//   const NetworkAwareWidget({
//     Key? key,
//     @required this.child,
//   }) : super(key: key);

//   @override
//   _NetworkAwareWidgetState createState() => _NetworkAwareWidgetState();
// }

// class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     final networkProvider = Provider.of<NetworkProvider>(context);
//     final navigator = Navigator.of(context);

//     if (networkProvider.networkStatus == ConnectivityResult.none) {
//       navigator.push(NetworkAlertOverlay());
//     } else {
//       if (navigator.canPop()) {
//         navigator.pop();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.child!;
//   }
// }
