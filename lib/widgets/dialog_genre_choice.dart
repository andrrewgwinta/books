import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/books.dart';

import '../widgets/genre_list_widget.dart';

class DialogGenreChoise extends StatelessWidget {
  final Book book;
  final void Function() pressOK;

  DialogGenreChoise({required this.book, required this.pressOK});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('выбираем жанры'),
      children: [
        Container(
          width: 300,
          height: 200,
          // MediaQuery.of(context).size.height -
          //     250,
          child: GenreCheckList(book.genreCodeId!),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 20,
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('отмена')),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                  //onPressed: ()=>pressOK(),
                  onPressed: pressOK,
                  child: Text('запомнить')),
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ],
    );
  }
}
