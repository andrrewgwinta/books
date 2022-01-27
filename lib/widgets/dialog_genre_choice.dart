import 'package:flutter/material.dart';

import '../providers/books.dart';
import '../widgets/genre_list_widget.dart';

class DialogGenreChoice extends StatelessWidget {
  final Book book;
  final void Function() pressOK;

  const DialogGenreChoice({Key? key, required this.book, required this.pressOK})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('выбираем жанры'),
      children: [
        SizedBox(
          width: 300,
          height: 200,
          // MediaQuery.of(context).size.height -
          //     250,
          child: GenreCheckList(book.genreCodeId!),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              width: 20,
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('отмена')),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                  //onPressed: ()=>pressOK(),
                  onPressed: pressOK,
                  child: const Text('запомнить')),
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
      ],
    );
  }
}
