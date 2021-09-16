import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../screens/read_state_screen_add.dart';
import '../constants.dart';

class ReadState {
  String id;
  String name;
  String orderNumber;
  bool actual;

  ReadState({this.id='', this.name='', this.orderNumber = '', this.actual=true});

  factory ReadState.fromJson(Map<String, dynamic> json) {
    return ReadState(
      id: json['id'].toString(),
      name: json['name'],
      orderNumber : json['npp'].toString(),
      actual: (json['actual'] == 1)
    );
  }

  String get sActual => actual ? '1' : '0';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'npp':orderNumber,
    'actual':sActual,
  };

  @override
  String toString() {
    return 'id:$id name:$name orderNumber:$orderNumber actual:${actual.toString()}';
  }

  void actualOnServer() async {
    final url = Uri.parse('${prefixURL}do_actual_nsi.php?idx=2&val=$sActual&id=$id');
    try {
      final response = await http.get(url);
    } catch (error) {
      rethrow;
    }
  }

  void modifyOnServer(ActionType actionType) async {
    final Map<String, dynamic> queryParam = toJson();
    final String queryString = Uri(queryParameters: queryParam).query;
    final url = Uri.parse('${prefixURL}do_update_state.php?$queryString');
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

class ReadStates extends ChangeNotifier {
  List<ReadState> _items = [];

  List<ReadState> get items => [..._items];

  List<ReadState> get itemsActual => [..._items.where((element) => element.actual)];
  

  Future<void> loadReadState() async {
    _items = [];
    final url = Uri.parse('${prefixURL}get_state.php');
    try {

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> loadJson = json.decode(response.body);
        final _loadedInfo =
        loadJson.map((json) => ReadState.fromJson(json)).toList();
        _items = _loadedInfo;
      }
    } catch (error) {
      rethrow;
    }
  }

  // deleteReadState(ReadState readState) {
  //   readState.deleteOnServer();
  //   _items.remove(readState);
  //   notifyListeners();
  // }

  updateReadState(ReadState readState) {
    ReadState currentItem = _items.firstWhere((element) => element.id == readState.id);
    // currentItem.name = readState.name;
    // currentItem.orderNumber = readState.orderNumber;
    currentItem.modifyOnServer(ActionType.atUpdate);
    notifyListeners();
  }

  insertReadState(ReadState readState) {
    //final newItem = ReadState(id:'0', name: newName, orderNumber: newNpp);
    _items.add(readState);
    readState.modifyOnServer(ActionType.atInsert);
    notifyListeners();
  }

  List<NsiRecord> getListMap() {
    List<NsiRecord> result = [];
    for (var data in itemsActual) {
      result.add(NsiRecord(id: data.id, name: data.name));
    }
    return result;
  }

  NsiRecord firstState(){
    ReadState firstState=_items[0];
    for (var element in _items) {
      if (int.parse(element.orderNumber) < int.parse(firstState.orderNumber)) {
         firstState = element;
      }
    }
    return(NsiRecord(id:firstState.id, name:firstState.name));
  }

  String getNameById(String index){
    return _items.firstWhere((element) => element.id==index).name;
  }

}
