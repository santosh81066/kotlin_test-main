import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../providers/eventformproviders.dart';
import '../providers/eventprovider.dart';
import '../widgets/appbar.dart';
import '../widgets/eventcard.dart';

class Events extends ConsumerStatefulWidget {
  const Events({super.key});

  @override
  ConsumerState<Events> createState() => _EventsState();
}

class _EventsState extends ConsumerState<Events> {
  @override
  void initState() {
    // Provider.of<ApiCalls>(context, listen: false).getFamilyMembers(context);
    ref.read(eventFormDataProvider.notifier).getFamilyMembers(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var apicalls = Provider.of<ApiCalls>(context);
    return Consumer(
      builder: (context, ref, child) {
        var eventsProvider = ref.read(eventDataProvider);
        return Scaffold(
          appBar: purohithAppBar(context, 'Events'),
          body: eventsProvider.eventdata == null
              ? const Center(child: Text('There are no events'))
              : LayoutBuilder(
                  builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                    return Stack(
                      children: [
                        ListView.builder(
                          itemCount: eventsProvider.eventdata!.length,
                          itemBuilder: (context, index) {
                            final event = eventsProvider.eventdata![index];
                            return Opacity(
                              opacity: 0,
                              child: EventCard(event: event),
                            );
                          },
                        ),
                        Center(
                          child: ListView.builder(
                            itemCount: eventsProvider.eventdata!.length,
                            itemBuilder: (context, index) {
                              final event = eventsProvider.eventdata![index];
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  children: [
                                    EventCard(event: event),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}
