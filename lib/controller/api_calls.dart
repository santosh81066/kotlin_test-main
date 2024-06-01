// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:http_parser/http_parser.dart' as parser;

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:kotlin_test/controller/auth.dart';
// import 'package:kotlin_test/models/booking.dart';
// import 'package:kotlin_test/models/carouselimages.dart';
// import 'package:kotlin_test/models/horoscope.dart';
// import 'package:kotlin_test/models/profiledata.dart';
// import 'package:kotlin_test/models/purohithusers.dart';
// import 'package:kotlin_test/utils/purohitapi.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:http/retry.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:http/http.dart' as http;
// import 'package:open_file/open_file.dart';

// import '../models/categories.dart';
// import '../models/familymem.dart';
// import '../models/location.dart';
// import '../utils/permissionservice.dart';
// import 'flutter_functions.dart';

// class ApiCalls extends ChangeNotifier {
//   String? filterlocation;
//   String? token;
//   var isloading = false;
//   String? voiceToken;

//   Location? location;
//   String? fToken;
//   Map? purohit;
//   PurohitUsers? purohitUsers;
//   Bookings? userBookings;

//   List? users = [];
//   Horoscope? horoscope;
//   ProfileData? userDetails;
//   String? messages;
//   Categories? categorieModel;
//   int? locationId;
//   List<int> selectedCatId = [];

//   String? sub;
//   FamilyMembers? familyMember;
//   Map? user;
//   List<int> selectedbox = [];
//   SliderImages? carousel;
//   void updateId(int val) {
//     if (selectedbox.contains(val)) {
//       selectedbox.remove(val);
//     } else {
//       selectedbox.add(val);
//     }
//     notifyListeners();
//   }

//   void update(String token) {
//     this.token = token;
//   }

//   void updatesubcat(String cat) {
//     sub = cat;
//     notifyListeners();
//   }

//   void selectedCat(int val) {
//     if (selectedCatId.contains(val)) {
//       selectedCatId.remove(val);
//     } else {
//       selectedCatId.add(val);
//     }
//     notifyListeners();
//   }

//   void updateFtoken(String token) {
//     fToken = token;
//     notifyListeners();
//   }

//   void loading(String function, bool load) {
//     isloading = load;
//     notifyListeners();
//     print('isloading:$isloading');
//   }

//   Future<void> sendBooking(
//       {int? ctypeId,
//       String? address,
//       String? dateAndTime,
//       int? purohithId,
//       int? amount,
//       String? goutram,
//       String? status,
//       bool? otp,
//       BuildContext? context}) async {
//     int? startOtp;
//     int? endOtp;

//     if (otp == true) {
//       startOtp = generateRandomNumber();
//       endOtp = generateRandomNumber();
//     }
//     final url =
//         '${PurohitApi().baseUrl}${PurohitApi().catId}${ctypeId.toString()}/${PurohitApi().purohithId}${purohithId ?? ""}';
//     loading('send booking should be true', true);

//     final client = RetryClient(
//       http.Client(),
//       retries: 4,
//       when: (response) {
//         return response.statusCode == 401 ? true : false;
//       },
//       onRetry: (req, res, retryCount) async {
//         if (retryCount == 0 && res?.statusCode == 401) {
//           var accessToken =
//               await Provider.of<AuthenticationDetails>(context!, listen: false)
//                   .restoreAccessToken();
//           req.headers['Authorization'] = accessToken;
//         }
//       },
//     );
//     var response = await client.post(Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Authorization': token!
//         },
//         body: json.encode({
//           "address": address,
//           "time": dateAndTime,
//           "amount": amount,
//           "startotp": startOtp,
//           "endotp": endOtp,
//           "status": status,
//           "goutram": goutram
//         }));
//     var userDetails = json.decode(response.body);
//     switch (response.statusCode) {
//       case 201:
//         showDialog(
//           context: context!,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Success'),
//               content: const Text('Booking sent successfully'),
//               actions: [
//                 ElevatedButton(
//                   child: const Text('OK'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );

//         loading('send booking should be false', false);
//         break;
//       case 500:
//         messages = userDetails['messages'].toString();
//         //loading('send booking should be false');
//         break;
//       case 400:
//         messages = userDetails['messages'].toString();
//         showDialog(
//           context: context!,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Error'),
//               content: Text(messages!),
//               actions: [
//                 ElevatedButton(
//                   child: const Text('OK'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//         //loading('send booking should be false');
//         break;
//     }

//     notifyListeners();
//   }

