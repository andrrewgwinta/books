import 'dart:async';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

import '../providers/filter.dart';

//import '../constants.dart';
import '../providers/series.dart';
import '../screens/books_screen_overview.dart';
import '../screens/series_screen_add.dart';
import '../constants.dart';

class SeriesScreen extends StatefulWidget {
  static const routeName = '/series_nsi';

  const SeriesScreen({Key? key}) : super(key: key);

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {

  String _currentSearchString = '';
  Timer? searchDebounce;
  final TextEditingController _controllerSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    super.dispose();
  }

  void modifyRecord(BuildContext context, SeriesItem series) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      //вот так клавиатура не будет заслонять вылезший БоттомШит
      builder: (BuildContext context) => SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddSeriesScreen(
          series: series,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final series = Provider.of<Series>(context);
    final seriesData = series.getFilteredSeries(_currentSearchString);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Серии'),
      ),
      body:
        Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controllerSearch,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF4d4dff),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      //suffixIcon: const Icon(Icons.clear, color:Colors.white),
                      hintText: 'поиск по наименованию',
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                    onChanged: (value) {
                      _currentSearchString = value;
                      searchDebounce?.cancel();
                      searchDebounce =
                          Timer(const Duration(milliseconds: 500), () {
                            setState(() {
                              //reread series list
                            });
                          });
                    },
                  ),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _currentSearchString = '';
                        _controllerSearch.text = '';
                      });
                    },
                    icon: const Icon(Icons.clear, color: Colors.blue))
              ],
            ),
          ),

          Expanded(child:
            ListView.builder(
                itemCount: seriesData.length,
                itemBuilder: (ctx, index) {
                  return SeriesCard(seriesData[index],
                      //тап на редактироваии
                      () {
                    modifyRecord(context, seriesData[index]);
                  }, () {
                    series.deleteSeries(context, seriesData[index]);
                  });
                }),
          ),
        ],),
    );
  }
}

class SeriesCard extends StatefulWidget {
  final SeriesItem series;
  final void Function() onEditTap;
  final void Function() onDeleteTap;

  const SeriesCard(this.series, this.onEditTap, this.onDeleteTap, {Key? key})
      : super(key: key);

  @override
  State<SeriesCard> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<SeriesCard> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      //*********************
      background: Container(
        color: Colors.blueAccent,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      key: ValueKey(widget.series.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        widget.onDeleteTap();
      },
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Удаление серии "${widget.series.name}"'),
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
                      Navigator.of(ctx).pop(true);
                    },
                  ),
                ],
              );
            });
      },
      //****************
      child: SizedBox(
        height: 75,
        child: GestureDetector(
          onTap: widget.onEditTap,
          child: Card(
            elevation: 6,
            shadowColor: Colors.deepPurple,
            //color: Colors.grey,
            child: ListTile(
              title: Text(widget.series.name),
              subtitle: Text(
                widget.series.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: IconButton(
                onPressed: () {
                  final fd = Provider.of<Filter>(context, listen: false);
                  fd.clearFilter();
                  fd.filter.fltSeries = widget.series.id;
                  fd.filter.fltActual = FilterActualType.fatNone;

                  Navigator.of(context)
                      .pushNamed(BooksOverviewScreen.routeName);
                },
                icon: const Icon(
                  //Icons.search,
                  Icons.navigate_next,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
        //),
      ),
    );
  }
}
