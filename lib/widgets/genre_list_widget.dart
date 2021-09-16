import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/genres.dart';

class GenreCheckList extends StatefulWidget {
  String valueString = '';

  GenreCheckList(this.valueString);

  @override
  State<GenreCheckList> createState() => _GenreCheckListState();
}

class _GenreCheckListState extends State<GenreCheckList> {
  bool isInit = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      Provider.of<Genres>(context).setCheckedValue(widget.valueString);
    }
    isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Genres>(builder: (context, genresData, child) {
      final genres = genresData.itemsActual;
      return ListView.builder(
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          return Container(
            height: 25,
            padding: const EdgeInsets.only(left: 8.0, right: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(genre.name),
                Checkbox(
                  value: genre.checkState,
                  onChanged: (value) {
                    genresData.setElementChecked(genre, value!);
                  },
                )
              ],
            ),
          );
        },
      );
    });
  }
}
