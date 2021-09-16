import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/authors.dart';

class AddAuthorScreen extends StatefulWidget {

  Author author;

  AddAuthorScreen({Key? key, required this.author})
      : super(key: key);

  @override
  State<AddAuthorScreen> createState() => _AddAuthorScreenState();
}

class _AddAuthorScreenState extends State<AddAuthorScreen> {
  final TextEditingController _controllerRus = TextEditingController();
  final TextEditingController _controllerOrig = TextEditingController();

  late ActionType actionType;

  @override
  void initState() {
    super.initState();
    _controllerRus.text = widget.author.nameRus;
    _controllerOrig.text = widget.author.nameOrig;
    actionType = (widget.author.id=='0'?ActionType.atInsert:ActionType.atUpdate);
  }

  @override
  void dispose() {
    super.dispose();
    _controllerRus.dispose();
    _controllerOrig.dispose();
  }

  void pressOk(){
    if (actionType == ActionType.atUpdate) {
      Provider.of<Authors>(context, listen: false)
          .updateAuthor(widget.author);
    } else {
      Provider.of<Authors>(context, listen: false)
          .insertAuthor(widget.author);
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                (actionType == ActionType.atUpdate)
                    ? 'исправление'
                    : 'новый автор',
                style: const TextStyle(
                    fontSize: 30, color: Colors.lightBlueAccent),
              ),
              const Text('имя', style: kTextStyleLabel,),
              Container(
                decoration: kInputBoxDecoration,
                child: TextField(
                  decoration: kInputFieldDecoration,
                  controller: _controllerRus,
                  autofocus: true,
                  textAlign: TextAlign.start,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    widget.author.nameRus = value;
                  },
                ),
              ),
              const Text('на языке оригинала', style: kTextStyleLabel,),
              Container(
                decoration: kInputBoxDecoration,
                child: TextField(
                  decoration: kInputFieldDecoration,
                  controller: _controllerOrig,
                  autofocus: true,
                  textAlign: TextAlign.start,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    widget.author.nameOrig = value;
                  },
                ),
              ),

              API.answerButtons(context, pressOk),

            ]),
      ),
    );
  }
}
