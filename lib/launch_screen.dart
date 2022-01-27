import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../globals.dart' as global;
import '../providers/genres.dart';
import '../providers/authors.dart';
import '../providers/filter.dart';
import '../providers/read_state.dart';
import '../providers/series.dart';
import '../screens/books_screen_overview.dart';

class LaunchScreen extends StatefulWidget {
  static const routeName = '/launch';

  const LaunchScreen({Key? key}) : super(key: key);

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {

  @override
  void initState() {
    super.initState();
    _appInitialization();
  }

  void _appInitialization() async {
      //однократно грузить здесь, сбрасывая флаг logonInit
      if (global.isFirst) {
        //await Provider.of<Filter>(context, listen: false).readFilterData().then((_) => print('filter loaded'));
        await Provider.of<Filter>(context, listen: false).readFilterData();
        await Provider.of<Authors>(context, listen: false).loadAuthors();
        await Provider.of<Genres>(context, listen: false).loadGenres();
        await Provider.of<ReadStates>(context, listen: false).loadReadState();
        await Provider.of<Series>(context, listen: false).loadSeries();
      }
      global.isFirst = false;
      Navigator.pushReplacementNamed(context, BooksOverviewScreen.routeName);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image:  DecorationImage(
            image: Image.asset('assets/books-splash.png').image,
            fit: BoxFit.fitWidth,
          ),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.blue,),),
      ),
    );
  }
}



