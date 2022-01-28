import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/filter.dart';
import '../providers/series.dart';
import '../providers/read_state.dart';

class Book {
  String id;
  String? nameRus;
  String? nameOriginal;
  int? grade;
  String? note;
  String? stateId;
  String? stateName;
  String? genreCodeId;
  String? genreCodeName;
  String? authorId;
  String? authorName;
  DateTime? dateInit;
  bool actual;
  bool checked;
  String? seriesId;
  String? seriesName;
  String? seriesSeq;

  Book({
    required this.id,
    this.nameRus,
    this.nameOriginal,
    this.grade,
    this.note,
    this.stateId,
    this.stateName,
    this.genreCodeId,
    this.genreCodeName,
    this.authorId,
    this.authorName,
    this.actual = true,
    this.dateInit,
    this.checked = false,
    this.seriesId,
    this.seriesName,
    this.seriesSeq,
  });

  String get sActual {
    return actual ? '1' : '0';
  }

  bool get noSeries {
    return (seriesId == '');
  }

  bool get inSeries {
    return (seriesId != '');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameRus': nameRus,
        'nameOriginal': nameOriginal,
        'grade': grade.toString(),
        'note': note,
        'stateId': stateId,
        'genreCode': serverCodeId,
        'authorName': authorName,
        'actual': sActual,
        'seriesId': seriesId,
        'seriesSeq': seriesSeq,
      };

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'].toString(),
      nameRus: json['nameRus'],
      nameOriginal: json['nameOriginal'] ?? '',
      grade: json['grade'],
      note: json['note'] ?? '',
      stateId: json['stateId'].toString(),
      stateName: json['stateName'],
      // genreCodeId: (json['genreCodeId'] == null)?'':json['genreCodeId'],
      // genreCodeName: (json['genreCodeName'] == null)?'':json['genreCodeName'],
      genreCodeId: json['genreCodeId'] ?? '',
      genreCodeName: json['genreCodeName'] ?? '',
      authorId: json['authorId'].toString(),
      authorName: json['authorName'].toString(),
      actual: (json['actual'] == 1),
      dateInit: (json['dateInit'] != null)
          ? DateTime.parse(json['dateInit'])
          : DateTime(2000, 1, 1),
      seriesId: (json['seriesId'] ?? '').toString() ,
      seriesName: json['seriesName'] ?? '',
      seriesSeq : (json['seriesSeq'] ?? '').toString(),

    );
  }

  void actualOnServer(int value) async {
    final url =
        Uri.parse('${prefixURL}do_actual_nsi.php?idx=3&val=$value&id=$id');
    try {
      final response = await http.get(url);
    } catch (error) {
      rethrow;
    }
  }

  String get serverCodeId {
    return genreCodeId!.isEmpty
        ? ''
        : genreCodeId!
            .substring(2, genreCodeId!.length - 2)
            .replaceAll('^^', ',');
  }

  void modifyOnServer() async {
    // final ActionType actionType =
    //     (id == '0') ? ActionType.atInsert : ActionType.atUpdate;
    final Map<String, dynamic> queryParam = toJson();
    final String queryString = Uri(queryParameters: queryParam).query;
    final url = Uri.parse('${prefixURL}do_update_book.php?$queryString');
    //print(url);
    try {
      final response = await http.get(url);
      //если вставляли, прочитаем новый pk c сервера и исправим его здесь
      //if (actionType == ActionType.atInsert) {
      dynamic infoJson = json.decode(response.body);
      id = infoJson['workId'].toString();
      //print('id in modifyOnServer $id');
      //}
      authorId = infoJson['authorId'].toString();
    } catch (error) {
      rethrow;
    }
  }
}

class Books extends ChangeNotifier {
  List<Book> _items = [];

  List<Book> get items {
    return [..._items];
  }

  List<Book> get itemsChecked {
    return [..._items.where((element) => element.checked)];
  }

  bool get emptyChecked {
    return itemsChecked.isEmpty;
  }

  NsiRecord firstCheckedAuthor() {
    if (emptyChecked) {
      return NsiRecord(id: '', name: '');
    } else {
      return NsiRecord(
        id: itemsChecked[0].authorId!,
        name: itemsChecked[0].authorName!,
      );
    }
  }

  Future<void> loadBooks(FilterData filter) async {
    _items = [];
    final Map<String, dynamic> queryParam = filter.toJson();
    final String queryString = Uri(queryParameters: queryParam).query;
    final url = Uri.parse('${prefixURL}get_books.php?$queryString');
    //print(url);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> loadJson = json.decode(response.body);
        final _loadedInfo =
            loadJson.map((json) => Book.fromJson(json)).toList();
        _items = _loadedInfo;
      }
    } catch (error) {
      rethrow;
    }
  }

  deleteBook(Book book) {
    book.actualOnServer(0);
    _items.remove(book);
    notifyListeners();
  }

  restoreBook(Book book) {
    book.actual = true;
    book.actualOnServer(1);
    notifyListeners();
  }

  Book copyBook(Book source) {
    final newBook = clone(source, '(копия)');
    newBook.id = '0';
    insertBook(newBook);
    notifyListeners();
    return newBook;
  }

  Book clone(Book source, [String suffix = '']) {
    return Book(
      id: '0',
      nameRus: '${source.nameRus} $suffix',
      nameOriginal: source.nameOriginal,
      grade: source.grade,
      note: source.note,
      stateId: source.stateId,
      stateName: source.stateName,
      genreCodeName: source.genreCodeName,
      genreCodeId: source.genreCodeId,
      authorId: source.authorId,
      authorName: source.authorName,
      dateInit: source.dateInit,
      actual: source.actual,
      seriesId: source.seriesId,
      seriesName: source.seriesName,
      seriesSeq: source.seriesSeq
    );
  }

  Book createEmpty(BuildContext context) {
    NsiRecord firstState =
        Provider.of<ReadStates>(context, listen: false).firstState();
    return Book(
      id: '0',
      nameRus: '',
      nameOriginal: '',
      grade: 0,
      note: '',
      stateId: firstState.id,
      stateName: firstState.name,
      genreCodeName: '',
      genreCodeId: '',
      authorId: '0',
      authorName: '',
      dateInit: DateTime.now(),
      actual: true,
      seriesId: '',
      seriesName: '',
      seriesSeq: ''
    );
  }

  insertBook(Book newBook) {
    _items.add(newBook);
    newBook.modifyOnServer();
    notifyListeners();
  }

  updateBook(Book book) {
    Book currentItem = _items.firstWhere((element) => element.id == book.id);
    currentItem.modifyOnServer();
    notifyListeners();
  }

  unCheckedAll() {
    for (var element in _items) {
      element.checked = false;
    }
    notifyListeners();
  }

  String get codeCheckString{
      String s = '^^';
      for (Book element in _items.where((element) => element.checked)) {
        s += '${element.id}^^';
      }
      return s=='^^'?'':s;
    }


  String get codeCheckStringForServer {
    String s = '';
    for (Book element in _items.where((element) => element.checked)) {
      s += '${element.id},';
    }
    return s.substring(0, s.length - 1);
  }

  void cleanSeries(String id){
    for (Book element in _items.where((element) => (element.seriesId == id))){
      element.seriesId = '';
      element.seriesName = '';
      element.seriesSeq = '';
    }
  }

  refreshSeries(String bookCodeList, SeriesItem series) {
    for (Book element in _items.where((element) => bookCodeList.contains('^${element.id}^'))) {
      element.seriesId = series.id;
      element.seriesName = series.name;
    }
  }

}

