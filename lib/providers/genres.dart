import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class Genre {
  String id;
  String name;
  bool checkState;
  bool actual;

  Genre(
      {this.id = '',
      this.name = '',
      this.checkState = false,
      this.actual = true});

  String get sActual {
    return actual ? '1' : '0';
  }

  void setCheckState(bool value) {
    checkState = value;
  }
  @override

  String toString() {
    return 'id:$id name:$name actual:${actual.toString()}';
  }


  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'].toString(),
      name: json['name'],
      actual: (json['actual'] == 1),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'actual': sActual,
      };

  void actualOnServer() async {
    final url = Uri.parse('${prefixURL}do_actual_nsi.php?idx=1&val=$sActual&id=$id');
    try {
      final response = await http.get(url);
    } catch (error) {
      rethrow;
    }
  }

  // void deleteOnServer() async {
  //   final url = Uri.parse('${prefixURL}do_actual_nsi.php?idx=1&val=0&id=$id');
  //   try {
  //     final response = await http.get(url);
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

  void modifyOnServer(ActionType actionType) async {
    final Map<String, dynamic> queryParam = toJson();
    final String queryString = Uri(queryParameters: queryParam).query;
    final url = Uri.parse('${prefixURL}do_update_genre.php?$queryString');

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

class Genres extends ChangeNotifier {
  List<Genre> _items = [];

  List<Genre> get items {
    return [..._items];
  }

  List<Genre> get itemsActual {
    return [..._items.where((element) => element.actual)];
  }


  Future<void> loadGenres() async {
    _items = [];
    final url = Uri.parse('${prefixURL}get_genres.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> loadJson = json.decode(response.body);
        final _loadedInfo =
            loadJson.map((json) => Genre.fromJson(json)).toList();
        _items = _loadedInfo;
      }
    } catch (error) {
      rethrow;
    }
  }

  // deleteGenre(Genre genre) {
  //   genre.deleteOnServer();
  //   _items.remove(genre);
  //   notifyListeners();
  // }

  updateGenre(String index, String newName) {
    Genre currentItem = _items.firstWhere((element) => element.id == index);
    currentItem.name = newName;
    currentItem.modifyOnServer(ActionType.atUpdate);
    notifyListeners();
  }

  insertGenre(String newName) {
    final newItem = Genre(id: '0', name: newName);
    _items.add(newItem);
    newItem.modifyOnServer(ActionType.atInsert);
    notifyListeners();
  }

  void setCheckedValue(String valueString) {
    for (Genre element in _items) {
      element.checkState = valueString.contains('^${element.id}^');
    }
  }

  void setElementChecked(Genre genre, bool value) {
    genre.setCheckState(value);
    notifyListeners();
  }
  String get codeCheckString {
    String s = '^^';
    for (Genre element in _items.where((element) => element.checkState)) {
      s += '${element.id}^^';
    }
    return s=='^^'?'':s;
  }


  String get nameCheckString {
    String s = '';
    for (Genre element in _items.where((element) => element.checkState)) {
      s += '${element.name}, ';
    }
    return s.isEmpty?'':s.substring(0, s.length - 2);
  }

  String get codeCheckStringForServer {
    String s = '';
    for (Genre element in _items.where((element) => element.checkState)) {
      s += '${element.id},';
    }
    return s.substring(0, s.length - 1);
  }
}