//   Future updateUser(
//       String? username, String? pob, String? dob, BuildContext context) async {
//     const url = "https://purohithuluapp.in/saveprofile";
//     String randomLetters = generateRandomLetters(10);
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     loading('update user should be true', true);
//     try {
//       final client = RetryClient(
//         http.Client(),
//         retries: 4,
//         when: (response) {
//           return response.statusCode == 401 ? true : false;
//         },
//         onRetry: (req, res, retryCount) async {
//           if (retryCount == 0 && res?.statusCode == 401) {
//             var accessToken =
//                 await Provider.of<AuthenticationDetails>(context, listen: false)
//                     .restoreAccessToken();
//             // Only this block can run (once) until done

//             req.headers['Authorization'] = accessToken;
//           }
//         },
//       );

//       var request = http.MultipartRequest('POST', Uri.parse(url));
//       request.headers.addAll({
//         'Authorization': token!,
//       });
//       request.fields['username'] = username!;
//       request.fields['dob'] = dob!;
//       request.fields['pob'] = pob!;
//       if (userDetails!.data![0].profilepic == null) {
//         request.fields['profilepic'] = "${randomLetters}_profilepic";
//       }
//       if (userDetails!.data![0].xfile != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//             'image', userDetails!.data![0].xfile!.path));
//       }

//       var response = await client.send(request);
//       var responseBody = await response.stream.bytesToString();
//       var jsonResponse = json.decode(responseBody);

//       if (response.statusCode == 200) {
//         prefs.setBool('profile', true);
//       }
//       loading('update user should be false', false);
//       return jsonResponse["success"];
//     } catch (e) {
//       if (e is FormatException) {
//         // handle the format exception here
//       } else {
//         // handle other exceptions here
//       }

//       return false;
//     }
//   }

//   void setImageFile(XFile? file) {
//     userDetails!.data![0].xfile = file;
//     notifyListeners();
//   }

//   Future<void> updateUserModel(String id, UserProfileData newUser) async {
//     final prodIndex = userDetails!.data!.indexWhere((prod) => prod.id == id);
//     if (prodIndex != -1) {
//       userDetails!.data![prodIndex] = newUser;
//       notifyListeners();
//     }
//     notifyListeners();
//   }

//   String generateRandomLetters(int length) {
//     var random = Random();
//     var letters = List.generate(length, (_) => random.nextInt(26) + 97);
//     return String.fromCharCodes(letters);
//   }

//   int generateRandomNumber() {
//     var random = Random();
//     return random.nextInt(9000) + 1000;
//   }

//   Future<void> sendOfferToRemoteUser(BuildContext context) async {
//     final url = '${PurohitApi().baseUrl}${PurohitApi().voicecalling}';

//     final client = RetryClient(
//       http.Client(),
//       retries: 4,
//       when: (response) {
//         return response.statusCode == 401 ? true : false;
//       },
//       onRetry: (req, res, retryCount) async {
//         if (retryCount == 0 && res?.statusCode == 401) {
//           var accessToken =
//               await Provider.of<AuthenticationDetails>(context, listen: false)
//                   .restoreAccessToken();
//           // Only this block can run (once) until done
//           req.headers['Authorization'] = accessToken;
//         }
//       },
//     );
//     await client.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': token!
//       },
//     );

//     notifyListeners();
//   }

//   Future register(String mobileno, String expirience, String languages,
//       String userName, BuildContext context, List price) async {
//     var flutterFunctions =
//         Provider.of<FlutterFunctions>(context, listen: false);
//     var catIdString = selectedCatId.isNotEmpty ? selectedCatId.join(",") : '';
//     String randomLetters = generateRandomLetters(10);

//     var data = {
//       "mobileno": mobileno,
//       "role": "p",
//       "username": userName,
//       "userstatus": "0",
//       "adhar": "${randomLetters}_adhar",
//       "profilepic": "${randomLetters}_profilepic",
//       "expirience": expirience,
//       "lang": languages,
//       "isonline": "0",
//       "location": locationId
//     };
//     var separator = '/';
//     List<List<String>> priceList = [];
//     for (var i = 0; i < price.length; i++) {
//       List<String> subcatPrices = [];
//       for (var j = 0; j < price[i].length; j++) {
//         String text = price[i][j].text;

//         if (text.isNotEmpty) {
//           subcatPrices.add(text);
//         }
//         // Do something with the text value
//       }
//       priceList.add(subcatPrices);
//     }
//     String prices = priceList.map((e) => e.join(',')).join(',');
//     prices = prices.replaceAll(RegExp(r',+$'), ''); // remove trailing commas
//     prices = prices.replaceAll(RegExp(r',,'), ','); // remove trailing commas

//     var url =
//         "${PurohitApi().baseUrl}${PurohitApi().register}$catIdString$separator$prices";
//     Map<String, String> obj = {"attributes": json.encode(data).toString()};
//     try {
//       loading('register is true', true);
//       var response = http.MultipartRequest('POST', Uri.parse(url));

