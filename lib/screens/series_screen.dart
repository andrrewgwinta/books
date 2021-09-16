import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

//import '../constants.dart';
import '../providers/series.dart';
import '../providers/filter.dart';
import '../screens/serie_screens_add.dart';

class SeriesScreen extends StatelessWidget {
  static const routeName = '/series_nsi';

  const SeriesScreen({Key? key}) : super(key: key);

  void modifyRecord(
      BuildContext context, SeriesItem series) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      //вот так клавиатура не будет заслонять вылезший БоттомШит
      builder: (BuildContext context) => SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddSeriesScreen(serie: series,),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final series = Provider.of<Series>(context);
    final seriesData = series.items;

    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     modifyRecord(context, ActionType.atInsert, '', '0');
      //   },
      // ),
      appBar: AppBar(
        title: Text('Серии'),
      ),
      body: ListView.builder(
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
    );
  }
}

class SeriesCard extends StatefulWidget {
  final SeriesItem serie;
  final void Function() onEditTap;
  final void Function() onDeleteTap;

  const SeriesCard(this.serie, this.onEditTap, this.onDeleteTap, {Key? key})
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
      key: ValueKey(widget.serie.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        widget.onDeleteTap();
      },
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Удаление серии "${widget.serie.name}"'),
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
          onDoubleTap: (){
            final fd = Provider.of<Filter>(context, listen: false);
            fd.clearFilter();
            fd.filter.fltSeries = widget.serie.id;
            Navigator.of(context).pushNamed('/');
          },
          onTap: widget.onEditTap,
          child: Card(
            elevation: 6,
            shadowColor: Colors.deepPurple,
            //color: Colors.grey,
            child: ListTile(
              title: Text(widget.serie.name),
              subtitle: Text(
                widget.serie.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
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
