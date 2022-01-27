import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/authors.dart';
import '../providers/books.dart';
import '../providers/genres.dart';
import '../providers/read_state.dart';
import '../widgets/combo_widget.dart';
import '../widgets/dialog_author_choice.dart';
import '../widgets/dialog_genre_choice.dart';

// class BookModifyScreenArgument {
//   final ActionType actionType;
//   final Book book;
//   BookModifyScreenArgument({required this.actionType, required this.book, t});
// }

class BookModifyScreen extends StatefulWidget {
  static const routeName = '/book_add';

  const BookModifyScreen({Key? key}) : super(key: key);

  @override
  State<BookModifyScreen> createState() => _BookModifyScreenState();
}

class _BookModifyScreenState extends State<BookModifyScreen> {
  bool isInit = true;
  late Book book;

  final TextEditingController _controllerNameRus = TextEditingController();
  final TextEditingController _controllerSeriesSeq = TextEditingController();
  final TextEditingController _controllerAuthor = TextEditingController();
  final TextEditingController _controllerNote = TextEditingController();

  @override
  void dispose() {
    _controllerNameRus.dispose();
    _controllerSeriesSeq.dispose();
    _controllerAuthor.dispose();
    _controllerNote.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      book = ModalRoute.of(context)!.settings.arguments as Book;
      _controllerNameRus.text = book.nameRus!;
      _controllerSeriesSeq.text = book.seriesSeq!;
      _controllerAuthor.text = book.authorName!;
      _controllerNote.text = book.note!;
    }
    isInit = false;
  }

  void modifyBook() {
    (book.id == '0')
        ? Provider.of<Books>(context, listen: false).insertBook(book)
        : Provider.of<Books>(context, listen: false).updateBook(book);
  }

  @override
  Widget build(BuildContext context) {
    final readStates = Provider.of<ReadStates>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.nameRus!),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Card(
              shadowColor: Colors.blue,
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'название',
                      style: kTextStyleLabel,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: 100,
                            decoration: kInputBoxDecoration,
                            child: TextField(
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: kInputFieldDecoration,
                              controller: _controllerNameRus,
                              onChanged: (value) => book.nameRus = value,
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              _controllerNameRus.text = '';
                            },
                            icon: const Icon(
                              Icons.cancel_rounded,
                              color: kInputColor,
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    if (book.inSeries)
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              width: 100,
                              decoration: kInputBoxDecoration,
                              child: TextField(
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                //textCapitalization: TextCapitalization.sentences,
                                decoration: kInputFieldDecoration,
                                controller: _controllerSeriesSeq,
                                onChanged: (value) => book.seriesSeq = value,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'в серии',
                                    style: kTextStyleLabel,
                                  ),
                                  Text(
                                    book.seriesName!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    const Text(
                      'автор',
                      style: kTextStyleLabel,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                              decoration: kInputBoxDecoration,
                              child: TextField(
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: kInputFieldDecoration,
                                controller: _controllerAuthor,
                                onChanged: (value) {
                                  book.authorName = value;
                                  book.authorId = '0';
                                },
                              )),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  final Author author = Author(
                                      id: book.authorId!,
                                      nameRus: book.authorName!);
                                  return DialogAuthorChoice(
                                    authorListType: AuthorListType.altActual,
                                    author: author,
                                    pressOK: () {
                                      book.authorId = author.id;
                                      book.authorName = author.nameRus;
                                      _controllerAuthor.text = book.authorName!;
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                  );
                                });
                          },
                        ),
                      ],
                    ),
                    const Text(
                      'жанр',
                      style: kTextStyleLabel,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 42,
                            decoration: kInputBoxDecoration,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              //child: Center(
                              child: Row(
                                children: [
                                  Text(book.genreCodeName!,
                                      textAlign: TextAlign.justify),
                                ],
                              ),
                            ),
                            //),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return DialogGenreChoice(
                                      book: book,
                                      pressOK: () {
                                        setState(() {
                                          final genres = Provider.of<Genres>(
                                              context,
                                              listen: false);
                                          book.genreCodeId =
                                              genres.codeCheckString;
                                          book.genreCodeName =
                                              genres.nameCheckString;
                                        });
                                        Navigator.of(context).pop();
                                      });
                                });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: SizedBox(
                            height: 70,
                            child: ComboWidget(
                              items: readStates.getListMap(),
                              onChange: (value) {
                                book.stateId = value!.toString();
                                book.stateName =
                                    readStates.getNameById(book.stateId!);
                              },
                              initialValue: book.stateId!,
                              caption: 'статус',
                            ),
                          ),
                        ),
                        Expanded(flex: 1, child: Center(child: Text(book.grade.toString(),
                        style: const TextStyle(

                            fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
                        ))),
                        // Expanded(
                        //   flex: 4,
                        //       child: Slider(
                        //         value: book.grade!.toDouble(),
                        //         min: 0,
                        //         max: 10,
                        //         divisions: 10,
                        //         onChanged: (value) {
                        //           setState(() {
                        //             book.grade = value.toInt();
                        //           });
                        //         },
                        //       ),
                        //       Expanded(flex: 1, child: Text(book.grade.toString())),
                        // ),
                      ],
                    ),
    Slider(
            value: book.grade!.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) {
              setState(() {
                book.grade = value.toInt();
              });
            },
          ),
                    const Text(
                      'комментарий',
                      style: kTextStyleLabel,
                    ),
                    Container(
                        decoration: kInputBoxDecoration,
                        height: 180,
                        child: TextField(
                          maxLines: 4,
                          decoration: kInputFieldDecoration,
                          controller: _controllerNote,
                          onChanged: (value) => book.note = value,
                        )),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('отмена')),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                            //onPressed: () => Navigator.of(context).pop(),
                            onPressed: () {
                              setState(() {
                                book =
                                    Provider.of<Books>(context, listen: false)
                                        .copyBook(book);
                                _controllerNameRus.text = book.nameRus!;
                              });
                            },
                            child: const Text('копия')),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                            onPressed: () {
                              modifyBook();
                              Navigator.of(context).pop();
                            },
                            child: const Text('запомнить')),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