// // Check if the adhar image is available and not null
//       if (flutterFunctions.imageFileList['adhar'] != null) {
//         response.files.add(await http.MultipartFile.fromPath(
//             "imagefile[]", flutterFunctions.imageFileList['adhar']!.path,
//             contentType: parser.MediaType("image", "jpg")));
//       }

// // Check if the profile image is available and not null
//       if (flutterFunctions.imageFileList['profile'] != null) {
//         response.files.add(await http.MultipartFile.fromPath(
//             "imagefile[]", flutterFunctions.imageFileList['profile']!.path,
//             contentType: parser.MediaType("image", "jpg")));
//       }

// // Add the rest of your fields and complete your API call...
//       response.fields.addAll(obj);
//       final send = await response.send();
//       final res = await http.Response.fromStream(send);
//       var statuscode = res.statusCode;
//       loading('register is false', false);

//       user = json.decode(res.body);

//       if (user!['data'] != null) {
//         users = user!['data'];
//         messages = user!['messages'].toString();
//         // var firebaseresponse = await http.post(Uri.parse(firebaseUrl),
//         //     body: json.encode({'status': apiCalls.users![0]['isonline']}));
//         // var firebaseDetails = json.decode(firebaseresponse.body);
//       }
//       messages = user!['messages'].toString();
//       notifyListeners();
//       return statuscode;
//     } catch (e) {
//       messages = e.toString();
//     }
//   }

//   Future<void> getCarousel(BuildContext cont) async {
//     final url = PurohitApi().baseUrl + PurohitApi().adds;

//     final client = RetryClient(
//       http.Client(),
//       retries: 4,
//       when: (response) {
//         return response.statusCode == 401 ? true : false;
//       },
//       onRetry: (req, res, retryCount) async {
//         if (retryCount == 0 && res?.statusCode == 401) {
//           var accessToken =
//               await Provider.of<AuthenticationDetails>(cont, listen: false)
//                   .restoreAccessToken();
//           // Only this block can run (once) until done
//           req.headers['Authorization'] = accessToken;
//         }
//       },
//     );
//     var response = await client.get(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': token!
//       },
//     );
//     Map<String, dynamic> purohithCarouselResponse = json.decode(response.body);
//     carousel = SliderImages.fromJson(purohithCarouselResponse);

//     notifyListeners();
//   }

//   Future<XFile?> getCarouselPic(BuildContext cont, String imageid) async {
//     final url = "${PurohitApi().baseUrl}${PurohitApi().adds}/$imageid";
//     loading('getEventPic should be true', true);
//     print('getCarouselPic:$url');
//     final client = RetryClient(
//       http.Client(),
//       retries: 4,
//       when: (response) {
//         return response.statusCode == 401 ? true : false;
//       },
//       onRetry: (req, res, retryCount) async {
//         if (retryCount == 0 && res?.statusCode == 401) {
//           var accessToken =
//               await Provider.of<AuthenticationDetails>(cont, listen: false)
//                   .restoreAccessToken();
//           // Only this block can run (once) until done
//           req.headers['Authorization'] = accessToken;
//         }
//       },
//     );
//     var response = await client.get(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': token!
//       },
//     );
//     //Map<String, dynamic> userResponse = json.decode(response.body);
//     final Uint8List resbytes = response.bodyBytes;

//     switch (response.statusCode) {
//       case 200:

//         // Attempt to create an Image object from the image bytes
//         // final image = Image.memory(resbytes);
//         final tempDir = await getTemporaryDirectory();
//         final file = File('${tempDir.path}/slider$imageid');
//         await file.writeAsBytes(resbytes);
//         final xfile = XFile(file.path);

//         //userDetails!.data![0].xfile = XFile(file.path);
//         loading('getEventPic should be false', false);

//         notifyListeners();
//         return xfile;
//       // If the image was created successfully, the bytes are in a valid format
//     }

//     return null;
//   }

//   Future<void> loadCarouselImages(BuildContext cont) async {
//     loading("loadImages is true", true);
//     var api = Provider.of<ApiCalls>(cont, listen: false);
//     for (var i = 0; i < carousel!.data!.length; i++) {
//       final carouseldata = carousel!.data![i];

//       final imageid = carouseldata.id;

//       // Check if the packageid and imageid are not null
//       if (imageid != null) {
//         // Call the getEventPic API to download the image
//         final xfile = await api.getCarouselPic(cont, imageid.toString());

//         if (xfile != null) {
//           carouseldata.xfile = xfile;
//           // print(
//           //     "this is from getCarouselPic:${carousel!.data![i].xfile!.readAsBytes()}");
//           notifyListeners();
//         }
//       }
//       loading("loadImages is false", false);
//     }
//   }
// }
