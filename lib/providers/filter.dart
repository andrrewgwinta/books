import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterData {
  String fltName;
  String fltAuthor;
  String fltGenres;
  String fltState;
  String fltSeries;
  bool fltActual;
  bool fltAuthorActual;
  bool fltExpandedState;

  FilterData({
    this.fltName = '',
    this.fltAuthor = '',
    this.fltGenres = '',
    this.fltState = '',
    this.fltSeries = '',
    this.fltActual = true,
    this.fltAuthorActual = true,
    this.fltExpandedState = false,
  });

  @override
  String toString() {
    return 'fltName=$fltName  fltAuthor=$fltAuthor fltGenres=$fltGenres  fltState=$fltState fltActual=$fltActual fltAuthorActual=$fltAuthorActual fltExpandedState=$fltExpandedState fltSeries=$fltSeries';
  }

  Map<String, dynamic> toJson() => {
        'fltName': fltName,
        'fltAuthor': fltAuthor,
        'fltGenres': fltGenresForServer,
         'fltSeries':fltSeries,
        'fltState': fltExpandedState?fltState:'',
        'act': fltActual ? '1' : '0',
      };

  String get fltGenresForServer {
    return fltGenres.isEmpty
        ? ''
        : fltGenres.substring(2, fltGenres.length - 2).replaceAll('^^', ',');
  }
}

class Filter with ChangeNotifier {
  FilterData filter = FilterData(
      fltName: '',
      fltAuthor: '',
      fltGenres: '',
      fltState: '',
      fltActual: true,
      fltAuthorActual: true);

  void clearFilter() {
    filter.fltName = '';
    filter.fltAuthor = '';
    filter.fltGenres = '';
    filter.fltState = '';
    filter.fltActual = true;
    filter.fltExpandedState = false;
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> readFilterData() async {
    final prefs = await _prefs;
    FilterData emptyData = FilterData(
        fltName: '',
        fltAuthor: '',
        fltGenres: '',
        fltState: '',
        fltActual: true,
        fltAuthorActual: true,
        fltExpandedState: false);

    try {
      final extractedFilterData =
          json.decode(prefs.getString('filterData')!) as Map<String, dynamic>;
      if ((prefs != null) && (prefs.containsKey('filterData'))) {
        filter = FilterData(
            fltName: extractedFilterData['fltName'].toString(),
            fltAuthor: extractedFilterData['fltAuthor'].toString(),
            fltGenres: extractedFilterData['fltGenres'].toString(),
            fltState: extractedFilterData['fltState'].toString(),
            fltActual: (extractedFilterData['fltActual'] == 'true'),
            fltAuthorActual: true,
            fltExpandedState:
                (extractedFilterData['fltExpandedState'] == 'true'));
      } else {
        filter = emptyData;
      }
    } catch (error) {
      filter = emptyData;
    }
  }

  Future<void> saveFilterData() async {
    final prefs = await _prefs;
    final filterData = json.encode({
      'fltName': filter.fltName,
      'fltAuthor': filter.fltAuthor,
      'fltGenres': filter.fltGenres,
      'fltState': filter.fltState,
      'fltActual': filter.fltActual.toString(),
      'fltExpandedState': filter.fltExpandedState.toString(),
    });
    prefs.setString('filterData', filterData);
  }
}
