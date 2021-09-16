import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../helpers/swipedetecor.dart';
import '../providers/genres.dart';
import '../screens/genre_screen_add.dart';

class GenreScreen extends StatelessWidget {
  static const routeName = '/genres_nsi';

  const GenreScreen({Key? key}) : super(key: key);

  void modifyRecord(
      BuildContext context, ActionType actionType, String name, String index) {
      showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      //вот так клавиатура не будет заслонять вылезший БоттомШит
      builder: (BuildContext context) => SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddGenreScreen(
          actionType: actionType,
          genreName: name,
          index: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final genres = Provider.of<Genres>(context);
    final genresData = genres.items;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          modifyRecord(context, ActionType.atInsert, '', '0');
        },
      ),
      appBar: AppBar(
        title: Text('Жанры'),
      ),
      body: ListView.builder(
          itemCount: genresData.length,
          itemBuilder: (ctx, index) {
            return GenreCard(genresData[index],
                //тап на редактироваии
                () {
                      modifyRecord(
                        context,
                        ActionType.atUpdate,
                        genresData[index].name,
                        genresData[index].id,
              );
            });
        }),
    );
  }
}

class GenreCard extends StatefulWidget {
  final Genre genre;
  final void Function() onEditTap;

  const GenreCard(this.genre, this.onEditTap, {Key? key})
      : super(key: key);

  @override
  State<GenreCard> createState() => _GenreCardState();
}

class _GenreCardState extends State<GenreCard> {

  @override
  Widget build(BuildContext context) {
    final String question = widget.genre.actual?'удаляем':'восстанавливаем';
    return Dismissible(
      //*********************
      background: Container(
        color: widget.genre.actual? Colors.blueAccent:Colors.lightBlueAccent,
        child: Icon(
          widget.genre.actual ? Icons.delete : Icons.restore_from_trash,
          color: Colors.white,
          size: 40,
        ),
      ),
      key: ValueKey(widget.genre.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_){
      },
      confirmDismiss: (direction) {

        return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('$question "${widget.genre.name}"'),
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
                        setState(() {
                          widget.genre.actual = !widget.genre.actual;
                        });
                        widget.genre.actualOnServer();
                        Navigator.of(ctx).pop(false);
                      }
                  ),
                ],
              );
            });
      },

      //****************
      child: SizedBox(
        height: 45,
        child: GestureDetector(
            onTap: widget.onEditTap,
            child: Card(
              elevation: 6,
              shadowColor: Colors.deepPurple,
              //color: Colors.grey,
              child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                        height: 30,
                      ),
                      Text(
                        widget.genre.name,
                        style: TextStyle(fontSize: 16,
                        color: widget.genre.actual?Colors.black:Colors.grey,
                        ),
                      ),
                    ],
                ),
            ),
          ),
        //),
      ),
    );
  }
}
