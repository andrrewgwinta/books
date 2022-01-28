import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/series.dart';

class AddSeriesScreen extends StatefulWidget {
  final SeriesItem series;

  const AddSeriesScreen({Key? key, required this.series}) : super(key: key);

  @override
  State<AddSeriesScreen> createState() => _AddSeriesScreenState();
}

class _AddSeriesScreenState extends State<AddSeriesScreen> {
  final TextEditingController _controllerName = TextEditingController();

  //final TextEditingController _controllerAuthor = TextEditingController();

  late ActionType actionType;

  @override
  void initState() {
    super.initState();
    _controllerName.text = widget.series.name;
    //_controllerOrig.text = widget.author.nameOrig;
    actionType =
        (widget.series.id == '0' ? ActionType.atInsert : ActionType.atUpdate);
  }

  @override
  void dispose() {
    _controllerName.dispose();
    super.dispose();
  }

  void pressOk() {
    if (actionType == ActionType.atUpdate) {
      Provider.of<Series>(context, listen: false).updateSeries(widget.series);
    } else {
      Provider.of<Series>(context, listen: false)
          .createSeries(context, widget.series);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff757575),
      child: Container(
        height: 250,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: kBoxDecoration,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                (actionType == ActionType.atUpdate)
                    ? 'исправление'
                    : 'новая серия',
                style: const TextStyle(
                    fontSize: 30, color: Colors.lightBlueAccent),
              ),
              Text(
                widget.series.authorName,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              //const Text('название серии', style: kTextStyleLabel,),
              Container(
                decoration: kInputBoxDecoration,
                child: TextField(
                  decoration: kInputFieldDecoration,
                  controller: _controllerName,
                  autofocus: true,
                  textAlign: TextAlign.start,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    widget.series.name = value;
                  },
                ),
              ),

              API.answerButtons(context, pressOk),
            ]),
      ),
    );
  }
}
