import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/categorynotifier.dart';
import '../providers/imagepicker.dart';
import '../providers/locationstatenotifier.dart';

import 'insertprofile.dart';

class AddUser extends StatefulWidget {
  const AddUser({
    super.key,
    this.mobileNo,
    this.userName,
    this.languages,
    this.adharId,
    this.languagesHint,
    this.mobileHint,
    this.userNameHint,
    this.panId,
    this.buttonName,
    this.scaffoldMessengerKey,
    this.description,
  });
  final TextEditingController? mobileNo;
  final TextEditingController? userName;
  final TextEditingController? languages;

  final TextEditingController? description;
  final String? panId;
  final String? adharId;
  final String? mobileHint;
  final String? userNameHint;
  final String? languagesHint;
  final String? buttonName;

  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    widget.mobileNo!.dispose();
    widget.userName!.dispose();
    widget.languages!.dispose();

    widget.description!.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//     // var flutterFunctions = Provider.of<FlutterFunctions>(context);
//     // var apicalls = Provider.of<ApiCalls>(context, listen: false);

//     // List<List<TextEditingController>> prices = List.generate(
//     //   apicalls.categorieModel!.data!.length,
//     //   (mainindex) {
//     //     var subcatCount =
//     //         apicalls.categorieModel!.data![mainindex].subcat!.length;
//     //     return List.generate(
//     //       subcatCount + 1, // add one for the main category price
//     //       (subindex) => TextEditingController(),
//     //     );
//     //   },
//     // );

//     // String? errorMessage =
//     //     apicalls.validateForm(flattenedPrices, apicalls.selectedCatId);
    // List<Data> filteredCategories =
    //     apicalls.categorieModel!.data!.where((category) {
    //   // return true if the category meets the filter condition, false otherwise
    //   return category.cattype != "e"; // replace with your own filter condition
    // }).toList();

