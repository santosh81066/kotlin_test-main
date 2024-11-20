import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/horoscopenotifier.dart';


class HoroscopeList extends StatefulWidget {
  final String? title;
  final void Function(String) onTitleChanged;
  const HoroscopeList({
    this.title,
    required this.onTitleChanged,
    super.key,
  });

  @override
  State<HoroscopeList> createState() => _HoroscopeListState();
}

class _HoroscopeListState extends State<HoroscopeList> {
  @override
  void initState() {
    widget.onTitleChanged("Horoscope List");

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          ref.read(horoScopeDataProvider.notifier).getHoroscope(context);
          final horoscope = ref.watch(horoScopeDataProvider);
          return (horoscope.data == null || horoscope.data!.isEmpty)
              ? const Center(child: Text('No Horoscope to download'))
              : ListView.builder(
                  itemCount: horoscope.data?.length,
                  itemBuilder: (context, index) {
                    var data = horoscope.data![index];
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(64, 75, 96, .9)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          title: Text(
                            data.title ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: ref
                                  .read(horoScopeDataProvider.notifier)
                                  .isFileDownloaded("${data.title!}.pdf")
                              ? IconButton(
                                  icon: const Icon(Icons.open_in_new,
                                      color: Colors.white, size: 30),
                                  onPressed: () {
                                    ref
                                        .read(horoScopeDataProvider.notifier)
                                        .openFile(
                                            "${data.title!}.pdf", 'Horoscope');
                                  },
                                )
                              : IconButton(
                                  icon: const Icon(Icons.download_rounded,
                                      color: Colors.white, size: 30),
                                  onPressed: () {
                                    ref
                                        .read(horoScopeDataProvider.notifier)
                                        .downloadPDF(
                                            data.title!, data.id.toString());
                                  },
                                ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
