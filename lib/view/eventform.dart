import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../models/booking.dart';
import '../providers/bookingnotifier.dart';
import '../providers/eventformproviders.dart';
import '../providers/loader.dart';
import '../widgets/appbar.dart';
import '../widgets/button.dart';

class EventForm extends StatelessWidget {
  const EventForm({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController familyMembers = TextEditingController();
    TextEditingController altmobileno = TextEditingController();
    TextEditingController addr = TextEditingController();
    TextEditingController pinco = TextEditingController();
    TextEditingController goutram = TextEditingController();
    final familyMembersFormKey =
        GlobalKey<FormState>(); // Separate FormKey for family members field
    String book = 'Book';
    String address = 'Enter your complete address';
    String pincode = 'Enter pincode';
    String familygotram = 'Enter your family goutram';
    String familymember = 'Add family member';
    final formKey = GlobalKey<FormState>();

    final eventDetails = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      appBar: purohithAppBar(context, "Event Form"),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Consumer(
            builder: (context, ref, child) {
              var familyMembersState = ref.read(eventFormDataProvider);
              var isLoading = ref.watch(loadingProvider);
              return Column(
                children: [
                  TextFormField(
                    keyboardType:
                        TextInputType.phone, // Set the keyboard type to phone
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (value.length != 10) {
                          return 'Mobile number should be 10 digits';
                        }
                      }
                      return null;
                    },
                    controller: altmobileno,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                    ),
                  ),
                  TextFormField(
                    maxLines: 4,
                    validator: (validator) {
                      if (validator == null || validator.isEmpty) {
                        return "please enter complete address";
                      }
                      return null;
                    },
                    controller: addr,
                    decoration: InputDecoration(label: Text(address)),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (validator) {
                      if (validator == null || validator.isEmpty) {
                        return "please enter pin code";
                      }
                      return null;
                    },
                    controller: pinco,
                    decoration: InputDecoration(label: Text(pincode)),
                  ),
                  TextFormField(
                    validator: (validator) {
                      if (validator == null || validator.isEmpty) {
                        return "please enter the goutram of your family";
                      }
                      return null;
                    },
                    controller: goutram,
                    decoration: InputDecoration(label: Text(familygotram)),
                  ),
                  familyMembersState.data == null
                      ? Container()
                      : Consumer(
                          builder: (context, ref, child) {
                            return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: familyMembersState.data!.length,
                                itemBuilder: (context, member) {
                                  return CheckboxListTile(
                                    title: Text(
                                        "${familyMembersState.data![member].familymember}"),
                                    value: ref
                                        .read(eventFormDataProvider.notifier)
                                        .selectedFamilyMemberId
                                        .contains(familyMembersState
                                            .data![member].id),
                                    onChanged: (val) {
                                      ref
                                          .read(eventFormDataProvider.notifier)
                                          .selectedFamilyMember(
                                              familyMembersState
                                                  .data![member].id!);
                                    },
                                  );
                                });
                          },
                        ),
                  Form(
                    key: familyMembersFormKey,
                    child: TextFormField(
                      validator: (validator) {
                        if (validator == null || validator.isEmpty) {
                          return "please enter the name of the family member";
                        }
                        return null;
                      },
                      controller: familyMembers,
                      decoration: InputDecoration(label: Text(familymember)),
                    ),
                  ),
                  Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              Button(
                                buttonname: 'Add Family Member',
                                onTap: () {
                                  if (familyMembersFormKey.currentState!
                                      .validate()) {
                                    ref
                                        .read(eventFormDataProvider.notifier)
                                        .addFamilyMember(
                                            context, familyMembers.text);
                                  }
                                },
                              ),
                              Button(
                                buttonname: book,
                                onTap: isLoading
                                    ? null
                                    : () async {
                                        BookingData newBooking = BookingData(
                                          // Set properties for the new booking
                                          amount: eventDetails['amount'],
                                          goutram: goutram.text.trim(),
                                          address:
                                              "${addr.text.trim()},familymember:${ref.read(eventFormDataProvider.notifier).selectedFamilyMemberName},altmobileno:${altmobileno.text}",
                                          bookingStatus: 'w',
                                          // ... other properties ...
                                        );
                                        if (formKey.currentState!.validate()) {
                                          await ref
                                              .read(
                                                  bookingDataProvider.notifier)
                                              .sendBooking(
                                                  ctypeId:
                                                      eventDetails['catid'],
                                                  bookings: newBooking,
                                                  otp: false,
                                                  context: context);
                                        }
                                      },
                              ),
                            ],
                          ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
