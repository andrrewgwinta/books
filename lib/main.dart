import 'package:books/screens/author_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../screens/books_screen_overview.dart';
import '../screens/genre_screen.dart';
import '../screens/read_state_screen.dart';
import '../screens/book_screen_add.dart';
import '../screens/author_screen.dart';
import '../screens/series_screen.dart';

import '../providers/genres.dart';
import '../providers/books.dart';
import '../providers/read_state.dart';
import '../providers/authors.dart';
import '../providers/series.dart';

import '../providers/filter.dart';
import '../globals.dart' as global;
import '../helpers/custom_route.dart';
import '../launch_screen.dart';

void main() {
  runApp(const BookApp());
}

class BookApp extends StatefulWidget {
  const BookApp({Key? key}) : super(key: key);


  @override
  _BookAppState createState() => _BookAppState();
}

class _BookAppState extends State<BookApp> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Genres()),
        ChangeNotifierProvider(create: (ctx) => ReadStates()),
        ChangeNotifierProvider(create: (ctx) => Filter()),
        ChangeNotifierProvider(create: (ctx) => Books()),
        ChangeNotifierProvider(create: (ctx) => Authors()),
        ChangeNotifierProvider(create: (ctx) => Series()),

      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'это надо прочитать',

          theme: ThemeData(
            //brightness: Brightness.dark,
            primaryColor: Colors.lightBlueAccent,
            pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android : CustomPageTransitionBuilder(),
                  TargetPlatform.iOS : CustomPageTransitionBuilder(),
                }
            ),
          ),

          routes: {
            '/': (ctx) => (global.isFirst)? const LaunchScreen() : const BooksOverviewScreen(),
            GenreScreen.routeName : (ctx) => const GenreScreen(),
            ReadStateScreen.routeName : (ctx) => const ReadStateScreen(),
            BookModifyScreen.routeName : (ctx) => const BookModifyScreen(),
            AuthorScreen.routeName : (ctx) => const AuthorScreen(),
            SeriesScreen.routeName : (ctx) => const SeriesScreen(),
            BooksOverviewScreen.routeName : (ctx) => const BooksOverviewScreen(),

          },
        ),

    );
  }
}


