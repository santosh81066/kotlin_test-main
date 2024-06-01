// import 'dart:io';
// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';
// import '../controller/flutter_functions.dart';

// class InsertProfile extends StatelessWidget {
//   const InsertProfile(
//       {super.key,
//       this.buttonName,
//       this.imageIcon,
//       this.insertCategory,
//       this.label,
//       this.index});

//   final String? buttonName;
//   final String? label;
//   final Function? imageIcon;

//   final Function? insertCategory;
//   final String? index;
//   @override
//   Widget build(BuildContext context) {
//     var flutterFunctions = Provider.of<FlutterFunctions>(context);
//     return Column(
//       children: [
//         flutterFunctions.imageFileList.containsKey(index)
//             ? SizedBox(
//                 width: 30,
//                 child: Image.file(
//                     File(flutterFunctions.imageFileList['profile']!.path)))
//             : TextButton.icon(
//                 onPressed: () {
//                   imageIcon!();
//                 },
//                 icon: const Icon(Icons.image),
//                 label: Text(label!)),
//       ],
//     );
//   }
// }
