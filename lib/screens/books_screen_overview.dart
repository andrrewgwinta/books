import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/authors.dart';
import '../providers/books.dart';
import '../providers/filter.dart';
import '../providers/genres.dart';
import '../providers/read_state.dart';
import '../providers/series.dart';
import '../screens/author_screen.dart';
import '../screens/book_screen_add.dart';
import '../screens/genre_screen.dart';
import '../screens/read_state_screen.dart';
import '../screens/serie_screens_add.dart';
import '../screens/series_screen.dart';
import '../widgets/book_card_widget.dart';
import '../widgets/filter_drawer.dart';
import '../globals.dart' as global;

class BooksOverviewScreen extends StatefulWidget {
  static const routeName = '/books_list';

  const BooksOverviewScreen({Key? key}) : super(key: key);

  @override
  State<BooksOverviewScreen> createState() => _BooksOverviewScreenState();
}

class _BooksOverviewScreenState extends State<BooksOverviewScreen> {
  //var isLoading = true;
  var isSeriesMode = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    //однократно грузить здесь, сбрасывая флаг logonInit
    //print(global.isFirst.toString());
    if (global.isFirst) {
      await Provider.of<Filter>(context, listen: false).readFilterData().then((_) => print('filter loaded'));
      await Provider.of<Authors>(context, listen: false).loadAuthors();
      await Provider.of<Genres>(context, listen: false).loadGenres();
      await Provider.of<ReadStates>(context, listen: false).loadReadState();
      await Provider.of<Series>(context, listen: false).loadSeries();
    }
    global.isFirst = false;
    //print(global.isFirst.toString());
  }

  TextStyle itemStyle =
      const TextStyle(color: Colors.lightBlueAccent, fontSize: 16);

  @override
  Widget build(BuildContext context) {
    final filter  = Provider.of<Filter>(context, listen: false).filter;
    //print('in build $filter');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          isSeriesMode ? Icons.merge_type_sharp : Icons.add,
          size: 40,
        ),
        onPressed: () async {
          final bookProvider = Provider.of<Books>(context, listen: false);
          if (isSeriesMode) {
            if (bookProvider.emptyChecked) {
              await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('нет отмеченных книг'),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('   OK   ')),
                      ],
                    );
                  });
            } else {
              SeriesItem newSeries = SeriesItem();
              NsiRecord seriesAuthor = bookProvider.firstCheckedAuthor();
              newSeries.authorId = seriesAuthor.id;
              newSeries.authorName = seriesAuthor.name;

              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                //вот так клавиатура не будет заслонять вылезший БоттомШит
                builder: (BuildContext context) => SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: AddSeriesScreen(serie: newSeries),
                ),
              ).then((value) => setState(() {
                    isSeriesMode = false;
                    bookProvider.unCheckedAll();
                  }));
            }
          } else {
            //переход в окно ins?upd книги
            final Book newBook = bookProvider.createEmpty(context);
            Navigator.of(context)
                .pushNamed(BookModifyScreen.routeName, arguments: newBook);
          }
        },
      ),
      drawer: FilterDrawer(() {
        //print('reload with ${filter.toString()}');
      }),
      appBar: AppBar(
        title: const Text('КОГДА ВСЁ ЭТО ЧИТАТЬ???'),
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(FontAwesomeIcons.search),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        actions: [
          PopupMenuButton(
            tooltip: 'справочники',
            child: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    //TODO прятать попап при переходе, просто Navigator.of(context).pop(); моргает!
                    //на всех пунктах
                    Navigator.of(context).pushNamed(AuthorScreen.routeName);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'авторы',
                        style: kTextStylePopUp,
                      ),
                      Icon(FontAwesomeIcons.userFriends)
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () async {
                    //на всех пунктах
                    await Navigator.of(context)
                        .pushNamed(SeriesScreen.routeName)
                        .then((_) => setState(() {}));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'серии',
                        style: kTextStylePopUp,
                      ),
                      Icon(Icons.format_list_numbered, size: 35,)
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(GenreScreen.routeName);
                  },
                  child: Row(
                    children: const [
                      Text(
                        'жанры',
                        style: kTextStylePopUp,
                      ),
                      Icon(FontAwesomeIcons.theaterMasks)
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(ReadStateScreen.routeName);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'этапы процесса',
                        style: kTextStylePopUp,
                      ),
                      Icon(FontAwesomeIcons.bookReader)
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    Provider.of<Authors>(context, listen: false).loadAuthors();
                    Provider.of<Genres>(context, listen: false).loadGenres();
                    Provider.of<ReadStates>(context, listen: false)
                        .loadReadState();
                    Provider.of<Series>(context, listen: false).loadSeries();

                    Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'синхронизировать ',
                        style: kTextStylePopUp,
                      ),
                      Icon(FontAwesomeIcons.sync)
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'режим "серии"',
                    style: kTextStylePopUp,
                  ),
                  Switch(
                    value: isSeriesMode,
                    onChanged: (_) {
                      setState(() {
                        isSeriesMode = !isSeriesMode;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )),
            ],
          ),
          const SizedBox(
            width: 15,
          )
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<Books>(context, listen: false).loadBooks(filter),
        //future: Provider.of<Filter>(context, listen: false).readFilterData(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (dataSnapshot.error != null) {
            return const Center(
              child: Text('[хуйня кака-то'),
            );
          } else {
            return Consumer<Books>(
              builder: (ctx, booksData, child) => (booksData.items.isEmpty)
                  ? const Center(
                      child: Text(
                      'с таким фильтром ничего не нашлось...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.blueAccent,
                      ),
                    ))
                  : ListView.builder(
                      itemCount: booksData.items.length,
                      itemBuilder: (ctx, index) =>
                          BookCard(booksData.items[index], isSeriesMode,
                              //onEdiitTap
                              () {
                        Navigator.of(context).pushNamed(
                            BookModifyScreen.routeName,
                            arguments: booksData.items[index]);
                      },
                              //onDeleteTap
                              () {
                        if (booksData.items[index].actual) {
                          booksData.deleteBook(booksData.items[index]);
                        } else {
                          booksData.restoreBook(booksData.items[index]);
                        }
                      }),
                    ),
            );
          }
        },
      ),
    );
  }
}