    final formKey = GlobalKey<FormState>();
    return Scrollbar(
      thickness: 4,
      radius: const Radius.circular(4),
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        child: Form(
            key: formKey,
            child: Consumer(
              builder: (context, ref, child) {
                final imagePickerNotifier =
                    ref.read(imagePickerProvider.notifier);
                final locationNotifier = ref.read(locationProvider.notifier);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: widget.mobileHint,
                            labelStyle: const TextStyle(color: Colors.grey),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          controller: widget.mobileNo!,
                          validator: (validator) {
                            final RegExp phoneRegex = RegExp(r'^\+?\d{10,12}$');
                            if (!phoneRegex.hasMatch(validator!)) {
                              return 'Please enter a valid phone number';
                            }
                            if (validator.isEmpty) {
                              return "please enter the mobile no";
                            }
                            return null;
                          },
                          cursorColor: Colors.grey),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: widget.userNameHint,
                            labelStyle: const TextStyle(color: Colors.grey),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          controller: widget.userName!,
                          validator: (validator) {
                            if (validator == null || validator.isEmpty) {
                              return "please enter the username";
                            }
                            return null;
                          },
                          cursorColor: Colors.grey),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: widget.languagesHint,
                            labelStyle: const TextStyle(color: Colors.grey),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          controller: widget.languages!,
                          validator: (validator) {
                            if (validator == null || validator.isEmpty) {
                              return "please enter languages";
                            }
                            return null;
                          },
                          cursorColor: Colors.grey),
                    ),
                    InsertProfile(
                      imageIcon: () {
                        imagePickerNotifier.uploadIdentity(
                            ImageSource.gallery, 'profile');
                      },
                      label: 'select profile pic(Optional)',
                      index: 'profile',
                    ),
                    ref
                            .watch(imagePickerProvider)
                            .imageFileList
                            .containsKey('profile')
                        ? TextButton(
                            onPressed: () {
                              imagePickerNotifier.uploadIdentity(
                                  ImageSource.gallery, 'profile');
                            },
                            child: const Text("Change profile pic"))
                        : Container(),
                    TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: ' your expirience',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        controller: widget.description,
                        validator: (validator) {
                          if (validator == null || validator.isEmpty) {
                            return "please enter expirience";
                          }
                          return null;
                        },
                        cursorColor: Colors.grey),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final locationState = ref.watch(locationProvider);
                          final locationNotifier =
                              ref.read(locationProvider.notifier);
                          return DropdownButton<String>(
                            elevation: 16,
                            isExpanded: true,
                            hint: const Text('please select location'),
                            items: locationState.data.isEmpty
                                ? []
                                : locationState.data.map((v) {
                                    return DropdownMenuItem<String>(
                                        onTap: () {
                                          locationNotifier.setFilterLocation(
                                              v.location, v.id);
                                        },
                                        value: v.location,
                                        child: Text(v.location));
                                  }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                locationNotifier.setFilterLocation(
                                    val,
                                    locationState.data
                                        .firstWhere(
                                            (data) => data.location == val)
                                        .id);
                              }
                            },
                            value: locationNotifier.getFilterLocation(),
                          );
                        },
                      ),
                    ),
                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      validator: (validator) {
                        if (locationNotifier.getLocationId() == null) {
                          return 'Please select a location';
                        }
                        return null;
                      },
                    ),
                    const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Please select your services below')),
                    Consumer(builder: (context, cat, child) {
                      final categoryState = cat.watch(categoryProvider);
                      final filteredCategories = ref
                          .watch(categoryProvider.notifier)
                          .getFilteredCategories("e");

                      //print(value.categories);
                      return Flexible(
                        flex: 1,
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (context, mainindex) {
                            return const Divider(
                              thickness: 3,
                              color: Colors.yellowAccent,
                            );
                          },
                          itemCount: filteredCategories.length,
                          itemBuilder: (cont, mainindex) {
                            final category = filteredCategories[mainindex];
                            final hasSubCategories = category.subcat != null &&
                                category.subcat!.isNotEmpty;
                            //                          //price.add(TextEditingController());

                            // TextEditingController controller1 =
                            //     prices[mainindex].isNotEmpty
                            //         ? prices[mainindex][0]
                            //         : TextEditingController();

                            return hasSubCategories
                                ? ExpansionTile(
                                    title: Text(category.title!),
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (contex, subindex) {
                                          return Column(
                                            children: [
                                              CheckboxListTile(
                                                value: value.selectedCatId
                                                    .contains(value
                                                        .categorieModel!
                                                        .data![mainindex]
                                                        .subcat![subindex]
                                                        .id),
                                                onChanged: (val) {
                                                  value.selectedCat(value
                                                      .categorieModel!
                                                      .data![mainindex]
                                                      .subcat![subindex]
                                                      .id!);
                                                  //value.updateId(subindex);
                                                },
                                                title: Text(value
                                                    .categorieModel!
                                                    .data![mainindex]
                                                    .subcat![subindex]
                                                    .title!),
                                              ),
                                            ],
                                          );
                                        },
                                        itemCount: apicalls.categorieModel!
                                            .data![mainindex].subcat!.length,
                                      )
                                    ],
                                  )
                                : Column(
                                    children: [
                                      CheckboxListTile(
                                        value: value.selectedCatId.contains(
                                            value.categorieModel!
                                                .data![mainindex].id),
                                        onChanged: (val) {
                                          value.selectedCat(value
                                              .categorieModel!
                                              .data![mainindex]
                                              .id!);

                                          value.updateId(mainindex);
                                        },
                                        title: Text(value.categorieModel!
                                            .data![mainindex].title!),
                                      ),
                                    ],
                                  );
                          },
                        ),
                      );
                    }),
//               Consumer(
//                 builder: (context, value, child) {
//                   // print(value.isloading);
//                   return value.watch(loadingProvider) == false
//                       ? Button(
//                           onTap: () async {
//                             showDialog(
//                               context: context,
//                               builder: (context) {
//                                 return AlertDialog(
//                                   content: const Text(
//                                       'If you are registering with the same mobile number, you will be logged out of the app and your account will be converted to Purohith. You will not be logged in as a user. Press "OK" to continue.'),
//                                   actions: [
//                                     value.watch(loadingProvider) == false
//                                         ? Button(
//                                             buttonname: 'OK',
//                                             onTap: () {
//                                               if (formKey.currentState!
//                                                   .validate()) {
//                                                 value.read(phoneAuthProvider.notifier).phoneAuth(
//                                                     context,
//                                                     "+91${widget.mobileNo!.text.trim()}",
//                                                     widget.description!.text
//                                                         .trim(),
//                                                     widget.languages!.text
//                                                         .trim(),
//                                                     widget.userName!.text
//                                                         .trim(),
//                                                     prices);
//                                               }
//                                             },
//                                           )
//                                         : const CircularProgressIndicator(
//                                             backgroundColor: Colors.yellow,
//                                           )
//                                   ],
//                                 );
//                               },
//                             );
//                           },
//                           buttonname: widget.buttonName,
//                         )
//                       : const CircularProgressIndicator(
//                           backgroundColor: Colors.yellow,
//                         );
//                 },
//               ),
//               TextFormField(
//                 validator: (validator) {
//                   if (apicalls.selectedCatId.isEmpty) {
//                     return 'Please select atleast one service';
//                   }
//                   return null;
//                 },
//               ),
                  ],
                );
              },
            )),
      ),
    );
  }
}
