import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/genres.dart';

class AddGenreScreen extends StatefulWidget {
  final ActionType actionType;
  String index;
  String genreName;

  AddGenreScreen({Key? key, required this.actionType, required this.genreName, this.index ='0'})
      : super(key: key);

  @override
  State<AddGenreScreen> createState() => _AddGenreScreenState();
}

class _AddGenreScreenState extends State<AddGenreScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.genreName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void pressOk(){
    if (widget.actionType == ActionType.atUpdate) {
      Provider.of<Genres>(context, listen: false)
          .updateGenre(widget.index, widget.genreName);
    } else {
      Provider.of<Genres>(context, listen: false)
          .insertGenre(widget.genreName);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff757575),
      child: Container(
        height: 170,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: kBoxDecoration,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                (widget.actionType == ActionType.atUpdate)
                    ? 'исправление'
                    : 'новый жанр',
                style: const TextStyle(
                    fontSize: 30, color: Colors.lightBlueAccent),
              ),
              Container(
                decoration: kInputBoxDecoration,
                child: TextField(
                  decoration: kInputFieldDecoration,
                  controller: _controller,
                  autofocus: true,
                  textAlign: TextAlign.start,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    widget.genreName = value;
                  },
                ),
              ),
              API.answerButtons(context, pressOk),

            ]),
      ),
    );
  }
}
