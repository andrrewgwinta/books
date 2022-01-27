import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/books.dart';

class SeriesItem {
  String id;
  String name;
  String authorId;
  String authorName;
  String bookCount;

  //bool actual;

  SeriesItem({
    this.id = '0',
    this.name = '',
    this.authorId = '',
    this.authorName = '',
    this.bookCount = '0',
    //this.actual=true,
  });

  //String get sActual => actual ? '1' : '0';

  factory SeriesItem.fromJson(Map<String, dynamic> json) {
    return SeriesItem(
      id: json['id'].toString(),
      name: json['name'],
      authorId: json['authorId'].toString(),
      authorName: json['authorName'],
      bookCount: json['bookCount'].toString(),
      //actual: (json['actual'] == 1),
    );
  }

  @override
  String toString() {
    return 'id:$id nameRus:$name authorId:$authorId  authorName:$authorName bookCount:$bookCount';
  }


  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'authorId': authorId,
        //'authorName': authorName,
        //'actual': sActual,
      };

  void deleteOnServer() async {
    final url = Uri.parse('${prefixURL}do_delete_series.php?id=$id');
    try {
      final response = await http.get(url);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> insertOnServer(String bookCode) async {
    final Map<String, dynamic> queryParam = toJson();
    final String queryString = Uri(queryParameters: queryParam).query;
    final url = Uri.parse(
        '${prefixURL}do_update_series.php?$queryString&bookCode=$bookCode');

    try {
      final response = await http.get(url);
      //прочитаем новый pk c сервера и исправим его здесь
      dynamic infoJson = json.decode(response.body);
      id = infoJson['workId'].toString();
    } catch (error) {
      rethrow;
    }
  }

  void updateOnServer() async {
    //only NAME
    final url =
        Uri.parse('${prefixURL}do_update_series_name.php?name=$name&id=$id');
    //print(url);
    try {
      final response = await http.get(url);
      //прочитаем новый pk c сервера и исправим его здесь
      dynamic infoJson = json.decode(response.body);
    } catch (error) {
      rethrow;
    }
  }
}

class Series with ChangeNotifier {
  List<SeriesItem> _items = [];

  List<SeriesItem> get items => [..._items];

  //List<SeriesItem> get itemsActual => [..._items.where((element) => element.actual)];

  Future<void> loadSeries() async {
    _items = [];
    final url = Uri.parse('${prefixURL}get_series.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> loadJson = json.decode(response.body);
        final _loadedInfo =
            loadJson.map((json) => SeriesItem.fromJson(json)).toList();
        _items = _loadedInfo;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteSeries(BuildContext context, SeriesItem series) async {
    Provider.of<Books>(context, listen: false).cleanSeries(series.id);
    _items.remove(series);
    series.deleteOnServer();
    notifyListeners();
  }

  Future<void> updateSeries(SeriesItem series) async {
    series.updateOnServer();
    notifyListeners();
  }

  Future<void> createSeries(BuildContext context, SeriesItem series) async {
    final books = Provider.of<Books>(context, listen: false);
    String bookCodeList = books.codeCheckString;
    String bookCodeServer = books.codeCheckStringForServer;

    _items.add(series);
    await series
        .insertOnServer(bookCodeServer)
        .then((_) => books.refreshSeries(bookCodeList, series))
        .then((_) => notifyListeners());
  }
}
