import 'package:flutter/material.dart';

import '../constants.dart';
import '../providers/books.dart';

class BookCard extends StatefulWidget {
  final Book book;
  final bool seriesMode;

  final void Function() onDeleteTap;
  final void Function() onEditTap;

  const BookCard(this.book, this.seriesMode, this.onEditTap, this.onDeleteTap,
      {Key? key})
      : super(key: key);

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  @override
  Widget build(BuildContext context) {
    final bool isActual = widget.book.actual;
    final String question = (isActual) ? 'Удаляем' : 'Восстанавливаем';

    return Dismissible(
      background: Container(
        color: isActual ? Colors.blueAccent : Colors.lightBlueAccent,
        child: Icon(
          isActual ? Icons.delete : Icons.restore_from_trash,
          color: Colors.white,
          size: 40,
        ),
      ),
      key: ValueKey(widget.book.id),
      //************
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        widget.onDeleteTap();
      },
      confirmDismiss: (direction) {
        //return Future.value(true);
        return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('$question "${widget.book.nameRus}"'),
                content: const Text('Вы уверены?'),
                actions: [
                  ElevatedButton(
                    child: const Text('НЕТ'),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                  ),
                  ElevatedButton(
                    child: const Text('ДА'),
                    onPressed: () {
                      if (widget.book.actual) {
                        Navigator.of(ctx).pop(true);
                      } else {
                        widget.onDeleteTap();
                        Navigator.of(ctx).pop(false);
                      }
                    },
                  ),
                ],
              );
            });
      },

      //************
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 8,
            child: Container(
              height: widget.book.noSeries ? 85 : 110,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              width: double.infinity,
              //color: Colors.red,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: widget.onEditTap,
                    child: Text(
                      widget.book.nameRus!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: (widget.seriesMode)
                              ? (widget.book.checked
                                  ? Colors.black
                                  : Colors.grey[400])
                              : (isActual ? Colors.black : Colors.grey[400]),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    widget.book.authorName!,
                    style: TextStyle(
                        color: isActual ? Colors.black : Colors.grey[400]),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // серии
                  if (!widget.book.noSeries)
                    Expanded(
                      child: Row(
                        children: [
                          const Text('серия : ', style: kTextStyleLabel,),
                          Text('${widget.book.seriesSeq} - ${widget.book.seriesName}'),
                        ],
                      ),
                    ),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'доб',
                          style: kTextStyleLabel,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(API.rusDate(widget.book.dateInit!)),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'статус',
                          style: kTextStyleLabel,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.book.stateName!,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Text(
                        //   widget.book.grade.toString(),
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                         if (widget.seriesMode)
                          Expanded(
                            child: Checkbox(
                                value: widget.book.checked,
                                activeColor: Colors.red,
                                //checkColor: Colors.red,
                                onChanged: (value) {
                                  setState(() {
                                    widget.book.checked = value!;
                                  });
                                }),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

      //  ),

      ),
    );
  }
}
