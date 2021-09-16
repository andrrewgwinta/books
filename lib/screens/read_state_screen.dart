import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/read_state.dart';
import '../providers/filter.dart';
import '../screens/read_state_screen_add.dart';

class ReadStateScreen extends StatelessWidget {
  static const routeName = '/readstate_nsi';

  const ReadStateScreen({Key? key}) : super(key: key);

  @override
  void modifyRecord(BuildContext context, ReadState readState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      //вот так клавиатура не будет заслонять вылезший БоттомШит
      builder: (BuildContext context) => SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: AddReadStateScreen(readState)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readState = Provider.of<ReadStates>(context);
    final readStateData = readState.items;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          modifyRecord(context,
              ReadState(id: '0', name: '', orderNumber: '', actual: true));
        },
      ),
      appBar: AppBar(
        title: const Text('этапы-состояния чтения'),
      ),
      body: ListView.builder(
          itemCount: readStateData.length,
          itemBuilder: (ctx, index) {
            return ReadStateCard(readStateData[index], () {
              modifyRecord(
                  context, readStateData[index]);
            });
          }),
    );
  }
}

class ReadStateCard extends StatefulWidget {
  final ReadState readState;
  final void Function() onEditTap;

  ReadStateCard(this.readState, this.onEditTap);

  @override
  State<ReadStateCard> createState() => _ReadStateCardState();
}

class _ReadStateCardState extends State<ReadStateCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String question =
        widget.readState.actual ? 'удаляем' : 'восстанавливаем';
    return Dismissible(
      //*********************
      background: Container(
        color: widget.readState.actual
            ? Colors.blueAccent
            : Colors.lightBlueAccent,
        child: Icon(
          widget.readState.actual ? Icons.delete : Icons.restore_from_trash,
          color: Colors.white,
          size: 40,
        ),
      ),
      key: ValueKey(widget.readState.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {},
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('$question "${widget.readState.name}"'),
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
                          widget.readState.actual = !widget.readState.actual;
                        });
                        widget.readState.actualOnServer();
                        Navigator.of(ctx).pop(false);
                      }),
                ],
              );
            });
      },

      //****************
      child: SizedBox(
        height: 45,
        child: GestureDetector(
          onDoubleTap: (){
            final fd = Provider.of<Filter>(context, listen: false);
            fd.clearFilter();
            fd.filter.fltState = widget.readState.id;
            Navigator.of(context).pushNamed('/');
          },

          onTap: widget.onEditTap,
          child: Card(
            elevation: 6,
            shadowColor: Colors.deepPurple,
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                  height: 30,
                ),
                Text(
                  widget.readState.orderNumber,
                  style: TextStyle(fontSize: 16,
                    color: widget.readState.actual?Colors.black:Colors.grey,),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.readState.name,
                  style: TextStyle(fontSize: 16,
                  color: widget.readState.actual?Colors.black:Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
