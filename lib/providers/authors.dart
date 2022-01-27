import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class Author {
  String id;
  String nameRus;
  String nameOrig;
  bool checkState;
  bool actual;

  Author(
      {this.id = '',
      this.nameRus = '',
      this.nameOrig = '',
      this.actual = true,
      this.checkState = false});

  @override
  String toString() {
     return 'id:$id nameRus:$nameRus nameOrig:$nameOrig actual:${actual.toString()}';
  }

    void setCheckState(bool value) {
    checkState = value;
  }

  String get sActual{
    return actual?'1':'0';
  }

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'].toString(),
      nameRus: json['nameRus'],
      nameOrig: json['nameOrig'],
      actual: (json['actual'] == 1),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameRus': nameRus,
        'nameOrig': nameOrig,
        'actual' : sActual,
      };

  void actualOnServer() async {
    final url = Uri.parse('${prefixURL}do_actual_nsi.php?idx=4&val=$sActual&id=$id');
    try {
      final response = await http.get(url);
    } catch (error) {
      rethrow;
    }
  }

  void modifyOnServer(ActionType actionType) async {
    final Map<String, dynamic> queryParam = toJson();
    final String queryString = Uri(queryParameters: queryParam).query;
    final url = Uri.parse('${prefixURL}do_update_authors.php?$queryString');
    //print(url);
    try {
      final response = await http.get(url);
      //если вставляли, прочитаем новый pk c сервера и исправим его здесь
      if (actionType == ActionType.atInsert) {
        dynamic infoJson = json.decode(response.body);
        id = infoJson['workId'].toString();
      }
    } catch (error) {
      rethrow;
    }
  }

}

class Authors extends ChangeNotifier {
  List<Author> _items = [];

  List<Author> get items {
    return [..._items];
  }

  List<Author> get itemsActual {
    return [..._items.where((element) => element.actual)];
  }

  List<Author> get itemsChecked {
    return [..._items.where((element) => element.checkState)];
  }

  bool get emptyChecked {
    return itemsChecked.isEmpty;
  }

  Future<void> mergingAuthors(String mainCode) async {
    String mergeCodes = codeCheckString;
    //print('$mergeCodes => $mainCode');
    for (Author element in _items) {
      element.checkState = false;
    }
    final url = Uri.parse('${prefixURL}do_merge_author.php?src=$mergeCodes&dst=$mainCode');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        //print(response.body);
      }
    } catch (error) {
      rethrow;
    }
  }

  List<Author> getFilteredAuthors(String s){
    if (s=='') {
      return _items; 
    } 
    else {
      //List<Author> result = [];
      return [..._items.where((element) => element.nameRus.toUpperCase().contains(s.toUpperCase()))];   
      //return result;
    }
  }
  
  Future<void> loadAuthors() async {
    _items = [];
    final url = Uri.parse('${prefixURL}get_author.php');
    //print(url);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> loadJson = json.decode(response.body);
        final _loadedInfo =
            loadJson.map((json) => Author.fromJson(json)).toList();
        _items = _loadedInfo;
      }
    } catch (error) {
      rethrow;
    }
  }

  updateAuthor(Author author) {
    Author currentItem =
        _items.firstWhere((element) => element.id == author.id);
    currentItem.modifyOnServer(ActionType.atUpdate);
    notifyListeners();
  }

  insertAuthor(Author author) {
    final newItem =
        Author(id: '0', nameRus: author.nameRus, nameOrig: author.nameOrig, actual: true);
    _items.add(newItem);
    //TODO попробовать просто _items.add(author);
    newItem.modifyOnServer(ActionType.atInsert);
    notifyListeners();
  }

  String get codeCheckString {
    String s = '';
    for (Author element in _items.where((element) => element.checkState)) {
      s += '${element.id},';
    }
    return (s.isNotEmpty)?s.substring(0, s.length-1):'';
    //return s;
  }

}
