import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const prefixURL = 'http://91.237.235.227:8012/books/';

enum ActionType {
  atUpdate,
  atInsert,
}

enum AuthorListType {
  altAll,
  altActual,
  altChecked
}

enum BookListMode {
  blmOverview,
  blmSeries
}



const kTextStyleLabel = TextStyle(
  color: Colors.lightBlueAccent,
  //fontStyle: FontStyle.italic,
);

const Color kInputColor = Color(0xFFBDBDBD);

class NsiRecord {
  final String id;
  final String name;
  NsiRecord({required this.id, required this.name});

  @override
  String toString(){
    return 'id:$id  name:$name ';
  }

  factory NsiRecord.fromJson(Map<String, dynamic> json) {
    return NsiRecord(
      id: json['id'].toString(),
      name: json['name'],
    );
  }

}

const kTextStylePopUp = TextStyle(
  color: Colors.blue,
  fontSize: 18,
  overflow: TextOverflow.ellipsis,
);

const kBoxDecorationComboBox = BoxDecoration(
        color: kInputColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(15)),
        border:kBorderAllBlue,
);

const kBorderAllBlueAccent = Border(
  top: BorderSide(color: Colors.lightBlueAccent, width: 1 ),
  left: BorderSide(color: Colors.lightBlueAccent, width: 1),
  bottom: BorderSide(color: Colors.lightBlueAccent, width: 1),
  right: BorderSide(color: Colors.lightBlueAccent, width: 1),
);

const kBorderAllBlue = Border(
  top: BorderSide(color: Colors.lightBlue, width: 1 ),
  left: BorderSide(color: Colors.lightBlue, width: 1),
  bottom: BorderSide(color: Colors.lightBlue, width: 1),
  right: BorderSide(color: Colors.lightBlue, width: 1),
);

const kBoxDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  ),
);

const kInputBoxDecoration = BoxDecoration(
  color: Color(0xFFBDBDBD), //Colors.grey[400],
  border: kBorderAllBlue,
  borderRadius: BorderRadius.all(
    Radius.circular(10.0),
  ),
);

const kInputFieldDecoration = InputDecoration(
  focusedBorder: InputBorder.none,
  enabledBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
);

class API {
  API() : super();

  static String rusDate(DateTime dt, [String prefix = '']) {
    return (dt.isAfter(DateTime(2000, 2, 2)))
        ? prefix + DateFormat.yMMMd('ru').format(dt)
        : 'не изв';
  }


  static ButtonStyle buttonStyle(bool yes) {
    return ElevatedButton.styleFrom(
        primary: yes ? Colors.green : Colors.red,
        onPrimary: Colors.white,
        elevation: 10);
  }

  static Widget answerButtons(BuildContext context, Function() onPressOk) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('   отмена   ')),
        ElevatedButton(onPressed: onPressOk, child: const Text('запомнить')),
      ],
    );
  }

  static Future<void> displayTextInputDialog(
      BuildContext context,
      TextEditingController controller,
      String title,
      String hint,
      TextInputType textInputType,
      double fontSize,
      Function onChanged) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              style: TextStyle(fontSize: fontSize),
              keyboardType: textInputType,
              onChanged: (value) {
                onChanged(value);
              },
              controller: controller,
              decoration: InputDecoration(hintText: hint),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: buttonStyle(false),
                child: Text('ОТМЕНА'),
                onPressed: () {
                  onChanged('');
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                style: buttonStyle(true),
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
