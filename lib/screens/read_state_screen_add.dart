import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/read_state.dart';

class AddReadStateScreen extends StatefulWidget {
  final ReadState readState;

  AddReadStateScreen(this.readState);

  @override
  State<AddReadStateScreen> createState() => _AddReadStateScreenState();
}

class _AddReadStateScreenState extends State<AddReadStateScreen> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerOrder = TextEditingController();
  late ActionType actionType;
  @override
  void initState() {
    super.initState();
    _controllerName.text = widget.readState.name;
    _controllerOrder.text = widget.readState.orderNumber;
    actionType = widget.readState.id == '0'?ActionType.atInsert:ActionType.atUpdate;
  }

  @override
  void dispose() {
    super.dispose();
    _controllerName.dispose();
    _controllerOrder.dispose();
  }

  void pressOk() {
    if (actionType == ActionType.atUpdate) {
      Provider.of<ReadStates>(context, listen: false).updateReadState(
          widget.readState);
    } else {
      Provider.of<ReadStates>(context, listen: false)
          .insertReadState(widget.readState);
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
                (actionType == ActionType.atUpdate)
                    ? 'исправление'
                    : 'новый этап',
                style: const TextStyle(
                    fontSize: 30, color: Colors.lightBlueAccent),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: kInputBoxDecoration,
                      child: TextField(
                        decoration: kInputFieldDecoration,

                        controller: _controllerOrder,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          widget.readState.orderNumber = value;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: kInputBoxDecoration,
                      child: TextField(
                        decoration: kInputFieldDecoration,
                        controller: _controllerName,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          widget.readState.name = value;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              API.answerButtons(context, pressOk),
            ]),
      ),
    );
  }
}
